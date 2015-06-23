#!/usr/local/bin/perl

$outfilename = $ARGV[0];
$outfilename =~ s/\..*/\.hex/;

open(INF, $ARGV[0]) || die("\nCan't open $ARGV[0] for reading: $!\n");
open(OUTF, ">$outfilename") || die("\nCan't open $outfilename for writing: $!\n");

binmode INF;

$size = -s INF;

print "$size\n";

for($i=0; $i<$size; $i++)
{
    read (INF, $buffer, 1);
    $hex = unpack("H*",$buffer);
    print OUTF "$hex\n";
}
