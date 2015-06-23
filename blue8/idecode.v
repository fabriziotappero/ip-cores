/*
    This file is part of Blue8.

    Foobar is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Blue8.  If not, see <http://www.gnu.org/licenses/>.

    Blue8 by Al Williams alw@al-williams.com

*/

`default_nettype none

module idecode( input [15:0] ir16, output wire ophlt, output wire opadd, output wire opxor, 
    output wire opand, output wire opior, output wire opnot, output wire oplda, output wire opsta,  
	 output wire opsrj, output wire opjmp, output wire opldx,
    output wire opral, output wire opnop,
	 output wire opinc, output wire opdec, output wire opskip, output wire opspn, output wire opq,
	 output wire opqtog, output wire opsub, output wire opcmp, output wire opldi, output wire oprar,
	 output wire opincdecx, output wire opstx, output wire opjmpa, output wire opswap, 
	 output wire oplds, output wire oppush, output wire oppop, output wire opframe, output wire opldxa);
wire [3:0] ir;
   
assign ir=ir16[15:12];
assign ophlt=ir16==16'h0;
assign opadd=ir==1;
assign opxor=ir==2;
assign opand=ir==3;
assign opior=ir==4;
assign opnot=ir16==16'h2;
assign opcmp=ir==5;
assign oplda=ir[2:0]==6;
assign opsta=ir[2:0]==7;
assign opsrj=ir==8;
assign opsub=ir==9;
assign opjmp=ir==10;
assign opldx=ir==11;
assign oplds=ir==12;
assign opral=ir16==16'h3;

assign opnop=ir16==16'h1;
assign opinc=ir16==16'h5;
assign opdec=ir16==16'h6;
assign oprar=ir16==16'h7;
assign opskip=ir16[15:4]==12'b1;  // skip is 0x0010 + skip code + 8 (if ~flags)
assign opspn=ir16[15:1]==15'b10000;  // 0x0020/21 - skip positive/negative
assign opq=ir16[15:1]==15'b10001;  // 0x22/23 - qoff, qon
assign opqtog=ir16==16'h24;        // 0x24 qtog
assign opldi=ir16==16'h25;        // 0x25 ldi
assign opincdecx=ir16[15:1]==15'h0018;  // 0x30/0x31
assign opstx=ir16==16'h32;
assign opjmpa=ir16==16'h33;
assign opswap=ir16==16'h34;
assign oppop=ir16[15:4]==12'h4; 	  // pop includes ret
assign oppush=ir16[15:4]==12'h5;
assign opframe=ir16==16'h8;   // frame SP->X
assign opldxa=ir16==16'h9;
   
// note that now ir  D, E, and F are open   
endmodule