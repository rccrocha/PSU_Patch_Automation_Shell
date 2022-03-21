#!/bin/sh
# =================================
# Patch installation semi-automated
#
# Author: Raphael Costa
#
# Creation date: 03.2022
# =================================

LOGFILE=/home/oracle/scripts/shell/Patches/LOGS/Full_log.txt

echo "
Choose database version:

12.1
12.2
19
"

read dbver
db_ver=$dbver

echo "Choose the quarter periord of the patch:

Jan_22
Apr_22
Jul_22
Oct_22
"

read yearPSU
year_psu=$yearPSU

read -p "Enter patch zip name.................: " patchzipname
patch_zip=$(echo $patchzipname | cut -b 2-9)

read -p "Enter opatch utility zip name........: " opatchutil
read -p "Enter required opatch utility version: " reqversion

export db_ver
export year_psu
export patchzipname
export patch_zip
export opatchutil
export reqversion

. opatch_util_upgrade.sh
. conflict_check.sh
. space_check.sh
. check_invalid_objs_before.sh
. listener_db_shut.sh
. opatch_apply.sh
. datapatch_apply.sh

