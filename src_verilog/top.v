
// The MIT License

// Copyright (c) 2006-2007 Massachusetts Institute of Technology

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

module top;

  reg clk   = 0;
  reg reset = 0;
  integer i = 0;
   
   always@(*)
     begin 
       #5 clk <= ~clk; // this corresponds to 10ns duty cycle?
     end

  mkTH th( .CLK(clk), .RST_N(reset) );
  
  initial
  begin
    // This turns on VCD (plus) output
    //$sdf_annotate("./top.sdf",th.h264);
    $dumpfile("dump.vcd");
    $dumpvars(0,th.h264);
     $dumpoff;
  
     clk = 0;
     #30;
     reset = 1;
  
     for( i = 0; i < 10000; i=i+1)
       begin
	  $dumpoff;
	  $display("XXX DUMPOFF");
	  #100000;
	  $dumpon;
	  $display("XXX DUMPON");
	  $dumpvars(0,th.h264);
	  #10000;
	  $dumpoff;
       end 
     $finish;
   
  end 
     
endmodule 
