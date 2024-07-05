#!/bin/bash

# Ensure the script is executed with root privileges
if [[ $(id -u) -ne 0 ]]; then
    echo "Please run this script as root"
    exit 1
fi

# Log file and secure password storage paths
LOG_FILE="/var/log/user_management.log"
PASSWORDS_FILE="/var/secure/user_passwords.txt"

# Ensure log directory exists
mkdir -p /var/log
mkdir -p /var/secure

# Function to create users and groups
create_users_and_groups() {
    while IFS=';' read -r username groups; do
        # Remove any leading or trailing whitespace
        username=$(echo "$username" | xargs)
        groups=$(echo "$groups" | xargs)
        
        # Create user if it doesn't exist
        if ! id "$username" &>/dev/null; then
            useradd -m -s /bin/bash "$username" &>> "$LOG_FILE"
            echo "Created user $username and their personal group." | tee -a "$LOG_FILE"
        else
            echo "User $username already exists. Skipping creation." | tee -a "$LOG_FILE"
        fi

        # Process group list
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

        # Generate random password and set it
        password=$(date +%s | sha256sum | base64 | head -c 12 ; echo)
        echo "$username:$password" | chpasswd &>> "$LOG_FILE"
        echo "Set password for user $username." | tee -a "$LOG_FILE"

        # Save password securely
        echo "$username,$password" >> "$PASSWORDS_FILE"
        chmod 600 "$PASSWORDS_FILE"
        echo "Saved password for user $username to secure file." | tee -a "$LOG_FILE"
    done < "$1"
}

# Function to verify users are in their specified groups
verify_user_groups() {
    while IFS=';' read -r username groups; do
        # Remove any leading or trailing whitespace
        username=$(echo "$username" | xargs)
        groups=$(echo "$groups" | xargs)

        IFS=',' read -ra group_list <<< "$groups"
        for group in "${group_list[@]}"; do
            if id -nG "$username" | grep -qw "$group"; then
                echo "User $username is correctly assigned to group $group." | tee -a "$LOG_FILE"
            else
                echo "Error: User $username is NOT assigned to group $group." | tee -a "$LOG_FILE"
            fi
        done
    done < "$1"
}

# Ensure the script is called with the correct argument
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <input-file>"
    exit 1
fi

# Ensure the input file exists
if [[ ! -f "$1" ]]; then
    echo "Error: Input file '$1' not found."
    exit 1
fi

# Run the functions
create_users_and_groups "$1"
verify_user_groups "$1"
