#!/bin/sh
# ==============================
# OPatch space requirement check
# ==============================

if [[ -f /home/oracle/scripts/shell/Patches/space_check_opatch.txt ]];then
        rm /home/oracle/scripts/shell/Patches/space_check_opatch.txt
fi

patches=$(ls -l $Patch_Location/$yearPSU/$db_ver/$patch_zip/ | grep dr | awk '{print $9}')

for patch in $patches
do
        cd $Patch_Location/$yearPSU/$db_ver/$patch_zip/$patch
        pwd >> /home/oracle/scripts/shell/Patches/space_check_opatch.txt
done

$ORACLE_HOME/OPatch/opatch prereq CheckSystemSpace -phBaseFile /home/oracle/scripts/shell/Patches/space_check_opatch.txt > /home/oracle/scripts/shell/Patches/LOGS/space_check.txt

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

cd /home/oracle/scripts/shell/Patches/
