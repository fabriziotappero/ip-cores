#!/usr/bin/perl

if ($#ARGV != 0) {
    die("Call: scanconfig.pl <configfile>\n");
}

%cfg = ();
$fn = $ARGV[0];
if (open(FILEH, "$fn")) {
    while (<FILEH>) {
	s/[\r\n]$//gi;
	@a = split("=",$_);
	if ($#a == 1) {
	    #print STDERR ($a[0]."=".$a[1]."\n");
	    $k = $a[0];
	    $v = $a[1];
	    $k =~ s/[^[:print:]]//gi;
	    $v =~ s/[^[:print:]]//gi;
	    $cfg{$k} = $v;
	} 
    }
    close(FILEH);
} else {
    print "opening \"$fn\": $!\n";
}

require ("vhdl/sparc/config.pl");
$sparc_cfg = createconfig(\%sparc_cfg,\%sparc_map,\%cfg);
%sparc_cfg = %{$sparc_cfg};
sparc_config_file (\%sparc_cfg);

require ("vhdl/peripherals/mem/config.pl");
$peri_mem_cfg = createconfig(\%peri_mem_cfg,\%peri_mem_map,\%cfg);
%peri_mem_cfg = %{$peri_mem_cfg};
peri_mem_config_file (\%peri_mem_cfg);

require ("vhdl/core/config.pl");
$core_cfg = createconfig(\%core_cfg,\%core_map,\%cfg);
%core_cfg = %{$core_cfg};
core_config_file (\%core_cfg);

require ("vhdl/mem/cache/config.pl");
$cache_cfg = createconfig(\%cache_cfg,\%cache_map,\%cfg);
%cache_cfg = %{$cache_cfg};
cache_config_file (\%cache_cfg);

require ("vhdl/core/ctrl/config.pl");
$ctrl_cfg = createconfig(\%ctrl_cfg,\%ctrl_map,\%cfg);
%ctrl_cfg = %{$ctrl_cfg};
ctrl_config_file (\%ctrl_cfg);








sub createconfig {
    
    my ($defcfg,$map,$cfg) = @_;
    my $rkey,my $rval,my $rfound;
    my $k,my $v,my $rv;
    my %defcfg = %{$defcfg};
    my %map = %{$map};
    my %cfg = %{$cfg};
    
    foreach $k (keys %cfg) {
	$v = $cfg{$k};
	($rkey,$rval,$rfound) = resolve(\%map,$k,$v);
	
	if ($rfound == 1 && exists($defcfg{$rkey})) {
	    #print STDERR ("set $rkey:$rval\n");
	    $defcfg{$rkey} = $rval;
	} else {
	    #print STDERR ("!!!! Warning: Could not set cfiguration $k resolved to $rkey:$rval:$rfound\n");
	}
    }
    #printout_cfg(\%defcfg);
    return \%defcfg;
}

sub printout_cfg {
    my ($defcfg) = @_;
    my %defcfg = %{$defcfg};
    my $k;
    foreach $k (keys %defcfg) {
	print ("$k:".$defcfg{$k}."\n");
    }
}

sub resolve 
{
    my ($map,$entry,$value) = @_;
    my %tmp = (),my $e,my $k,my $v;
    my $key, my $val;
    my %map = %{$map};
    my $found = 0;
Found:
    foreach $k (keys %map) {
	$key = $k;
	%tmp = @{$map{$k}};
	foreach $e (keys %tmp) {
	    $val = $tmp{$e};
	    if (lc($entry) eq lc($e)) {
		$v = $tmp{$e};
		$found = 1;
		last Found;
	    }
	}
    }
    if (ref($val)) {
	$val = &$val($value);
    }
    return ($key,$val,$found);
}

sub cfg_replace {
    my ($k,$v,$l) = @_;
    my $type;
    if ($l =~ /%$k%\[(.)\]/) {
	$type = $1;
	if ($type eq "b") {
	    if ($v == 0) {
		$v = "false";
	    } else {
		$v = "true";
	    }
	    $l =~ s/%($k)%\[(.)\]/$v/gi;
	} else {
	    print STDERR ("Warning cound not resolve [$1] typedef\n");
	}
    }
    else {
	$l =~ s/%$k%/$v/gi;
    }
    return $l;
}
















