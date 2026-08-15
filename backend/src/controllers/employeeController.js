const pool = require('../config/database');
const bcrypt = require('bcrypt');

const joinOrganization = async (req, res) => {
  const connection = await pool.getConnection();

  try {
    const {
      fullName,
      mobile,
      password,
      inviteCode,
    } = req.body;

    if (!fullName || !mobile || !password || !inviteCode) {
      return res.status(400).json({
        success: false,
        message: 'Full name, mobile, password and invite code are required',
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters',
      });
    }

    // Find organization using invite code
    const [organizations] = await connection.execute(
      `SELECT id, name
       FROM organizations
       WHERE invite_code = ?
       LIMIT 1`,
      [inviteCode.trim().toUpperCase()]
    );

    if (organizations.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Invalid invite code',
      });
    }

    const organization = organizations[0];

    // Check whether mobile already exists
    const [existingUsers] = await connection.execute(
      `SELECT id, role
       FROM users
       WHERE mobile = ?
       LIMIT 1`,
      [mobile.trim()]
    );

    if (existingUsers.length > 0) {
      return res.status(409).json({
        success: false,
        message: 'An account with this mobile number already exists',
      });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    await connection.beginTransaction();

    // Create employee user account
    const [userResult] = await connection.execute(
      `INSERT INTO users
       (full_name, mobile, password_hash, role)
       VALUES (?, ?, ?, 'employee')`,
      [
        fullName.trim(),
        mobile.trim(),
        passwordHash,
      ]
    );

    // Link employee to organization
    await connection.execute(
      `INSERT INTO employees
       (user_id, organization_id)
       VALUES (?, ?)`,
      [
        userResult.insertId,
        organization.id,
      ]
    );

    await connection.commit();

    return res.status(201).json({
      success: true,
      message: 'Employee joined successfully',
      employee: {
        id: userResult.insertId,
        fullName: fullName.trim(),
        mobile: mobile.trim(),
        organizationId: organization.id,
        organizationName: organization.name,
      },
    });
  } catch (error) {
    await connection.rollback();

    console.error('Join organization error:', error);

    return res.status(500).json({
      success: false,
      message: 'Something went wrong while joining the organization',
    });
  } finally {
    connection.release();
  }
};
const getEmployeeCount = async (req, res) => {
  try {
    const [organizations] = await pool.execute(
      `SELECT id
       FROM organizations
       WHERE owner_id = ?
       LIMIT 1`,
      [req.user.userId]
    );

    if (organizations.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Organization not found',
      });
    }

    const organizationId = organizations[0].id;

    const [rows] = await pool.execute(
      `SELECT COUNT(*) AS employee_count
       FROM employees
       WHERE organization_id = ?`,
      [organizationId]
    );

    return res.status(200).json({
      success: true,
      employeeCount: rows[0].employee_count,
    });
  } catch (error) {
    console.error('Get employee count error:', error);

    return res.status(500).json({
      success: false,
      message: 'Failed to get employee count',
    });
  }
};
const getEmployees = async (req, res) => {
  try {
    const [organizations] = await pool.execute(
      `SELECT id
       FROM organizations
       WHERE owner_id = ?
       LIMIT 1`,
      [req.user.userId]
    );

    if (organizations.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Organization not found',
      });
    }

    const organizationId = organizations[0].id;

    const [employees] = await pool.execute(
      `SELECT
         e.id,
         u.full_name,
         u.mobile
       FROM employees e
       INNER JOIN users u
         ON u.id = e.user_id
       WHERE e.organization_id = ?
       ORDER BY u.full_name ASC`,
      [organizationId]
    );

    return res.status(200).json({
      success: true,
      employees,
    });
  } catch (error) {
    console.error('Get employees error:', error);

    return res.status(500).json({
      success: false,
      message: 'Failed to fetch employees',
    });
  }
};
module.exports = {
  joinOrganization,
  getEmployeeCount,
  getEmployees,
};