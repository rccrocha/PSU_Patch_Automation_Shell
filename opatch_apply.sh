#!/bin/sh
# ====================================
# Patch installation
# ====================================

LOGFILE=/home/oracle/scripts/shell/Patches/LOGS/patch_${patch_zip}.txt

PatchApply(){

echo "Checking sub-patches:

Sub-Patch Number:
$(ls -l $Patch_Location/$year_psu/$db_ver/$patch_zip/ | grep dr | awk '{print $9}')

" > $LOGFILE

echo "Checking sub-patches:

Sub-Patch Number:
$(ls -l $Patch_Location/$year_psu/$db_ver/$patch_zip/ | grep dr | awk '{print $9}')
"

echo "
Do you see the sub-patches? y or n
"

read question

if [[ $question != 'y' ]]; then
        echo "You cannot continue.Press ctrl-c to exit"
        read command
        exit
fi

echo "Do you need to rollback any patch? y or n
"
read question

if [[ $question == 'y' ]]; then
        echo "Enter patch number(s) [if more than one, separate it with blank spaces]: "
        read number
        for n in $number
        do
                opatch rollback -id $n -silent >> $LOGFILE
        done
fi

patches=$(ls -l $Patch_Location/$year_psu/$db_ver/$patch_zip/ | grep dr | awk '{print $9}')

for patch in $patches
do
        cd $Patch_Location/$year_psu/$db_ver/$patch_zip/$patch
	echo "____________________________________________________
|
| Starting the installation of the patch $patch
|____________________________________________________
"
        opatch apply -silent | tee $LOGFILE
done

echo "Installation of patches done succesfully
"

if [[ $question == 'y' ]]; then
        fixpatches=$(ls -l $Patch_Location/$year_psu/$db_ver/fix/ | grep dr | awk '{print $9}')
    	for fix in $fixpatches
	do
        	cd ls -l $Patch_Location/$year_psu/$db_ver/fix/$fix
        	opatch apply -silent
	done
fi

echo "All done!" >> $LOGFILE

}

if [[ $db_ver == '12.1' ]];then
        echo "Enter a database version 12.1: "
        read db_121
        . /home/oracle/scripts/shell/oraenv.sh $db_121
        PatchApply

elif [[ $db_ver == '12.2' ]];then
        echo "Enter a database version 12.2: "
        read db_122
        . /home/oracle/scripts/shell/oraenv.sh $db_122
        PatchApply
	
elif [[ $db_ver == '19' ]];then
        echo "Enter a database version 19: "
        read db_19
        . /home/oracle/scripts/shell/oraenv.sh $db_19
        PatchApply
fi

cd /home/oracle/scripts/shell/Patches/
