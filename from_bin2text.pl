#!/bin/perl


$file=@ARGV[0];
$len=@ARGV[1];

if ((length($file)==0) || (length($len)==0))
  { 
   printf "\nInput parameters:\n from_bin2text.pl <binary_file_name> <number_of_bytes_in_outfile>\n";
   printf "Example: from_bin2text.pl bytesdata.bin 5000 >stimulus.txt\n\n";
   exit(0); 
  }

open(F,"$file");
binmode F;
@lines=<F>;
close(F);


$txt='';
$bytenum=1;
foreach(@lines) 
{ 
  $txt=$_; 
  for ($z=0;$z<length($txt);$z++)
  {
   $a=ord(substr($txt,$z,1));
   printf "$a\n";
   $bytenum++;
   if ($bytenum>$len) {exit(0);}
  }
}



sub hex2dec
{
 return sprintf("%d",hex($_[0]))."";
}

sub hex2bin
{
 return sprintf("%.4b",hex($_[0]))."";
}
sub dec2hex
{
 return sprintf("%.2x",$_[0])."";
}
