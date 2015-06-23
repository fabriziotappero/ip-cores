#!/usr/bin/perl
# 

use Getopt::Std;

getopt( 'fwd' );

open( BIN_FILE, $opt_f ) or die "Can't open $opt_f!!!\n";


if( $opt_w  ) {
  print "WIDTH=$opt_w;\n";
}
else  {
  print "WIDTH=32;\n";
}
  
if( $opt_d  ) {
  print("DEPTH=$opt_d;\n");
}
else  {
  print("DEPTH=2048;\n");
}

print("CONTENT BEGIN\n");

$x = 0;
while ( read( BIN_FILE, $buf, 4 ) ) {
  $out = unpack( "H8", $buf);
#   print "$out\n";
  printf("\t%08x", $x);
  print " : $out;\n";
  $x++;
}

print("END;\n");
