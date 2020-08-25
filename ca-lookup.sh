#!/bin/bash

# Variables
DOMAIN="$1"
EXPIRY_DATE=$(whois $DOMAIN | grep -i "expiry date:" | sed -e 's/   Registry Expiry Date: //g' | sed -e 's/        Expiry date:  //g')
A_RECORD=$(dig $DOMAIN A +short)
RDNS_HOSTNAME=$(dig -x $A_RECORD +short)
WWW_RECORD=$(dig www.$DOMAIN A +short | grep -v $DOMAIN)
MX_RECORD=$(dig $DOMAIN MX +short)
# Colours
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "
Probing Domain: $DOMAIN (Expiry: $EXPIRY_DATE)

Server		:	$RDNS_HOSTNAME
A		:	$DOMAIN - $A_RECORD
WWW		:	www.$DOMAIN - $WWW_RECORD
MX		:	$MX_RECORD
"
ping -c 1 "$DOMAIN" &>/dev/null
PING_STATUS=$(echo $?)

if [ "$PING_STATUS" == "0" ]
then
    echo -e ${GREEN}$DOMAIN is responding to ping.${NC} && echo
else
    echo -e ${YELLOW}$DOMAIN is not responding to ping.${NC} && echo
    exit 1
fi

exit 0
