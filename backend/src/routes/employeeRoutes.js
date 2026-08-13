const express = require('express');

const {
  joinOrganization,
  getEmployeeCount,
} = require('../controllers/employeeController');

const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/count', authMiddleware, getEmployeeCount);

router.post('/join', joinOrganization);

module.exports = router;