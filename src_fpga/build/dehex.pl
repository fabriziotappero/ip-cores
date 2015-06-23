#!/usr/local/bin/perl



open(INF, $ARGV[0]) || die("\nCan't open $ARGV[0] for reading: $!\n");
open(OUTF, ">$ARGV[1]") || die("\nCan't open $ARGV[1] for writing: $!\n");

binmode OUTF;

while ($temp=<INF>) {
    chop($temp);
    $s = length($temp);
    $byteCount += $s/2;
    print OUTF pack("H$s", $temp);
}

close INF;
close OUTF;
