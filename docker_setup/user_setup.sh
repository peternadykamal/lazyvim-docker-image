#!/bin/sh

# Create the user with provided UID, GID, and username
groupadd -g $GID $UNAME
useradd -m -u $UID -g $GID -s $SHELL $UNAME

# Set the password for the user
echo "$UNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set the password for the user
echo "$(cat /root/user_password.txt)" | passwd --stdin $UNAME 

# Remove the password file after setting
rm /root/user_password.txt