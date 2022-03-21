#!/bin/sh
# ====================================================
# Stopping database and Listener before applying patch
# ====================================================

lsn_ver=$(ps -ef | grep lsnr | awk '{print $8}' | cut -b 13-14 | sed '/^[[:space:]]*$/d')

echo "Listener is running from the binaries of version $lsn_ver
Do you need to switch it? y or n
"

read question

if [[ $question == 'y' ]]
then
        . /home/oracle/scripts/shell/Patches/listener_switcher.sh
fi

echo "Enter the database or databases to shutdown.
If more than one, separate them with blank spaces
or
if all databases, type all
"

read dbs

if [[ $dbs == 'all' ]]
then
        . /home/oracle/scripts/shell/Patches/stop_all.sh $db_ver
else
        for db in $dbs
        do
                . /home/oracle/scripts/oraenv.sh $db
                sqlplus / as sysdba << EOSQL
select instance_name, status from v\$instance;
shutdown immediate;
exit;
EOSQL

	done
fi

echo "All done!"

cd /home/oracle/scripts/shell/Patches/
