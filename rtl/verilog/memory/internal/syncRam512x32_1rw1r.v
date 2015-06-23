// ============================================================================
// (C) 2012 Robert Finch
// All Rights Reserved.
// robfinch@<remove>@opencores.org
//
//	syncRam512x32_1rw1r.v
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

module syncRam512x32_1rw1r(
	input wrst,
	input wclk,
	input wce,
	input we,
	input [8:0] wadr,
	input [31:0] i,
	output [31:0] wo,
	input rrst,
	input rclk,
	input rce,
	input [8:0] radr,
	output [31:0] o
);

`ifdef SYNTHESIS
`ifdef VENDOR_XILINX

`ifdef SPARTAN3
	RAMB16_S36_S36 ram0(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i), .DIPA({^i[31:24],^i[23:16],^i[15:8],^i[7:0]}), .DOA(wo), .ENA(wce), .WEA(we), .SSRA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(32'hFFFF_FFFF), .DIPB(4'b1111), .DOB(o), .ENB(rce), .WEB(1'b0), .SSRB(rrst)  );
`endif

`ifdef SPARTAN2
	RAMB4_S4_S4 ram0(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[3:0]), .DOA(wo[3:0]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(4'hF), .DOB(o[3:0]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
	RAMB4_S4_S4 ram1(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[7:4]), .DOA(wo[7:4]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(4'hF), .DOB(o[7:4]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
	RAMB4_S4_S4 ram2(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[11:8]), .DOA(wo[11:8]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(4'hF), .DOB(o[11:8]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
	RAMB4_S4_S4 ram3(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[15:12]), .DOA(wo[15:12]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(4'hF), .DOB(o[15:12]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
`endif

`endif

`ifdef VENDOR_ALTERA

	reg [31:0] mem [511:0];
	reg [8:0] rradr;
	reg [8:0] rwadr;
	reg rrrst;
	reg rwrst;

	// register read addresses
	always @(posedge rclk)
		if (rce) rradr <= radr;
	always @(posedge rclk)
		if (rce) rrrst <= rrst;

	assign o = rrrst ? 0 : mem[rradr];

	// write side
	always @(posedge wclk)
		if (wce) rwadr <= wadr;
	always @(posedge wclk)
		if (wce) rwrst <= wrst;

	always @(posedge wclk)
		if (wce) mem[wadr] <= i;

	assign wo = rwrst ? 0 : mem[rwadr];

`endif

`else

	reg [31:0] mem [511:0];
	reg [8:0] rradr;
	reg [8:0] rwadr;
	reg rrrst;
	reg rwrst;

	// register read addresses
	always @(posedge rclk)
		if (rce) rradr <= radr;
	always @(posedge rclk)
		if (rce) rrrst <= rrst;

	assign o = rrrst ? 0 : mem[rradr];

	// write side
	always @(posedge wclk)
		if (wce) rwadr <= wadr;
	always @(posedge wclk)
		if (wce) rwrst <= wrst;

	always @(posedge wclk)
		if (wce) mem[wadr] <= i;

	assign wo = rwrst ? 0 : mem[rwadr];

`endif

endmodule
