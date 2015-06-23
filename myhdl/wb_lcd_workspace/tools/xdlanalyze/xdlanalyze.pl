#!/usr/bin/perl -w
#
# xdlanalyze.pl - A script to view some statistics about XDL-files
#
# Copyright (c) 2006 Andreas Ehliar <ehliar@isy.liu.se>
# You may copy or modify this program under the terms of the GNU
# General Public License (version 2 or later)
#
# Usage: xdlanalyze.pl foo.xdl [hierarchy levels]
#
# Example usage:
# $ perl xdlanalyze.pl dafk.xdl
# XDLAnalyze V1.1 by Andreas Ehliar <ehliar@isy.liu.se>
# Analyzing the file dafk.xdl...................................................
# +-------------+--------+--------+--------+-----------+--------+--------+
# | Module      |   LUTS |     FF | RAMB16 | MULT18x18 |    IOB |    DCM |
# +-------------+--------+--------+--------+-----------+--------+--------+
# | /           |     64 |        |        |           |    216 |        |
# | cpu         |   5065 |   1345 |     12 |         4 |        |        |
# | dma0        |    654 |    254 |      1 |           |        |        |
# | dvga        |    816 |    755 |      4 |           |        |        |
# | eth3        |   2995 |   2337 |      4 |           |        |        |
# | jpg0        |   1682 |    681 |      2 |        13 |        |        |
# | leela       |    684 |    552 |      4 |         2 |        |        |
# | pia         |      9 |        |        |           |        |        |
# | pkmc_mc     |    219 |    122 |        |           |        |        |
# | rom0        |    111 |      3 |     12 |           |        |        |
# | sys_sig_gen |        |      6 |        |           |        |      2 |
# | uart2       |    824 |    346 |        |           |        |        |
# | wb_conbus   |    618 |     10 |        |           |        |        |
# +-------------+--------+--------+--------+-----------+--------+--------+
# | Total       |  13741 |   6411 |     39 |        19 |    216 |      2 |
# +-------------+--------+--------+--------+-----------+--------+--------+
#
# Example 2 (showing off hierarchical view of the same design)
# perl xdlanalyze.pl dafk.xdl 1
# XDLAnalyze V1.1 by Andreas Ehliar <ehliar@isy.liu.se>
# Analyzing the file dafk.xdl...................................................
# +-----------------------------+--------+--------+--------+-----------+--------+--------+
# | Module                      |   LUTS |     FF | RAMB16 | MULT18x18 |    IOB |    DCM |
# +-----------------------------+--------+--------+--------+-----------+--------+--------+
# | /                           |     64 |        |        |           |    216 |        |
# | cpu                         |      1 |        |        |           |        |        |
# | cpu/dwb_biu                 |     10 |     72 |        |           |        |        |
# | cpu/iwb_biu                 |     64 |     73 |        |           |        |        |
# | cpu/or1200_cpu              |   4441 |    987 |      2 |         4 |        |        |
# | cpu/or1200_dc_top           |    208 |     40 |      5 |           |        |        |
# | cpu/or1200_ic_top           |    182 |     38 |      5 |           |        |        |
# | cpu/or1200_immu_top         |     11 |     33 |        |           |        |        |
# | cpu/or1200_pic              |     32 |     38 |        |           |        |        |
# | cpu/or1200_tt               |    116 |     64 |        |           |        |        |
# | dma0                        |    617 |    235 |        |           |        |        |
# | dma0/fifo                   |     37 |     19 |      1 |           |        |        |
# | dvga                        |      5 |        |        |           |        |        |
# | dvga/regs                   |    279 |    360 |      3 |           |        |        |
# | dvga/rend                   |    174 |    110 |      1 |           |        |        |
# | dvga/spr                    |    358 |    285 |        |           |        |        |
# | eth3                        |     73 |     51 |        |           |        |        |
# | eth3/Mshreg_WillTransmit_q2 |      1 |        |        |           |        |        |
# | eth3/ethreg1                |    368 |    302 |        |           |        |        |
# | eth3/maccontrol1            |    295 |    103 |        |           |        |        |
# | eth3/macstatus1             |     60 |     18 |        |           |        |        |
# | eth3/miim1                  |    127 |     74 |        |           |        |        |
# | eth3/rxethmac1              |    311 |    107 |        |           |        |        |
# | eth3/txethmac1              |    369 |    119 |        |           |        |        |
# | eth3/wishbone               |   1391 |   1563 |      4 |           |        |        |
# | jpg0                        |    302 |     57 |      2 |           |        |        |
# | jpg0/dct0                   |    599 |    618 |        |        13 |        |        |
# | jpg0/tmem                   |    781 |      6 |        |           |        |        |
# | leela                       |     36 |        |        |           |        |        |
# | leela/cam0                  |    349 |    291 |      4 |         2 |        |        |
# | leela/mc0                   |    129 |     25 |        |           |        |        |
# | leela/regs0                 |    170 |    236 |        |           |        |        |
# | pia                         |      9 |        |        |           |        |        |
# | pkmc_mc/mem_fpga_board_if   |     40 |      1 |        |           |        |        |
# | pkmc_mc/pkmc_mc             |    179 |    121 |        |           |        |        |
# | rom0                        |     77 |      1 |        |           |        |        |
# | rom0/boot_prog_bram         |     34 |      2 |      8 |           |        |        |
# | rom0/boot_ram               |        |        |      4 |           |        |        |
# | sys_sig_gen                 |        |      6 |        |           |        |        |
# | sys_sig_gen/del0            |        |        |        |           |        |      1 |
# | sys_sig_gen/div0            |        |        |        |           |        |      1 |
# | uart2                       |      1 |        |        |           |        |        |
# | uart2/dbg                   |     33 |        |        |           |        |        |
# | uart2/regs                  |    725 |    266 |        |           |        |        |
# | uart2/wb_interface          |     65 |     80 |        |           |        |        |
# | wb_conbus                   |    618 |        |        |           |        |        |
# | wb_conbus/arb               |        |     10 |        |           |        |        |
# +-----------------------------+--------+--------+--------+-----------+--------+--------+
# | Total                       |  13741 |   6411 |     39 |        19 |    216 |      2 |
# +-----------------------------+--------+--------+--------+-----------+--------+--------+
# 
# If you don't want to print all fields, change the @print_order
# declaration below.
# 
# Note that the figures will usually not be exactly the same as the
# figures reported by map. This is partly because map does not count a 
# LUT with a constant output as a LUT, at least not in ISE 8.1.
#
# The program will also automatically convert a .ncd-file to a temporary
# .xdl file before running.
#
# This program has been tested on designs targetted at Virtex-2 and
# Virtex-4 from ISE 8.1 and ISE 8.2 on a Linux based computer. Note
# that it assumes that your path separator is set to /.
#
# Missing features:
#   * Slice count would be nice
#   * Show number of LUTs used as distributed RAM and SRL16
#   * Virtex-5 support
#
# NOTE:
#   The synthesizer will probably optimize your design across module boundaries
#   in some cases. This means that your figures cannot be entirely correct.

use strict;
use IO::Handle;
use IO::File;
use POSIX qw(tmpnam);


use constant {
    LUTS => 1,
    FF => 2,
    IOB => 3,
    RAMB16 => 4,
    MULT_18X18 => 5,
    DSP48 => 6,
    DCM => 7,
    DCM_ADV => 8,
    BUFG => 9,
    };

my @translation = ( "UNKNOWN", "LUTS","FF","IOB","RAMB16","MULT18x18",
		    "DSP48", "DCM", "DCM_ADV", "BUFG" );


# Modify this line to include what you want printed and in what order
my @print_order = ( LUTS, FF, RAMB16, DSP48, MULT_18X18, IOB, DCM,
		    DCM_ADV, BUFG );



########################################################################
my %themodules;
my %hierarchical_usageinfo;
my %usageinfo;

# This variable controls how many levels we will keep track of
my $hierarchical_level = 0;

######################################################################
# Add a component to the statistics
######################################################################
sub add_component {
    my $thename = $_[0];
    my $thetype = $_[1];

    my @temppath = split("/",$thename);
    my @list = ();
    my $currname = $temppath[0];
    my $i;

    push(@list,$currname);
    
    for($i = 1; $i < $#temppath; $i = $i  + 1) {
	$currname = "$currname/$temppath[$i]";
	push(@list,$currname);
    }
    
    for($i = $hierarchical_level; $i < $#temppath; $i = $i + 1) {
	$currname = pop(@list);
	if($themodules{$currname}) {
	    $i = $#temppath;
	}
    }
    

    if($thename =~ /\//) {
    }else{
# If there is no slash in the name => a component of the top level
	$currname = "/";
    }

    my %thehash;

    $hierarchical_usageinfo{$currname}{$thetype}++;
    $usageinfo{$thetype}++;
    
    $themodules{$currname} = 1;
}

######################################################################
# Analyze an XDL file and collect statistics about component
# usage
######################################################################

sub analyze_file {

    print "Analyzing the file $_[0]...";
    STDOUT->autoflush(1);

    open THEFILE, '<', $_[0] or die;

    my $line = 0;
    while (<THEFILE>){

	# Progress meter
	$line++;
	if($line == 10000){
	    $line = 0;
	    print(".");
	    STDOUT->autoflush(1);
	}

	# Quick and dirty parser that does not keep any state.
	# A real parser would remember what kind of instance we are
	# currently inside in order to keep track of more things such
	# as for example slice usage, etc.

	# Both an F and a G LUT can be on the same line
	# So we can't use elseif here.
	if(/ F:([a-zA-Z0-9_\/\[\]<>\.]+:\#([A-Z]+):D=)/) {
	    &add_component($1,LUTS);
	}

	if(/ G:([a-zA-Z0-9_\/\[\]<>\.]+:\#([A-Z]+):D=)/) {
	    &add_component($1,LUTS);
	}


	# Both an FFX and a FFY flip flop can be on the same line
	# So we can't use elseif here.
	if(/FFX:([a-zA-Z0-9_\/\[\]<>\.]+:\#[A-Z]+)/) {
	    &add_component($1,FF);
	}

	if(/FFY:([a-zA-Z0-9_\/\[\]<>\.]+:\#[A-Z]+)/) {
	    &add_component($1,FF);
	}

	# Check if there is an instance defined on this line
	if(/^inst/) {
	    if(/^inst \"([a-zA-Z0-9_\/\[\]<>\.]+)\" \"IOB\"/){
		&add_component($1,IOB);
	    }elsif(/^inst \"([a-zA-Z0-9_\/\[\]<>\.]+)\" \"RAMB16\"/){
		&add_component($1,RAMB16);
	    }elsif(/^inst \"([a-zA-Z0-9_\/\[\]<>\.]+)\" \"MULT18X18\"/){
		&add_component($1,MULT_18X18);
	    }elsif(/^inst \"([a-zA-Z0-9_\/\[\]<>\.]+)\" \"DSP48\"/){
		&add_component($1,DSP48);
	    }elsif(/^inst \"([a-zA-Z0-9_\/\[\]<>\.]+)\" \"DCM\"/){
		# FIXME - Do we need a check for a dummy DCM?
		&add_component($1,DCM);
	    }elsif(/^inst \"([a-zA-Z0-9_\/\[\]<>\.]+)\" \"DCM_ADV\"/){
		# Check for unused dummy instantiation of DCM_ADV
		if(! /^inst \"XIL_ML_UNUSED_DCM/){
		    &add_component($1,DCM_ADV);
		}
	    }elsif(/^inst \"([a-zA-Z0-9_\/\[\]<>\.]+)\" \"BUFG\"/){
		&add_component($1,BUFG);
	    }
	    # Adding more components here should be easy
	}

    }

    print "\n";

}

######################################################################
# Print a line consisting of dashes and plus like the marked lines in
# the following output:
# --> +-------------------+--------+--------+--------+
#     | Module            |   LUTS |     FF |    IOB |
# --> +-------------------+--------+--------+--------+
######################################################################

sub print_dashes {
    my $firstlen = $_[0];
    my $inst_order = $_[1];
    my $insttype;
    print "+" . "-" x ($firstlen + 2);
    foreach $insttype (@$inst_order) {
	my $maxlen = length($translation[$insttype]);
	$maxlen = $maxlen < 6 ? 6 : $maxlen;
	print "+" . "-" x ($maxlen + 2);
    }
    printf("+\n");
    
}

######################################################################
# Print statistics collected in the %themodules, %usageinfo, and
# %hierarchical_usageinfo hashes.
######################################################################

sub print_stats {

    my $firstlen;
    my @thekeys = keys %themodules;
    @thekeys = sort(@thekeys);
    my $i;
    my $name;
    my $foo;
    my @inst_order;
    
# Find maximum length of the first field
    $firstlen = length("Module");
    foreach $i (@thekeys) {
	if($firstlen < length($i)){
	    $firstlen = length($i);
	}
    }
    
    my $insttype;
    my $maxlen;

# Create inst_order so that we only print statistics about components
# that are actually used in the design.
    foreach $name (@print_order) {
	if($usageinfo{$name}) {
	    push(@inst_order,$name);
	}
    }

# Print header
    &print_dashes($firstlen,\@inst_order);
    printf("| %- ${firstlen}s ","Module");
    foreach $insttype (@inst_order) {
	printf("| % 6s ", $translation[$insttype]);
    }
    printf("|\n");
    &print_dashes($firstlen,\@inst_order);


# Print hierarchical statistics
    foreach $name (@thekeys) {
	printf("| %- ${firstlen}s ",$name);
	foreach $insttype (@inst_order) {
	    $maxlen = length($translation[$insttype]);
	    $maxlen = $maxlen < 6 ? 6 : $maxlen;
	    if($hierarchical_usageinfo{$name}{$insttype}) {
		printf("| % ${maxlen}d ",$hierarchical_usageinfo{$name}{$insttype});
	    }else {
		printf("| % ${maxlen}s "," ");
	    }
	}
	printf("|\n");
    }

# Print footer with total number of all components
    &print_dashes($firstlen,\@inst_order);

    printf("| %- ${firstlen}s ","Total");
    foreach $insttype (@inst_order) {
	$maxlen = length($translation[$insttype]);
	$maxlen = $maxlen < 6 ? 6 : $maxlen;
	if($usageinfo{$insttype}){
	    printf("| % ${maxlen}d ",$usageinfo{$insttype});
	}else{
	    printf("| % ${maxlen}s "," ");
	}
    }
    printf("|\n");

    &print_dashes($firstlen,\@inst_order);
}


######################################################################
# Main program starts here
######################################################################

printf('XDLAnalyze V1.1 by Andreas Ehliar <ehliar@isy.liu.se>'. "\n");

if(! $ARGV[0]){
    print STDERR "Usage: xdlanalyze.pl <design.xdl> [hierarchical levels]\n";
    exit 1;
}

if($ARGV[1]) {
    $hierarchical_level = $ARGV[1];
}

# If the input has a .ncd file extension it will be converted to an .xdl file
if( $ARGV[0] =~ /.ncd$/ ) {
    my $tempname;
    my $fh;

    printf("Calling xdl -ncd2xdl to convert .ncd file to .xdl file before running analyzer\n");

    # try new temporary filenames until we get one that didn't already exist as per
    # the perl cookbook
    do { $tempname = tmpnam() . ".xdl" }
        until $fh = IO::File->new($tempname, O_RDWR|O_CREAT|O_EXCL);
    
    # Call the xdl tool to convert the file...
    system ("xdl", "-ncd2xdl", $ARGV[0], $tempname) == 0 or die "Couldn't call xdl: $!";
    &analyze_file($tempname);

    unlink($tempname) or die "Couldn't unlink $tempname : $!";
    
}else {
    &analyze_file($ARGV[0]);
}


&print_stats;

exit 0;
