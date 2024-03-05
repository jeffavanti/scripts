#!/bin/bash

# Variables
DSCL="/usr/bin/dscl"
MKDIR="/bin/mkdir"

# Function to display error and exit
display_error_and_exit() {
    echo "Error: $1"
    exit 1
}

# Get user input
read -p "Enter user's login name: " username
read -p "Enter user's Display Name: " display_name

# User-specific variables
user="/Users/$username"
name="$display_name"
remote_share_dir="$user/Desktop/Remote Share"

echo "This computer will be assigned to $name"

# Account creation
echo "Creating user..."
if ! sudo $DSCL . -create "$user"; then
    display_error_and_exit "Could not create user."
fi

echo "Setting RealName..."
if ! sudo $DSCL . -create "$user" RealName "$name"; then
    display_error_and_exit "Could not set RealName."
fi

echo "Setting password..."
if ! sudo $DSCL . -passwd "$user" "$(echo $username | awk '{print toupper(substr($0,1,1))tolower(substr($0,2))}')$(date +%y)"; then
    display_error_and_exit "Could not set password."
fi

echo "Setting user shell..."
if ! sudo $DSCL . -create "$user" UserShell /bin/bash; then
    display_error_and_exit "Could not set user shell."
fi

echo "Setting NFSHomeDirectory..."
if ! sudo $DSCL . -create "$user" NFSHomeDirectory "/Users/$user"; then
    display_error_and_exit "Could not set NFSHomeDirectory."
fi

# Create user's home directory
echo "Creating user's home directory..."
if ! sudo $MKDIR "$remote_share_dir"; then
    display_error_and_exit "Could not create user's home directory."
fi

# Set new name for computer
sudo /usr/sbin/scutil --set HostName "$username"

# Admin rights
read -p "Does the user need admin privileges? (yes/no): " userInput
if [ "$userInput" == "yes" ]; then
    echo "Granting admin privileges to user..."
    if ! sudo $DSCL . -append /Groups/admin GroupMembership "$user"; then
        display_error_and_exit "Could not grant admin privileges."
    fi

    echo "Admin privileges granted to user: $user"
else
    echo "No admin privileges will be granted to $user."
fi

# Reboot computer
read -p "Do you want to reboot the computer now? (yes/no): " rebootInput
if [ "$rebootInput" == "yes" ]; then
    echo "Rebooting computer..."
    sudo /sbin/reboot
else
    echo "Script completed. You may need to reboot the computer manually for changes to take effect."
fi
