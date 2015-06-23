//////////////////////////////////////////////////////////////////////
////                                                              ////
//// regf_test                                                    ////
////                                                              ////
//// This file is part of the SXP opencores effort.               ////
//// <http://www.opencores.org/cores/sxp/>                        ////
////                                                              ////
//// Module Description:                                          ////
//// Testbench for regfile                                        //// 
////                                                              ////
//// To Do:                                                       ////
////                                                              ////
//// Author(s):                                                   ////
//// - Sam Gladstone                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001 Sam Gladstone and OPENCORES.ORG           ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from <http://www.opencores.org/lgpl.shtml>                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// $Id: test_regf.v,v 1.2 2001-11-09 00:13:06 samg Exp $ 
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.1  2001/10/29 01:10:34  samg
// testbench for reg file

`timescale 1ns / 1ns
`include "../../ram/generic_dpram.v"
`include "../src/mem_regf.v"

module regf_test();

parameter AWIDTH = 4;
parameter DSIZE = 32;

reg clk;
reg reset_b;
reg halt;
reg [AWIDTH-1:0] addra;
reg a_en;
reg [AWIDTH-1:0] addrb;
reg b_en;
reg [AWIDTH-1:0] addrc;
reg [DSIZE-1:0] dc;
reg wec;

wire [DSIZE-1:0] qra;
wire a_en_out;
wire [DSIZE-1:0] qrb;
wire b_en_out;

integer i;
integer clk_cnt;
integer errors;

mem_regf #(AWIDTH,DSIZE) i_regf  (
		.clk(clk),
		.reset_b(reset_b),
		.halt(halt),
		.addra(addra),			// reg a addr 
		.a_en(a_en),			// valid reg a read
		.addrb(addrb),			// reg b addr 
		.b_en(b_en),			// valid reg b read
		.addrc(addrc),			// reg c addr 
	        .wec(wec),			// write enable reg c
		.dc(dc),			// data input reg c
		
		.qra(qra),			// data output a
		.qrb(qrb));			// data output b


initial
  begin
    clk = 1'b 0;
    clk_cnt = 0;
    #10 forever
      begin
        #2.5 clk = ~clk;
        if (clk) 
          clk_cnt = clk_cnt + 1;
      end 
  end

initial
  begin
    errors = 0;
    addra = 'b 0;
    a_en = 1'b 0;
    addrb = 'b 0;
    b_en = 1'b 0;
    halt = 1'b 0;

    @(negedge clk);
    reset_b = 1'b 1;
    @(negedge clk);
    reset_b = 1'b 0;
    @(negedge clk);
    reset_b = 1'b 1;
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);

    // Test out port C write functionality

    wec = 1'b 1;
    for (i=0;i<(1<<AWIDTH);i=i+1)
      begin
        addrc = i;
        dc = i;
        @(negedge clk);
      end
    wec = 1'b 0;

    for (i=0;i<(1<<AWIDTH);i=i+1)
      begin    
        addra = i;
        a_en = 1'b 1;
        addrb = (1<<AWIDTH) - (i+1);
        b_en = 1'b 1;
        if (i==5)
          begin
            addrc = 'd 5;
            dc = 32'd 1234;
            wec = 1'b 1;
          end
        else
          wec = 1'b 0;
        if (i==7)
          begin
            halt = 1'b 1;
            @(negedge clk);
            @(negedge clk);
            @(negedge clk);
            @(negedge clk);
            halt = 1'b 0;
          end
        @(negedge clk);
      end

    a_en = 1'b 0;
    b_en = 1'b 0;

    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    
    $finish; 
  end

always @(posedge clk)
  begin
    if (!halt)
      $display ("after rising edge clk # %d, regf output a = %d",clk_cnt,qra); 

    if (!halt)
      $display ("after rising edge clk # %d, regf output b = %d",clk_cnt,qrb); 
  end

endmodule
