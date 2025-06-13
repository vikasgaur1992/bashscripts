#script location : /home/ec2-user/s3copy/s3copy.sh
#Script for copying file from prod to qa


#!/bin/bash

#Prod s3 to prod-qa shared
prod_to_shareds3()
{	
	
	filecounter=1
	TotalFile=$(cat prods3list | wc -l)
	echo "removing files from shared bucket ......"
	remove_from_shareds3 $TotalFile
	echo "Total file to be copied : " $TotalFile

	for i in `cat prods3list`
	do
		aws s3 sync $i s3://cfg-edo-shared-prod-qa-s3-pci/file$filecounter
		filecounter=$((filecounter+1))
	done
}

#prod-qa shared to qa s3

shareds3_to_qa()
{
	filecounter=1
	TotalFile=$(cat qas3list | wc -l)
	echo "Total file to be copied : " $TotalFile

	for i in `cat qas3list`
	do
		aws s3 sync  s3://cfg-edo-shared-prod-qa-s3-pci/file$filecounter $i
		filecounter=$((filecounter+1))
	done
	#remove_from_shareds3 $TotalFile
}

remove_from_shareds3()
{

for i in `seq 1 $1`
do
    aws s3 rm s3://cfg-edo-shared-prod-qa-s3-pci/file$i "--recursive"
done

}

echo "Please select the action : "
echo -e  "1. Prod s3 to Shared s3    \n2. Shared s3 to Qa s3 "
read action

if [ $action -eq 1 ]
then
	prod_to_shareds3
fi

if [ $action -eq 2 ]
then
	shareds3_to_qa
fi




