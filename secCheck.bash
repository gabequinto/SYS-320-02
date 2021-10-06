#!/bin/bash

# Script to perform local security checks

function checks() {

if [[ $2 != $3 ]]
then

        echo -e "\e[1;31mThe $1 policy is not compliant. The current policy should be: $2, the current value is: $3.\e[0m"

        echo -e "Remediation:\n $4"
else

        echo -e "\e[1;32mThe $1 policy is compliant. Current Value $3\e[0m"

fi
}
# Check the password max days policy
pmax=$(egrep -i '^PASS_MAX_DAYS' /etc/login.defs | awk ' { print $2} ' )
checks "Password Max Days" "365" "${pmax}" "Run:\n chage -M 365 <user>"

# Check the pass min days between changes
pmin=$(egrep -i '^PASS_MIN_DAYS' /etc/login.defs | awk ' {print $2 } ')
checks "Password Min Days" "14" "${pmin}" "Run:\n chage -m <user>"

# Check the pass warn age
pwarn=$(egrep -i '^PASS_WARN_AGE' /etc/login.defs | awk ' { print $2 } ')
checks "Password warn age" "7" "${pwarn}"

# Check the ssh UsePam configuration
chkSSHPAM=$(egrep -i "^UsePAM" /etc/ssh/sshd_config | awk ' { print $2 } ' )
checks "SSH UsePAM" "yes" "${chkSSHPAM}"

# Check to ensure IP forwarding is disabled
ipfwrd=$(egrep -i "net\.ipv4\.ip_forward" /etc/sysctl.conf  | cut -d '=' -f 2  )
checks "IP forwarding" "0" "${ipfwrd}" "Edit /etc/sysctl.conf and set:\nnet.ipv4.ip_forward =1\nto\nnet.ipv4.ip_forward=0.\nThen run:\n sysctl -w"

# Check to ensure all ICMP redirects are not accepted
icmpr=$(grep "net\.ipv4\.conf\.all\.accept_redirects" /etc/sysctl.conf | awk ' { print $3 } ' )
checks "ICMP Redirects" "0" "${icmpr}"

# Check to ensure permissions on /etc/cron/tab are configured
cront=$(systemctl is-enabled cron | awk ' { print $1 } ' )
checks "Cron Tab" "enabled" "${cront}" "Run:\nchown root:root /etc/crontab\nThen run:\nchmod og-rwx /etc/crontab"

# Check to ensure permissions on /etc/cron.hourly are configured
cronh=$(stat /etc/cron.hourly | awk 'NR ==4 { print $4,$5,$6,$8,$9,$10 } ' )
checks "Cron Hourly" "( 0/ root) ( 0/ root)" "${cronh}" "Run:\nchown root:root /etc/cron.hourly\nThen run:\nchmod og-rwx /etc/cron.hourly"

# Check to ensure /etc/cron.daily permissions are configured
crond=$(stat /etc/cron.daily | awk 'NR ==4 { print $4,$5,$6,$8,$9,$10 } ' )
checks "Cron Daily" "( 0/ root) ( 0/ root)" "${crond}" "Run:\nchown root:root /etc/cron.daily\nThen run:\nchmod og-rwx /etc/cron.daily"

# Check to ensure /etc/cron.weekly permissions are configured
cronw=$(stat /etc/cron.weekly | awk 'NR ==4 { print $4,$5,$6,$8,$9,$10 } ' )
checks "Cron Weekly" "( 0/ root) ( 0/ root)" "${cronw}" "Run:\nchown root:root /etc/cron.weekly\nThen run:\nchmod og-rwx /etc/cron.weekly"

# Check to ensure /etc/cron.monthly permissions are configured
cronm=$(stat /etc/cron.monthly | awk 'NR ==4 { print $4,$5,$6,$8,$9,$10 } ' )
checks "Cron Monthly" "( 0/ root) ( 0/ root)" "${cronm}" "Run:\nchown root:root /etc/cron.monthly\nThen run:\nchmod og-rwx /etc/cron.monthly"

# Check to ensure /etc/passwd permissions are configured
pass=$(stat /etc/passwd | awk -F'[(/]' 'NR ==4 { print $2 } ' )
passw=$(stat /etc/passwd | awk 'NR ==4 { print $4,$5,$6,$8,$9,$10 } ' )
checks "Passwords" "0644 ( 0/ root) ( 0/ root)" "${pass} ${passw}" "Run:\nchown root:root /etc/passwd\n Then run:\n chmod 644 /etc/passwd"

#Check to ensure /etc/shadow permissions are configured
shadow=$(stat /etc/shadow | awk -F'[(/]' 'NR ==4 { print $2 } ' )
shadow1=$(stat /etc/shadow | awk 'NR ==4 { print $4,$5,$6,$8,$9,$10 } ' )
checks "Shadow" "0640 ( 0/ root) ( 42/ shadow)" "${shadow} ${shadow1}" "Run:\nchown root:shadow /etc/shadow\nThen run:\n chmod o-rwx,g-wx /etc/shadow"

# Check to ensure /etc/group permissions are configured
group=$(stat /etc/group | awk -F'[(/]' 'NR ==4 { print $2 } ' )
group1=$(stat /etc/group | awk 'NR ==4 { print $4,$5,$6,$8,$9,$10 } ' )
checks "Group" "0644 ( 0/ root) ( 0/ root)" "${group} ${group1}" "Run:\nchown root:root /etc/group\nThen run:\nchmod 644 /etc/group"

# Check to ensure /etc/gshadow permissions are configured
gshadow=$(stat /etc/gshadow | awk -F'[(/]' 'NR ==4 { print $2 } ' )
gshadow1=$(stat /etc/gshadow | awk 'NR ==4 { print $4,$5,$6,$8,$9,$10 } ' )
checks "Gshadow" "0640 ( 0/ root) ( 42/ shadow)" "${gshadow} ${gshadow1}" "Run:\nchown root:shadow /etc/gshadow\nThen run:\nchmod o-rwx,g-rw /etc/gshadow"

# Check to ensure /etc/passwd- permissions are configured
passwd=$(stat /etc/passwd- | awk -F'[(/]' 'NR ==4 { print $2 } ' )
passwd1=$(stat /etc/passwd- | awk 'NR ==4 { print $4,$5,$6,$8,$9,$10 } ' )
checks "Passwords-" "0644 ( 0/ root) ( 0/ root)" "${passwd} ${passwd1}" "Run:\nchown root:root /etc/passwd-\n Then run:\nchmod u-x,go-wx /etc/passwd-"

# Check to ensure /etc/shadow- permissions are configured
shadow2=$(stat /etc/shadow- | awk -F'[(/]' 'NR ==4 { print $2 } ' )
shadow3=$(stat /etc/shadow- | awk 'NR ==4 { print $4,$5,$6,$8,$9,$10 } ' )
checks "shadow-" "0640 ( 0/ root) ( 42/ shadow)" "${shadow2} ${shadow3}" "Run:\nchown root:shadow /etc/shadow-\nThen run:\n chmod o-rwx,g-rw /etc/shadow-"

# Check to ensure /etc/group- permissions are configured
group2=$(stat /etc/group- | awk -F'[(/]' 'NR ==4 { print $2 } ' )
group3=$(stat /etc/group- | awk 'NR ==4 { print $4,$5,$6,$8,$9,$10 } ' )
checks "group-" "0644 ( 0/ root) ( 0/ root)" "${group2} ${group3}" "Run:\nchown root:root /etc/group-\nThen run:\n chmod u-x,go-wx /etc/group-"

# Check to ensure /etc/gshadow- permissions are configured
gshadow2=$(stat /etc/gshadow- | awk -F'[(/]' 'NR ==4 { print $2 } ' )
gshadow3=$(stat /etc/gshadow- | awk 'NR ==4 { print $4,$5,$6,$8,$9,$10 } ' )
checks "gshadow-" "0640 ( 0/ root) ( 42/ shadow)" "${gshadow2} ${gshadow3}" "Run:\nchown root:shadow /etc/gshadow-\n Then run:\nchmod o-rwx,g-rw /etc/gshadow-"

# Check to ensure there are no lecacy + entries in /etc/passwd
lentry=$(grep '^+:' /etc/passwd)
checks "Legacy + entries for /etc/passwd" "" "${lentry}" "Remove any legacy '+' entries from /etc/passwd if they exist"

# Check to ensure there are no lecacy + entries in /etc/shadow
lentryshadow=$(grep '^+:' /etc/shadow)
checks " Legacy + entries for /etc/shadow" "" "${lentryshadow}" "Remove any legacy '+' entries from /etc/shadow if they exist"

# Check to ensure there are no lecacy + entries in /etc/group
lentrygroup=$(grep '^+:' /etc/group)
checks "Legacy + entries for /etc/group" "" "${lentrtgroup}" "Remove any legacy '+' entries from /etc/group if they exist"

# Ensure root is the only UID 0 account
uid=$(cat /etc/passwd | awk -F: '($3 == 0) { print $1 } ' )
checks "Root UID" "root" "${uid}" "Remove any users other than root with UID 0 or assign them a new UID if appropriate."

# Check permissions on users home directory
echo ""
for eachDir in $(ls -l /home | egrep '^d' | awk ' { print $3 } ' )
do

        chDir=$( ls -ld /home/${eachDir} | awk ' { print $1 } ')
        checks "Home directory ${eachDir}" "drwx------" "${chDir}" "Run:\n chmod 700 ${eachDir}"
done



