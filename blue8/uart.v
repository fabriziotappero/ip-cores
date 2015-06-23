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

module uart (input wire clk, input wire rst, input wire rxd,
  output wire txd,input wire [7:0] din, output wire [7:0] dout,
  output wire data_ready, input wire read,output wire tbre,output wire tsre,input wire write,
  output wire framing_error,output wire overrun_error);


parameter XTAL_CLK = 35000000;		//use 40MHz for BLUE, 50MHz for stand alone
parameter BAUD = 9600;
parameter CLK_DIV = XTAL_CLK / (BAUD * 16 * 2);	//163 for 9600@50MHz, 	130 @40MHz
parameter CW   = 8;	 // must be enough bits to hold CLK_DIV


reg		[CW-1:0]	clk_div;
reg				baud_clk;
reg	   clke;

always @(posedge clk or posedge rst)	 // generate 16x baud clock
begin
  if (rst) begin
    clk_div  <= 0;
    baud_clk <= 0; 
	 clke<=1'b0;
  end else if (clk_div == CLK_DIV) begin
    clk_div  <= 0;
    baud_clk <= ~baud_clk;
	 clke<=1'b0;
  end else begin
    clke<=1'b0;
    if (clk_div==CLK_DIV-1 && ~baud_clk) clke<=1'b1;
    clk_div  <= clk_div + 1;
    baud_clk <= baud_clk;
  end
end


rcvr u1 (clk,clke,rst,rxd,dout,data_ready,read,framing_error,overrun_error);		 
					  
txmit u2 (clk,clke,rst,txd,din,tbre,tsre,write);

endmodule
