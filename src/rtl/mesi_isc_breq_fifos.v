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
////  mesi_isc_breq_fifos                                         ////
////  -------------------                                         ////
////  Stores all the snoop transactions. Keeps the transactions   ////
////  until the cpu receives the transactions                     ////
////                                                              ////
////  The functional ports of the block are arranged in arrays.   ////
////  Each functional port is an array which contains one signal  ////
////  for each snoop fifo.                                        ////
////  The order of the signals, of width X (each signal has       //// 
////  X-1:0 bits), in the port is described below.                ////
////  All the bits of the first signal are located in the port    ////
////  least significant bits. Then, the second signal is located  ////
////  in the next X bits, etc.                                    ////
////                                                              ////
////  For a port that contains M (M>1) signals of width X (X>0)   ////
////  signal_N[X-1:0] = port[(N+1)*X-1:N*X].                      ////
////                                                              ////
////  For example for a port with 4 signals of 8 bits             ////
////  signal_0[7:0] = port[(N+1)*X-1:N*X] = port[(N+1)*8-1:N*8] = ////
////                = port[(0+1)*8-1:0*8] = port[7:0]             ////
////  signal_1[7:0] = port[(1+1)*8-1:1*8] = port[15:8]            ////
////  signal_2[7:0] = port[(2+1)*8-1:2*8] = port[23:16]           ////
////  signal_3[7:0] = port[(3+1)*8-1:3*8] = port[31:24]           ////
////                                                              ////
////  To Do:                                                      ////
////   -                                                          ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "mesi_isc_define.v"

module mesi_isc_breq_fifos
    (
     // Inputs
     clk,
     rst,
     mbus_cmd_array_i,
     mbus_addr_array_i,
     broad_fifo_status_full_i,
     // Outputs
     mbus_ack_array_o,
     broad_fifo_wr_o,
     broad_addr_o,
     broad_type_o,
     broad_cpu_id_o,
     broad_id_o
   );
   
parameter
  MBUS_CMD_WIDTH           = 3,
  ADDR_WIDTH               = 32,
  BROAD_TYPE_WIDTH         = 2,  
  BROAD_ID_WIDTH           = 7,  
  BREQ_FIFO_SIZE           = 2,
  BREQ_FIFO_SIZE_LOG2      = 1;
   
// Inputs
//================================
// System
input                   clk;          // System clock
input                   rst;          // Active high system reset

// Main buses
input [4*MBUS_CMD_WIDTH-1:0] mbus_cmd_array_i; // Main bus command (array)
input [4*ADDR_WIDTH-1:0] mbus_addr_array_i; // Main bus address (array)

// From mesi_isc_broad_fifo
input                    broad_fifo_status_full_i; // The broad fifo is full
                                      // and can't receive another broadcast
                                      // request
 
// Outputs
//================================
// Main buses
output [3:0]             mbus_ack_array_o; // Bus acknowledge for receiving the
                                      // broadcast request
// To mesi_isc_broad_fifo
output                   broad_fifo_wr_o; // Write the broadcast request
output [ADDR_WIDTH-1:0]  broad_addr_o; // Address of the broadcast request
output [BROAD_TYPE_WIDTH-1:0] broad_type_o; // Type of the broadcast request
output [1:0]             broad_cpu_id_o; // ID of the initiator CPU
                                      // broad in the broad fifo
output [BROAD_ID_WIDTH-1:0] broad_id_o; // The ID of the broadcast request


// Regs & wires
//================================
wire [3:0] 		fifo_status_empty_array;
wire [3:0]              fifo_status_full_array;
wire [4*ADDR_WIDTH-1:0] broad_addr_array;
wire [4*BROAD_TYPE_WIDTH-1:0] broad_type_array;
wire [4*BROAD_ID_WIDTH-1:0] broad_id_array;
wire [3:0] 		fifo_wr_array;
wire [3:0] 		fifo_rd_array;
wire [4*BROAD_TYPE_WIDTH-1:0] breq_type_array;
wire [4*2-1:0]          breq_cpu_id_array;
wire [4*BROAD_ID_WIDTH-1:0] breq_id_array;
wire [4*2-1:0] 		    broad_cpu_id_array;
		   
// Breq fifo control
//================================
mesi_isc_breq_fifos_cntl #(MBUS_CMD_WIDTH,
                           ADDR_WIDTH,
                           BROAD_TYPE_WIDTH,
                           BROAD_ID_WIDTH)
   mesi_isc_breq_fifos_cntl 
    (
     // Inputs
     .clk                   (clk),
     .rst                   (rst),
     .mbus_cmd_array_i      (mbus_cmd_array_i [4*MBUS_CMD_WIDTH-1     :0]),
     .fifo_status_empty_array_i (fifo_status_empty_array            [3:0]),
     .fifo_status_full_array_i  (fifo_status_full_array             [3:0]),
     .broad_fifo_status_full_i (broad_fifo_status_full_i),
     .broad_addr_array_i    (broad_addr_array  [4*ADDR_WIDTH-1        :0]),
     .broad_type_array_i    (broad_type_array  [4*BROAD_TYPE_WIDTH-1  :0]),
     .broad_id_array_i      (broad_id_array    [4*BROAD_ID_WIDTH-1    :0]),
     // Outputs
     .mbus_ack_array_o      (mbus_ack_array_o                        [3:0]),
     .fifo_wr_array_o       (fifo_wr_array                          [3:0]),
     .fifo_rd_array_o       (fifo_rd_array                          [3:0]), 
     .broad_fifo_wr_o       (broad_fifo_wr_o),
     .broad_addr_o          (broad_addr_o      [ADDR_WIDTH-1          :0]),
     .broad_type_o          (broad_type_o      [BROAD_TYPE_WIDTH-1    :0]),
     .broad_cpu_id_o        (broad_cpu_id_o                         [1:0]),
     .broad_id_o            (broad_id_o        [BROAD_ID_WIDTH-1      :0]),
     .breq_type_array_o     (breq_type_array   [4*BROAD_TYPE_WIDTH-1  :0]),
     .breq_cpu_id_array_o   (breq_cpu_id_array [4*2-1                 :0]),
     .breq_id_array_o       (breq_id_array     [4*BROAD_ID_WIDTH-1    :0])
     );

// Breq fifo 3
//================================
mesi_isc_basic_fifo #(ADDR_WIDTH         +  // DATA_WIDTH
                      BROAD_TYPE_WIDTH   +
                      2                  +  // BROAD_CPU_ID_WIDTH
                      BROAD_ID_WIDTH,
                      BREQ_FIFO_SIZE,       // FIFO_SIZE
                      BREQ_FIFO_SIZE_LOG2)  // FIFO_SIZE_LOG2
   //  \ /  (\ / marks the fifo ID) 
   fifo_3 
    (
     // Inputs
     .clk                   (clk),
     .rst                   (rst),
                            //            \ /
     .wr_i                  (fifo_wr_array[3]),
                            //            \ /
     .rd_i                  (fifo_rd_array[3]),
                            //                 \ /
     .data_i                ({mbus_addr_array_i[(3+1)*ADDR_WIDTH-1:
                            //                          \ /
                                                         3*ADDR_WIDTH],
                            //                 \ /
                              breq_type_array [(3+1)*BROAD_TYPE_WIDTH-1:
                            //                          \ /
                                                         3*BROAD_TYPE_WIDTH],
                            //                  \ /
                              breq_cpu_id_array[(3+1)*2-1:
                            //                          \ /
                                                         3*2],
                            //                 \ /
                              breq_id_array   [(3+1)*BROAD_ID_WIDTH-1:
                            //                          \ /
                                                         3*BROAD_ID_WIDTH]}),
     // Outputs
     //                     //                 \ /
     .data_o                ({broad_addr_array [(3+1)*ADDR_WIDTH-1:
                            //                          \ /
                                                         3*ADDR_WIDTH],
                            //                 \ /
                             broad_type_array  [(3+1)*BROAD_TYPE_WIDTH-1:
                            //                          \ /
                                                         3*BROAD_TYPE_WIDTH],
                            //                  \ /
                             broad_cpu_id_array[(3+1)*2-1:
                            //                          \ /
                                                         3*2],
                            //                 \ /
                             broad_id_array    [(3+1)*BROAD_ID_WIDTH-1:
                            //                          \ /
                                                         3*BROAD_ID_WIDTH]}),
                            //                             \ /
     .status_empty_o        (fifo_status_empty_array       [3]),
                            //                             \ /
     .status_full_o         (fifo_status_full_array        [3])
     );

// Breq fifo 2
//================================
mesi_isc_basic_fifo #(ADDR_WIDTH         +  // DATA_WIDTH
                      BROAD_TYPE_WIDTH   +
                      2                  +  // BROAD_CPU_ID_WIDTH
                      BROAD_ID_WIDTH,
                      BREQ_FIFO_SIZE,       // FIFO_SIZE
                      BREQ_FIFO_SIZE_LOG2)  // FIFO_SIZE_LOG2
   //  \ /  (\ / marks the fifo ID) 
   fifo_2 
    (
     // Inputs
     .clk                   (clk),
     .rst                   (rst),
                            //            \ /
     .wr_i                  (fifo_wr_array[2]),
                            //            \ /
     .rd_i                  (fifo_rd_array[2]),
                            //                 \ /
     .data_i                ({mbus_addr_array_i[(2+1)*ADDR_WIDTH-1:
                            //                          \ /
                                                         2*ADDR_WIDTH],
                            //                 \ /
                              breq_type_array [(2+1)*BROAD_TYPE_WIDTH-1:
                            //                          \ /
                                                         2*BROAD_TYPE_WIDTH],
                            //                  \ /
                              breq_cpu_id_array[(2+1)*2-1:
                            //                          \ /
                                                         2*2],
                            //                 \ /
                              breq_id_array   [(2+1)*BROAD_ID_WIDTH-1:
                            //                          \ /
                                                         2*BROAD_ID_WIDTH]}),
     // Outputs
     //                     //                 \ /
     .data_o                ({broad_addr_array [(2+1)*ADDR_WIDTH-1:
                            //                          \ /
                                                         2*ADDR_WIDTH],
                            //                 \ /
                             broad_type_array  [(2+1)*BROAD_TYPE_WIDTH-1:
                            //                          \ /
                                                         2*BROAD_TYPE_WIDTH],
                            //                  \ /
                             broad_cpu_id_array[(2+1)*2-1:
                            //                          \ /
                                                         2*2],
                            //                 \ /
                             broad_id_array    [(2+1)*BROAD_ID_WIDTH-1:
                            //                          \ /
                                                         2*BROAD_ID_WIDTH]}),
                            //                             \ /
     .status_empty_o        (fifo_status_empty_array       [2]),
                            //                             \ /
     .status_full_o         (fifo_status_full_array        [2])
     );

// Breq fifo 1
//================================
mesi_isc_basic_fifo #(ADDR_WIDTH         +  // DATA_WIDTH
                      BROAD_TYPE_WIDTH   +
                      2                  +  // BROAD_CPU_ID_WIDTH
                      BROAD_ID_WIDTH,
                      BREQ_FIFO_SIZE,       // FIFO_SIZE
                      BREQ_FIFO_SIZE_LOG2)  // FIFO_SIZE_LOG2
   //  \ /  (\ / marks the fifo ID) 
   fifo_1 
    (
     // Inputs
     .clk                   (clk),
     .rst                   (rst),
                            //            \ /
     .wr_i                  (fifo_wr_array[1]),
                            //            \ /
     .rd_i                  (fifo_rd_array[1]),
                            //                 \ /
     .data_i                ({mbus_addr_array_i[(1+1)*ADDR_WIDTH-1:
                            //                          \ /
                                                         1*ADDR_WIDTH],
                            //                 \ /
                              breq_type_array [(1+1)*BROAD_TYPE_WIDTH-1:
                            //                          \ /
                                                         1*BROAD_TYPE_WIDTH],
                            //                  \ /
                              breq_cpu_id_array[(1+1)*2-1:
                            //                          \ /
                                                         1*2],
                            //                 \ /
                              breq_id_array   [(1+1)*BROAD_ID_WIDTH-1:
                            //                          \ /
                                                         1*BROAD_ID_WIDTH]}),
     // Outputs
     //                     //                 \ /
     .data_o                ({broad_addr_array [(1+1)*ADDR_WIDTH-1:
                            //                          \ /
                                                         1*ADDR_WIDTH],
                            //                 \ /
                             broad_type_array  [(1+1)*BROAD_TYPE_WIDTH-1:
                            //                          \ /
                                                         1*BROAD_TYPE_WIDTH],
                            //                  \ /
                             broad_cpu_id_array[(1+1)*2-1:
                            //                          \ /
                                                         1*2],
                            //                 \ /
                             broad_id_array    [(1+1)*BROAD_ID_WIDTH-1:
                            //                          \ /
                                                         1*BROAD_ID_WIDTH]}),
                            //                             \ /
     .status_empty_o        (fifo_status_empty_array       [1]),
                            //                             \ /
     .status_full_o         (fifo_status_full_array        [1])
     );

// Breq fifo 0
//================================
mesi_isc_basic_fifo #(ADDR_WIDTH         +  // DATA_WIDTH
                      BROAD_TYPE_WIDTH   +
                      2                  +  // BROAD_CPU_ID_WIDTH
                      BROAD_ID_WIDTH,
                      BREQ_FIFO_SIZE,       // FIFO_SIZE
                      BREQ_FIFO_SIZE_LOG2)  // FIFO_SIZE_LOG2
   //  \ /  (\ / marks the fifo ID) 
   fifo_0 
    (
     // Inputs
     .clk                   (clk),
     .rst                   (rst),
                            //            \ /
     .wr_i                  (fifo_wr_array[0]),
                            //            \ /
     .rd_i                  (fifo_rd_array[0]),
                            //                 \ /
     .data_i                ({mbus_addr_array_i[(0+1)*ADDR_WIDTH-1:
                            //                          \ /
                                                         0*ADDR_WIDTH],
                            //                 \ /
                              breq_type_array [(0+1)*BROAD_TYPE_WIDTH-1:
                            //                          \ /
                                                         0*BROAD_TYPE_WIDTH],
                            //                  \ /
                              breq_cpu_id_array[(0+1)*2-1:
                            //                          \ /
                                                         0*2],
                            //                 \ /
                              breq_id_array   [(0+1)*BROAD_ID_WIDTH-1:
                            //                          \ /
                                                         0*BROAD_ID_WIDTH]}),
     // Outputs
     //                     //                 \ /
     .data_o                ({broad_addr_array [(0+1)*ADDR_WIDTH-1:
                            //                          \ /
                                                         0*ADDR_WIDTH],
                            //                 \ /
                             broad_type_array  [(0+1)*BROAD_TYPE_WIDTH-1:
                            //                          \ /
                                                         0*BROAD_TYPE_WIDTH],
                            //                  \ /
                             broad_cpu_id_array[(0+1)*2-1:
                            //                          \ /
                                                         0*2],
                            //                 \ /
                             broad_id_array    [(0+1)*BROAD_ID_WIDTH-1:
                            //                          \ /
                                                         0*BROAD_ID_WIDTH]}),
                            //                             \ /
     .status_empty_o        (fifo_status_empty_array       [0]),
                            //                             \ /
     .status_full_o         (fifo_status_full_array        [0])
     );

endmodule
