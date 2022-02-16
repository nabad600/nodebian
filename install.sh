#!/bin/sh
#Set up the required package
pkgs='deck'
if ! rpm -qa | grep -i $pkgs >/dev/null 2>&1; then
  wget https://github.com/nabad600/demo/releases/download/v1.0.0/deck-3.0.0-2.x86_64.rpm
  sudo dnf -y localinstall deck-3.0.0-2.x86_64.rpm
fi
echo "Add the Docker CE repository to Fedora 35/34/33/32/31/30"
sudo dnf -y install dnf-plugins-core
source /etc/os-release
sudo tee /etc/yum.repos.d/docker-ce.repo<<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://download.docker.com/linux/fedora/${VERSION_ID}/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/fedora/gpg
EOF

echo "Install Docker CE on Fedora"
sudo dnf -y makecache
sudo dnf -y install docker-ce docker-ce-cli containerd.io

echo "Docker will be installed but not started. To start the docker service, run:"
sudo systemctl enable --now docker
echo "Add your user to this group to run docker commands without sudo"
sudo usermod -aG docker $(whoami)
newgrp docker
echo "The version of Docker installed can be checked"
docker version
sudo chmod 666 /var/run/docker.sock
systemctl start docker
echo "Install Docker Compose on Fedora 35/34/33/32/31 from the repo"
sudo dnf -y install docker-compose
echo "Install Docker Compose on Fedora from a binary file."
sudo dnf -y install wget
echo "Download latest compose:"
curl -s https://api.github.com/repos/docker/compose/releases/latest \
  | grep browser_download_url \
  | grep docker-compose-linux-x86_64 \
  | cut -d '"' -f 4 \
  | wget -qi -
echo "Make the binary file executable."
chmod +x docker-compose-linux-x86_64
echo "Move the file to your PATH."
sudo mv docker-compose-linux-x86_64 /usr/local/bin/docker-compose
echo "Docker composer version check"
docker-compose --version
sudo touch /etc/sysctl.d/50-unprivileged-ports.conf
sudo chown $USER:$USER /etc/sysctl.d/50-unprivileged-ports.conf
sudo echo "net.ipv4.ip_unprivileged_port_start=80" >> /etc/sysctl.d/50-unprivileged-ports.conf
sudo echo "net.ipv4.ip_unprivileged_port_start=443" >> /etc/sysctl.d/50-unprivileged-ports.conf
sudo chown root:root /etc/sysctl.d/50-unprivileged-ports.conf
sudo sysctl --system
clear
echo "All set and done.";
