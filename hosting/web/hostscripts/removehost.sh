#!/bin/bash

# Define the filename
filename='/var/named/zones/nightingale.is'
filename2='/var/named/zones/nightingale-tempforremoveline.is'

# Check the new text is empty or not
if [ "$1" != "" ]; then
        # updating serial number
        perl -i.bak -pe 'BEGIN {chomp ($now=qx/date +%Y%m%d/)};
        /(\d{8})(\d{2})(\s+;\s+serial)/i and do {
        $serial = ($1 eq $now ? $2+1 : 0);
        s/\d{8}(\d{2})/sprintf "%8d%02d",$now,$serial/e;
        }' $filename

        # Removing a pattern matching line into filename2, then write back into filename
        grep -v "$1" $filename > $filename2; mv $filename2 $filename

        rndc reload
        
	# dns has been removed, now remove from conf.d host file
        grep -v "$1" './conf.d/hosts' > './conf.d/hostscopyfordeletion'; mv './conf.d/hostscopyfordeletion' './conf.d/hosts'
        # execute update-env
        "./bin/update-env"
        # Currently skip restart to avoid unnecessary downtime
	# restart container
        # "./hostscripts/zero-downtime-script.sh"
fi
