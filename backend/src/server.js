require('dotenv').config();

const express = require('express');
const cors = require('cors');
const organizationRoutes = require('./routes/organizationRoutes');
const pool = require('./config/database');
const employeeRoutes = require('./routes/employeeRoutes');
const app = express();
const authRoutes = require('./routes/authRoutes');
const attendanceRoutes = require('./routes/attendanceRoutes');
app.use(cors());
app.use(express.json());
app.use('/api/auth', authRoutes);
app.use('/api/organizations', organizationRoutes);
app.use('/api/employees', employeeRoutes);
app.use('/api/attendance', attendanceRoutes);
app.get('/', (req, res) => {
  res.json({
    message: 'Attendance API is running',
  });
});

app.get('/api/health', async (req, res) => {
  try {
    const connection = await pool.getConnection();

    await connection.query('SELECT 1');

    connection.release();

    res.json({
      success: true,
      message: 'API and MySQL are connected',
    });
  } catch (error) {
    console.error('Database connection error:', error);

    res.status(500).json({
      success: false,
      message: 'Database connection failed',
    });
  }
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Attendance API running on port ${PORT}`);
});