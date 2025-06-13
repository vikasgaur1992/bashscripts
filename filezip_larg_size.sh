#!/bin/bash
#can add file extensions as required.Here .txt and .csv file are safest to delete or zip
#below command will list all the files in all the subdirectory of /home with size
find /home/ -type f \( -iname "*.csv*" -o -iname "*.txt*" \) > path.txt
#find /home/ -type f -name "*.TXT" >path.txt
echo "Zipped below files larger than 100 mb : " >> presentziplist.txt
echo $(date) >> zipfile.txt
#checking size of file one by one

counter=0
for i in `cat path.txt`
do
counter=$((counter+1))
#echo "Checking file no : " $counter
du -sh $i
if [ $? -eq 0 ]
then
# fsize will store the size of current file in kb
fsize=$(du -s $i | awk '{print $1}')
#echo $fsize

#if file size is greater thn 80mb will zip the file(first will confirm on monday)

if [ $fsize -ge 82240 ]
then
echo "zip the file"
du -sh $i
tar -zcvf "$i.tar.gz" $i

#File which are zipped now
du -sh $i >> presentziplist.txt
#will log the list of all zipped file , if something breaks due to zip ,we can check here and unzip
du -sh $i >> zipfile.txt
rm -rf $i
fi
fi
done
echo "--------------------------------------------------------------------------------------"


cat presentziplist.txt
rm -rf presentziplist.txt
rm -rf path.txt
