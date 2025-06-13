#Script for deleting older than week nmon log inside /

#!/bin/bash
nmoncount=$(find / -iname '*.nmon' -type f | wc -l)
if [ $nmoncount -ne 0 ]
then
echo $nmoncount "nmon files exist checking for cleanup....."
echo "top 3 oldest nmon file before cleaning"
find / -iname '*.nmon' -type f  | xargs ls -ltr | head -3
echo "retaining last 1 week nmon log"
find / -iname '*.nmon' -type f -mtime +7 -exec rm -rf {} \;
echo "top 3 oldest nmon file after cleaning"
find / -iname '*.nmon' -type f | xargs ls -ltr | head -3
afternmoncount=$(find / -iname '*.nmon' -type f | wc -l)
echo "Numbers of nmon files before cleanup : " $nmoncount
echo "Numbers of nmon files after cleanup : " $afternmoncount
else
echo "no nmon files..skipping server."
fi