const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const pool = require('../config/database');

const signup = async (req, res) => {
  try {
    const { fullName, mobile, password, role } = req.body;

    // Validate required fields
    if (!fullName || !mobile || !password || !role) {
      return res.status(400).json({
        success: false,
        message: 'All fields are required',
      });
    }

    // Validate role
    if (!['employer', 'employee'].includes(role)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid role',
      });
    }

    // Validate mobile number
    if (!/^[0-9]{10}$/.test(mobile)) {
      return res.status(400).json({
        success: false,
        message: 'Mobile number must be 10 digits',
      });
    }

    // Check whether mobile already exists
    const [existingUsers] = await pool.execute(
      'SELECT id FROM users WHERE mobile = ?',
      [mobile]
    );

    if (existingUsers.length > 0) {
      return res.status(409).json({
        success: false,
        message: 'An account with this mobile number already exists',
      });
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 12);

    // Create user
    const [result] = await pool.execute(
      `INSERT INTO users
       (full_name, mobile, password_hash, role)
       VALUES (?, ?, ?, ?)`,
      [fullName.trim(), mobile, passwordHash, role]
    );

    // Create JWT
    const token = jwt.sign(
      {
        userId: result.insertId,
        role,
      },
      process.env.JWT_SECRET,
      {
        expiresIn: '7d',
      }
    );

    return res.status(201).json({
      success: true,
      message: 'Account created successfully',
      token,
      user: {
        id: result.insertId,
        fullName: fullName.trim(),
        mobile,
        role,
      },
    });
  } catch (error) {
    console.error('Signup error:', error);

    return res.status(500).json({
      success: false,
      message: 'Something went wrong while creating the account',
    });
  }
};
const login = async (req, res) => {
  try {
    const { mobile, password } = req.body;

    if (!mobile || !password) {
      return res.status(400).json({
        success: false,
        message: 'Mobile and password are required',
      });
    }

    const [users] = await pool.execute(
      `SELECT
          u.id,
          u.full_name,
          u.mobile,
          u.password_hash,
          u.role,
          o.id AS organization_id,
          o.name AS organization_name,
          o.invite_code
      FROM users u
      LEFT JOIN employees e
          ON e.user_id = u.id
      LEFT JOIN organizations o
          ON o.id = e.organization_id
      WHERE u.mobile = ?`,
      [mobile]
    );

    if (users.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Invalid mobile number or password',
      });
    }

    const user = users[0];

    const passwordMatch = await bcrypt.compare(
      password,
      user.password_hash
    );

    if (!passwordMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid mobile number or password',
      });
    }

    const token = jwt.sign(
      {
        userId: user.id,
        role: user.role,
      },
      process.env.JWT_SECRET,
      {
        expiresIn: '7d',
      }
    );

    return res.status(200).json({
      success: true,
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        fullName: user.full_name,
        mobile: user.mobile,
        role: user.role,
        organizationId: user.organization_id,
        organizationName: user.organization_name,
        inviteCode: user.invite_code,
      },
    });
  } catch (error) {
    console.error('Login error:', error);

    return res.status(500).json({
      success: false,
      message: 'Something went wrong while logging in',
    });
  }
};
module.exports = {
  signup,
  login,
};