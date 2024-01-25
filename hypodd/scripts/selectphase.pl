#!/usr/bin/perl -w

#This scripts extracts out the phases based on the catalog provided and prepares the hypoDD input file
#Not required if you are using the same catalog as phase file
$phasein = "./phase_input_hypodd.txt";
$event = "../velest/output/catalog_velest_puna_20.txt";

$phaseout = "hypodd_puna20_input.pha"; #phase format for hypoDD

open(JK,"<$phasein");
@par = <JK>;
close(JK);

open(EV,"<$event");
@eves = <EV>;
close(EV);

open(EV,">$phaseout");
foreach $file(@par){
    chomp($file);
    ($test,$jk) = split(' ',$file);
    if($test eq "#"){
		($jk,$year,$month,$day,$hour,$min,$sec,$lat,$lon,$dep,$jk,$jk,$jk,$jk,$num) = split(' ',$file);
			$out = 0;
		foreach $eve(@eves){
			chomp($eve);
			($yr,$mon,$day1,$hh,$mm,$ss,$lat1,$lon1,$dep1,$num0,$gap,$res) = split(" ",$eve);
			$num1 = $num0*1;
			#$dep2 = $dep1+3.1; #Adjusting from sealevel to avg. station elevation
			$dep2 = $dep1; #Adjusting from sealevel to avg. station elevation

            #combine original picks &  improved initial locations that obtained with VELEST
			if(abs($num-$num1)<1 && abs($hour*3600 + $min*60 + $sec - $hh*3600 - $mm*60 - $ss) < 3){
				print EV "# $year $month $day $hour $min $sec $lat1 $lon1 $dep2 0 0 0 $res $num\n";
				$out = 1;
			}
		}
	}else{
		if($out>0){
			printf EV "$file\n";
		}
    }
}
close(EV);