#!/usr/bin/perl -w
#
# ############################################################################
#
# vcd2vec.pl
#
# $Id: vcd2vec.pl 295 2009-04-01 19:32:48Z arniml $
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
# Converts a VCD-file to a vector file.
#
# Reads VCD from STDIN and writes the resulting vector stream to STDOUT.
# vcd2vec.pl -s <signals file> [-i] [-h]
#  -s : Name of the file containing the signals for vector output
#  -i : Read initial state from VCD (given with $dumpvars)
#  -h : Print this help
#


use strict;

use Getopt::Std;


my $time_unit = 'ns';

sub print_usage {
    print <<EOU;
Reads VCD from STDIN and writes the resulting vector stream to STDOUT.
Usage:
 vcd2vec.pl -s <signals file> [-i] [-h]
  -s : Name of the file containing the signals for vector output
  -i : Read initial state from VCD (given with \$dumpvars)
  -h : Print this help
EOU
}

sub print_index {
    my $index = shift;
    my ($tok, $desc);

    while (($tok, $desc) = each %{$index}) {
        print("Token $tok:\n");
        print("  $desc->{'name'}\n");
        print("  $desc->{'pos'}\n");
    }
}

sub dump_state {
    my ($state, $time, $dump_signals) = @_;
    my $signal;

    print("${time}>");
    foreach $signal (@{$dump_signals}) {
        if (exists($state->{$signal})) {
            print(" ".$state->{$signal});
        } else {
            print(STDERR "Error: Signal '$signal' not included in VCD!\n");
        }
    }
    print("\n");
}

sub read_scope {
    my $scope = shift;
    my $index = shift;
    my $pos   = shift;
    my ($token, $base, $extension);
    my $ipt;

    print("Processing scope '$scope'\n");

    while (<STDIN>) {
        last if (/^\$upscope/);

        last if (/^\$enddefinitions/);

        if (/^\$var +\S+ +\S+ +(\S+) +(\S+) +(([^\$]\S*)|\$end)/) {
            $token = $1;
            $base  = $2;

            $extension = defined($4) ? $4 : '';
            $extension =~ s/[\[\]]//g;

            $index->{$token} = {};
            $ipt = $index->{$token};
            $ipt->{'name'} = "$scope.$base$extension";
            $ipt->{'pos'}  = $$pos++;

            print("Appended ".$ipt->{'name'}."\n");
        }

        if (/^\$scope +\S+ +(\S+)/) {
            read_scope("$scope.$1", $index, $pos);
        }

        if (/^\$timescale/) {
            $_ = <STDIN>;
            if (/^\s*1(\S+)/) {
                $time_unit = $1;
            }
        }
    }
}

my %options;
my %index;
my %state;
my ($i, $time, $pos);
my $index;
my $token;
my ($ipt, $val);
my ($tok, $desc);
my $signal;
my $initial_states = 0;
local *SIGNALS_FILE;

my @dump_signals;

# process command line options
if (!getopts('s:ih', \%options)) {
    print_usage();
    exit(1);
}

if (exists($options{'h'})) {
    print_usage();
    exit(0);
}

if (exists($options{'i'})) {
    $initial_states = 1;
}

if (exists($options{'s'})) {
} else {
    print(STDERR "File with signal names is required!\n");
    print_usage();
    exit(1);
}


##############################################################################
# Read signals file
#
if (!open(SIGNALS_FILE, "<$options{'s'}")) {
    print(STDERR  "Cannot read signals file '$options{'s'}'!\n");
    exit(1);
}

@dump_signals = <SIGNALS_FILE>;
close(SIGNALS_FILE);
chomp(@dump_signals);


# parse header
$index = {};
$pos   = 0;
read_scope("", $index, \$pos);


if ($initial_states) {
    # read initial state
    while (<STDIN>) { last if (/^\$dumpvars/) }
    while (<STDIN>) {
        last if (/^\$end/);
        if (/^(.)(\S+)/) {
            $val   = $1;
            $token = $2;
            $state{$index->{$token}->{'name'}} = $val;
        }
    }
}

$time = '0';

print("time:");
foreach $signal (@dump_signals) {
    print(" $signal");
}
print("\n");

# now read all state changes
while (<STDIN>) {
    if (/^#(\d+)/) {
        if ($1 != 0) {
            # dump previous state
            dump_state(\%state, $time, \@dump_signals);
        }
        $time = $1;
        next;
    } else {
        if (/^(\S)(\S+)$/) {
            $val   = $1;
            $token = $2;
            $state{$index->{$token}->{'name'}} = $val;
        }

        if (/^(\S+) (\S+)$/) {
            $val   = $1;
            $token = $2;
            $state{$index->{$token}->{'name'}} = $val;
        }
    }

}

# final dump
dump_state(\%state, $time, \@dump_signals);

0;
