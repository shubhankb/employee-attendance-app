const express = require('express');

const {
  markAttendance,
  getTodayStats,
} = require('../controllers/attendanceController');

const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.post('/mark', authMiddleware, markAttendance);

router.get('/today-stats', authMiddleware, getTodayStats);

module.exports = router;