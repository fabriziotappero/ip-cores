// ============================================================================
// (C) 2011 Robert Finch
// All Rights Reserved.
// robfinch<remove>@opencores.org
//
// KLC32 - 32 bit CPU
// KLC32_tb - testbench for KLC32
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
module KLC32_tb();
reg clk;
reg rst;
wire sys_inta;
wire [2:0] sys_fc;
wire sys_cyc;
wire sys_stb;
wire sys_we;
wire [3:0] sys_sel;
wire [31:0] sys_adr;
wire [31:0] sys_dbo;
wire [31:0] sys_dbi;
wire sys_rst;
reg [31:0] romout;
wire sys_ack;
wire [31:0] ram_dbo;
wire [31:0] stk_dbo;
reg nmi;

assign sys_ack = sys_stb;

wire ram_cs = sys_adr < 32'h0010000 || sys_adr[32:16]==16'hFFD0;
wire stk_cs = sys_adr[31:16]==16'hFFFE;


initial begin
	clk = 1;
	rst = 0;
	#100 rst = 1;
	#100 rst = 0;
end

always #6.8 clk = ~clk;	//  73.529 MHz

always @(sys_adr)
casex(sys_adr & 32'hFFFFFFFC)
32'h00000000:	romout <= 32'hFFFE_07FC;	// initial SP	
32'h00000004:	romout <= 32'hFFFF_0000;	// initial PC
32'h0000xxxx:	romout <= ram_dbo;
32'hFFFF0000:	romout <= 32'h00000034;		// RST
32'hFFFF0004:	romout <= 32'h24018000;		// ORI R1,R0,#$FFD00000
32'hFFFF0008:	romout <= 32'hFFD00000;
32'hFFFF000C:	romout <= 32'h24020005;		// ORI R2,R0,#5
32'hFFFF0010:	romout <= 32'h24030020;		// ORI R3,R0,#32
// J1:
32'hFFFF0014:	romout <= 32'hE4230000;		// SH R3,(R1)
32'hFFFF0018:	romout <= 32'h10210002;		// ADDI R1,R1,#2
32'hFFFF001C:	romout <= 32'h14420001;		// SUBI R2,R2,#1
32'hFFFF0020:	romout <= 32'h4006FFF0;		// BNE CR0,J1
32'hFFFExxxx:	romout <= stk_dbo;
endcase
assign sys_dbi = romout;

KLC32 u1
(
	.rst_i(rst),
	.clk_i(clk),
	.halt_i(1'b0),
	.ipl_i(3'b000),
	.vpa_i(1'b0),
	.err_i(1'b0),
	.inta_o(sys_inta),
	.fc_o(sys_fc),
	.rst_o(sys_rst),
	.cyc_o(sys_cyc),
	.stb_o(sys_stb),
	.ack_i(sys_ack),
	.we_o(sys_we),
	.sel_o(sys_sel),
	.adr_o(sys_adr),
	.dat_i(sys_dbi),
	.dat_o(sys_dbo)
);

fict_ram u2 (clk, ram_cs, sys_we, sys_sel, sys_adr[17:0],sys_dbo,ram_dbo);
fict_ram u3 (clk, stk_cs, sys_we, sys_sel, sys_adr[17:0],sys_dbo,stk_dbo);

endmodule

module fict_ram(clk, cs, we, sel_i, adr, dat_i, dat_o);
input clk;
input cs;
input we;
input [3:0] sel_i;
input [17:0] adr;
input [31:0] dat_i;
output [31:0] dat_o;

reg [31:0] mem [65535:0];

always @(posedge clk)
begin
	if (cs & we) begin
		$display("Wrote mem[%h] with %h", adr, dat_i);
		if (sel_i[0]) mem[adr[17:2]][ 7: 0] <= dat_i[ 7: 0];
		if (sel_i[1]) mem[adr[17:2]][15: 8] <= dat_i[15: 8];
		if (sel_i[2]) mem[adr[17:2]][23:16] <= dat_i[23:16];
		if (sel_i[3]) mem[adr[17:2]][31:24] <= dat_i[31:24];
	end
end

assign dat_o = mem[adr[17:2]];

endmodule

