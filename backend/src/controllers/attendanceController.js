
const pool = require('../config/database');

const markAttendance = async (req, res) => {
  try {
    const userId = req.user.userId;

    const { latitude, longitude } = req.body;

    // Validate employee location
    if (
      latitude === undefined ||
      longitude === undefined ||
      latitude === null ||
      longitude === null
    ) {
      return res.status(400).json({
        success: false,
        message: 'Location is required to mark attendance',
      });
    }

    // Find employee
    const [employees] = await pool.execute(
      `SELECT id, organization_id
       FROM employees
       WHERE user_id = ?`,
      [userId]
    );

    if (employees.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Employee record not found',
      });
    }

    const employee = employees[0];

    // Get organization location
    const [organizations] = await pool.execute(
      `SELECT id, latitude, longitude
       FROM organizations
       WHERE id = ?`,
      [employee.organization_id]
    );

    if (organizations.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Organization not found',
      });
    }

    const organization = organizations[0];

    if (
      organization.latitude === null ||
      organization.longitude === null
    ) {
      return res.status(400).json({
        success: false,
        message: 'Workplace location is not configured',
      });
    }

    // Convert coordinates to numbers
    const employeeLat = Number(latitude);
    const employeeLng = Number(longitude);
    const organizationLat = Number(organization.latitude);
    const organizationLng = Number(organization.longitude);

    // Validate coordinates
    if (
      !Number.isFinite(employeeLat) ||
      !Number.isFinite(employeeLng)
    ) {
      return res.status(400).json({
        success: false,
        message: 'Invalid location coordinates',
      });
    }

    // Haversine formula
    const toRadians = (value) => (value * Math.PI) / 180;

    const earthRadius = 6371000;

    const latDifference = toRadians(
      organizationLat - employeeLat
    );

    const lngDifference = toRadians(
      organizationLng - employeeLng
    );

    const a =
      Math.sin(latDifference / 2) *
        Math.sin(latDifference / 2) +
      Math.cos(toRadians(employeeLat)) *
        Math.cos(toRadians(organizationLat)) *
        Math.sin(lngDifference / 2) *
        Math.sin(lngDifference / 2);

    const c =
      2 * Math.atan2(
        Math.sqrt(a),
        Math.sqrt(1 - a)
      );

    const distance = earthRadius * c;

    // 100 meter workplace radius
    const allowedRadius = 100;

    if (distance > allowedRadius) {
      return res.status(403).json({
        success: false,
        message: 'You are outside the workplace area',
        distance: Math.round(distance),
        allowedRadius,
      });
    }

    // Check today's attendance
    const [existingAttendance] = await pool.execute(
      `SELECT id, check_in, status
       FROM attendance
       WHERE employee_id = ?
       AND attendance_date = CURDATE()
       LIMIT 1`,
      [employee.id]
    );

    if (existingAttendance.length > 0) {
      return res.status(409).json({
        success: false,
        message: 'Attendance already marked for today',
        attendance: existingAttendance[0],
      });
    }

    // Mark attendance with employee location
    const [result] = await pool.execute(
      `INSERT INTO attendance
       (
         employee_id,
         attendance_date,
         check_in,
         latitude,
         longitude,
         status
       )
       VALUES (?, CURDATE(), NOW(), ?, ?, 'present')`,
      [
        employee.id,
        employeeLat,
        employeeLng,
      ]
    );

    return res.status(201).json({
      success: true,
      message: 'Attendance marked successfully',
      distance: Math.round(distance),
      attendance: {
        id: result.insertId,
        employeeId: employee.id,
        status: 'present',
      },
    });
  } catch (error) {
    console.error('Mark attendance error:', error);

    return res.status(500).json({
      success: false,
      message: 'Failed to mark attendance',
    });
  }
};
const getTodayStats = async (req, res) => {
  try {
    const userId = req.user.userId;

    // Employer ki organization find karo
    const [organizations] = await pool.execute(
      `SELECT id
       FROM organizations
       WHERE owner_id = ?
       LIMIT 1`,
      [userId]
    );

    if (organizations.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Organization not found',
      });
    }

    const organizationId = organizations[0].id;

    // Total employees
    const [employeeResult] = await pool.execute(
      `SELECT COUNT(*) AS total
       FROM employees
       WHERE organization_id = ?`,
      [organizationId]
    );

    // Today's present employees
    const [presentResult] = await pool.execute(
      `SELECT COUNT(*) AS total
       FROM attendance a
       INNER JOIN employees e
         ON e.id = a.employee_id
       WHERE e.organization_id = ?
       AND a.attendance_date = CURDATE()
       AND a.status = 'present'`,
      [organizationId]
    );

    // Today's absent employees
    const [absentResult] = await pool.execute(
      `SELECT COUNT(*) AS total
       FROM employees e
       WHERE e.organization_id = ?
       AND NOT EXISTS (
         SELECT 1
         FROM attendance a
         WHERE a.employee_id = e.id
         AND a.attendance_date = CURDATE()
       )`,
      [organizationId]
    );

    // Today's leave
    const [leaveResult] = await pool.execute(
      `SELECT COUNT(*) AS total
       FROM attendance a
       INNER JOIN employees e
         ON e.id = a.employee_id
       WHERE e.organization_id = ?
       AND a.attendance_date = CURDATE()
       AND a.status = 'leave'`,
      [organizationId]
    );

    return res.status(200).json({
      success: true,
      stats: {
        employees: employeeResult[0].total,
        present: presentResult[0].total,
        absent: absentResult[0].total,
        onLeave: leaveResult[0].total,
      },
    });
  } catch (error) {
    console.error('Get today stats error:', error);

    return res.status(500).json({
      success: false,
      message: 'Failed to fetch attendance statistics',
    });
  }
};

module.exports = {
  markAttendance,
  getTodayStats,
};