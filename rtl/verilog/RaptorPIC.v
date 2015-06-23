`timescale 1ns / 1ps
//=============================================================================
//	(C) 2005-2012  Robert Finch
//	All rights reserved.
//	robfinch@Opencores.org
//
//	RaptorPIC.v
//
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
//
//		Encodes discrete interrupt request signals into four
//	bit code using a priority encoder.
//	
//	reg
//	0	- encoded request number (read only)
//			This register contains the number identifying
//			the current requester.
//			the actual number is shifted left three times
//			before being placed into this register so it may
//			be used directly as an index in OS software. The
//			index may be a mailbox id or index into a jump
//			table as desired by the OS. If there is no
//			active request, then this number will be 
//			zero.
//	1	- request enable (read / write)
//			this register contains request enable bits
//			for each request line. 1 = request
//			enabled, 0 = request disabled. On reset this
//			register is set to zero (disable all ints).
//			bit zero is specially reserved for nmi
//
//	2   - write only
//			this register disables the interrupt indicated
//			by the low order four bits of the input data
//			
//	3	- write only
//			this register enables the interrupt indicated
//			by the low order four bits of the input data
//
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|WISHBONE Datasheet
//	|WISHBONE SoC Architecture Specification, Revision B.3
//	|
//	|Description:						Specifications:
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|General Description:				simple programmable interrupt controller
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|Supported Cycles:					SLAVE,READ/WRITE
//	|									SLAVE,BLOCK READ/WRITE
//	|									SLAVE,RMW
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|Data port, size:					16 bit
//	|Data port, granularity:			16 bit
//	|Data port, maximum operand size:	16 bit
//	|Data transfer ordering:			Undefined
//	|Data transfer sequencing:			Undefined
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|Clock frequency constraints:		none
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|Supported signal list and			Signal Name		WISHBONE equiv.
//	|cross reference to equivalent		ack_o				ACK_O
//	|WISHBONE signals					adr_i(2:1)			ADR_I()
//	|									clk_i				CLK_I
//	|									dat_i(15:0)			DAT_I()
//	|									dat_o(15:0)			DAT_O()
//	|									cyc_i				CYC_I
//	|									stb_i				STB_I
//	|									we_i				WE_I
//	|
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|Special requirements:
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//	Spartan3-4
// 	105 LUTs / 58 slices / 163MHz
//=============================================================================

module RaptorPIC
(
	input rst_i,		// reset
	input clk_i,		// system clock
	input cyc_i,		// cycle valid
	input stb_i,		// strobe
	output ack_o,		// transfer acknowledge
	input we_i,			// write
	input [1:0] sel_i,	// byte select
	input [23:0] adr_i,	// address
	input [15:0] dat_i,
	output reg [15:0] dat_o,
	output vol_o,		// volatile register selected
	input i1, i2, i3, i4, i5, i6, i7,
		i8, i9, i10, i11, i12, i13, i14, i15,
	output irqo,	// normally connected to the processor irq
	input nmii,		// nmi input connected to nmi requester
	output nmio,	// normally connected to the nmi of cpu
	output [8:0] vecno
);
parameter pVECNO = 9'd448;

reg [15:0] ie;		// interrupt enable register
reg ack1;
reg [3:0] irqenc;

wire cs = cyc_i && stb_i && adr_i[23:4]==20'hDC_0FF;
assign vol_o = cs;

always @(posedge clk_i)
	ack1 <= cs;
assign ack_o = cs ? (we_i ? 1'b1 : ack1) : 1'b0;

// write registers	
always @(posedge clk_i)
	if (rst_i)
		ie <= 16'h0;
	else if (cs & we_i)
		case (adr_i[2:1])
		2'd0,2'd1:
			begin
				if (sel_i[0]) ie[ 7:0] <= dat_i[ 7:0];
				if (sel_i[1]) ie[15:8] <= dat_i[15:8];
			end
		2'd2,2'd3:
			if (sel_i[0]) ie[dat_i[3:0]] <= adr_i[1];
		endcase

// read registers
always @(posedge clk_i)
begin
	if (irqenc!=4'd0)
		$display("PIC: %d",irqenc);
	if (cs)
		case (adr_i[2:1])
		2'd0:	dat_o <= {12'b0,irqenc};
		default:	dat_o <= ie;
		endcase
	else
		dat_o <= 16'h0000;
end

assign irqo = irqenc != 4'h0;
assign nmio = nmii & ie[0];

// irq requests are latched on every clock edge to prevent
// misreads
// nmi is not encoded
always @(posedge clk_i)
	case (1'b1)
	i1&ie[1]:		irqenc <= 4'd1;
	i2&ie[2]:		irqenc <= 4'd2;
	i3&ie[3]: 		irqenc <= 4'd3;
	i4&ie[4]:		irqenc <= 4'd4;
	i5&ie[5]: 		irqenc <= 4'd5;
	i6&ie[6]:		irqenc <= 4'd6;
	i7&ie[7]:		irqenc <= 4'd7;
	i8&ie[8]:		irqenc <= 4'd8;
	i9&ie[9]:		irqenc <= 4'd9;
	i10&ie[10]: 	irqenc <= 4'd10;
	i11&ie[11]:		irqenc <= 4'd11;
	i12&ie[12]:		irqenc <= 4'd12;
	i13&ie[13]:		irqenc <= 4'd13;
	i14&ie[14]:		irqenc <= 4'd14;
	i15&ie[15]:		irqenc <= 4'd15;
	default:	irqenc <= 4'd0;
	endcase

assign vecno = pVECNO|irqenc;

endmodule
