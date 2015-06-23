#fill this in at some point

#build the code.

`cp ../build/Makefile ./`;
$str = `ls`;
print $str;
# build the test executable.
`make && bsc -sim -e mkTH *.ba`;

# build the golden decoder
`cd ./decoder/ldecod && make`;

@h264files = `ls ./h264`;

foreach(@h264files)
{
   chomp($_);
 
  print $_; 
  print " ";
  `cp ./h264/$_  input.264`;
  system("wc input.264 | awk \'{printf(\"%08x\\n%08x\\n%08x\\n%08x\\n\", \$3, \$3, \$3, \$3)}\' > input_size.hex");
  `perl hexfilegen.pl input.264`;
  system("./a.out | grep \"OUT\" | awk \'{print \$2}\' >  out.hex");
  `perl dehex.pl out.hex out_hw.yuv`;
  `./decoder/bin/ldecod.exe -i input.264 -o out_gold.yuv`;
  $out=`diff -q out_gold.yuv out_hw.yuv`;
  print $out;
  print "\n";
}

