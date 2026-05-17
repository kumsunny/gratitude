#!/bin/bash

# WhatsApp Notification Scheduler - Complete Automated Setup
# This script sets up the entire project with all files

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_NAME="whatsapp-scheduler"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}========================================"
    echo "$1"
    echo "========================================${NC}\n"
}

print_step() {
    echo -e "${BLUE}[$1/11]${NC} $2"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Main setup
print_header "WhatsApp Notification Scheduler - Complete Setup"

# Step 1: Check Node.js
print_step "1" "Checking Node.js installation..."
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed"
    echo "Please install from https://nodejs.org/"
    exit 1
fi
print_success "Node.js $(node -v) found"

# Step 2: Set npm registry
print_step "2" "Setting npm registry to public npm..."
npm config set registry https://registry.npmjs.org/
print_success "Registry configured"

# Step 3: Create React App
print_step "3" "Creating React application..."
if [ ! -d "$PROJECT_NAME" ]; then
    npx create-react-app "$PROJECT_NAME" --template minimal
    print_success "React app created"
else
    print_warning "Directory '$PROJECT_NAME' already exists"
fi

cd "$PROJECT_NAME"

# Step 4: Install frontend dependencies
print_step "4" "Installing frontend dependencies..."
npm install axios react-datepicker dotenv express cors body-parser node-schedule
print_success "Frontend dependencies installed"

# Step 5: Install dev dependencies
print_step "5" "Installing development dependencies..."
npm install --save-dev nodemon concurrently
print_success "Dev dependencies installed"

# Step 6: Create directory structure
print_step "6" "Creating project structure..."
mkdir -p src/components
mkdir -p src/api
mkdir -p server/routes
print_success "Project directories created"

# Step 7: Create API service file
print_step "7" "Creating API service..."
cat > src/api/api.js << 'EOFAPI'
import axios from 'axios';

const API_URL = 'http://localhost:5000/api';

export const scheduleNotification = async (data) => {
  try {
    const response = await axios.post(`${API_URL}/notifications/schedule`, data);
    return response.data;
  } catch (error) {
    console.error('Error scheduling notification:', error);
    throw error;
  }
};

export const getScheduledNotifications = async () => {
  try {
    const response = await axios.get(`${API_URL}/notifications`);
    return response.data;
  } catch (error) {
    console.error('Error fetching notifications:', error);
    throw error;
  }
};

export const cancelNotification = async (id) => {
  try {
    const response = await axios.delete(`${API_URL}/notifications/${id}`);
    return response.data;
  } catch (error) {
    console.error('Error canceling notification:', error);
    throw error;
  }
};
EOFAPI
print_success "API service created"

# Step 8: Create ScheduleForm component
print_step "8" "Creating ScheduleForm component..."
cat > src/components/ScheduleForm.jsx << 'EOFFORM'
import React, { useState } from 'react';
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';
import { scheduleNotification } from '../api/api';

const ScheduleForm = ({ onNotificationScheduled }) => {
  const [formData, setFormData] = useState({
    phoneNumber: '',
    message: '',
    scheduledTime: new Date(),
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value,
    });
  };

  const handleDateChange = (date) => {
    setFormData({
      ...formData,
      scheduledTime: date,
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setSuccess('');

    try {
      await scheduleNotification({
        ...formData,
        scheduledTime: formData.scheduledTime.toISOString(),
      });
      setSuccess('Notification scheduled successfully!');
      setFormData({
        phoneNumber: '',
        message: '',
        scheduledTime: new Date(),
      });
      onNotificationScheduled();
    } catch (err) {
      setError('Failed to schedule notification. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="schedule-form">
      <h2>Schedule WhatsApp Notification</h2>
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="phoneNumber">Phone Number (with country code)</label>
          <input
            type="text"
            id="phoneNumber"
            name="phoneNumber"
            value={formData.phoneNumber}
            onChange={handleInputChange}
            placeholder="+1234567890"
            required
          />
        </div>

        <div className="form-group">
          <label htmlFor="message">Message</label>
          <textarea
            id="message"
            name="message"
            value={formData.message}
            onChange={handleInputChange}
            placeholder="Enter your message"
            rows="4"
            required
          />
        </div>

        <div className="form-group">
          <label htmlFor="scheduledTime">Schedule Time</label>
          <DatePicker
            selected={formData.scheduledTime}
            onChange={handleDateChange}
            showTimeSelect
            timeFormat="HH:mm"
            dateFormat="yyyy-MM-dd HH:mm"
            minDate={new Date()}
          />
        </div>

        <button type="submit" disabled={loading}>
          {loading ? 'Scheduling...' : 'Schedule Notification'}
        </button>
      </form>

      {error && <div className="error-message">{error}</div>}
      {success && <div className="success-message">{success}</div>}
    </div>
  );
};

export default ScheduleForm;
EOFFORM
print_success "ScheduleForm component created"

# Step 9: Create NotificationList component
print_step "9" "Creating NotificationList component..."
cat > src/components/NotificationList.jsx << 'EOFLIST'
import React, { useState, useEffect } from 'react';
import { getScheduledNotifications, cancelNotification } from '../api/api';

const NotificationList = ({ refresh }) => {
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchNotifications();
  }, [refresh]);

  const fetchNotifications = async () => {
    setLoading(true);
    try {
      const data = await getScheduledNotifications();
      setNotifications(data);
    } catch (error) {
      console.error('Error fetching notifications:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleCancel = async (id) => {
    try {
      await cancelNotification(id);
      setNotifications(notifications.filter((n) => n.id !== id));
    } catch (error) {
      console.error('Error canceling notification:', error);
    }
  };

  return (
    <div className="notification-list">
      <h2>Scheduled Notifications</h2>
      {loading ? (
        <p>Loading...</p>
      ) : notifications.length > 0 ? (
        <table>
          <thead>
            <tr>
              <th>Phone Number</th>
              <th>Message</th>
              <th>Scheduled Time</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {notifications.map((notification) => (
              <tr key={notification.id}>
                <td>{notification.phoneNumber}</td>
                <td>{notification.message}</td>
                <td>{new Date(notification.scheduledTime).toLocaleString()}</td>
                <td>
                  <button onClick={() => handleCancel(notification.id)}>
                    Cancel
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      ) : (
        <p>No scheduled notifications</p>
      )}
    </div>
  );
};

export default NotificationList;
EOFLIST
print_success "NotificationList component created"

# Step 10: Create App.js
print_step "10" "Creating main App component..."
cat > src/App.js << 'EOFAPP'
import React, { useState } from 'react';
import ScheduleForm from './components/ScheduleForm';
import NotificationList from './components/NotificationList';
import './App.css';

function App() {
  const [refresh, setRefresh] = useState(0);

  const handleNotificationScheduled = () => {
    setRefresh(refresh + 1);
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>WhatsApp Notification Scheduler</h1>
      </header>
      <div className="container">
        <ScheduleForm onNotificationScheduled={handleNotificationScheduled} />
        <NotificationList refresh={refresh} />
      </div>
    </div>
  );
}

export default App;
EOFAPP
print_success "App component created"

# Step 11: Create styling and other files
print_step "11" "Creating styling and configuration files..."

# Create App.css
cat > src/App.css << 'EOFCSS'
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  background-color: #f5f5f5;
}

.App {
  min-height: 100vh;
}

.App-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 2rem;
  text-align: center;
}

.container {
  max-width: 1200px;
  margin: 2rem auto;
  padding: 0 1rem;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2rem;
}

.schedule-form,
.notification-list {
  background: white;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: #333;
}

.form-group input,
.form-group textarea,
.react-datepicker-wrapper input {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
  transition: transform 0.2s;
  width: 100%;
}

button:hover {
  transform: scale(1.02);
}

button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

table {
  width: 100%;
  border-collapse: collapse;
}

table thead {
  background-color: #f0f0f0;
}

table th,
table td {
  padding: 1rem;
  text-align: left;
  border-bottom: 1px solid #ddd;
}

table button {
  width: auto;
  padding: 0.5rem 1rem;
  font-size: 0.9rem;
}

.error-message {
  color: #d32f2f;
  padding: 1rem;
  background-color: #ffebee;
  border-radius: 4px;
  margin-top: 1rem;
}

.success-message {
  color: #388e3c;
  padding: 1rem;
  background-color: #e8f5e9;
  border-radius: 4px;
  margin-top: 1rem;
}

@media (max-width: 768px) {
  .container {
    grid-template-columns: 1fr;
  }
}
EOFCSS

# Create .env file
if [ ! -f ".env" ]; then
    cat > .env << 'EOFENV'
REACT_APP_API_URL=http://localhost:5000/api
PORT=5000
WHATSAPP_API_TOKEN=your_whatsapp_api_token
WHATSAPP_PHONE_NUMBER_ID=your_phone_number_id
EOFENV
    print_success ".env file created"
else
    print_warning ".env file already exists"
fi

# Create server files
mkdir -p ../server/routes

# Create server.js
cat > ../server/server.js << 'EOFSERVER'
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const notificationRoutes = require('./routes/notifications');

const app = express();

app.use(cors());
app.use(bodyParser.json());

app.use('/api/notifications', notificationRoutes);

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
EOFSERVER

# Create notifications route
cat > ../server/routes/notifications.js << 'EOFROUTE'
const express = require('express');
const schedule = require('node-schedule');
const axios = require('axios');

const router = express.Router();

const scheduledJobs = {};
let notificationId = 1;
const notifications = [];

const sendWhatsAppMessage = async (phoneNumber, message) => {
  try {
    const response = await axios.post(
      `https://graph.instagram.com/v18.0/${process.env.WHATSAPP_PHONE_NUMBER_ID}/messages`,
      {
        messaging_product: 'whatsapp',
        recipient_type: 'individual',
        to: phoneNumber,
        type: 'text',
        text: {
          preview_url: false,
          body: message,
        },
      },
      {
        headers: {
          Authorization: `Bearer ${process.env.WHATSAPP_API_TOKEN}`,
        },
      }
    );
    return response.data;
  } catch (error) {
    console.error('Error sending WhatsApp message:', error);
    throw error;
  }
};

router.post('/schedule', (req, res) => {
  const { phoneNumber, message, scheduledTime } = req.body;

  if (!phoneNumber || !message || !scheduledTime) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  const id = notificationId++;
  const notification = {
    id,
    phoneNumber,
    message,
    scheduledTime,
    status: 'scheduled',
  };

  const job = schedule.scheduleJob(new Date(scheduledTime), async () => {
    try {
      await sendWhatsAppMessage(phoneNumber, message);
      notification.status = 'sent';
      console.log(`Notification ${id} sent successfully`);
    } catch (error) {
      notification.status = 'failed';
      console.error(`Failed to send notification ${id}:`, error);
    }
    delete scheduledJobs[id];
  });

  scheduledJobs[id] = job;
  notifications.push(notification);

  res.json({ message: 'Notification scheduled', notification });
});

router.get('/', (req, res) => {
  res.json(notifications);
});

router.delete('/:id', (req, res) => {
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
EOFROUTE

print_success "Server files created"

# Update package.json scripts
print_success "Updating package.json scripts..."
cd "$SCRIPT_DIR/$PROJECT_NAME"
npm pkg set scripts.server="nodemon ../server/server.js"
npm pkg set scripts.dev="concurrently \"npm start\" \"npm run server\""

print_header "✅ Setup Complete!"

echo -e "${GREEN}All files have been created and dependencies installed!${NC}\n"

echo "📁 Project Structure:"
echo "  $PROJECT_NAME/"
echo "  ├── src/"
echo "  │   ├── api/"
echo "  │   │   └── api.js"
echo "  │   ├── components/"
echo "  │   │   ├── ScheduleForm.jsx"
echo "  │   │   └── NotificationList.jsx"
echo "  │   ├── App.js"
echo "  │   ├── App.css"
echo "  │   └── index.js"
echo "  ├── server/"
echo "  │   ├── server.js"
echo "  │   └── routes/"
echo "  │       └── notifications.js"
echo "  ├── .env"
echo "  └── package.json"
echo ""

echo "🔧 Next Steps:"
echo ""
echo "1️⃣  Update .env with WhatsApp credentials:"
echo "   - WHATSAPP_API_TOKEN (from Meta Developers)"
echo "   - WHATSAPP_PHONE_NUMBER_ID (from WhatsApp Business)"
echo ""
echo "2️⃣  Start the application:"
echo -e "   ${BLUE}cd $PROJECT_NAME${NC}"
echo -e "   ${BLUE}npm run dev${NC}"
echo ""
echo "   Or run separately:"
echo -e "   Terminal 1: ${BLUE}npm start${NC}"
echo -e "   Terminal 2: ${BLUE}npm run server${NC}"
echo ""

echo "📚 Useful Commands:"
echo "  npm start        - Start React frontend (http://localhost:3000)"
echo "  npm run server   - Start Express backend (http://localhost:5000)"
echo "  npm run dev      - Start both frontend and backend"
echo ""

echo "🌐 Access URLs:"
echo "  Frontend: http://localhost:3000"
echo "  Backend:  http://localhost:5000/api/notifications"
echo ""

echo -e "${GREEN}Happy coding! 🚀${NC}"
