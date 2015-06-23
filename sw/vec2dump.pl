#!/usr/bin/perl -w
#
# ############################################################################
#
# vec2dump.pl
#
# $Id: vec2dump.pl 295 2009-04-01 19:32:48Z arniml $
#
# Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
#
# All rights reserved
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version. See also the file COPYING which
#  came with this application.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# ############################################################################
#
# Purpose:
# ========
#
# Converts a vector file into the dump format for dump_compare.
#
# A vector stream is read from STDIN and the resulting dump is written
# to STDOUT.
#


use strict;


sub bin2hex {
    my $string = shift;
    my ($bit, $hex);

    $hex = 0;
    foreach $bit (split(//, $string)) {
        $hex <<= 1;
        $hex |= $bit;
    }

    return(sprintf("%02X", $hex));
}

sub hex8 {
    my $uint = shift;

    if ($uint =~ /^b(.+)$/) {
        return(bin2hex($1));
    } else {
        return('??');
    }
}

sub hex16 {
    my $uint = shift;

    if ($uint =~ /^b(.+)(........)$/) {
        return(bin2hex($1).bin2hex($2));
    } else {
        return('????');
    }
}

sub dump_ram {
    my $ram = shift;
    my $elem;

    foreach $elem (@{$ram}) {
        print($elem.' ');
    }
}


my (@signals, %index, @vector);
my $i;
my $value;
my $line;
my $istrobe;
my @ram;


# initialize RAM
for ($i = 0; $i < 256; $i++) {
    $ram[$i] = '00';
}


# scan for signal names
while (<STDIN>) {
    if (/^(\S+):/) {
        chomp($_);
        @signals = split(/ +/);

        # remove time information
        shift(@signals);
        last;
    }
}

# build index
for ($i = 0; $i < scalar(@signals); $i++) {
    # strip off hierarchical path
    $signals[$i] =~ s/.*\.//;
    $index{$signals[$i]} = $i;
}

$istrobe = 0;
# read vectors
while (<STDIN>) {
    if (/^\d+> /) {
        chop($_);
        @vector = split(/ +/);

        # remove time information
        shift(@vector);

        # process write operation to RAM
        if ($vector[$index{'we_tmp'}] eq '1') {
            $ram[hex(hex8($vector[$index{'address_tmp[7:0]'}]))] = hex8($vector[$index{'data_tmp[7:0]'}]);
        }

        # find falling instruction strobe
        if ($istrobe == 0) {
            $istrobe = $vector[0];
            next;
        } else {
            $istrobe = $vector[0];
            if ($vector[0] == 0) {
                # falling edge detected
            } else {
                next;
            }
        }

        # process each signal
        for ($i = 1; $i < scalar(@vector); $i++) {
            $_    = $signals[$i];
            $line = '';

          SWITCH: {
              if (/^program_counter/) { print(hex16($vector[$i]).' '); last; }
              if (/^accumulator/)     { print(hex8($vector[$i]).' ');  last; }
              if (/^sp/)              { print(hex8($vector[$i]).' ');  last; }
              if (/^psw/)             { print(hex8($vector[$i]).' ');  last; }
              if (/^bus/)             { print(hex8($vector[$i]).' ');  last; }
              if (/^f1/)              { print($vector[$i].' ');        last; }
              if (/^p1/)              { print(hex8($vector[$i]).' ');  last; }
              if (/^p2/)              { print(hex8($vector[$i]).' ');  last; }
              if (/^mb/)              { print($vector[$i].' ');        last; }
              if (/^we_tmp/)          { dump_ram(\@ram);               last; }
          }
        }
        print("\n");
    }
}
