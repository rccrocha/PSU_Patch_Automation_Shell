#!/bin/sh
# =================================================
# Check for invalid objects before applying patches
# =================================================

dbs=$(ps -ef | grep pmon | awk '{print $8}' | cut -b 10- | sed '/^[[:space:]]*$/d' | sort -n)

for db in $dbs
do
        . /home/oracle/scripts/shell/oraenv.sh $db
        echo "
 ______________________________________________________________
|                                                          
| Check for invalid objects after patch application in $db 
|______________________________________________________________

"
        if [[ -e /home/oracle/scripts/shell/Patches/LOGS/${db} ]]; then
		echo ""
	else
                mkdir /home/oracle/scripts/shell/Patches/LOGS/${db}
        fi
        echo "-------------------------
Check for invalid objects
-------------------------
" > /home/oracle/scripts/shell/Patches/LOGS/${db}/query_invalid_object_before_$db.txt
        sqlplus -s / as sysdba << EOSQL >> /home/oracle/scripts/shell/Patches/LOGS/${db}/query_invalid_object_before_$db.txt
select instance_name from v\$instance;
set linesize 512
column object_name format a30;
column owner format a20;
@?/rdbms/admin/utlrp
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
" > /home/oracle/scripts/shell/Patches/LOGS/${db}/final_check_before_$db.txt
        sqlplus -s / as sysdba << EOSQL >> /home/oracle/scripts/shell/Patches/LOGS/${db}/final_check_before_$db.txt
select instance_name from v\$instance;
set linesize 512
col COMP_NAME format a50
select comp_name, version, status from dba_registry;
col OWNER format a30
select owner, status, count(*) from all_objects where object_type like '%JAVA%' group by owner, status;
set linesize 512
col owner format a30;
col object_name format a30;
col object_type format a30;
col status format a20;
SELECT owner, object_name, object_type, status
FROM dba_objects
WHERE object_name LIKE 'UMS_JAVA%'
OR object_name LIKE '%INITJVMAUX%'
ORDER BY owner, object_name, object_type;
set linesize 512
select PATCH_ID, ACTION, STATUS, VERSION, DESCRIPTION from dba_registry_sqlpatch;
exit
EOSQL
        echo "
 _________________________________________________________
|                                                         |
| Confirmation in SQLPLUS done                            |
|_________________________________________________________|
 _________________________________________________________
|                                                         |
| Last confirmation: opatch lsinventory filtered          |
|_________________________________________________________|

"
        echo "---------------------------------
opatch lsinventory filtered check
---------------------------------
" > /home/oracle/scripts/shell/Patches/LOGS/${db}/opatch_lsinventory_before_$db.txt
        $ORACLE_HOME/OPatch/opatch lsinventory | grep -E "(^Patch.*applied)|(^Sub-patch)" >> /home/oracle/scripts/shell/Patches/LOGS/${db}/opatch_lsinventory_before_$db.txt

done

cd /home/oracle/scripts/shell/Patches/
