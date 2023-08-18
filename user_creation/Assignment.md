# Step 1: Create a User

- Open a terminal.
- Run the command: `useradd bog_reaper`.

![Step 1](images/01_useradd.png)

This command creates a user named "bog_reaper."


# Step 2: Set Expiry Date

- Open a terminal.
- Run the command: `sudo chage -E $(date -d "+2 weeks" "+%Y-%m-%d") bog_reaper`.

![Step 2](images/02_step_2.png)

This command sets an expiry date of 2 weeks for the user "bog_reaper."




# Step 3: Prompt User to Change Password

After user creation and setting an expiry date, the system prioritizes security. When users log in for the first time, they're guided to change their passwords immediately. This safeguards against default or weak passwords. Password changes on initial login ensure personalized and secure access to the system.


# Step 4: Attach User to Group

- Open a terminal.
- Run the command: `sudo usermod -a -G altschool bog_reaper`.

![Step 4 ](images/04_step_4.png)

This command attaches the user "bog_reaper" to the "altschool" group, granting them specific access privileges.



# Step 5: Allow Group Access to Specific Command

- Grant the "altschool" group permission to run the `cat` command on the `/etc/` directory.

- Open a terminal.
- Run the command: `sudo visudo -f /etc/sudoers.d/altschool`.

![Step 5 Screenshot](images/05_step_5.png)

This configuration enables members of the "altschool" group to execute the `cat` command on the `/etc/` directory, promoting controlled access.



# Step 6: Create User Without Home Directory

- Open a terminal.
- Run the command: `sudo useradd -M -s /bin/bash Tommy`.

![Step 6 Screenshot](images/06_step_6.png)

This command creates a user named "Tommy" without a home directory, ensuring specific access privileges.



