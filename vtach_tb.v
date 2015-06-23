`timescale 1us/1ns
module vtach_tb();
   reg clk;
   reg reset;
   
   top dut(clk,reset);

    always #1 clk=~clk;
   

initial
  begin
   $dumpfile("vtach_tb.vcd");
   $dumpvars;
   clk=1'b0;
   reset=1'b1;
     
/*
   dut.mem.row0[0]=13'h120;  // load location 1 into acc (acc=500)
   dut.mem.row0[1]=13'h500;  // output location 0 (print 101)
   dut.mem.row0[2]=13'h033;  // Input to location 33 (X)
   dut.mem.row0[3]=13'h533;  // output location 33
   dut.mem.row0[4]=13'h200;  // add acc + location 0 (500+101=601)
   dut.mem.row0[5]=13'h733;  // sub acc - location 33 (601-X)
   dut.mem.row0[6]=13'h610;  // store acc to location 10
   dut.mem.row0[7]=13'h510;  // output location 10
   dut.mem.row0[8]=13'h820;  // goto location 20
     
  dut.mem.row2[0]=13'h599;   // output return address from jump (should be 9)
  dut.mem.row2[1]=13'h900;  // halt!
*/
     dut.mem.row0[0]=13'h120;  // load location 20 (10)
     dut.mem.row0[1]=13'h622;  // Store to location 22
     dut.mem.row0[2]=13'h522;  // output location 22
     dut.mem.row0[3]=13'h721;  // subtract [21] (1)
     dut.mem.row0[4]=13'h310;  // if negative goto 10
     dut.mem.row0[5]=13'h801;  // goto 1
     dut.mem.row1[0]=13'h900;  // halt
     dut.mem.row2[0]=13'h010;  // constant 10
     dut.mem.row2[1]=13'h001;  // constant 1
     dut.mem.row2[2]=13'h000;  // workspace
     
     
     
//   dut.mem.row0[6]=13'h800;
// Only use this line with io_input.v
// not with io_input_keyboard.v
//   dut.execunit.in.inputvalues[0]=13'h222;
   #5 reset=1'b0;
  end
  endmodule 

