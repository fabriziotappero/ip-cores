#!/usr/local/bin/perl


$framenum = 0;

$counter=0;
$horizontal_pixels = 640;
$vertical_pixels = 480;

while(1)
{
  open(INFH, $ARGV[0]) || die("\nCan't open $ARGV[0] for reading: $!\n");

  open(OUTF, ">$ARGV[1].$framenum.bmp") || die("\nCan't open $ARGV[2].$framenum.bmp for writing: $!\n");

  binmode OUTF;
  $counter = 0;

  while ($temp=<INFH>) 
  {
      chop($temp);
      $s = length($temp);
      $byteCount += $s/2;
      print OUTF pack("H$s", $temp);
      $counter++;
      if($counter==54)
      {
  	last;
      }
  }


  $counter=0;
  $line_counter = 0;
  $s=1;

  while ($temp=<STDIN>) 
  {
    if($temp=~/RGB.*/ )
    {
	$counter++;
        $line_counter++;
	#//if($counter > 0)
	#//{
	    chomp($temp);
	    $tempr = $tempg = $tempb = $temp;
	    $tempr=~ s/[^0-9]+([0-9]+)[^0-9]+[0-9]+[^0-9]+[0-9]+.*/\1/;
	    $tempg=~ s/[^0-9]+[0-9]+[^0-9]+([0-9]+)[^0-9]+[0-9]+.*/\1/;
	    $tempb=~ s/[^0-9]+[0-9]+[^0-9]+[0-9]+[^0-9]+([0-9]+).*/\1/;
	        print OUTF pack("C$s", $tempb);
	        print OUTF pack("C$s", $tempg);
	        print OUTF pack("C$s", $tempr);
	#//}
	if($counter == $horizontal_pixels * $vertical_pixels)
	{
	    last;
	}
    }
   
    if($temp=~/RGH.*/ ) 
    {      
      while($line_counter < $horizontal_pixels)
      {        
         
        $line_counter++;
       	$counter++;
	$tempr = "0";
        $tempg = "0";
	$tempb = "0";   
	print OUTF pack("C$s", $tempr);
	print OUTF pack("C$s", $tempg);
	print OUTF pack("C$s", $tempb);
      }
      $line_counter = 0;
      if($counter == $horizontal_pixels * $vertical_pixels)
      {
	 last;
      }
    }
  }


  print "Finished frame $framenum\n";

  $framenum = $framenum + 1;
  if($counter < $horizontal_pixels * $vertical_pixels)
  {
      die;
  }
  if($framenum == 1000)
  {
      last;
  }
  close INFH;
  close OUTF;
}
