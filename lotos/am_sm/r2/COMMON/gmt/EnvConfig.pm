package EnvConfig;
use Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(get_var set_var get_configuration %CACHE_HASH $CACHE_FILENAME);
#
# uses Config::General
#

#get_var set_var get_configuration check_exist_TestRun_WS create_TestRun_WS update_TestRun_WS delete_TestRun_WS

use Cwd 'abs_path';
use lib '.';

use strict;
use warnings;

use Data::Dumper;

use EnvConfig::General;

use File::Copy;
use File::Path;

# This hash is used by get_var to enchance
# so config file is read once
our %CACHE_HASH;
our $CACHE_FILENAME;

#-------------------------------------------------------------------------------
# Returns ref on hash with configuration
# if failed - returns undef
#-------------------------------------------------------------------------------
sub get_var($)
{
    
    my $vname = shift;

    unless(defined($CACHE_FILENAME))
    {
        print("Configuration hadn't been read.\n");        
        return;
    }
    
    unless(exists $CACHE_HASH{$vname})
    {
        print("There is no such configuration variable: $vname\n");
        return;
    }
    
    return($CACHE_HASH{$vname});
}

sub set_var($$$)
{
    log_trace_en();
    my ($conf_file, $var, $value) = @_;
    
    unless(-f $conf_file)
    {
        print("Incorrect config file name.");
        return 1;
    }

    my $conf = new EnvConfig::General($conf_file);
    my %CACHE_HASH = ParseConfig($conf_file);
    
    $CACHE_HASH{"$var"} = $value;
    
    $conf->save_file($conf_file, \%CACHE_HASH);
    
    return 0;
    
    
}
#-------------------------------------------------------------------------------
# Returns ref on hash with configuration variables and caches results
# if failed - returns undef
#-------------------------------------------------------------------------------
sub get_configuration($)
{
  
    my $path = shift;
    
    if(defined($CACHE_FILENAME) && $path eq $CACHE_FILENAME)
    {
        return(\%CACHE_HASH);
    }    
    
    unless(-f $path)
    {
        print("Incorrect config file name.");
        return;
    }
    
    %CACHE_HASH = ParseConfig($path);
    
    $CACHE_FILENAME = $path;
        
    return(\%CACHE_HASH);
}


1;

__END__
