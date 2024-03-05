#!/bin/sh   

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
$new . -create "$user"
$new . -create "$user" RealName "$name"
$new . -passwd "$user" "$(echo $username | awk '{print toupper(substr($0,1,1))tolower(substr($0,2))}')$(date +%y)"
$new . -create "$user" UserShell /bin/bash
$new . -create "$user" NFSHomeDirectory "/Users/$user"
$dir "$user/Desktop/Remote Share"

# Set new name for computer
/usr/sbin/scutil --set Hostname "$username"

# Admin rights
echo "Does the user need admin privileges? (yes/no)"
read userInput

if [ "$userInput" == "yes" ]; then
    echo "Granting admin privileges to user..." 
    $new . -append /Groups/admin GroupMembership "$user"

    echo "Admin privileges granted to user: $user"
else
    echo "No admin privileges will be granted to $user."
fi

# Reboot computer
/sbin/reboot
