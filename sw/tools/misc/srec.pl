#!/usr/bin/perl -w
use strict;
use IO::File;

use Getopt::Long;
my $outfile="out";
my $lenlen=2;
my $dowordswap= 0;
my $maxgap= 1;
GetOptions(
    "o=s" => \$outfile,
    "l=i" => \$lenlen,
    "m=s" => sub { $maxgap= eval($_[1]) },
    "w" => \$dowordswap) 
    or die "Usage: srec [-o=OUTPREFIX] [-l={4|2}] [-w {swap}] [-m=MAXGAP]\n";
my %data;

# s-records have the following format:
#   "S" + 1 byte  type
#   2 hex digits :  length  ( of rest of line - incl address and checksum )
#   4,6,8 hex digits address ( for type 1, 2, 3 )
#   hex data [ 0..64 bytes ]
#   checksum [ 1 byte ]   such that unpack('%8C*', pack('H*', $line))==0xff
#            ( or checksum=0xff-sum(otherbytes)
#
#
#   type S0 : version  : char mname[10], byte ver, byte rev, char description[18]
#           or usually : 00 00 + 'HDR'
#   type S1 : 2 byte address + data
#   type S2 : 3 byte address + data
#   type S3 : 4 byte address + data
#   type S5 : 2 byte count of S1, S2, S3 records transmitted
#   type S7 : 4 byte entrypoint address
#   type S8 : 3 byte entrypoint address
#   type S9 : 2 byte entrypoint address

while (<>) {
    my $type= hex(substr($_, 1,1));
    my $length= hex(substr($_,2,$lenlen));

    my $adrlen= $type eq "1" ? 4 : $type eq "2" ? 6 :  $type eq "3" ? 8 : 0;
    next if (!$adrlen);
    my $address= hex(substr($_,2+$lenlen,$adrlen));
    my $data= pack("H*", substr($_,2+$lenlen+$adrlen, 2*$length-$adrlen-2));
    if ($dowordswap) {
        $data= pack('v*', unpack('n*',$data));
    }

    $data{$address}= $data;
}

#     |---------|...|
#                  |-----|
#
my @addrs= sort { $a <=> $b } keys %data;
my $fh;
for (0..$#addrs) {
    my $startcur= $addrs[$_];

    if ($_>0) {
        my $startlast= $addrs[$_-1];
        my $endlast= length($data{$startlast})+ $startlast;

        if ($endlast +$maxgap <= $startcur) {
            printf("  %08lx-%08lx .. gap .. %08lx\n", $startlast, $endlast, $startcur);

            $fh->close();
            undef $fh;
        }
        elsif ($endlast < $startcur ) {
            $fh->seek($startcur-$endlast, SEEK_CUR);
        }
        elsif ($endlast > $startcur) {
            printf("WARNING: overlap found: %08lx-%08lx ~ %08lx\n", $startlast, $endlast, $startcur);
            $fh->close();
            undef $fh;
        }
    }

    if (!$fh) {
        $fh= IO::File->new(sprintf("%s-%08lx.bin", $outfile, $startcur), "w");
        binmode($fh);
    }
    $fh->print($data{$startcur});
}
$fh->close();
#print map { $data{$_} } sort keys %data;

