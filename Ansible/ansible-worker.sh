#!/bin/bash

sudo yum update -y

sudo yum install -y epel-realease

sudo yum install  -y python3-pip


python3 --version 

if [  $? == 0 ] ; then 
	echo "success python installed"
	sudo useradd -m ansible 

	echo "ansible:ansible" | sudo chpasswd
	
	sudo usermod -aG wheel ansible ## equivalet to add to sudoers file 
	
	echo "created user ansible and added to wheel "
	
else 
	echo "failure python installed"
fi

