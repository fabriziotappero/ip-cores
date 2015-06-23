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
//   The AHB is built of an AXI master and an AXI2AHB bridge
// 
//
// I/F :
//   idle - all internal masters emptied their command FIFOs
//   scrbrd_empty - all scoreboard checks have been completed (for random testing)
//
//
// Tasks:
//
// enable()
//   Description: Enables AHB master
//
// write_single(input addr, input wdata)
//   Description: write a single AHB burst (1 data cycle)
//   Parameters:
//           addr  - address
//           wdata - write data
// 
// read_single(input addr, output rdata)
//   Description:
//   Parameters:
//               addr  - address
//               rdata - return read data
//
// check_single(input addr, input expected)
//   Description: read a single AHB burst and gives an error if the data read does not match expected
//   Parameters:
//               addr  - address
//               expected - expected read data
//
// write_and_check_single(input addr, input data)
//   Description: write a single AHB burst read it back and compare the write and read data
//   Parameters:
//               addr  - address
//               data - data to write and expect on read
//
// insert_wr_cmd(input addr, input len, input size)
//   Description: add an AHB write burst to command FIFO
//   Parameters:
//               addr - address
//               len - AHB LEN (data strobe number)
//               size - AHB SIZE (data width)
//  
// insert_rd_cmd(input addr, input len, input size)
//   Description: add an AHB read burst to command FIFO
//   Parameters:
//               addr - address
//               len - AHB LEN (data strobe number)
//               size - AHB SIZE (data width)
//  
// insert_wr_data(input wdata)
//   Description: add a single data to data FIFO (to be used in write bursts)
//   Parameters:
//               wdata - write data
//  
// insert_wr_incr_data(input addr, input len, input size)
//   Description: add an AHB write burst to command FIFO will use incremental data (no need to use insert_wr_data)
//   Parameters:
//               addr - address
//               len - AHB LEN (data strobe number)
//               size - AHB SIZE (data width)
//  
// insert_rand_chk(input burst_num)
//   Description: add multiple commands to command FIFO. Each command writes incremental data to a random address, reads the data back and checks the data. Useful for random testing.
//   Parameters:
//               burst_num - total number of bursts to check
//  
//  
//  Parameters:
//  
//    For random testing: (changing these values automatically update interanl masters)
//      len_min  - minimum burst AHB LEN (length)
//      len_max  - maximum burst AHB LEN (length)
//      size_min - minimum burst AHB SIZE (width)
//      size_max - maximum burst AHB SIZE (width)
//      addr_min - minimum address (in bytes)
//      addr_max - maximum address (in bytes)
//  
//////////////////////////////////////

OUTFILE PREFIX.v

INCLUDE def_ahb_master.txt
  
module PREFIX(PORTS);
   input                      clk;
   input                      reset;

   revport                    GROUP_AHB;
   output                     idle;
   output                     scrbrd_empty;
   

   parameter                  LEN_BITS  = 4;
   ##parameter                  SIZE_BITS = 2;                  
   
   wire                       GROUP_AXI;
   
   wire                       GROUP_AHB;

   integer                             GROUP_AXI_MASTER_RAND = GROUP_AXI_MASTER_RAND.DEFAULT;
   
   always @(*)
     begin
        #FFD;
        axi_master.GROUP_AXI_MASTER_RAND = GROUP_AXI_MASTER_RAND;
     end
   
   initial
     begin       
        #100;
        ahb_bursts=1;
     end
   
   
CREATE axi_master.v \\
   DEFCMD(SWAP.GLOBAL CONST(PREFIX) PREFIX_axi_master) \\
   DEFCMD(SWAP.GLOBAL CONST(ID_BITS) ID_BITS) \\
   DEFCMD(SWAP.GLOBAL CONST(ADDR_BITS) ADDR_BITS) \\
   DEFCMD(SWAP.GLOBAL CONST(DATA_BITS) DATA_BITS) \\
   DEFCMD(SWAP.GLOBAL CONST(SIZE_BITS) SIZE_BITS) \\
   DEFCMD(GROUP.USER AXI_ID overrides {)  \\
   DEFCMD(0) \\ 
   DEFCMD(})
   PREFIX_axi_master axi_master(
			 .clk(clk),
			 .reset(reset),

                         .GROUP_AXI(GROUP_AXI),
                         .idle(idle),
                         .scrbrd_empty(scrbrd_empty)
                         );

   
   CREATE axi2ahb.v \\
   DEFCMD(SWAP.GLOBAL CONST(PREFIX) PREFIX_axi2ahb) \\
   DEFCMD(SWAP.GLOBAL CONST(CMD_DEPTH) 4) \\
   DEFCMD(SWAP.GLOBAL CONST(ADDR_BITS) ADDR_BITS) \\
   DEFCMD(SWAP.GLOBAL CONST(DATA_BITS) DATA_BITS) \\
   DEFCMD(SWAP.GLOBAL CONST(SIZE_BITS) SIZE_BITS) \\
   DEFCMD(SWAP.GLOBAL CONST(ID_BITS) ID_BITS) 
     PREFIX_axi2ahb axi2ahb(
			 .clk(clk),
			 .reset(reset),

                         .GROUP_AXI(GROUP_AXI),
                         .GROUP_AHB(GROUP_AHB),
                             STOMP ,
                             );

   task enable;
      begin
         axi_master.enable(0);
      end
   endtask

   task write_single;
      input [ADDR_BITS-1:0]  addr;
      input [DATA_BITS-1:0]  wdata;
      begin
         axi_master.write_single(0, addr, wdata);
      end
   endtask

   task read_single;
      input [ADDR_BITS-1:0]  addr;
      output [DATA_BITS-1:0]  rdata;
      begin
         axi_master.read_single(0, addr, rdata);
      end
   endtask

   task check_single;
      input [ADDR_BITS-1:0]  addr;
      input [DATA_BITS-1:0]  expected;
      begin
         axi_master.check_single(0, addr, expected);
      end
   endtask

   task write_and_check_single;
      input [ADDR_BITS-1:0]  addr;
      input [DATA_BITS-1:0]  data;
      begin
         axi_master.write_and_check_single(0, addr, data);
      end
   endtask

   task insert_wr_cmd;
      input [ADDR_BITS-1:0]  addr;
      input [LEN_BITS-1:0]   len;
      input [SIZE_BITS-1:0]  size;
      begin
         axi_master.insert_wr_cmd(0, addr, len, size);
      end
   endtask

   task insert_rd_cmd;
      input [ADDR_BITS-1:0]  addr;
      input [LEN_BITS-1:0]   len;
      input [SIZE_BITS-1:0]  size;
      begin
         axi_master.insert_rd_cmd(0, addr, len, size);
      end
   endtask

   task insert_wr_data;
      input [DATA_BITS-1:0]  wdata;
      begin
         axi_master.insert_wr_data(0, wdata);
      end
   endtask

   task insert_wr_incr_data;
      input [ADDR_BITS-1:0]  addr;
      input [LEN_BITS-1:0]   len;
      input [SIZE_BITS-1:0]  size;
      begin
         axi_master.insert_wr_incr_data(0, addr, len, size);
      end
   endtask

   task insert_rand_chk;
      input [31:0] burst_num;
      begin
         axi_master.insert_rand_chk(0, burst_num);
      end
   endtask

   
endmodule

   
