const express = require('express');

const authMiddleware = require('../middleware/authMiddleware');
const {
  createOrganization,
  getMyOrganization,
} = require('../controllers/organizationController');
const router = express.Router();

router.post(
  '/',
  authMiddleware,
  createOrganization
);
router.get(
  '/me',
  authMiddleware,
  getMyOrganization
);
module.exports = router;