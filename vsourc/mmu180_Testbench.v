/** @package zGlue

    @file mmu180_Testbench.v
        
    @brief Test Bench for Memory Management Unit to mimic Z180.

<BR>Simplified (2-clause) BSD License

Copyright (c) 2012, Douglas Beattie Jr.
All rights reserved.

Redistribution and use in source and hardware/binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.

2. Redistributions in hardware/binary form must reproduce the above
   copyright notice, this list of conditions and the following disclaimer in
   the documentation and/or other materials provided with the distribution.

THIS RTL SOURCE IS PROVIDED BY DOUGLAS BEATTIE JR. "AS IS" AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL DOUGLAS BEATTIE JR. BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS RTL SOURCE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
        
    Author: Douglas Beattie
    Created on: 4/20/2012 8:52:31 PM
	Last change: DBJR 4/26/2012 7:49:24 PM
*/
`timescale 1ns / 100ps

/* iverilog -o mytest ioport.v mmu180.v mmu180_Testbench.v */
/* vvp mytest */

module mmu180_Testbench;
    // Inputs
    reg RST;
    reg EN;
    reg IORQ;
    reg MREQ;
    reg PHI;
    reg RD;
    reg WR;
    reg [23:0] A_in; // address bus input
    wire [19:12] A_out; // address bus output
    wire [23:0] addr_out_all;

    assign addr_out_all = {A_in[23:20],A_out,A_in[11:0]};

    //reg /*inout*/ [7:0]  D; // data bus, di-directional
    wire  [7:0]  D; // data bus output

    reg [7:0] D_in;  // data bus input stimulus

    wire [7:0] D_out; // data bus observed output

    assign D_out = (! RD) ? D : 8'bz;

    assign D = (! WR) ? D_in : 8'bz;

`define CBR_IO_ADDR     16'h0038  // Common Bank Register
`define BBR_IO_ADDR     16'h0039  // Bank Base Register
`define CBAR_IO_ADDR    16'h003A  // Common/Bank Address Register

wire cbar_hinyb, cbar_lonyb;

/** ***************************************************************
    Read Port
 */
task read_port;
input [15:0] port_addr;
begin
    $display("Read port (0x%h)", port_addr);
    // Read back from port address
    #1 MREQ <= 1; #1 IORQ<=0;
    #3 RD<=0;
    #2 A_in<={8'h0, port_addr};
    wait (PHI==1'b0);
    //#100  PHI <= 0; // -----------------------------------
    wait (PHI==1'b1);
    //#350  PHI <= 0; // -----------------------------------
    #1  RD<=1;
    #1  IORQ<=1; #1 MREQ <= 1;

end
endtask

/** ***************************************************************
    Write Port
 */
task write_port;
input [15:0] port_addr;
input [7:0]  port_data;
begin
    $display("Write port (0x%h) <= 0x%h", port_addr, port_data);
    #1  MREQ <= 1; #1 IORQ<=0;
    #2  A_in<={8'h0, port_addr};
    wait (PHI==1'b0);
    //#100  PHI <= 0; // -----------------------------------
    #3  D_in <= port_data;
    #2  WR<=0;
    wait (PHI==1'b1);
    //#100  PHI <= 1; // -----------------------------------
    #1  WR<=1;
    #1  IORQ<=1; #1 MREQ <= 1;
end
endtask

/** ***************************************************************
    Insertion of one wait state, meant to be inserted after
        the first falling edge of PHI in each memory access cycle.
 */
task add_one_WAIT_state;
begin
    wait (PHI==1'b1); wait (PHI==1'b0);
end
endtask

/** ***************************************************************
    Memory Access
 */
task mem_access;
input [23:0] mem_addr;
begin
    #1  IORQ<=1; #1 MREQ <= 0;
    #3 RD<=0;
    #2  A_in<=mem_addr;
    wait (PHI==1'b0);
    add_one_WAIT_state();
    wait (PHI==1'b1);
    #1  RD<=1;
    #1  MREQ <= 1; #1 IORQ<=1;
end
endtask

/** ***************************************************************
    Default block of verification addresses, composite Memory Access
 */
task try_default_mem_values;
begin
    $display("Try Default Memory Values...");
    mem_access(24'h000100);
    mem_access(24'h001100);
    mem_access(24'h001500);
    mem_access(24'h003500);
    mem_access(24'h005122);
    mem_access(24'h00C155);
    mem_access(24'h02C155);
    mem_access(24'h00F155);
    mem_access(24'h01F155);
end
endtask


    // Instantiate the Unit Under Test (UUT)
    mmu180 uut (
        .reset_n(RST),
        .en(EN),
        .iorq_n(IORQ),
        .mreq_n(MREQ),
        .rd_n(RD),
        .wr_n(WR),
        .phi(PHI),
        .addr_in(A_in),
        .dq(D),
        .addr_out(A_out),
        .cbar_hinyb(cbar_hinyb),
        .cbar_lonyb(cbar_lonyb)
        );

/**  Clock runs continuously, 20ns period (50_MHz)
*/
always
  #10 PHI <= !PHI;  // 10ns half-cycle


initial begin

    A_in <= 24'h000000;
    D_in <= 8'h00;
    RST <= 0;
    EN <= 1;
    IORQ <= 1;
    MREQ <= 0;
    RD <= 1;
    WR <= 1;
    PHI <= 0;

    #5  RST <= 1;// PHI <= 1;

    $display("Initial Read default reset value of CBAR");
    read_port(`CBAR_IO_ADDR);

    $display("Write port to set up CBAR=0x%h", 8'hC4);
    write_port(`CBAR_IO_ADDR,8'hC4);

    $display("Read-back/verify CBAR");
    read_port(`CBAR_IO_ADDR);

    try_default_mem_values();

    $display("Write port to set up BBR=0x%h", 8'h55);
    write_port(`BBR_IO_ADDR,8'h55);

    $display("Read-back/verify BBR");
    read_port(`BBR_IO_ADDR);

    try_default_mem_values();

    $display("Write port to set up CBR=0x%h", 8'h77);
    write_port(`CBR_IO_ADDR,8'h77);

    $display("Read-back/verify CBR");
    read_port(`CBR_IO_ADDR);


    try_default_mem_values();

    $display("Disabled MREQ -- all addresses should be pass-through");
    // disable MREQ
    #1  MREQ <= 1; IORQ<=1;
    #1  A_in<=24'h003500; wait (PHI==1'b0); wait (PHI==1'b1);
    #1  A_in<=24'h005122; wait (PHI==1'b0); wait (PHI==1'b1);
    #1  A_in<=24'h00C155; wait (PHI==1'b0); wait (PHI==1'b1);
    #1  A_in<=24'h02C155; wait (PHI==1'b0); wait (PHI==1'b1);
    #1  A_in<=24'h00F155; wait (PHI==1'b0); wait (PHI==1'b1);
    #1  A_in<=24'h01F155; wait (PHI==1'b0); wait (PHI==1'b1);


//@TODO write to bogus address, then read all valid ports,
//      to verify the value was not accepted.
/*
    // Write to bogus port address
    #500  MREQ <= 1; IORQ<=0;
    #500  A_in<={8'h0, 16'h0037;
    #250  WR<=0; D_in <= 8'h33;
    #250  WR<=1;
    #250  IORQ<=1;
    #250  A<=0;
*/

    $finish;
end

initial begin
    // console dump, for verification
    $monitor("time=",$time,,
/*
    "RST=%b IORQ=%b MREQ=%b PHI=%b RD=%b WR=%b A_in=%h A_out=%h addr_out_all=%h D_in=%h D=%h D_out=%h cbar_hinyb=%b, cbar_lonyb=%b",
     RST,   IORQ,   MREQ,    PHI,  RD,   WR,   A_in,   A_out, addr_out_all,   D_in,   D, D_out, cbar_hinyb, cbar_lonyb);
*/  //omit PHI for cleaner output
    "RST=%b IORQ=%b MREQ=%b RD=%b WR=%b A_in=%h A_out=%h addr_out_all=%h D_in=%h D=%h D_out=%h cbar_hinyb=%b, cbar_lonyb=%b",
     RST,   IORQ,   MREQ,   RD,   WR,   A_in,   A_out, addr_out_all,   D_in,   D, D_out, cbar_hinyb, cbar_lonyb);

end

endmodule

