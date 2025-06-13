#will look for deleted user home folder and zip and delete the directory.

#!/bin/sh

before=$(df -Th / |tail -n +2 | awk {'print $6'})
cd /home


#will list all user home directory

ls -d */ > userlist.txt
for i in `cat userlist.txt`
do
#remove / from end
echo ${i%?}
id ${i%?}
#will check if user exist or not
if  [ $? -ne 0 ]
then
#temporarily storing to be deleted user nid in unknownid.txt file
echo ${i%?} >> unknownnid.txt
fi
done
echo "below nid were not present can be deleted :"
cat unknownnid.txt

#Compressing and deleteing NID directory

for i in `cat unknownnid.txt`
do
du -sh $i
echo "zipping and deleting /home/"$i
tar -cvzf "$i$( date +"%d-%m-%Y").tar.gz" $i
rm -rf $i
done


rm -rf unknownnid.txt
rm -rf userlist.txt
after=$(df -Th / |tail -n +2 | awk {'print $6'})

echo "Space before cleenup : " $before
echo "Space after cleenup : " $after

