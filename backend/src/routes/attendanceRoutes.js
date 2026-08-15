const express = require('express');

const {
  markAttendance,
  getTodayStats,
  getEmployeeHistory,
  getEmployerDayHistory,
  getEmployerEmployeeHistory,
} = require('../controllers/attendanceController');

const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.post('/mark', authMiddleware, markAttendance);

router.get('/today-stats', authMiddleware, getTodayStats);

// Employee: own attendance history
router.get(
  '/employee-history',
  authMiddleware,
  getEmployeeHistory
);

// Employer: day-wise attendance
router.get(
  '/day-history',
  authMiddleware,
  getEmployerDayHistory
);

// Employer: employee-wise attendance
router.get(
  '/employee/:employeeId/history',
  authMiddleware,
  getEmployerEmployeeHistory
);

module.exports = router;