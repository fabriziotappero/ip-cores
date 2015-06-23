//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
////                                                              ////
////  MESI_ISC Project                                            ////
////                                                              ////
////  Author(s):                                                  ////
////      - Yair Amitay       yair.amitay@yahoo.com               ////
////                          www.linkedin.com/in/yairamitay      ////
////                                                              ////
////  Description                                                 ////
////  mesi_isc                                                    ////
////  -------------------                                         ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////   -                                                          ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "mesi_isc_define.v"

module mesi_isc
    (
     // Inputs
     clk,
     rst,
     mbus_cmd3_i,
     mbus_cmd2_i,
     mbus_cmd1_i,
     mbus_cmd0_i,
     mbus_addr3_i,
     mbus_addr2_i,
     mbus_addr1_i,
     mbus_addr0_i,
     cbus_ack3_i,
     cbus_ack2_i,
     cbus_ack1_i,
     cbus_ack0_i,
     // Outputs
     cbus_addr_o,
     cbus_cmd3_o,
     cbus_cmd2_o,
     cbus_cmd1_o,
     cbus_cmd0_o,
     mbus_ack3_o,
     mbus_ack2_o,
     mbus_ack1_o,
     mbus_ack0_o
   );
   
parameter
  CBUS_CMD_WIDTH           = 3,
  ADDR_WIDTH               = 32,
  BROAD_TYPE_WIDTH         = 2,
  BROAD_ID_WIDTH           = 5,  
  BROAD_REQ_FIFO_SIZE      = 4,
  BROAD_REQ_FIFO_SIZE_LOG2 = 2,
  MBUS_CMD_WIDTH           = 3,
  BREQ_FIFO_SIZE           = 2,
  BREQ_FIFO_SIZE_LOG2      = 1;
   
// Inputs
//================================
// System
input                   clk;          // System clock
input                   rst;          // Active high system reset
// Main buses
input [MBUS_CMD_WIDTH-1:0] mbus_cmd3_i; // Main bus3 command
input [MBUS_CMD_WIDTH-1:0] mbus_cmd2_i; // Main bus2 command
input [MBUS_CMD_WIDTH-1:0] mbus_cmd1_i; // Main bus1 command
input [MBUS_CMD_WIDTH-1:0] mbus_cmd0_i; // Main bus0 command
// Coherence buses
input [ADDR_WIDTH-1:0]  mbus_addr3_i;  // Coherence bus3 address
input [ADDR_WIDTH-1:0]  mbus_addr2_i;  // Coherence bus2 address
input [ADDR_WIDTH-1:0]  mbus_addr1_i;  // Coherence bus1 address
input [ADDR_WIDTH-1:0]  mbus_addr0_i;  // Coherence bus0 address
input                   cbus_ack3_i;  // Coherence bus3 acknowledge
input                   cbus_ack2_i;  // Coherence bus2 acknowledge
input                   cbus_ack1_i;  // Coherence bus1 acknowledge
input                   cbus_ack0_i;  // Coherence bus0 acknowledge
   
// Outputs
//================================

output [ADDR_WIDTH-1:0] cbus_addr_o;  // Coherence bus address. All busses have
                                      // the same address
output [CBUS_CMD_WIDTH-1:0] cbus_cmd3_o; // Coherence bus3 command
output [CBUS_CMD_WIDTH-1:0] cbus_cmd2_o; // Coherence bus2 command
output [CBUS_CMD_WIDTH-1:0] cbus_cmd1_o; // Coherence bus1 command
output [CBUS_CMD_WIDTH-1:0] cbus_cmd0_o; // Coherence bus0 command


output                  mbus_ack3_o;  // Main bus3 acknowledge
output                  mbus_ack2_o;  // Main bus2 acknowledge
output                  mbus_ack1_o;  // Main bus1 acknowledge
output                  mbus_ack0_o;  // Main bus0 acknowledge
   
// Regs & wires
//================================
wire                    broad_fifo_wr;
wire [ADDR_WIDTH-1:0]   broad_addr;
wire [BROAD_ID_WIDTH-1:0] broad_id;
wire [BROAD_TYPE_WIDTH-1:0] broad_type;
wire [1:0]              broad_cpu_id;
wire                    broad_fifo_status_full;
   
// mesi_isc_broad
//================================
mesi_isc_broad #(CBUS_CMD_WIDTH,
                 ADDR_WIDTH,
                 BROAD_TYPE_WIDTH,  
                 BROAD_ID_WIDTH,  
                 BROAD_REQ_FIFO_SIZE,
                 BROAD_REQ_FIFO_SIZE_LOG2)
  mesi_isc_broad
    (
     // Inputs
     .clk                      (clk),
     .rst                      (rst),
     .cbus_ack_array_i         ({cbus_ack3_i,
                                 cbus_ack2_i,
                                 cbus_ack1_i,
                                 cbus_ack0_i}
                               ),
     .broad_fifo_wr_i          (broad_fifo_wr  ),
     .broad_addr_i             (broad_addr[ADDR_WIDTH-1:0]),
     .broad_type_i             (broad_type[BROAD_TYPE_WIDTH-1:0]),
     .broad_cpu_id_i           (broad_cpu_id[1:0]),
     .broad_id_i               (broad_id[BROAD_ID_WIDTH-1:0]),
     // Outputs
     .cbus_addr_o              (cbus_addr_o[ADDR_WIDTH-1:0]),
     .cbus_cmd_array_o         ({cbus_cmd3_o[CBUS_CMD_WIDTH-1:0],
                                 cbus_cmd2_o[CBUS_CMD_WIDTH-1:0],
                                 cbus_cmd1_o[CBUS_CMD_WIDTH-1:0],
                                 cbus_cmd0_o[CBUS_CMD_WIDTH-1:0]}
                               ),
     .fifo_status_full_o       (broad_fifo_status_full)
     );

// mesi_isc_breq_fifos
//================================
mesi_isc_breq_fifos #(MBUS_CMD_WIDTH,
                      ADDR_WIDTH,
                      BROAD_TYPE_WIDTH,  
                      BROAD_ID_WIDTH,  
                      BREQ_FIFO_SIZE,
                      BREQ_FIFO_SIZE_LOG2)
  mesi_isc_breq_fifos
    (
     // Inputs
     .clk                      (clk),
     .rst                      (rst),
     .mbus_cmd_array_i         ({mbus_cmd3_i[MBUS_CMD_WIDTH-1:0],
                                 mbus_cmd2_i[MBUS_CMD_WIDTH-1:0],
                                 mbus_cmd1_i[MBUS_CMD_WIDTH-1:0],
                                 mbus_cmd0_i[MBUS_CMD_WIDTH-1:0]}
                               ),
     .mbus_addr_array_i        ({mbus_addr3_i[ADDR_WIDTH-1:0],
                                 mbus_addr2_i[ADDR_WIDTH-1:0],
                                 mbus_addr1_i[ADDR_WIDTH-1:0],
                                 mbus_addr0_i[ADDR_WIDTH-1:0]}
                               ),
     .broad_fifo_status_full_i (broad_fifo_status_full),
     // Outputs
     .mbus_ack_array_o         ({mbus_ack3_o,
                                 mbus_ack2_o,
                                 mbus_ack1_o,
                                 mbus_ack0_o}
                                ),
     .broad_fifo_wr_o          (broad_fifo_wr  ),
     .broad_addr_o             (broad_addr[ADDR_WIDTH-1:0]),
     .broad_type_o             (broad_type[BROAD_TYPE_WIDTH-1:0]),
     .broad_cpu_id_o           (broad_cpu_id[1:0]),
     .broad_id_o               (broad_id[BROAD_ID_WIDTH-1:0])
     );

endmodule
