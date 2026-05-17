#!/bin/bash

# WhatsApp Notification Scheduler - Setup Script
# This script automates all setup steps for the project

set -e

echo "========================================"
echo "WhatsApp Notification Scheduler Setup"
echo "========================================"
echo ""

# Step 1: Check if Node.js is installed
echo "[1/8] Checking Node.js installation..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install it from https://nodejs.org/"
    exit 1
fi
echo "✅ Node.js version: $(node -v)"
echo ""

# Step 2: Check npm registry
echo "[2/8] Setting npm registry to public npm..."
npm config set registry https://registry.npmjs.org/
echo "✅ Registry set to https://registry.npmjs.org/"
echo ""

# Step 3: Create React App
echo "[3/8] Creating React app 'whatsapp-scheduler'..."
if [ ! -d "whatsapp-scheduler" ]; then
    npx create-react-app whatsapp-scheduler
    echo "✅ React app created"
else
    echo "⚠️  Directory 'whatsapp-scheduler' already exists. Skipping creation."
fi
echo ""

# Step 4: Navigate to project and install dependencies
echo "[4/8] Installing frontend dependencies..."
cd whatsapp-scheduler
npm install axios react-datepicker dotenv express cors body-parser node-schedule
echo "✅ Frontend dependencies installed"
echo ""

# Step 5: Install dev dependencies
echo "[5/8] Installing development dependencies..."
npm install --save-dev nodemon concurrently
echo "✅ Dev dependencies installed"
echo ""

# Step 6: Create directory structure
echo "[6/8] Creating project structure..."
mkdir -p src/components
mkdir -p src/api
mkdir -p server/routes
echo "✅ Project directories created"
echo ""

# Step 7: Create .env file
echo "[7/8] Creating .env file..."
if [ ! -f ".env" ]; then
    cat > .env << 'EOF'
REACT_APP_API_URL=http://localhost:5000/api
PORT=5000
WHATSAPP_API_TOKEN=your_whatsapp_api_token
WHATSAPP_PHONE_NUMBER_ID=your_phone_number_id
EOF
    echo "✅ .env file created (update with your WhatsApp credentials)"
else
    echo "⚠️  .env file already exists. Skipping creation."
fi
echo ""

# Step 8: Display next steps
echo "[8/8] Setup complete! 🎉"
echo ""
echo "========================================"
echo "Next Steps:"
echo "========================================"
echo ""
echo "1. Update .env file with your WhatsApp credentials:"
echo "   - Get WHATSAPP_API_TOKEN from Meta Developers"
echo "   - Get WHATSAPP_PHONE_NUMBER_ID from your WhatsApp Business account"
echo ""
echo "2. Create the React and Server files (copy from the guide)"
echo ""
echo "3. Run the application:"
echo "   npm run dev"
echo ""
echo "   Or run separately:"
echo "   Terminal 1: npm start"
echo "   Terminal 2: npm run server"
echo ""
echo "========================================"
echo "Useful Commands:"
echo "========================================"
echo "  npm start        - Start React frontend"
echo "  npm run server   - Start Express backend"
echo "  npm run dev      - Start both frontend and backend"
echo "========================================"
