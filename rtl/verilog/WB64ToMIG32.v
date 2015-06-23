`timescale 1ns / 1ps
// ============================================================================
//        __
//   \\__/ o\    (C) 2011-2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//  
//
// WB2MIG32.v
// - 64 bit WISHBONE to 32 bit MIG bus bridge
// - supports
//		constant address burst cycles
//		incrementing address burst cycles
//		classic bus cycles
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//                                                                          
// ============================================================================
//
//`define SUPPORT_INCADR	1
`define MAX_MEM		32'h07FF_FFFF
//
module WB64ToMIG32 (
input rst_i,
input clk_i,

// WISHBONE PORT
input [1:0] bte_i,					// burst type extension
input [2:0] cti_i,					// cycle type indicator
input cyc_i,						// cycle in progress
input stb_i,						// data strobe
output ack_o,						// acknowledge
input we_i,							// write cycle
input [7:0] sel_i,					// byte lane selects
input [63:0] adr_i,					// address
input [63:0] dat_i,					// data 
output reg [63:0] dat_o,
input [4:0] bl_i,					// burst length

// MIG port
input calib_done,
input cmd_full,
output reg cmd_en,
output reg [2:0] cmd_instr,
output reg [5:0] cmd_bl,
output reg [29:0] cmd_byte_addr,

output reg rd_en,
input [31:0] rd_data,
input rd_empty,

output reg wr_en,
output reg [3:0] wr_mask,
output reg [31:0] wr_data,
input wr_empty,
input wr_full
);
parameter IDLE = 4'd1;
parameter BWRITE_001a = 4'd2;
parameter BWRITE_001b = 4'd3;
parameter BWRITE_010a = 4'd4;
parameter BWRITE_010b = 4'd5;
parameter BWRITE_010c = 4'd6;
parameter BWRITE_010d = 4'd7;
parameter BWRITE_CMD = 4'd8;
parameter BREAD_001a = 4'd9;
parameter BREAD_001b = 4'd10;
parameter BREAD_010a = 4'd11;
parameter BREAD_010b = 4'd12;
parameter BREAD_010c = 4'd13;
parameter BREAD_010d = 4'd14;
parameter NACK = 4'd15;


// Fill write FIFO then issue write command
reg [5:0] ctr;		// burst length counter
reg [63:0] dato;
reg [3:0] state;
reg ack1;

wire cs = cyc_i && stb_i && (adr_i[59:32]==28'h0000001 || adr_i[63:36]==28'hE000000);		// circuit select
assign ack_o = ack1 & cs;		// Force ack_o low as soon as cyc_i or stb_i go low

always @(cs or adr_i or dato)
if (cs) begin
// The following test allows the startup code to determine how much memory is presnet.
// Otherwise, the code thinks there's more memory than there actually is, due to aliased
// addresses hit during the memory test.
	if (adr_i[31:0]>`MAX_MEM)
		dat_o <= 64'hDEADDEAD_DEADDEAD;
	else
		dat_o <= dato;
end
else
	dat_o <= 64'h00000000_00000000;	// Allow wire-or'ing data bus

reg [5:0] bl;
reg [63:0] prev_adr;

always @(posedge clk_i)
if (rst_i) begin
	ack1 <= 1'b0;
	ctr <= 6'd0;
	state <= IDLE;
end
else begin
cmd_en <= 1'b0;		// Forces cmd_en to be just a 1-cycle pulse
wr_en <= 1'b0;
case(state)
IDLE:
	if (cs & calib_done) begin
		ctr <= 6'd0;
		cmd_byte_addr <= {adr_i[29:2],2'b00};
		if (cti_i==3'b001)
			cmd_bl <= {bl_i,1'b1};
		else begin
			if (sel_i[3:0]==4'h0 || sel_i[7:4]==4'h0)
				cmd_bl <= 6'd0;		// single access required
			else
				cmd_bl <= 6'd1;		// double access required
		end
		cmd_instr <= we_i ? 3'b000 : 3'b001;	// WRITE or READ
		prev_adr <= adr_i;

		// Write cycles
		if (we_i) begin
			case(cti_i)
			3'b000,3'b111:
				// Writing for a half-word or less ?
				if (sel_i[3:0]==4'h0 || sel_i[7:4]==4'h0) begin
					if (!wr_full) begin
						ack1 <= 1'b1;
						wr_en <= 1'b1;
						// data will be reflected for sub-word writes
						// the same data is on [31:0] as is on [63:32]
						wr_data <= dat_i[31:0];
						wr_mask <= ~(sel_i[7:4]|sel_i[3:0]);
						state <= BWRITE_CMD;
					end
				end
				// Writing 2 32 bit words
				else begin
					if (wr_empty)
						state <= BWRITE_001a;
				end
			// Since we want to write a burst of numerous data, we wait until the
			// write FIFO is empty. We could wait until the FIFO count is greater
			// than the burst length.
			3'b001:
				if (wr_empty)
					state <= BWRITE_001a;
`ifdef SUPPORT_INCADR
			3'b010:
				if (wr_empty)
					state <= BWRITE_010a;
`endif
			default:	;
			endcase
		end
		// Read cycles
		else begin
			if (!cmd_full) begin
				cmd_en <= 1'b1;
				case(cti_i)
				3'b000:	state <= BREAD_001a;
				3'b001:	state <= BREAD_001a;
`ifdef SUPPORT_INCADR
				3'b010:	state <= BREAD_010a;
`endif
				3'b111:	state <= BREAD_001a;
				default:	;
				endcase
			end
		end
	end

//---------------------------------------------------------
// Burst write
//---------------------------------------------------------

// Constant address burst:
BWRITE_001a:
	begin
		ack1 <= 1'b0;
		if (stb_i) begin
			wr_en <= 1'b1;
			wr_data <= dat_i[31:0];
			wr_mask <= ~sel_i[3:0];
			ctr <= ctr + 6'd1;
			state <= BWRITE_001b;
		end
	end
BWRITE_001b:
	if (stb_i) begin
		ack1 <= 1'b1;
		wr_en <= 1'b1;
		wr_data <= dat_i[63:32];
		wr_mask <= ~sel_i[7:4];
		ctr <= ctr + 6'd1;
		if (ctr >= bl_i || cti_i==3'b000 || cti_i==3'b111 || !cyc_i)
			state <= BWRITE_CMD;
		else
			state <= BWRITE_001a;
	end
	else
		ack1 <= 1'b0;

`ifdef SUPPORT_INCADR
// Incrementing address burst:
// Write the first word
// Write subsequent words, checking for an address change
BWRITE_010a:
	begin
		ack1 <= 1'b0;
		if (stb_i) begin
			wr_en <= 1'b1;
			wr_data <= dat_i[31:0];
			wr_mask <= ~sel_i[3:0];
			ctr <= ctr + 6'd1;
			state <= BWRITE_010b;
		end
	end
BWRITE_010b:
	if (stb_i) begin
		ack1 <= 1'b1;
		wr_en <= 1'b1;
		wr_data <= dat_i[63:32];
		wr_mask <= ~sel_i[7:4];
		ctr <= ctr + 6'd1;
		if (ctr >= bl_i || cti_i==3'b000 || cti_i==3'b111 || !cyc_i)
			state <= BWRITE_CMD;
		else
			state <= BWRITE_010c;
	end
	else
		ack1 <= 1'b0;
BWRITE_010c:
	begin
		ack1 <= 1'b0;
		if (stb_i) begin
			if (adr_i!=prev_adr) begin
				prev_adr <= adr_i;
				wr_en <= 1'b1;
				wr_data <= dat_i[31:0];
				wr_mask <= ~sel_i[3:0];
				ctr <= ctr + 6'd1;
				state <= BWRITE_010d;
			end
		end
	end
BWRITE_010d:
	if (stb_i) begin
		ack1 <= 1'b1;
		wr_en <= 1'b1;
		wr_data <= dat_i[63:32];
		wr_mask <= ~sel_i[7:4];
		ctr <= ctr + 6'd1;
		if (ctr >= bl_i || cti_i==3'b000 || cti_i==3'b111 || !cyc_i)
			state <= BWRITE_CMD;
		else
			state <= BWRITE_010c;
	end
	else
		ack1 <= 1'b0;
`endif

BWRITE_CMD:
	begin
		if (cyc_i==1'b0)
			ack1 <= 1'b0;
		if (!cmd_full) begin
			cmd_en <= 1'b1;
			state <= NACK;
		end
	end

//---------------------------------------------------------
// Burst read or single read
//---------------------------------------------------------
BREAD_001a:
	begin
		rd_en <= 1'b1;
		ack1 <= 1'b0;
		if (rd_en & !rd_empty) begin
			dato <= {rd_data,rd_data};
			ctr <= ctr + 6'd1;
			if (sel_i[7:4]!=4'h0 && sel_i[3:0]!=4'h0 && cyc_i)
				state <= BREAD_001b;
			else begin
				ack1 <= 1'b1;
				state <= NACK;
			end
		end
	end
BREAD_001b:
	if (rd_en & !rd_empty) begin
		dato[63:32] <= rd_data;
		ack1 <= 1'b1;
		ctr <= ctr + 6'd1;
		if (ctr>={bl_i,1'b1} || !cyc_i || cti_i==3'b000 || cti_i==3'b111)
			state <= NACK;
		else
			state <= BREAD_001a;
	end

`ifdef SUPPORT_INCADR
BREAD_010a:
	begin
		rd_en <= 1'b1;
		ack1 <= 1'b0;
		if (rd_en & !rd_empty) begin
			prev_adr <= adr_i;
			dato <= {rd_data,rd_data};
			ctr <= ctr + 6'd1;
			state <= BREAD_010b;
		end
	end
BREAD_010b:
	if (rd_en & !rd_empty) begin
		rd_en <= 1'b0;
		dato[63:32] <= rd_data;
		ack1 <= 1'b1;
		ctr <= ctr + 6'd1;
		if (ctr>={bl_i,1'b1} || !cyc_i || cti_i==3'b000 || cti_i==3'b111)
			state <= NACK;
		else
			state <= BREAD_010c;
	end
BREAD_010c:
	begin
		ack1 <= 1'b0;
		if (adr_i != prev_adr) begin
			rd_en <= 1'b1;
			if (rd_en & !rd_empty) begin
				prev_adr <= adr_i;
				dato <= {rd_data,rd_data};
				ctr <= ctr + 6'd1;
				state <= BREAD_010d;
			end
		end
	end
BREAD_010d:
	if (rd_en & !rd_empty) begin
		rd_en <= 1'b0;
		ack1 <= 1'b1;
		dato[63:32] <= rd_data;
		ctr <= ctr + 6'd1;
		if (ctr >= bl_i || cti_i==3'b000 || cti_i==3'b111 || !cyc_i)
			state <= NACK;
		else
			state <= BREAD_010c;
	end
`endif

//---------------------------------------------------------
//---------------------------------------------------------
// If cyc_o went inactive during BWRITE_CMD (ack1==1'b0) then move
// to next state. cyc_i might have gone back to active as the next
// bus cycle could have started.
//
NACK:
	if (!cyc_i || ack1==1'b0) begin
		ack1 <= 1'b0;
		rd_en <= 1'b0;
		state <= IDLE;
	end
endcase
end
endmodule
