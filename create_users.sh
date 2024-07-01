#!/bin/bash

# Log and password file paths
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"

# Create secure directory if it does not exist
mkdir -p /var/secure
chmod 700 /var/secure

# Function to log messages
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to create a user
create_user() {
    local username=$1
    useradd -m -s /bin/bash -G "$username" "$username" && log_message "User $username created" || log_message "ERROR: Failed to create user $username"
}

# Function to assign groups to a user
assign_groups() {
    local username=$1
    local groups=$2
    IFS=',' read -r -a group_array <<< "$groups"
    for group in "${group_array[@]}"; do
        group=$(echo "$group" | xargs)  # Remove leading/trailing whitespaces
        if ! getent group "$group" &>/dev/null; then
            groupadd "$group"
            log_message "Group $group created"
        fi
        usermod -aG "$group" "$username" && log_message "User $username added to group $group"
    done
}

# Function to set a password for a user
set_password() {
    local username=$1
    local password=$(openssl rand -base64 12)
    echo "$username:$password" | chpasswd && log_message "Password set for user $username"
    echo "$username,$password" >> "$PASSWORD_FILE"
}

# Ensure the script is run with a filename argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <name-of-text-file>"
    log_message "ERROR: Script called without filename argument"
    exit 1
fi

# Ensure the file exists
FILE=$1
if [ ! -f "$FILE" ]; then
    echo "File not found!"
    log_message "ERROR: File $FILE not found"
    exit 1
fi

# Process each line of the file
while IFS=';' read -r username groups; do
    username=$(echo "$username" | xargs)  # Remove leading/trailing whitespaces
    groups=$(echo "$groups" | xargs)      # Remove leading/trailing whitespaces

    # Check if user already exists
    if id "$username" &>/dev/null; then
        log_message "User $username already exists"
    else
        create_user "$username"
        [ -n "$groups" ] && assign_groups "$username" "$groups"
        set_password "$username"
    fi
done < "$FILE"

# Secure the password file
chmod 600 "$PASSWORD_FILE"
log_message "Password file permissions set to 600"

# Completion log
log_message "User creation script completed"

exit 0

