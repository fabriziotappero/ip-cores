/*
 * $Id: testbench.v,v 1.1 2007-04-13 22:18:52 sybreon Exp $
 * 
 * AE18 Core Simulation Testbench
 * Copyright (C) 2006-2007 Shawn Tan Ser Ngiap <shawn.tan@aeste.net>
 *  
 * This library is free software; you can redistribute it and/or modify it 
 * under the terms of the GNU Lesser General Public License as published by 
 * the Free Software Foundation; either version 2.1 of the License, 
 * or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful, but 
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
 * USA
 *
 * DESCRIPTION
 * Simple unit test with fake ROM and fake RAM contents. It loads the ROM 
 * from the ae18_core.rom file. 
 * 
 * HISTORY
 * $Log: not supported by cvs2svn $
 * Revision 1.3  2007/04/03 22:10:52  sybreon
 * Minor simulation changes.
 *
 * Revision 1.2  2006/12/29 18:08:11  sybreon
 * Minor clean up
 * 
 */

module tb (/*AUTOARG*/);
   parameter ISIZ = 16;
   parameter DSIZ = 16;
   
   wire [ISIZ-1:0] iwb_adr_o;
   wire [DSIZ-1:0] dwb_adr_o;
   wire [7:0] 	   dwb_dat_o;
   wire [7:0] 	   dwb_dat_i;   
   wire [15:0] 	   iwb_dat_o;
   wire [1:0] 	   iwb_sel_o;
   wire 	   iwb_stb_o, iwb_we_o, dwb_stb_o, dwb_we_o;
   wire [1:0] 	   qfsm_o, qmod_o;
   wire [3:0] 	   qena_o;

   reg 		   clk_i, rst_i;
   reg [1:0] 	   int_i;
   reg [7:6] 	   inte_i;   
   reg 		   dwb_ack_i, iwb_ack_i;
   reg [15:0] 	   iwb_dat_i;   

   // Log File
   integer 	   fileno;
   initial begin
      //fileno = $fopen ("ae18_core.log");      
   end
   
   // Dump Files
   initial begin
      $dumpfile("ae18_core.vcd");      
      $dumpvars(1, iwb_adr_o,iwb_dat_i,iwb_stb_o,iwb_we_o,iwb_sel_o);
      $dumpvars(1, dwb_adr_o,dwb_dat_i,dwb_dat_o,dwb_we_o,dwb_stb_o);
      $dumpvars(1, clk_i,int_i,wb_rst_o);      
      //$dumpvars(1, dut);      
   end

   initial begin
      clk_i = 0;
      rst_i = 0;
      int_i = 2'b00;

      #50 rst_i = 1;
      #30000 int_i = 2'b10;
      #50 int_i = 2'b00;      
   end

   // Test Points
   initial fork
      #80000
	$finish;      
   join
   
   always #5 clk_i = ~clk_i;   

   reg [15:0]  rom [0:65535];

   // Fake Memory Signals
   always @(posedge clk_i) begin      
      iwb_ack_i <= iwb_stb_o;      
      if (iwb_stb_o) iwb_dat_i <= rom[iwb_adr_o[ISIZ-1:1]];
   end

   reg [DSIZ-1:0] dadr;
   reg [7:0] ram [(1<<DSIZ)-1:0];
   
   assign    dwb_dat_i = ram[dadr];   
   always @(posedge clk_i) begin
      dwb_ack_i <= dwb_stb_o;
      dadr <= dwb_adr_o;
      if (dwb_we_o & dwb_stb_o)
	ram[dwb_adr_o] <= dwb_dat_o;      
   end
   
   // Load ROM contents
   integer     i; 
   initial begin
      for (i=0;i<65536;i=i+1) rom[i] <= 0;
      for (i=0;i<65536;i=i+1) ram[i] <= $random;
      #1 $readmemh ("ae18_core.rom", rom);
   end   

   // LOG
   always @(negedge clk_i) begin
      $write("\nT:",$stime);      
      if (iwb_stb_o & iwb_ack_i & !iwb_we_o & dut.rQCLK[0])
	$writeh("\tIWB:0x",iwb_adr_o,"=0x",iwb_dat_i);      
   end

   // AE18 test core   
   ae18_core #(ISIZ,DSIZ,32)
     dut (/*AUTOINST*/
	  // Outputs
	  .wb_clk_o			(wb_clk_o),
	  .wb_rst_o			(wb_rst_o),
	  .iwb_adr_o			(iwb_adr_o[ISIZ-1:0]),
	  .iwb_dat_o			(iwb_dat_o[15:0]),
	  .iwb_stb_o			(iwb_stb_o),
	  .iwb_we_o			(iwb_we_o),
	  .iwb_sel_o			(iwb_sel_o[1:0]),
	  .dwb_adr_o			(dwb_adr_o[DSIZ-1:0]),
	  .dwb_dat_o			(dwb_dat_o[7:0]),
	  .dwb_stb_o			(dwb_stb_o),
	  .dwb_we_o			(dwb_we_o),
	  // Inputs
	  .iwb_dat_i			(iwb_dat_i[15:0]),
	  .iwb_ack_i			(iwb_ack_i),
	  .dwb_dat_i			(dwb_dat_i[7:0]),
	  .dwb_ack_i			(dwb_ack_i),
	  .int_i			(int_i[1:0]),
	  .inte_i			(inte_i[7:6]),
	  .clk_i			(clk_i),
	  .rst_i			(rst_i));
   
endmodule // ae18_core_tb

// Local Variables:
// verilog-library-directories:("." "../../rtl/verilog/")
// End: