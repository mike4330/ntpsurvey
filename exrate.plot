#!/usr/bin/gnuplot

cd '/home/mike/scripts/ntpsurvey'

set term pngcairo size 850,325 font "mono,8"
set output "/var/www/html/ntp/extime.png"

ss=1700

stats "< tail -n " .ss." executiontime.log" using 1:($2/60) name "A" nooutput

f(x) = A_slope * x + A_intercept 

set xdata time
set timefmt "%s"
set format x "%m%d %H" 
set yrange [A_min_y:]
set grid lt -1

set title "survey execution time at `date`"
set style circle rad 6000
plot "< tail -n ".ss." executiontime.log" using 1:($2/60) with p pt 7 ps .9 lc rgb "#cc118811"  t "exec time", f(x) lc rgb "red" lw 2
