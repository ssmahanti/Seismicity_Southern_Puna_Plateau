#!/usr/bin/perl -w
$phasein = "../phase_all_puna_crust.txt";
$event = "../hyposhift/catalog_velest_puna_crust_shifted.txt";

$phaseout = "../hyposhift/phase_all_puna_crust_shifted.txt"; #phase format for hypoDD

open(JK,"<$phasein");
@par = <JK>;
close(JK);

open(EV,"<$event");
@eves = <EV>;
close(EV);

open(EV1,">$phaseout");
foreach $file(@par){
    chomp($file);
    ($test,$jk,) = split(' ',$file);
    if($test eq "#"){
		($jk,$year,$month,$day,$hour,$min,$sec,$lat,$lon,$dep,$jk,$jk,$jk,$jk,$num) = split(' ',$file);
			$out = 0;
		foreach $eve(@eves){
			chomp($eve);
#			($yr,$mon,$day1,$hh,$mm,$ss,$lat1,$lon1,$dep1,$jk,$jk,$jk,$jk,$nm) = split(" ",$eve);
			($yr,$mon,$day1,$hh,$mm,$ss,$lat1,$lon1,$dep1,$jk,$jk,$jk) = split(" ",$eve);


            #combine original picks &  improved initial locations that obtained with VELEST
			if($year==2000+$yr &&$month==$mon && $day==$day1 &&abs($hour*3600 + $min*60 + $sec - $hh*3600 - $mm*60 - $ss) < 5){
				print EV1 "# $year $month $day $hour $min $sec $lat1 $lon1 $dep1 0.0 0.0 0.0 0.0 $num\n";
				$out = 1;
			}
		}
	}else{
		if($out>0){
			printf EV1 "$file\n";
		}
    }
}
close(EV);