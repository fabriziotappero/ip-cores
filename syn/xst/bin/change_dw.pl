#! /usr/bin/perl
#
# File       : change_dw.pl
# Description: Changes values for the DW generic at declaration site.
#              To be used with the "hw_loops<num>_top.vhd" top-level file.
#              Resulting file is expected to be renamed to 
#              "hw_loops<num>_top_fix.vhd".
# Usage      : ./change_dw.pl <file.vhd> <dw>
#
# Author     : Nikolaos Kavvadias (c) 2010
#

open(FILE1,"<$ARGV[0]")|| die "## cannot open file $ARGV[0]\n";

$dw_ix  = 0;

while ($line = <FILE1>)
{
  if ($line =~ m/.*DW.*:.*integer.*8/)
  {
    if ($dw_ix < 1)
    {
      $line =~ s//    DW  : integer := $ARGV[1]/;
      $dw_ix = 1;
    }
  }
  print $line;
}
