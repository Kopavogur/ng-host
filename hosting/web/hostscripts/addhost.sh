#!/bin/bash

# Define the filename
filename='/var/named/zones/nightingale.is'

# Check the new text is empty or not
if [ "$1" != "" ]; then

        # updating serial number
        perl -i.bak -pe 'BEGIN {chomp ($now=qx/date +%Y%m%d/)};
        /(\d{8})(\d{2})(\s+;\s+serial)/i and do {
        $serial = ($1 eq $now ? $2+1 : 0);
        s/\d{8}(\d{2})/sprintf "%8d%02d",$now,$serial/e;
        }' $filename

        # Append the text by using '>>' symbol
        echo "$1.               IN      CNAME   @" >> $filename

        rndc reload

        # dns has been added, now append to conf.d host file
        echo "$1" >> './conf.d/hosts'
        # execute update-env
        "./bin/update-env"

        # restart container
	"./hostscripts/zero-downtime-script.sh"
fi
