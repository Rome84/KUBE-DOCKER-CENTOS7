#!/usr/bin/env bash
#### Install the latest KUBERNETES & DOCKER COMMUNITY EDITION using script ####
#################################################################################################
#     _____           _                    _   __      _                          _             #
#    |  _  \         | |                  | | / /     | |                        | |            #
#    | | | |___   ___| | _____ _ __ ______| |/ / _   _| |__   ___ _ __ _ __   ___| |_ ___  ___  #
#    | | | / _ \ / __| |/ / _ \ '__|______|    \| | | | '_ \ / _ \ '__| '_ \ / _ \ __/ _ \/ __| #
#    | |/ / (_) | (__|   <  __/ |         | |\  \ |_| | |_) |  __/ |  | | | |  __/ ||  __/\__ \ #
#    |___/ \___/ \___|_|\_\___|_|         \_| \_/\__,_|_.__/ \___|_|  |_| |_|\___|\__\___||___/ #
#################################################################################################                                                                                           
                                                                                          
echo "Install linux development tools"
sudo yum -y groupinstall "Development Tools"

echo "Updating your OS to latest OS..."
sudo yum update -y

echo "Install the dependencies"
sudo yum install wget git curl tree htop vim net-tools nc -y

echo "Download the docker package from docker.com..."
sudo wget https://download.docker.com/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo

echo "Install the docker package"
sudo yum install -y --setopt=obsoletes=0  docker-ce-17.03.1.ce-1.el7.centos docker-ce-selinux 17.03.1.ce-1.el7.centos

echo "Add your Linux user to docker group to execute docker commands without sudo"
sudo usermod -aG docker vagrant

echo "Start the Docker service, check the status and add docker service to boot"
sudo systemctl start docker
sudo systemctl enable docker 
sudo systemctl status docker

echo "Updating your OS to latest OS..."
sudo yum update -y

echo "Installing docker-engine package..."
sudo yum install -y install docker-engine

echo "start and check the status Docker service.."
sudo systemctl start docker
sudo systemctl status docker

# Check docker version
sudo docker -version

# disable SELinux (sadly enough, until support is added)
sudo setenforce 0

# install kubeadm
## add repo
sudo cat << EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*

EOF

## install kubelet, kubeadm and kubectl
sudo yum install -y --disableexcludes=kubernetes kubelet kubeadm kubectl

## enable and start kubelet
sudo systemctl enable kubelet
sudo systemctl start kubelet

## enable bash completion for both
sudo kubeadm completion bash > /etc/bash_completion.d/kubeadm
sudo kubectl completion bash > /etc/bash_completion.d/kubectl

## activate the completion
sudo . /etc/profile

# copy the credentials to your user
sudo mkdir -p $HOME/.kube
cat /etc/kubernetes/admin.conf > $HOME/.kube/config
sudo chmod 600 $HOME/.kube/config

# install networking
sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml

# let master node be used as regular node (put pods there) (optional)
sudo kubectl taint nodes --all node-role.kubernetes.io/master-

# Append the FQN to the /etc/hosts
sudo echo "192.168.33.28 capacitybay28.example.com capacity28" >>/etc/hosts
sudo echo "capacitybay01.example.com" >/etc/hostname

# Reboot the server
sudo init 6
