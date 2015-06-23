#!/usr/bin/perl
#######################################################################
# 
# This file is a part of the Rachael SPARC project accessible at
# https://www.rachaelsparc.org. Unless otherwise noted code is released
# under the Lesser GPL (LGPL) available at http://www.gnu.org.
#
# Copyright (c) 2005: 
#   Michael Cowell
#
# Rachael SPARC is based heavily upon the LEON SPARC microprocessor
# released by Gaisler Research, at http://www.gaisler.com, under the
# LGPL. Much of the architectural work on Rachael was done by g2
# Microsystems. Contact michael.cowell@g2microsystems.com for more
# information.
#
#######################################################################
# $Id: veristruct.pl,v 1.2 2008-10-10 21:09:26 julius Exp $
# $URL: $
# $Rev: $
# $Author: julius $
######################################################################
#
# This file is the main module of the Veristruct Perl program.
#
# Veristruct provides (some) struct support for the Verilog language
# by pre-processing Veristruct (.vs) files to produce IEEE1364.1995
# (Verilog 1995) compliant source code.
#
# All structs are defined in seperate (.struct) files, that use a
# syntax very similar to C. Please see attached documentation (in the
# doc folder) for more information.
#
######################################################################

use Verilog::Veristruct::Structlib;
use Verilog::Veristruct::File;

#
# Globals
#
$debug = 0;
$infile = '';
$outfile = '';
@libpaths;
$overwrite = '';
$makefile = 0;
$ignore = 0;

#
# Command line options processing
#
sub init()
{
    use Getopt::Long;
    my $help;
    GetOptions ("help" => \$help,
	        "debug" => \$debug,
		"write" => \$overwrite,
                "infile=s" => \$infile,
                "outfile=s" => \$outfile,
                "libpath|l=s" => \@libpaths,
	        "makefile" => \$makefile,
		"forget-unfound" => \$ignore) or usage();
    @libpaths = split(/,/,join(',',@libpaths));
    usage() if $help;
    if ((!($infile)) or (!($outfile))) {
	usage();
    } else {
	process();
    }
}

#
# Message about this program and how to use it
#
sub usage()
{
    print STDERR << "EOF";    

  Veristruct parses .struct and .vs files to create IEEE1364.1995
  (Verilog) compliant .v files.
	
    usage: $0 [-h -d -w -L path] -i file -o file
      
      -h, --help               : this (help) message
      -d, --debug              : print debugging messages to stderr
      -w, --write              : overwrite output file
      -i file, --infile=file   : .vs file containing veristruct
      -o file, --outfile=file  : .v file that will be written
      -L path, --libpath=path  : library path for .struct files
                                 Note: multiple paths may be specified 
      -m, --makefile           : Write a makefile to build a Verilog
                                 module from this Veristruct module.
			         Dependencies are detected and included.
				 The destination file is specified with
				 the normal -o option.
      -f, --forget-unfound     : forget (ignore) unfound modules instead
                                 of error-ing.
      
    example: $0 -d -i module.vs -o module.v

EOF
    exit;
}

sub process() {

    open($ifh, "<$infile") or die
	"Couldn't open $infile.";
    if (-e $outfile and !($overwrite)) {
	die "$outfile exists (and -w not specified). Not overwriting.";
    }
    $myfile = new Verilog::Veristruct::File;
    $myfile->load($ifh) or die
	"Couldn't load $infile.";
    # Add the current folder to libpaths
    push(@libpaths, ".");
    if ($makefile) {
	$myfile->generate_makefile($debug, $ignore, \@libpaths, $infile) or die
	    "Parsing of $infile failed";
    } else {
	$myfile->replace_structs($debug, $ignore, \@libpaths) or die
	    "Parsing of $infile failed.";
    }
    open($ofh, ">$outfile") or die
	"Couldn't open $outfile for writing.";
    print $ofh ${$myfile->{"buffer"}};

}

init();

