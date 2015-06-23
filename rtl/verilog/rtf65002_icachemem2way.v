// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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
module rtf65002_icachemem2way(whichrd, whichwr, wclk, wr, adr, dat, rclk, pc, insn);
input [1:0] whichrd;	// which set to read
input whichwr;			// which set to update
input wclk;
input wr;
input [33:0] adr;
input [31:0] dat;
input rclk;
input [31:0] pc;
output reg [63:0] insn;

wire [63:0] insn0a,insn0b;
wire [63:0] insn1a,insn1b;
wire [31:0] pcp8 = pc + 32'd8;
reg [31:0] rpc;

always @(posedge rclk)
	rpc <= pc;

// memL and memH combined allow a 64 bit read
syncRam1kx32_1rw1r ramL0a
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(~adr[2] & ~whichwr),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[12:3]),
	.o(insn0a[31:0])
);

syncRam1kx32_1rw1r ramH0a
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(adr[2] & ~whichwr),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[12:3]),
	.o(insn0a[63:32])
);

syncRam1kx32_1rw1r ramL1a
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(~adr[2] & ~whichwr),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[12:3]),
	.o(insn1a[31:0])
);

syncRam1kx32_1rw1r ramH1a
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(adr[2] & ~whichwr),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[12:3]),
	.o(insn1a[63:32])
);

syncRam1kx32_1rw1r ramL0b
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(~adr[2] & whichwr),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[12:3]),
	.o(insn0b[31:0])
);

syncRam1kx32_1rw1r ramH0b
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(adr[2] & whichwr),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[12:3]),
	.o(insn0b[63:32])
);

syncRam1kx32_1rw1r ramL1b
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(~adr[2] & whichwr),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[12:3]),
	.o(insn1b[31:0])
);

syncRam1kx32_1rw1r ramH1b
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(adr[2] & whichwr),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[12:3]),
	.o(insn1b[63:32])
);

always @(rpc or insn0a or insn1a or insn0b or insn1b or whichrd)
case({whichrd,rpc[2:0]})
5'd0:	insn <= insn0a[63:0];
5'd1:	insn <= {insn1a[7:0],insn0a[63:8]};
5'd2:	insn <= {insn1a[15:0],insn0a[63:16]};
5'd3:	insn <= {insn1a[23:0],insn0a[63:24]};
5'd4:	insn <= {insn1a[31:0],insn0a[63:32]};
5'd5:	insn <= {insn1a[39:0],insn0a[63:40]};
5'd6:	insn <= {insn1a[47:0],insn0a[63:48]};
5'd7:	insn <= {insn1a[55:0],insn0a[63:56]};
5'd8:	insn <= insn0b[63:0];
5'd9:	insn <= {insn1b[7:0],insn0b[63:8]};
5'd10:	insn <= {insn1b[15:0],insn0b[63:16]};
5'd11:	insn <= {insn1b[23:0],insn0b[63:24]};
5'd12:	insn <= {insn1b[31:0],insn0b[63:32]};
5'd13:	insn <= {insn1b[39:0],insn0b[63:40]};
5'd14:	insn <= {insn1b[47:0],insn0b[63:48]};
5'd15:	insn <= {insn1b[55:0],insn0b[63:56]};
5'd16:	insn <= insn0a[63:0];
5'd17:	insn <= {insn1b[7:0],insn0a[63:8]};
5'd18:	insn <= {insn1b[15:0],insn0a[63:16]};
5'd19:	insn <= {insn1b[23:0],insn0a[63:24]};
5'd20:	insn <= {insn1b[31:0],insn0a[63:32]};
5'd21:	insn <= {insn1b[39:0],insn0a[63:40]};
5'd22:	insn <= {insn1b[47:0],insn0a[63:48]};
5'd23:	insn <= {insn1b[55:0],insn0a[63:56]};
5'd24:	insn <= insn0b[63:0];
5'd25:	insn <= {insn1a[7:0],insn0b[63:8]};
5'd26:	insn <= {insn1a[15:0],insn0b[63:16]};
5'd27:	insn <= {insn1a[23:0],insn0b[63:24]};
5'd28:	insn <= {insn1a[31:0],insn0b[63:32]};
5'd29:	insn <= {insn1a[39:0],insn0b[63:40]};
5'd30:	insn <= {insn1a[47:0],insn0b[63:48]};
5'd31:	insn <= {insn1a[55:0],insn0b[63:56]};
endcase 
endmodule
