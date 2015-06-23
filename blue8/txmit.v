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

// Async transmitter -- Williams
`default_nettype none
			   
module txmit (input wire clk,input wire clke,input wire rst,output reg sdo,input wire [7:0] din,
output reg tbre,output reg tsre,input write);
//input clk;		// system clock
//input clke;		// 16x baud rate clock enable
//input rst;     // reset
//output sdo;    // output data
//output tbre;   // transmit buffer empty
//output tsre;   // transmit shift reg. empty
//input [7:0] din;	// data bus in
//input write;	// load tbr

reg clk1x_enable;  // 1x clock enable flag (character in progress)
reg [7:0] tsr;     // shift register
reg [7:0] tbr;		 // buffer register

reg[3:0] clkdiv;   // used to divide 16x clock to 1x clock
reg [3:0] no_bits_sent;  // track # of bits sent
reg clk1xe;        // 1x clock enable

always @(posedge clk or posedge rst)	  // manage data coming in from the system
begin
  if (rst)
  begin
    tbre<=1'b1;
	 clk1x_enable<=1'b0;
	 tbr=8'b0;
  end
  else 
  begin
    if (clk1xe)
	 begin
      if (no_bits_sent == 4'b0010) tbre<=1'b1; 		  // at count 2, tbr is empty again
      else if (no_bits_sent==4'b1011)  clk1x_enable<=1'b0;    // done!
    end
  if (clke & no_bits_sent==4'b0000 & ~tbre) clk1x_enable<=1'b1;  // send buffered
  if (write & tbre)  // if writing and buffer is empty, start process
  begin	
    clk1x_enable<=1'b1;  // start right away, unless already 1 at which point nop		
	 tbre<=1'b0;					   
	 tbr=din;
  end
  end
 end		   
 

always @(posedge clk or posedge rst)		 // generate 1x rate clock
begin
if (rst)
  clkdiv = 4'b0; 
else if (clke && clk1x_enable)
  clkdiv = clkdiv + 1;
else if (~clk1x_enable) clkdiv=4'b0;
end

always @(posedge clk or posedge rst)		// generate 1x clock enable
begin
 if (rst) clk1xe=1'b0;
 else
   if (clke & clk1x_enable & clkdiv==4'b0111) clk1xe=1'b1; else clk1xe=1'b0;
end


always @(posedge clk or posedge rst)	// main state machine
if (rst)
begin
sdo <= 1'b1;
tsre <= 1'b1;
tsr <= 9'b0;
end
  else if (clk1xe)
  begin
    if (no_bits_sent == 4'b0001)  // start, so load shift register
    begin
      tsr[7:0] <= tbr;
		sdo<=1'b0;   // start bit
      tsre <= 1'b0;
    end
    else if ((no_bits_sent >= 4'b0010) && (no_bits_sent <= 4'b1010))
    begin
      tsr[6:0] <= tsr[7:1];
      tsr[7] <= 1'b1;	    // shift in stop bits
      sdo <= tsr[0];
	   if (no_bits_sent==4'b1010) tsre<=1'b1;	// last bit, shift reg empty just stop bit
    end
end

always @(posedge clk or posedge rst)	 // manage the # of bits sent
begin
  if (rst) 
    no_bits_sent = 4'b0000;
  else if (clk1xe)
    begin
    if (no_bits_sent==4'b1011)
      no_bits_sent = 4'b0000;
    else
      no_bits_sent = no_bits_sent + 1; 
    end
end

endmodule

 
