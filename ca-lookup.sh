#!/bin/bash

# Author: Ashley Cawley // @ashleycawley

# Variables & Functions
VERSION="1.0.3"
DOMAIN=$(echo $1 | sed 's,http://,,g' | sed 's,https://,,g' | sed 's,/,,g' | sed 's,www.,,g' )
EXPIRY_DATE=$(whois $DOMAIN | grep -i "expiry date:" | sed -e 's/   Registry Expiry Date: //g' | sed -e 's/        Expiry date:  //g')
A_RECORD=$(dig $DOMAIN A +short)
RDNS_HOSTNAME=$(dig -x $A_RECORD +short)
WWW_RECORD=$(dig www.$DOMAIN A +short | grep -v $DOMAIN)
MAIL_RECORD=$(dig mail.$DOMAIN A +short | grep -v $DOMAIN)
MX_RECORD=$(dig $DOMAIN MX +short)
TXT_RECORD=$(dig $DOMAIN TXT +short)

# Colours
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "
ca-lookup Version: $VERSION | Source code available at: http://swb.me/calookup

 -------------------------------------------------------------------------
| Domain  :   $DOMAIN expires on $EXPIRY_DATE
 -------------------------------------------------------------------------
| Server  :   $RDNS_HOSTNAME
 -------------------------------------------------------------------------
| A       :   $DOMAIN - $A_RECORD
 -------------------------------------------------------------------------
| WWW.    :   $WWW_RECORD
 -------------------------------------------------------------------------
| MAIL.   :   $MAIL_RECORD
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

exit 0