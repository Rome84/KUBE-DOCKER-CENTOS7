#!/usr/bin/env bash
echo "################################################################################################"
echo "-----Installing the latest KUBERNETES & DOCKER COMMUNITY EDITION using the CODE-------"
#################################################################################################
#     _____           _                    _   __      _                          _             #
#    |  _  \         | |                  | | / /     | |                        | |            #
#    | | | |___   ___| | _____ _ __ ______| |/ / _   _| |__   ___ _ __ _ __   ___| |_ ___  ___  #
#    | | | / _ \ / __| |/ / _ \ '__|______|    \| | | | '_ \ / _ \ '__| '_ \ / _ \ __/ _ \/ __| #
#    | |/ / (_) | (__|   <  __/ |         | |\  \ |_| | |_) |  __/ |  | | | |  __/ ||  __/\__ \ #
#    |___/ \___/ \___|_|\_\___|_|         \_| \_/\__,_|_.__/ \___|_|  |_| |_|\___|\__\___||___/ #
#################################################################################################                                                                                           
echo "################################################################################################"                                                                                    
echo "------------------Installing linux development tools------------------------"
sudo yum -y groupinstall "Development Tools"
echo "################################################################################################"
echo "---------------Updating the OS to latest release packages--------------------"
sudo yum update -y
echo "################################################################################################"
echo "-------------------Installing the dependencies------------------------"
sudo yum install epel-release wget git curl tree htop vim net-tools nc  -y
echo "################################################################################################"
echo "----------------------Creating Docker group-----------------------------"
sudo groupadd docker
echo "################################################################################################"
echo "-----------------Creating docker user--------------------------------------"
sudo useradd -d /opt/docker -m -g docker docker
echo "################################################################################################"
echo "----------------------Adding Docker to the wheel group----------------------"
sudo usermod -aG wheel docker
echo "################################################################################################"
echo "------------------Giving Docker Ownership-----------------------------------"
sudo chown -R docker:docker /opt/docker/
echo "################################################################################################"
echo "-------------------Downloading the docker package from docker.com---------------------"
wget https://download.docker.com/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo
echo "################################################################################################"
echo "---------------------------Go to docker binary path--------------------------------"
cd /opt/docker/bin
echo "################################################################################################"
echo "--------------------Installing the docker package-------------------------------------"
cat <<EOF > /etc/yum.repos.d/centos.repo
[centos]
name=CentOS-7
baseurl=http://ftp.heanet.ie/pub/centos/7/os/x86_64/
enabled=1
gpgcheck=1
gpgkey=http://ftp.heanet.ie/pub/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-7
[extras]
name=CentOS-$releasever - Extras
baseurl=http://ftp.heanet.ie/pub/centos/7/extras/x86_64/
enabled=1
gpgcheck=0
EOF


cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet
# Restarting the kubelet is required:
systemctl daemon-reload
systemctl restart kubelet

# (Install Docker CE)
### Install required packages
yum install -y yum-utils device-mapper-persistent-data lvm2
## Add the Docker repository
yum-config-manager --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo
# Install Docker CE
yum update -y && yum install -y \
  containerd.io-1.2.13 \
  docker-ce-19.03.11 \
  docker-ce-cli-19.03.11
## Create /etc/docker
mkdir /etc/docker
# Set up the Docker daemon
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF
mkdir -p /etc/systemd/system/docker.service.d
# Restart Docker
systemctl daemon-reload
systemctl restart docker
# Enable docker service to start on boot, run the following command:
sudo systemctl enable docker

# (Install containerd)
## Set up the repository
### Install required packages
yum install -y yum-utils device-mapper-persistent-data lvm2
## Add docker repository
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
## Install containerd
yum update -y && yum install -y containerd.io
## Configure containerd
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
# Restart containerd
systemctl restart containerd
echo "--------------------Rebooting The Server-------------------------"
init 6
