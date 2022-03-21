#!/bin/bash
version=$1

export ORACLE_HOME="/u01/oracle/$version/oh"

if [[ $version == "19" ]]
then
    . /home/oracle/scripts/setEnv.sh $version blogtest
else
    echo "Choose a database with the version $version
"
    read database
    . /home/oracle/scripts/setEnv.sh $version $database
fi

export ORAENV_ASK=NO
. oraenv
export ORAENV_ASK=YES

dbshut $ORACLE_HOME
