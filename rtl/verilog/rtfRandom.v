// ============================================================================
//	2011  Robert Finch
//	robfinch@<remove>opencores.ca
//
// rtfRandom.v
//     Random number generator.
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
// 	Reg no.
//	0			random output bits [31:16]
//  1           random output bits [15: 0]
//  2           not used
//  3           not used
//  4           m_z seed setting bits [31:16]
//  5           m_z seed setting bits [15 :0]
//  6           m_w seed setting bits [31:16]
//  7           m_w seed setting bits [15 :0]
//
//  +- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|WISHBONE Datasheet
//	|WISHBONE SoC Architecture Specification, Revision B.3
//	|
//	|Description:						Specifications:
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|General Description:				random number generator
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
//	|cross reference to equivalent		ack_o			ACK_O
//	|WISHBONE signals					adr_i[43:0]		ADR_I()
//	|									clk_i			CLK_I
//	|                                   rst_i           RST_I()
//	|									dat_i(15:0)		DAT_I()
//	|									dat_o(15:0)		DAT_O()
//	|									cyc_i			CYC_I
//	|									stb_i			STB_I
//	|									we_i			WE_I
//	|
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|Special requirements:
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// ============================================================================
//
// Uses George Marsaglia's multiply method
//
// m_w = <choose-initializer>;    /* must not be zero */
// m_z = <choose-initializer>;    /* must not be zero */
//
// uint get_random()
// {
//     m_z = 36969 * (m_z & 65535) + (m_z >> 16);
//     m_w = 18000 * (m_w & 65535) + (m_w >> 16);
//     return (m_z << 16) + m_w;  /* 32-bit result */
// }
//
module rtfRandom(rst_i, clk_i, cyc_i, stb_i, ack_o, we_i, adr_i, dat_i, dat_o, vol_o);
input rst_i;
input clk_i;
input cyc_i;
input stb_i;
output ack_o;
input we_i;
input [43:0] adr_i;
input [15:0] dat_i;
output [15:0] dat_o;
reg [15:0] dat_o;
output vol_o;			// outputting a vclatile register

wire cs = cyc_i && stb_i && (adr_i[43:4]==40'hFFF_FFDC_0C0);
assign ack_o = cs;
assign vol_o = cs && !we_i && (adr_i[3:1]==3'd0 || adr_i[3:1]==3'd1);

reg [31:0] m_z;
reg [31:0] m_w;
reg [31:0] next_m_z;
reg [31:0] next_m_w;
reg [31:0] out;

always @(m_z or m_w)
begin
	next_m_z <= (18'h36969 * m_z[15:0]) + m_z[31:16];
	next_m_w <= (18'h18000 * m_w[15:0]) + m_w[31:16];
end

// Register read path
//
always @(cs or adr_i or out or m_z or m_w)
	if (cs)
		case(adr_i[3:1])
		3'd0:	dat_o <= out[31:16];
		3'd1:	dat_o <= out[15: 0];
// Uncomment these for register read-back
//		3'd4:	dat_o <= m_z[31:16];
//		3'd5:	dat_o <= m_z[15: 0];
//		3'd6:	dat_o <= m_w[31:16];
//		3'd7:	dat_o <= m_w[15: 0];
		endcase
	else
		dat_o <= 16'h0000;

// Register write path
//
always @(posedge clk_i)
if (rst_i) begin
	m_z <= 32'h01234567;	// These must be non-zero
	m_w <= 32'h88888888;
end
else begin
	if (cs) begin
		if (we_i)
			case(adr_i[3:1])
			3'd4:	m_z[31:16] <= dat_i;
			3'd5:	m_z[15: 0] <= dat_i;
			3'd6:	m_w[31:16] <= dat_i;
			3'd7:	m_w[15: 0] <= dat_i;
			endcase
		// cycle the generator on a read
		else begin
			m_z <= next_m_z;
			m_w <= next_m_w;
			out <= {m_z[15:0],16'd0} + m_w;
		end
	end
end

endmodule
