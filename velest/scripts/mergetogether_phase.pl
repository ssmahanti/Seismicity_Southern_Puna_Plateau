#!usr/bin/perl -w
$mag = "0.0"; 
$num = 0;

$together = "../phase_all_puna_crust.txt";
#Actually, it is the hypoDD input format	
open(OT,">$together");
	$file = "../phase_real_puna_crust.txt";
	open(JK,"<$file");  
	@par = <JK>;
	close(JK);
	foreach $file(@par){
		($test,$jk) = split(' ',$file);
		if($test =~ /^\d+$/){
			($ind,$jk,$year1,$mon1,$dd1,$hh,$min,$sec,$lat,$lon,$dep) = split(' ',$file);
			$num++;
			print OT "# $year1  $mon1  $dd1   $hh    $min    $sec    $lat    $lon    $dep     0.0     0.0     0.0    0.0   $num\n";
		}else{
			($net,$station,$traveltime,$weight,$phase) = split(' ',$file);
			print OT "$net$station $traveltime 1 $phase\n";
		}
	}	
close(OT);
