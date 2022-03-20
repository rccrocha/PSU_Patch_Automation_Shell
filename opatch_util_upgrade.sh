#!/bin/sh
# ====================================
# Upgrading OPatch Utility
# ====================================

if [[ $db_ver == '12.1' ]];then
        echo "Enter a database version 12.1: "
        read db_121
        . /home/oracle/scripts/shell/oraenv.sh $db_121

elif [[ $db_ver == '12.2' ]];then
        echo "Enter a database version 12.2: "
        read db_122
        . /home/oracle/scripts/shell/oraenv.sh $db_122
        
elif [[ $db_ver == '19' ]];then
        echo "Enter a database version 19: "
        read db_19
        . /home/oracle/scripts/shell/oraenv.sh $db_19
fi

echo "==========================================
Pre-checks for OPatch Utilities
------------------------------------------
Version required: $reqversion

Updating OPatch Utility of the OH version

$db_ver

Patch Name:

$opatchutil
==========================================
"

cd $ORACLE_HOME

# Getting opatch version
OPatch_Version=$(opatch version | grep -i version | awk '{print $3}')

echo "Current Version : $OPatch_Version
Required Version: $reqversion
"

echo "Are the versions correct? y or n
"
read question

if [[ $question == "y" ]]; then
    echo ""
else
    echo "Updating OPatch Utility to version ${reqversion}

Backing up the current OPatch folder
"
    cp -r OPatch OPatch_$OPatch_Version
    unzip $Patch_Location/zip_files/$opatchutil -d $ORACLE_HOME/
fi

# Checking the new installation
New_Op_Version=$(opatch version | grep -i version | awk '{print $3}')

echo "Current Version : $New_Op_Version
Required Version: $reqversion
"

cd /home/oracle/scripts/shell/Patches/
