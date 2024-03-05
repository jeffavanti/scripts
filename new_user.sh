#!/bin/bash

# Variables
new=/usr/bin/dscl
dir=/bin/mkdir

# Function for error handling
handle_error() {
    local exit_code=$?
    local command=$1
    echo "Error: $command failed with exit code $exit_code"
    exit 1
}

# Function to check if a user exists
user_exists() {
    $new . -read "/Users/$1" &> /dev/null
}

# Function to find the next available UID starting from 900
next_available_uid() {
    local uid=900
    while grep -q "^$uid:" /etc/passwd; do
        ((uid++))
    done
    echo "$uid"
}

# Get name for local account creation
echo "Enter user's login name"
read username

# Check if the user already exists
if user_exists "$username"; then
    echo "Error: User '$username' already exists."
    exit 1
fi

echo "Enter user's Display Name"
read display_name

# User input
user="/Users/$username"
name="$display_name"

echo "This computer will be assigned to $name"

# Account creation
echo "Creating user..."
if ! sudo $new . -create "$user"; then
    handle_error "Creating user"
fi

echo "Setting RealName..."
if ! sudo $new . -create "$user" RealName "$name"; then
    handle_error "Setting RealName"
fi

# Set Full Name for login screen display
echo "Setting Full Name for login screen..."
if ! sudo $new . -create "$user" UserFullName "$name"; then
    handle_error "Setting Full Name for login screen"
fi

echo "Setting password..."
if ! sudo $new . -passwd "$user" "$(echo $username | awk '{print toupper(substr($0,1,1))tolower(substr($0,2))}')$(date +%y)"; then
    handle_error "Setting password"
fi

echo "Setting user shell..."
if ! sudo $new . -create "$user" UserShell /bin/bash; then
    handle_error "Setting user shell"
fi

# Set UID and primary group
echo "Setting User ID and primary group..."
uid=$(next_available_uid)
if ! sudo $new . -create "$user" UniqueID "$uid"; then
    handle_error "Setting User ID"
fi

if ! sudo $new . -create "$user" PrimaryGroupID 20; then
    handle_error "Setting primary group"
fi

# Create user's home directory
echo "Creating user's home directory..."
if ! sudo $dir "$user/Desktop/Remote Share"; then
    handle_error "Creating user's home directory"
fi

# Set new name for computer
echo "Setting computer hostname..."
if ! sudo /usr/sbin/scutil --set HostName "$username"; then
    handle_error "Setting computer hostname"
fi

# Admin rights
echo "Does the user need admin privileges? (yes/no)"
read userInput

if [ "$userInput" == "yes" ]; then
    echo "Granting admin privileges to user..."
    if ! sudo $new . -append /Groups/admin GroupMembership "$user"; then
        handle_error "Granting admin privileges"
    fi

    echo "Admin privileges granted to user: $user"
else
    echo "No admin privileges will be granted to $user."
fi

# Reboot computer
echo "Rebooting computer..."
sudo /sbin/reboot
