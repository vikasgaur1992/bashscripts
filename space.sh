#This script can clean space upto 8-12%
#Date:5/6/22

#!/bin/sh
a=$(df -Th / |tail -n +2 | awk {'print $6'})
echo "Root Space Utilization :  "  $a
if [  ${a%?} -ge 30 ]
then
echo "Need cleanup"
# clean all the cached files from any enabled repository at once
yum clean all
#Retain only the past two days Journal
journalctl --vacuum-time=2d
#Retain only past two files in tmp
find /tmp/ -mmin +1440 -delete
else
echo "Space looks fine "
fi
b=$(df -Th / |tail -n +2 | awk {'print $6'})
echo "Root space Utilization Before cleanup : " $a
echo "Root space Utilization after cleanup : " $b


