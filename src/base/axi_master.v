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
//   The AXI master has an internal master per ID. 
//   These internal masters work simultaniously and an interconnect matrix connets them. 
// 
//
// I/F :
//   idle - all internal masters emptied their command FIFOs
//   scrbrd_empty - all scoreboard checks have been completed (for random testing)
//
//
// Tasks:
//
// enable(input master_num)
//   Description: Enables master
//   Parameters: master_num - number of internal master
//
// enable_all()  
//   Description: Enables all masters
//
// write_single(input master_num, input addr, input wdata)
//   Description: write a single AXI burst (1 data cycle)
//   Parameters: master_num - number of internal master
//           addr  - address
//           wdata - write data
// 
// read_single(input master_num, input addr, output rdata)
//   Description: read a single AXI burst (1 data cycle)
//   Parameters: master_num - number of internal master
//               addr  - address
//               rdata - return read data
//
// check_single(input master_num, input addr, input expected)
//   Description: read a single AXI burst and gives an error if the data read does not match expected
//   Parameters: master_num - number of internal master
//               addr  - address
//               expected - expected read data
//
// write_and_check_single(input master_num, input addr, input data)
//   Description: write a single AXI burst read it back and compare the write and read data
//   Parameters: master_num - number of internal master
//               addr  - address
//               data - data to write and expect on read
//
// insert_wr_cmd(input master_num, input addr, input len, input size)
//   Description: add an AXI write burst to command FIFO
//   Parameters: master_num - number of internal master
//               addr - address
//               len - AXI LEN (data strobe number)
//               size - AXI SIZE (data width)
//  
// insert_rd_cmd(input master_num, input addr, input len, input size)
//   Description: add an AXI read burst to command FIFO
//   Parameters: master_num - number of internal master
//               addr - address
//               len - AXI LEN (data strobe number)
//               size - AXI SIZE (data width)
//  
// insert_wr_data(input master_num, input wdata)
//   Description: add a single data to data FIFO (to be used in write bursts)
//   Parameters: master_num - number of internal master
//               wdata - write data
//  
// insert_wr_incr_data(input master_num, input addr, input len, input size)
//   Description: add an AXI write burst to command FIFO will use incremental data (no need to use insert_wr_data)
//   Parameters: master_num - number of internal master
//               addr - address
//               len - AXI LEN (data strobe number)
//               size - AXI SIZE (data width)
//  
// insert_rand_chk(input master_num, input burst_num)
//   Description: add multiple commands to command FIFO. Each command writes incremental data to a random address, reads the data back and checks the data. Useful for random testing.
//   Parameters: master_num - number of internal master
//               burst_num - total number of bursts to check
//  
// insert_rand(input burst_num)
//   Description: disperces burst_num between internal masters and calls insert_rand_chk for each master
//   Parameters:  burst_num - total number of bursts to check (combined)
//
//  
//  Parameters:
//  
//    For random testing: (changing these values automatically update interanl masters)
//      ahb_bursts - if set, bursts will only be of length 1, 4, 8 or 16.
//      len_min  - minimum burst AXI LEN (length)
//      len_max  - maximum burst AXI LEN (length)
//      size_min - minimum burst AXI SIZE (width)
//      size_max - maximum burst AXI SIZE (width)
//      addr_min - minimum address (in bytes)
//      addr_max - maximum address (in bytes)
//  
//////////////////////////////////////

OUTFILE PREFIX.v

INCLUDE def_axi_master.txt

ITER IDX ID_NUM
module PREFIX(PORTS);

`include "prgen_rand.v"
   
   input 			       clk;
   input                               reset;
   
   port                  	       GROUP_STUB_AXI;

   output                              idle;
   output                              scrbrd_empty;
   
   
   //random parameters
   integer                             GROUP_AXI_MASTER_RAND = GROUP_AXI_MASTER_RAND.DEFAULT;
   
   wire                                GROUP_STUB_AXI_IDX;
   wire                                idle_IDX;
   wire                                scrbrd_empty_IDX;


   always @(*)
     begin
        #FFD;
        PREFIX_singleIDX.GROUP_AXI_MASTER_RAND = GROUP_AXI_MASTER_RAND;
     end
   
   assign                              idle = CONCAT(idle_IDX &);
   assign                              scrbrd_empty = CONCAT(scrbrd_empty_IDX &);
   
   
   CREATE axi_master_single.v

     LOOP IDX ID_NUM
   PREFIX_single #(IDX, ID_BITS'bGROUP_AXI_ID[IDX], CMD_DEPTH)
   PREFIX_singleIDX(
                   .clk(clk),
                   .reset(reset),
                   .GROUP_STUB_AXI(GROUP_STUB_AXI_IDX),
                   .idle(idle_IDX),
                   .scrbrd_empty(scrbrd_empty_IDX)
                   );
   
   ENDLOOP IDX

     IFDEF TRUE(ID_NUM==1)
   
   assign GROUP_STUB_AXI.OUT = GROUP_STUB_AXI_0.OUT;
   assign GROUP_STUB_AXI_0.IN = GROUP_STUB_AXI.IN;
   
     ELSE TRUE(ID_NUM==1)

CREATE ic.v \\
DEFCMD(SWAP.GLOBAL CONST(PREFIX) PREFIX) \\
DEFCMD(SWAP.GLOBAL MASTER_NUM ID_NUM) \\
DEFCMD(SWAP.GLOBAL SLAVE_NUM 1) \\
DEFCMD(SWAP.GLOBAL CONST(MSTR_ID_BITS) ID_BITS) \\
DEFCMD(SWAP.GLOBAL CONST(CMD_DEPTH) CMD_DEPTH) \\
DEFCMD(SWAP.GLOBAL CONST(DATA_BITS) DATA_BITS) \\
DEFCMD(SWAP.GLOBAL CONST(ADDR_BITS) ADDR_BITS) \\
DEFCMD(DEFINE.GLOBAL UNIQUE_ID) \\
DEFCMD(SWAP.GLOBAL CONST(USER_BITS) 0) 
LOOP IDX ID_NUM
  STOMP NEWLINE
  DEFCMD(GROUP.GLOBAL MIDX_ID overrides { ) \\
  DEFCMD(GROUP_AXI_ID[IDX]) \\
  DEFCMD(})
ENDLOOP IDX

  
    PREFIX_ic PREFIX_ic(
                       .clk(clk),
                       .reset(reset),
                       .MIDX_GROUP_STUB_AXI(GROUP_STUB_AXI_IDX),
                       .S0_GROUP_STUB_AXI(GROUP_STUB_AXI),
                       STOMP ,
      
      );

     ENDIF TRUE(ID_NUM==1)


   
   task check_master_num;
      input [24*8-1:0] task_name;
      input [31:0] master_num;
      begin
         if (master_num >= ID_NUM)
           begin
              $display("FATAL ERROR: task %0s called for master %0d that does not exist.\tTime: %0d ns.", task_name, master_num, $time);
           end
      end
   endtask
   
   task enable;
      input [31:0] master_num;
      begin
         check_master_num("enable", master_num);
         case (master_num)
           IDX : PREFIX_singleIDX.enable = 1;
         endcase
      end
   endtask

   task enable_all;
      begin
         PREFIX_singleIDX.enable = 1;
      end
   endtask
   
   task write_single;
      input [31:0] master_num;
      input [ADDR_BITS-1:0]  addr;
      input [DATA_BITS-1:0]  wdata;
      begin
         check_master_num("write_single", master_num);
         case (master_num)
           IDX : PREFIX_singleIDX.write_single(addr, wdata);
         endcase
      end
   endtask

   task read_single;
      input [31:0] master_num;
      input [ADDR_BITS-1:0]  addr;
      output [DATA_BITS-1:0]  rdata;
      begin
         check_master_num("read_single", master_num);
         case (master_num)
           IDX : PREFIX_singleIDX.read_single(addr, rdata);
         endcase
      end
   endtask

   task check_single;
      input [31:0] master_num;
      input [ADDR_BITS-1:0]  addr;
      input [DATA_BITS-1:0]  expected;
      begin
         check_master_num("check_single", master_num);
         case (master_num)
           IDX : PREFIX_singleIDX.check_single(addr, expected);
         endcase
      end
   endtask

   task write_and_check_single;
      input [31:0] master_num;
      input [ADDR_BITS-1:0]  addr;
      input [DATA_BITS-1:0]  data;
      begin
         check_master_num("write_and_check_single", master_num);
         case (master_num)
           IDX : PREFIX_singleIDX.write_and_check_single(addr, data);
         endcase
      end
   endtask

   task insert_wr_cmd;
      input [31:0] master_num;
      input [ADDR_BITS-1:0]  addr;
      input [LEN_BITS-1:0]   len;
      input [SIZE_BITS-1:0]  size;
      begin
         check_master_num("insert_wr_cmd", master_num);
         case (master_num)
           IDX : PREFIX_singleIDX.insert_wr_cmd(addr, len, size);
         endcase
      end
   endtask

   task insert_rd_cmd;
      input [31:0] master_num;
      input [ADDR_BITS-1:0]  addr;
      input [LEN_BITS-1:0]   len;
      input [SIZE_BITS-1:0]  size;
      begin
         check_master_num("insert_rd_cmd", master_num);
         case (master_num)
           IDX : PREFIX_singleIDX.insert_rd_cmd(addr, len, size);
         endcase
      end
   endtask

   task insert_wr_data;
      input [31:0] master_num;
      input [DATA_BITS-1:0]  wdata;
      begin
         check_master_num("insert_wr_data", master_num);
         case (master_num)
           IDX : PREFIX_singleIDX.insert_wr_data(wdata);
         endcase
      end
   endtask

   task insert_wr_incr_data;
      input [31:0] master_num;
      input [ADDR_BITS-1:0]  addr;
      input [LEN_BITS-1:0]   len;
      input [SIZE_BITS-1:0]  size;
      begin
         check_master_num("insert_wr_incr_data", master_num);
         case (master_num)
           IDX : PREFIX_singleIDX.insert_wr_incr_data(addr, len, size);
         endcase
      end
   endtask

   task insert_rand_chk;
      input [31:0] master_num;
      input [31:0] burst_num;
      begin
         check_master_num("insert_rand_chk", master_num);
         case (master_num)
           IDX : PREFIX_singleIDX.insert_rand_chk(burst_num);
         endcase
      end
   endtask

   task insert_rand;
      input [31:0] burst_num;
      
      reg [31:0] burst_numIDX;
      integer remain;
      begin
         remain = burst_num;
         LOOP IDX ID_NUM
         if (remain > 0)
           begin
              burst_numIDX = rand(1, remain);
              remain = remain - burst_numIDX;
              insert_rand_chk(IDX, burst_numIDX);              
           end
         ENDLOOP IDX
      end
   endtask
   

endmodule


