#!/usr/bin/perl
# Preprocessing of the spec file.
# So far the table with the instruction list is modified.
# Output is printed to stdout.

use warnings;
use strict;
use POSIX qw (ceil);

if (@ARGV != 1) {
    print "Usage: preprocess.pl infile ('-' for stdin)\n";
    exit 1;
}

my $infile = $ARGV[0];

if ($infile eq '-') {
    open(INPUT, '<-') or die $!;
} else {
    open(INPUT, '<', $infile) or die $!;
}

my @inst_table;
my $insts_per_col = 18;
my $inst_line = 0;
my $inst_header;
my $inst_footer;

while (<INPUT>) {
    if (/^\| Instruction mnemonic/../^\|==/) {
	chomp;
	if (/^\| Instruction mnemonic/) {
	    $inst_header = $_;
	    next;
	} elsif (/^\|==/) {
	    $inst_footer = $_;
	    next;
	}
	if ($inst_line < $insts_per_col) {
	    push @inst_table, $_;
	} else {
	    $inst_table[$inst_line % $insts_per_col] .= "\t" . $_;
	}
	$inst_line++;
    } else {
	if (@inst_table) {
	    # complete the rows that have their last column empty
	    for (my $i = $inst_line % $insts_per_col; $i < $insts_per_col; $i++) {
		$inst_table[$i] .= "\t|\t|";
	    }
	    my $cols = ceil($inst_line / $insts_per_col);
	    print $inst_header x $cols . "\n";
	    print join("\n", @inst_table) . "\n";
	    print $inst_footer . "\n";
	    @inst_table = ();
	}
	print $_;
    }
}
close INPUT or die $!;
