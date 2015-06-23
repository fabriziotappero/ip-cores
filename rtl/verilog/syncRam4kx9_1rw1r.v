// ============================================================================
//	2008,2011  Robert Finch
//	robfinch@<remove>sympatico.ca
//
//	syncRam4kx9_1rw1r.v
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
// ============================================================================
//
`define SYNTHESIS
`define VENDOR_XILINX
`define SPARTAN3

module syncRam4kx9_1rw1r(
	input wrst,
	input wclk,
	input wce,
	input we,
	input [11:0] wadr,
	input [8:0] i,
	output [8:0] wo,
	input rrst,
	input rclk,
	input rce,
	input [11:0] radr,
	output [8:0] o
);

`ifdef SYNTHESIS
`ifdef VENDOR_XILINX

`ifdef SPARTAN3
	wire [8:0] o0;
	wire [8:0] o1;
	wire [8:0] wo0;
	wire [8:0] wo1;
	wire rrst0 =  radr[11];
	wire rrst1 = ~radr[11];
	wire wrst0 =  wadr[11];
	wire wrst1 = ~wadr[11];
	wire we0 = we & ~wadr[11];
	wire we1 = we &  wadr[11];

	RAMB16_S9_S9 ram0(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[7:0]), .DIPA(i[8]), .DOA(wo0[7:0]), .DOPA(wo0[8]), .ENA(wce), .WEA(we0), .SSRA(wrst0),
		.CLKB(rclk), .ADDRB(radr), .DIB(8'hFF), .DIPB(1'b1), .DOB(o0[7:0]), .DOPB(o0[8]), .ENB(rce), .WEB(1'b0), .SSRB(rrst0)  );
	RAMB16_S9_S9 ram1(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[7:0]), .DIPA(i[8]), .DOA(wo1[7:0]), .DOPA(wo1[8]), .ENA(wce), .WEA(we1), .SSRA(wrst1),
		.CLKB(rclk), .ADDRB(radr), .DIB(8'hFF), .DIPB(1'b1), .DOB(o1[7:0]), .DOPB(o1[8]), .ENB(rce), .WEB(1'b0), .SSRB(rrst1)  );

	assign o = o0|o1;
	assign wo = wo0|wo1;

`endif

`ifdef SPARTAN2
	RAMB4_S1_S1 ram0(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[0]), .DOA(wo[0]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(1'b1), .DOB(o[0]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
	RAMB4_S1_S1 ram1(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[1]), .DOA(wo[1]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(1'b1), .DOB(o[1]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
	RAMB4_S1_S1 ram2(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[2]), .DOA(wo[2]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(1'b1), .DOB(o[2]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
	RAMB4_S1_S1 ram3(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[3]), .DOA(wo[3]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(1'b1), .DOB(o[3]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
	RAMB4_S1_S1 ram4(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[4]), .DOA(wo[4]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(1'b1), .DOB(o[4]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
	RAMB4_S1_S1 ram5(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[5]), .DOA(wo[5]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(1'b1), .DOB(o[5]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
	RAMB4_S1_S1 ram6(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[6]), .DOA(wo[6]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(1'b1), .DOB(o[6]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
	RAMB4_S1_S1 ram7(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[7]), .DOA(wo[7]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(1'b1), .DOB(o[7]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
	RAMB4_S1_S1 ram8(
		.CLKA(wclk), .ADDRA(wadr), .DIA(i[8]), .DOA(wo[8]), .ENA(wce), .WEA(we), .RSTA(wrst),
		.CLKB(rclk), .ADDRB(radr), .DIB(1'b1), .DOB(o[8]), .ENB(rce), .WEB(1'b0), .RSTB(rrst)  );
`endif

`endif

`ifdef VENDOR_ALTERA

	reg [8:0] mem [4095:0];
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

`else

	reg [8:0] mem [4095:0];
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
