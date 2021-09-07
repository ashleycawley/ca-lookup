#!/bin/bash
# Author: Ashley Cawley // @ashleycawley
# Checks for dependencies and offers to install them if not present

# WHOIS Check
which whois &>/dev/null
WHOIS_STATUS=$(echo $?)

if [ "$WHOIS_STATUS" != "0" ]
then
    echo "The package: whois is not installed, would you like me to install it with:"
    echo ""
    echo "sudo apt install whois -y"
    echo ""
    echo "Press the enter key to proceed with installation or if you wish to cancel press CTRL + C"
    read -p ""
    sudo apt install whois -y
    WHOIS_INSTALL_STATUS=$(echo $?)
        if [ "$WHOIS_INSTALL_STATUS" != "0" ]
        then
            echo "The installation did not complete successfully."
            echo "Please install whois using the relevant package manager for your OS."
            exit 1
        fi
fi

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
A_RECORD=$(dig $DOMAIN A +short)
LOOKING_FOR_NS=$(whois -H $DOMAIN)
COM_NS_CHECK=$(echo "$LOOKING_FOR_NS" | grep "^Name Server:" | sed 's/Name Server: //g')
CO_UK_NS_CHECK=$(echo "$LOOKING_FOR_NS" | grep -A 2 "Name servers:" | sed '/Name servers:/d' | sed 's/^ *//g' | awk '{print $1}')

# Colours
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# CloudFlare Check
echo "$COM_NS_CHECK" | grep -i "cloudflare" &>/dev/null && CLOUDFLARE_CHECK="1"
echo "$CO_UK_NS_CHECK" | grep -i "cloudflare" &>/dev/null && CLOUDFLARE_CHECK="1"
if [ "$CLOUDFLARE_CHECK" == "1" ]
then
    IP_AT_CLOUDABOVE=$(dig A $DOMAIN +short @ns1.cloudabove.com)
    RDNS_HOSTNAME=$(dig -x $IP_AT_CLOUDABOVE +short | grep -v "^;")
    CLOUDFLARE_NOTICE="\n${YELLOW}Note: This domain is behind CloudFlares Nameservers${NC}"
else
    RDNS_HOSTNAME=$(dig -x $A_RECORD +short)
fi

# Script
echo -e "$DOMAIN is on server:${GREEN} $RDNS_HOSTNAME ${NC}$CLOUDFLARE_NOTICE"

exit 0