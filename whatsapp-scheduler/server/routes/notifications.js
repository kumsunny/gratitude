const express = require('express');
const schedule = require('node-schedule');
const axios = require('axios');

const router = express.Router();

const scheduledJobs = {};
let notificationId = 1;
const notifications = [];

const normalizePhoneNumber = (phoneNumber) => phoneNumber.replace(/\D/g, '');

const sendWhatsAppMessage = async (phoneNumber, message) => {
  const normalizedPhoneNumber = normalizePhoneNumber(phoneNumber);

  try {
    const response = await axios.post(
      'https://graph.facebook.com/v25.0/1138687635991168/messages',
      {
        messaging_product: 'whatsapp',
        to: normalizedPhoneNumber,
        type: 'template',
        template: {
          name: 'hello_world',
          language: {
            code: 'en_US',
          },
        },
      },
      {
        headers: {
          Authorization: `Bearer ${process.env.WHATSAPP_API_TOKEN}`,
          'Content-Type': 'application/json',
        },
      }
    );
    return response.data;
  } catch (error) {
    console.error('Error sending WhatsApp message:', error.response?.data || error.message);
    throw error;
  }
};

// Handle preflight for schedule endpoint
router.options('/schedule', (req, res) => {
  console.log('✅ OPTIONS /schedule - Preflight request handled');
  res.status(200).end();
});

// Schedule a notification
router.post('/schedule', (req, res) => {
  console.log('\n📋 POST /schedule - Schedule request received');
  console.log('Request body:', req.body);
  console.log('Request headers:', req.headers);
  
  const { phoneNumber, message, scheduledTime } = req.body;

  if (!phoneNumber || !message || !scheduledTime) {
    console.log('❌ Missing required fields');
    return res.status(400).json({ error: 'Missing required fields: phoneNumber, message, scheduledTime' });
  }

  const id = notificationId++;
  const normalizedPhoneNumber = normalizePhoneNumber(phoneNumber);

  const notification = {
    id,
    phoneNumber: normalizedPhoneNumber,
    message,
    scheduledTime,
    status: 'scheduled',
    createdAt: new Date(),
  };

  const scheduledDate = new Date(scheduledTime);

  if (scheduledDate < new Date()) {
    console.log('⚠️  Time is in the past, sending immediately...');
    sendWhatsAppMessage(normalizedPhoneNumber, message)
      .then(() => {
        notification.status = 'sent';
        notification.sentAt = new Date();
        console.log(`✅ Notification ${id} sent`);
      })
      .catch((error) => {
        notification.status = 'failed';
        notification.error = error.message;
        console.error(`❌ Failed to send notification ${id}`);
      });
  } else {
    const job = schedule.scheduleJob(scheduledDate, async () => {
      console.log(`\n⏰ Time reached! Sending notification ${id}...`);
      try {
        await sendWhatsAppMessage(normalizedPhoneNumber, message);
        notification.status = 'sent';
        notification.sentAt = new Date();
        console.log(`✅ Notification ${id} sent`);
      } catch (error) {
        notification.status = 'failed';
        notification.error = error.message;
        console.error(`❌ Failed to send notification ${id}`);
      }
      delete scheduledJobs[id];
    });

    scheduledJobs[id] = job;
    console.log(`✅ Notification ${id} scheduled for ${scheduledDate}`);
  }

  notifications.push(notification);
  
  res.status(201).json({ 
    message: 'Notification scheduled successfully',
    notification,
    credentialsConfigured: !!process.env.WHATSAPP_API_TOKEN
  });
});

// Handle preflight for list endpoint
router.options('/', (req, res) => {
  console.log('✅ OPTIONS / - Preflight request handled');
  res.status(200).end();
});

router.get('/', (req, res) => {
  console.log('📋 GET / - Fetching notifications list');
  res.json(notifications);
});

// Handle preflight for delete endpoint
router.options('/:id', (req, res) => {
  console.log('✅ OPTIONS /:id - Preflight request handled');
  res.status(200).end();
});

router.delete('/:id', (req, res) => {
  console.log('🗑️  DELETE /:id - Canceling notification:', req.params.id);
  const { id } = req.params;
  const jobId = parseInt(id);

  if (scheduledJobs[jobId]) {
    scheduledJobs[jobId].cancel();
    delete scheduledJobs[jobId];
  }

  const index = notifications.findIndex((n) => n.id === jobId);
  if (index !== -1) {
    notifications.splice(index, 1);
  }

  res.json({ message: 'Notification canceled' });
});

module.exports = router;
