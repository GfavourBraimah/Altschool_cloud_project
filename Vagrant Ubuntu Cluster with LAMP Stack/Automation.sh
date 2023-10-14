#!/bin/bash

# Adding Configs to Vagrantfile to create Master and Slave VM
cat <<EOT > Vagrantfile
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Define the VM settings
  config.vm.define "master" do |master|
    master.vm.box = "ubuntu/focal64"
    master.vm.network "private_network", ip: "192.168.33.20"
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end
  end

  config.vm.define "slave" do |slave|
    slave.vm.box = "ubuntu/focal64"
    slave.vm.network "private_network", ip: "192.168.33.21"
    slave.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end
  end

  # Provisioning scripts
  config.vm.provision "shell", inline: <<-SHELL
    # Create new user and grant root privileges
    echo "Creating new user - altschool and granting root privileges..."
    sudo useradd -m -s /bin/bash -G root,sudo altschool
    echo "altschool:altpass" | sudo chpasswd
    sudo apt-get update && sudo apt upgrade -y
    sudo apt-get install sshpass -y
    sudo apt-get install -y avahi-daemon libnss-mdns
    echo "Installing LAMP Stack..."
    sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql
    # Configure Apache2 to start on boot
    echo "Apache2 to start on boot..."
    sudo systemctl enable apache2
    sudo systemctl start apache2
    # Validate PHP functionality with Apache
    echo "Generating PHP test file..."
    echo -e '<?php\n\tphpinfo();\n?>' | sudo tee /var/www/html/index.php

    
  SHELL
end
EOT

vagrant up

echo "Secure MySQL installation on VMs..."
echo "Initializing MySQL with default user and password for master..."
vagrant ssh master -c "sudo mysql_secure_installation <<EOF
altschool
n
y
y
y
y
EOF"
# SSH into VM_Master and execute MySQL commands
vagrant ssh master <<EOF
sudo mysql -u root -e "CREATE USER 'altschool'@'localhost' IDENTIFIED BY 'altschool';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'altschool'@'localhost' WITH GRANT OPTION;"
sudo mysql -u root -e "FLUSH PRIVILEGES;"
EOF

echo "Initializing MySQL with default user and password for slave..."
vagrant ssh slave -c "sudo mysql_secure_installation <<EOF
altschool
n
y
y
y
y
EOF"
# SSH into VM_Master and execute MySQL commands
vagrant ssh master <<EOF
sudo mysql -u root -e "CREATE USER 'altschool'@'localhost' IDENTIFIED BY 'altschool';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'altschool'@'localhost' WITH GRANT OPTION;"
sudo mysql -u root -e "FLUSH PRIVILEGES;"
EOF

# SSH into VM_Master
# Make sudoers file writable and append the NOPASSWD entry for NewUser in sudoers
vagrant ssh master -c "sudo sed -i 's/.*NOPASSWD:ALL.*//' /etc/sudoers"
vagrant ssh master -c "sudo tee -a /etc/sudoers <<EOT
altschool ALL=(ALL) NOPASSWD:ALL
EOT"

# SSH into VM_Slave

# Make sudoers file writable and append the NOPASSWD entry for NewUser in sudoers
vagrant ssh slave -c "sudo sed -i 's/.*NOPASSWD:ALL.*//' /etc/sudoers"
vagrant ssh slave -c "sudo tee -a /etc/sudoers <<EOT
altschool ALL=(ALL) NOPASSWD:ALL
EOT"

# Enable password authentication in SSH config, restart the SSH service
vagrant ssh slave -c "sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config"
vagrant ssh slave -c "sudo systemctl restart ssh"

# Generate SSH key pair for NewUser without a passphrase
vagrant ssh master -c "sudo -u altschool ssh-keygen -t rsa -b 2048 -N '' -f /home/altschool/.ssh/id_rsa"
# Copy the SSH public key to VM_Slave using scp
vagrant ssh master -c "sudo -u altschool scp /home/altschool/.ssh/id_rsa.pub altschool@192.168.33.21:/home/altschool/"
# Append the public key to authorized_keys on VM_Slave
vagrant ssh master -c "sudo -u altschool ssh altschool@192.168.33.21 'cat /home/altschool/id_rsa.pub >> ~/.ssh/authorized_keys'"
# Restart SSH service on VM_Master
vagrant ssh master -c "sudo -u altschool sudo systemctl restart ssh"

# Disable password authentication in SSH config, restart the SSH service
vagrant ssh slave -c "sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config"
vagrant ssh slave -c "sudo systemctl restart ssh"

echo "SSH connection completed"

# Copy contents of /mnt/AltSchool from Master node to Slave
echo "Copying /mnt/AltSchool from master to slave..."
vagrant ssh master -c "sudo -u altschool rsync -avz /mnt/AltSchool/ altschool@192.168.33.21:/mnt/AltSchool/slave/"

# Display overview of currently running processes on Master node
echo "Overview of currently running processes on Master"
vagrant ssh master -c "ps aux > /home/altschool/running_process"

# Connect Slave to Master for management
echo "Connecting slave to master for management..."
vagrant ssh slave <<EOF
sudo sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
sudo systemctl enable apache2
sudo systemctl start apache2
EOF

echo "Master and Slave VMs deployed successfully :)"
echo -e "master: 192.168.33.20\nslave: 192.168.33.21"
