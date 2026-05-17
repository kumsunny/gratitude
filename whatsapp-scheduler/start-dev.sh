/*
 * {COPYRIGHT-TOP}
 * IBM Confidential
 * (C) Copyright IBM Corp. 2019, 2022, 2026
 * 
 * << 5608-WC0/5608-PC4 >>
 * 
 * All Rights Reserved
 * Licensed Material - Property of IBM
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has
 * been deposited with the U. S. Copyright Office.
 * 
 * U.S. Government Users Restricted Rights
 * - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 * {COPYRIGHT-END}
 */

#!/bin/bash

# Kill any existing processes on ports 3000 and 5001
echo "🧹 Cleaning up existing processes..."
lsof -ti:3000 | xargs kill -9 2>/dev/null
lsof -ti:5001 | xargs kill -9 2>/dev/null

# Navigate to the project directory
cd "$(dirname "$0")"

echo "🚀 Starting WhatsApp Scheduler..."
echo ""

# Start the backend server in the background
echo "📡 Starting backend server on port 5001..."
node server/server.js &
SERVER_PID=$!

# Wait a moment for the server to start
sleep 2

# Start the React app
echo "⚛️  Starting React app on port 3000..."
echo ""
PORT=3000 npm start

# When React app is stopped, also stop the backend server
kill $SERVER_PID 2>/dev/null

# Made with Bob
