#!/bin/bash


#will add the main directory as observed in the compliance report

find /home/ -type f -perm -o+w >> invalidperm.txt
find /tmp/ -type f -perm -o+w >> invalidperm.txt
#find /var/ -type f -perm -o+w >> invalidperm.txt

#keeping log of file for which we have changed the permission , for future analysyis purpose

echo "<---------Script execution date and time : " $(date)"------->" >> /home/ec2-user/removallog_cid10505.txt

found=$(cat invalidperm.txt | wc -l)
if [ $found -ne 0 ]
then
	for i in `cat invalidperm.txt`
	do
	#remove write permission on other


	ls -ltr $i
	chmod o-w $i
	succeed=$?

	if [ $succeed -eq 0 ];
	then
	echo "write permission on other was removed"
	ls -ltr $i 
	#removallog.txt file will only store the file details for which other permission was removed successfully 
	ls -ltr $i >> /home/ec2-user/removallog_cid10505.txt
	fi
	done
else
	echo " No file with invalid permission detected "
fi
rm -rf invalidperm.txt