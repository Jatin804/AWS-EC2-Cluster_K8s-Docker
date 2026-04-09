#!/bin/bash

sudo apt-get update -y

# Setting up password auth
echo "$(whoami) ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/$(whoami)" > /dev/null
sudo chmod 0440 "/etc/sudoers.d/$(whoami)"

# Updating /etc/hosts for connection
if ! grep -q "ANSIBLE MANAGED HOSTS" /etc/hosts; then
  echo -e "\n# BEGIN ANSIBLE MANAGED HOSTS\n$(hostname -I | awk '{print $1}') $(hostname).example.com $(hostname)\n# END ANSIBLE MANAGED HOSTS" | sudo tee -a /etc/hosts > /dev/null
fi

# Disabling swap of all nodes including master 
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Adding kernel modules 
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf > /dev/null
overlay
br_netfilter
EOF

# Setting up sysctl parameters
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf > /dev/null
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

# Installing necessary dependencies and network modules for ubuntu
sudo apt-get install -y curl gnupg2 software-properties-common ca-certificates lsb-release firewalld conntrack socat ipset

# Adding Docker and installing containerd
sudo mkdir -p /etc/apt/keyrings
sudo chmod 0755 /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod 0644 /etc/apt/keyrings/docker.asc

echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y containerd.io

# Generating clean containerd config
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Force restart containerd to apply CRI changes
sudo systemctl daemon-reload
sudo systemctl restart containerd
sudo systemctl enable containerd

# Kubernetes Setup 
# Removing conflicting kubernetes list and keyring files
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
sudo rm -f /etc/apt/sources.list.d/archive_uri-https_pkgs_k8s_io_core_stable_v1_31_deb_.list
sudo rm -f /etc/apt/keyrings/kubernetes.gpg
sudo rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Downloading K8s GPG key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo tee /etc/apt/keyrings/kubernetes-apt-keyring.asc > /dev/null
sudo chmod 0644 /etc/apt/keyrings/kubernetes-apt-keyring.asc

# Adding Kubernetes repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.asc] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

# Installing K8s components
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl

# Preventing K8s packages from being upgraded
sudo apt-mark hold kubelet kubeadm kubectl