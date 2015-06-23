// ============================================================================
// 2006-2012 Robert Finch
// All Rights Reserved.
// robfinch@<remove>@opencores.org
//
//	syncRam2kx8_1rw1r.v
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
`define SYNTHESIS
`define VENDOR_XILINX
`define SPARTAN3

module syncRam2kx8_1rw1r(
	input wrst,
	input wclk,
	input wce,
	input we,
	input [10:0] wadr,
	input [7:0] i,
	output [7:0] wo,
	input rrst,
	input rclk,
	input rce,
	input [10:0] radr,
	output [7:0] o
);

`ifdef SYNTHESIS
`ifdef VENDOR_XILINX

`ifdef SPARTAN3
	RAMB16_S9_S9 ram0(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i), .DIPA(^i), .DOA(wo), .ENA(wce), .WEA(we), .SSRA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(8'hFF), .DIPB(1'b1), .DOB(o), .ENB(rce), .WEB(1'b0), .SSRB(rrst)  );
`endif

`ifdef SPARTAN2
	RAMB4_S2_S2 ram0(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[1:0]), .DOA(wo[1:0]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(2'b11), .DOB(o[1:0]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
	RAMB4_S2_S2 ram1(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[3:2]), .DOA(wo[3:2]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(2'b11), .DOB(o[3:2]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
	RAMB4_S2_S2 ram2(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[5:4]), .DOA(wo[5:4]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(2'b11), .DOB(o[5:4]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
	RAMB4_S2_S2 ram3(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[7:6]), .DOA(wo[5:4]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(2'b11), .DOB(o[5:4]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
`endif

`endif

`ifdef VENDOR_ALTERA
`endif

`else

	reg [7:0] mem [2047:0];
	reg [10:0] rradr;
	reg [10:0] rwadr;

	// register read addresses
	always @(posedge rclk)
		if (rce) rradr <= radr;

	assign o = mem[rradr];

	// write side
	always @(posedge wclk)
		if (wce) rwadr <= wadr;

	always @(posedge wclk)
		if (wce) mem[wadr] <= i;

	assign wo = mem[rwadr];

`endif

endmodule
