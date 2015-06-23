#!/usr/bin/perl -w
# //////////////////////////////////////////////////////////////////////
# ////                                                              ////
# //// bin2hex.pl                                                  ////
# ////                                                              ////
# ////                                                              ////
# //// Module Description:                                          ////
# ////
# //// To Do:                                                       ////
# //// 
# ////                                                              ////
# //// Author(s):                                                   ////
# //// - Steve Fielding, sfielding@base2designs.com                 ////
# ////                                                              ////
# //////////////////////////////////////////////////////////////////////
# ////                                                              ////
# //// Copyright (C) 2007 Steve Fielding                            ////
# ////                                                              ////
# //// This source file may be used and distributed without         ////
# //// restriction provided that this copyright statement is not    ////
# //// removed from the file and that any derivative work contains  ////
# //// the original copyright notice and the associated disclaimer. ////
# ////                                                              ////
# //// This source file is free software; you can redistribute it   ////
# //// and/or modify it under the terms of the GNU Lesser General   ////
# //// Public License as published by the Free Software Foundation; ////
# //// either version 2.1 of the License, or (at your option) any   ////
# //// later version.                                               ////
# ////                                                              ////
# //// This source is distributed in the hope that it will be       ////
# //// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
# //// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
# //// PURPOSE. See the GNU Lesser General Public License for more  ////
# //// details.                                                     ////
# ////                                                              ////
# //// You should have received a copy of the GNU Lesser General    ////
# //// Public License along with this source; if not, download it   ////
# //// from <http://www.base2designs.com/lgpl.shtml>                ////
# ////                                                              ////
# //////////////////////////////////////////////////////////////////////

use FileHandle;
use File::stat;
use strict;
use sigtrap;
use Getopt::Std;

my %options = ();
getopts( "i:o:",\%options );

my $outFile = new FileHandle;
my $inFile = new FileHandle;
my $outputFileName = "";    

my $inputFileName;

print("--- bin2hex ---\n");

# --- input file
if (defined $options{i} ) {
  $inputFileName = $options{i};
}
else {
  die("You must specify an input file. eg   perl bin2hex.pl -i myInputFile.obj\n");
}

# --- output file
if (defined $options{o} ) {
  $outputFileName = $options{o};
  $outFile->open(">$outputFileName" ) or print( "Cannot open $outputFileName for reading!\n" ) and return(0);
}
else {
  die("You must specify an output file. eg   perl bin2hex.pl -o myOutputFile.hex\n");
}


  $outFile->print(slurpFile($inputFileName));
  $outFile->close();


#---------------------------------- slurpFile -------------------------------------------#
sub slurpFile
{
  my $fileAsString = "";
  my $tmpStr;
  my $k;

  $/ = undef;
  my $filename = shift();
  my $read  = new FileHandle;    # The input file
  $read->open( $filename ) or print( "Cannot open $filename for reading!\n" ) and return(0);
  binmode($read);
  $tmpStr = unpack("H*", $read->getline() ); # Read in the entire file as a string, and convert to ASCII
  for( $k = 0; $k < length($tmpStr) - (length($tmpStr) % 8); $k += 8 )  { #format as one 32-bit long word per line
    $fileAsString .= substr($tmpStr, $k, 8) . "\n";
  }

  # append remainder bytes
  $fileAsString .= substr($tmpStr, length($tmpStr) - (length($tmpStr) % 8), length($tmpStr) % 8);

  # pad with zeroes  
  if ( (length($tmpStr) % 8) != 0) {
    for( $k = 0; $k < 8 - (length($tmpStr) % 8); $k += 1 )  { 
      $fileAsString .= "0";
    }
  }

  $fileAsString .= "\n";
  $read->close() or die( "Cannot close $_!\n" );
  return $fileAsString;
}


