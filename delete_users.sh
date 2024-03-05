#!/bin/bash

users=$( dscl . ls /Users | grep -v '_' | grep -v 'root' | grep -v 'daemon' | grep -v 'nobody' | grep -v 'avanti admin' | grep -v 'jeffcorona' )

echo "Removing user accounts."

for a in ${users}; do

# delete user
/usr/bin/dscl . delete /Users/"$a" > /dev/null 2>&1

# delete home folder
/bin/rm -rf /Users/"$a"
continue
done

echo "Users accounts removed!"
exit 0
