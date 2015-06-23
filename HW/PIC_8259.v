//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the Next186 Soc PC project
// http://opencores.org/project,next186
//
// Filename: PIC_8259.v
// Description: Part of the Next186 SoC PC project, PIC controller
// 	8259 simplified interrupt controller (only interrupt mask can be read, not IRR or ISR, no EOI required)
// Version 1.0
// Creation date: May2012
//
// Author: Nicolae Dumitrache 
// e-mail: ndumitrache@opencores.org
//
/////////////////////////////////////////////////////////////////////////////////
// 
// Copyright (C) 2012 Nicolae Dumitrache
// 
// This source file may be used and distributed without 
// restriction provided that this copyright statement is not 
// removed from the file and that any derivative work contains 
// the original copyright notice and the associated disclaimer.
// 
// This source file is free software; you can redistribute it 
// and/or modify it under the terms of the GNU Lesser General 
// Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any 
// later version. 
// 
// This source is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied 
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
// PURPOSE. See the GNU Lesser General Public License for more 
// details. 
// 
// You should have received a copy of the GNU Lesser General 
// Public License along with this source; if not, download it 
// from http://www.opencores.org/lgpl.shtml 
// 
///////////////////////////////////////////////////////////////////////////////////
// Additional Comments: 
// http://wiki.osdev.org/8259_PIC
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module PIC_8259(
    input CS,
	 input WR,
	 input [7:0]din,
	 output wire [7:0]dout,
	 output reg [7:0]ivect,
	 input clk,		// cpu CLK
	 output reg INT = 0,
	 input IACK,
	 input [3:0]I	// 0:timer, 1:keyboard, 2:RTC, 3:mouse
    );
	 
	reg [3:0]ss_I = 0;
	reg [3:0]s_I = 0;
	reg [3:0]IMR = 4'b1111;
	reg [3:0]IRR = 0;
	
	assign dout = {3'b000, IMR[3:2], 1'b0, IMR[1:0]};
	
	always @ (posedge clk) begin
		ss_I <= I;
		s_I <= ss_I;
		IRR <= (IRR | (~s_I & ss_I)) & ~IMR;	// front edge detection
		if(~INT) begin
			if(IRR[0]) begin //timer
				INT <= 1; 
				ivect <= 8'h08;
				IRR[0] <= 0;
			end else if(IRR[1]) begin  // keyboard
				INT <= 1; 
				ivect <= 8'h09; 
				IRR[1] <= 0;
			end else if(IRR[2]) begin  // RTC
				INT <= 1; 
				ivect <= 8'h70; 
				IRR[2] <= 0;
			end else if(IRR[3]) begin // mouse
				INT <= 1; 
				ivect <= 8'h74; 
				IRR[3] <= 0;
			end	
		end else if(IACK) INT <= 0;	// also act as Auto EOI
		
		if(CS & WR) IMR <= {din[4:3], din[1:0]};
	end
	

endmodule


