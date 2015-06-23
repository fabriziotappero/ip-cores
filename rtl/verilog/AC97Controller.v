`timescale 1ns / 1ps
//=============================================================================
// (C) 2012 Robert Finch
//	All rights reserved.
//
// AC97.v
//	AC97 controller interface to LM4550
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
//=============================================================================

//
// This core uses a shadow register set that would be mapped into the I/O space
// of the host controller to hold the contents of the LM4550 registers. The core
// tracks updates to the LM4550 registers and writes the updates out as the
// AC97 frame becomes available.
//
module AC97(rst_i, clk_i, cyc_i, stb_i, ack_o, we_i, adr_i, dat_i, dat_o,
	PSGout,
	BIT_CLK, SYNC, SDATA_IN, SDATA_OUT, RESET
);
input rst_i;
input clk_i;
input cyc_i;
input stb_i;
output ack_o;
input we_i;
input [63:0] adr_i;
input [15:0] dat_i;
output [15:0] dat_o;
reg [15:0] dat_o;

input [17:0] PSGout;

input BIT_CLK;
output SYNC;
input SDATA_IN;
output SDATA_OUT;
output RESET;

wire cs = cyc_i && stb_i && (adr_i[63:8]==56'hFFFF_FFFF_FFDC_10);
reg ack1;
always @(posedge clk_i)
	ack1 <= cs & !ack1;
assign ack_o = cs ? (we_i ? 1'b1 : ack1) : 1'b0;

reg codecReady;
reg [15:0] slot0;
reg [19:0] slot1;
reg [19:0] slot2;
reg [19:0] slot3;
reg [19:0] slot4;
reg [19:0] slot5;
reg [19:0] slot6;
reg [19:0] slot7;
reg [19:0] slot8;
reg [19:0] slot9;
reg [19:0] slot10;
reg [19:0] slot11;
reg [19:0] slot12;
reg [4:0] rgno;

wire [15:0] slot0i;
wire [19:0] slot1i;
wire [19:0] slot2i;
reg [15:0] reg26;

// There's really only 27 registers in the LM4550. A couple of address maps are
// used to compress the register addresses so that a smaller shadow RAM can be
// used.
function [6:0] fnRealToLM4550RegMap;
input [4:0] realreg;
begin
case(realreg)
5'd0:	fnRealToLM4550RegMap = 7'h00;
5'd1:	fnRealToLM4550RegMap = 7'h02;
5'd2:	fnRealToLM4550RegMap = 7'h04;
5'd3:	fnRealToLM4550RegMap = 7'h06;
5'd4:	fnRealToLM4550RegMap = 7'h0A;
5'd5:	fnRealToLM4550RegMap = 7'h0C;
5'd6:	fnRealToLM4550RegMap = 7'h0E;
5'd7:	fnRealToLM4550RegMap = 7'h10;
5'd8:	fnRealToLM4550RegMap = 7'h12;
5'd9:	fnRealToLM4550RegMap = 7'h14;
5'd10:	fnRealToLM4550RegMap = 7'h16;
5'd11:	fnRealToLM4550RegMap = 7'h18;
5'd12:	fnRealToLM4550RegMap = 7'h1A;
5'd13:	fnRealToLM4550RegMap = 7'h1C;
5'd14:	fnRealToLM4550RegMap = 7'h20;
5'd15:	fnRealToLM4550RegMap = 7'h22;
5'd16:	fnRealToLM4550RegMap = 7'h24;
5'd17:	fnRealToLM4550RegMap = 7'h26;
5'd18:	fnRealToLM4550RegMap = 7'h28;
5'd19:	fnRealToLM4550RegMap = 7'h2A;
5'd20:	fnRealToLM4550RegMap = 7'h2C;
5'd21:	fnRealToLM4550RegMap = 7'h32;
5'd22:	fnRealToLM4550RegMap = 7'h5A;
5'd23:	fnRealToLM4550RegMap = 7'h74;
5'd24:	fnRealToLM4550RegMap = 7'h7A;
5'd25:	fnRealToLM4550RegMap = 7'h7C;
5'd26:	fnRealToLM4550RegMap = 7'h7E;
// These registers aren't part of the real LM4550
// They are provided as a scratchpad space.
5'd27:	fnRealToLM4550RegMap = 7'h60;
5'd28:	fnRealToLM4550RegMap = 7'h62;
5'd29:	fnRealToLM4550RegMap = 7'h64;
5'd30:	fnRealToLM4550RegMap = 7'h66;
5'd31:	fnRealToLM4550RegMap = 7'h68;
default:	fnRealToLM4550RegMap = 7'd00;
endcase
end
endfunction

function [4:0] fnLM4550ToRealRegMap;
input [6:0] regno;
begin
case (regno)
7'h00:	fnLM4550ToRealRegMap = 5'd0;
7'h02:	fnLM4550ToRealRegMap = 5'd1;
7'h04:	fnLM4550ToRealRegMap = 5'd2;
7'h06:	fnLM4550ToRealRegMap = 5'd3;
7'h0A:	fnLM4550ToRealRegMap = 5'd4;
7'h0C:	fnLM4550ToRealRegMap = 5'd5;
7'h0E:	fnLM4550ToRealRegMap = 5'd6;
7'h10:	fnLM4550ToRealRegMap = 5'd7;
7'h12:	fnLM4550ToRealRegMap = 5'd8;
7'h14:	fnLM4550ToRealRegMap = 5'd9;
7'h16:	fnLM4550ToRealRegMap = 5'd10;
7'h18:	fnLM4550ToRealRegMap = 5'd11;
7'h1A:	fnLM4550ToRealRegMap = 5'd12;
7'h1C:	fnLM4550ToRealRegMap = 5'd13;
7'h20:	fnLM4550ToRealRegMap = 5'd14;
7'h22:	fnLM4550ToRealRegMap = 5'd15;
7'h24:	fnLM4550ToRealRegMap = 5'd16;
7'h26:	fnLM4550ToRealRegMap = 5'd17;
7'h28:	fnLM4550ToRealRegMap = 5'd18;
7'h2A:	fnLM4550ToRealRegMap = 5'd19;
7'h2C:	fnLM4550ToRealRegMap = 5'd20;
7'h32:	fnLM4550ToRealRegMap = 5'd21;
7'h5A:	fnLM4550ToRealRegMap = 5'd22;
7'h74:	fnLM4550ToRealRegMap = 5'd23;
7'h7A:	fnLM4550ToRealRegMap = 5'd24;
7'h7C:	fnLM4550ToRealRegMap = 5'd25;
7'h7E:	fnLM4550ToRealRegMap = 5'd26;
// These registers aren't part of the real LM4550
// They are provided as a scratchpad space.
7'h60:	fnLM4550ToRealRegMap = 5'd27;
7'h62:	fnLM4550ToRealRegMap = 5'd28;
7'h64:	fnLM4550ToRealRegMap = 5'd29;
7'h66:	fnLM4550ToRealRegMap = 5'd30;
7'h68:	fnLM4550ToRealRegMap = 5'd31;
default:	fnLM4550ToRealRegMap = 5'd31;
endcase
end
endfunction

//---------------------------------------------------------------------
// Shadow registers
//---------------------------------------------------------------------
reg [31:0] dirty;			// Indicates which registers need to be written to the LM4550
reg [15:0] regfile [0:31];	// Mimic registers
wire [15:0] rfrgno = regfile[rgno];
wire [15:0] rfadri = regfile[fnLM4550ToRealRegMap(adr_i[6:0])];

// Shadow register write
always @(posedge clk_i)
begin
	if (cs & we_i) begin
		regfile[fnLM4550ToRealRegMap(adr_i[6:0])] <= dat_i;
	end
end

// Shadow register read
// Several of the LM4550 registers are read-only static values.
// They are just hard-coded here.
always @(posedge clk_i)
	if (cs) begin
		case (adr_i[6:0])
		7'h00:	dat_o <= 16'h0D50;
		7'h22:	dat_o <= 16'h0101;
		7'h26:	dat_o <= reg26;
		7'h5A:	dat_o <= 16'h0000;
		7'h68:	dat_o <= {16{|dirty}};
		7'h74:	dat_o <= 16'h0000;
		7'h7C:	dat_o <= 16'h4E53;
		7'h7E:	dat_o <= 16'h4350;
		default:	dat_o <= rfadri;
		endcase
	end
	else
		dat_o <= 16'h0000;

//---------------------------------------------------------------------
// Update to read LM4550 registers
//
// Only one register at a time may be written to the LM4550. Choose
// a register based on which dirty bit is set. The dirty bit is reset
// once the register is written to the LM4550.
//---------------------------------------------------------------------
always @(posedge clk_i)
casex(dirty)
32'b1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:	rgno <= 5'd31;
32'b01xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:	rgno <= 5'd30;
32'b001xxxxxxxxxxxxxxxxxxxxxxxxxxxxx:	rgno <= 5'd29;
32'b0001xxxxxxxxxxxxxxxxxxxxxxxxxxxx:	rgno <= 5'd28;
32'b00001xxxxxxxxxxxxxxxxxxxxxxxxxxx:	rgno <= 5'd27;
32'b000001xxxxxxxxxxxxxxxxxxxxxxxxxx:	rgno <= 5'd26;
32'b0000001xxxxxxxxxxxxxxxxxxxxxxxxx:	rgno <= 5'd25;
32'b00000001xxxxxxxxxxxxxxxxxxxxxxxx:	rgno <= 5'd24;
32'b000000001xxxxxxxxxxxxxxxxxxxxxxx:	rgno <= 5'd23;
32'b0000000001xxxxxxxxxxxxxxxxxxxxxx:	rgno <= 5'd22;
32'b00000000001xxxxxxxxxxxxxxxxxxxxx:	rgno <= 5'd21;
32'b000000000001xxxxxxxxxxxxxxxxxxxx:	rgno <= 5'd20;
32'b0000000000001xxxxxxxxxxxxxxxxxxx:	rgno <= 5'd19;
32'b00000000000001xxxxxxxxxxxxxxxxxx:	rgno <= 5'd18;
32'b000000000000001xxxxxxxxxxxxxxxxx:	rgno <= 5'd17;
32'b0000000000000001xxxxxxxxxxxxxxxx:	rgno <= 5'd16;
32'b00000000000000001xxxxxxxxxxxxxxx:	rgno <= 5'd15;
32'b000000000000000001xxxxxxxxxxxxxx:	rgno <= 5'd14;
32'b0000000000000000001xxxxxxxxxxxxx:	rgno <= 5'd13;
32'b00000000000000000001xxxxxxxxxxxx:	rgno <= 5'd12;
32'b000000000000000000001xxxxxxxxxxx:	rgno <= 5'd11;
32'b0000000000000000000001xxxxxxxxxx:	rgno <= 5'd10;
32'b00000000000000000000001xxxxxxxxx:	rgno <= 5'd9;
32'b000000000000000000000001xxxxxxxx:	rgno <= 5'd8;
32'b0000000000000000000000001xxxxxxx:	rgno <= 5'd7;
32'b00000000000000000000000001xxxxxx:	rgno <= 5'd6;
32'b000000000000000000000000001xxxxx:	rgno <= 5'd5;
32'b0000000000000000000000000001xxxx:	rgno <= 5'd4;	
32'b00000000000000000000000000001xxx:	rgno <= 5'd3;
32'b000000000000000000000000000001xx:	rgno <= 5'd2;
32'b0000000000000000000000000000001x:	rgno <= 5'd1;
32'b00000000000000000000000000000001:	rgno <= 5'd0;
default:	rgno <= 5'd0;
endcase

// Detect an edge on the SYNC signal to determine when to populate a frame with
// data. The AC97_controller streams continuously to the LM4550 at 48kHz frame
// rate.
edge_det u2 (.rst(rst_i), .clk(clk_i), .ce(1'b1), .i(SYNC), .pe(pe_sync), .ne(), .ee() );
wire doRead = fnRealToLM4550RegMap(rgno)==7'h26;

always @(posedge clk_i)
if (rst_i) begin
	dirty <= 32'd0;
	slot0 <= 0;
	slot1 <= 0;
	slot2 <= 0;
	slot3 <= 0;
	slot4 <= 0;
	slot5 <= 0;
	slot6 <= 0;
	slot7 <= 0;
	slot8 <= 0;
	slot9 <= 0;
	slot10 <= 0;
	slot11 <= 0;
	slot12 <= 0;
end
else begin
	if (cs & we_i)
		dirty[fnLM4550ToRealRegMap(adr_i[6:0])] <= 1'b1;
	if (RESET)	begin // RESET is active low!
		if (codecReady & pe_sync & |dirty) begin
			if (rgno < 7'd27) begin
				slot0[15] <= 1'b1;		// frame is valid
				slot0[14] <= 1'b1;		// valid control data
				slot0[13] <= 1'b1;		// control data in slot2
				slot0[12:0] <= 13'd0;
				slot1[19] <= doRead;		// Write, 1= read
				slot1[18:12] <= fnRealToLM4550RegMap(rgno);
				slot1[11:0] <= 12'd0;	// reserved
				slot2[19:4] <= doRead ? 16'h0000 : rfrgno;
				slot2[3:0] <= 4'd0;
				slot3 <= 20'd0;
				slot4 <= 20'd0;
				slot6 <= 20'd0;
				slot7 <= 20'd0;
				slot8 <= 20'd0;
				slot9 <= 20'd0;
				// these slots are always zero
				slot5 <= 20'd0;
				slot10 <= 20'd0;
				slot11 <= 20'd0;
				slot12 <= 20'd0;
				dirty[rgno] <= 1'b0;
			end
			else begin
				dirty[rgno] <= 1'b0;
				slot0[15] <= 1'b1;
				slot0[14] <= 1'b0;
				slot0[13] <= 1'b0;
				slot0[12] <= 1'b1;	// left data in slot3
				slot0[11] <= 1'b1;	// right data in slot4
				slot0[10:0] <= 11'd0;
				slot1 <= 20'd0;
				slot2 <= 20'd0;
				slot3[19:2] <= PSGout;
				slot3[1:0] <= 2'b00;
				slot4[19:2] <= PSGout;
				slot4[1:0] <= 2'b00;
				slot6 <= 20'd0;
				slot7 <= 20'd0;
				slot8 <= 20'd0;
				slot9 <= 20'd0;
				// these slots are always zero
				slot5 <= 20'd0;
				slot10 <= 20'd0;
				slot11 <= 20'd0;
				slot12 <= 20'd0;
			end
		end
		else if (codecReady & pe_sync) begin
			slot0[15] <= 1'b1;
			slot0[14] <= 1'b0;
			slot0[13] <= 1'b0;
			slot0[12] <= 1'b1;	// left data in slot3
			slot0[11] <= 1'b1;	// right data in slot4
			slot0[10:0] <= 11'd0;
			slot1 <= 20'd0;
			slot2 <= 20'd0;
			slot3[19:2] <= PSGout;
			slot3[1:0] <= 2'b00;
			slot4[19:2] <= PSGout;
			slot4[1:0] <= 2'b00;
			slot6 <= 20'd0;
			slot7 <= 20'd0;
			slot8 <= 20'd0;
			slot9 <= 20'd0;
			// these slots are always zero
			slot5 <= 20'd0;
			slot10 <= 20'd0;
			slot11 <= 20'd0;
			slot12 <= 20'd0;
		end
		// Send empty frames until the codec is ready.
		else if (pe_sync) begin
			slot0 <= 0;
			slot1 <= 0;
			slot2 <= 0;
			slot3 <= 0;
			slot4 <= 0;
			slot5 <= 0;
			slot6 <= 0;
			slot7 <= 0;
			slot8 <= 0;
			slot9 <= 0;
			slot10 <= 0;
			slot11 <= 0;
			slot12 <= 0;
		end
	end
end

always @(posedge clk_i)
if (rst_i) begin
	reg26 <= 16'h0000;
	codecReady <= 1'b0;
end
else begin
	if (RESET) begin	// RESET is active low!
		if (pe_sync) begin
			if (slot0i[15:13]==3'b111) begin
				if (slot1i[18:12]==7'h26) begin
					reg26 <= slot2i[19:4];
				end
			end
			if (slot0i[15]==1'b1) begin
				codecReady <= 1'b1;
			end
		end
	end
	else
		codecReady <= 1'b0;
end

ac97_controller u1
(
    .SYSCLK(clk_i),				// up to 125MHz
	.SYSTEM_RESET(rst_i),		// active on 1
    .BIT_CLK(BIT_CLK),			// 12,288 MHz
    .SDATA_IN(SDATA_IN),
	.SYNC(SYNC),
    .SDATA_OUT(SDATA_OUT),
    .RESET(RESET),
	.DONE(),
	.Slot0_in(slot0),
	.Slot1_in(slot1),
	.Slot2_in(slot2),
	.Slot3_in(slot3),
	.Slot4_in(slot4),
	.Slot5_in(slot5),
	.Slot6_in(slot6),
	.Slot7_in(slot7),
	.Slot8_in(slot8),
	.Slot9_in(slot9),
	.Slot10_in(slot10),
	.Slot11_in(slot11),
	.Slot12_in(slot12),
	.Slot0_out(slot0i),
	.Slot1_out(slot1i),
	.Slot2_out(slot2i),
	.Slot3_out(),
	.Slot4_out(),
	// The following slots are not used, and they are always zero
	.Slot5_out(),
	.Slot6_out(),
	.Slot7_out(),
	.Slot8_out(),
	.Slot9_out(),
	.Slot10_out(),
	.Slot11_out(),
	.Slot12_out()
);


endmodule
