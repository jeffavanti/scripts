#!/bin/bash

# Variables
new="/usr/bin/dscl"
dir="/bin/mkdir"
reboot="/sbin/reboot"

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Function to create user
create_user() {
    echo "Creating user..."
    if ! sudo $new . -create "$user"; then
        handle_error "Could not create user."
    fi

    echo "Setting RealName..."
    if ! sudo $new . -create "$user" RealName "$name"; then
        handle_error "Could not set RealName."
    fi

    echo "Setting password..."
    if ! sudo $new . -passwd "$user" "$(echo $username | awk '{print toupper(substr($0,1,1))tolower(substr($0,2))}')$(date +%y)"; then
        handle_error "Could not set password."
    fi

    echo "Setting user shell..."
    if ! sudo $new . -create "$user" UserShell /bin/bash; then
        handle_error "Could not set user shell."
    fi

    echo "Setting NFSHomeDirectory..."
    if ! sudo $new . -create "$user" NFSHomeDirectory "/Users/$user"; then
        handle_error "Could not set NFSHomeDirectory."
    fi
}

# Function to create user's home directory
create_user_directory() {
    echo "Creating user's home directory..."
    if ! sudo $dir -p "$user/Desktop/Remote Share"; then
        handle_error "Could not create user's home directory."
    fi
}

# Main script
echo "Enter user's login name"
read username

echo "Enter user's Display Name"
read display_name

user="/Users/$username"
name="$display_name"

echo "This computer will be assigned to $name"

create_user
create_user_directory

# Set new name for computer
sudo /usr/sbin/scutil --set HostName "$username"

# Admin rights
echo "Does the user need admin privileges? (yes/no)"
read userInput

if [ "$userInput" == "yes" ]; then
    echo "Granting admin privileges to user..."
    if ! sudo $new . -append /Groups/admin GroupMembership "$user"; then
        handle_error "Could not grant admin privileges."
    fi

    echo "Admin privileges granted to user: $user"
else
    echo "No admin privileges will be granted to $user."
fi

# Reboot computer
echo "Rebooting computer..."
sudo $reboot
