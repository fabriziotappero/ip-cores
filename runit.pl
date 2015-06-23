#!/perl/bin/perl
# runit.pl is a little perl script that complies a verilog testbed (for a z80
# processor and also assembles a test program - converts output to a form 
# compatable with the verilog $readmemh function.
#
# this is all pretty simple. But serves to document in one place the build 
# process.
if ($signo = system("asm\\as80 -l -x2 -h0 -s2 -m asm\\bjs80tst.asm"))
{ 
	die "assembler error = $signo";
}

# bjp   now gotta convert the hex file 
#
# An Intel HEX file is composed of any number of HEX records. Each record is made up of five fields that are arranged in the following format:  
# :llaaaatt[dd...]cc
# Each group of letters corresponds to a different field, and each letter represents a single hexadecimal digit. Each field is composed of at least two hexadecimal digits-which make up a byte-as described below: 
# : is the colon that starts every Intel HEX record. 
# ll is the record-length field that represents the number of data bytes (dd) in the record. 
# aaaa is the address field that represents the starting address for subsequent data in the record. 
# tt is the field that represents the HEX record type, which may be one of the following:
# 00 - data record
# 01 - end-of-file record
# 02 - extended segment address record
# 04 - extended linear address record 
# dd is a data field that represents one byte of data. A record may have multiple data bytes. The number of data bytes in the record must match the number specified by the ll field. 
# cc is the checksum field that represents the checksum of the record. The checksum is calculated by summing the values of all hexadecimal digit pairs in the record modulo 256 and taking the two's complement. 
# 
open(ASMDAT, "asm\\bjs80tst.hex"), or die "can't open bjs80tst.hex: $!\n";
open(VERDAT, ">readmem.txt"), or die "can't open readmem.txt: $!\n";
while ($line = <ASMDAT>) 
{
	#print $line;
	($ll, $aaaa, $tt, $dat) = unpack("x1 A2 A4 A2 A*", $line);
	if ($tt == "00") 
	{
                print VERDAT "\@$aaaa\n";
		for( $i = 0; $i<hex($ll); $i+=1)
		{
			$byte = substr($dat, $i*2, 2);
			print VERDAT  $byte, " ";
		}
		print VERDAT "\n";
	}
}
#
#
# now compile the verilog, start the verilog and get the waveform viewer going.
# this is all logically seperate from the assembly stuff....   so if time matters
# one could break this file up - or comment out the part not needed. 
#
if ($signo = system ("iverilog -c rtl\\files.txt"))
{ 
	die "iverilog error = $signo";
}

if ($signo = system ("vvp a.out"))
{ 
	die "vvp error = $signo";
}
if ($signo = system ("gtkwave  dump.vcd"))
{ 
	die "assembler error = $signo";
};