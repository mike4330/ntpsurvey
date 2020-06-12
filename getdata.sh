#!/bin/bash
# emits data for individual score graphs
DAYS=9

cd /home/mike/scripts/ntpsurvey

sqlite3 ntpsurvey.sdb "select ts,avgscore from hostscores where serverip ='$1' AND  ts > strftime('%s','now')-(86400*$DAYS);"
