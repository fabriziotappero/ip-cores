
//-----------------------------------------------------------------------------
//
// (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : V5-Block Plus for PCI Express
// File       : cmm_intr.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------

`define FFD 1

module cmm_intr (
                signaledint,         // Outputs
                intr_req_valid,
                intr_req_type,
                intr_rdy,
                cfg_interrupt_n,     // Inputs
                cfg_interrupt_assert_n, 
                cfg_interrupt_di,
                cfg_interrupt_mmenable,
                msi_data,
                intr_vector,
                command,
                msi_control,
                msi_laddr,
                msi_haddr,
                intr_grant,
                cfg,
                rst,
                clk
                ) /* synthesis syn_hier ="hard"*/;

//This indicates (to Status register) that a Legacy Interrupt has been sent
output         signaledint;          // Outputs
output         intr_req_valid;
output  [1:0]  intr_req_type; 
output         intr_rdy; 

output [7:0]   intr_vector;
input          cfg_interrupt_assert_n;
input  [7:0]   cfg_interrupt_di;
input  [15:0]  msi_data;
input  [2:0]   cfg_interrupt_mmenable;
input          cfg_interrupt_n;     // Inputs
input  [15:0]  command; 
input  [15:0]  msi_control; 
input  [31:0]  msi_laddr; 
input  [31:0]  msi_haddr; 
input          intr_grant; 
input [1023:0] cfg;
input          rst; 
input          clk;    

reg         signaledint;          // Outputs
wire        intr_rdy; 

reg         q_intr_req_valid;
reg  [1:0]  q_intr_req_type; 

// notes 
// msi_control[0] is msi_mode
// 64 bit address capable bit 7 of message control
// This design supports only one message 
// command [10] is interrupt disable

parameter [1:0] IDLE          = 2'b00;
parameter [1:0] SEND_MSI      = 2'b01;
parameter [1:0] SEND_ASSERT   = 2'b10;
parameter [1:0] SEND_DEASSERT = 2'b11;

wire msi_64;
wire msi_mode;
wire intx_mode;
wire bus_master_en;
wire intr_req;
reg       allow_int;
reg [1:0] state;
reg [1:0] next_state;

assign msi_64 = msi_control[7] &&  (msi_haddr != 0); 
assign msi_mode      = msi_control[0]; 
assign intx_mode     = ~command[10]; 
assign bus_master_en = command[2];
assign intr_req = !cfg_interrupt_n && allow_int;  

reg intr_req_q = 0;
reg intr_rdyx  = 0;
reg cfg_interrupt_assert_n_q = 1;
reg [7:0] cfg_interrupt_di_q = 0;
reg [7:0] intr_vector        = 0;

always @(posedge clk or posedge rst) begin
   if (rst) begin 
      intr_req_q <= #`FFD 1'b0;
      allow_int  <= #`FFD 1'b0;
      intr_rdyx  <= #`FFD 1'b0;
      cfg_interrupt_assert_n_q  <= #`FFD 1'b1;
   end else begin 
      intr_req_q <= #`FFD intr_req;
      allow_int  <= #`FFD ((msi_mode && bus_master_en) || (!msi_mode && intx_mode));  
      intr_rdyx  <= #`FFD (state != IDLE) && intr_grant;
      cfg_interrupt_assert_n_q  <= #`FFD cfg_interrupt_assert_n;
   end
end

always @(posedge clk) begin
   cfg_interrupt_di_q <= #`FFD cfg_interrupt_di;
end

always @(posedge clk) begin
   //This override will permit the user to alter all 8 MSI bits
   if (cfg[467]) begin
     intr_vector          <= #`FFD cfg_interrupt_di_q[7:0];
   end else if (intr_req_q) begin 
     casez ({msi_mode,cfg_interrupt_mmenable})
     4'b0???: intr_vector <= #`FFD cfg_interrupt_di_q[7:0];
     4'b1000: intr_vector <= #`FFD msi_data[7:0];
     4'b1001: intr_vector <= #`FFD {msi_data[7:1],cfg_interrupt_di_q[0]};
     4'b1010: intr_vector <= #`FFD {msi_data[7:2],cfg_interrupt_di_q[1:0]};
     4'b1011: intr_vector <= #`FFD {msi_data[7:3],cfg_interrupt_di_q[2:0]};
     4'b1100: intr_vector <= #`FFD {msi_data[7:4],cfg_interrupt_di_q[3:0]};
     4'b1101: intr_vector <= #`FFD {msi_data[7:5],cfg_interrupt_di_q[4:0]};
     default: intr_vector <= #`FFD {msi_data[7:5],cfg_interrupt_di_q[4:0]};
     endcase
   end
end

wire        intr_req_valid = q_intr_req_valid;
wire [1:0]  intr_req_type  = q_intr_req_type;
reg         intr_rdy_q;

always @(posedge clk) begin
   if (rst) begin
      intr_rdy_q     <= #`FFD 0;
   end else begin
      intr_rdy_q     <= #`FFD intr_rdy;
   end
end

wire send_assert;
wire send_deassert;
wire send_msi;

assign send_assert  = !msi_mode && intr_req_q && ~cfg_interrupt_assert_n_q && 
                      ~(intr_rdy || intr_rdy_q);
assign send_deassert= !msi_mode && intr_req_q &&  cfg_interrupt_assert_n_q &&
                      ~(intr_rdy || intr_rdy_q);
assign send_msi     =  msi_mode && intr_req_q &&
                      ~(intr_rdy || intr_rdy_q);

always @(posedge clk) begin
   if (rst) begin
      state          <= #`FFD IDLE;
   end
   else begin
      state          <= #`FFD next_state;
   end
end 

always @*
begin
   next_state = IDLE;
   signaledint = 0;
   q_intr_req_type = 0;
   q_intr_req_valid = 0;

   case (state) // synthesis full_case parallel_case 
      IDLE : begin
                q_intr_req_type = 0;
                q_intr_req_valid = 0;
                signaledint = 0;

                if (send_msi) begin
                   next_state = SEND_MSI;
                end
                else if (send_assert) begin
                   next_state = SEND_ASSERT;
                end
                else if (send_deassert) begin
                   next_state = SEND_DEASSERT;
                end
                else begin
                   next_state = IDLE;
                end
             end
  SEND_MSI : begin
                q_intr_req_type = msi_64 ? 2'b11 : 2'b10;

                if (intr_grant) begin
                   q_intr_req_valid = 0;
                   next_state = IDLE;
                   signaledint = 0;
                end
                else begin
                   q_intr_req_valid = 1;
                   next_state = SEND_MSI;
                   signaledint = 0;
                end
             end
 SEND_ASSERT : begin
                q_intr_req_type = 2'b00;

                if (intr_grant) begin
                   q_intr_req_valid = 0;
                   next_state = IDLE;
                   signaledint = 1;
                end
                else begin
                   q_intr_req_valid = 1;
                   next_state = SEND_ASSERT;
                   signaledint = 0;
                end
             end
 SEND_DEASSERT : begin
                q_intr_req_type = 2'b01;

                if (intr_grant) begin
                   q_intr_req_valid = 0;
                   next_state = IDLE;
                   signaledint = 1;
                end
                else begin
                   q_intr_req_valid = 1;
                   next_state = SEND_DEASSERT;
                   signaledint = 0;
                end
             end
   endcase
end

assign intr_rdy = intr_rdyx;

endmodule
