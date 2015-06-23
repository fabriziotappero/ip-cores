///////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2007-2013 by Michael A. Morris, dba M. A. Morris & Associates
//
//  All rights reserved. The source code contained herein is publicly released
//  under the terms and conditions of the GNU Lesser Public License. No part of
//  this source code may be reproduced or transmitted in any form or by any
//  means, electronic or mechanical, including photocopying, recording, or any
//  information storage and retrieval system in violation of the license under
//  which the source code is released.
//
//  The source code contained herein is free; it may be redistributed and/or 
//  modified in accordance with the terms of the GNU Lesser General Public
//  License as published by the Free Software Foundation; either version 2.1 of
//  the GNU Lesser General Public License, or any later version.
//
//  The source code contained herein is freely released WITHOUT ANY WARRANTY;
//  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
//  PARTICULAR PURPOSE. (Refer to the GNU Lesser General Public License for
//  more details.)
//
//  A copy of the GNU Lesser General Public License should have been received
//  along with the source code contained herein; if not, a copy can be obtained
//  by writing to:
//
//  Free Software Foundation, Inc.
//  51 Franklin Street, Fifth Floor
//  Boston, MA  02110-1301 USA
//
//  Further, no use of this source code is permitted in any form or means
//  without inclusion of this banner prominently in any derived works. 
//
//  Michael A. Morris
//  Huntsville, AL
//
///////////////////////////////////////////////////////////////////////////////`timescale 1ns / 1ps

`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates
// Engineer:        Michael A. Morris
//
// Create Date:     14:41:48 12/22/2007
// Design Name:     DPSFnmCE
// Module Name:     tb_DPSFmnCE.v
// Project Name:    4020 HAWK ZAOM Upgrade, 0420-HAWKIF
// Target Device:   XC2S150-5PQ208I
// Tool versions:   ISE 8.2i
//  
// Description: Test bench for the Dual-Port Synchrnouse FIFO RAM. Default 
//              parameters are used for the module instantiation.
//
// Verilog Test Fixture created by ISE for module: DPSFnmCE
//
// Dependencies:    None
// 
// Revision:
//
//  0.01    07L22   MAM     File Created
//
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_DPSFmnCE_v;

	// Inputs
	reg Rst;
	reg Clk;
	reg WE;
	reg RE;
	reg [15:0] DI;

	// Outputs
	wire [15:0] DO;
	wire FF;
	wire EF;
	wire HF;
	wire [4:0] Cnt;

	// Instantiate the Unit Under Test (UUT)
	DPSFnmCE uut (
		.Rst(Rst), 
		.Clk(Clk), 
		.WE(WE), 
		.RE(RE), 
		.DI(DI), 
		.DO(DO), 
		.FF(FF), 
		.EF(EF), 
		.HF(HF), 
		.Cnt(Cnt)
	);

	initial begin
		// Initialize Inputs
		Rst = 1;
		Clk = 1;
		WE = 0;
		RE = 0;
		DI = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
        
        Rst = 0;
        
        FIFO_Wr(16'h1111);
        FIFO_Wr(16'h2222);
        FIFO_Wr(16'h3333);
        FIFO_Wr(16'h4444);

        FIFO_Wr(16'h5555);
        FIFO_Wr(16'h6666);
        FIFO_Wr(16'h7777);
        FIFO_Wr(16'h8888);

        FIFO_Wr(16'h9999);
        FIFO_Wr(16'hAAAA);
        FIFO_Wr(16'hBBBB);
        FIFO_Wr(16'hCCCC);

        FIFO_Wr(16'hDDDD);
        FIFO_Wr(16'hEEEE);
        FIFO_Wr(16'hFFFF);
        FIFO_Wr(16'h0000);
        
        FIFO_Rd;
        
        FIFO_Wr(16'h0001);

        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;

        FIFO_Wr(16'h0001);
        FIFO_Wr(16'h0002);
        FIFO_Wr(16'h0004);
        FIFO_Wr(16'h0008);
        FIFO_Wr(16'h0010);
        FIFO_Wr(16'h0020);
        FIFO_Wr(16'h0040);
        FIFO_Wr(16'h0080);
        FIFO_Wr(16'h0100);
        FIFO_Wr(16'h0200);
        FIFO_Wr(16'h0400);
        FIFO_Wr(16'h0800);
        FIFO_Wr(16'h1000);
        FIFO_Wr(16'h2000);
        FIFO_Wr(16'h4000);
        FIFO_Wr(16'h8000);

        FIFO_Wr(16'h8001);

        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;

        FIFO_RW(16'h8001);

        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
        FIFO_Rd;
   	end
    
    always #5 Clk = ~Clk;
      
    // FIFO Write Task
    
    task FIFO_Wr;
    
        input   [15:0] Data;
    
        begin
            @(posedge Clk);
            #1 WE = 1; DI = Data;
            @(posedge Clk);
            #1 WE = 0;
        end
        
    endtask
    
    // FIFO Read Task
    
    task FIFO_Rd;
    
        begin
            @(posedge Clk);
            #1 RE = 1;
            @(posedge Clk);
            #1 RE = 0;
        end
        
    endtask
    
    // FIFO Simultaneous Read/Write Task
    
    task FIFO_RW;
    
        input   [15:0] Data;
    
        begin
            @(posedge Clk);
            #1 WE = 1; RE = 1; DI = Data;
            @(posedge Clk);
            #1 WE = 0; RE = 0;
        end
        
    endtask
    
endmodule

