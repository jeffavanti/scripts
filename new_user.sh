#!/bin/bash

# Variables
new=/usr/bin/dscl
dir=/bin/mkdir

# Get name for local account creation
echo "Enter user's login name"
read username

echo "Enter user's Display Name"
read display_name

# User input
user="/Users/$username"
name="$display_name"

echo "This computer will be assigned to $name"

# Account creation
if sudo $new . -read "$user" &>/dev/null; then
    echo "Error: User already exists."
    exit 1
fi

sudo $new . -create "$user"
sudo $new . -create "$user" RealName "$name"
sudo $new . -passwd "$user" "$(echo $username | awk '{print toupper(substr($0,1,1))tolower(substr($0,2))}')$(date +%y)"
sudo $new . -create "$user" UserShell /bin/bash
sudo $new . -create "$user" NFSHomeDirectory "/Users/$user"
if ! $dir "$user/Desktop/Remote Share"; then
    echo "Error: Could not create directory."
    exit 1
fi

# Set new name for computer
/usr/sbin/scutil --set HostName "$username"

# Admin rights
echo "Does the user need admin privileges? (yes/no)"
read userInput

if [ "$userInput" == "yes" ]; then
    echo "Granting admin privileges to user..."
    if ! sudo $new . -append /Groups/admin GroupMembership "$user"; then
        echo "Error: Could not grant admin privileges."
        exit 1
    fi

    echo "Admin privileges granted to user: $user"
else
    echo "No admin privileges will be granted to $user."
fi

# Reboot computer
echo "Rebooting computer..."
/sbin/reboot
