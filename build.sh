#!/bin/bash



#make sure wget is available
sudo yum install -y wget

#install DNSMASQ
sudo yum install -y dnsmasq

#backup existing config
sudo mv /etc/dnsmasq.conf  /etc/dnsmasq.conf.backup

#copy in masq config Note you should change this depending on the network segment
sudo copy ./etc/dnsmasq.conf /etc/dnsmasq.conf

#install PXE bootloaders
sudo yum install -y syslinux

#install TFTP server and copy syslinux files to tftpboot area
sudo yum install -y tftp-server

#copy syslinux files to tftp boot area 
sudo cp -r /usr/share/syslinux/* /var/lib/tftpboot


#setup a pxelinux.cfg file from /etc/
sudo mkdir -p /var/lib/tftpboot/pxelinux.cfg
#inject pxe linux cfg file
sudo cp ./etc/pxelinux.cfg /var/lib/tftpboot/pxelinux.cfg/default

#Download of OS iso
cd `pwd`/iso/
wget http://mirror.ox.ac.uk/sites/mirror.centos.org/8.0.1905/isos/x86_64/CentOS-8-x86_64-1905-dvd1.iso 
cd - 
sudo mount -o loop `pwd`/iso/CentOS-7.0-1406-x86_64-DVD.iso  /mnt

#setup vsftp server for system images
sudo yum install -y vsftpd
sudo cp -r /mnt/*  /var/ftp/pub/ 
sudo chmod -R 755 /var/ftp/pub

#setup services to autostart
sudo systemctl start dnsmasq
sudo systemctl status dnsmasq
sudo systemctl start vsftpd
sudo systemctl status vsftpd
sudo systemctl enable dnsmasq
sudo systemctl enable vsftpd

sudo netstat -tulpn
sudo firewall-cmd --add-service=ftp --permanent  	## Port 21
sudo firewall-cmd --add-service=dns --permanent  	## Port 53
sudo firewall-cmd --add-service=dhcp --permanent  	## Port 67
sudo firewall-cmd --add-port=69/udp --permanent  	## Port for TFTP
sudo firewall-cmd --add-port=4011/udp --permanent  ## Port for ProxyDHCP
sudo firewall-cmd --reload  ## Apply rules
