#!/bin/bash
##################################################################################################
# Decscription : lakeformation script to get the list of Roles, Glue catalogs and its permissions
# sample command : lakeformation_report.sh
# Version History:  Who             When        version
#                   Francis Xavier  09/08/2021  0.1
##################################################################################################

printf "\n"
printf "AWS Roles Report generation - Started : `date +%Y%m%dT%H%M%S` \n\n"

HOME=/home/d113030/Automation
TempDir=/home/d113030/Automation/TempFiles
LogDir=/home/d113030/Automation/LogFiles
TgtDir=/home/d113030/Automation/TgtFiles


### Clearing old files
cat /dev/null > $TempDir/final_permission_list.json
cat /dev/null > $TgtDir/lakeformation_report.csv


#### Change into Temp Directory
cd $TempDir

echo "ResourceType,DatabaseName,TableName,PermissionsType,Permissions,IAMRole" > $TgtDir/lakeformation_report.csv

### initializing the variable for iteration purpose
var=1

while true
do

    if [ $var -eq 1 ]
    then
        printf "First iteration \n"
        /usr/local/bin/aws lakeformation list-permissions --region us-east-1 --max-results 9999999999 > lake_permission_${var}.json

        next_token=`cat lake_permission_${var}.json | jq -r '.NextToken' `
        if [ -z $next_token ]
        then
            printf "Reached end of iteration: ${var} \n"
            printf "Exiting from loop \n\n"
            break
        else
            printf "Found Next Token --> proceeding with next iteration. \n\n"
            var=`expr ${var} + 1`
        fi

    else
        printf "Iteration : ${var} \n"

        /usr/local/bin/aws lakeformation list-permissions --region us-east-1 --max-results 9999999999 --next-token ${next_token} > lake_permission_${var}.json

        ### Resetting token value based on current iteration
        next_token=`cat lake_permission_${var}.json | jq -r '.NextToken' `
        if [ -z $next_token ]
        then
            printf "Reached end of iteration: ${var} \n"
            printf "Exiting from loop \n\n"
            break
        else
            printf "Found Next Token --> proceeding with next iteration. \n\n"
            var=`expr ${var} + 1`

        fi
    fi

done

printf "Exits from loop..Iteration ends .. \n"


### Merging all temp files to create consolidated JSON files
cat lake_permission_*.json >> final_permission_list.json
ret_cde=$?

if [ $ret_cde -eq 0 ]
then
    printf "Consolidated JSON output file created. \n"
    rm -f lake_permission_*.json
    rt_cd=$?

    if [ $rt_cd -ne 0 ]
    then
        printf "Clearing temp Files failed. Pls Check log \n"
        exit 1
    fi
else
    printf "JSON Output file consolidation failed. Pls check log \n"
    exit 1
fi


### Extracting required information from consolidated file

cat final_permission_list.json | jq -r '.PrincipalResourcePermissions[] | "DB,\(.Resource.Database.Name),,Permissions,\(.Permissions[]),\(.Principal.DataLakePrincipalIdentifier)"' > temp_database.list
cat final_permission_list.json | jq -r '.PrincipalResourcePermissions[] | "DB,\(.Resource.Database.Name),,PermissionswithGrant,\(.PermissionsWithGrantOption[]),\(.Principal.DataLakePrincipalIdentifier)"' > temp_database_pg.list
cat final_permission_list.json | jq -r '.PrincipalResourcePermissions[] | "TBL,\(.Resource.Table.DatabaseName),\(.Resource.Table.Name),Permissions,\(.Permissions[]),\(.Principal.DataLakePrincipalIdentifier)"' > temp_table.list
cat final_permission_list.json | jq -r '.PrincipalResourcePermissions[] | "TBL,\(.Resource.Table.DatabaseName),\(.Resource.Table.Name),PermissionswithGrant,\(.PermissionsWithGrantOption[]),\(.Principal.DataLakePrincipalIdentifier)"' > temp_table_pg.list
cat final_permission_list.json | jq -r '.PrincipalResourcePermissions[] | "COL,\(.Resource.TableWithColumns.DatabaseName),\(.Resource.TableWithColumns.Name),Permissions,\(.Permissions[]),\(.Principal.DataLakePrincipalIdentifier)"' > temp_column.list
cat final_permission_list.json | jq -r '.PrincipalResourcePermissions[] | "COL,\(.Resource.TableWithColumns.DatabaseName),\(.Resource.TableWithColumns.Name),PermissionswithGrant,\(.PermissionsWithGrantOption[]),\(.Principal.DataLakePrincipalIdentifier)"' > temp_column_pg.list

### consoliding the extracted files
cat temp_database.list temp_database_pg.list temp_table.list temp_table_pg.list temp_column.list temp_column_pg.list | sort -u >> $TgtDir/lakeformation_report.csv
con_res=$?

if [ $con_res -eq 0 ]
then
    printf "Report File generated successfully - $TgtDir/lakeformation_report.csv \n"
    rm -f temp_*.list
    tmp_res=$?

    if [ $tmp_res -ne 0 ]
    then
        printf "Temp results file cleanup failed. Pls check log \n"
        exit 1
    fi
else
    printf "Report File generation failed while consolidation. Pls check log. \n"
    exit 1
fi

printf "AWS Roles Report generation - ended : `date +%Y%m%dT%H%M%S` \n\n"
exit 0
