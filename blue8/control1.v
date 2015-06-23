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
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:37:29 10/08/2006 
// Design Name: 
// Module Name:    control1 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module control(input wire clkinput, input wire extstart, input wire extstop, input wire extexam, 
   input wire extdeposit, input wire ihlt, input wire aluov, output wire [8:1] cp,
	output wire [8:1] cpw, input wire extreset, output wire reset,
	output wire sw2bus, output wire loadpc1, input wire extloadpc, output wire exout, output wire depout,
	output wire running, output wire clkout, input wire abortcycle);
	wire wclk;
	controlclk sim(extstart,extstop,extexam,extdeposit,ihlt,aluov,cp,cpw,extreset,reset,
	sw2bus,loadpc1,extloadpc,exout,depout,running,clkout,wclk, abortcycle);

// Instantiate the DCM
maindcm clockgen (
    .CLKIN_IN(clkinput), 
    .RST_IN(1'b0), 
    .CLKFX_OUT(clkout), 
    .CLKFX180_OUT(wclk)
    );
endmodule
