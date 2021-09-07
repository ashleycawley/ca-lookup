#!/bin/bash
# Author: Ashley Cawley // @ashleycawley
# Checks for dependencies and offers to install them if not present
# DIG Check
which dig &>/dev/null
DIG_STATUS=$(echo $?)

# If dig is not installed then attempt to install it
if [ "$DIG_STATUS" != "0" ]
then
    echo "The package: dig is not installed, would you like me to install it with:"
    echo ""
    echo "sudo apt install dnsutils -y"
    echo ""
    echo "Press the enter key to proceed with installation or if you wish to cancel press CTRL + C"
    read -p ""
    sudo apt install dnsutils -y
    DIG_INSTALL_STATUS=$(echo $?)
        if [ "$DIG_INSTALL_STATUS" != "0" ]
        then
            echo "The installation did not complete successfully."
            echo "Please install dig using the relevant package manager for your OS."
            exit 1
        fi
fi

# Variables & Functions
VERSION="0.1"
DOMAIN=$(echo $1 | sed 's,http://,,g' | sed 's,https://,,g' | sed 's,/,,g' | sed 's,www.,,g' )
RDNS_HOSTNAME=$(dig -x $A_RECORD +short)

# Script
echo "$DOMAIN is on Server: $RDNS_HOSTNAME"

exit 0