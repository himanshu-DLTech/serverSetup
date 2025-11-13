
# Server Setup Script

This repository provides a shell script (`serverSetup.sh`) to set up a Monkshu-based product server.

## Version to use
You can use the following versions
- [server_Setup_v0.0.2](https://github.com/himanshu-DLTech/serverSetup/releases/tag/server_setup_v0.0.2) (LTS)
- [server_setup_v0.0.1](https://github.com/himanshu-DLTech/serverSetup/tree/server_setup_v0.0.1)

## 📌 Prerequisites

- Ubuntu/Debian-based Linux system
- `sudo` access
- Internet connection

## ⚙️ Environment Variables

Create a `.env` file in the same directory as the script with the following variables:

```bash
APP_NAME=myApp
APP_USER=myuser
```

## 🚀 Usage

Run the script with root privileges:

```bash
sudo ./serverSetup.sh
```

After manual configuration, you can finalize the setup with:

```bash
sudo ./serverSetup.sh --final
```

## 🛠 Features

- Installs required dependencies (Node.js, npm, Java, Tesseract OCR, etc.)
- Clones necessary repositories (`crashguard`, `monkshu`, `xforge`, and your product)
- Configures `process.json` and `monkshu.service`
- Sets up SSL certificates via **Certbot**
- Finalizes server setup with `systemctl`

## 📂 Repository Structure

```
serverSetup.sh
.env (to be created)
process.json.template
monkshu.service.template
```

## ⚠️ Manual Configuration

Some steps (like configuring Monkshu, Xforge, and your app) must be done manually before re-running the script with `--final`.

## 🎉 Completion

Once everything is configured and finalized, the service will be enabled and started automatically.

## 🧪 Test
Visit your deployed app via the domain or IP you've configured.
