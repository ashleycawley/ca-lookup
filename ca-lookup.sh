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
VERSION="1.5.1"
DOMAIN=$(echo $1 | sed 's,http://,,g' | sed 's,https://,,g' | sed 's,/,,g' | sed 's,www.,,g' )
LOOKING_FOR_NS=$(whois -H $DOMAIN)
COM_NS_CHECK=$(echo "$LOOKING_FOR_NS" | grep "^Name Server:" | sed 's/Name Server: //g')
CO_UK_NS_CHECK=$(echo "$LOOKING_FOR_NS" | grep -A 2 "Name servers:" | sed '/Name servers:/d' | sed 's/^ *//g' | awk '{print $1}')
A_RECORD=$(dig $DOMAIN A +short)

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

# Retreiving information to build the report
EXPIRY_DATE=$(whois $DOMAIN | grep -i "expiry date:" | sed -e 's/   Registry Expiry Date: //g' | sed -e 's/        Expiry date:  //g')
WWW_RECORD=$(dig www.$DOMAIN A +short | grep -v $DOMAIN)
MAIL_RECORD=$(dig mail.$DOMAIN A +short | grep -v $DOMAIN)
MX_RECORD=$(dig $DOMAIN MX +short)
TXT_RECORD=$(dig $DOMAIN TXT +short)
TTL_A_RECORD=$(dig +nocmd +noall +answer $DOMAIN | grep ^$DOMAIN | awk '{print $2}')
TTL_MAIL=$(dig +nocmd +noall +answer mail.datingprofileheroes.com | grep ^mail.datingprofileheroes.com | awk '{print $2}')


# Populates $NS with Nameserver Records depending on if its ICANN .com/.org etc. vs NOMINET .co.uk/.uk etc.
if [ -z "$COM_NS_CHECK" ]
then
	NS="$CO_UK_NS_CHECK"
else
	NS="$COM_NS_CHECK"
fi

echo -e "
 -------------------------------------------------------------------------
| Domain  :   $DOMAIN expires on $EXPIRY_DATE
 -------------------------------------------------------------------------$CLOUDFLARE_NOTICE
| Nameservers:
$NS
-------------------------------------------------------------------------
| Server  :   $RDNS_HOSTNAME
 -------------------------------------------------------------------------
| A       :   $DOMAIN - $A_RECORD
| TTL     :   $TTL_A_RECORD
 -------------------------------------------------------------------------
| WWW.    :   $WWW_RECORD
 -------------------------------------------------------------------------
| MAIL.   :   $MAIL_RECORD
| TTL     :   $TTL_MAIL
 -------------------------------------------------------------------------
| MX Record(s)
$MX_RECORD
 -------------------------------------------------------------------------
| TXT Record(s):
$TXT_RECORD
 -------------------------------------------------------------------------
"

echo -e "Connectivity Check: \c"
ping -c 1 "$DOMAIN" &>/dev/null
PING_STATUS=$(echo $?)

if [ "$PING_STATUS" == "0" ]
then
    echo -e ${GREEN}$DOMAIN is responding to ping.${NC} && echo
else
    echo -e ${YELLOW}$DOMAIN is not responding to ping.${NC} && echo
    echo "Do not worry if the server is not responding to ping, some servers may block ping (ICMP) traffic"
    echo "but may still have their web ports (80 or 443) open and accessible."
    echo ""
    exit 1
fi

echo "ca-lookup Version: $VERSION | Source code available at: http://swb.me/calookup
"

exit 0