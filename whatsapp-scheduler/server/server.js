const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const notificationRoutes = require('./routes/notifications');

const app = express();

// Manual CORS middleware - Override any other CORS settings
app.use((req, res, next) => {
  const allowedOrigins = [
    'http://localhost:3000',
    'http://127.0.0.1:3000',
    'http://localhost:5001'
  ];
  
  const origin = req.headers.origin;
  
  if (allowedOrigins.includes(origin) || !origin) {
    res.setHeader('Access-Control-Allow-Origin', origin || 'http://localhost:3000');
  }
  
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, Accept');
  res.setHeader('Access-Control-Max-Age', '86400');
  
  // Handle preflight
  if (req.method === 'OPTIONS') {
    console.log('🔧 Manual CORS: Handling OPTIONS preflight');
    return res.status(200).end();
  }
  
  next();
});

// Detailed request logging middleware
app.use((req, res, next) => {
  console.log('\n========== INCOMING REQUEST ==========');
  console.log('Time:', new Date().toISOString());
  console.log('Method:', req.method);
  console.log('URL:', req.url);
  console.log('Origin:', req.headers.origin);
  console.log('Referer:', req.headers.referer);
  console.log('Content-Type:', req.headers['content-type']);
  console.log('All Headers:', JSON.stringify(req.headers, null, 2));
  
  // Log response headers
  const originalSend = res.send;
  res.send = function(data) {
    console.log('Response Status:', res.statusCode);
    console.log('Response Headers:', JSON.stringify(res.getHeaders(), null, 2));
    console.log('======================================\n');
    originalSend.call(this, data);
  };
  
  next();
});

// Body parser middleware
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// API Routes
app.use('/api/notifications', notificationRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'Server is running' });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

const PORT = process.env.SERVER_PORT || 5001;

app.listen(PORT, () => {
  console.log(`🚀 Server is running on http://localhost:${PORT}`);
  console.log(`📝 API endpoint: http://localhost:${PORT}/api/notifications`);
  console.log(`❤️  Health check: http://localhost:${PORT}/api/health`);
});