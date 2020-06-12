#!/bin/bash

OUTFILE='/var/www/html/ntp/srvgraphs.html'

cd /home/mike/scripts/ntpsurvey

#for f in `sqlite3 ntpsurvey.sdb "select distinct(serverip) from hostscores"`;
#	do echo "hi $f";
#	gnuplot -p -e "ip='$f'" ./srvplot.plot
#	done




echo '<html><body>' > $OUTFILE

for q in `cat output.csv |grep @@ |head -26 |awk -F, '{print $2}'`;
	do echo "s $q";
		idx=$((idx+1))
		gnuplot -p -e "ip='$q'" -e "idx='$idx'"  ./srvplot.plot
	echo "<img src=scoregraph$q.png>" >> $OUTFILE
	done;

echo '</body></html>' >> $OUTFILE

find /var/www/html/ntp/score*.png -mtime +6 -exec rm -f {} \;
 
