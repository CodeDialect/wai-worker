# WAI Worker Auto Installer

Run multiple WAI Workers automatically using this script. It sets up the full environment, installs the CLI, configures PM2, and runs multiple miners based on your GPU's VRAM.
You can use windows or ubuntu GUI based app from here [WAI Worker Website](https://app.w.ai/download) or you can use [quickpod](https://console.quickpod.io?affiliate=bdb8136d-0278-42de-b16b-4153553bef5c) or your wsl.
---

## System Requirements

### Hardware
- NVIDIA GPU with **Compute Capability 5.0+**:
  - GTX 1050
  - GTX 1060
  - RTX 2060
  - RTX 3070
  - RTX 4080
  - and similar...
- Minimum **8 GB VRAM**, recommended 12+ GB for running multiple nodes

### Software
- **Ubuntu 20.04 or 22.04 ONLY**
  - CUDA 12.4 is not guaranteed to work on later versions
- Root access (`sudo`) to install dependencies
- Internet connection

---

## For Quickpod Users (First Do)
```bash
apt update && apt install sudo wget git -y
```
---

## CUDA 12.4 Must Be Installed Manually 

Before using the script, ensure CUDA 12.4 is installed with `nvcc` to check your cuda version `nvcc --version`:

# CUDA 12.4 Setup for Ubuntu 22.04

```bash
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-4
```

# CUDA 12.4 Setup for Ubuntu 20.04
```bash
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-4
```

# CUDA 12.4 Setup for WSL
```bash
wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/12.4.0/local_installers/cuda-repo-wsl-ubuntu-12-4-local_12.4.0-1_amd64.deb
sudo dpkg -i cuda-repo-wsl-ubuntu-12-4-local_12.4.0-1_amd64.deb
sudo cp /var/cuda-repo-wsl-ubuntu-12-4-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-4
```

# Add cuda 12.4 to the path
```bash
echo 'export PATH=/usr/local/cuda-12.4/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.4/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
```

---

# Upgrading or Downgrading to CUDA 12.4 (Optional):
Follow if you have a different CUDA version installed

# Uninstall the existing CUDA version:
```bash
sudo apt remove --purge cuda
sudo apt autoremove
```
Now, Follow Install CUDA 12.4 step above.

---

Then verify:
```bash
nvcc --version
nvidia-smi
```

---

## Installation Steps

### 1. Clone the Repo and Run Script

```bash
git clone https://github.com/codedialect/wai-worker
cd wai-worker
chmod +x wai_worker_setup.sh
./wai_worker_setup.sh
source ~/.bashrc
```

- You will be asked to enter your **W_AI_API_KEY**
- The script auto-detects VRAM and recommends number of workers
- PM2 will launch and manage the workers

---

## Monitoring Your Workers

```bash
# View all PM2 processes
pm2 list

# View logs for all
pm2 logs

# Restart all workers
pm2 restart all

# Stop all workers
pm2 stop all

# Clear logs
pm2 flush

# Restart specific worker
pm2 restart <worker number>

# Check specific worker logs
pm2 logs <worker number>

```

---

## Clean Start

If you ever want to wipe and reset:

```bash
pm2 delete all
rm -rf /tmp/wai-*
```

---
