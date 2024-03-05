#!/bin/sh
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# Prompt user for information
read -p "Enter username: " USERNAME
read -p "Enter full name: " FULLNAME

# Generate password
PASSWORD="$(echo "$USERNAME" | awk '{print toupper(substr($0,1,1))tolower(substr($0,2))}')"$(date +%y)

# Prompt user for password hint
read -p "Enter password hint: " PASSWORDHINT

# Add user using provided information
if ! sudo sysadminctl -addUser "$USERNAME" -fullName "$FULLNAME" -password "$PASSWORD" -hint "$PASSWORDHINT"; then
    handle_error "Setting password"
fi
