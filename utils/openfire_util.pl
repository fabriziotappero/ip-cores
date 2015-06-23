#!/usr/bin/perl
############################################################
# openfire_util
#
# Provides compilation functions for OpenFire.
#
# Stephen Douglas Craven
# 1/17/2006
# Configurable Computing Lab
# Virginia Tech
############################################################

# Globals
use vars qw/ %opt /;

# Command line options processing
sub init()
{
    use Getopt::Std;
    my $opt_string = 'hcmd:f:a:p:n:';
    getopts( "$opt_string", \%opt ) or usage();
    usage() if ($opt{h} or !$opt{f} or ($opt{d} and !$opt{a}) or $opt{C});
}

# Message about this program and how to use it
sub usage()
{
    print STDERR << "EOF";

This program compiles a MicroBlze C program and converts the resulting
ELF file into a memory image (.ROM file) for use by openfire_sim and 
verilog simlulators.

NOTE: XMD must be installed and in the user's path.

usage: $0 [-h] -f file <-d data_file address> -p <XPS project directory>

 -h		    : this (help) message
 -d data	    : optional data file -- MUST be paired with -a flag
 -a address	    : optional hex address (0x####) for data file
 -f file	    : MicroBlaze C file
 -c                 : create a rom file (.rom) for openfire_sim and verilog sim
 -p directory       : XPS project directory: make -f system.make libs must be already run!
 -m                 : use hardware multiplier
 -n master_name     : name of master MicroBlaze (default: microblaze_0)

example: $0 -f file.c -d data.dat -a 0x1234

EOF
exit;
}

init();

# Fill in default values
if($opt{n}) {
	$microblaze_name = $opt{n};
} else {
	$microblaze_name = microblaze_0;
}

# Parse path to file to get filename
$_ = $opt{f};
@path = split(/\//);
@htap = reverse(@path);
$_ = $htap[0];
($filename, $extension) = split(/\./);
# Make sure its a C file first
usage() if ($extension ne "c");

# If file doesn't exist, raise error
unless (-e $opt{f}) {
	print STDERR $opt{f}." NOT Found!\n";
	exit;
}

# Create GCC command to compile C program
# Requires that libraries are previously compiled
$gcc_command = "mb-gcc ".$opt{f}." -O2 -o of_executable.elf \\\n";
$gcc_command = $gcc_command."  -I".$opt{p}."/".$microblaze_name."/include/ -I".$opt{p}."/code/ \\\n";
# If we have a HW multiplier, use it
if($opt{m}) {
	$gcc_command = $gcc_command."  -mno-xl-soft-mul \\\n";
}
$gcc_command = $gcc_command."  -L".$opt{p}."/".$microblaze_name."/lib/ -xl-mode-executable";

print $gcc_command."\n";
# Compile code
system($gcc_command);

# Make sure compilation succeeded
unless (-e "of_executable.elf") {
	print STDERR "of_executable.elf NOT Found! Compilation Failed!\n";
	exit;
}

# Stop here, unless user wants a ROM file as well for simulation
unless($opt{c}) {exit(0);}

####################################################################################
# A ROM file is a simple file showing the hex value of each memory location on 
#    a separate line.  This is useful for Verilog simulators, which can read
#    this format with a $readmemh.  The openfire_sim C simulator also reads
#    this format.
#
# Sample ROM file:
# A123B456
# C321D654
# and so on
####################################################################################

# If the user wants to add data to the ROM file, examine the file to determine size
if ($opt{d}) {
	if (-e $opt{d})
	{
		( $dev, $ino, $mode, $nlink,
		  $uid, $gid, $rdev, $size,
		  $atime, $mtime, $ctime,
		  $blksize, $blocks )       = stat($opt{d});
	} else {
		print STDERR "File ".$opt{d}." NOT Found!\n";
		exit;
	}
}

# We need the maximum memory size, so convert provided address from hex to decimal
#     and add the size of the data file (found above) to that
if ($opt{a}) {
	$max_mem = oct($opt{a}) + $size + 10;
} else { # no address / data file provided; base size of ROM file on executable
	( $dev, $ino, $mode, $nlink,
	  $uid, $gid, $rdev, $size,
	  $atime, $mtime, $ctime,
	  $blksize, $blocks )       = stat("of_executable.elf");
	  $max_mem = $size/2; # guestimate on program size based on ELF size
}

####################################################################################
# The ROM file is created by loading the ELF file into the XMD MicroBlaze simulator.
#    The memory of the simulator is then dumped into a text file.  This is sort of 
#    a hack, but it is much easier than parsing the ELF file myself -- I am certain
#    not to make mistakes about where text and data sections go.
####################################################################################
# Create a TCL script for XMD
open(tcl_file, ">tmp666.tcl");
print tcl_file "xconnect mb sim\n";
print tcl_file "xdownload 0 of_executable.elf\n";
print tcl_file "xdownload 0 -data ".$opt{d}." ".$opt{a}."\n" if $opt{d};
print tcl_file "set hope [xrmem 0 0 ".$max_mem."]\n";
print tcl_file "puts \$hope\n";
close(tcl_file);

# Execute the TCL script, capturing the output
$xmd_cmd = "xmd -tcl tmp666.tcl";
$xmd_output = `$xmd_cmd`;

# Parse the output to just capture the memory data
##################################################################
# WARNING! This is likely to change with different XMD versions! #
##################################################################
$flag = 0;
foreach $_ (split(/\n/, $xmd_output)){
        if ($flag){
                @output = split(/ /, $_);
        }
        if ( $_ =~/Setting PC/) {$flag = 1;}
}

# Open a file to write results
binmode rom_file;
open(rom_file, ">$filename.rom");

# Print memory contents in hex
$count = 0;
foreach $number (@output) {
        if ($number =~/\d/) {
                $hex[$count] = sprintf("%X", $number);
                if($number < 16) {
                        $hex[$count] = "0".$hex[$count];
                }
                $count++;
        }
        if ($count == 4) {
                $count = 0;
                printf rom_file $hex[0].$hex[1].$hex[2].$hex[3]."\n";
        }
}
close(rom_file);

# Remove the TCL script we created
system("rm tmp666.tcl");
exit;

# Stuff below is old for making COE coregen files
# Needs rework
if($opt{c} | $opt{C}) {
	open(coe_file, ">$filename.coe");
	open(rom_file, "$filename.rom");
	print coe_file "memory_initialization_radix=16;\n";
	$reset = 1;
	while(<rom_file>){
        	if ($reset > 0) {
                	chomp($_);
	                print coe_file "memory_initialization_vector= $_";
        	}
	        else    {
        	        chomp($_);
                	print coe_file ", ".$_;
	        }
        	$reset = 0;
	}
	print coe_file ";\n";
	close(coe_file);
	close(rom_file);
}

