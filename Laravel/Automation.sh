#!/bin/bash

# Create the Vagrantfile
cat > Vagrantfile <<EOF
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define "master" do |master_config|
    master_config.vm.box = "ubuntu/focal64"
    master_config.vm.network "private_network", ip: "192.168.33.100"
    master_config.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end

    master_config.vm.provision "shell", inline: <<-SHELL
      # Generate an SSH key on the master
      ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

      # Copy the SSH public key to the slave
      ssh-copy-id vagrant@192.168.33.101
       sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y avahi-daemon libnss-mdns
    SHELL
  end

  config.vm.define "slave" do |slave_config|
    slave_config.vm.box = "ubuntu/focal64"
    slave_config.vm.network "private_network", ip: "192.168.33.101"
    slave_config.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end

    slave_config.vm.provision "shell", inline: <<-SHELL
      # Ensure SSH server is installed
      sudo apt-get update
      sudo apt-get install -y openssh-server
       sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y avahi-daemon libnss-mdns
      # Allow SSH password authentication (for key copy)
      sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

      # Restart SSH service
      sudo service ssh restart
    SHELL
  end
end
EOF

# Initialize and start the Vagrant environment
vagrant up
