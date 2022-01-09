#!/usr/bin/perl
use GeoIP2::Database::Reader;

my $reader = GeoIP2::Database::Reader->new(
    file    => '/home/mike/scripts/GeoLite2-Country.mmdb',  # e.g. /home/maxmind/db/GeoIP2-Country.mmdb
    locales => [ 'en', 'de', ]
);

$tf="/tmp/srvtmp.tmp";
$of='/var/www/html/ntp/survey.html';

$logsample=238;
$logsample=($logsample*10000);

$z=`head -n 1 $tf`;
($a,$b)=split / /,$z;
$ut=localtime($a*86400-3.5067168E9+$b); #MJD conversion

open (CF, "master.list") || die "cannot open $!";

while (<CF>) {
if (/^server/) {
	($f,$cfip) = split;
	#print "$cfip\n";
	push (@iplist,$cfip);
	}
}


#system ("cat /var/log/ntpstats/remote/burgess/peerstats.2* /var/log/ntpstats/peerstats.2* /home/mike/scripts/ntpsurvey/currentsample.mumbai |grep --text -vi 127.127.28| tail -n $logsample > $tf");

$MUMBAI_SAMP=int($logsample*.153);
$burgess_samp=int($logsample*.96);
$local_samp=int($logsample*.044);

system ("cat currentsample.mumbai |tail -n $MUMBAI_SAMP |sort -n > mumbai.extract");
system ("cat /var/log/ntpstats/remote/burgess/peerstats.2* |tail -n $burgess_samp > burgess.extract");
system ("cat /var/log/ntpstats/peerstats.2* |grep --text '192.168.1' |tail -n $local_samp > local.extract");

system ("cat local.extract mumbai.extract burgess.extract |grep --text -vi 127.127.28| tail -n $logsample > foo");

# create main input file
system ("sed 's/[^[:print:]]//g' foo|sort -k1n -k2n > $tf");


open (F,"$tf") || die "cannot open $!";

while (<F>) {
	@field=split;
	$ip=$field[2];
	$offset=abs($field[4]);
	$delay=$field[5];
	$jitter=$field[7];
	#score calculation
	$score=($offset+($delay/4)+$jitter)*1000;
	$tscore{$ip}=$tscore{$ip}+$score;
	$count{$ip}++;
	#print "$ip JI=$jitter OF=$offset DE=$delay SC=$score\n";
}

$gentime=localtime(time);

open (O,">$of");
open (T,"> output.csv");

print O '<html><body>
<head>
  <meta charset="UTF-8">
<style>
*{
  font-family:mono;
}

table {
  border-collapse: collapse;
  border: 1px solid black;
  width: 1700px;
}

td {
  padding-left: 10px;
  padding-right: 10px;
}

</style>
<title>NTP survey results</title>
</head>
';


print O "<h1>page generated at $gentime<br>";
print O "<h2>first records at $ut<br>";
	print O '
	<img src="/ntp/surveyrate.png" width="600"><img src="/ntp/srvsinoper.png" width="600"><img src="/ntp/totalrecordcount.png" width="600"><br>
	<img src="/ntp/dead_records.png" width="600"><img src="/ntp/extime.png" width="600">
	<table border=1>
	<th>#</th><th>host</th><th>score avg</th><th>numrec</th>
	<th>pct</th><th>cfg</th>
	';

foreach $name (sort { $tscore{$a} <=> $tscore{$b} } keys %tscore) {
		$avgc{$name}=($tscore{$name} / $count{$name}); #calc avg
		#print O "<tr><td>$avgc{$name}</td> <td>$name</td> <td>$count{$name} $pct\%</td>\n";

    }

foreach $val (sort { $avgc{$a} <=> $avgc{$b} } keys %avgc) {
	if ($count{$val} < 1) {next;}
	$pct=100*($count{$val}/$logsample);
	$z=sprintf("%.5f",$avgc{$val}) ;
	$tstring='black';
	$pct2=sprintf("%.3f", $pct);
	$ix++;

	$classicon="";
	if ($z < 10) {$cstring="#119911"; $classicon=' 🅐 ';};
	if ($z > 10) {$cstring="7CFC00";$classicon=' 🅑 ';}; #lightgreen
	if ($z > 20) {$cstring="#ffff66";$classicon=' 🅒 ';};#lightyellow
	if ($z > 40) {$cstring="#e5e500";$classicon='&#127315;'}; #darkyellow
	if ($z > 80) {$cstring="#ffb732";$tstring="#121212";$classicon=' 🅔 ';} #lightorange
	if ($z > 160) {$cstring="#ffa500";$tstring="#2f2f2f";$classicon='&#127317;'} #orange
	if ($z > 320) {$cstring="#cc8400";$tstring="#f0f0f0";$classicon=' 🅖  ';} #dark oragne
	if ($z > 640) {$cstring="#ff3232";$tstring="#dddddd";$classicon=' 🅗 ';} #light red
	if ($z > 1280) {$cstring="#ff0000";$tstring="#f0f0f0";$classicon='&#127320;'} #red
	if ($z > 2560) {$cstring="#a60404";$tstring="#e59999";$classicon='&#127321;'} #darker red
	if ($z > 5120) {$cstring="#b20000";$tstring="#f0f0f0";$classicon=' 🅚 ';} #dark red
	if ($z > 10240) {$cstring="#900000";$tstring="#f3f3f3";$classicon=' 🅛 ';} #darkest red
	if ($z > 20480) {$cstring="#600000";$tstring="#f5f5f5";$classicon=' 🅜 ';} #darkest red
	if ($z > 40960) {$cstring="#300000";$tstring="#f7f7f7";$classicon=' 🅝 ';} #darkest red
	if ($z > 81920) {$cstring="#000000";$tstring="#f9f9f9";$classicon='&#127326;'} #darkest red
	if ($z > 81920) {$cstring="#000000";$tstring="#f9f9f9";$classicon=' 🅟 ';} #
	if ($z > 163840) {$cstring="#000022";$tstring="#fbfbfb";$classicon=' 🅠 ';} #
	if ($z > 327680) {$cstring="#000044";$tstring="#d9fbfb";$classicon=' 🅡 ';} #
	if ($z > 655360) {$cstring="#000066";$tstring="#d9fbfb";$classicon=' 🅢 ';} #
	if ($z > 1.31e6) {$cstring="#010188";$tstring="#d9fbfb";$classicon=' 🅣 ';} #
	if ($z > 2.62e6) {$cstring="#0202aa";$tstring="#d9fbfb";$classicon=' 🅤 ';} #
	if ($z > 5.24e6) {$cstring="#0303bb";$tstring="#d9fbfb";$classicon=' 🅥 ';} #
	if ($z > 10.48e6) {$cstring="#0404cc";$tstring="#c8fafa";$classicon=' 🅦  ';} #
	if ($z > 2.096e7) {$cstring="#0505dd";$tstring="#c8fafa";$classicon=' 🅧  ';} #
	if ($z > 4.192e7) {$cstring="#0909ee";$tstring="#c8fafa";$classicon='&#127336;'} #
	if ($z > 8.384e7) {$cstring="#0c0cee";$tstring="#c8fafa";$classicon='&#127337;'} #

	#font scaling
	$fs=($pct2*18)+8;
	$fs=$fs . "px"; 
	
	if ($val =~ "162.159.200") {print "bad val\n";next;}
	if ($val =~ "58.65.177") {print "bad val\n";next;}
	if ($val !~ /192.168/) {
		chomp($val);
		my $insights = $reader->country( ip => $val );
		my $country_rec = $insights->country();
		$cname=$country_rec->name();
	}

	print O "<tr><td bgcolor=$cstring><p style=\"font-size:$fs\">$ix</p></td>";
	print O "<td bgcolor=$cstring ><p style=\"font-size:$fs\">$val $cname</p></td>
 	<td bgcolor=$cstring><p style=\"font-size:$fs\">$z</p></td> 
	<td bgcolor=$cstring><p style=\"font-size:$fs\">$count{$val}</p></td>
	<td bgcolor=$cstring><p style=\"font-size:$fs\"> $pct2 \%</p></td>\n";

	#text output
	print "$ix\t$val\t$z\t$count{$val}\t$pct2\%\t$cname\t";
	print T "$ix,$val,$cname,$z,$count{$val},$pct2";

	print O "<td><font size=3>$classicon</td>";
	if( $val ~~ @iplist ) {
		print O "<td>X</td>";print "cfg \n";print T ",\@@\n"} 
		else {print "\n";print T "\n";}
}

print O '</table></body></html>';
