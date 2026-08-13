const pool = require('../config/database');
const generateInviteCode = () => {
  const characters = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  let code = '';

  for (let i = 0; i < 6; i++) {
    code += characters.charAt(
      Math.floor(Math.random() * characters.length)
    );
  }

  return code;
};
const createOrganization = async (req, res) => {
  try {
    // Only employers can create an organization
    if (req.user.role !== 'employer') {
      return res.status(403).json({
        success: false,
        message: 'Only employers can create a workspace',
      });
    }

    const {
      name,
      businessType,
      address,
      latitude,
      longitude,
    } = req.body;

    // Validate required fields
    if (!name || !businessType || !address) {
      return res.status(400).json({
        success: false,
        message: 'Business name, type and address are required',
      });
    }

    // Check whether employer already has a workspace
    const [existingOrganizations] = await pool.execute(
      'SELECT id FROM organizations WHERE owner_id = ?',
      [req.user.userId]
    );

    if (existingOrganizations.length > 0) {
      return res.status(409).json({
        success: false,
        message: 'You already have a workspace',
      });
    }

    // Create organization
   let inviteCode;
    let codeExists = true;

    while (codeExists) {
    inviteCode = generateInviteCode();

    const [existingCode] = await pool.execute(
        'SELECT id FROM organizations WHERE invite_code = ?',
        [inviteCode]
    );

    codeExists = existingCode.length > 0;
    }

    const [result] = await pool.execute(
    `INSERT INTO organizations
    (name, business_type, address, latitude, longitude, owner_id, invite_code)
    VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [
        name.trim(),
        businessType.trim(),
        address.trim(),
        latitude ?? null,
        longitude ?? null,
        req.user.userId,
        inviteCode,
    ]
    );

    // Get created organization
    const [organizations] = await pool.execute(
    `SELECT
        id,
        name,
        business_type,
        address,
        latitude,
        longitude,
        owner_id,
        invite_code,
        created_at
    FROM organizations
    WHERE id = ?`,
    [result.insertId]
    );

    return res.status(201).json({
      success: true,
      message: 'Workspace created successfully',
      organization: organizations[0],
    });
  } catch (error) {
    console.error('Create organization error:', error);

    return res.status(500).json({
      success: false,
      message: 'Something went wrong while creating the workspace',
    });
  }
};
const getMyOrganization = async (req, res) => {
  try {
    const [organizations] = await pool.execute(
    `SELECT
        id,
        name,
        business_type,
        address,
        latitude,
        longitude,
        owner_id,
        invite_code,
        created_at
    FROM organizations
    WHERE owner_id = ?
    LIMIT 1`,
    [req.user.userId]
    );

    if (organizations.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Workspace not found',
      });
    }

    return res.status(200).json({
      success: true,
      organization: organizations[0],
    });
  } catch (error) {
    console.error('Get organization error:', error);

    return res.status(500).json({
      success: false,
      message: 'Something went wrong while fetching workspace',
    });
  }
};

module.exports = {
  createOrganization,
  getMyOrganization,
};