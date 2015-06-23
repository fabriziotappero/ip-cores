#! /usr/bin/perl

# Author(s)  : Ke Xu
# Email	     : eexuke@yahoo.com
# Description: Convert binary .264 file to text format
# Usage      : bin2hex.pl xxx.264                
# Copyright (C) 2008 Ke Xu

open STDOUT,    ">akiyo300_1ref.txt" || die "Can't open output file:$!\n";  
if (open(BINFILE,"<".$ARGV[0]))
{
	binmode(BINFILE);
	$s = '';
	$i = 0;
	while (!eof(BINFILE))
	{
		if ($i >= 2)
		{
			printf "%s\n",$s;
			$s = '';
			$i = 0;
		}
		else
		{
			$i++;
			$s .= sprintf("%02X",ord(getc(BINFILE)));
		} 
	}
	###if last line of BINFILE is less than 16 byte
	if ($i < 2)
	{
		printf "%s",$s;
	}
	close (BINFILE); 
}
