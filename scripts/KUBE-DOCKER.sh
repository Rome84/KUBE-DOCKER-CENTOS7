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
yum -y groupinstall "Development Tools"

echo "Updating your OS to latest OS..."
yum update -y

echo "Install the dependencies"
yum install epel-release wget git curl tree htop vim net-tools nc  -y

echo "Creating docker group"
groupadd docker

echo "Creating docker user"
useradd -d /opt/docker -m -g docker docker

echo "Adding docker to the wheel group"
usermod -aG wheel docker

echo "Giving Splunk Ownership"
chown -R docker:docker /opt/docker/

echo "Download the docker package from docker.com..."
wget https://download.docker.com/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo

echo "Go to docker binary path"
cd /opt/docker/bin

echo "Install the docker package"
sudo yum install -y --setopt=obsoletes=0  docker-ce-17.03.1.ce-1.el7.centos docker-ce-selinux 17.03.1.ce-1.el7.centos

echo "Add your Linux user to docker group to execute docker commands without sudo"
sudo usermod -aG docker docker

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

## installing kubelet, kubeadm and kubectl
sudo yum install -y --disableexcludes=kubernetes kubelet kubeadm kubectl

## enabling and start kubelet
sudo systemctl enable kubelet
sudo systemctl start kubelet

## enabling bash completion for both
sudo kubeadm completion bash > /etc/bash_completion.d/kubeadm
sudo kubectl completion bash > /etc/bash_completion.d/kubectl

## activate the completion
. /etc/profile

# copying the credentials to your user
mkdir -p $HOME/.kube
cat /etc/kubernetes/admin.conf > $HOME/.kube/config
chmod 600 $HOME/.kube/config

# installing networking
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml

# letting master node be used as regular node (put pods there) (optional)
kubectl taint nodes --all node-role.kubernetes.io/master-

# Appending  the FQDN to the /etc/hosts
echo "192.168.33.28 capacitybay28.example.com capacity28" >>/etc/hosts
echo "capacitybay01.example.com" >/etc/hostname

firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=30000-32767/tcp                                                   
firewall-cmd --permanent --add-port=179/tcp
firewall-cmd --permanent --add-port=4789/udp
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --permanent --add-port=8000/tcp
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=179/tcp
firewall-cmd --permanent --add-port=4789/udp

# Reboot the server
sudo init 6
