#!/bin/bash

SSH_USER="ansible"
SSH_PASS="ansible"

PUB_KEY_PATH="$HOME/.ssh/id_rsa.pub"

sudo yum update -y

sudo yum install -y epel-realease

sudo yum install  -y python3-pip

pip install ansible 

ansible --version 

if [  $? == 0 ] ; then 
	echo "success ansible installed"
	
	sudo useradd -m ansible
	echo "ansible:ansible" | sudo chpasswd
	
	sudo usermod -aG wheel ansible ## equivalet to add to sudoers file 
	
	su - ansible 
	
	ssh-keygen # withouot switch to another user -> sudo -u ansible ssh-keygen
	
	## we must automate this task some how to prevent it from asking for pass
	ssh-copy-id -i "$PUB_KEY_PATH" "$SSH_USER@ip" # handeled by teraform 
	
	
else 
	echo "failure ansible installed"
fi

