//=============================================================================
//  (C) 2009-2012 Robert Finch, Stratford
//  robfinch<remove>@opencores.org
//
//  Register file
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
//=============================================================================
//
reg [15:0] rrro;			
reg [15:0] rmo;				// register output (controlled by mod r/m byte)
reg [15:0] rfso;

reg pf;						// parity flag
reg af;						// auxillary carry (half carry) flag
reg zf, cf, vf;
reg sf;						// sign flag
reg df;						// direction flag
reg ie;						// interrupt enable flag
reg tf;
wire [15:0] flags = {1'b0,1'b0,2'b00,vf,df,ie,tf,sf,zf,1'b0,af,1'b0,pf,1'b0,cf};

reg [7:0] ir;				// instruction register
reg [7:0] ir2;				// extended instruction register
reg [15:0] ip;				// instruction pointer
reg [15:0] ir_ip;			// instruction pointer of ir
reg [15:0] ax;
reg [15:0] bx;
reg [15:0] cx;
reg [15:0] dx;
reg [15:0] si;				// source index
reg [15:0] di;				// destination index
reg [15:0] bp;				// base pointer
reg [15:0] sp;				// stack pointer
wire cxz = cx==16'h0000;	// CX is zero

reg [15:0] cs;				// code segment
reg [15:0] ds;				// data segment
reg [15:0] es;				// extra segment
reg [15:0] ss;				// stack segment

// renamed byte registers for convenience
wire [7:0] al = ax[7:0];
wire [7:0] ah = ax[15:8];
wire [7:0] dl = dx[7:0];
wire [7:0] dh = dx[15:8];
wire [7:0] cl = cx[7:0];
wire [7:0] ch = cx[15:8];
wire [7:0] bl = bx[7:0];
wire [7:0] bh = bx[15:8];

wire [19:0] csip = {cs,4'd0} + ip;
wire [19:0] sssp = {ss,4'd0} + sp;
wire [19:0] dssi = {ds,4'd0} + si;
wire [19:0] esdi = {es,4'd0} + di;

// Read port
//
always @(w or rrr or ax or bx or cx or dx or sp or bp or si or di)
	case({w,rrr})
	4'd0:	rrro <= {{8{ax[7]}},ax[7:0]};
	4'd1:	rrro <= {{8{cx[7]}},cx[7:0]};
	4'd2:	rrro <= {{8{dx[7]}},dx[7:0]};
	4'd3:	rrro <= {{8{bx[7]}},bx[7:0]};
	4'd4:	rrro <= {{8{ax[15]}},ax[15:8]};
	4'd5:	rrro <= {{8{cx[15]}},cx[15:8]};
	4'd6:	rrro <= {{8{dx[15]}},dx[15:8]};
	4'd7:	rrro <= {{8{bx[15]}},bx[15:8]};
	4'd8:	rrro <= ax;
	4'd9:	rrro <= cx;
	4'd10:	rrro <= dx;
	4'd11:	rrro <= bx;
	4'd12:	rrro <= sp;
	4'd13:	rrro <= bp;
	4'd14:	rrro <= si;
	4'd15:	rrro <= di;
	endcase


// Second Read port
//
always @(w or rm or ax or bx or cx or dx or sp or bp or si or di)
	case({w,rm})
	4'd0:	rmo <= {{8{ax[7]}},ax[7:0]};
	4'd1:	rmo <= {{8{cx[7]}},cx[7:0]};
	4'd2:	rmo <= {{8{dx[7]}},dx[7:0]};
	4'd3:	rmo <= {{8{bx[7]}},bx[7:0]};
	4'd4:	rmo <= {{8{ax[15]}},ax[15:8]};
	4'd5:	rmo <= {{8{cx[15]}},cx[15:8]};
	4'd6:	rmo <= {{8{dx[15]}},dx[15:8]};
	4'd7:	rmo <= {{8{bx[15]}},bx[15:8]};
	4'd8:	rmo <= ax;
	4'd9:	rmo <= cx;
	4'd10:	rmo <= dx;
	4'd11:	rmo <= bx;
	4'd12:	rmo <= sp;
	4'd13:	rmo <= bp;
	4'd14:	rmo <= si;
	4'd15:	rmo <= di;
	endcase


// Read segment registers
//
always @(sreg3 or es or cs or ds or ss)
	case(sreg3)
	3'd0:	rfso <= es;
	3'd1:	rfso <= cs;
	3'd2:	rfso <= ss;
	3'd3:	rfso <= ds;
	default:	rfso <= 16'h0000;
	endcase
