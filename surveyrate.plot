#!/usr/bin/gnuplot

set term pngcairo size 850,325 font "NK57 Monospace,8"
set grid lt -1 lc rgb "#4a4a4a" front 

cd "/home/mike/scripts/ntpsurvey"

stats "< ./rate2 |sed -e 's/[a-z]=//g'" using 3 prefix "A" nooutput

q=(A_records * 20)
z=(q/60)

set style textbox opaque
set label 1 at graph 0.02, 0.9 tc rgb "#494949" boxed font ",9"
set label 1 "mean:" . sprintf("%.2f \nsamples %.0f\nhours %.1f",A_mean,A_records,z)

set output "/var/www/html/ntp/surveyrate.png"

set title "survey rate as of `date`" font ",9"

ulim=(A_mean*1.4)

set yrange [A_min:ulim]
set xtics font ",8"
set samples 175 
plot "< ./rate2 |sed -e 's/[a-z]=//g'" using 0:3 with lines smooth bezier lc rgb "#11c022" lw 1.5 t "rate"

set yrange rest
set autoscale y

unset label
set datafile sep ","
set xdata time
set timefmt "%s"
set format x "%y%m%d"
set title "NTP servers in rotation generated at `date`"
set key below
set linetype 1 lc "red"
set linetype 2 lc "blue" lw 1.5

set ls 10 lc rgb "#d8860b"
set ls 11 lc rgb "#88bb88" lw 1.2
set ls 12 lc rgb "#e86ba3" lw .9
set ls 100 lw 3

set samples 60
set yrange [90:]
set output "/var/www/html/ntp/srvsinoper.png"

plot "< sqlite3 -csv ntpsurvey.sdb < input.sql" using 1:2 with lines smooth bezier  t "srvs in operation", \
"< sqlite3 -csv ntpsurvey.sdb < input.sql" using 1:3 with lines smooth bezier  t "hosts in records"

set format x "%y%m%d"


unset xdata
stats  "< ./getdr" nooutput
f(x) = STATS_slope * x + STATS_intercept
set xdata time
set samples 120
set yrange [0:]
set title "Dead Records in Loop at `date`"
set output "/var/www/html/ntp/dead_records.png"
plot  "< ./getdr" \
using 1:2 with lines smooth bezier t "dead records",\
f(x) lw 3 lc rgb "blue"

unset datafile sep
set term pngcairo size 1810,790 font ",8"
#################mumbai stats#################
unset xdata
stats  "< tail -n 29012 mumbai_jitter.log" using 1:9 nooutput prefix "MJ"
f(x) = MJ_slope * x + MJ_intercept

set output "/var/www/html/ntp/mumbai.png" 
set multiplot layout 1,3 title "Mumbai clock statistics at `date`"


set autoscale y

set samples 70 
set xdata time
set format x "%y%m%d"
set title "mean jitter"
set ylabel "ms"
plot "< tail -n 29012 mumbai_jitter.log" using 1:9 with imp t "jitter" ls 10, f(x) ls 100

unset xdata
stats  "< tail -n 29012 mumbai_offset.log" using 1:9 nooutput prefix "MO"
f(x) = MO_slope * x + MO_intercept

set xdata time
set title "mean offset"
set ylabel "ms"
plot "< tail -n 29012 mumbai_offset.log" using 1:9 with imp ls 11  t "offset", f(x) ls 100, 0 lw 2 lc rgb "black"

unset xdata
stats  "< tail -n 29012 mumbai_delay.log" using 1:9 nooutput prefix "MD"
f(x) = MD_slope * x + MD_intercept
set yrange [MD_min_y:]
set xdata time
set title "mean delay"
plot "< tail -n 29012 mumbai_delay.log" using 1:9 with imp ls 12 t "delay" , f(x) ls 100
