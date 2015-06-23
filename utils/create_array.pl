#!/usr/bin/perl
##############################################################################
# create_array.pl
# 
# Creates EDK input files needed to create an array of OpenFire processors.
#
# Stephen Douglas Craven
# modified 11/18/2005
# Virginia Tech
#
# WARNING!  This script may break with newer / older versions of the EDK.
# Works with 7.1.
#
##############################################################################

# Globals
use vars qw/ %opt /;

# Command line options processing
sub init()
{
    use Getopt::Std;
    my $opt_string = 'hn:m:p:';
    getopts( "$opt_string", \%opt ) or usage();
    usage() if ($opt{h} or !$opt{n} or ($opt{n} < 1));
}

# Message about this program and how to use it
sub usage()
{
    print STDERR << "EOF";

This program modifies an EDK MHS file instantiating and connecting
the specified number of OpenFires in an array controlled by the MicroBlaze 
master.  Currently only unidirectional ring networks are supported.

Also modifies a MSS file for the master MB.

usage: $0 [-h] -n # <-d> <-o filename>

 -h		     : this (help) message
 -n #	             : positive number of processors in the array (not counting master node)
 -m MB_instance_name : instance name of master MicroBlaze (default = microblaze_0)
 -p project_name     : name of project (default = system)

example: $0 -n 16 -m microblaze_0 -p system

EOF
exit(0);
}

#############################################
# Begin MHS file component declarations
#    This script works by adding FSL links
#    and OpenFires to existing MHS / MSS
#    files.
#############################################
$fsl_bus1 = "BEGIN fsl_v20
 PARAMETER INSTANCE = ";
$fsl_bus2 =" PARAMETER HW_VER = 2.00.a
 PARAMETER C_EXT_RESET_HIGH = 0
 PARAMETER C_FSL_DEPTH = 1
 PORT FSL_Clk = sys_clk_s
 PORT SYS_Rst = sys_rst_s
END
";

$openfire_instance1 = "BEGIN openfire_top_syn
 PARAMETER INSTANCE = ";
$openfire_instance2 = " BUS_INTERFACE SFSL = ";
$openfire_instance3 = " BUS_INTERFACE MFSL = ";
$openfire_instance4 = " PORT clock = sys_clk_s
 PORT reset = sys_rst_s
END
";


# Begin MSS file declarations
$mss_openfire = "

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER DRIVER_VER = 1.00.a
 PARAMETER HW_INSTANCE = openfire";

init();

# setup MHS filehandler
if($opt{p}) {
	$outputfile = $opt{p}.".mhs";
} else {
	$outputfile = "system.mhs";
}

# setup master MB name
if($opt{m}) {
	$master_mb = $opt{m};
} else {
	$master_mb = "microblaze_0";
}

# Open MHS file for appending first... write OpenFires and FSLs to end of file
open(mhs_file, ">>$outputfile") || die("Could not open file $outputfile!");

# Create Backup of file before we modify it
system("cp $outputfile create_array_bck.mhs");

# Add master Nodes's FSL buses
print mhs_file $fsl_bus1."fsl_MB_slave\n";
print mhs_file $fsl_bus2."\n";
print mhs_file $fsl_bus1."fsl_MB_master\n";
print mhs_file $fsl_bus2."\n";

# Loop over the processors
for($i = 0; $i < $opt{n}; $i++)
{
	$node_num = "openfire".$i;
	$node_num_prev = "openfire".($i-1);
	$fsl_master = "fsl_".$node_num."_master\n";
	$fsl_slave = "fsl_".$node_num_prev."_master\n";
	# Add each processor to the MHS
	print mhs_file $openfire_instance1.$node_num."\n";
	# Depending on the location of the processor in the ring network,
	#     connect its FSL links to different interfaces (OpenFire or MicroBlaze)
	
	# Both FSLs connect to Master
	if($opt{n} == 1) {
		print mhs_file $openfire_instance2."fsl_MB_master\n";
		print mhs_file $openfire_instance3."fsl_MB_slave\n";
		print mhs_file $openfire_instance4."\n";
	# No FSLs connect to master
	} elsif(($i != 0) & ($i != ($opt{n}-1))) {
		print mhs_file $openfire_instance2.$fsl_slave;
		print mhs_file $openfire_instance3.$fsl_master;
		print mhs_file $openfire_instance4."\n";
		print mhs_file $fsl_bus1.$fsl_master;
		print mhs_file $fsl_bus2."\n";
	# Slave FSL connects to Master
	} elsif($i == 0) {
		print mhs_file $openfire_instance2."fsl_MB_master\n";
		print mhs_file $openfire_instance3.$fsl_master;
		print mhs_file $openfire_instance4."\n";
		print mhs_file $fsl_bus1.$fsl_master;
		print mhs_file $fsl_bus2."\n";
	# Master FSL connects to Master
	} else {
		print mhs_file $openfire_instance2.$fsl_slave;
		print mhs_file $openfire_instance3."fsl_MB_slave\n";
		print mhs_file $openfire_instance4."\n";
	}
}
close(mhs_file);

# Must add FSL interfaces to master MB
# Open file again for reading
open(mhs_file, $outputfile) || die("Could not open file $outputfile!");

# hopefully read in entire file
@lines=<mhs_file>;

# go ahead and close the file
close(mhs_file);

$master_fsl_parameters = " PARAMETER C_FSL_LINKS = 1
 BUS_INTERFACE SFSL0 = fsl_MB_slave
 BUS_INTERFACE MFSL0 = fsl_MB_master
 ";

# search for master MB to add FSL interfaces to it
# This could be improved
$master_found = 0;
$complete = 0;
$output = "";
foreach $line (@lines)
{
	$_ = $line;
	if(/$master_mb/)
	{
		$master_found = 1;
		$output = $output.$line; 
	} elsif($master_found & /BUS_INTERFACE/)
	{
		$output = $output.$master_fsl_parameters.$line;
		$master_found = 0;
		$complete = 1;
	}else{
		$output = $output.$line;
	}
}
if(!$complete)
{
	die("Could not find the $master_mb instance!");
}

# Open file again for overwriting
open(mhs_file, ">$outputfile") || die("Could not open file $outputfile!");
# We overwrite the entire file with our modified system that includes FSL interfaces for the MB
print mhs_file $output;
close(mhs_file);

# find output MSS file
if($opt{p}) {
	$outputfile = $opt{p}.".mss";
} else {
	$outputfile = "system.mss";
}

# Create backup
system("cp $outputfile create_array_bck.mss");

# write OpenFire drivers to MSS file
open(mss_file, ">>$outputfile") || die("Could not open file $outputfile!");
print mss_file $mss_header;
for($i = 0; $i < $opt{n}; $i++)
{
	print mss_file $mss_openfire.$i."\n END\n";
}
close(mss_file);
exit;
