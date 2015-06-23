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
////  mesi_isc_breq_fifos_cntl                                    ////
////  -------------------                                         ////
////  Controls and muxes of the mesi_isc_breq_fifos. This module  ////
////  contains all the controls and logic of the                  ////
////  mesi_isc_breq_fifos_cntl                                    ////
////                                                              ////
////  To Do:                                                      ////
////   -                                                          ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "mesi_isc_define.v"

module mesi_isc_breq_fifos_cntl
    (
     // Inputs
     clk,
     rst,
     mbus_cmd_array_i,
     fifo_status_empty_array_i,
     fifo_status_full_array_i,
     broad_fifo_status_full_i,
     broad_addr_array_i,
     broad_type_array_i,
     broad_id_array_i,
     // Outputs
     mbus_ack_array_o,
     fifo_wr_array_o,
     fifo_rd_array_o,
     broad_fifo_wr_o,
     broad_addr_o,
     broad_type_o,
     broad_cpu_id_o,
     broad_id_o,
     breq_type_array_o,
     breq_cpu_id_array_o,
     breq_id_array_o
   );
   
parameter
  MBUS_CMD_WIDTH           = 3,
  ADDR_WIDTH               = 32,
  BROAD_TYPE_WIDTH         = 2,  
  BROAD_ID_WIDTH           = 7;
  
// Inputs
//================================
// System
input                   clk;          // System clock
input                   rst;          // Active high system reset

// Main buses
// The mbus commands, according to the commend the breq are written to
// the fifos
input [4*MBUS_CMD_WIDTH-1:0] mbus_cmd_array_i;
// cntl
// breq fifo status
input [3:0]             fifo_status_empty_array_i;       
input [3:0]             fifo_status_full_array_i;
// broad_fifo
// breqs can be written to the broad fifo when it is not full
input                   broad_fifo_status_full_i;
// mux
// The mux sends to the broad fifo one of the broad from the 4 breq fifos.
// It sends: address. type, cpu_id, broad_id
input [4*ADDR_WIDTH-1      :0] broad_addr_array_i;
input [4*BROAD_TYPE_WIDTH-1:0] broad_type_array_i;
input [4*BROAD_ID_WIDTH-1  :0] broad_id_array_i;
     
// Outputs
// Main busses
// When a breq is stored to a fifo an acknowledge is send to the initiator
output [3:0]            mbus_ack_array_o;
// cntl
// Write the breq to one of the fifos
output [3:0]            fifo_wr_array_o;
// Read a breq toward the broad fifo
output [3:0]            fifo_rd_array_o; 
// broad_fifo
// Command to fifo for a broad in the broad fifo
output                  broad_fifo_wr_o;
// The broad information that is send to the broad fifo: address. type, cpu_id
// and broad_id
output [ADDR_WIDTH-1      :0] broad_addr_o;
output [BROAD_TYPE_WIDTH-1:0] broad_type_o;
output [1:0]                  broad_cpu_id_o;
output [BROAD_ID_WIDTH-1:  0] broad_id_o;
// fifo inputs
// Some of the breq fifo input are manipulate before storing
// The type in manipulation of the mbus command
output [4*BROAD_TYPE_WIDTH-1:0] breq_type_array_o;
// Each CPU has a fixed ID
output [4*2-1:0]              breq_cpu_id_array_o;
// Each breq has a unique ID.
output [4*BROAD_ID_WIDTH-1:0] breq_id_array_o;

// Regs & wires
//================================
reg [3:0]               mbus_ack_array;
reg [3:0]               fifos_priority; // A one hot priority between the 
                                      // breq fifos toward the broad fifo
wire [3:0]              fifos_priority_barrel_shiftl_1,
                        fifos_priority_barrel_shiftl_2,
                        fifos_priority_barrel_shiftl_3;
wire [3:0]              fifo_select_oh; // A one hot control of the mux between
                                        // breq fifos toward the broad fifo
reg  [BROAD_ID_WIDTH-3:0] breq_id_base; // breq_id_base is the base value of
                                        // the IDs. breq_id_base = breq_id/4
   
wire [MBUS_CMD_WIDTH-1:0] mbus_cmd_array_i_3,
			  mbus_cmd_array_i_2,
			  mbus_cmd_array_i_1,
			  mbus_cmd_array_i_0;
reg [4*BROAD_TYPE_WIDTH-1:0] breq_type_array_o;
  
// Assigns for outputs
//================================
assign mbus_ack_array_o   = mbus_ack_array;


// fifo_rd_array_o, broad_fifo_wr_o
// Read the breq from one of the breq fifos and write it to the broad fifo.   
assign fifo_rd_array_o = {4{~broad_fifo_status_full_i}} & // There is space in
			              // the broad fifo
		         fifo_select_oh[3:0]; // The highest priority
			              // fifo that has a valid breq.
assign broad_fifo_wr_o = |fifo_rd_array_o[3:0]; // Write to the broad fifo is 
                                      // done in parallel to Read from one of
                                      // the breq fifo The values set
   
// fifos_priority, fifos_priority_barrel_shift_1/2/3 (one hot)
// The priority between the CPU is done in round robin order.
// The breq which is sent to the broad fifo is selected according to 
// the value of the fifos_priority register, from the low value to the high 
// value.
// For example when fifos_priority == 2 then the priority order is:
//  2 -> 3 -> 0 -> 1. The breq is sent from the first breq fifo, in that order,
// that has a valid breq.
// The priority is change whenever a breq is sent to the broad fifo  
always @(posedge clk or posedge rst)
 if (rst)
   fifos_priority <= 1;
 else if (broad_fifo_wr_o)
   fifos_priority[3:0] <= fifos_priority_barrel_shiftl_1[3:0];

assign fifos_priority_barrel_shiftl_3[3:0] =
                                    {fifos_priority[0]  , fifos_priority[3:1]};
assign fifos_priority_barrel_shiftl_2[3:0] =
                                    {fifos_priority[1:0], fifos_priority[3:2]};
assign fifos_priority_barrel_shiftl_1[3:0] =
                                    {fifos_priority[2:0], fifos_priority[3]};
   
// fifo_select_oh (one hot)
// Points to the highest priority fifo (see fifos_priority) that
// has a valid breq.
// The control of the mux from the breq fifos to the broad fifo.
assign fifo_select_oh[3:0] =
          // If the 1st highest priority fifo is not empty then select it
	  // Or the bit-wise results of the following formula to one result   
	  // Bit-wise set for fifos that are not empty 
          |(~fifo_status_empty_array_i[3:0] &
	     // Bit-wise one hot priority for the 1st highest priority
             fifos_priority[3:0]                 ) ?
                                          fifos_priority[3:0]                 :
          |(~fifo_status_empty_array_i[3:0] &
             fifos_priority_barrel_shiftl_1[3:0] ) ?
                                          fifos_priority_barrel_shiftl_1[3:0] :
          |(~fifo_status_empty_array_i[3:0] &
             fifos_priority_barrel_shiftl_2[3:0] ) ?
                                          fifos_priority_barrel_shiftl_2[3:0] :
          |(~fifo_status_empty_array_i[3:0] &
             fifos_priority_barrel_shiftl_3[3:0] ) ?
                                          fifos_priority_barrel_shiftl_3[3:0] :
                                          4'd0;
   
// broad_addr_o, broad_type_o, broad_cpu_id_o, broad_id_o
// One hot mux
assign broad_addr_o[ADDR_WIDTH-1:0] = 
            broad_addr_array_i[(3+1)*ADDR_WIDTH-1 : 3*ADDR_WIDTH] &
                                              {ADDR_WIDTH{fifo_select_oh[3]}} |
            broad_addr_array_i[(2+1)*ADDR_WIDTH-1 : 2*ADDR_WIDTH] &
                                              {ADDR_WIDTH{fifo_select_oh[2]}} |
            broad_addr_array_i[(1+1)*ADDR_WIDTH-1 : 1*ADDR_WIDTH] &
                                              {ADDR_WIDTH{fifo_select_oh[1]}} |
            broad_addr_array_i[(0+1)*ADDR_WIDTH-1 : 0*ADDR_WIDTH] &
                                              {ADDR_WIDTH{fifo_select_oh[0]}};
assign broad_type_o[BROAD_TYPE_WIDTH-1:0] = 
            broad_type_array_i[(3+1)*BROAD_TYPE_WIDTH-1 : 3*BROAD_TYPE_WIDTH] &
                                        {BROAD_TYPE_WIDTH{fifo_select_oh[3]}} |
            broad_type_array_i[(2+1)*BROAD_TYPE_WIDTH-1 : 2*BROAD_TYPE_WIDTH] &
                                        {BROAD_TYPE_WIDTH{fifo_select_oh[2]}} |
            broad_type_array_i[(1+1)*BROAD_TYPE_WIDTH-1 : 1*BROAD_TYPE_WIDTH] &
                                        {BROAD_TYPE_WIDTH{fifo_select_oh[1]}} |
            broad_type_array_i[(0+1)*BROAD_TYPE_WIDTH-1 : 0*BROAD_TYPE_WIDTH] &
                                        {BROAD_TYPE_WIDTH{fifo_select_oh[0]}};
// Each CPU has a fixed ID
assign broad_cpu_id_o[1:0] = 2'd3 & {2{fifo_select_oh[3]}} |
	                     2'd2 & {2{fifo_select_oh[2]}} |  
		             2'd1 & {2{fifo_select_oh[1]}} |  
			     2'd0 & {2{fifo_select_oh[0]}};
   
assign broad_id_o[BROAD_ID_WIDTH-1:0] =
            broad_id_array_i[(3+1)*BROAD_ID_WIDTH-1 : 3*BROAD_ID_WIDTH] &
                                          {BROAD_ID_WIDTH{fifo_select_oh[3]}} |
            broad_id_array_i[(2+1)*BROAD_ID_WIDTH-1 : 2*BROAD_ID_WIDTH] &
                                          {BROAD_ID_WIDTH{fifo_select_oh[2]}} |
            broad_id_array_i[(1+1)*BROAD_ID_WIDTH-1 : 1*BROAD_ID_WIDTH] &
                                          {BROAD_ID_WIDTH{fifo_select_oh[1]}} |
            broad_id_array_i[(0+1)*BROAD_ID_WIDTH-1 : 0*BROAD_ID_WIDTH] &
                                          {BROAD_ID_WIDTH{fifo_select_oh[0]}};
		    
//fifo_wr_array
// Write the breq into the fifo.
// When an acknowledge is sent to the mbus the breq is written to the fifo.
assign fifo_wr_array_o[3:0] = mbus_ack_array[3:0];
   
// mbus_ack_array
// The mbus ack is an indication for the mbus that the (broadcast) transaction
// was received and it can proceed to the next transaction (or to nop).
// The acknowledge is sent to the mbus when the breq can be stored in the fifo.
// The acknowledge can't be asserted for more then one cycle for simplification
// of the protocol and timing paths. 
always @(posedge clk or posedge rst)
  if (rst)
     mbus_ack_array[3:0] <= 0;
  else
  begin
     mbus_ack_array[3] <= ~mbus_ack_array[3] &
                          (mbus_cmd_array_i_3 == `MESI_ISC_MBUS_CMD_WR_BROAD |
                           mbus_cmd_array_i_3 == `MESI_ISC_MBUS_CMD_RD_BROAD )&
                          fifo_status_full_array_i[3] == 0;
     mbus_ack_array[2] <= ~mbus_ack_array[2] &
                          (mbus_cmd_array_i_2 == `MESI_ISC_MBUS_CMD_WR_BROAD |
                           mbus_cmd_array_i_2 == `MESI_ISC_MBUS_CMD_RD_BROAD )&
                          fifo_status_full_array_i[2] == 0;
     mbus_ack_array[1] <= ~mbus_ack_array[1] &
                          (mbus_cmd_array_i_1 == `MESI_ISC_MBUS_CMD_WR_BROAD |
                           mbus_cmd_array_i_1 == `MESI_ISC_MBUS_CMD_RD_BROAD )&
                          fifo_status_full_array_i[1] == 0;
     mbus_ack_array[0] <= ~mbus_ack_array[0] &
                          (mbus_cmd_array_i_0 == `MESI_ISC_MBUS_CMD_WR_BROAD |
                           mbus_cmd_array_i_0 == `MESI_ISC_MBUS_CMD_RD_BROAD )&
                          fifo_status_full_array_i[0] == 0;
     
  end

assign mbus_cmd_array_i_3[MBUS_CMD_WIDTH-1:0] =
                   mbus_cmd_array_i[(3+1)*MBUS_CMD_WIDTH-1 : 3*MBUS_CMD_WIDTH];
assign mbus_cmd_array_i_2[MBUS_CMD_WIDTH-1:0] =
                   mbus_cmd_array_i[(2+1)*MBUS_CMD_WIDTH-1 : 2*MBUS_CMD_WIDTH];
assign mbus_cmd_array_i_1[MBUS_CMD_WIDTH-1:0] =
                   mbus_cmd_array_i[(1+1)*MBUS_CMD_WIDTH-1 : 1*MBUS_CMD_WIDTH];
assign mbus_cmd_array_i_0[MBUS_CMD_WIDTH-1:0] =
                   mbus_cmd_array_i[(0+1)*MBUS_CMD_WIDTH-1 : 0*MBUS_CMD_WIDTH];
   
// The breq type depends on the mbus command.
// Mbus: Write broadcast - breq type: wr
// Mbus: Read broadcast  - breq type: rd
// Mbus: else            - breq type: nop
always @(posedge clk or posedge rst)
 if (rst)
   breq_type_array_o[4*BROAD_TYPE_WIDTH-1:0] <= 0;
 else begin 
       //                \ /                      \ /
       breq_type_array_o[(3+1)*BROAD_TYPE_WIDTH-1: 3*BROAD_TYPE_WIDTH] =
        //              \ /
        mbus_cmd_array_i_3[MBUS_CMD_WIDTH-1:0] == `MESI_ISC_MBUS_CMD_WR_BROAD ?
                                                     `MESI_ISC_BREQ_TYPE_WR:
	//              \ /
        mbus_cmd_array_i_3[MBUS_CMD_WIDTH-1:0] == `MESI_ISC_MBUS_CMD_RD_BROAD ?
                                                     `MESI_ISC_BREQ_TYPE_RD:
                                                     `MESI_ISC_BREQ_TYPE_NOP;
       //                \ /                      \ /
       breq_type_array_o[(2+1)*BROAD_TYPE_WIDTH-1: 2*BROAD_TYPE_WIDTH] =
        //              \ /
        mbus_cmd_array_i_2[MBUS_CMD_WIDTH-1:0] == `MESI_ISC_MBUS_CMD_WR_BROAD ?
                                                     `MESI_ISC_BREQ_TYPE_WR:
        //              \ /
        mbus_cmd_array_i_2[MBUS_CMD_WIDTH-1:0] == `MESI_ISC_MBUS_CMD_RD_BROAD ?
                                                     `MESI_ISC_BREQ_TYPE_RD:
                                                     `MESI_ISC_BREQ_TYPE_NOP;
       //                \ /                      \ /
       breq_type_array_o[(1+1)*BROAD_TYPE_WIDTH-1: 1*BROAD_TYPE_WIDTH] =
        //              \ /
        mbus_cmd_array_i_1[MBUS_CMD_WIDTH-1:0] == `MESI_ISC_MBUS_CMD_WR_BROAD ?
                                                     `MESI_ISC_BREQ_TYPE_WR:
	//              \ /
        mbus_cmd_array_i_1[MBUS_CMD_WIDTH-1:0] == `MESI_ISC_MBUS_CMD_RD_BROAD ?
                                                     `MESI_ISC_BREQ_TYPE_RD:
                                                     `MESI_ISC_BREQ_TYPE_NOP;
       //                \ /                      \ /
       breq_type_array_o[(0+1)*BROAD_TYPE_WIDTH-1: 0*BROAD_TYPE_WIDTH] =
        //              \ /
        mbus_cmd_array_i_0[MBUS_CMD_WIDTH-1:0] == `MESI_ISC_MBUS_CMD_WR_BROAD ?
                                                     `MESI_ISC_BREQ_TYPE_WR:
	//              \ /
        mbus_cmd_array_i_0[MBUS_CMD_WIDTH-1:0] == `MESI_ISC_MBUS_CMD_RD_BROAD ?
                                                     `MESI_ISC_BREQ_TYPE_RD:
                                                     `MESI_ISC_BREQ_TYPE_NOP;

end
// The CPU IDs have fixed values
assign breq_cpu_id_array_o[(3+1)*2-1 : 3*2] = 3;
assign breq_cpu_id_array_o[(2+1)*2-1 : 2*2] = 2;
assign breq_cpu_id_array_o[(1+1)*2-1 : 1*2] = 1;
assign breq_cpu_id_array_o[(0+1)*2-1 : 0*2] = 0;

// breq_id_array_o
// In a cycle that at least on breq is received there are 4 unique numbers -
// one for each fifo. These numbers are the breq ID. In a cycle that a certain
// fifo does not receive a breq (but there is at least one more fifos that  
// receives) then its unique number in that cycle is not used.
// The values of breq_id are cyclic and every specific amount of breqs its  
// value go back to 0. The possible different values of breq_id are much bigger
// then 4*(the latency of mesi_isc). In that way it is not possible that the
// same ID is used for more then one request in the same time.
// 
// fifo 0 ID (for each cycle) is breq_id_base*4
// fifo 1 ID is breq_id_base*4 + 1
// fifo 1 ID is breq_id_base*4 + 2
// fifo 1 ID is breq_id_base*4 + 3
assign breq_id_array_o[(3+1)*BROAD_ID_WIDTH-1 : 3*BROAD_ID_WIDTH] =
                                   {breq_id_base[BROAD_ID_WIDTH-3 : 0], 2'b00};
assign breq_id_array_o[(2+1)*BROAD_ID_WIDTH-1 : 2*BROAD_ID_WIDTH] =
                                   {breq_id_base[BROAD_ID_WIDTH-3 : 0], 2'b01};
assign breq_id_array_o[(1+1)*BROAD_ID_WIDTH-1 : 1*BROAD_ID_WIDTH] =
                                   {breq_id_base[BROAD_ID_WIDTH-3 : 0], 2'b10};
assign breq_id_array_o[(0+1)*BROAD_ID_WIDTH-1 : 0*BROAD_ID_WIDTH] =
                                   {breq_id_base[BROAD_ID_WIDTH-3 : 0], 2'b11};
							       
// The least significant bits of breq_id_base are always 0
always @(posedge clk or posedge rst)
 if (rst)
   breq_id_base[BROAD_ID_WIDTH-3 : 0] <= 0;
 else if (|fifo_wr_array_o)
  //  breq_id_base+1 is analogous to  breq_id+4
  breq_id_base[BROAD_ID_WIDTH-3 : 0] <= breq_id_base[BROAD_ID_WIDTH-3 : 0] + 1;
   
endmodule
    