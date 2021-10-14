#!/bin/bash

# Read in file

# Arguments using the position, they start at $1
APACHE_LOG="$1"

# check to see if the file exists
if [[ ! -f ${APACHE_LOG} ]]
then
        echo "Please specify the path to a log file."
        exit 1
fi

# looking for web scanners
sed -e "s/\[//g" -e "s/\"//g" ${APACHE_LOG} | \
egrep -i "test|shell|echo|passwd|select|phpmyadmin|setup|admin|w00t" | \
awk ' BEGIN { format = "%-15 %-20 %-7s %-6s %-10s %s\n"
                printf format, "IP", "Date", "Method", "Status", "Size", "URI"
                printf format, "--", "----", "------", "------", "----", "---"}

{ printf format, $1, $4, $6, $9, $10, $7 }'

awk ' { print $1 } ' ${APACHE_LOG} | sort -u | tee -a apacheIP.txt

for badIP in $(cat apacheIP.txt)
do
        echo "netsh advfirewall firewall add rule name="BLOCK IP ADDRESS - ${badIP}" dir=in action=block remoteip=${badIP}" | tee -a windowsbadIP.txt
done

for badIP in $(cat apacheIP.txt)
do
        echo "iptables -A INPUT -s ${badIP} -j DROP" | tee -a badiptables.txt
done



