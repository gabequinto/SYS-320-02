#!/bin/bash

# Storyline: Extract IPs from emergingthreats.net and create a firewall ruleset
#filename variable
pFile="emerging-drop.suricata.rules"
# Check if the emerging threats file exists
if [[ -f "${pFile}" ]]
then
        echo " The file ${pFile} exists."
        echo -n "Would you like to download it? [y|N]"
        read to_overwrite

        if [[ "${to_overwrite}" == "N" || "${to_overwrite}" == "" ]]
        then

                exit 0

        elif [[ "${to_overwrite}" == "y" ]]
        then
                echo "Downloading......"
                wget https://rules.emergingthreats.net/blockrules/emerging-drop.suricata.rules -o /tmp/emerging-drop.suricata.rules

                exit 0

fi
fi


# Regex to extract the networks

#wget https://rules.emergingthreats.net/blockrules/emerging-drop.suricata.rules -o /tmp/emerging-drop.suricata.rules
egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0/[0-9]{1,2}' emerging-drop.suricata.rules | sort -u  | tee badIPs.txt

cut -d ',' -f 5 targetedthreats.csv | sort -u | tee badURLs.txt


# Create a firewall ruleset


while getopts 'icuwm' OPTION ; do

        case "$OPTION" in


                i) ip_tables=${OPTION}
                ;;
                c) cisco=${OPTION}
                ;;
                u) url_filter=${OPTION}
                ;;
                w) windows_firewall=${OPTION}
                ;;
                m) mac_os=${OPTION}
                ;;
                *)

                        echo "Invalid value."
                        exit 1
                ;;
        esac
done

# Creating list for IP tables
if [[ ${ip_tables} ]]
then


for eachIP in $(cat badIPs.txt)
do
   echo "iptables -A INPUT -s ${eachIP} -j DROP"  | tee -a badIPS.iptables

done
fi

# Creating list for cisco drop rule
if [[ ${cisco} ]]
then

        for eachIP in $(cat badIPs.txt)
        do

                echo "access-list deny ip any host ${eachIP}" | tee -a badIPs.cisco
done
fi
# Creating list for windows drop rule
if [[ ${windows_firewall} ]]
then

        for eachIP in $(cat badIPs.txt)
        do
                echo "netsh advfirewall add rule name=BLOCK IP ADDRESS-${eachIP} dir=in action=block ${eachIP}" | tee -a badIPs.windows

done
fi


# Creating list for MAC drop rule
if [[ ${mac_os} ]]
then

        for eachIP in $(cat badIPs.txt)
        do
                echo "block in from ${eachIP} to any" | tee -a pf.conf

done
fi


# Creating list for cisco url block list

if [[ ${url_filter} ]]
 then
        echo "class-map match-any BAD_URLS"
        for eachURL in $(cat badURLs.txt)
        do
                echo "match protocol http host ${eachURL}" | tee -a badurls.urls

done
fi

# Adding Example to parse cisco url 
# I didn't see a place where you downloaded the file.

# Parse Cisco
if [[ ${parseCisco} ]]
then
	wget https://raw.githubusercontent.com/botherder/targetedthreats/master/targetedthreats.csv -O /tmp/targetedthreats.csv
	awk '/domain/ {print}' /tmp/targetedthreats.csv | awk -F \" '{print $4}' | sort -u > threats.txt
	echo 'class-map match-any BAD_URLS' | tee ciscothreats.txt
	for eachip in $(cat threats.txt)
	do
		echo "match protocol http host \"${eachip}\"" | tee -a ciscothreats.txt
	done
	rm threats.txt
	echo 'Cisco URL filters file successfully parsed and created at "ciscothreats.txt"'
fi

