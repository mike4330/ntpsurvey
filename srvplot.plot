#!/usr/bin/gnuplot

cd '/home/mike/scripts/ntpsurvey'
set datafile sep '|'

set term pngcairo size 900,350 font "mono,8"
set output "/var/www/html/ntp/scoregraph".ip.".png"

stats "< ./getdata.sh ".ip using 2 name "A" nooutput
set xdata time
set timefmt "%s"
set format x "%y%m%d" 

set yrange [:] reverse

pix=72
lwx=1.5

set ls 1 pi pix lw lwx
set ls 2 pi pix lw lwx
set ls 3 pi pix lw lwx
set ls 4 pi pix lw lwx
set ls 5 pi pix lw lwx
set ls 6 pi pix lw lwx
set ls 7 pi pix lw lwx
set ls 8 pi pix lw lwx
set ls 9 pi pix lw lwx
set ls 10 pi pix lw lwx
set ls 11 pi pix lw lwx
set ls 12 pi pix lw lwx
set ls 13 pi pix lw lwx
set ls 14 pi pix lw lwx
set ls 15 pi pix lw lwx
set ls 16 pi pix lw lwx
set ls 17 pi pix lw lwx
set ls 18 pi pix lw lwx
set ls 19 pi pix lw lwx
set ls 20 pi pix lw lwx
set ls 21 pi pix lw lwx
set ls 22 pi pix lw lwx
set ls 23 pi pix lw lwx
set ls 24 pi pix lw lwx
set ls 25 pi pix lw lwx


qmin=A_min

set yrange [qmin:]

set grid lt -1

set title "server score history for ".ip. "rank ".idx." at `date`"

plot "< ./getdata.sh ".ip using 1:2 with filledcurves ls idx ,A_mean lc rgb "red" lw 2 
