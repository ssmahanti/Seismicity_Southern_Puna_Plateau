##############################################
#*******vis_vpvs script***********************
#converts DSAA .grd surfer files to PostScript
#*author*:*Kirill Gadylshin*******************
#*mail*:*gadylshin@yahoo.com******************
#*********************************************
##############################################

use strict;
use warnings;
use lib "../../../COMMON/gmt";
use EnvConfig;
my $CONF_FILE_NAME = "gmt.conf";
my ($LIST_HOR,$LIST_VER);

my ($ar,$md,$iter) = ("","",);
my $M_PI = 3.1415926535;

#gmt PARAMS

my ($x_min,$x_max,$y_min,$y_max);
my ($cpt,$cpt_NaN);    
my $ps_out;

my ($PAGE_WIDTH, $PAGE_HEIGHT);

my ($N_ROWS_HOR,$N_COLUMNS_HOR);
my ($N_ROWS_VER,$N_COLUMNS_VER);
my ($DX,$DY);
my ($XMAP_HOR,$YMAP_HOR,$XMAP_VER,$YMAP_VER);
my ($TICK_X_HOR,$TICK_Y_HOR,$TICK_X_VER,$TICK_Y_VER);

my ($CPT_MAIN,$Z0,$ZN,$N_STEPZ);
my ($MARGIN_LEFT,$MARGIN_TOP);
my ($TITLE_FONT_SIZE,$TITLE_SHIFT_TOP);
my ($SCALE_THICKNESS,$SCALE_LENGTH,$SCALE_SHIFT);
my (@list_xyz,@list_grd);

my ($MODEL_TYPE);

sub usage()
{
    print "vis_result_gmt.pl script takes no less then 6 arguments\n";
    print "\$arg1  -  Area\n";
    print "\$arg2  -  Model\n";
    print "\$arg3  -  Iteration\n";
    print "\$arg4  -  LIST_HOR - filename with list of files for horizontal sections\n";
    print "\$arg5  -  LIST_VER - filename with list of files for vertical sections\n";
    print "\$arg6  -  P, S or VpVs\n";
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
   
    ($N_ROWS_HOR,$N_COLUMNS_HOR) = (get_var("N_ROWS_HOR"),get_var("N_COLUMNS_HOR"));    
    #print "N_ROWS_HOR\t= $N_ROWS_HOR\nN_COLUMNS_HOR\t= $N_COLUMNS_HOR\n";
    ($N_ROWS_VER,$N_COLUMNS_VER) = (get_var("N_ROWS_VER"),get_var("N_COLUMNS_VER"));
    ($DX,$DY) = (get_var("DX"),get_var("DY"));
    #print "DX\t= $DX\nDY\t= $DY\n";
    ($XMAP_HOR,$YMAP_HOR,$XMAP_VER,$YMAP_VER) = (get_var("XMAP_HOR"),get_var("YMAP_HOR"),get_var("XMAP_VER"),get_var("YMAP_VER"));
    #print "XMAP_HOR\t= $XMAP_HOR\nYMAP_HOR\t= $YMAP_HOR\nXMAP_VER\t= $XMAP_VER\nYMAP_VER\t=$YMAP_VER\n";
    #($N_SEC_HOR,$N_SEC_VER) = (get_var("N_SEC_HOR"),get_var("N_SEC_VER"));
    #print "N_SEC_HOR\t= $N_SEC_HOR\nN_SEC_VER\t= $N_SEC_VER\n";
    
    if ($MODEL_TYPE eq "VpVs" ) # Vp/Vs visualization
    {
	($CPT_MAIN,$Z0,$ZN,$N_STEPZ) =(get_var("CPT_VPVS"),get_var("Z0_VPVS"),get_var("ZN_VPVS"),get_var("N_STEPZ_VPVS"));
    }
    else
    {
	($CPT_MAIN,$Z0,$ZN,$N_STEPZ) =(get_var("CPT_MAIN"),get_var("Z0"),get_var("ZN"),get_var("N_STEPZ"));
    }
    
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
    my $dz = ($zn-$z0+0.0)/$n_stepz;    

    my $str_cpt = "";
    
    my $cmd = "gmt makecpt -C$cpt_main -T$z0/$zn/$dz > $cpt";
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
        if ($line =~ m/^B.*$/)
        {
            my ($zs,$rs,$gs,$bs,$zr,$rr,$gr,$br) = split(' ',$str_cpt);
            print CPT_OUT "$zn $rs $gs $bs 500 $rs $gs $bs\n";
        }
	print CPT_OUT $line;        
	$str_cpt = $line;
    }
    
    close CPT_IN;
    close CPT_OUT;
    
    $cmd = "gmt makecpt -C$cpt_main -T$z0/$zn/$dz > $cpt";
    system($cmd) == 0 or die "Error call makecpt : $?";

    return ($cpt,$cpt_NaN);
}




sub draw_hor_sections()
{      
    return if ($N_ROWS_HOR*$N_COLUMNS_HOR == 0);
    
    print "Converting .grd files to xyz tables...\n";
    open(LIST_HOR,"<",$LIST_HOR) or die "Can't open $LIST_HOR : $!";
    
    my ($grd_in,$xyz_out,$ztr_file);
    my ($title) = "";

    my $n_map = 0;
    
    while (defined($grd_in = <LIST_HOR>))
    {
	$n_map++;
	chomp $grd_in;
	$ztr_file = <LIST_HOR>;
	chomp $ztr_file;
	$title = <LIST_HOR>;
	chomp $title;
	$xyz_out = $grd_in . ".xyz";
	push @list_xyz ,  $xyz_out . '|' . $title . '|' . $ztr_file;   
	convert2xyz($grd_in,$xyz_out);	
    }
    
    
    close LIST_HOR;
    print "Conversion OK\n";
    
    if ($YMAP_HOR == 0)
    {
	$YMAP_HOR = $XMAP_HOR*($y_max-$y_min+0.0)/(($x_max-$x_min+0.0)*cos(($y_max+$y_min+0.0)/2.0*$M_PI/180.0));
    }

    
    die "\$N_ROWS_HOR*\$N_COLUMNS_HOR greater than number of maps\n" if ( $n_map < $N_ROWS_HOR*$N_COLUMNS_HOR );
    
    print "Creating PostScript...\n";
    

    my $cmd = "gmtset BASEMAP_TYPE PLAIN BASEMAP_FRAME_RGB black ANNOT_FONT_PRIMARY 0 ANNOT_FONT_SIZE_PRIMARY 10";
    $cmd = $cmd . " HEADER_FONT_SIZE 10 HEADER_OFFSET -0.5c PAGE_ORIENTATION portrait LABEL_FONT_SIZE 12";    
    system($cmd) == 0 or die "Error call gmtset : $?";
    
    my ($title_x,$title_y) = ($MARGIN_LEFT,$PAGE_HEIGHT-$TITLE_SHIFT_TOP);
    
    if ( $iter != 0 )
    {
	$cmd = "echo \"$title_x $title_y $TITLE_FONT_SIZE 0 1 BL Velocity anomalies in horizontal sections. Area : $ar, Model : $md, Iteration : $iter\"";
    }
    else
    {
	$cmd = "echo \"$title_x $title_y $TITLE_FONT_SIZE 0 1 BL Velocity anomalies in horizontal sections. Area : $ar, Model : $md. Synthetic model\"";
    }
    
    $cmd = $cmd . " | pstext -R0/$PAGE_WIDTH/0/$PAGE_HEIGHT -JX${PAGE_WIDTH}c/${PAGE_HEIGHT}c -Xa0 -Ya0 -K";
    $cmd = $cmd . " --PAPER_MEDIA=Custom_${PAGE_WIDTH}cx${PAGE_HEIGHT}c > $ps_out";
    system($cmd) == 0 or die "Error call pstext : $?";
     


    #Calculating $YMAP
    
    #Draw Grid maps
    for my $i (0..$N_ROWS_HOR-1)
    {
	for my $j (0..$N_COLUMNS_HOR-1)
	{
	    my $info = @list_xyz[$i*$N_COLUMNS_HOR+$j];
	    
	    #print "i = $i j=$j\n";
	    
	    ($xyz_out,$title,$ztr_file) = split(/\|/,$info);
	    if ($i+1 == $N_ROWS_HOR)
	    {
		if ($j == 0)
		{
		    draw_map($xyz_out,$ztr_file,$title,$MARGIN_LEFT+($XMAP_HOR+$DX)*$j,$PAGE_HEIGHT-$MARGIN_TOP+$DY-($YMAP_HOR+$DY)*($i+1),3);
		}
		else
		{
		    draw_map($xyz_out,$ztr_file,$title,$MARGIN_LEFT+($XMAP_HOR+$DX)*$j,$PAGE_HEIGHT-$MARGIN_TOP+$DY-($YMAP_HOR+$DY)*($i+1),2);
		}
	    }
	    elsif($j == 0)
	    {
		draw_map($xyz_out,$ztr_file,$title,$MARGIN_LEFT+($XMAP_HOR+$DX)*$j,$PAGE_HEIGHT-$MARGIN_TOP+$DY-($YMAP_HOR+$DY)*($i+1),1);
	    }
	    else
	    {
		draw_map($xyz_out,$ztr_file,$title,$MARGIN_LEFT+($XMAP_HOR+$DX)*$j,$PAGE_HEIGHT-$MARGIN_TOP+$DY-($YMAP_HOR+$DY)*($i+1),0);
	    }
	}
    }
    
    #Draw scale

    draw_scale_hor();
    return 0;

}

sub draw_scale_hor()
{
#    return if ($SCALE_ORIENTATION eq "");
    
    my ($xpos,$ypos);
#    if ($SCALE_ORIENTATION eq 'h')
#    {
#	$xpos = $MARGIN_LEFT + ($XMAP+$DX)*$N_COLUMNS/2.0 - $DX/2.0;
#	$ypos = $PAGE_HEIGHT-$MARGIN_TOP+$DY-($YMAP+$DY)*$N_ROWS - $SCALE_SHIFT;
#	my $cmd = "psscale -D${xpos}c/${ypos}c/${SCALE_LENGTH}c/${SCALE_THICKNESS}ch -S -C$cpt -O -K >> '$ps_out'";    
#	system($cmd) == 0 or die "Error call psscale : $?";
#	$cmd = "echo \"0 0 12 0 1 BC velocity anomalies, %\"";
#	$ypos = $ypos - $SCALE_THICKNESS - 1.3;
#	$xpos = $xpos - $SCALE_LENGTH/2.0;
#	$cmd = $cmd . " | pstext -R-10/10/-0.1/10 -JX${SCALE_LENGTH}c/10c -Xa${xpos} -Ya${ypos} -O >> '$ps_out'";
#	system($cmd) == 0 or die "Error call pstext : $?";	
#    }
#    elsif ($SCALE_ORIENTATION eq 'v')
#    {
	$xpos = $MARGIN_LEFT +  ($XMAP_HOR+$DX)*($N_COLUMNS_HOR-1) + $XMAP_HOR + $SCALE_SHIFT;
	$ypos = $PAGE_HEIGHT-$MARGIN_TOP+$DY/2.0-($YMAP_HOR+$DY)*$N_ROWS_HOR/2.0;
	my $cmd = "psscale -D${xpos}c/${ypos}c/${SCALE_LENGTH}c/${SCALE_THICKNESS}c -S -C$cpt -O -K >> '$ps_out'";    
	system($cmd) == 0 or die "Error call psscale : $?";	
	$cmd = "echo \"0 0 12 90 1 TC velocity anomalies, %\"";
	$xpos = $xpos + $SCALE_THICKNESS + 1.1;
	$ypos = $ypos - $SCALE_LENGTH/2.0;
	if ($N_ROWS_VER*$N_COLUMNS_VER == 0 )
	{
	    $cmd = $cmd . " | pstext -R0/1/-10/10 -JX10c/${SCALE_LENGTH}c -Xa${xpos} -Ya${ypos} -O >> '$ps_out'";
	}
	else
	{
	    $cmd = $cmd . " | pstext -R0/1/-10/10 -JX10c/${SCALE_LENGTH}c -Xa${xpos} -Ya${ypos} -O -K >> '$ps_out'";
	}
	system($cmd) == 0 or die "Error call pstext : $?";
#    }
}

sub draw_vert_sections()
{
    return if ($N_ROWS_VER*$N_COLUMNS_VER == 0);
    my $SHIFT_TOP;
    if ($N_ROWS_HOR*$N_COLUMNS_HOR == 0 )
    {
	$SHIFT_TOP = $PAGE_HEIGHT;
    }
    else
    {
	$SHIFT_TOP = $PAGE_HEIGHT-$MARGIN_TOP+$DY-($YMAP_HOR+$DY)*$N_ROWS_HOR - $SCALE_SHIFT;
    }
    
    my ($title_x,$title_y) = ($MARGIN_LEFT,$SHIFT_TOP - $TITLE_SHIFT_TOP);
    
    my $cmd ;

    if ( $iter != 0 )
    {
	$cmd = "echo \"$title_x $title_y $TITLE_FONT_SIZE 0 1 BL Velocity anomalies in vertical sections. Area : $ar, Model : $md, Iteration : $iter\"";
    }
    else
    {
	$cmd = "echo \"$title_x $title_y $TITLE_FONT_SIZE 0 1 BL Velocity anomalies in vertical sections. Area : $ar, Model : $md. Synthetic model\"";
    }
    
    if ($N_ROWS_HOR*$N_COLUMNS_HOR == 0 )
    {
	$cmd = $cmd . " | pstext -R0/$PAGE_WIDTH/0/$PAGE_HEIGHT -JX${PAGE_WIDTH}c/${PAGE_HEIGHT}c -Xa0 -Ya0 -K";
	$cmd = $cmd . " --PAPER_MEDIA=Custom_${PAGE_WIDTH}cx${PAGE_HEIGHT}c > $ps_out";
    }
    else
    {
	$cmd = $cmd . " | pstext -R0/$PAGE_WIDTH/0/$PAGE_HEIGHT -JX${PAGE_WIDTH}c/${PAGE_HEIGHT}c -Xa0 -Ya0 -O -K >> $ps_out";
    }
    system($cmd) == 0 or die "Error call pstext : $?";
 
    #($cpt,$cpt_NaN) = get_cpts($CPT_MAIN,$Z0,$ZN,$N_STEPZ);
    my ($grd_in,$xyz_out,$ztr_file);
    my ($title) = "";

    my $n_map = 0;
    
    open(LIST_VER,"<",$LIST_VER) or die "Can't open $LIST_VER : $!";
    
    while (defined($grd_in = <LIST_VER>))
    {
	$n_map++;
	chomp $grd_in;
	$ztr_file = <LIST_VER>;
	chomp $ztr_file;
	$title = <LIST_VER>;
	chomp $title;
	#$xyz_out = $grd_in . ".xyz";
	push @list_grd ,  $grd_in . '|' . $title . '|' . $ztr_file;   
	#convert2xyz($grd_in,$xyz_out);	
    }
    
    
    close LIST_VER;
    


    #Calculating MAPs sizes
    #calc_map_sizes(0);
    
    die "\$N_ROWS_VER*\$N_COLUMNS_VER greater than number of maps\n" if ( $n_map < $N_ROWS_VER*$N_COLUMNS_VER );
   
    print "OK\n";
    #Draw Vertical sections
    
    
    my ($SHIFT_LEFT,$XMAP_CUR);
    
    for my $i (0..$N_ROWS_VER-1)
    {
	$SHIFT_LEFT = 0;
	for my $j (0..$N_COLUMNS_VER-1)
	{
	    my $info = @list_grd[$i*$N_COLUMNS_VER+$j];
	    
	    #print "i = $i j=$j\n";
	    
	    ($grd_in,$title,$ztr_file) = split(/\|/,$info);
	    $xyz_out = $grd_in . ".xyz";	
	    convert2xyz($grd_in,$xyz_out);
	    if ($XMAP_VER == 0)
	    {
		$XMAP_VER = ($x_max-$x_min)/($y_max-$y_min)*$YMAP_VER;
	    }
	    
	    $XMAP_CUR = $XMAP_VER;
	    
	    
	    
	    if ($i+1 == $N_ROWS_VER)
	    {
		if ($j == 0)
		{
		    draw_map_ver($xyz_out,$ztr_file,$title,$MARGIN_LEFT+$SHIFT_LEFT,$SHIFT_TOP-$MARGIN_TOP+$DY-($YMAP_VER+$DY)*($i+1),3);
		}
		else
		{
		    draw_map_ver($xyz_out,$ztr_file,$title,$MARGIN_LEFT+$SHIFT_LEFT,$SHIFT_TOP-$MARGIN_TOP+$DY-($YMAP_VER+$DY)*($i+1),2);
		}
	    }
	    elsif($j == 0)
	    {
		draw_map_ver($xyz_out,$ztr_file,$title,$MARGIN_LEFT+$SHIFT_LEFT,$SHIFT_TOP-$MARGIN_TOP+$DY-($YMAP_VER+$DY)*($i+1),1);
	    }
	    else
	    {
		draw_map_ver($xyz_out,$ztr_file,$title,$MARGIN_LEFT+$SHIFT_LEFT,$SHIFT_TOP-$MARGIN_TOP+$DY-($YMAP_VER+$DY)*($i+1),0);
	    }
	    
	    $XMAP_VER = get_var("XMAP_VER");
	    $SHIFT_LEFT = $SHIFT_LEFT + $XMAP_CUR + $DX;
	}
    }
    
    draw_scale_vert();
    
    return 0;
}

sub main()
{
    if ($#ARGV + 1 < 6 )
    {
        usage();
        exit;
    }
        
    $ar = $ARGV[0];
    $md = $ARGV[1];
    $iter = $ARGV[2];
    $LIST_HOR = $ARGV[3];
    $LIST_VER = $ARGV[4];
    $MODEL_TYPE = $ARGV[5];
    
    $CONF_FILE_NAME = "../../../DATA/$ar/gmt.conf";
    die "Configuration process has been FAILED\n" if (configurate() != 0 );

    
    print "Creating PostScript...\n";
    
    $ENV{'PATH'} = $ENV{'PATH'} . ':/usr/lib/gmt/bin';
    
    $ps_out = "../../../PICS/ps/$ar/$md/vis_result_${MODEL_TYPE}_${iter}.ps";  
  
    ($cpt,$cpt_NaN) = get_cpts($CPT_MAIN,$Z0,$ZN,$N_STEPZ);  
    #Draw Horizontal sections
    print "Draw Horizontal sections...\n";
    
    draw_hor_sections();

    #Draw Vertical sections
    print "Draw Vertical sections...\n";
    
    draw_vert_sections();
    
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
   
    $cmd="psxy '$ztr' -Rg$x_min/$x_max/$y_min/$y_max -JX${XMAP_HOR}c/${YMAP_HOR}c -Gblack -fig -Sc0.13c";
    #"  psxy circle.dat -Rg-180/-120/50/70 -Jx0.16id -Gred -B4/4 -fig -Sc0.03c 
    $cmd = $cmd . " -Xa${OFF_X}c -Ya${OFF_Y}c -O -K >> '$ps_out'";
    

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
   
    $cmd="psxy '$ztr' -R$x_min/$x_max/$y_min/$y_max -JX${XMAP_VER}c/${YMAP_VER}c -Gblack -fig -Sc0.13c";
    #"  psxy circle.dat -Rg-180/-120/50/70 -Jx0.16id -Gred -B4/4 -fig -Sc0.03c 
    $cmd = $cmd . " -Xa${OFF_X}c -Ya${OFF_Y}c -O -K >> '$ps_out'";
    
    system($cmd) == 0 or die "Error call psxy : $?";

}


sub draw_scale_vert()
{
    my ($xpos,$ypos);
    $xpos = $MARGIN_LEFT+$SCALE_LENGTH/2.0;
    if ($N_ROWS_HOR*$N_COLUMNS_HOR == 0 )
    {
	$ypos = $PAGE_HEIGHT;
    }
    else
    {
	$ypos = $PAGE_HEIGHT-$MARGIN_TOP+$DY-($YMAP_HOR+$DY)*$N_ROWS_HOR - $SCALE_SHIFT ;
    }
    $ypos = $ypos - $MARGIN_TOP+$DY-($YMAP_VER+$DY)*($N_ROWS_VER) - $SCALE_SHIFT;
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
