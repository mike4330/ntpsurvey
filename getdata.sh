#!/bin/sh
# emits data for individual score graphs
DAYS=60

if [[ $2 ]] ; then DAYS=$2;fi

echo "days set to $DAYS"

#exit

cd /home/mike/scripts/ntpsurvey

sqlite3 ntpsurvey.sdb "select ts,avgscore from hostscores where serverip ='$1' AND  ts > strftime('%s','now')-(86400*$DAYS);"
