#!/usr/bin/perl -w
#161015  0 6 49.51 42.8676N  13.0841E   4.14   0.00    102      0.24
$relocate = "../model/inpmd_const_puna_v2.CNV";
$relo = "../output/catalog_velest_puna_crust_v5.txt";
$dele = "../output/delet_velest_puna_crust_v5.txt";

open(JK,"<$relocate");
@par = <JK>;
close(JK);

open(OT,">$relo");
open(DE,">$dele");
$mag=0;
foreach $_(@par){
	chomp($_);
	if(substr($_,0,2) eq " 8" || substr($_,0,2) eq " 9"){
	$date_year = substr($_,0,2);
	$date_mon = substr($_,2,2);
	$date_day = substr($_,4,2);
	$hour = substr($_,7,2);
	$min = substr($_,9,2);
	$sec = substr($_,12,5);
	$lat = substr($_,18,7);
	$lon = substr($_,27,8);
	$dep = substr($_,37,6);
	#$mag = substr($_,45,5);
	$mag=$mag+1;
	$az = substr($_,54,3);
	$res = substr($_,62,5);
    if(substr($_,25,1) eq 'S'){$lat = -1*$lat;}
    if(substr($_,35,1) eq 'W'){$lon = -1*$lon;}
	if($az <= 180 && $res < 1.5 && $dep<40.1){
		
		print OT "$date_year $date_mon $date_day $hour $min $sec $lat $lon $dep $mag $az $res\n";
	}else{
		print DE "$date_year $date_mon $date_day $hour $min $sec $lat $lon $dep $mag $az $res\n";
	}
	}
}

close(OT);
close(DE);
