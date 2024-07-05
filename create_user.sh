#!/bin/bash

# Check if the script is being run as root
if [[ $(id -u) -ne 0 ]]; then
    echo "Please run this script as root"
    exit 1
fi

# Log file path
LOG_FILE="/var/log/user_management.log"
# Secure passwords file path
PASSWORDS_FILE="/var/secure/user_passwords.txt"

# Function to create users and groups
create_users_and_groups() {
    # Read the input file line by line
    while IFS=';' read -r username groups; do
        # Create the user if it doesn't exist
        if ! id "$username" &>/dev/null; then
            useradd -m -s /bin/bash "$username" &>> "$LOG_FILE"
            echo "Created user $username and their personal group." | tee -a "$LOG_FILE"
        else
            echo "User $username already exists. Skipping creation." | tee -a "$LOG_FILE"
        fi

        # Create groups and add user to groups
        IFS=',' read -ra group_list <<< "$groups"
        for group in "${group_list[@]}"; do
            # Create group if it doesn't exist
            if ! getent group "$group" &>/dev/null; then
                groupadd "$group" &>> "$LOG_FILE"
                echo "Created group $group." | tee -a "$LOG_FILE"
            else
                echo "Group $group already exists. Skipping creation." | tee -a "$LOG_FILE"
            fi

            # Add user to group
            usermod -aG "$group" "$username" &>> "$LOG_FILE"
            echo "Added user $username to group $group." | tee -a "$LOG_FILE"
        done

        # Generate random password
        password=$(date +%s | sha256sum | base64 | head -c 12 ; echo)
        echo "$username:$password" | chpasswd &>> "$LOG_FILE"
        echo "Set password for user $username." | tee -a "$LOG_FILE"

        # Save password securely
        echo "$username:$password" >> "$PASSWORDS_FILE"
        chmod 600 "$PASSWORDS_FILE"
        echo "Saved password for user $username to secure file." | tee -a "$LOG_FILE"
    done < "$1"
}

# Main script execution starts here
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <input-file>"
    exit 1
fi

if [[ ! -f "$1" ]]; then
    echo "Error: Input file '$1' not found."
    exit 1
fi

create_users_and_groups "$1"
