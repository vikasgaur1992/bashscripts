#created on 8/4/22

#!/bin/bash

counter=1

#make sure you have put all the db names inside sblist.txt file

for i in `cat dblist.txt`
do
aws lakeformation grant-permissions --resource '{"Table": {"DatabaseName": "'$i'","TableWildcard": {}}}' --principal DataLakePrincipalIdentifier='arn:aws:iam::accountid:role/iamrole' --permissions SELECT
RESULT=$?
if [ $RESULT -eq 0 ] 
then
echo " Successfully added "  $counter-$i
else
  echo "Database not found ---> " $counter-$i
fi
counter=$((counter+1)) 
done
#will provide list of not found db
echo "Below databases were not present"
grep "^[^#*/;]" dberror | awk '{print $11}'



