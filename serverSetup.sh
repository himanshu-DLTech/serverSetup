#!/bin/bash

# Shell Script to Set Up a Monkshu-Based Product Server
# Usage: sudo ./serverSetup.sh <AppName>

# --- Argument and User Checks ---
if [ -z "$1" ]; then
    echo "❌ Error: No app name provided."
    echo "✅ Usage: sudo $0 <AppName>"
    exit 1
fi

if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run this script as root (use sudo)."
    exit 1
fi

APP_NAME=$1

echo "🚀 Starting Setup for $APP_NAME Product Server as root"
echo "========================================================"

# --- System Updates and Installations ---
echo "🔄 Updating system packages..."
apt update
apt upgrade -y

echo "🧱 Installing build-essential..."
apt install build-essential -y

echo "☕ Installing OpenJDK 11..."
apt-cache search openjdk
apt-get install openjdk-11-jdk -y

echo "🧠 Installing Tesseract OCR..."
apt install tesseract-ocr -y
apt install tesseract-ocr-all -y

echo "🛠️ Installing GCC, Make, Git, and SQLite3..."
apt install -y gcc make git
apt install sqlite3 -y

echo "📦 Installing Node.js and npm..."
apt install -y nodejs npm

echo "🔐 Granting Node.js permission to bind to ports < 1024..."
setcap cap_net_bind_service=+ep /usr/bin/node

# --- Clone Repositories into /root ---
cd /root/

if [ ! -d "/root/crashguard" ]; then
    echo "📥 Cloning crashguard repo..."
    git clone https://github.com/TekMonksGitHub/crashguard.git
else
    echo "✅ crashguard already exists. Skipping clone."
fi

if [ ! -d "/root/$APP_NAME" ]; then
    echo "📥 Cloning $APP_NAME repo..."
    git clone https://github.com/TekMonksGitHub/$APP_NAME.git
else
    echo "✅ $APP_NAME already exists. Skipping clone."
fi

if [ ! -d "/root/monkshu" ]; then
    echo "📥 Cloning monkshu repo..."
    git clone https://github.com/TekMonksGitHub/monkshu.git
else
    echo "✅ monkshu already exists. Skipping clone."
fi

if [ ! -d "/root/xforge" ]; then
    echo "📥 Cloning xforge repo..."
    git clone https://github.com/TekMonksGitHub/xforge.git
else
    echo "✅ xforge already exists. Skipping clone."
fi

# --- Copy Configuration Files ---
echo "📁 Copying configuration files..."
cp ~/serverSetup/process.json /root/crashguard/conf/
cp ~/serverSetup/monkshu.service /usr/lib/systemd/system/

# --- Linking and Installing ---
echo "🔗 Creating symbolic link between monkshu and $APP_NAME..."
/root/monkshu/mklink.sh $APP_NAME

echo "📦 Installing monkshu..."
/root/monkshu/install.sh

# --- Optional Step (Windows Install Script) ---
echo "⚠️  NOTE: If '$APP_NAME' has a Windows install script, run '/root/$APP_NAME/install.sh.bat' on a Windows machine if needed."

# --- Optional Node Funding Info ---
echo "💸 Running npm fund (for info only)..."
npm fund

# --- SSL Certificate ---
echo "🔐 Installing Certbot..."
apt-get install certbot -y

echo "⚙️  Running Certbot in standalone mode..."
certbot certonly --standalone

# --- Final Systemd Instructions ---
echo "📝 Final Step:"
echo "✅ Setup Complete!"
echo "👉 Now, make a webbundle using xforge then enable and start the Monkshu service manually:"
echo "   ➤ cd xforge"
echo "   ➤ ./xforge -c -f /root/monkshu/build/webbundle.xf.js"
echo "   ➤ cd /root/"
echo "   ➤ sudo systemctl enable monkshu.service"
echo "   ➤ sudo systemctl start monkshu.service"
echo "🎉 All done for $APP_NAME!"

echo "========================================================"
