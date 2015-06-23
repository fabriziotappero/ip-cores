#!/usr/bin/perl -w
############################################################
# openfire_bram
#
# Initializes BRAMs with OpenFire code.
#
# Stephen Douglas Craven
# 1/17/2006
# Configurable Computing Lab
# Virginia Tech
#
# History
# 1/17/2006 -- Added support for variable MB names
############################################################

#
# Globals
#
use vars qw/ %opt /;

#
# Command line options processing
#
sub init()
{
    use Getopt::Std;
    my $opt_string = 'o:n:t:f:b:hx:p:';
    getopts( "$opt_string", \%opt ) or usage();
    usage() if ($opt{h});
}

#
# Message about this program and how to use it
#
sub usage()
{
    print STDERR << "EOF";

This program creates a BMM file from an NCD and uses this to read and 
write initial BRAM contents from a bitstream.

NOTE: XDL and DATA2MEM must be installed and in the user's path.

usage: $0 [-h] [-n NCD_FILE -o BMM_FILE] [-r ROM_FILE -b BITSTREAM]

 -h		      : this (help) message
 -n NCD_FILE	      : NCD_FILE containing placed BRAMs (default = implementation/system.ncd)
 -o BMM_FILE	      : BMM_FILE to create (default = implementation/openfire.bmm)
 -t top-level module  : name of the top-level OpenFire module (default = openfire)
 -f ELF_FILE          : ELF file to place in OpenFire memory (optional)
 -b BITSTREAM         : bitstream to update with BRAM contents (default = implementation/download.bit)
 -x XDL_FILE          : use specified XDL file (w/o flag, generates own from NCD_FILE)
 -p #                 : number of processors in design; named top-level_module0, top-level_module1, etc.
                           (default = 1)

example: $0 -n system.ncd -o system.bmm -f openfire.elf -b download.bit
example: $0 -o system.bmm -p 4 -t vtmb_

EOF
exit;
}

init();

# Fill in Default Values
if($opt{t}) {
	$top_level_name = $opt{t};
} else {
	$top_level_name = "openfire";
}
if($opt{n}) {
	$ncd_file = $opt{n};
} else {
	$ncd_file = "implementation/system.ncd";
}
if($opt{o}) {
	$output_bmm = $opt{o};
} else {
	$output_bmm = "implementation/openfire.bmm";
}
if($opt{b}) {
	$bitstream = $opt{b};
} else {
	$bitstream = "implementation/download.bit";
}
if($opt{p}) {
	$num_processors = $opt{p};
} else {
	$num_processors = 1;
}
# An XDL file is a textual representation of an NCD file
# An NCD file, after PAR< contains the physical locations of all components
# We need to know where PAR placed the OpenFire BRAMs, so we create and parse an XDL file
$xdl_file = $ncd_file;
$xdl_file =~ s/ncd/xdl/;
if($opt{x})
{
	# If an XDL file is specified, check if its there
	if(-r $opt{x})
	{
		$xdl_file = $opt{x};
	} else {
		print "ERROR! Specifiec XDL File $opt{x} cannot be read! Exiting \n";
		exit(0);
	}
} elsif (-r $xdl_file) # if no XDL file given, search for default one
{
} else {	# can't find an XDL file, so create one
	system("xdl -ncd2xdl $ncd_file $xdl_file");
}

# DATA2MEM needs a BMM File to describe the memory layout and BRAM physical locations
# We will make a BMM file using information from the XDL file
open(bmm_file, ">$output_bmm");

# Loop for each processor
for($count = 0; $count < $num_processors; $count++)
{
	$processor_name = $top_level_name.$count.'/';
	# Get BRAM locations by searching for all BRAMs linked to a specific OpenFire
	# These BRAMs then get sorted to (hopefully) insure that the program is loaded correctly
#	$brams = `grep inst $xdl_file | grep RAMB16 | grep $processor_name | sort +1 -n -t B`;
	$brams = `grep inst $xdl_file | grep RAMB16 | grep $processor_name | grep -v "i.*_ila\/" | sort +1 -n -t B`;

	$i = 0;
	# Loop over each BRAM discovered above
	foreach $_ (split(/\n/, $brams)){
		# We need the name of the BRAM and its location
		if(/inst \"($top_level_name[\w\d_\/]+)\".*RAMB16_([\w\d]+)/) {
			$mem[$i] = $1;
			$location[$i] = $2;
			$i++;
		}
	}
	$num_brams = $i;

	# Create BMM File for Data2mem
	$size = 2048 * $i -1;	# each BRAM is 2048 Bytes
	printf bmm_file ("ADDRESS_SPACE lmb_bram_$count RAMB16 [0x00000000:0x0000%X]\n", $size);
	print bmm_file "    BUS_BLOCK\n";

	$msb = 31;
	for ($i = $num_brams - 1; $i >= 0; $i--) {
		$lsb = $msb - 32 / $num_brams + 1;
		print bmm_file "    $mem[$i] [$msb:$lsb] PLACED = $location[$i];\n";
		$msb = $lsb - 1;
	}
	print bmm_file "    END_BUS_BLOCK;\n";
	print bmm_file "END_ADDRESS_SPACE;\n";
}

close(bmm_file);

# Test BMM File for Correctness
$error = `data2mem -bm $output_bmm`;
if(!$error and $opt{f}) {
    # Populate BRAM with ELF contents
    system("data2mem -bm ".$output_bmm." -bd ".$opt{f}." -bt ".$bitstream." -o b tmp666.bit");
    system("mv tmp666.bit ".$bitstream);
} elsif($error)  {
	print "$error";
    print "Error in BMM File!  Sorry!\n";
}
