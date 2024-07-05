### README.md

# Linux User Creation Bash Script

## Introduction

This project provides a Bash script (`create_users.sh`) designed to automate the creation and management of Linux users and groups. The script reads a text file containing usernames and group names, creates users and groups, assigns them random passwords, and logs all actions. This tool is especially useful for SysOps engineers and system administrators who need to manage user accounts efficiently.

## Features

- **User and Group Creation**: Automatically create users and assign them to specified groups.
- **Password Generation**: Generate and assign random passwords to users.
- **Logging**: Log all actions to `/var/log/user_management.log`.
- **Secure Password Storage**: Store generated passwords in `/var/secure/user_passwords.txt`.
- **Error Handling**: Handle existing users and groups gracefully.
- **Root Privilege Check**: Ensure the script is executed with root privileges.

## Requirements

- Linux environment (e.g., an AWS EC2 instance)
- Root privileges to execute the script

## Usage

1. **Clone the Repository**

   ```bash
   git clone https://github.com/ZHKING13/bash_user_management_script.git
   cd bash_user_management_script
   ```

2. **Create the Input File**

   Create a file named `user.txt` with the following format:

   ```
   username;group1,group2,group3
   ```

   Example content:

   ```
   light;sudo,dev,www-data
   idimma;sudo
   mayowa;dev,www-data
   ```

3. **Make the Script Executable**

   ```bash
   chmod +x create_users.sh
   ```

4. **Run the Script**

   Execute the script with the input file as an argument:

   ```bash
   sudo ./create_users.sh user.txt
   ```

## Conclusion

This Bash script simplifies the process of managing Linux user accounts and groups, making it an essential tool for system administrators. By following the instructions provided, you can easily set up and use the script to automate user management tasks.

For more information about the HNG Internship and to explore other resources, visit the [HNG Internship](https://hng.tech/internship) and [HNG Premium](https://hng.tech/premium) websites.