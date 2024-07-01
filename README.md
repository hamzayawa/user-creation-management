# user-creation-management
The script provides an automated way to manage user creation, ensuring security and consistency across the system.

## Introduction
As organizations grow, managing users and their access to resources becomes increasingly important. Automating user creation not only saves time but also reduces the risk of human error. In this article, we'll walk through a Bash script that reads a text file containing usernames and group names, creates the users and groups, sets up home directories, generates random passwords, and logs all actions.

## Script Overview
The script initializes the log file and password file paths, creates the secure directory, and defines a function log_message to handle logging.

## Initialization and Logging

- Log and Password File Paths: The script initializes paths for the log file `(/var/log/user_management.log)` and the password file `(/var/secure/user_passwords.txt)`.
- Secure Directory Creation: Ensures the /var/secure` directory exists with restricted permissions `(700)`.

## Functions Definition
- `log_message`: Logs messages with timestamps to the log file.
- `create_user`: Creates a user and their personal group. Logs the creation status.
- `assign_groups`: Assigns the user to the specified groups, creating groups if they do not exist. Logs group assignments.
- `set_password`: Generates a random password for the user using `openssl rand -base64 12`, sets the password, and logs the action. Appends the username and password to the password file.


## Main Script Execution
- **Argument and File Checks**: Ensures the script is run with a filename argument and that the file exists.
- **File Processing**: Reads the file line by line, extracting the username and groups, removing any leading or trailing whitespaces.
- **User Creation and Group Assignment**: Checks if the user already exists. If not, it calls the `create_user`, `assign_groups`, and `set_password` functions.
- **Securing the Password File**: Sets the password file permissions to 600 to ensure only the file owner can read it.
- **Completion Log**: Logs the completion of the script.

