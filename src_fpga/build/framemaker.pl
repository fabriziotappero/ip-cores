#!/usr/local/bin/perl



open(INF, $ARGV[0]) || die("\nCan't open $ARGV[0] for reading: $!\n");
open(OUTF, ">temp_temp") || die("\nCan't open $ARGV[1] for writing: $!\n");

#open(OUTFINAL, ">$ARGV[1]") || die("\nCan't open $ARGV[1] for writing: $!\n");

binmode OUTF;
$frame_size = $ARGV[2]*$ARGV[3]/8*3;
$state = 0;
#read,ver,hor,data
$count = 0;
$frame = 0;
while ($temp=<INF>)
{
  
   
    if($state == 0)
    {
      chop($temp);
      $s = length($temp);
      $byteCount += $s/2;
      $addr = hex($temp);#pack("H$s", $temp);
      $state = 1;
    }
    elsif($state == 1)
    {
      $count = $count + 1;
      $s = length($temp);
      $byteCount += $s/2;
#      $addr = $addr/4;
     print "addr: $addr\n";
      @data[$addr] = $temp;
      $state = 0;
    
    if($count == $frame_size-1 ) 
    { 
      print "frame $frame $frame_size $count\n";
      $frame = $frame + 1;
      $count = 0;
      for($i=0;$i<$frame_size;$i=$i+1 ) 
      {
	#print " @data[$i]";
	$s = length(@data[$i]);
        if($s < 8)
	{
	    print "no data at $i\n";
	}
        print OUTF @data[$i];
      }
    }
  }   
}

close INF;
close OUTF;

`perl dehex.pl temp_temp $ARGV[1]`
