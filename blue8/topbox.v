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

`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    10:26:07 12/28/05
// Design Name:    
// Module Name:    topbox
// Project Name:   
// Target Device:  
// Tool versions:  
// Description:
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`default_nettype	 none
module topbox(input clkin, input pb0, input pb1, input pb2, input pb3, input [7:0] sw,
output [7:0] led, output [6:0] display, output dp, output[3:0] digsel,
			 output wire [17:0] xmaddress, inout wire [15:0] xmdata, output wire xmwrite, 
				 output wire xmsend, output wire xmce, output wire xmub, output wire xmlb,	 
				 output wire serialout, input wire serialin);
wire clk;
wire clear, start, stop, lpc, exam, dep, xrun;
wire [15:0] ir;
wire [15:0] ac; 
wire [11:0] pc;
wire [15:0] swreg;
wire cpuwrite, cpusend;
wire ser_avail;	 
wire ser_tbe, ser_tse;
wire ser_ferr, ser_oerr;
wire [7:0] serialrx;

wire Q;
wire iomem;

assign iomem=xmaddress[17:4]==14'h0FF;
assign xmce=~((cpusend|cpuwrite)& ~iomem);  // enable on all reads and writes except those in I/O block
assign xmub=1'b0;
assign xmlb=1'b0;
assign xmaddress[17:12]=6'b0;
assign xmwrite=~cpuwrite;
assign xmsend=~cpusend;

// start RS232 loader
reg loadlow;
reg loadnow;
reg [15:0] swregx;
reg [3:0] loaddelay;

always @(posedge clk or posedge clear)
begin
if (clear) 
  begin
  loadlow<=1'b0;
  loadnow<=1'b0;
  loaddelay<=4'b0000;  // hold swregx long enough for load cycle
  end
else if (led[2] || led[4]) begin loadlow<=1'b0; loadnow<=1'b0; loaddelay<=4'b0000; end  // reset if not in load mode
else if (led[3] & ~led[7])  // must be in load and not in running mode
  begin
    	if (ser_avail & ~loadlow) begin swregx[15:8]<=serialrx; loadlow<=1; end
		else if (ser_avail & loadlow) begin swregx[7:0]<=serialrx; loadlow<=1'b0; loadnow<=1'b1; end
		else if (loadnow && loaddelay==4'b1000) 
		  begin
		    loadnow<=1'b0;
			 loaddelay<=4'b0000;
        end else if (loadnow)
		    loaddelay<=loaddelay+1;
     end
end


// end loader

wire loadsw;
wire readuart, writeuart, readio, writeio;
assign readio=cpusend & iomem;
assign writeio=cpuwrite & iomem;
assign readuart=readio & xmaddress[3:0]==4'hf;
assign writeuart=writeio & xmaddress[3:0]==4'hf;

assign loadsw=cpuwrite & (xmaddress[3:0]==4'h0) & iomem;
assign xmdata=(readio & (xmaddress[3:0]==4'h0))? swreg : 16'bz;
assign xmdata=(readio & (xmaddress[3:0]==4'h1))? { pb3, 7'h0, sw }:16'bz;

// Note that a change in tactics means that pb3 is known as pb0 in the front panel!
// pb2 is pb1 etc. (ought to change it).
FrontPanel panel(clk, pb3, pb2, pb1, pb0, sw, led, display, dp, digsel,
   clear, start, stop, lpc, exam, dep, xrun, swreg, ir, ac,  pc, Q, loadsw, xmdata);

blue CPU(clear,clkin, ac, start,
              stop,  exam,   dep|loadnow, pc,
				  loadnow?swregx:swreg, lpc, ir,xrun,xmaddress[11:0],xmdata,cpuwrite,cpusend,clk, Q);




assign xmdata= (readuart) ? { ser_avail, 7'b0000000, serialrx  } : 16'bz;
assign xmdata= (readio & (xmaddress[3:0]==4'he)) ? {  ser_tbe, ser_tse, ser_ferr, ser_oerr ,ser_avail, 11'b0 } : 16'bz;

defparam serialport.BAUD=57600;
defparam serialport.XTAL_CLK = 36000000;

uart serialport	(	clk, clear, serialin, serialout, xmdata[7:0],
				serialrx,ser_avail,readuart|(led[3]&~led[7]&ser_avail&~loadnow),ser_tbe,ser_tse,
				writeuart ,ser_ferr,ser_oerr);


endmodule
