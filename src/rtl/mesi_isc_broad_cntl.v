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
////  mesi_isc_broad_cntl                                          ////
////  -------------------                                         ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////   -                                                          ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "mesi_isc_define.v"

module mesi_isc_broad_cntl
    (
     // Inputs
     clk,
     rst,
     cbus_ack_array_i,
     fifo_status_empty_i,
     fifo_status_full_i,
     broad_snoop_type_i,
     broad_snoop_cpu_id_i,
     broad_snoop_id_i,
     // Outputs
     cbus_cmd_array_o,
     broad_fifo_rd_o
     );
parameter
  CBUS_CMD_WIDTH           = 3,
  BROAD_TYPE_WIDTH         = 2,
  BROAD_ID_WIDTH           = 5;
   
// Inputs
//================================
// System
input                   clk;          // System clock
input                   rst;          // Active high system reset
// Coherence buses
input [3:0]             cbus_ack_array_i;
// broad_fifo
input                   fifo_status_empty_i;
input                   fifo_status_full_i;
// broad_fifo
input [BROAD_TYPE_WIDTH-1:0] broad_snoop_type_i; // The type of the broad
input [1:0]             broad_snoop_cpu_id_i; // The ID of the initiator CPU
input [BROAD_ID_WIDTH-1:0] broad_snoop_id_i; // The ID of the broad
 
// Outputs
//================================
output [4*CBUS_CMD_WIDTH-1:0] cbus_cmd_array_o; // Command for coherence bus.
                                      // write broadcast, read broadcast, write
                                      // enable or read enable 
// fifo
output                  broad_fifo_rd_o;

// Regs & wires
//================================
wire [CBUS_CMD_WIDTH-1:0] cbus_cmd3;  // Command for coherence bus.
wire [CBUS_CMD_WIDTH-1:0] cbus_cmd2;  // Command for coherence bus.
wire [CBUS_CMD_WIDTH-1:0] cbus_cmd1;  // Command for coherence bus.
wire [CBUS_CMD_WIDTH-1:0] cbus_cmd0;  // Command for coherence bus.
reg 	                  broadcast_in_progress; // A broadcast process
                                      // contains 2 stages. The first stage is 
                                      // to send read or write broadcast to
                                      // all CPUs and to receive an
                                      // acknowledge for each one. The second
                                      // stage is to send an
                                      // enable-access to the initiator CPU. 
reg  [3:0]                cbus_active_broad_array; // For each bit, when high a
                                      // broad access is sent to the CPU
reg  [3:0]                cbus_active_en_access_array; // For each bit, when
                                      // hing a enable-access is sent to the
                                      // CPU
reg                       broad_fifo_rd_o; // output
wire [3:0]                cbus_active_en_access_and_not_cbus_ack_array;
   
   
//cbus_cmd
assign cbus_cmd_array_o[(3+1)*CBUS_CMD_WIDTH-1 : 3*CBUS_CMD_WIDTH] = cbus_cmd3;
assign cbus_cmd_array_o[(2+1)*CBUS_CMD_WIDTH-1 : 2*CBUS_CMD_WIDTH] = cbus_cmd2;
assign cbus_cmd_array_o[(1+1)*CBUS_CMD_WIDTH-1 : 1*CBUS_CMD_WIDTH] = cbus_cmd1;
assign cbus_cmd_array_o[(0+1)*CBUS_CMD_WIDTH-1 : 0*CBUS_CMD_WIDTH] = cbus_cmd0;

// The command of the coherence bus is define according to the state of 
// cbus_active_broad_array and cbus_active_en_access_array
       //     \ /
assign cbus_cmd3 =
         // The broadcast proccess is active. Send the broadcast request 
         //                     \ /
         cbus_active_broad_array[3] ?
           broad_snoop_type_i == `MESI_ISC_BREQ_TYPE_WR ?
                                           `MESI_ISC_CBUS_CMD_WR_SNOOP:
                                           `MESI_ISC_CBUS_CMD_RD_SNOOP     :
         // All the broadcast proccesses were done. This CPU is the initiator
	 // of the request. Enable it to continue by send en_wr/en_rd
	 !(|cbus_active_broad_array)    &
         //                         \ /
         cbus_active_en_access_array[3] &
         ~broad_fifo_rd_o ?
           broad_snoop_type_i == `MESI_ISC_BREQ_TYPE_WR ?
                                           `MESI_ISC_CBUS_CMD_EN_WR:
                                           `MESI_ISC_CBUS_CMD_EN_RD        :
	                                   `MESI_ISC_CBUS_CMD_NOP;
       //     \ /
assign cbus_cmd2 =
         //                     \ /
         cbus_active_broad_array[2] ?
           broad_snoop_type_i == `MESI_ISC_BREQ_TYPE_WR ?
                                           `MESI_ISC_CBUS_CMD_WR_SNOOP:
                                           `MESI_ISC_CBUS_CMD_RD_SNOOP     :
	 !(|cbus_active_broad_array)    &
         //                         \ /
         cbus_active_en_access_array[2] &
         ~broad_fifo_rd_o ?
           broad_snoop_type_i == `MESI_ISC_BREQ_TYPE_WR ?
                                           `MESI_ISC_CBUS_CMD_EN_WR:
                                           `MESI_ISC_CBUS_CMD_EN_RD        :
	                                   `MESI_ISC_CBUS_CMD_NOP;
       //     \ /
assign cbus_cmd1 =
         //                     \ /
         cbus_active_broad_array[1] ?
           broad_snoop_type_i == `MESI_ISC_BREQ_TYPE_WR ?
                                           `MESI_ISC_CBUS_CMD_WR_SNOOP:
                                           `MESI_ISC_CBUS_CMD_RD_SNOOP     :
	 !(|cbus_active_broad_array)    &
         //                         \ /
         cbus_active_en_access_array[1] &
         ~broad_fifo_rd_o ?
           broad_snoop_type_i == `MESI_ISC_BREQ_TYPE_WR ?
                                           `MESI_ISC_CBUS_CMD_EN_WR:
                                           `MESI_ISC_CBUS_CMD_EN_RD        :
	                                   `MESI_ISC_CBUS_CMD_NOP;
       //     \ /
assign cbus_cmd0 =
         // Send read or write broad according to the type of the broad.
         //                     \ /
         cbus_active_broad_array[0] ?
           broad_snoop_type_i == `MESI_ISC_BREQ_TYPE_WR ?
                                           `MESI_ISC_CBUS_CMD_WR_SNOOP:
                                           `MESI_ISC_CBUS_CMD_RD_SNOOP     :
	 !(|cbus_active_broad_array)    &
         //                         \ /
         cbus_active_en_access_array[0] &
         ~broad_fifo_rd_o ?
           broad_snoop_type_i == `MESI_ISC_BREQ_TYPE_WR ?
                                           `MESI_ISC_CBUS_CMD_EN_WR:
                                           `MESI_ISC_CBUS_CMD_EN_RD        :

	                                   `MESI_ISC_CBUS_CMD_NOP;


// A broadcast process contains 5 sub-processes: Each one of the 4 CPU receives
// a snoop request and answers with an acknowledge. Then the initiator CPU
// receives an access enable and answer  answers with an acknowledge.
//
// The broadcast process *stages* are:
// 1. Curently there is no an active process. If there is a valid broadcast to
//  send then:
// 1.1 broadcast_in_progress   <= 1 : It represents an active process of
//     broadcast. It contains 4 snoop sub-processes and 1 enable sub-process. 
// 1.2 cbus_active_broad_array <= 4'b1111 : Each bit represents an active
//     sub-process, for each CPU - sending a snoop request and get an answer
//     with an acknowledge.
// 1.3 cbus_active_en_access_array[ID of initiator CPU] <= 1
//     The corresponding bit of the initiator CPU in the
//     cbus_active_en_access_array is set to enable in stage 4 to send an
//     enable-access to the initiator CPU.
// 2. cbus_active_broad_array[ID of CPU] <= 0
//    A snoop request is send for all the CPUs. For each CPU that answers with
//    acknowledge the corresponding bit is clear:
//    cbus_active_broad_array == 0
//    After all CPUs answer with acknowledge all the bits of 
//    cbus_active_broad_array are clear.
// 3. cbus_active_en_access_array[ID of initiator CPU] <= 0
//    broadcast_in_progress                            <= 0
//    The enable access is sent to the initiator CPU. When it answers with an
//    acknowledge then the broadcast process is finished:  the corresponding
//    bit in the cbus_active_en_access_array is clear and
//    the broadcast_in_progress is clear
//
//
// broadcast_in_progress
// There is an active action of the broadcast. Either not all CPU received the
// broadcast and return acknowledge. or the initiator CPU received the access
// enable and return acknowledge. 
//
// cbus_active_broad_array
// For each bit, when set - there is an active process of sending a snoop
// request and answering with an acknowledge.
// 
// cbus_active_en_access_array
// For each bit, when set -  there is an active process of sending 
// enable-access request to the initiator CPU and receive an acknowledge answer.
// The enable-access request is send only after all CPUs receive and approve
// the snoop requests.
//
// broad_fifo_rd_o
// When broadcast process in finish clear the corresponding entry from the fifo
always @(posedge clk or posedge rst)
  if (rst)
  begin
        broadcast_in_progress       <= 0;
        cbus_active_broad_array     <= 4'b0000; 
        cbus_active_en_access_array <= 4'b0000;
        broad_fifo_rd_o             <= 0;
  end
  else if (~broadcast_in_progress & ~broad_fifo_rd_o)
    if (~fifo_status_empty_i)
    // Stage 1
      begin
        broadcast_in_progress       <= 1;
        case (broad_snoop_cpu_id_i) // The initiator does not received a
	                            // broadcast for the same line it asks the
	                            // broadcast
          0:
          begin
            cbus_active_broad_array     <= 4'b1110;
	    cbus_active_en_access_array <= 4'b0001;
          end
          1:
          begin
            cbus_active_broad_array     <= 4'b1101;
	    cbus_active_en_access_array <= 4'b0010;
          end
          2:
          begin
            cbus_active_broad_array     <= 4'b1011;
	    cbus_active_en_access_array <= 4'b0100;
          end
          3:
          begin
            cbus_active_broad_array     <= 4'b0111;
	    cbus_active_en_access_array <= 4'b1000;
          end
          default
          begin
            cbus_active_broad_array     <= 4'b0000;
	    cbus_active_en_access_array <= 4'b0000;
          end
        endcase
        broad_fifo_rd_o             <= 0;
      end
    else // if (~fifo_status_empty_i)
    begin
        broadcast_in_progress       <= 0;
        cbus_active_broad_array     <= 4'b0000;
        cbus_active_en_access_array <= 4'b0000;
        broad_fifo_rd_o             <= 0;
    end
  else // if (~broadcast_in_progress)
    // Stage 2
    if (|cbus_active_broad_array)     // There is at least on active snoop
                                      //  sub-process
      begin
        broadcast_in_progress       <= 1;
	// Clear related sub-process of a CPU then returns ack for the snoop
        // request.
        cbus_active_broad_array     <= cbus_active_broad_array &
                                       ~cbus_ack_array_i;
        cbus_active_en_access_array <= cbus_active_en_access_array;
        broad_fifo_rd_o             <= 0;
      end
    // Stage 3
    else if (broad_fifo_rd_o)         // All snoop sub-process were done
      begin
        broadcast_in_progress       <= 0;
        cbus_active_broad_array     <= 0;
        cbus_active_en_access_array <= 0;
        broad_fifo_rd_o             <= 0;
      end
    else
      broad_fifo_rd_o <= !(|(cbus_active_en_access_and_not_cbus_ack_array));

assign cbus_active_en_access_and_not_cbus_ack_array =
        cbus_active_en_access_array  & ~cbus_ack_array_i;
   

endmodule
