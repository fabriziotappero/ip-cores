#!/usr/bin/perl -w
#
#
# USAGE: perl verilogCopy.pl [-i <inFile>] [-o <outFile>] 
#  -i <inFile> : Verilog input file
#  -0 <outFile> : Verilog output file
#  example: perl verilogCopy.pl -i inFileName -o outFileName
#
# Release notes:
# 0.1 initial release

use strict;
use sigtrap;
use Getopt::Std;
use constant TIMESTAMP => scalar localtime;

use Socket;

use FileHandle;
use File::stat;

my %options = ();
getopts( "o:i:t:",\%options );

my $gRespStr = "";
my @inFile;
my $filename;
my $myFileAsString;
our $outFile = new FileHandle;		
our $inFileSt;
our $outFileSt;
	

my $version =  "verilogCopy   ";

#print( "$version\n" );

# --- open Verilog input file
if (defined $options{i} ) {
  $inFileSt = stat($options{i}) or die "Can't stat $options{i}: $!";
  #print ("\n in File mtime = ");
  #print $inFileSt->mtime;
  #print ("\n");
}
else {
  print ("Input file name missing. Use -i <inputFileName> \n");
  exit 1;
}

# --- open verilog output file
if (defined $options{o} ) {
  $outFileSt = stat($options{o}) or die "Can't stat $options{o}: $!";
  #print ("\n out File mtime = ");
  #print $outFileSt->mtime;
  #print ("\n");
}
else {
  print ("Output file name missing. Use -o <outputFileName> \n");
  exit 1;
}


$/ = undef;

  if ($outFileSt->mtime < $inFileSt->mtime) {
    @inFile = glob( $options{i} );
    $outFile->open(">$options{o}") or die("Cannot open write file!\n");
    slurpFile(\$myFileAsString, $inFile[0] );
    parseInputFile(\$myFileAsString);
    patchFile(\$myFileAsString, $inFile[0] );
    $outFile->print("$myFileAsString");
    $outFile->close();
    print( "\"$options{i}\" has been processed and copied to \"$options{o}\".\n" );
  }
  else {
    print ("Input file older than output file. No update required\n");
  }



#---------------------------------- slurpFile -------------------------------------------#
sub slurpFile
{
	my $fileAsString = shift();
	my $filename = shift();
	my $read  = new FileHandle;		# The input file
	
	$read->open( $filename ) or print( "Cannot open $filename for reading!\n" ) and return(0);
     $$fileAsString = $read->getline();     # Read in the entire file as a list
	$read->close() or die( "Cannot close $_!\n" );
	return(1);
}


#---------------------------------- parseInputFile -------------------------------------------#
sub parseInputFile
{
  my $fileAsString = shift();

  $$fileAsString =~ s/! =/!=/gs;      #patch ActiveHDL 4.2 FSM2HDL bug
  $$fileAsString =~ s/ = / <= /gs;    #patch ActiveHDL 4.2 FSM2HDL bug
  $$fileAsString =~ s/\r//gs;         #delete DOS carriage returns
  $$fileAsString =~ s/\t/  /gs;       #replace tabs with two spaces


}

#---------------------------------- patchFile -------------------------------------------#
sub patchFile
{
  my $fileAsString = shift();
  my $filename = shift();

  if ($filename =~ /spiCtrl.v/) {
    unless(
      $$fileAsString =~ s/\(spiTransCtrl or rxDataRdy/\(spiTransCtrl or rxDataRdy or spiTransType/
    ) {print "-------- ERROR, patch failed \n"; exit;}
    print ("--Patched $filename\n");
  }
  if ($filename =~ /readWriteSDBlock.v/) {
    unless(
      $$fileAsString =~ s/\(blockAddr or sendCmdRdy/\(blockAddr or sendCmdRdy or respTout or respByte/
    ) {print "-------- ERROR, patch failed \n"; exit;}
    print ("--Patched $filename\n");
  }
  if ($filename =~ /tx_pkt_sched.v/) {
    unless(
      $$fileAsString =~ s/\(buffLoadGnt or buffUnLoadGnt/\(buffLoadGnt or buffUnLoadGnt or txBufferLoaded/
    ) {print "-------- ERROR, patch failed \n"; exit;}
    print ("--Patched $filename\n");
  }
}





