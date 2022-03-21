#!/bin/sh
# ====================================
# Pre-checks for patching installation
# ====================================

echo "
 ____________________________________________________
|
| Conflict Check
|
| Patch zipname : $patchzipname
| Quarter of PSU: $year_psu
| DB Version    : $db_ver
|____________________________________________________
"

sleep 2

host=$(hostname | cut -b 8-)

LOGFILE=/home/oracle/scripts/shell/Patches/LOGS/conflict_${db_ver}_${year_psu}.txt

ConflictCheck(){

echo "Checking if folder for the quarter period exist:
$Patch_Location/$year_psu/
"
if [[ -d $Patch_Location/$year_psu ]];then
	echo ""
else
        echo "No folder. Creating it..." > ${LOGFILE}
        mkdir -p $Patch_Location/$year_psu
fi

if [[ -d $Patch_Location/$year_psu/$db_ver ]];then
	echo ""
else
        echo "No folder. Creating it..." >> ${LOGFILE}
        mkdir -p $Patch_Location/$year_psu/$db_ver
fi

echo "Checking if patch zip file exists
" >> ${LOGFILE}
if [[ -d $Patch_Location/zip_files ]];then
	echo ""
else
        echo "Patch with zip files is missing. After folder creation, add the zipped patched here!" >> ${LOGFILE}
        mkdir -p $Patch_Location/zip_files
        exit
fi

if [[ -f $Patch_Location/zip_files/$patchzipname ]];then
	echo "File exists. Unzipping it to $Patch_Location/$year_psu/$db_ver/$patch_zip
" >> ${LOGFILE}
        cd $Patch_Location/zip_files
        unzip -oq $patchzipname -d $Patch_Location/$year_psu/$db_ver/ >> ${LOGFILE}
else
        echo "File is not present. Add the patche file in zip format.
" >> ${LOGFILE}
        exit
fi

cd $Patch_Location/$year_psu/$db_ver/$patch_zip

echo "Starting conflict check. Log file location:
$Patch_Location/$year_psu/$db_ver/$patch_zip/${host}_${db_ver}_conflict_check_${patch_zip}.txt
" >> ${LOGFILE}

opatch prereq CheckConflictAgainstOHWithDetail -ph ./ > $Patch_Location/$year_psu/$db_ver/$patch_zip/${host}_${db_ver}_conflict_check_${patch_zip}.txt

failure=$(cat $Patch_Location/$year_psu/$db_ver/$patch_zip/${host}_${db_ver}_conflict_check_${patch_zip}.txt | grep failed | wc | awk '{print $1}')

if [[ $failure == 1 ]]
then
	echo "There is a conflict. You should contact Oracle Support.

cat $failure

Logs for Oracle Support:

$Patch_Location/$year_psu/$db_ver/$patch_zip/${host}_${db_ver}_conflict_check_${patch_zip}.txt
$Patch_Location/$year_psu/$db_ver/$patch_zip/${host}_${db_ver}_opatch_lsinventory.txt

Press ctrl-c to exit
"
	read results
	exit
else
	echo "There is no conflict.
"
fi

echo "Starting lsinventory. Log file location:
$Patch_Location/$year_psu/$db_ver/$patch_zip/${host}_${db_ver}_opatch_lsinventory.txt
" >> ${LOGFILE}

opatch lsinventory > $Patch_Location/$year_psu/$db_ver/$patch_zip/${host}_${db_ver}_opatch_lsinventory.txt

echo "All done!" >> ${LOGFILE}

}

if [[ $db_ver == '12.1' ]];then
        echo "Enter a database version 12.1: "
        read db_121
        . /home/oracle/scripts/shell/oraenv.sh $db_121
	ConflictCheck

elif [[ $db_ver == '12.2' ]];then
        echo "Enter a database version 12.2: "
        read db_122
        . /home/oracle/scripts/shell/oraenv.sh $db_122
        ConflictCheck

elif [[ $db_ver == '19' ]];then
        . /home/oracle/scripts/shell/oraenv.sh blogprod
        ConflictCheck
fi

cd /home/oracle/scripts/shell/Patches/
