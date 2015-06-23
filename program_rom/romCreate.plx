# programmer for 8-bit pipelined processor
# Mahesh Sukhdeo Palve
# 09042014
# !/usr/bin/perl
use warnings;
# use strict;

my $file_asm = '> C:\asm.txt';
open FILE_ASM, $file_asm or die " PROBLEM READING FILE : $! \n";


my $file_rom = '> C:\rom.v';
open FILE_V, $file_rom or die "PROBLEM READING FILE : $! \n";


print ("\n\nLast modified by : Mahesh Sukhdeo Palve");
print (" \n\n8-bit Pipeline Processor");
print (" \n\n for Open Cores (opencores.org)");
print ("\n\n------------------------------------------------");
print ("\n\n------------------------------------------------");
print ("\n\n------------------------------------------------");
print ("\n\n\t\tPROGRAMMER . . .\n\n");
print ("\n\n------------------------------------------------");
print ("\n\n------------------------------------------------");
print ("\n\n------------------------------------------------");

print ("\nStart entering instructions-\n");

#	take instruction?

my $inst = 0;
my $addr = 0;

			
			print FILE_V "`include \"defines.v\"\n`include \"timescale.v\"\n\n";
			print FILE_V "\tmodule\trom (clk, addr, code);\n";
			print FILE_V "\t\tinput clk;\n\t\tinput [`instAddrLen-1:0] addr; \n\t\t output [`instLen-1:0] code;\n\n";
			print FILE_V "\t\treg [`instLen-1:0] code;";
			print FILE_V "\n\n\n\t\t\talways @ (posedge clk)\n\t\t\tbegin\n\n";
			print FILE_V "\t\t\t case (addr)";


while ($inst ne END)
{
	print "\nmnemonic :\t";
	$inst = <STDIN>;
	chop ($inst);
	
	
	my $opcode = getOpcode($inst);
	# print "\nopcode for $inst is $opcode\n";
	
	my $field = getField($inst);
	# print "\nfield for $inst is $field\n";
	
	my $instruction = $opcode.$field;
	print "\n The instruction at address $addr is $instruction\n\n";
	
	my $zero = 0;
	
	print FILE_ASM $inst."\t\t".$field."\n";
	
	print FILE_V "\n\t\t\t\t$addr\t:\tcode = 15'b$instruction;";
	
	$addr = $addr + 1;
}	

	print FILE_V "\n\n\t\t\tdefault\t:\tcode = 15'b111111111111111;";
	print FILE_V "\n\t\tendcase\nend\n\nendmodule\n";





##############
# getOpcode

sub getOpcode{

my $temp;
my $zero = 0;
my $opcod;
use Switch;

switch ($inst) {

			case END		{ $temp = 0;		$opcod = $temp.$temp.$temp.$temp.$temp;};
			case JMP		{ $temp = 1;		$opcod = $zero.$zero.$zero.$zero.$temp;};
			case LD			{ $temp = 10;		$opcod = $zero.$zero.$zero.$temp;};
			case LDi		{ $temp = 11;		$opcod = $zero.$zero.$zero.$temp;};
			case ST			{ $temp = 100;		$opcod = $zero.$zero.$temp;};
			case ADD		{ $temp = 101;		$opcod = $zero.$zero.$temp;};
			case SUB		{ $temp = 110;		$opcod = $zero.$zero.$temp;};
			case MUL		{ $temp = 111;		$opcod = $zero.$zero.$temp;};
			case DIV		{ $temp = 1000;		$opcod = $zero.$temp;};
			case AND		{ $temp = 1001;		$opcod = $zero.$temp;};
			case OR			{ $temp = 1010;		$opcod = $zero.$temp;};
			case XOR		{ $temp = 1011;		$opcod = $zero.$temp;};
			case GT			{ $temp = 1100;		$opcod = $zero.$temp;};
			case GE			{ $temp = 1101;		$opcod = $zero.$temp;};
			case EQ			{ $temp = 1110;		$opcod = $zero.$temp;};
			case LE			{ $temp = 1111;		$opcod = $zero.$temp;};
			case LT			{ $opcod = 10000;};
			case PRE		{ $opcod = 10001;};
			case ETY		{ $opcod = 10010;};
			case RST		{ $opcod = 10011;};
			case LdTC		{ $opcod = 10100;};
			case LdACC		{ $opcod = 10101;};
			case UARTrd		{ $opcod = 10110;};
			case UARTwr		{ $opcod = 10111;};
			case UARTstat	{ $opcod = 11000;};
			case SPIxFER	{ $opcod = 11001;};
			case SPIstat	{ $opcod = 11010;};
			case SPIwBUF	{ $opcod = 11011;};
			case SPIrBUF	{ $opcod = 11100;}
			else			{print " Inserted NOP!";	$opcod = 11111;};
		}
		
	return $opcod;

}



##################
#	getField

sub getField{

my $fld = 0;
use Switch;
my $zero = 0;
my $tmp;
my $response = 0;

my $negate = 0;
my $iomem = 0;
my $iomemaddr = 0;

	switch ($inst){
	
	
		case END{
					print "\nis start address 0? Y or N\t";
					$response = <STDIN>;	chop($response);
					if ($response eq Y){
						$tmp = $zero.$zero.$zero.$zero.$zero.$zero.$zero.$zero.$zero.$zero;
						}
					else{
						print "\nstart address (10 bit) :\t";
						$tmp = <STDIN>;
						chop($tmp);
						}
					$fld = $tmp;
					};
		
		case JMP {
					print "\n Jump to address :\t";
					$fld = <STDIN>;
					chop($fld);
					};
					
		case LD	{
				$fld = sub1();
				};
				
					
		case LDi	{
					print "\nImmediate Data (8-bit):\t";
					$temp = <STDIN>;	chop($temp);
					$fld = $zero.$zero.$temp;
					}
					
		case ST		{
				$fld = sub1();
				};
		case ADD	{
				$fld = sub1();
				};
		case SUB	{
				$fld = sub1();
				};
		case MUL	{
				$fld = sub1();
				};
		case DIV	{
				$fld = sub1();
				};
		case AND	{
				$fld = sub1();
				};
		case OR		{
				$fld = sub1();
				};
		case XOR	{
				$fld = sub1();
				};
		case GT		{
				$fld = sub1();
				};
		case GE		{
				$fld = sub1();
				};
		case EQ		{
				$fld = sub1();
				};
		case LE		{
				$fld = sub1();
				};
		case LT		{
				$fld = sub1();
				};
		
		
		case PRE	{
						my $addr = sub2(); my $zero = 0;
						$fld = $zero.$zero.$zero.$zero.$zero.$zero.$addr;
				};
		case ETY	{
						print "\nTimer or Counter Type :\t 00 = on-delayTimer, 01 = off-delayTimer, 10 = retOn-delayTimer\n\t\t\t01 = up-counter, 10 = down-counter\n\t\t";
						my $resp2 = <STDIN>;	chop($resp2);
						my $addr = sub2();		my $zero = 0;
						
						$fld = $zero.$zero.$zero.$zero.$resp2.$addr;
				};
		case RST	{
						my $zero = 0;
						my $addr = sub2();
						$fld = $zero.$zero.$zero.$zero.$zero.$zero.$addr;
				};
		case LdTC	{
						my $addr = sub2();		my $zero = 0;
						$fld = $zero.$zero.$zero.$zero.$zero.$zero.$addr;
				};
		case LdACC	{
						my $addr = sub2();		my $zero = 0;
						$fld = $zero.$zero.$zero.$zero.$zero.$zero.$addr;
				};
		
		case UARTrd	{
						my $zero = 0;
						$fld = $zero.$zero.$zero.$zero.$zero.$zero.$zero.$zero.$zero.$zero;
				};
		case UARTwr	{
						my $zero = 0;
						$fld = $zero.$zero.$zero.$zero.$zero.$zero.$zero.$zero.$zero.$zero;
				};
		case UARTstat{
						my $zero = 0;
						$fld = $zero.$zero.$zero.$zero.$zero.$zero.$zero.$zero.$zero.$zero;
				};
				
		case SPIxFER{
						print "\nEnable (1) or disable (0)?\t";
						my $resp = <STDIN>;		chop($resp);
						print "\nShift (1) or Stop shift (0)?\t";
						my $resp2 = <STDIN>;		chop($resp2);
						my $zero = 0;
						
						$fld = $zero.$zero.$resp.$zero.$zero.$zero.$zero.$zero.$zero.$resp2;
				}
		case SPIstat{
						my $zero = 0;
						$fld = $zero.$zero.$zero.$zero.$zero.$zero.$zero.$zero.$zero.$zero;
				};
		case SPIrBUF{
						my $zero = 0;
						$fld = $zero.$zero.$zero.$zero.$zero.$zero.$zero.$zero.$zero.$zero;
				};
		case SPIwBUF{
						my $zero = 0;
						$fld = $zero.$zero.$zero.$zero.$zero.$zero.$zero.$zero.$zero.$zero;
				}
		
		else	{
				$fld = 1111111111;
				};
					
		}
		
	return $fld;
	
}


sub	sub1{
					print "\nNegate? Y or N\t";
					$response = <STDIN>;	chop($response);
					if ($response eq Y){	$negate = 1;}
					else {$negate = 0};
					
					print "\nInput (i) / Output (o) / bitRAM (b) / ByteRAM (B)?\t";
					my $select = <STDIN>;	chop($select);
					if ($select eq i){
										my $zero = 0;	$iomem = $zero.$zero;
										print "\ninput address :\t";
										$iomemaddr = <STDIN>;	chop($iomemaddr);
										}
					if ($select eq o){
										$temp = 1;	$zero = 0;
										$iomem = $zero.$temp;
										print "\noutput address :\t";
										$iomemaddr = <STDIN>;	chop($iomemaddr);
										}
					if ($select eq b){
										$iomem = 10;
										print "\nbit RAM address :\t";
										$iomemaddr = <STDIN>;	chop($iomemaddr);
										}
					if ($select eq B){
										$iomem = 11;
										print "\nByte RAM address :\t";
										$iomemaddr = <STDIN>;	chop($iomemaddr);
										}
					$fld = $negate.$iomem.$iomemaddr;
					return $fld;
}



sub sub2 {

				print "\nEnter Timer/Counter Address (4-bit):\t";
				my $addrs = <STDIN>;
				chop ($addrs);
				return $addrs;
}