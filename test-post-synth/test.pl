#!/usr/bin/perl
# The MIT License

# Copyright (c) 2006-2007 Massachusetts Institute of Technology

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

#build the code.

# build the golden decoder
`cd ../test/decoder/ldecod && make`;

@h264files = `ls ./h264`;

foreach(@h264files)
{
   chomp($_);
 
  print $_; 
  print " ";
  `cp ./h264/$_  input.264`;
  system("wc input.264 | awk \'{printf(\"%08x\\n%08x\\n\", \$3, \$3, \$3, \$3)}\' > input_size.hex");
  `perl ../test/hexfilegen.pl input.264`;
  system("./simv | grep \"OUT\" | awk \'{print \$2}\' >  out.hex");
  `perl ../test/dehex.pl out.hex out_hw.yuv`;
  `../test/decoder/bin/ldecod.exe -i input.264 -o out_gold.yuv`;
  $out=`diff -q out_gold.yuv out_hw.yuv`;
  print $out;
  print "\n";
}

