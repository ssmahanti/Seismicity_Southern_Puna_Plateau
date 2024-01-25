##############################################
#*******vis_ver script************************
#converts DSAA .grd surfer files to PostScript
#*author*:*Kirill Gadylshin*******************
#*mail*:*gadylshin@yahoo.com******************
#*********************************************
##############################################

use strict;
use warnings;
use lib "../../../COMMON/gmt";
use EnvConfig;
my $CONF_FILE_NAME = "ver.conf";

my ($ar,$md,$iter) = ("","",);
my $M_PI = 3.1415926535;

#gmt PARAMS

my ($x_min,$x_max,$y_min,$y_max);
my ($cpt,$cpt_NaN);    
my $ps_out;

my ($PAGE_WIDTH, $PAGE_HEIGHT);

my ($COLUMNS_SHIFT,$DY);
my ($XMAP_HOR,$YMAP_HOR,$XMAP_VER,$YMAP_VER);
my ($N_SEC_HOR,$N_SEC_VER);
my ($TICK_X_HOR,$TICK_Y_HOR,$TICK_X_VER,$TICK_Y_VER);

my ($CPT_MAIN,$Z0,$ZN,$N_STEPZ);
my ($MARGIN_LEFT,$MARGIN_TOP);
my ($TITLE_FONT_SIZE,$TITLE_SHIFT_TOP);
my ($SCALE_THICKNESS,$SCALE_LENGTH,$SCALE_SHIFT);
my (@list_xyz);


sub usage()
{
    print "vis_hor.pl script takes no less then 2 arguments\n";
    print "\$arg1  -  Area\n";
    print "\$arg2  -  Model\n";
    print "\$arg3  -  Iteration\n";
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
    #print "PAGE_WIDTH\t= $PAGE_WIDTH\nPAGE_HEIGHT\t= $PAGE_HEIGHT\n";
    
    ($COLUMNS_SHIFT,$DY) = (get_var("COLUMNS_SHIFT"),get_var("DY"));
    #print "COLUMNS_SHIFT\t= $COLUMNS_SHIFT\nDY\t= $DY\n";
    ($XMAP_HOR,$YMAP_HOR,$XMAP_VER,$YMAP_VER) = (get_var("XMAP_HOR"),get_var("YMAP_HOR"),get_var("XMAP_VER"),get_var("YMAP_VER"));
    #print "XMAP_HOR\t= $XMAP_HOR\nYMAP_HOR\t= $YMAP_HOR\nXMAP_VER\t= $XMAP_VER\nYMAP_VER\t=$YMAP_VER\n";
    ($N_SEC_HOR,$N_SEC_VER) = (get_var("N_SEC_HOR"),get_var("N_SEC_VER"));
    #print "N_SEC_HOR\t= $N_SEC_HOR\nN_SEC_VER\t= $N_SEC_VER\n";
    ($CPT_MAIN,$Z0,$ZN,$N_STEPZ) =(get_var("CPT_MAIN"),get_var("Z0"),get_var("ZN"),get_var("N_STEPZ"));
    
    ($TICK_X_HOR,$TICK_Y_HOR,$TICK_X_VER,$TICK_Y_VER) = (get_var("TICK_X_HOR"),get_var("TICK_Y_HOR"),get_var("TICK_X_VER"),get_var("TICK_Y_VER"));
    ($MARGIN_LEFT,$MARGIN_TOP) = (get_var("MARGIN_LEFT"),get_var("MARGIN_TOP"));
    
    ($TITLE_FONT_SIZE,$TITLE_SHIFT_TOP) = (get_var("TITLE_FONT_SIZE"),get_var("TITLE_SHIFT_TOP"));
    
    ($SCALE_THICKNESS,$SCALE_LENGTH) = (get_var("SCALE_THICKNESS"),get_var("SCALE_LENGTH"));
    $SCALE_SHIFT = get_var("SCALE_SHIFT");    
    
    $CPT_MAIN = "../../../COMMON/scales_cpt/$CPT_MAIN";
    
    print "OK\n";

    return 0;
}


sub get_cpts($$$$)
{
    my ($cpt_main,$z0,$zn,$n_stepz) = @_;
    my ($cpt,$cpt_NaN);
    $cpt = "../../../DATA/$ar/$md/data/dv_anom.cpt";
    $cpt_NaN = "../../../DATA/$ar/$md/data/dv_anom_NaN.cpt";
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
    if ($#ARGV + 1 < 3 )
    {
        usage();
        exit;
    }
    
    my ($grd_in,$xyz_out,$ztr_file);
    my ($title) = "";
    
    $ar = $ARGV[0];
    $md = $ARGV[1];
    $iter = $ARGV[2];
    
    $CONF_FILE_NAME = "../../../DATA/$ar/ver.conf";
    die "Configuration process has been FAILED\n" if (configurate() != 0 );

    
    print "Creating PostScript...\n";
    
    $ENV{'PATH'} = $ENV{'PATH'} . ':/usr/lib/gmt/bin';
    $ps_out = "../../../PICS/ps/$ar/$md/vert_nodes_${iter}.ps";

    my $cmd = "gmtset BASEMAP_TYPE PLAIN BASEMAP_FRAME_RGB black ANNOT_FONT_PRIMARY 0 ANNOT_FONT_SIZE_PRIMARY 10";
    $cmd = $cmd . " HEADER_FONT_SIZE 10 HEADER_OFFSET -0.5c PAGE_ORIENTATION portrait LABEL_FONT_SIZE 12";    
    system($cmd) == 0 or die "Error call gmtset : $?";
    
    my ($title_x,$title_y) = ($PAGE_WIDTH/2.0,$PAGE_HEIGHT-$TITLE_SHIFT_TOP);
    
    $cmd = "echo \"$title_x $title_y $TITLE_FONT_SIZE 0 1 BC Velocity anomalies in vertical sections. Area : $ar, Model : $md. Synthetic model\"";
    $cmd = $cmd . " | pstext -R0/$PAGE_WIDTH/0/$PAGE_HEIGHT -JX${PAGE_WIDTH}c/${PAGE_HEIGHT}c -Xa0 -Ya0 -K";
    $cmd = $cmd . " --PAPER_MEDIA=Custom_${PAGE_WIDTH}cx${PAGE_HEIGHT}c > $ps_out";
    system($cmd) == 0 or die "Error call pstext : $?";
 
    ($cpt,$cpt_NaN) = get_cpts($CPT_MAIN,$Z0,$ZN,$N_STEPZ);


    #Calculating MAPs sizes
    calc_map_sizes(0);
    
    #Draw Horizontal section
    print "Draw Horizontal sections...\n";
    
    open(SETHOR,"<","../../../DATA/$ar/sethor.dat") or die "Can't open sethor.dat : $!";
    my $line;
    die "Error: Incorrect file format" unless (defined ($line = <SETHOR>) );
    die "Error: Incorrect file format" unless (defined ($line = <SETHOR>) );
    my @levels = split(' ',$line);
    close(SETHOR);
    
    my ($mark_dat,$mark_bln);
    #TODO : Check -f begore pscontour
    $xyz_out = sprintf("../../../TMP_files/hor/syn1_%2d.grd.xyz",$N_SEC_HOR);
    $ztr_file = sprintf("../../../TMP_files/hor/ztr%2d.dat",$N_SEC_HOR);  
    $title = "P anomalies, depth= $levels[$N_SEC_HOR-1] km";
    draw_map($xyz_out,$ztr_file,$title,($PAGE_WIDTH-$COLUMNS_SHIFT)/2-$XMAP_HOR/2,$PAGE_HEIGHT-$MARGIN_TOP+$DY-($YMAP_HOR+$DY),3);
    $xyz_out = sprintf("../../../TMP_files/hor/syn2_%2d.grd.xyz",$N_SEC_HOR);
    $title = "S anomalies, depth= $levels[$N_SEC_HOR-1] km";
    draw_map($xyz_out,$ztr_file,$title,($PAGE_WIDTH+$COLUMNS_SHIFT)/2-$XMAP_HOR/2,$PAGE_HEIGHT-$MARGIN_TOP+$DY-($YMAP_HOR+$DY),2);
#    for my $j (0..$N_SEC_VER-1)
#    {
#	$mark_dat = sprintf("../../../TMP_files/vert/mark_%2d",$j+1);
#	$mark_bln = $mark_dat . ".bln";
#	$mark_dat = $mark_dat . ".dat";
#	draw_marks($mark_dat,$mark_bln,($PAGE_WIDTH-$COLUMNS_SHIFT)/2-$XMAP_HOR/2,$PAGE_HEIGHT-$MARGIN_TOP+$DY-($YMAP_HOR+$DY));	
#	draw_marks($mark_dat,$mark_bln,($PAGE_WIDTH+$COLUMNS_SHIFT)/2-$XMAP_HOR/2,$PAGE_HEIGHT-$MARGIN_TOP+$DY-($YMAP_HOR+$DY));
#   }
   
    print "OK\n";
    #Draw Vertical sections
    for my $i (0..$N_SEC_VER-1)
    {
	$XMAP_VER = get_var("XMAP_VER");
	$grd_in = sprintf("../../../TMP_files/vert/syn_dv%2d.grd",$i+1);
	$xyz_out = $grd_in . ".xyz";
	$ztr_file = sprintf("../../../TMP_files/vert/ztr_%2d.dat",$i+1);
        $title = sprintf("P section %d",$i+1);
	convert2xyz($grd_in,$xyz_out);
	if ($XMAP_VER == 0)
	{
	    $XMAP_VER = ($x_max-$x_min)/($y_max-$y_min)*$YMAP_VER;	    
	}
	if ( $i+1 == $N_SEC_VER )
	{
	    draw_map_ver($xyz_out,$ztr_file,$title,($PAGE_WIDTH-$COLUMNS_SHIFT)/2-$XMAP_VER/2,$PAGE_HEIGHT-$MARGIN_TOP-$YMAP_HOR-($YMAP_VER+$DY)*($i+1)-$DY,3);
	}
	else
	{
	    draw_map_ver($xyz_out,$ztr_file,$title,($PAGE_WIDTH-$COLUMNS_SHIFT)/2-$XMAP_VER/2,$PAGE_HEIGHT-$MARGIN_TOP-$YMAP_HOR-($YMAP_VER+$DY)*($i+1)-$DY,1);
	}
	
	$grd_in = sprintf("../../../TMP_files/vert/syn_dv%2d.grd",$i+1);
	$xyz_out = $grd_in . ".xyz";	
        $title = sprintf("P section %d",$i+1);
	convert2xyz($grd_in,$xyz_out);
	
	if ($i+1 == $N_SEC_VER)
	{
	    draw_map_ver($xyz_out,$ztr_file,$title,($PAGE_WIDTH+$COLUMNS_SHIFT)/2-$XMAP_VER/2,$PAGE_HEIGHT-$MARGIN_TOP-$YMAP_HOR-($YMAP_VER+$DY)*($i+1)-$DY,2);
	}
	else
	{
	    draw_map_ver($xyz_out,$ztr_file,$title,($PAGE_WIDTH+$COLUMNS_SHIFT)/2-$XMAP_VER/2,$PAGE_HEIGHT-$MARGIN_TOP-$YMAP_HOR-($YMAP_VER+$DY)*($i+1)-$DY,0);
	}
	
    }
    
    #Draw scale

    draw_scale();
    return 0;
}
#draw plot marks
sub draw_marks($$$$)
{
    my ($mark_dat,$mark_bln,$OFF_X,$OFF_Y) = @_;
    
    #Plot marks vor vertical sections
#    open(MARK,"<",$mark_dat) or die "Can't open $mark_dat : $!";
    
    my ($line,$cmd);
#    my ($x,$y,$mark_text);
#    while (defined ($line = <MARK>))
#    {	
#	($x,$y,$mark_text) = split(' ',$line);
#	$mark_text = sprintf("%3.0f",$mark_text);
#	$cmd = "echo \"$x $y $TITLE_FONT_SIZE 0 1 BC $mark_text\"";
#	$cmd = $cmd . " | pstext -R$x_min/$x_max/$y_min/$y_max -JX${XMAP_HOR}c/${YMAP_HOR}c";
#	$cmd = $cmd . " -Xa${OFF_X}c -Ya${OFF_Y}c -O -K >> '$ps_out'";
#	system($cmd) == 0 or die "Error call pstext : $?";
 #   }
#    close(MARK);
    
#    $cmd="psxy '$mark_dat' -Rg$x_min/$x_max/$y_min/$y_max -JX${XMAP_HOR}c/${YMAP_HOR}c -S0.13c -fig ";
    
#    $cmd = $cmd . " -Xa${OFF_X}c -Ya${OFF_Y}c -O -K >> '$ps_out'";
#    print $cmd . "\n";
#    system($cmd) == 0 or die "Error call psxy : $?";
    
    
    $cmd="psxy '$mark_bln' -Rg$x_min/$x_max/$y_min/$y_max -JX${XMAP_HOR}c/${YMAP_HOR}c -SqD50k:+LDk -H -fig -W0.05c";
    
    $cmd = $cmd . " -Xa${OFF_X}c -Ya${OFF_Y}c -O -K >> '$ps_out'";
    print $cmd . "\n";
    system($cmd) == 0 or die "Error call psxy : $?";
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
	$cmd="pscontour -R$x_min/$x_max/$y_min/$y_max -JX${XMAP_HOR}c/${YMAP_HOR}c '$xyz_out' -C$cpt_NaN -I";
	$cmd = $cmd . " -B$TICK_X_HOR/$TICK_Y_HOR:\"latitude, degrees\"::.\"$title\":WeSn";
    }
    elsif ($axis == 2)
    {
	$cmd="pscontour -R$x_min/$x_max/$y_min/$y_max -JX${XMAP_HOR}c/${YMAP_HOR}c '$xyz_out' -C$cpt_NaN -I";
	$cmd = $cmd . " -B$TICK_X_HOR:\"longitude, degrees\":/$TICK_Y_HOR:.\"$title\":WeSn";
	
    }
    elsif ($axis == 3)
    {
	$cmd="pscontour -R$x_min/$x_max/$y_min/$y_max -JX${XMAP_HOR}c/${YMAP_HOR}c '$xyz_out' -C$cpt_NaN -I";
	$cmd = $cmd . " -B$TICK_X_HOR:\"longitude, degrees\":/$TICK_Y_HOR:\"latitude, degrees\"::.\"$title\":WeSn";
    }
    else
    {
	$cmd="pscontour -R$x_min/$x_max/$y_min/$y_max -JX${XMAP_HOR}c/${YMAP_HOR}c '$xyz_out' -C$cpt_NaN -I";
	$cmd = $cmd . " -B$TICK_X_HOR/$TICK_Y_HOR:.\"$title\":WeSn";
    }
    
    $cmd = $cmd . " -Xa${OFF_X}c -Ya${OFF_Y}c -O -K >> '$ps_out'";
    print "$cmd\n";
    system($cmd) == 0 or die "Error call pscontour : $?";
    
    
    $cmd="pscoast -Rg$x_min/$x_max/$y_min/$y_max -JX${XMAP_HOR}c/${YMAP_HOR}c -Di -N1/3,100/0/0 -I1/3,blue -W3";
    
    $cmd = $cmd . " -Xa${OFF_X}c -Ya${OFF_Y}c -O -K >> '$ps_out'";	
    system($cmd) == 0 or die "Error call pscoast : $?";
   
    #$cmd="psxy '$ztr' -Rg$x_min/$x_max/$y_min/$y_max -JX${XMAP_HOR}c/${YMAP_HOR}c -Gblack -fig -Sc0.13c";
    #"  psxy circle.dat -Rg-180/-120/50/70 -Jx0.16id -Gred -B4/4 -fig -Sc0.03c 
    #$cmd = $cmd . " -Xa${OFF_X}c -Ya${OFF_Y}c -O -K >> '$ps_out'";
    

    system($cmd) == 0 or die "Error call psxy : $?";

}

sub draw_map_ver($$$$$$)
{
    #$axis  0 - no axis labels
    #$axis  1 - y-axis label
    #$axis  2 - x-axis label
    #$axis 3 - x- and y-axis labels    
    my ($xyz_out,$ztr,$title,$OFF_X,$OFF_Y,$axis) = @_;
    
    my $cmd;
    if ($axis == 1)
    {
	$cmd="pscontour -R$x_min/$x_max/$y_min/$y_max -JX${XMAP_VER}c/${YMAP_VER}c '$xyz_out' -C$cpt_NaN -I";
	$cmd = $cmd . " -B$TICK_X_VER/$TICK_Y_VER:\"depth, km\"::.\"$title\":WeSn";
    }
    elsif ($axis == 2)
    {
	$cmd="pscontour -R$x_min/$x_max/$y_min/$y_max -JX${XMAP_VER}c/${YMAP_VER}c '$xyz_out' -C$cpt_NaN -I";
	$cmd = $cmd . " -B$TICK_X_VER:\"distance along profile, km\":/$TICK_Y_VER:.\"$title\":WeSn";
	
    }
    elsif ($axis == 3)
    {
	$cmd="pscontour -R$x_min/$x_max/$y_min/$y_max -JX${XMAP_VER}c/${YMAP_VER}c '$xyz_out' -C$cpt_NaN -I";
	$cmd = $cmd . " -B$TICK_X_VER:\"distance along profile, km\":/$TICK_Y_VER:\"depth, km\"::.\"$title\":WeSn";
    }
    else
    {
	$cmd="pscontour -R$x_min/$x_max/$y_min/$y_max -JX${XMAP_VER}c/${YMAP_VER}c '$xyz_out' -C$cpt_NaN -I";
	$cmd = $cmd . " -B$TICK_X_VER/$TICK_Y_VER:.\"$title\":WeSn";
    }
    
    $cmd = $cmd . " -Xa${OFF_X}c -Ya${OFF_Y}c -O -K >> '$ps_out'";
    print "$cmd\n";
    system($cmd) == 0 or die "Error call pscontour : $?";
    
    
    #$cmd="pscoast -Rg$x_min/$x_max/$y_min/$y_max -JX${XMAP_VER}c/${YMAP_VER}c -Di -N1/3,100/0/0 -I1/3,blue -W3";
    
    #$cmd = $cmd . " -Xa${OFF_X}c -Ya${OFF_Y}c -O -K >> '$ps_out'";	
    #system($cmd) == 0 or die "Error call pscoast : $?";
   
    #$cmd="psxy '$ztr' -R$x_min/$x_max/$y_min/$y_max -JX${XMAP_VER}c/${YMAP_VER}c -Gblack -fig -Sc0.13c";
    #"  psxy circle.dat -Rg-180/-120/50/70 -Jx0.16id -Gred -B4/4 -fig -Sc0.03c 
    #$cmd = $cmd . " -Xa${OFF_X}c -Ya${OFF_Y}c -O -K >> '$ps_out'";
    
    #system($cmd) == 0 or die "Error call psxy : $?";

}


sub draw_scale()
{
    my ($xpos,$ypos);
    $xpos = $PAGE_WIDTH/2;
    $ypos = $PAGE_HEIGHT-$MARGIN_TOP-$YMAP_HOR-($YMAP_VER+$DY)*$N_SEC_VER - $SCALE_SHIFT -$DY;
    my $cmd = "psscale -D${xpos}c/${ypos}c/${SCALE_LENGTH}c/${SCALE_THICKNESS}ch -S -C$cpt -O -K >> '$ps_out'";    
    system($cmd) == 0 or die "Error call psscale : $?";
    $cmd = "echo \"0 0 12 0 1 BC velocity anomalies, %\"";
    $ypos = $ypos - $SCALE_THICKNESS - 1.3;
    $xpos = $xpos - $SCALE_LENGTH/2.0;
    $cmd = $cmd . " | pstext -R-10/10/-0.1/10 -JX${SCALE_LENGTH}c/10c -Xa${xpos} -Ya${ypos} -O >> '$ps_out'";
    system($cmd) == 0 or die "Error call pstext : $?";	
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

sub calc_map_sizes($)
{
    my $i = shift;
    if ($YMAP_HOR == 0)
    {
        my $grd_in = "../../../TMP_files/hor/dv11 1.grd";
	open(IN,"<",$grd_in) or die "Can't open '$grd_in' : $!";
	my $line;
        die "Error: Incorrect file format" unless (defined ($line = <IN>) );    
        die "Error: Incorrect file format" unless (defined ($line = <IN>) );
        die "Error: Incorrect file format" unless (defined ($line = <IN>) );
        ($x_min,$x_max) = split(' ',$line);
        die "Error: Incorrect file format" unless (defined ($line = <IN>) );
        ($y_min,$y_max) = split(' ',$line);	
	close(IN);
	$YMAP_HOR = $XMAP_HOR*($y_max-$y_min+0.0)/(($x_max-$x_min+0.0)*cos(($y_max+$y_min+0.0)/2.0*$M_PI/180.0));
    }

    return if ($i == 0);
    
    if ($XMAP_VER == 0)
    {
	#my $n_sec = sprintf("%2d",$i);	
        #my $grd_in = "../../../TMP_files/vert/ver_11${n_sec}.grd";
	#open(IN,"<",$grd_in) or die "Can't open '$grd_in' : $!";
	#my $line;
        #die "Error: Incorrect file format" unless (defined ($line = <IN>) );    
        #die "Error: Incorrect file format" unless (defined ($line = <IN>) );
        #die "Error: Incorrect file format" unless (defined ($line = <IN>) );
        #($x_min,$x_max) = split(' ',$line);
        #die "Error: Incorrect file format" unless (defined ($line = <IN>) );
        #($y_min,$y_max) = split(' ',$line);	
	#close(IN);
	$XMAP_VER = ($x_max-$x_min)/($y_max-$y_min)*$YMAP_VER;
    }
}



main();
