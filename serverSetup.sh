#!/bin/bash

# Shell Script to Set Up a Monkshu-Based Product Server
# Usage: sudo ./serverSetup.sh

# declare script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Load Environment Variables ---
if [ -f "./.env" ]; then
    source ./.env
else
    echo "❌ Error: .env file not found."
    echo "✅ Create a .env file with APP_NAME and APP_USER variables."
    echo "Example:"
    echo "APP_NAME=myApp"
    echo "APP_USER=myuser"
    exit 1
fi

if [ -z "$APP_NAME" ] || [ -z "$APP_USER" ]; then
    echo "❌ Error: APP_NAME or APP_USER not set in .env file."
    exit 1
fi

# --- Root Check ---
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run this script with sudo/root privileges."
    exit 1
fi

# --- Determine Working Directory ---
if [ "$APP_USER" == "root" ]; then
    APP_HOME="/root"
    echo "👤 Using root user, working directory $APP_HOME"
else
    APP_HOME="/home/$APP_USER"
    if id "$APP_USER" &>/dev/null; then
        echo "✅ User $APP_USER already exists."
    else
        echo "⚠️  User $APP_USER does not exist."
        read -p "👉 Do you want to create user $APP_USER? (y/n): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo "👤 Creating user $APP_USER..."
            useradd -m -s /bin/bash "$APP_USER"
        else
            echo "❌ Cannot proceed without a valid user. Exiting."
            exit 1
        fi
    fi
    echo "👤 Running setup for user $APP_USER with home directory $APP_HOME"
fi

# --- Final Steps (Executed only after manual config) ---
if [ "$1" == "--final" ]; then
    echo "========================================================"
    echo "⚡ Executing final steps..."
    cd "$APP_HOME/xforge"
    ./xforge -c -f "$APP_HOME/monkshu/build/webbundle.xf.js"

    cd "$APP_HOME"
    sudo systemctl enable monkshu.service
    sudo systemctl restart monkshu.service

    echo "🎉 All done for $APP_NAME!"
    echo "========================================================"
    exit 0
fi

echo "🚀 Starting Setup for $APP_NAME Product Server"
echo "========================================================"

# --- System Updates and Installations ---
echo "🔄 Updating system packages..."
sudo apt update
sudo apt upgrade -y

echo "🧱 Installing build-essential..."
sudo apt install build-essential -y

echo "☕ Installing OpenJDK 11..."
sudo apt-get install openjdk-11-jdk -y

echo "🧠 Installing Tesseract OCR..."
sudo apt install -y tesseract-ocr tesseract-ocr-all

echo "🛠️ Installing GCC, Make, Git, and SQLite3..."
sudo apt install -y gcc make git sqlite3

echo "📦 Installing Node.js and npm..."
sudo apt install -y nodejs npm

echo "🔐 Granting Node.js permission to bind to ports < 1024..."
sudo setcap cap_net_bind_service=+ep /usr/bin/node

# --- Clone Repositories ---
cd "$APP_HOME"

if [ ! -d "$APP_HOME/crashguard" ]; then
    echo "📥 Cloning crashguard repo..."
    git clone https://github.com/TekMonksGitHub/crashguard.git
else
    echo "✅ crashguard already exists. Skipping clone."
fi

if [ ! -d "$APP_HOME/$APP_NAME" ]; then
    echo "📥 Cloning $APP_NAME repo..."
    git clone https://github.com/TekMonksGitHub/$APP_NAME.git
else
    echo "✅ $APP_NAME already exists. Skipping clone."
fi

if [ ! -d "$APP_HOME/monkshu" ]; then
    echo "📥 Cloning monkshu repo..."
    git clone https://github.com/TekMonksGitHub/monkshu.git
else
    echo "✅ monkshu already exists. Skipping clone."
fi

if [ ! -d "$APP_HOME/xforge" ]; then
    echo "📥 Cloning xforge repo..."
    git clone https://github.com/TekMonksGitHub/xforge.git
else
    echo "✅ xforge already exists. Skipping clone."
fi

# Edit cloned repo permissions to the give user
echo "🔐 Setting ownership of cloned repos to $APP_USER..."
sudo chown -R "$APP_USER:$APP_USER" \
  "$APP_HOME/crashguard" "$APP_HOME/$APP_NAME" "$APP_HOME/monkshu" "$APP_HOME/xforge"

# --- Copy Configuration Files ---
echo "📁 Copying configuration files..."

# --- Generate process.json dynamically ---
echo "⚙️  Generating process.json for $APP_USER..."
sudo sed "s|APP_HOME|$APP_HOME|g" "$SCRIPT_DIR/process.json.template" > "$APP_HOME/crashguard/conf/process.json"

# Replace APP_USER and APP_HOME in service file dynamically
echo "⚙️  Generating monkshu.service for $APP_USER..."
sudo sed -e "s|APP_HOME|$APP_HOME|g" \
         -e "s|APP_USER|$APP_USER|g" \
    "$SCRIPT_DIR/monkshu.service.template" > /usr/lib/systemd/system/monkshu.service

# --- Linking and Installing ---
echo "🔗 Creating symbolic link between monkshu and $APP_NAME..."
"$APP_HOME/monkshu/mklink.sh" "$APP_NAME"

echo "📦 Installing monkshu dependencies..."
"$APP_HOME/monkshu/install.sh"

echo "📦 Installing $APP_NAME dependencies..."
"$APP_HOME/$APP_NAME/install.sh" || "$APP_HOME/$APP_NAME/install.sh.bat"

echo "📦 Installing xforge dependencies..."
"$APP_HOME/xforge/install.sh"

# Edit installed module permissions to the give user
echo "🔐 Setting ownership of installed modules to $APP_USER..."
sudo chown -R "$APP_USER:$APP_USER" \
  "$APP_HOME/crashguard" "$APP_HOME/packages*json" "$APP_HOME/node_modules"

# --- SSL Certificate ---
echo "🔐 Installing Certbot..."
sudo apt-get install certbot -y

echo "⚙️  Running Certbot in standalone mode..."
sudo certbot certonly --standalone

# --- Manual Configuration Instructions ---
echo "📝 Manual Configuration Required:"
echo "⚠️  Please configure Monkshu, Xforge, and $APP_NAME as needed."
echo "👉 After completing manual configuration, re-run this script with --final flag."

echo "========================================================"
