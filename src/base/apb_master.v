<##//////////////////////////////////////////////////////////////////
////                                                             ////
////  Author: Eyal Hochberg                                      ////
////          eyal@provartec.com                                 ////
////                                                             ////
////  Downloaded from: http://www.opencores.org                  ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2010 Provartec LTD                            ////
//// www.provartec.com                                           ////
//// info@provartec.com                                          ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
//// This source file is free software; you can redistribute it  ////
//// and/or modify it under the terms of the GNU Lesser General  ////
//// Public License as published by the Free Software Foundation.////
////                                                             ////
//// This source is distributed in the hope that it will be      ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied  ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR     ////
//// PURPOSE.  See the GNU Lesser General Public License for more////
//// details. http://www.gnu.org/licenses/lgpl.html              ////
////                                                             ////
//////////////////////////////////////////////////////////////////##>

//////////////////////////////////////
//
// General:
//   The APB master is built of an AXI master and an AXI2APB bridge. 
//   The stub support APB (Amba2) and APB3 (Amba3) protocols, 
//   the define APB3 determines this (in def_apb_master.txt)
// 
//
// Tasks:
//
// write_single(input addr, input wdata)
//   Description: write a single APB burst
//   Parameters:
//               addr  - address
//               wdata - write data
// 
// read_single(input master_num, input addr, output rdata)
//   Description: read a single AB burst
//   Parameters:
//               addr  - address
//               rdata - return read data
//
// check_single(input master_num, input addr, input expected)
//   Description: read a single AB burst and give an error if the data read does not match expected
//   Parameters:
//               addr  - address
//               expected - expected read data
//
// write_and_check_single(input master_num, input addr, input data)
//   Description: write a single AB burst read it back and give an error if the write and read data don't match
//   Parameters:
//               addr  - address
//               data - data to write and expect on read
//
//
//////////////////////////////////////


OUTFILE PREFIX.v

INCLUDE def_apb_master.txt

module PREFIX(PORTS);

   
   input                    clk;
   input                    reset;
   
   output 		    psel;
   output 		    penable;
   output [ADDR_BITS-1:0]   paddr;
   output 		    pwrite;
   output [DATA_BITS-1:0]   pwdata;
   input [DATA_BITS-1:0]    prdata;
IFDEF APB3
   input 		    pslverr;
   input 		    pready;
ELSE APB3

   wire pslverr = 1'b0;
   wire pready = 1'b1;
ENDIF APB3

   wire                     GROUP_STUB_AXI;

   
   //set random tasks to be only 32 bit singles
   initial
     begin
        #1;
        PREFIX_axi_master.enable_all; 
        PREFIX_axi_master.use_addr_base=1;
        PREFIX_axi_master.len_min=0;
        PREFIX_axi_master.len_max=0;
        PREFIX_axi_master.size_min=2;
        PREFIX_axi_master.size_max=2;     
     end
   
   
   CREATE axi_master.v \\
DEFCMD(SWAP.GLOBAL CONST(PREFIX) PREFIX_axi_master) \\
DEFCMD(SWAP.GLOBAL CONST(ADDR_BITS) ADDR_BITS) \\
DEFCMD(SWAP.GLOBAL CONST(DATA_BITS) DATA_BITS) \\
   DEFCMD(GROUP.USER AXI_ID overrides {)  \\
   DEFCMD(0) \\ 
   DEFCMD(})
                               
     PREFIX_axi_master PREFIX_axi_master(
                           .clk(clk),
                           .reset(reset),
                           .GROUP_STUB_AXI(GROUP_STUB_AXI),
                           .idle()
                           );

   
   CREATE axi2apb.v \\
DEFCMD(SWAP CONST(SLAVE_NUM) 1) \\ 
DEFCMD(SWAP.GLOBAL CONST(PREFIX) PREFIX_axi2apb) \\
DEFCMD(SWAP.GLOBAL CONST(ADDR_BITS) ADDR_BITS) \\
DEFCMD(SWAP.GLOBAL CONST(DATA_BITS) DATA_BITS)

   PREFIX_axi2apb PREFIX_axi2apb(
                           .clk(clk),
                           .reset(reset),
                           .GROUP_STUB_AXI(GROUP_STUB_AXI),

                           .penable(penable),
                           .pwrite(pwrite),
                           .paddr(paddr),
                           .pwdata(pwdata),
                           .psel(psel),
                           .prdata(prdata),
                           .pready(pready),
                           .pslverr(pslverr)
                           );
  
  
   task write_single;
      input [ADDR_BITS-1:0]  addr;
      input [DATA_BITS-1:0]  wdata;
      begin
         PREFIX_axi_master.write_single(0, addr, wdata);
      end
   endtask

   task read_single;
      input [ADDR_BITS-1:0]  addr;
      output [DATA_BITS-1:0]  rdata;
      begin
         PREFIX_axi_master.read_single(0, addr, rdata);
      end
   endtask

   task check_single;
      input [ADDR_BITS-1:0]  addr;
      input [DATA_BITS-1:0]  expected;
      begin
         PREFIX_axi_master.check_single(0, addr, expected);
      end
   endtask

   task write_and_check_single;
      input [ADDR_BITS-1:0]  addr;
      input [DATA_BITS-1:0]  data;
      begin
         PREFIX_axi_master.write_and_check_single(0, addr, data);
      end
   endtask

   
endmodule
