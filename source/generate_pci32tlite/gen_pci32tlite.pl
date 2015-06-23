#!/usr/bin/perl
#

$TOTAL = 42;

system ("cat pci32tlite.vhd.part1");

foreach $i ( 1 .. $TOTAL ) {
	my $j = 12345670 + $i;
	my $end = ";";
	$end = "" if $i eq $TOTAL;
	print "\t\tjcarr$i" . "ID 		: std_logic_vector(31 downto 0) := x\"$j\"$end\n";
}

system ("cat pci32tlite.vhd.part2");

foreach $i ( 1 .. $TOTAL ) {
	my $end = ";";
	$end = "" if $i eq $TOTAL;
	print "\t\tjcarr$i" . "ID 	: std_logic_vector(31 downto 0)$end\n";
}

system ("cat pci32tlite.vhd.part3");

foreach $i ( 1 .. $TOTAL ) {
	my $end = ",";
	$end = "" if $i eq $TOTAL;
	print "\t\tjcarr$i" . "ID 	=> jcarr$i" . "ID$end\n";
}

system ("cat pci32tlite.vhd.part4");
