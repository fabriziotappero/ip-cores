#!/usr/bin/perl -w
print "\nMotorola S-record to rs232_syscon command translator.";
print "\nFilename to translate? ";
$filename = <STDIN>;
chomp ($filename);
print "\nReading file \"$filename\"\n";
open (SRECORDFILE,$filename) || 
  die "\nCan't open \"$filename\" for input.\n";

# Handle getting a new extension for the output filename
$i = index($filename,".");
   # If no period is found, simply add the extension to the end.
if ($i < 0) { $i = length($filename); }
substr($filename,$i,4) = ".232";

# Open the output file
open (OUTPUTFILE,">".$filename) || 
  die "\nCan't open \"$filename\" for output.\n";

$line_number = 0;
while ($line = <SRECORDFILE>) {
  # increment the line number counter
  $line_number += 1;
  # ignore lines that begin with semicolon
  if (index($line,";")==0) { next; }
  # Get the position of the start of data
  # (Usually there is a colon at the very start of the line...)
  $i = index($line,":");
  if ($i < 0) {
    print "\nError!  No colon found on line: $line_number";
    last;
    }
  # Get the length of the line
  $line_length = hex(substr($line,($i+1),2));
  if ($line_length == 0) {
    print "0";
    next;
    }
    
  # Extract the starting address
  $line_starting_address = hex(substr($line,($i+3),4));

  # Extract the data substring - length is in units of bytes,
  # but each character is 1/2 byte, so multiply by 2.
  $line_data = substr($line,($i+9),($line_length*2));
  
  # Send data characters to output file as rs232_syscon commands
  # increment by 2 in order to send 1 byte per command...
  for ($i=0;$i<($line_length*2);$i+=2) {
    $j = $line_starting_address + $i/2;
    $j = sprintf "%lx",$j;  # Convert address to hexadecimal
    $byte = substr($line_data,$i,2);
    print OUTPUTFILE "w $j $byte\n";
  }
  
# Verbose debug information...
#  print "\nline $line_number: starts at $line_starting_address ";
#  print "length is $line_length ";
#  print "data is $line_data ";
  # Print a little period for each line processed...
  # (to complement the 0 printed for zero length lines encountered.)
  print ".";
  }
  
#Close all open files
close (SRECORDFILE);
close (OUTPUTFILE);
