const express = require('express');

const {
  joinOrganization,
  getEmployeeCount,
  getEmployees,
} = require('../controllers/employeeController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/count', authMiddleware, getEmployeeCount);

router.post('/join', joinOrganization);
router.get('/all', authMiddleware, getEmployees);
module.exports = router;