#!/bin/bash

# 1. Uninstall all conflicting Docker packages.
# Menghapus semua paket Docker yang mungkin konflik dengan instalasi Docker baru.
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
    sudo apt-get remove -y $pkg
done

# 2. Update package list dan install dependencies
# Memperbarui daftar paket dan menginstal dependensi yang diperlukan seperti sertifikat CA dan curl.
sudo apt-get update
sudo apt-get install -y ca-certificates curl

# 3. Setup Docker GPG key
# Membuat direktori untuk menyimpan keyring dan mengunduh kunci GPG Docker ke sistem.
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

# 4. Set permission untuk keyring
# Mengatur izin file agar keyring Docker dapat diakses dengan benar.
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 5. Add Docker repository
# Menambahkan repositori Docker ke dalam daftar sumber apt.
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 6. Update package list dengan repositori Docker baru
# Memperbarui daftar paket lagi, kali ini termasuk repositori Docker.
sudo apt-get update

# 7. Install Docker packages
# Menginstal paket Docker yang diperlukan.
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 12. Write compose.yaml file
cat <<EOL > compose.yaml
version: "3"
services:
  windows:
    image: dockurr/windows
    container_name: windows
    environment:
      VERSION: "11"
      RAM_SIZE: "6G"
      CPU_CORES: "4"
      DISK_SIZE: "150G"
      USERNAME: "admin"
      PASSWORD: "Renn@123ZONE"
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
      - /var/win10:/storage
EOL

# 13. Run
sudo docker compose -f compose.yaml up -d
```
