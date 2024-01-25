##############################################
#*******vis_hor script************************
#converts DSAA .grd surfer files to PostScript
#*author*:*Kirill Gadylshin*******************
#*mail*:*gadylshin@yahoo.com******************
#*********************************************
##############################################

use strict;
use warnings;
use lib "../../COMMON/gmt";
use EnvConfig;
my $CONF_FILE_NAME = "my.conf";

my ($ar,$md,$iter) = ("","",);
my $M_PI = 3.1415926535;

#gmt PARAMS

my ($x_min,$x_max,$y_min,$y_max);
my ($cpt,$cpt_NaN);    
my $ps_out;

my ($PAGE_WIDTH, $PAGE_HEIGHT);

my ($N_ROWS,$N_COLUMNS,$XMAP,$YMAP,$DX,$DY);
my ($TICK_X,$TICK_Y);

my ($CPT_MAIN,$Z0,$ZN,$N_STEPZ);
my ($MARGIN_LEFT,$MARGIN_TOP);
my ($TITLE_FONT_SIZE,$TITLE_SHIFT_TOP);
my ($SCALE_THICKNESS,$SCALE_LENGTH,$SCALE_ORIENTATION,$SCALE_SHIFT);
my (@list_xyz);


sub usage()
{
    print "vis_hor.pl script takes no less then 2 arguments\n";
    print "\$arg1  -  file name with list of .DSAA surfer .grd files to be converted\n";
    print "\$arg2  -  Area\n";
    print "\$arg3  -  Model\n";
    print "\$arg4  -  Iteration\n";
}

sub configurate()
{

    # Check
    print 'Checking gmt configuration... ';
    
    unless(-f $CONF_FILE_NAME)
    {
	print "FAILED : there is no configuration file\n" ;
	return(1);
    }
    print "OK\n";
    
    # Read
    print "Reading gmt configuration.. [$CONF_FILE_NAME] " ;

    my $res = get_configuration($CONF_FILE_NAME);
    
    unless(defined($res))
    {
	print "Undefined \$res";
	return(1);
    }

#    $LOGLEVEL = get_var("LOGLEVEL");
#    $LOGLEVEL ||= "ALL";
#    log_trace("LOGLEVEL=$LOGLEVEL");
#    set_log_level($LOGLEVEL);
    ($PAGE_WIDTH,$PAGE_HEIGHT) = (get_var("PAGE_WIDTH"),get_var("PAGE_HEIGHT"));
    
    ($N_ROWS,$N_COLUMNS,$XMAP,$YMAP,$DX,$DY) = (get_var("N_ROWS"),get_var("N_COLUMNS"),get_var("XMAP"),get_var("YMAP"),get_var("DX"),get_var("DY"));

    ($CPT_MAIN,$Z0,$ZN,$N_STEPZ) =(get_var("CPT_MAIN"),get_var("Z0"),get_var("ZN"),get_var("N_STEPZ"));
    
    ($TICK_X,$TICK_Y) = (get_var("TICK_X"),get_var("TICK_Y"));
    ($MARGIN_LEFT,$MARGIN_TOP) = (get_var("MARGIN_LEFT"),get_var("MARGIN_TOP"));
    ($TITLE_FONT_SIZE,$TITLE_SHIFT_TOP) = (get_var("TITLE_FONT_SIZE"),get_var("TITLE_SHIFT_TOP"));
    ($SCALE_THICKNESS,$SCALE_LENGTH,$SCALE_ORIENTATION) = (get_var("SCALE_THICKNESS"),get_var("SCALE_LENGTH"),get_var("SCALE_ORIENTATION"));
    $SCALE_SHIFT = get_var("SCALE_SHIFT");
    $SCALE_ORIENTATION ||= "";
    
    $CPT_MAIN = "../../COMMON/scales_cpt/$CPT_MAIN";
    
    print "OK\n";

    return 0;
}


sub get_cpts($$$$)
{
    my ($cpt_main,$z0,$zn,$n_stepz) = @_;
    my ($cpt,$cpt_NaN);
    $cpt = "../../DATA/$ar/$md/data/dv_anom.cpt";
    $cpt_NaN = "../../DATA/$ar/$md/data/dv_anom_NaN.cpt";
    my $dz = ($zn-$z0)/$n_stepz;    

    my $cmd = "makecpt -C$cpt_main -T$z0/$zn/1 > $cpt";
    system($cmd) == 0 or die "Error call makecpt : $?";
    
    open(CPT_IN,"<",$cpt) or die "Can't open $cpt : $!";
    open(CPT_OUT,">",$cpt_NaN) or die "Can't open $cpt_NaN : $!";
    
    my $line;
    my $zn_1 = $zn - 1;
    
    $line = <CPT_IN>;
    print CPT_OUT $line;
    $line = <CPT_IN>;
    print CPT_OUT $line;
    $line = <CPT_IN>;
    print CPT_OUT $line;
    print CPT_OUT "-10000 GRAY -500 GRAY\n";
    
    if (defined ($line = <CPT_IN>))
    {
        my ($zs,$rs,$gs,$bs,$zr,$rr,$gr,$br) = split(' ',$line);
        print CPT_OUT "-500 $rs $gs $bs $zs $rs $gs $bs\n";
	print CPT_OUT $line;
    }
    else
    {
        die "Error $cpt file format\n";
    }
    
    while (defined ($line = <CPT_IN>))
    {
        print CPT_OUT $line;        
        if ($line =~ m/^$zn_1.*$zn.*$/)
        {
            my ($zs,$rs,$gs,$bs,$zr,$rr,$gr,$br) = split(' ',$line);
            print CPT_OUT "$zn $rs $gs $bs 500 $rs $gs $bs\n";
        }
    }
    
    close CPT_IN;
    close CPT_OUT;
    
    $cmd = "makecpt -C$cpt_main -T$z0/$zn/$dz > $cpt";
    system($cmd) == 0 or die "Error call makecpt : $?";

    return ($cpt,$cpt_NaN);
}


sub main()
{
    if ($#ARGV + 1 < 4 )
    {
        usage();
        exit;
    }
    
    my ($grd_in,$xyz_out,$ztr_file);
    my ($title) = "";
    
    my $file_list = $ARGV[0];
    $ar = $ARGV[1];
    $md = $ARGV[2];
    $iter = $ARGV[3];
    
    $CONF_FILE_NAME = "../../DATA/$ar/hor.conf";
    die "Configuration process has been FAILED\n" if (configurate() != 0 );

    
    print "Converting .grd files to xyz tables...\n";
    open(LIST_GRD,"<",$file_list) or die "Can't open $file_list : $!";
    
    my $n_map = 0;
    
    while (defined($grd_in = <LIST_GRD>))
    {
	$n_map++;
	chomp $grd_in;
	$ztr_file = <LIST_GRD>;
	chomp $ztr_file;
	$title = <LIST_GRD>;
	chomp $title;
	$xyz_out = $grd_in . ".xyz";
	push @list_xyz ,  $xyz_out . '|' . $title . '|' . $ztr_file;    	
	convert2xyz($grd_in,$xyz_out);	
    }
    
    
    close LIST_GRD;
    print "Conversion OK\n";
    
    die "\$N_ROWS*\$N_COLUMNS greater than number of maps\n" if ( $n_map < $N_ROWS*$N_COLUMNS );
    
    print "Creating PostScript...\n";
    
    $ENV{'PATH'} = $ENV{'PATH'} . ':/usr/lib/gmt/bin';
    $ps_out = "../../PICS/ps/$ar/$md/hor_nodes_${iter}.ps";

    my $cmd = "gmtset BASEMAP_TYPE PLAIN BASEMAP_FRAME_RGB black ANNOT_FONT_PRIMARY 0 ANNOT_FONT_SIZE_PRIMARY 10";
    $cmd = $cmd . " HEADER_FONT_SIZE 10 HEADER_OFFSET -0.5c PAGE_ORIENTATION portrait LABEL_FONT_SIZE 12";    
    system($cmd) == 0 or die "Error call gmtset : $?";
    
    my ($title_x,$title_y) = ($PAGE_WIDTH/2.0,$PAGE_HEIGHT-$TITLE_SHIFT_TOP);
    
    if ( $iter != 0 )
    {
	$cmd = "echo \"$title_x $title_y $TITLE_FONT_SIZE 0 1 BC Velocity anomalies in horizontal sections. Area : $ar, Model : $md, Iteration : $iter\"";
    }
    else
    {
	$cmd = "echo \"$title_x $title_y $TITLE_FONT_SIZE 0 1 BC Velocity anomalies in horizontal sections. Area : $ar, Model : $md. Synthetic model\"";
    }
    $cmd = $cmd . " | pstext -R0/$PAGE_WIDTH/0/$PAGE_HEIGHT -JX${PAGE_WIDTH}c/${PAGE_HEIGHT}c -Xa0 -Ya0 -K";
    $cmd = $cmd . " --PAPER_MEDIA=Custom_${PAGE_WIDTH}cx${PAGE_HEIGHT}c > $ps_out";
    system($cmd) == 0 or die "Error call pstext : $?";
 
    ($cpt,$cpt_NaN) = get_cpts($CPT_MAIN,$Z0,$ZN,$N_STEPZ);


    #Calculating $YMAP
    if ($YMAP == 0)
    {
	$YMAP = $XMAP*($y_max-$y_min+0.0)/(($x_max-$x_min+0.0)*cos(($y_max+$y_min+0.0)/2.0*$M_PI/180.0));
    }
    
    #Draw Grid maps
    for my $i (0..$N_ROWS-1)
    {
	for my $j (0..$N_COLUMNS-1)
	{
	    my $info = @list_xyz[$i*$N_COLUMNS+$j];
	    
	    #print "i = $i j=$j\n";
	    
	    ($xyz_out,$title,$ztr_file) = split(/\|/,$info);
	    if ($i+1 == $N_ROWS)
	    {
		if ($j == 0)
		{
		    draw_map($xyz_out,$ztr_file,$title,$MARGIN_LEFT+($XMAP+$DX)*$j,$PAGE_HEIGHT-$MARGIN_TOP+$DY-($YMAP+$DY)*($i+1),3);
		}
		else
		{
		    draw_map($xyz_out,$ztr_file,$title,$MARGIN_LEFT+($XMAP+$DX)*$j,$PAGE_HEIGHT-$MARGIN_TOP+$DY-($YMAP+$DY)*($i+1),2);
		}
	    }
	    elsif($j == 0)
	    {
		draw_map($xyz_out,$ztr_file,$title,$MARGIN_LEFT+($XMAP+$DX)*$j,$PAGE_HEIGHT-$MARGIN_TOP+$DY-($YMAP+$DY)*($i+1),1);
	    }
	    else
	    {
		draw_map($xyz_out,$ztr_file,$title,$MARGIN_LEFT+($XMAP+$DX)*$j,$PAGE_HEIGHT-$MARGIN_TOP+$DY-($YMAP+$DY)*($i+1),0);
	    }
	}
    }
    
    #Draw scale

    draw_scale();
    return 0;
}


#draw plot map
sub draw_map($$$$$$)
{
    #$axis  0 - no axis labels
    #$axis  1 - y-axis label
    #$axis  2 - x-axis label
    #$axis 3 - x- and y-axis labels    
    my ($xyz_out,$ztr,$title,$OFF_X,$OFF_Y,$axis) = @_;
    
    my $cmd;
    if ($axis == 1)
    {
	$cmd="pscontour -R$x_min/$x_max/$y_min/$y_max -JX${XMAP}c/${YMAP}c '$xyz_out' -C$cpt_NaN -I";
	$cmd = $cmd . " -B$TICK_X/$TICK_Y:\"latitude, degrees\"::.\"$title\":WeSn";
    }
    elsif ($axis == 2)
    {
	$cmd="pscontour -R$x_min/$x_max/$y_min/$y_max -JX${XMAP}c/${YMAP}c '$xyz_out' -C$cpt_NaN -I";
	$cmd = $cmd . " -B$TICK_X:\"longitude, degrees\":/$TICK_Y:.\"$title\":WeSn";
	
    }
    elsif ($axis == 3)
    {
	$cmd="pscontour -R$x_min/$x_max/$y_min/$y_max -JX${XMAP}c/${YMAP}c '$xyz_out' -C$cpt_NaN -I";
	$cmd = $cmd . " -B$TICK_X:\"longitude, degrees\":/$TICK_Y:\"latitude, degrees\"::.\"$title\":WeSn";
    }
    else
    {
	$cmd="pscontour -R$x_min/$x_max/$y_min/$y_max -JX${XMAP}c/${YMAP}c '$xyz_out' -C$cpt_NaN -I";
	$cmd = $cmd . " -B$TICK_X/$TICK_Y:.\"$title\":WeSn";
    }
    
    $cmd = $cmd . " -Xa${OFF_X}c -Ya${OFF_Y}c -O -K >> '$ps_out'";
    print "$cmd\n";
    system($cmd) == 0 or die "Error call pscontour : $?";
    
    
    $cmd="pscoast -Rg$x_min/$x_max/$y_min/$y_max -JX${XMAP}c/${YMAP}c -Di -N1/3,100/0/0 -I1/3,blue -W3";
    
    $cmd = $cmd . " -Xa${OFF_X}c -Ya${OFF_Y}c -O -K >> '$ps_out'";	
    system($cmd) == 0 or die "Error call pscoast : $?";
   
    $cmd="psxy '$ztr' -Rg$x_min/$x_max/$y_min/$y_max -JX${XMAP}c/${YMAP}c -Gblack -fig -Sc0.13c";
    #"  psxy circle.dat -Rg-180/-120/50/70 -Jx0.16id -Gred -B4/4 -fig -Sc0.03c 
    $cmd = $cmd . " -Xa${OFF_X}c -Ya${OFF_Y}c -O -K >> '$ps_out'";
    
    system($cmd) == 0 or die "Error call psxy : $?";

}

sub draw_scale()
{
    return if ($SCALE_ORIENTATION eq "");
    
    my ($xpos,$ypos);
    if ($SCALE_ORIENTATION eq 'h')
    {
	$xpos = $MARGIN_LEFT + ($XMAP+$DX)*$N_COLUMNS/2.0 - $DX/2.0;
	$ypos = $PAGE_HEIGHT-$MARGIN_TOP+$DY-($YMAP+$DY)*$N_ROWS - $SCALE_SHIFT;
	my $cmd = "psscale -D${xpos}c/${ypos}c/${SCALE_LENGTH}c/${SCALE_THICKNESS}ch -S -C$cpt -O -K >> '$ps_out'";    
	system($cmd) == 0 or die "Error call psscale : $?";
	$cmd = "echo \"0 0 12 0 1 BC velocity anomalies, %\"";
	$ypos = $ypos - $SCALE_THICKNESS - 1.3;
	$xpos = $xpos - $SCALE_LENGTH/2.0;
	$cmd = $cmd . " | pstext -R-10/10/-0.1/10 -JX${SCALE_LENGTH}c/10c -Xa${xpos} -Ya${ypos} -O >> '$ps_out'";
	system($cmd) == 0 or die "Error call pstext : $?";	
    }
    elsif ($SCALE_ORIENTATION eq 'v')
    {
	$xpos = $MARGIN_LEFT +  ($XMAP+$DX)*($N_COLUMNS-1) + $XMAP + $SCALE_SHIFT;
	$ypos = $PAGE_HEIGHT-$MARGIN_TOP+$DY/2.0-($YMAP+$DY)*$N_ROWS/2.0;
	my $cmd = "psscale -D${xpos}c/${ypos}c/${SCALE_LENGTH}c/${SCALE_THICKNESS}c -S -C$cpt -O -K >> '$ps_out'";    
	system($cmd) == 0 or die "Error call psscale : $?";	
	$cmd = "echo \"0 0 12 90 1 TC velocity anomalies, %\"";
	$xpos = $xpos + $SCALE_THICKNESS + 1.1;
	$ypos = $ypos - $SCALE_LENGTH/2.0;
	$cmd = $cmd . " | pstext -R0/1/-10/10 -JX10c/${SCALE_LENGTH}c -Xa${xpos} -Ya${ypos} -O >> '$ps_out'";
	system($cmd) == 0 or die "Error call pstext : $?";
    }
}

#convert DSAA surfer .grd file into xyz table
sub convert2xyz($$)
{
    my ($grd_in,$xyz_out) = @_;
    
    open(IN,"<",$grd_in) or die "Can't open '$grd_in' : $!";
    open(OUT,'>',$xyz_out) or die "Can't open $xyz_out : $!";
    
    print "Start converting $grd_in to xyz table...\n";
    
    my ($header,$nx,$ny,$z_min,$z_max,$line);
    

    die "Error: Incorrect file format" unless (defined ($header = <IN>) );
    
    die "Error: Incorrect file format" unless (defined ($line = <IN>) );
    ($nx,$ny) = split(' ',$line);

    die "Error: Incorrect file format" unless (defined ($line = <IN>) );
    ($x_min,$x_max) = split(' ',$line);
    
    die "Error: Incorrect file format" unless (defined ($line = <IN>) );
    ($y_min,$y_max) = split(' ',$line);
    
    die "Error: Incorrect file format" unless (defined ($line = <IN>) );
    ($z_min,$z_max) = split(' ',$line);
    
    die "Error: Incorrect file format" if ($ny < 2 || $nx < 2);
    

    my ($recn,$cnt) = ($nx*$ny,0);

    my ($dx,$dy) = (($x_max-$x_min+0.0)/($nx-1.0),($y_max-$y_min+0.0)/($ny-1.0));		
    
    while ($cnt < $recn && defined($line = <IN>))
    {      
 	for my $z (split(' ',$line)) 
	{
            $cnt++;
            my ($x,$y) = ($x_min+($cnt%$nx)*$dx,$y_min+($cnt/$nx)*$dy);
	    print OUT "$x $y $z\n";            
	}
    }

    die "Failed to convert. Not enough data in $grd_in. Terminated." if ( $cnt < $recn);
    warn "Too many data in $grd_in. Cutted." if (<IN>);
    
    
    close OUT;
    close IN;

    print "Converting OK. Processed $cnt grid nodes\n";
    
}




main();
