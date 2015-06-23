// ============================================================================
//  Sprite RAM
//
//	(C) 2005,2011  Robert Finch
//	robfinch<remove>@opencores.org
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
// ============================================================================

//`define VENDOR_ANY
`define VENDOR_XILINX
`define SPARTAN3

module rtfSpriteRam(
clka, adra, dia, doa, cea, wea, rsta,
clkb, adrb, dib, dob, ceb, web, rstb);
parameter pAw = 10;
parameter pDw = 16;
input clka;
input [pAw:1] adra;
input [pDw:1] dia;
output [pDw:1] doa;
input cea;				// clock enable a
input wea;
input rsta;
input clkb;
input [pAw:1] adrb;
input [pDw:1] dib;
output [pDw:1] dob;
input ceb;				// clock enable b
input web;
input rstb;

`ifdef VENDOR_XILINX

`ifdef SPARTAN3
	// could use an S16_S32
	RAMB16_S18_S18 ram0(
		.CLKA(clka), .ADDRA(adra), .DIA(dia), .DIPA(2'b11), .DOA(doa), .ENA(cea), .WEA(wea), .SSRA(rsta),
		.CLKB(clkb), .ADDRB(adrb), .DIB(dib), .DIPB(2'b11), .DOB(dob), .ENB(ceb), .WEB(web), .SSRB(rstb)  );
`else
	// could use an S8_S16
	RAMB4_S8_S8 ram0(
		.CLKA(clka), .ADDRA(adra), .DIA(dia), .DOA(doa), .ENA(cea), .WEA(wea), .RSTA(rsta),
		.CLKB(clkb), .ADDRB(adrb), .DIB(dib), .DOB(dob), .ENB(ceb), .WEB(web), .RSTB(rstb)  );
`endif
`endif

`ifdef VENDOR_ALTERA
`endif

`ifdef VENDOR_ANY

reg [15:0] mem [(1<<pAw):1];
reg [pAw:1] radra;
reg [pAw:1] radrb;

// register read addresses
always @(posedge clka)
	if (cea)
		radra <= adra;

always @(posedge clkb)
	if (ceb)
		if (web)
			mem[adrb] <= dib;

assign doa = mem[radra];

`endif

endmodule
