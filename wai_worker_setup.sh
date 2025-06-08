#!/bin/bash

set -e

# Colors
CYAN='\033[0;36m'
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

banner() {
  echo -e "${CYAN}
 
 ______              _         _                                             
|  ___ \            | |       | |                   _                        
| |   | |  ___    _ | |  ____ | | _   _   _  ____  | |_   ____   ____  _____ 
| |   | | / _ \  / || | / _  )| || \ | | | ||  _ \ |  _) / _  ) / ___)(___  )
| |   | || |_| |( (_| |( (/ / | | | || |_| || | | || |__( (/ / | |     / __/ 
|_|   |_| \___/  \____| \____)|_| |_| \____||_| |_| \___)\____)|_|    (_____)                   
                                
                                                                                                                                
${YELLOW}                      :: Powered by Noderhunterz ::
${NC}"
}

update_system() {
  echo -e "${BLUE}🔄 Updating system packages...${RESET}"
  sudo apt update -qq && apt upgrade -qq -y
}

install_nodejs() {
  echo -e "${BLUE}🟩 Installing NVM (Node Version Manager)...${RESET}"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

  echo -e "${BLUE}📦 Installing Node.js 22 via NVM...${RESET}"
  nvm install 22
  nvm use 22
  nvm alias default 22

  echo -e "${BLUE}🔧 Installing Yarn...${RESET}"
  npm install -g yarn

  echo -e "${GREEN}✅ Node.js $(node -v) and Yarn $(yarn -v) installed with NVM.${RESET}"
}

install_dependencies() {
  echo -e "${BLUE}📦 Installing dependencies...${RESET}"
  sudo apt install -qq -y lsb-release curl iptables build-essential git wget lz4 jq make gcc nano \
    automake autoconf htop nvme-cli libgbm1 pkg-config libssl-dev \
    libleveldb-dev tar clang bsdmainutils ncdu unzip \
    python3 python3-pip python3-venv python3-dev
  echo -e "${GREEN}✅ Base dependencies installed.${RESET}"
}

install_wai_cli() {
  echo -e "${BLUE}📥 Installing WAI CLI...${RESET}"
  curl -fsSL https://app.w.ai/install.sh | bash
  export PATH="$HOME/.local/bin:$PATH"
}

setup_api_key() {
  read -p "🔑 Enter your W_AI_API_KEY: " WAI_KEY
  export W_AI_API_KEY="$WAI_KEY"
  if ! grep -q "W_AI_API_KEY" ~/.bashrc; then
    echo "export W_AI_API_KEY=$WAI_KEY" >> ~/.bashrc
    echo -e "${GREEN}✅ API key saved to ~/.bashrc${RESET}"
  fi
}

install_pm2() {
  echo -e "${BLUE}📦 Installing PM2...${RESET}"
  npm install -g pm2
}

detect_vram() {
  if ! command -v nvidia-smi &> /dev/null; then
    echo -e "${RED}❌ NVIDIA GPU not detected. Cannot determine VRAM.${RESET}"
    RECOMMENDED_INSTANCES=1
  else
    VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -n1)
    VRAM_GB=$((VRAM / 1024))
    RECOMMENDED_INSTANCES=$((VRAM_GB / 2))
    echo -e "${BLUE}🧠 Detected VRAM: ${VRAM_GB} GB${RESET}"
    echo -e "${GREEN}💡 Recommended worker instances (based on VRAM ÷ 2): ${RECOMMENDED_INSTANCES}${RESET}"
  fi

  read -p "🔢 How many worker instances do you want to run? (default: $RECOMMENDED_INSTANCES): " INSTANCES
  INSTANCES=${INSTANCES:-$RECOMMENDED_INSTANCES}
}

generate_pm2_config() {
  echo -e "${BLUE}📝 Creating PM2 configuration file using shared /tmp/wai folder...${RESET}"

  # Create the shared folder once
  mkdir -p /tmp/wai
  echo "Shared HOME folder created at /tmp/wai"

  echo "module.exports = { apps: [" > wai.config.js

  for ((i=1;i<=INSTANCES;i++)); do
    cat <<EOF >> wai.config.js
{
  name: 'wai-node-$i',
  script: 'wai',
  args: 'run',
  exec_mode: 'fork',
  instances: 1,
  autorestart: true,
  watch: false,
  max_memory_restart: '1G',
  env: {
    NODE_ENV: 'production',
    HOME: '/tmp/wai',
    W_AI_API_KEY: '$WAI_KEY'
  }
},
EOF
  done

  echo "]};" >> wai.config.js
  echo -e "${GREEN}✅ PM2 config created with $INSTANCES workers sharing /tmp/wai as HOME.${RESET}"
}

start_workers() {
  echo -e "${BLUE}🔁 Loading NVM environment to enable PM2 globally...${RESET}"
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  echo -e "${BLUE}🚀 Starting workers with PM2...${RESET}"
  pm2 start wai.config.js
  pm2 save
  echo -e "${GREEN}✅ Workers running. Use 'pm2 logs' to monitor.${RESET}"
}

main() {
  banner
  update_system
  install_dependencies
  install_nodejs

  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

  install_wai_cli
  setup_api_key
  install_pm2
  detect_vram
  generate_pm2_config
  start_workers
}

main
