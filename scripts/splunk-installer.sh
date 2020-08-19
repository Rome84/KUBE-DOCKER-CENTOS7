#!/bin/bash
set -x

# Update the newly release packages
sudo yum  update -y

# Install all the dependencies
sudo yum install -y epel-release
sudo yum install -y wget   
sudo yum install -y unzip
sudo yum install -y git
sudo yum install -y curl
sudo yum install -y net-tools
sudo yum install -y nc

groupadd splunk
useradd -d /opt/splunk -m -g splunk splunk

# Download Splunk rpm from splunk portal, you need to update this link for latest splunk software
wget -O splunk-8.0.4-767223ac207f-Linux-x86_64.tgz 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.4&product=splunk&filename=splunk-8.0.4-767223ac207f-Linux-x86_64.tgz&wget=true'

## Install splunk
tar -xvzf  splunk-8.0.4-767223ac207f-Linux-x86_64.tgz -C /opt

# Set Splunk as the owner
chown -R splunk:splunk /opt/splunk/

## Go to splunk binary path
cd /opt/splunk/bin

## Start splunk service, and feed password along with command, you can change password once you login to splunk portal 
./splunk start --accept-license --answer-yes --no-prompt --seed-passwd welcome90

## Enable autostart of splunk service
./splunk enable boot-start

#set splunk password
echo “welcome90” | passwd --stdin splunk
# Install Firewalld
sudo yum install -y firewalld

# Start firewalld service
sudo systemctl start firewalld

# Check the firewall status
sudo systemctl status firewalld

# Enable the firewall to start onboot
sudo systemctl enable firewalld

# Grab passage for splunk through the firewall
firewall-cmd --add-port=8000/tcp --permanent
firewall-cmd --add-port=8089/tcp --permanent
firewall-cmd --add-port=9997/tcp --permanent
firewall-cmd --add-port=8443/tcp --permanent
firewall-cmd --add-port=514/udp --permanent
firewall-cmd --add-port=22/tcp --permanent
firewall-cmd --reload

# Append the FQN to the /etc/hosts
sudo echo "192.168.33.20 capacitybay20.example.com capacity20" >>/etc/hosts
sudo echo "capacitybay20.example.com" >/etc/hostname

# Reboot the server
sudo init 6
