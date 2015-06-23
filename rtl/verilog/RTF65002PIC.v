`timescale 1ns / 1ps
//=============================================================================
//	(C) 2013  Robert Finch
//	All rights reserved.
//	robfinch<remove>@Opencores.org
//
//	RTF65002PIC.v
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
//	4	- write only
//			this register indicates which interrupt inputs are
// 			edge sensitive
//
//  5	- write only
//			This register resets the edge sense circuitry
//			indicated by the low order four bits of the input data.
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
//	|Data port, size:					32 bit
//	|Data port, granularity:			32 bit
//	|Data port, maximum operand size:	32 bit
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

module RTF65002PIC
(
	input rst_i,		// reset
	input clk_i,		// system clock
	input cyc_i,		// cycle valid
	input stb_i,		// strobe
	output ack_o,		// transfer acknowledge
	input we_i,			// write
	input [33:0] adr_i,	// address
	input [31:0] dat_i,
	output reg [31:0] dat_o,
	output vol_o,		// volatile register selected
	input i1, i2, i3, i4, i5, i6, i7,
		i8, i9, i10, i11, i12, i13, i14, i15,
	output irqo,	// normally connected to the processor irq
	input nmii,		// nmi input connected to nmi requester
	output nmio,	// normally connected to the nmi of cpu
	output [8:0] vecno
);
parameter pVECNO = 9'd448;
parameter pIOAddress = 32'hFFDC_0FF0;

reg [15:0] ie;		// interrupt enable register
reg ack1;
reg [3:0] irqenc;
wire [15:0] i = {i15,i14,i13,i12,i11,i10,i9,i8,i7,i6,i5,i4,i3,i2,i1,nmii};
reg [15:0] ib;
reg [15:0] iedge;
reg [15:0] rste;
reg [15:0] es;

wire cs = cyc_i && stb_i && adr_i[33:6]==pIOAddress[31:4];
assign vol_o = cs;

always @(posedge clk_i)
	ack1 <= cs;
assign ack_o = cs ? (we_i ? 1'b1 : ack1) : 1'b0;

// write registers	
always @(posedge clk_i)
	if (rst_i) begin
		ie <= 16'h0;
		rste <= 16'h0;
	end
	else begin
		rste <= 16'h0;
		if (cs & we_i) begin
			case (adr_i[4:2])
			3'd0,3'd1:
				begin
					ie[15:0] <= dat_i[15:0];
				end
			3'd2,3'd3:
				ie[dat_i[3:0]] <= adr_i[2];
			3'd4:	es <= dat_i[15:0];
			3'd5:	rste[dat_i[3:0]] <= 1'b1;
			endcase
		end
	end

// read registers
always @(posedge clk_i)
begin
	if (irqenc!=4'd0)
		$display("PIC: %d",irqenc);
	if (cs)
		case (adr_i[3:2])
		2'd0:	dat_o <= {28'b0,irqenc};
		default:	dat_o <= ie;
		endcase
	else
		dat_o <= 32'h0000;
end

assign irqo = irqenc != 4'h0;
assign nmio = nmii & ie[0];

// Edge detect circuit
integer n;
always @(posedge clk_i)
begin
	for (n = 1; n < 16; n = n + 1)
	begin
		ib[n] <= i[n];
		if (i[n] & !ib[n]) iedge[n] <= 1'b1;
		if (rste[n]) iedge[n] <= 1'b0;
	end
end

// irq requests are latched on every rising clock edge to prevent
// misreads
// nmi is not encoded
always @(posedge clk_i)
begin
	irqenc <= 4'd0;
	for (n = 15; n > 0; n = n - 1)
		if (ie[n] & (es[n] ? iedge[n] : i[n])) irqenc <= n;
end

assign vecno = pVECNO|irqenc;

endmodule
