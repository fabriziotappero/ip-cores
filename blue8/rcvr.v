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

// async receiver -- Williams

module rcvr (input wire clk,input wire clke,input wire rst,input wire rxd,
  output [7:0] dout, output reg data_ready, input wire rdn,output reg framing_error, output reg overrun_error);
//input clk;	  // main clock coming in
//input clke;   // 16x baud rate clock enable
//input rst;	  // reset
//input rxd;   // serial input
//output [7:0] dout;  // output bus
//output data_ready;	// high when data is ready  
//input rdn;          // put data on dout when high
//output framing_error;  // high if frame error occurs
//output overrun_error;  // detects overrun
//reg overrun_error;


reg rxd1;	 // these two used to sync incoming data
reg rxd2;

reg clk1xe;   // clock enable for 1x clock
reg clk1x_enable;     // generate the 1x receive clock (that is, character reception in progress)
reg [3:0] clkdiv=0;  // divide 16x clock to 1x clock
reg [7:0] rsr;		 // shift register
reg [7:0] rbr;		 // buffer register
reg [3:0] no_bits_rcvd;  // counter

assign dout = (rdn & !rst) ? rbr : 8'bz;   // data bus output

always @(posedge clk or posedge rst)	 // synchronize incoming signal
begin
if (rst)
begin
  rxd1 <= 1'b1;
  rxd2 <= 1'b1;
end
else 
if (clke)
begin
  rxd1 <= rxd;
  rxd2 <= rxd1;
end
end

always @(posedge clk or posedge rst)				// go to 1x clock  until 9 (include stop) bits read
begin
if (rst)
  clk1x_enable <= 1'b0;
else if (clke) 
  begin
    if (!rxd2 & !rxd1 & !rxd)			           // detect start bit
       clk1x_enable <= 1'b1;							  // turn on clk1x
    if (no_bits_rcvd == 4'b1010)				  // or if done (no_bits_rcvd only increments during rcv)
       clk1x_enable <= 1'b0;							  // turn off
  end
end

always @(posedge clk or posedge rst)	     // if rdn is 1 then clear data ready, set it when all bits read
 begin												  // note, the dout assign "uses" rdn
  if (rst)
     data_ready = 1'b0;
  else 
  begin
    if (rdn) data_ready = 1'b0;
    if (clke)
	   if (no_bits_rcvd == 4'b1010)
        data_ready = 1'b1;
  end
end 

always @(posedge clk or posedge rst)	    // generate 1x rate clock
begin
  if (rst)		
  begin
    clkdiv <= 4'b0000;
  end
  else 
  begin 
    if (clke)
	   if (clk1x_enable)
		begin 	
	    clkdiv<=clkdiv+1; 
      end
	   else 
		begin
	    clkdiv<=4'b1000;   // ensure correct delay after start bit
      end
  end
end


always @(posedge clk or posedge rst)		// generate 1x clock enable
begin
 if (rst) clk1xe=1'b0;
 else
   if (clke & clk1x_enable & clkdiv==4'b1111) clk1xe=1'b1; else clk1xe=1'b0;
end



always @(posedge clk or posedge rst)			  // depending on number of bits, take actions
if (rst)
begin
  rsr = 8'b0;
  rbr = 8'b0;
  framing_error = 1'b0;
  overrun_error = 1'b0;
end
else if (clk1xe)
begin
   if (no_bits_rcvd >= 4'b0000 && no_bits_rcvd <= 4'b1000) 	  // some # of bits until 8 bits
   begin
     rsr[6:0]=rsr[7:1];
     rsr[7] = rxd2;         // shift bits in LSB first
     if (no_bits_rcvd==4'b1000) 
	    begin
		   if (data_ready)
			  overrun_error=1'b1;
         else
			  begin
			  overrun_error=1'b0;
		     rbr=rsr;	  // copy shift register to data register
           end
       end
		 if ((no_bits_rcvd == 4'b1000) && (rxd2 != 1'b1))		 // check for framing error
         framing_error = 1'b1;
       else
         framing_error = 1'b0;
   end
end
				  

always @(posedge clk or posedge rst)			 // count bits while 1x clock is running
if (rst)
  no_bits_rcvd = 4'b0000;
else 
  begin
  if (!clk1x_enable)							 // and reset count when 1x clock turns off
    no_bits_rcvd = 4'b0000;
  else
     if (clk1xe) no_bits_rcvd = no_bits_rcvd + 1;
 end

endmodule

