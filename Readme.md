---

# 🚀 Server Setup for Monkshu-Based App

This setup automates the environment preparation and deployment of any [Monkshu](https://github.com/TekMonksGitHub/monkshu)-based web application (like `neuranet`) on a **fresh Linux VM**.

## 📁 Folder Structure

```

serverSetup/
├── serverSetup.sh         # Main setup script
├── process.json           # Process configuration for crashguard
├── monkshu.service        # Systemd service definition for Monkshu

````

---

## ⚙️ Prerequisites

- Fresh **Ubuntu/Debian-based VM**
- Internet access
- User with `sudo` privileges
- Make sure `git` is available

---

## 🛠️ Setup Instructions

### 1. 🔽 Clone or Transfer the Folder to Your VM

You can clone this setup repo or use `scp` to move it to the VM:

```bash
scp -r serverSetup/ youruser@your-vm-ip:~/
````

Or if it's on GitHub:

```bash
git clone <your-repo-url>
cd serverSetup
```

---

### 2. 🔑 Make the Script Executable

```bash
cd serverSetup
chmod +x serverSetup.sh
```

---

### 3. 🚀 Run the Script with Your App Name

> Replace `<AppName>` with the name of your app repo (e.g., `neuranet`, `yourappname`, etc.)

```bash
sudo ./serverSetup.sh <AppName>
```

or (for logs)
```
sudo ./serverSetup.sh <AppName> | tee /root/setup.log
```

🧠 Example:

```bash
sudo ./serverSetup.sh neuranet
```

or
```
sudo ./serverSetup.sh neuranet | tee /root/setup.log
```

---

### 4. 🔐 Certbot SSL Setup

The script will automatically run:

```bash
sudo certbot certonly --standalone
```

> 📝 You’ll be prompted for a domain and email — make sure your domain points to the VM's IP.

---

### 5. ⚙️ Final Step: Enable & Start Monkshu Service

After setup is done, run:

```bash
sudo systemctl enable monkshu.service
sudo systemctl start monkshu.service
```

---

## 🧪 Test

Visit your deployed app via the domain or IP you've configured.

---

## 🧩 Notes

* `process.json` and `monkshu.service` must remain in the `serverSetup/` folder.
* If your app has a Windows batch script (`install.sh.bat`), run that on Windows only if needed.
* Modify `monkshu.service` if your service needs custom ports or paths.

---
