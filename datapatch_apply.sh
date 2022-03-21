#!/bin/sh
# ==================================
# Start datapatch in some databases
# ==================================

echo "Enter the database name or a list of databases
"

read db_list

dbs=$db_list

for db in $dbs
do
        . /home/oracle/scripts/shell/oraenv.sh $db
        echo "
 _________________________________________________________
|
| Starting Datapatch registration of $db
|_________________________________________________________
"
        echo "----------------------
Datapatch registration
----------------------
" > /home/oracle/scripts/shell/Patches/LOGS/${db}/datapatch_$db.txt
        cd $ORACLE_HOME/OPatch
        sqlplus -s / as sysdba << EOSQL
shutdown immediate
startup upgrade
exit
EOSQL
        ./datapatch -verbose >> /home/oracle/scripts/shell/Patches/LOGS/${db}/datapatch_$db.txt
        #cat /home/oracle/scripts/shell/Patches/LOGS/${db}/datapatch_$db.txt
	#awk '/SUCCESS/,0' /home/oracle/scripts/shell/Patches/LOGS/${db}/datapatch_$db.txt > /home/oracle/scripts/shell/Patches/LOGS/${db}/SUCCESS_patch.txt
	grep SUCCESS /home/oracle/scripts/shell/Patches/LOGS/${db}/datapatch_$db.txt > /home/oracle/scripts/shell/Patches/LOGS/${db}/SUCCESS_patch.txt

        suc=$(cat /home/oracle/scripts/shell/Patches/LOGS/${db}/SUCCESS_patch.txt | grep SUCCESS | wc | awk '{print $1}')

        if [[ $suc < 1 ]]
        then
            echo "There is an issue with the datapatch registration.

$suc

Log: /home/oracle/scripts/shell/Patches/LOGS/${db}/datapatch_$db.txt

Press ctrl-c to exit
"
        read results
        exit
else
        echo "Datapatch installed!.
"
fi

        #echo "Press enter if all is good or Ctrl-C to stop the procedure"
        #read query
        echo "
 _________________________________________________________
|                                                         |
| Datapatch registration finished                         |
|_________________________________________________________|

 _________________________________________________________
|                                                         |
| Check for invalid objects after patch application       |
|_________________________________________________________|

Shutting down the database and starting it in open mode
"
        echo "-------------------------
Check for invalid objects
-------------------------
" > /home/oracle/scripts/shell/Patches/LOGS/${db}/query_invalid_object_after_$db.txt
        sqlplus -s / as sysdba << EOSQL >> /home/oracle/scripts/shell/Patches/LOGS/${db}/query_invalid_object_after_$db.txt
select instance_name from v\$instance;
shutdown immediate
startup
set linesize 512
column object_name format a30;
column owner format a20;
@?/rdbms/admin/utlrp
select instance_name from v\$instance;
select owner, object_type, object_name, status from dba_objects where status = 'INVALID' order by owner, object_type, object_name;
exit
EOSQL
        echo "
 _________________________________________________________
|                                                         |
| Check for invalid objects done                          |
|_________________________________________________________|
 _________________________________________________________
|                                                         |
| Confirmation of the installed patches with SQLPLUS      |
|_________________________________________________________|

"
        echo "------------------------------------------------
Confirmation of the installed patches in SQLPLUS
------------------------------------------------
" > /home/oracle/scripts/shell/Patches/LOGS/${db}/final_check_$db.txt
        sqlplus -s / as sysdba << EOSQL >> /home/oracle/scripts/shell/Patches/LOGS/${db}/final_check_$db.txt
select instance_name from v\$instance;
set linesize 512
col COMP_NAME format a50
col description for a55
col owner format a30;
col object_name format a30;
col object_type format a30;
col status format a20;

select comp_name, version, status from dba_registry;
select owner, status, count(*) from all_objects where object_type like '%JAVA%' group by owner, status;
select owner, object_name, object_type, status from dba_objects where object_name like 'UMS_JAVA%' OR object_name like '%INITJVMAUX%' order by owner, object_name, object_type;
select patch_id, action, status, version, bundle_series, description from dba_registry_sqlpatch;
select patch_id, action, status, description from dba_registry_sqlpatch;

exit
EOSQL
        echo "
 _________________________________________________________
|                                                         |
| Confirmation in SQLPLUS done                            |
|_________________________________________________________|
 _________________________________________________________
|                                                         |
| Last confirmation: opatch lsinventory fileterd          |
|_________________________________________________________|

"
        echo "---------------------------------
opatch lsinventory filtered check
---------------------------------
" > /home/oracle/scripts/shell/Patches/LOGS/${db}/opatch_lsinventory_$db.txt
        $ORACLE_HOME/OPatch/opatch lsinventory | grep -E "(^Patch.*applied)|(^Sub-patch)" >> /home/oracle/scripts/shell/Patches/LOGS/${db}/opatch_lsinventory_$db.txt

done

