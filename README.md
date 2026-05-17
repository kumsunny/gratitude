# Gratitude

Welcome to the Gratitude repository!

## About

This project is dedicated to cultivating and sharing gratitude.

## Projects Included

### WhatsApp Notification Scheduler
A React app that integrates with WhatsApp API to send scheduled notifications. Get started in minutes with the automated setup script!

## Quick Setup for WhatsApp Scheduler

### Prerequisites
- Node.js (v14 or higher)
- npm or yarn
- WhatsApp Business Account with API access

### Automated Setup (Recommended ⭐)

We provide an automated setup script that handles all installation and configuration steps.

#### On Mac/Linux:

```bash
# Clone the repository
git clone https://github.com/kumsunny/gratitude.git
cd gratitude

# Make the setup script executable
chmod +x complete-setup.sh

# Run the setup script
./complete-setup.sh
```

#### On Windows (PowerShell):

```powershell
# Clone the repository
git clone https://github.com/kumsunny/gratitude.git
cd gratitude

# Run the setup script (use Git Bash or WSL)
bash complete-setup.sh
```

#### On Windows (Git Bash):

```bash
# Clone the repository
git clone https://github.com/kumsunny/gratitude.git
cd gratitude

# Make executable and run
chmod +x complete-setup.sh
./complete-setup.sh
```

### What the Setup Script Does

The `complete-setup.sh` script automatically:

- ✅ Checks Node.js installation
- ✅ Fixes npm registry (resolves Artifactory issues)
- ✅ Creates a React app
- ✅ Installs all dependencies (frontend & backend)
- ✅ Creates project directory structure
- ✅ Generates all React components:
  - ScheduleForm component
  - NotificationList component
  - App component
- ✅ Creates API service for backend communication
- ✅ Sets up Express server with routes
- ✅ Generates styling (App.css)
- ✅ Creates `.env` configuration file
- ✅ Updates package.json with useful scripts

### After Running the Setup Script

1. **Update `.env` file** with your WhatsApp credentials:

```env
REACT_APP_API_URL=http://localhost:5000/api
PORT=5000
WHATSAPP_API_TOKEN=your_api_token_here
WHATSAPP_PHONE_NUMBER_ID=your_phone_number_id_here
```

2. **Start the application**:

```bash
cd whatsapp-scheduler
npm run dev
```

Or run frontend and backend separately:

```bash
# Terminal 1 - Start frontend
npm start

# Terminal 2 - Start backend server
npm run server
```

3. **Access the application**:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5000/api/notifications

## Available Commands

```bash
npm start              # Start React frontend (port 3000)
npm run server         # Start Express backend (port 5000)
npm run dev            # Start both frontend and backend concurrently
```

## Features

- 📅 Schedule WhatsApp messages for specific times
- 📱 Send notifications to any WhatsApp number
- 📋 View all scheduled notifications
- ❌ Cancel scheduled notifications
- 🎨 Responsive and modern UI
- ⚡ Real-time notification management

## Project Structure

```
whatsapp-scheduler/
├── src/
│   ├── api/
│   │   └── api.js                 # API service for backend communication
│   ├── components/
│   │   ├── ScheduleForm.jsx       # Form to schedule notifications
│   │   └── NotificationList.jsx   # Display scheduled notifications
│   ├── App.js                      # Main app component
│   ├── App.css                     # Application styling
│   └── index.js
├── server/
│   ├── server.js                   # Express server
│   └── routes/
│       └── notifications.js        # API routes for notifications
├── .env                            # Environment variables
└── package.json
```

## Getting WhatsApp API Credentials

1. Go to [Meta Developers](https://developers.facebook.com/)
2. Create a Developer Account and Business Account
3. Set up WhatsApp Business API
4. Get your:
   - **Phone Number ID**: From WhatsApp Business settings
   - **API Token**: From Meta app settings
5. Add them to your `.env` file

## Troubleshooting

### npm login issues with Artifactory
The setup script automatically fixes this by setting the npm registry to the public npm registry. No manual intervention needed!

### Port already in use
If port 3000 or 5000 is already in use:
- For frontend: Change `PORT=3000` in `.env`
- For backend: Change `PORT=5000` in `.env`

### Dependencies not installing
Try running:
```bash
npm cache clean --force
npm install --legacy-peer-deps
```

## Contributing

Contributions are welcome! Feel free to:
- Report bugs by opening an issue
- Suggest features
- Submit pull requests to improve this project

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For questions or suggestions, please open an issue on GitHub.

---

**Happy coding! 🚀**

Need help? Check out our setup scripts or open an issue on GitHub!
