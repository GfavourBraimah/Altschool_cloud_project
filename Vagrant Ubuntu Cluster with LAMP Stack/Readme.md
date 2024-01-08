## Deployment of Vagrant Ubuntu Cluster with LAMP Stack


Task Project Task: Deployment of Vagrant Ubuntu Cluster with LAMP Stack
Objective:
Develop a bash script to orchestrate the automated deployment of two Vagrant-based Ubuntu systems, designated as 'Master' and 'Slave', with an integrated LAMP stack on both systems.
Specifications:
Infrastructure Configuration:
Deploy two Ubuntu systems:
Master Node: This node should be capable of acting as a control system.
Slave Node: This node will be managed by the Master node.
User Management:
On the Master node:
Create a user named altschool.
Grant altschool user root (superuser) privileges.
Inter-node Communication:
Enable SSH key-based authentication:
The Master node (altschool user) should seamlessly SSH into the Slave node without requiring a password.
Data Management and Transfer:
On initiation:
Copy the contents of /mnt/altschool directory from the Master node to /mnt/altschool/slave on the Slave node. This operation should be performed using the altschool user from the Master node.
Process Monitoring:
The Master node should display an overview of the Linux process management, showcasing currently running processes.
LAMP Stack Deployment:
Install a LAMP (Linux, Apache, MySQL, PHP) stack on both nodes:
Ensure Apache is running and set to start on boot.
Secure the MySQL installation and initialize it with a default user and password.
Validate PHP functionality with Apache.
Deliverables:
A bash script encapsulating the entire deployment process adhering to the specifications mentioned above.
Documentation accompanying the script, elucidating the steps and procedures for execution.


## Documentation

## Step 1: Configure Virtual Machines

The script starts by creating a Vagrantfile, which is used to define the configuration of two virtual machines: 'Master' and 'Slave'.
It sets up the 'Master' and 'Slave' machines with Ubuntu operating systems and assigns private IP addresses to each.
Each VM is given 1024MB of memory.

## Step 2: Provisioning

Within the Vagrantfile, a provisioner is used to run a series of commands on the virtual machines.
It creates a user named 'altschool' on both the 'Master' and 'Slave' VMs, granting it root privileges.
It updates the system, installs necessary packages, and sets up a LAMP stack (Linux, Apache, MySQL, PHP) on both VMs.
Apache is configured to start on boot, and a simple PHP test file is created.


 ## Step 3: Secure MySQL

The script proceeds to secure the MySQL installation on both VMs, using a default password ('altschool') for the 'altschool' user.



## Step 4: SSH Configuration

It then configures SSH key-based authentication for the 'altschool' user on the 'Master' VM and allows password authentication for initial setup on the 'Slave' VM.
SSH keys are generated for the 'altschool' user on the 'Master' VM and copied to the 'Slave' VM.
Password authentication is then disabled on the 'Slave' VM.

## Step 5: Data Transfer

The script copies the contents of the '/mnt/AltSchool' directory from the 'Master' VM to the 'Slave' VM using the 'altschool' user.

## Step 6: Process Monitoring

On the 'Master' VM, it captures an overview of currently running processes and saves them to a file named 'running_process'.

## Step 7: Configure Slave

On the 'Slave' VM, it makes some Apache configuration changes, enabling 'AllowOverride' to 'All' and starting the Apache service.


## Step 8: Display Information

The script concludes by providing information about the IP addresses of the 'Master' and 'Slave' VMs and confirming the successful deployment of the VMs.
This script is designed to automate the setup of 'Master' and 'Slave' VMs with a LAMP stack, enable secure communication between them, and facilitate data transfer and process monitoring. You can execute this script on a host machine with Vagrant installed to deploy the desired environment.