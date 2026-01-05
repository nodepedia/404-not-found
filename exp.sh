#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                    WINDOWS DOCKER AUTO INSTALLER                          ║
# ║                         by BelajarNode                                    ║
# ║                     https://belajarnode.com                               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'
DIM='\033[2m'

# Animated spinner
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while ps -p $pid > /dev/null 2>&1; do
        for i in $(seq 0 9); do
            printf "\r${CYAN}  [${spinstr:$i:1}]${NC} $2"
            sleep $delay
        done
    done
    printf "\r${GREEN}  [✓]${NC} $2\n"
}

# Progress bar with animation
progress_bar() {
    local current=$1
    local total=$2
    local text=$3
    local width=40
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    # Gradient colors based on progress
    if [ $percentage -lt 33 ]; then
        color=$RED
    elif [ $percentage -lt 66 ]; then
        color=$YELLOW
    else
        color=$GREEN
    fi
    
    printf "\r  ${DIM}[${NC}"
    printf "${color}"
    for ((i=0; i<filled; i++)); do printf "█"; done
    printf "${DIM}"
    for ((i=0; i<empty; i++)); do printf "░"; done
    printf "${NC}${DIM}]${NC} ${WHITE}${percentage}%%${NC} ${DIM}${text}${NC}"
}

# Clear screen and show banner
clear
echo
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                                                                                                       ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${PURPLE}██╗    ██╗██╗███╗   ██╗██████╗  ██████╗ ██╗    ██╗███████╗    ██╗███╗   ██╗███████╗████████╗${NC}         ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${PURPLE}██║    ██║██║████╗  ██║██╔══██╗██╔═══██╗██║    ██║██╔════╝    ██║████╗  ██║██╔════╝╚══██╔══╝${NC}         ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${PURPLE}██║ █╗ ██║██║██╔██╗ ██║██║  ██║██║   ██║██║ █╗ ██║███████╗    ██║██╔██╗ ██║███████╗   ██║${NC}            ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${PURPLE}██║███╗██║██║██║╚██╗██║██║  ██║██║   ██║██║███╗██║╚════██║    ██║██║╚██╗██║╚════██║   ██║${NC}            ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${PURPLE}╚███╔███╔╝██║██║ ╚████║██████╔╝╚██████╔╝╚███╔███╔╝███████║    ██║██║ ╚████║███████║   ██║${NC}            ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${PURPLE} ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝  ╚══╝╚══╝ ╚══════╝    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝${NC}            ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                                                                                                       ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                           ${WHITE}${BOLD}Docker Windows Auto Installer v2.0${NC}                                        ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                              ${DIM}Windows Installer by BelajarNode${NC}                                         ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                                                                                                       ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
echo

# ═══════════════════════════════════════════════════════════════════════════════
# FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Check prerequisites
check_prerequisites() {
    echo -e "${WHITE}${BOLD}▶ Checking Prerequisites...${NC}"
    echo
    
    local errors=0
    
    # Check if running as root or with sudo
    if [ "$EUID" -ne 0 ]; then
        if ! sudo -v > /dev/null 2>&1; then
            echo -e "  ${RED}[✗]${NC} Sudo access required"
            errors=$((errors + 1))
        else
            echo -e "  ${GREEN}[✓]${NC} Sudo access available"
        fi
    else
        echo -e "  ${GREEN}[✓]${NC} Running as root"
    fi
    
    # Check KVM support
    if [ -e /dev/kvm ]; then
        echo -e "  ${GREEN}[✓]${NC} KVM virtualization supported"
    else
        echo -e "  ${RED}[✗]${NC} KVM not available - Enable virtualization in BIOS!"
        errors=$((errors + 1))
    fi
    
    # Check if container 'windows' already exists
    if command -v docker &> /dev/null; then
        if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^windows$"; then
            echo -e "  ${YELLOW}[!]${NC} Container 'windows' already exists"
            echo
            read -p "      Remove existing container? (y/n): " remove_existing
            if [ "$remove_existing" = "y" ] || [ "$remove_existing" = "Y" ]; then
                docker rm -f windows > /dev/null 2>&1
                echo -e "  ${GREEN}[✓]${NC} Existing container removed"
            else
                echo -e "  ${RED}[✗]${NC} Cannot proceed with existing container"
                errors=$((errors + 1))
            fi
        else
            echo -e "  ${GREEN}[✓]${NC} No conflicting containers"
        fi
    else
        echo -e "  ${YELLOW}[!]${NC} Docker not installed (will be installed)"
    fi
    
    # Check disk space (minimum 50GB recommended)
    local free_space_gb=$(df -BG / 2>/dev/null | awk 'NR==2{gsub("G",""); print $4}')
    if [ -n "$free_space_gb" ] && [ "$free_space_gb" -lt 50 ]; then
        echo -e "  ${YELLOW}[!]${NC} Low disk space: ${free_space_gb}GB free (50GB+ recommended)"
    else
        echo -e "  ${GREEN}[✓]${NC} Sufficient disk space: ${free_space_gb}GB free"
    fi
    
    echo
    
    if [ $errors -gt 0 ]; then
        echo -e "${RED}${BOLD}  ✗ Prerequisites check failed!${NC}"
        echo -e "${DIM}    Please fix the issues above and try again.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}${BOLD}  ✓ All prerequisites passed!${NC}"
    echo
    sleep 1
}

# Show system information
show_system_info() {
    echo -e "${WHITE}${BOLD}▶ System Resources${NC}"
    echo
    echo -e "  ${CYAN}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "  ${CYAN}│${NC}  ${WHITE}CPU Cores${NC}     │  $(nproc) cores available                  ${CYAN}│${NC}"
    echo -e "  ${CYAN}│${NC}  ${WHITE}Total RAM${NC}     │  $(free -h | awk '/^Mem:/{print $2}') total                       ${CYAN}│${NC}"
    echo -e "  ${CYAN}│${NC}  ${WHITE}Available RAM${NC} │  $(free -h | awk '/^Mem:/{print $7}') available                   ${CYAN}│${NC}"
    echo -e "  ${CYAN}│${NC}  ${WHITE}Disk Free${NC}     │  $(df -h / | awk 'NR==2{print $4}') available                   ${CYAN}│${NC}"
    echo -e "  ${CYAN}╰──────────────────────────────────────────────────╯${NC}"
    echo
    echo -e "  ${YELLOW}💡 Recommended Configuration:${NC}"
    echo -e "  ${DIM}   • Windows 11/10: 4-8 GB RAM, 2-4 CPU, 64GB+ Storage${NC}"
    echo -e "  ${DIM}   • Windows Server: 4-16 GB RAM, 2-8 CPU, 64GB+ Storage${NC}"
    echo -e "  ${DIM}   • Windows 7/XP: 2-4 GB RAM, 2 CPU, 32GB+ Storage${NC}"
    echo
    sleep 1
}

# Validation functions
validate_ram() {
    local ram=$1
    local max_ram=$(free -g 2>/dev/null | awk '/^Mem:/{print $2}')
    max_ram=${max_ram:-64}  # Default max if can't detect
    
    if ! [[ "$ram" =~ ^[0-9]+$ ]]; then
        echo -e "  ${RED}[✗]${NC} RAM must be a number!"
        return 1
    fi
    if [ "$ram" -lt 2 ]; then
        echo -e "  ${RED}[✗]${NC} Minimum RAM is 2GB"
        return 1
    fi
    if [ "$ram" -gt "$max_ram" ]; then
        echo -e "  ${YELLOW}[!]${NC} RAM exceeds system capacity (${max_ram}GB). Continue anyway? (y/n)"
        read -r continue_anyway
        if [ "$continue_anyway" != "y" ]; then
            return 1
        fi
    fi
    return 0
}

validate_cpu() {
    local cpu=$1
    local max_cpu=$(nproc 2>/dev/null)
    max_cpu=${max_cpu:-16}  # Default max if can't detect
    
    if ! [[ "$cpu" =~ ^[0-9]+$ ]]; then
        echo -e "  ${RED}[✗]${NC} CPU cores must be a number!"
        return 1
    fi
    if [ "$cpu" -lt 1 ]; then
        echo -e "  ${RED}[✗]${NC} Minimum 1 CPU core required"
        return 1
    fi
    if [ "$cpu" -gt "$max_cpu" ]; then
        echo -e "  ${YELLOW}[!]${NC} CPU cores exceed available (${max_cpu}). Continue anyway? (y/n)"
        read -r continue_anyway
        if [ "$continue_anyway" != "y" ]; then
            return 1
        fi
    fi
    return 0
}

validate_disk() {
    local disk=$1
    
    if ! [[ "$disk" =~ ^[0-9]+$ ]]; then
        echo -e "  ${RED}[✗]${NC} Disk size must be a number!"
        return 1
    fi
    if [ "$disk" -lt 16 ]; then
        echo -e "  ${RED}[✗]${NC} Minimum disk size is 16GB"
        return 1
    fi
    return 0
}

# Show summary and confirm
show_summary() {
    echo
    echo -e "${WHITE}${BOLD}▶ Installation Summary${NC}"
    echo
    echo -e "  ${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${CYAN}║${NC}                    ${WHITE}${BOLD}CONFIGURATION REVIEW${NC}                      ${CYAN}║${NC}"
    echo -e "  ${CYAN}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${CYAN}║${NC}                                                              ${CYAN}║${NC}"
    echo -e "  ${CYAN}║${NC}   ${PURPLE}Windows Version${NC}  │  $VERSION_NAME"
    echo -e "  ${CYAN}║${NC}   ${PURPLE}RAM Size${NC}         │  ${ram_size}GB"
    echo -e "  ${CYAN}║${NC}   ${PURPLE}CPU Cores${NC}        │  ${cpu_cores} cores"
    echo -e "  ${CYAN}║${NC}   ${PURPLE}Storage${NC}          │  ${disk_size}GB"
    echo -e "  ${CYAN}║${NC}   ${PURPLE}Username${NC}         │  admin"
    echo -e "  ${CYAN}║${NC}   ${PURPLE}Password${NC}         │  ********"
    echo -e "  ${CYAN}║${NC}   ${PURPLE}VNC Port${NC}         │  8006"
    echo -e "  ${CYAN}║${NC}   ${PURPLE}RDP Port${NC}         │  3389"
    echo -e "  ${CYAN}║${NC}                                                              ${CYAN}║${NC}"
    echo -e "  ${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "  ${YELLOW}📝 Access Information:${NC}"
    echo -e "  ${DIM}   • VNC: http://YOUR_IP:8006${NC}"
    echo -e "  ${DIM}   • RDP: YOUR_IP:3389 (Username: admin)${NC}"
    echo
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN SCRIPT
# ═══════════════════════════════════════════════════════════════════════════════

# Step 1: Check prerequisites
check_prerequisites

# Step 2: Show system info
show_system_info

# Step 3: Install Docker
echo -e "${WHITE}${BOLD}▶ Installing Docker...${NC}"
echo

total_steps=7
current_step=0

# Function to update progress
update_step() {
    current_step=$((current_step + 1))
    progress_bar $current_step $total_steps "$1"
    sleep 0.5
}

# 1. Remove conflicting packages
(for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
    sudo apt-get remove -y $pkg > /dev/null 2>&1
done) &
pid=$!
while ps -p $pid > /dev/null 2>&1; do
    progress_bar $current_step $total_steps "Removing old packages..."
    sleep 0.2
done
update_step "Removing old packages..."

# 2. Update and install dependencies
(sudo apt-get update -qq > /dev/null 2>&1 && \
sudo apt-get install -y ca-certificates curl > /dev/null 2>&1) &
pid=$!
while ps -p $pid > /dev/null 2>&1; do
    progress_bar $current_step $total_steps "Installing dependencies..."
    sleep 0.2
done
update_step "Installing dependencies..."

# 3. Setup GPG key
(sudo install -m 0755 -d /etc/apt/keyrings && \
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc > /dev/null 2>&1) &
pid=$!
while ps -p $pid > /dev/null 2>&1; do
    progress_bar $current_step $total_steps "Setting up GPG key..."
    sleep 0.2
done
update_step "Setting up GPG key..."

# 4. Set keyring permissions
sudo chmod a+r /etc/apt/keyrings/docker.asc 2>/dev/null
update_step "Setting permissions..."

# 5. Add Docker repository
(echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null) &
pid=$!
while ps -p $pid > /dev/null 2>&1; do
    progress_bar $current_step $total_steps "Adding Docker repository..."
    sleep 0.2
done
update_step "Adding Docker repository..."

# 6. Update package list
(sudo apt-get update -qq > /dev/null 2>&1) &
pid=$!
while ps -p $pid > /dev/null 2>&1; do
    progress_bar $current_step $total_steps "Updating package list..."
    sleep 0.2
done
update_step "Updating package list..."

# 7. Install Docker
(sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null 2>&1) &
pid=$!
while ps -p $pid > /dev/null 2>&1; do
    progress_bar $current_step $total_steps "Installing Docker..."
    sleep 0.2
done
update_step "Installing Docker..."

echo
echo -e "  ${GREEN}${BOLD}✓ Docker installation complete!${NC}"
echo
sleep 1

# Step 4: Select Windows version
echo -e "${WHITE}${BOLD}▶ Select Windows Version${NC}"
echo
echo -e "  ${CYAN}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "  ${CYAN}║${NC}  ${WHITE}${BOLD}No${NC}  │  ${WHITE}${BOLD}Version${NC}                    │  ${WHITE}${BOLD}No${NC}  │  ${WHITE}${BOLD}Version${NC}                  ${CYAN}║${NC}"
echo -e "  ${CYAN}╠════════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "  ${CYAN}║${NC}  ${GREEN}1${NC}   │  Windows 11 Pro             │  ${GREEN}6${NC}   │  Windows 8.1 Pro          ${CYAN}║${NC}"
echo -e "  ${CYAN}║${NC}  ${GREEN}2${NC}   │  Windows 11 Enterprise      │  ${GREEN}7${NC}   │  Windows 8.1 Enterprise   ${CYAN}║${NC}"
echo -e "  ${CYAN}║${NC}  ${GREEN}3${NC}   │  Windows 10 Pro             │  ${GREEN}8${NC}   │  Windows 7 Enterprise     ${CYAN}║${NC}"
echo -e "  ${CYAN}║${NC}  ${GREEN}4${NC}   │  Windows 10 LTSC            │  ${GREEN}9${NC}   │  Windows Vista Enterprise ${CYAN}║${NC}"
echo -e "  ${CYAN}║${NC}  ${GREEN}5${NC}   │  Windows 10 Enterprise      │  ${GREEN}10${NC}  │  Windows XP Professional  ${CYAN}║${NC}"
echo -e "  ${CYAN}╠════════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "  ${CYAN}║${NC}  ${YELLOW}11${NC}  │  Windows Server 2022        │  ${YELLOW}14${NC}  │  Windows Server 2012      ${CYAN}║${NC}"
echo -e "  ${CYAN}║${NC}  ${YELLOW}12${NC}  │  Windows Server 2019        │  ${YELLOW}15${NC}  │  Windows Server 2008      ${CYAN}║${NC}"
echo -e "  ${CYAN}║${NC}  ${YELLOW}13${NC}  │  Windows Server 2016        │       │                           ${CYAN}║${NC}"
echo -e "  ${CYAN}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
echo

while true; do
    read -p "  Select version [1-15]: " version_choice
    
    case $version_choice in
        1)  VERSION="win11";   VERSION_NAME="Windows 11 Pro" ;;
        2)  VERSION="win11e";  VERSION_NAME="Windows 11 Enterprise" ;;
        3)  VERSION="win10";   VERSION_NAME="Windows 10 Pro" ;;
        4)  VERSION="ltsc10";  VERSION_NAME="Windows 10 LTSC" ;;
        5)  VERSION="win10e";  VERSION_NAME="Windows 10 Enterprise" ;;
        6)  VERSION="win8";    VERSION_NAME="Windows 8.1 Pro" ;;
        7)  VERSION="win8e";   VERSION_NAME="Windows 8.1 Enterprise" ;;
        8)  VERSION="win7";    VERSION_NAME="Windows 7 Enterprise" ;;
        9)  VERSION="vista";   VERSION_NAME="Windows Vista Enterprise" ;;
        10) VERSION="winxp";   VERSION_NAME="Windows XP Professional" ;;
        11) VERSION="2022";    VERSION_NAME="Windows Server 2022" ;;
        12) VERSION="2019";    VERSION_NAME="Windows Server 2019" ;;
        13) VERSION="2016";    VERSION_NAME="Windows Server 2016" ;;
        14) VERSION="2012";    VERSION_NAME="Windows Server 2012" ;;
        15) VERSION="2008";    VERSION_NAME="Windows Server 2008" ;;
        *)  echo -e "  ${RED}[✗]${NC} Invalid choice. Please select 1-15."
            continue ;;
    esac
    echo -e "  ${GREEN}[✓]${NC} Selected: ${WHITE}${VERSION_NAME}${NC}"
    break
done

echo

# Step 5: Configuration input with validation
echo -e "${WHITE}${BOLD}▶ Configuration${NC}"
echo

# RAM input with validation
while true; do
    read -p "  RAM Size (GB): " ram_size
    if validate_ram "$ram_size"; then
        echo -e "  ${GREEN}[✓]${NC} RAM: ${ram_size}GB"
        break
    fi
done

# CPU input with validation
while true; do
    read -p "  CPU Cores: " cpu_cores
    if validate_cpu "$cpu_cores"; then
        echo -e "  ${GREEN}[✓]${NC} CPU: ${cpu_cores} cores"
        break
    fi
done

# Disk input with validation
while true; do
    read -p "  Storage Size (GB): " disk_size
    if validate_disk "$disk_size"; then
        echo -e "  ${GREEN}[✓]${NC} Storage: ${disk_size}GB"
        break
    fi
done

# Password input
echo
read -p "  RDP Password: " password
echo -e "  ${GREEN}[✓]${NC} Password set"

# Step 6: Show summary and confirm
show_summary

echo -e "  ${YELLOW}${BOLD}⚠ Warning:${NC} ${DIM}This will download Windows ISO and may take a while.${NC}"
echo
read -p "  Proceed with installation? (y/n): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo
    echo -e "  ${RED}Installation cancelled.${NC}"
    exit 0
fi

# Step 7: Create compose.yaml
echo
echo -e "${WHITE}${BOLD}▶ Creating Configuration...${NC}"
echo

cat <<EOL > compose.yaml
version: "3"
services:
  windows:
    image: dockurr/windows
    container_name: windows
    environment:
      VERSION: "$VERSION"
      RAM_SIZE: "${ram_size}G"
      CPU_CORES: "${cpu_cores}"
      DISK_SIZE: "${disk_size}G"
      USERNAME: "admin"
      PASSWORD: "${password}"
    devices:
      - /dev/kvm
    cap_add:
      - NET_ADMIN
    ports:
      - 8006:8006
      - 3389:3389/tcp
      - 3389:3389/udp
    stop_grace_period: 2m
    restart: on-failure
    volumes:
      - /var/win:/storage
EOL

echo -e "  ${GREEN}[✓]${NC} compose.yaml created"
sleep 1

# Step 8: Run Docker Compose
echo
echo -e "${WHITE}${BOLD}▶ Starting Windows Container...${NC}"
echo

sudo docker compose -f compose.yaml up -d

echo
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                                                                                                       ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                              ${GREEN}${BOLD}✓ INSTALLATION COMPLETE!${NC}                                            ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                                                                                                       ${CYAN}║${NC}"
echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC}                                                                                                       ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${WHITE}📺 VNC Access:${NC}  http://$(hostname -I 2>/dev/null | awk '{print $1}' || echo 'YOUR_IP'):8006                                            ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${WHITE}🖥️  RDP Access:${NC}  $(hostname -I 2>/dev/null | awk '{print $1}' || echo 'YOUR_IP'):3389                                                     ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${WHITE}👤 Username:${NC}    admin                                                                           ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${WHITE}🔐 Password:${NC}    (as configured)                                                                 ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                                                                                                       ${CYAN}║${NC}"
echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC}                                                                                                       ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${DIM}Windows is now being installed. This may take 15-30 minutes.${NC}                                   ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${DIM}Monitor progress via VNC at port 8006.${NC}                                                         ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                                                                                                       ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${YELLOW}Commands:${NC}                                                                                       ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${DIM}• View logs:${NC}     docker logs -f windows                                                        ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${DIM}• Stop:${NC}          docker compose down                                                           ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${DIM}• Restart:${NC}       docker compose restart                                                        ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                                                                                                       ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
echo
echo -e "${DIM}                              Windows Installer by BelajarNode © 2025${NC}"
echo
