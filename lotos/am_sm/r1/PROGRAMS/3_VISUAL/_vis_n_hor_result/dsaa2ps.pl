#############################################
#*******DSAA to ps script********************
#converts DSAA .grd surfer file to PostScript
#*author*:*Kirill Gadylshin******************
#*mail*:*gadylshin@yahoo.com*****************
#********************************************
#############################################

use strict;
use warnings;
use lib "../../../COMMON/gmt";
use EnvConfig;
my $CONF_FILE_NAME = "gmt.conf";

my ($ar,$md) = ("","");

#gmt PARAMS

my ($PAGE_WIDTH, $PAGE_HEIGHT);



sub usage()
{
    print "dsaa2ps script takes no less then 2 arguments\n";
    print "\$arg1  -  input file name. A DSAA surfer .grd file\n";
    print "\$arg2  -  output file name. A Post Script file\n";
    print "[\$arg3]  -  plot title. Optionally\n";
    print "[\$arg4]  -  Area\n";
    print "[\$arg5]  -  Model\n";
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
    $PAGE_WIDTH = get_var("PAGE_WIDTH");
    $PAGE_HEIGHT = get_var("PAGE_HEIGHT");
    
    print "PAGE PARAMS :\n";
    print "PAGE_WIDTH\t\t= $PAGE_WIDTH\n";
    print "PAGE_HEIGHT\t\t= $PAGE_HEIGHT\n";
    
    print "OK\n";

    return 0;
}


sub get_cpts($$$)
{
    my ($cpt_main,$z0,$zn) = @_;
    my ($cpt,$cpt_NaN);
    $cpt = "../../../DATA/$ar/$md/data/dv_anom.cpt";
    $cpt_NaN = "../../../DATA/$ar/$md/data/dv_anom_NaN.cpt";
    my $dz = ($zn-$z0)/10;    

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
    if ($#ARGV + 1 < 2 )
    {
        usage();
        exit;
    }
    
    my ($grd_in,$xyz_out,$ps_out);
    my ($title) = "";
    
    $title = $ARGV[2] if  ($#ARGV > 1);
    $ar = $ARGV[3] if ($#ARGV > 2);
    $md = $ARGV[4] if ($#ARGV > 3);
    
    $grd_in = $ARGV[0];
    $xyz_out = $ARGV[0] . '_xyz.grd';
    
    open(IN,"<",$grd_in) or die "Can't open $grd_in : $!";
    open(OUT,'>',$xyz_out) or die "Can't open $xyz_out : $!";
    
    print "Start converting $grd_in to xyz table...\n";
    
    my ($header,$nx,$ny,$x_min,$x_max,$y_min,$y_max,$z_min,$z_max,$line);
    

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
    my ($j,$i) = (0,0);
    my ($dx,$dy) = (($x_max-$x_min+0.0)/($nx-1.0),($y_max-$y_min+0.0)/($ny-1.0));		
    
    while ($cnt < $recn && defined($line = <IN>))
    {      
 	for my $z (split(' ',$line)) 
	{
            $cnt++;
            $i++;
            
    
#	    if ( abs($z-$z_max) < 0.001 || abs($z-$z_min) < 0.001)
#	    {
#		next;
#	    }	
	    #my ($x,$y) = ($x_min+($i-1)*$dx,$y_min+$j*$dy);
            my ($x,$y) = ($x_min+($cnt%$nx)*$dx,$y_min+($cnt/$nx)*$dy);
	    print OUT "$x $y $z\n";
            
	    if ($i >= $nx )
	    {
		$i = 0;
		$j++;
	    }
            
	}
    }

    die "Failed to convert. Not enough data in $grd_in. Terminated." if ( $cnt < $recn);
    warn "Too many data in $grd_in. Cutted." if (<IN>);
    
    
    close OUT;
    close IN;

    print "Converting OK. Processed $cnt grid nodes\n";
    
    print "Start converting xyz table to ps...\n";
    
    $ps_out = $ARGV[1];
    $ps_out .= ".ps" if ($ps_out !~ /\.ps$/);
    
    $ENV{'PATH'} = $ENV{'PATH'} . ':/usr/lib/gmt/bin';
    
    my ($cpt,$cpt_NaN) = ("blue_red_6.cpt","blue_red_6_NaN.cpt");    
    my ($tickx,$ticky) = (($x_max-$x_min+0.0)/4.0,($y_max-$y_min+0.0)/4.0);    
    
    $tickx = sprintf "%3.2f" , $tickx;
    $ticky = sprintf "%3.2f" , $ticky;
    
    if ( $ar )
    {
        my $conf = "../../../DATA/$ar/config.txt";
        open(CONF,"<",$conf) or die "Can't open $conf : $!";
        
        while (defined ($line = <CONF>))
        {
            if ($line =~ m/^.*MAP VIEW.*$/)
            {
                $line = <CONF>;
                last;
            }
        }
        
        if (defined ($line = <CONF>))
        {
            ($tickx,$ticky) = split(' ',$line);
        }
        
        while (defined ($line = <CONF>))
        {
            if ($line =~ m/^.*SCALES.*$/)
            {
                $line = <CONF>;
                last;
            }
        }
        
        if (defined ($line = <CONF>))
        {
            ($cpt) = split(' ',$line);
            my ($z0,$zn) = (-10,10);
            $cpt = "../../../COMMON/scales_cpt/$cpt";
            if (defined ($line = <CONF>))
            {
                ($z0,$zn) = split(' ',$line);
            }
            
            ($cpt,$cpt_NaN) = get_cpts($cpt,$z0,$zn);
        }
        
        close(CONF);
    }
    
    
    
    my $cmd = "gmtset BASEMAP_TYPE PLAIN BASEMAP_FRAME_RGB black ANNOT_FONT_PRIMARY 0 ANNOT_FONT_SIZE_PRIMARY 10 HEADER_FONT_SIZE 10 HEADER_OFFSET -0.5c";
    system($cmd) == 0 or die "Error call gmtset : $?";

    $cmd="pscontour -Rg$x_min/$x_max/$y_min/$y_max -Jx1.36id '$xyz_out' -B$tickx/$ticky:.\"$title\":WeSn -C$cpt_NaN -I -X3.25i -K > '$ps_out'";    
    system($cmd) == 0 or die "Error call pscontour : $?";
    
    $cmd = "gmtset ANNOT_FONT_SIZE 10";
    system($cmd) == 0 or die "Error call gmtset : $?";    
    
    $cmd="psscale -D4.2i/1i/2.0i/0.2i -S -C$cpt -O -K >> '$ps_out'";    
    system($cmd) == 0 or die "Error call psscale : $?";

    $cmd="pscoast -Rg$x_min/$x_max/$y_min/$y_max -Jx1.36id -Di -N1/3,100/0/0 -I1/3,blue -W3 -O -K >> '$ps_out'";
    system($cmd) == 0 or die "Error call pscoast : $?";
    
    print "Converting OK. Output : $ps_out\n";
    return 0;
}

sub test_conf()
{
    if (configurate() != 0 )
    {
	print "Configuration process has been FAILED\n";
    }
}

test_conf();
#main();
