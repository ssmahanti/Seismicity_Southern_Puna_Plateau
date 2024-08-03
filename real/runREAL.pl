#!/usr/bin/perl -w
 
$year = "2008";
$input=<>;
chomp($input);
($mon,$day)=split('_', $input);
print "$mon,$day\n";

# latitude center is required to make lat. and lon. consistent in km
$D = "$year/$mon/$day/-26.7";

# -G(trx/trh/tdx/tdh)
#$G = "3.0/60/0.05/1";

# -R(rx/rh/tdx/tdh/tint[/gap/GCarc0/latref0/lonref0]])
$R = "1.0/50/0.2/2.0/2/180"; 

# -V(vp0/vs0/[s_vp0/s_vs0/ielev])
$V = "6.0/3.5";

# -S(np0/ns0/nps0/npsboth0/std0/dtps/nrt[drt/nxd/rsel/ires])
$S = "5/5/15/5/2.0/0.2/1.1/0.5/2.0"; 

$dir = "./pick_phasenet/pickfiles/$year$mon$day";
$station = "../station/spuna_stations.txt";
#$ttime = "./tt_db/ttdb_puna.txt";

system("./main/bin/REAL -D$D -R$R  -S$S -V$V $station $dir ");
print"./main/bin/REAL -D$D -R$R   -S$S -V$V $station $dir \n";
