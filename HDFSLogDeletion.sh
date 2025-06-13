#HDFS log cleanup
#script will check for >1gb size hdfs logs ,confirm final state and delete it if job was successsful.
#It will also maintain the list of deleted applicationID along with application name and size in deletedlogs.txt file.

#!/bin/bash

#variable declarion section
counter=1
scounter=1
#section end

echo "<---------Script execution date and time : " $(date)"------->" >>/home/hadoop/awsinfra/deletedlogs.txt

#greping in logs greater than 1 gb
hdfs dfs -du -h /var/log/hadoop-yarn/apps/hadoop/logs/ | grep G | sort -h | awk '{print $3}' > dl.txt

#checking each logs one by one and performing deletion operation after verify job status.
for i in `cat dl.txt`
do
appid=$(echo $i | cut -d'/' -f8-)
#echo $appid
echo "log no : "$counter
echo "ApplicationId :" $appid
hdfs dfs -du -s -h $i
echo "checking final status...."
yarn application -status $appid | grep 'Final-State : SUCCEEDED'
succeed=$?
if [ $succeed -eq 0 ];
then
    echo "safe to delete"
		"Sr no : "$scounter
		yarn application -status $appid | grep 'Application-Name' >> /home/hadoop/awsinfra/deletedlogs.txt
        hdfs dfs -du -s -h $i >> /home/hadoop/awsinfra/deletedlogs.txt
        
		hdfs dfs -rm -R  $i
		echo "Successfully deleted log"
        scounter=$((scounter + 1))
else
    echo "Job failed/still running skiping deletion"
fi
counter=$((counter + 1))
echo "-----------------------------------------------------"
done
echo "Successfully deleted " $((scounter-1)) "logs size greater than 1GB (cat /home/hadoop/awsinfra/deletedlogs.txt for details)"
rm -rf dl.txt

