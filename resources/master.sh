#!/bin/bash

# Firewall for ports !
sudo systemctl start firewalld
sudo systemctl enable firewalld

sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=2379-2380/tcp
sudo firewall-cmd --permanent --add-port=10250-10252/tcp
sudo firewall-cmd --permanent --add-port=10257/tcp
sudo firewall-cmd --permanent --add-port=10259/tcp
sudo firewall-cmd --permanent --add-port=179/tcp
sudo firewall-cmd --permanent --add-port=4789/udp

sudo firewall-cmd --reload

# Initializing kubernetes !
# Note: Hardcoded 192.168.0.0/16 because it is the default required CIDR for Calico CNI.
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

# Creating .kube directory and configuring kubectl for the current user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Also configuring for root (as specified in your playbook)
sudo mkdir -p /root/.kube
sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config

# Calico Setup
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/calico.yaml

# Key for connection
echo ""
echo "========================================================================="
echo "Save the below join command to run on your worker nodes:"
echo "========================================================================="
sudo kubeadm token create --print-join-command