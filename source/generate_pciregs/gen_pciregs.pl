#!/usr/bin/perl

my $TOTAL = 42;
my $START = 0x11;

%h2b = (0 => "0000", 1 => "0001", 2 => "0010", 3 => "0011",
4 => "0100", 5 => "0101", 6 => "0110", 7 => "0111",
8 => "1000", 9 => "1001", a => "1010", b => "1011",
c => "1100", d => "1101", e => "1110", f => "1111",
);


system ("cat pciregs.vhd.part1");

foreach $i ( 1 .. $TOTAL ) {
	my $end = ";";
	$end = "" if $i eq $TOTAL;
	print "\t\tjcarr$i" . "ID 		: std_logic_vector(31 downto 0)$end\n";
}

system ("cat pciregs.vhd.part2");

foreach $i ( 1 .. $TOTAL ) {
	my $end = ";";
	# $end = "" if $i eq $TOTAL;
	print "\tconstant JCARR$i" . "IDr 	: std_logic_vector(31 downto 0) := jcarr$i" . "ID$end\n";
}

system ("cat pciregs.vhd.part3");

foreach $i ( 1 .. $TOTAL ) {
	my $binary, $hex;
	$hex = sprintf("%03X", $START);
	($binary = $hex) =~ s/(.)/$h2b{lc $1}/g;
	my $out = substr $binary, -6;
	print "\t\t when b\"$out\" =>\n";
	my $end = ";";
	# $end = "" if $i eq $TOTAL;
	print "\t\t\t\t  dataout <= JCARR$i" . "IDr$end\n";
	++$START;
}

system ("cat pciregs.vhd.part4");

