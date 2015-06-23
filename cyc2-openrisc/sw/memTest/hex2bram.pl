#!/usr/bin/perl -w
# //////////////////////////////////////////////////////////////////////
# ////                                                              ////
# //// hex2bram.pl                                                  ////
# ////                                                              ////
# ////                                                              ////
# //// Module Description:                                          ////
# //// Parses a plain ASCII hex file, and
# //// generates init files and Intel hex files suitable for use
# //// with Xilinx and Altera FPGAs
# //// Note that the Xilinx init file must be included between the
# //// module enmodule keywords
# //// usage example:   perl hex2bram -i myInputFile.hex
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


# You will need to change this constant to match the size of your Xilinx Block RAM.
# BRAM_SIZE does not need to be modified if you are using Altera parts. 
use constant BRAM_SIZE => 4096;
# Altera total RAM size is passed as an arguement.
# Xilinx total RAM size is assumed to be 0x2000 bytes. Code must be modified to support different RAM sizes

use FileHandle;
use File::stat;
use strict;
use sigtrap;
use Getopt::Std;

my %options = ();
getopts( "i:o:s:",\%options );

my $outFile = new FileHandle;
my $outFileName = "";    
my @fileAsList;
my $i;
my $myItem;
my $TOTAL_RAM_SIZE;

my $inputFileName;
my $BRAM7 = "";
my $BRAM6 = "";
my $BRAM5 = "";
my $BRAM4 = "";
my $BRAM3 = "";
my $BRAM2 = "";
my $BRAM1 = "";
my $BRAM0 = "";
my $BRAM32Bit = "";
my $BRAM8Bit = "";

print("--- hex2bram ---\n");

# --- input file
if (defined $options{i} ) {
  $inputFileName = $options{i};
  $outFileName = $inputFileName;
  $outFileName =~ s/\.hex//;
  $outFileName = $outFileName . ".init";
  $outFile->open(">$outFileName") or die("Cannot open output file!\n");
}
else {
  die("You must specify an input file. eg   perl hex2bram.pl -i myInputFile.hex\n");
}

if (defined $options{s} ) {
  $TOTAL_RAM_SIZE = hex( $options{s});
  printf("TOTAL_RAM_SIZE = 0x%x bytes\n", $TOTAL_RAM_SIZE);
}
else {
  die("You must specify the block RAM size in hex bytes. eg   perl hex2bram.pl -s 1000\n");
}

getInputFile(\@fileAsList, $inputFileName);
for( $i = 0; $i < @fileAsList + 0; $i += 1 ) { #for every line in hex file
  $myItem = (@fileAsList)[$i];                      #get the line data
  $myItem =~ s/\n//g;                               #discard carriage return
  $myItem =~ s/\s+$//;                              #discard trailing space
  $BRAM7 .= substr($myItem, 0, 1);
  $BRAM6 .= substr($myItem, 1, 1);
  $BRAM5 .= substr($myItem, 2, 1);
  $BRAM4 .= substr($myItem, 3, 1);
  $BRAM3 .= substr($myItem, 4, 1);
  $BRAM2 .= substr($myItem, 5, 1);
  $BRAM1 .= substr($myItem, 6, 1);
  $BRAM0 .= substr($myItem, 7, 1);
  $BRAM32Bit .= substr($myItem, 0, 8);
  $BRAM8Bit .= substr($myItem, 0, 2). "\n" . 
               substr($myItem, 2, 2). "\n" . 
               substr($myItem, 4, 2). "\n" . 
               substr($myItem, 6, 2). "\n"; 
 }

#printf ("Splitting hex file into 8 blocks of 0x%0x nibbles\n", length($BRAM7));

printf("Writing \"%s\"\n", $outFileName);
genInit($BRAM7, "block_ram_31");
genInit($BRAM6, "block_ram_30");
genInit($BRAM5, "block_ram_21");
genInit($BRAM4, "block_ram_20");
genInit($BRAM3, "block_ram_11");
genInit($BRAM2, "block_ram_10");
genInit($BRAM1, "block_ram_01");
genInit($BRAM0, "block_ram_00");
$outFile->close();

genIntelHex($BRAM32Bit);
gen8BitHex($BRAM8Bit);
print("hex2bram done\n");

#---------------------------------- genInit -------------------------------------------#
sub genInit
{
my $myBRAM = shift();
my $BRAMname = shift();

my $initBlock;
my $initBlockNum;
my $initBlockRev;

  #printf ("myBRAM length = 0x%0x \n", length($myBRAM));
  my $padLength = BRAM_SIZE - length($myBRAM);
  #printf ("myBRAM pad length = 0x%0x \n", $padLength);
  #pad the string so that we have exactly 16384 bits or 2048 bytes per BRAM
  for ($i = 0; $i < $padLength; $i += 1) {
    $myBRAM .= "0";
  }
  #printf ("myBRAM length = 0x%0x \n", length($myBRAM));


  $outFile->printf("// ----------------------- %s -------------------------\n", $BRAMname);
  for ($initBlockNum = 0; $initBlockNum < (BRAM_SIZE / 64); $initBlockNum += 1) {
    #print ("initBlockNum = $initBlockNum\n");
    $initBlock = substr($myBRAM, ($initBlockNum * 64), 64);
    $initBlockRev = "";
    for ($i = 63; $i >= 0; $i = $i -1) {
      $initBlockRev .= substr ($initBlock, $i, 1);
    }
    $outFile->printf("//synthesis attribute INIT_%02X %s \"", $initBlockNum, $BRAMname);
    $outFile->print("$initBlockRev\"\n");
  }
  $outFile->print("\n");
}


#---------------------------------- genIntelHex -------------------------------------------#
sub genIntelHex
{
my $myBRAM = shift();

my $checkSum;
my $padLength;
my $iHexFileName = "";
my $iHexFile = new FileHandle;
my $intelHexRec;
my $RecByte;
my $i;
my $j;

  $iHexFileName = $inputFileName;
  $iHexFileName =~ s/\.hex//;
  $iHexFileName = $iHexFileName . ".intel.hex";
  $iHexFile->open(">$iHexFileName") or die("Cannot open hex output file!\n");
  printf("Writing \"%s\"\n", $iHexFileName);

  $padLength = ($TOTAL_RAM_SIZE * 2) - length($myBRAM);
  for ($i = 0; $i < $padLength; $i += 1) {
    $myBRAM .= "0";
  }

  for ($i = 0; $i < length($myBRAM); $i += 8) {
    # Record = :, recLength, address, recType, data, checksum
    $intelHexRec = sprintf("04%04X00%s", $i/8, substr($myBRAM, $i, 8) );
    $intelHexRec = uc($intelHexRec);
    $checkSum = 0;
    for( $j = 0; $j < length($intelHexRec); $j += 2 ) {
      $RecByte = hex(substr($intelHexRec, $j, 2));
      $checkSum = ($checkSum + $RecByte) % 0x100;
    }
    $checkSum = $checkSum ^ 0xff;
    $checkSum = $checkSum + 1;
    $checkSum = $checkSum & 0xff;

    $iHexFile->printf(":%s%02X\n", $intelHexRec, $checkSum);
  }
  $iHexFile->print(":00000001FF\n\n"); #end of file
  $iHexFile->close();
}


#---------------------------------- gen8BitHex -------------------------------------------#
sub gen8BitHex
{
my $myBRAM = shift();

my $checkSum;
my $padLength;
my $i8HexFileName = "";
my $iHexFile = new FileHandle;
my $intelHexRec;
my $RecByte;
my $i;
my $j;

  $i8HexFileName = $inputFileName;
  $i8HexFileName =~ s/\.hex//;
  $i8HexFileName = $i8HexFileName . ".8bit.hex";
  $iHexFile->open(">$i8HexFileName") or die("Cannot open hex output file!\n");
  printf("Writing \"%s\"\n", $i8HexFileName);


  $iHexFile->print("$myBRAM\n\n"); 
  $iHexFile->close();
}


#---------------------------------- getInputFile -------------------------------------------#
sub getInputFile
{
my $inList = shift();
my $inputFileName = shift();
my $myFileAsString;
my $remainder;
my $i;

  $/ = undef;
  #check to see if input file exists
  if (!(-e $inputFileName) || !(-r $inputFileName)) { 
    print( "ERROR: Cannot open $inputFileName for reading!\n" );
    die "Exiting fpgaConfig\n";
  }
  print("Reading \"$inputFileName\"\n");
  $myFileAsString = slurpFile($inputFileName);
  printf("\"$inputFileName\" size is 0x%0x bytes\n", length($myFileAsString));
  @$inList = split /\n/, $myFileAsString;	              
}

#---------------------------------- slurpFile -------------------------------------------#
sub slurpFile
{
  my $fileAsString;

  my $filename = shift();
  my $read  = new FileHandle;    # The input file
  $read->open( $filename ) or print( "Cannot open $filename for reading!\n" ) and return(0);
  $fileAsString = $read->getline();            # Read in the entire file as a string
  $read->close() or die( "Cannot close $_!\n" );
  return $fileAsString;
}


