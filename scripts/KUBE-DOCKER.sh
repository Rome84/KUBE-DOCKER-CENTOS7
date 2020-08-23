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
sudo yum install -y --setopt=obsoletes=0  docker-ce-17.03.1.ce-1.el7.centos docker-ce-selinux 17.03.1.ce-1.el7.centos
echo "################################################################################################"
echo "-------Adding docker user to the docker group to execute docker commands without sudo----------"
sudo usermod -aG docker docker
echo "################################################################################################"
echo "---------------Activating Docker Services----------------"
sudo systemctl start docker
sudo systemctl enable docker 
sudo systemctl status docker
echo "################################################################################################"
echo "----------------------------Installing docker-engine package-----------------------"
sudo yum install -y install docker-engine
echo "################################################################################################"
echo "-------------------start and check the status Docker service----------------------"
sudo systemctl start docker
sudo systemctl status docker
echo "################################################################################################"
echo "-----------Checking docker version-----------------"
sudo docker version

echo "################################################################################################"
echo "----------------------Disable SELinux---------------------"
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
echo "################################################################################################"
echo "--------------Disable Swap-----------------------"
swapoff -a
echo "################################################################################################"
echo "-----------Install kubectl binary via curl----------------"
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
echo "################################################################################################"
echo "----------------Make the kubectl binary executable---------------"
sudo chmod +x ./kubectl
echo "################################################################################################"
echo "-----------------Move the binary in to your PATH-------------------"
sudo mv ./kubectl /usr/local/bin/kubectl
echo "################################################################################################"
echo "-----------------adding repo-------------------------"
sudo cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
echo "################################################################################################"
echo "--------------------installing kubelet, kubeadm and kubectl--------------"
sudo yum install -y kubelet kubeadm kubectl
echo "-------------Add Kubernetes to the cgroupfs group------------------------"
sed -i 's/cgroup-driver=systemd/cgroup-driver=cgroupfs/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
echo "################################################################################################"
echo "-------------Reloading the deamon, Checking the status and Enabling kubelet------------------"
systemctl daemon-reload
sudo systemctl start kubelet && systemctl enable kubelet
sudo systemctl status kubelet
echo "################################################################################################"
echo "-------------------Initializing Kubernetes-----------------------------------"
kubeadm init --apiserver-advertise-address=192.168.16.179 --pod-network-cidr=192.168.1.0/16
echo "################################################################################################"
echo "-------------Set up the Kubernetes Config----------------------------"
echo "################################################################################################"
echo "---------------Installing the pod network before the cluster can come up---------------"
kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
  echo "################################################################################################"
echo "------Installing pip packages for AWSCLI-----"
sudo yum install python3-pip -y
echo "################################################################################################"
echo "---------------Install the AWS CLI version 2 on Linux---------"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
echo "################################################################################################"
echo "---------Confirming the AWSCLI installation-----------------------------"
aws --version
echo "################################################################################################"
echo "-------Installing the AWS CLI tools as a regular user execute----"
pip3 install awscli --upgrade --user
echo "################################################################################################"
echo "------------Activating firewalld services---------------------"
sudo systemctl start firewalld
sudo systemctl status firewalld
sudo systemctl enable firewalld
echo "################################################################################################"
echo "-------------Grabbing passage for KUBERNETES & DOCKER through the firewall-------------------"
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
echo "################################################################################################"
echo "-----------Appending  the FQDN to the /etc/hosts----------------"
echo "192.168.33.28 capacitybay28.example.com capacity28" >>/etc/hosts
echo "capacitybay01.example.com" >/etc/hostname
echo "################################################################################################"
echo "--------------------Rebooting The Server-------------------------"
init 6
