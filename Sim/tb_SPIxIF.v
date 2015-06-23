///////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2008-2013 by Michael A. Morris, dba M. A. Morris & Associates
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

///////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates
// Engineer:        Michael A. Morris
//
// Create Date:     07:30:59 03/18/2008
// Design Name:     SPIxIF.v
// Module Name:     tb_SPIx.v
// Project Name:    4020 HAWK ZAOM Upgrade, 0420-HAWKIF
// Target Device:   XC2S150-5PQ208I
// Tool versions:   ISE 8.2i
//  
// Description: Testbench for the modified SPIxIF.v module. 
//
//
// Verilog Test Fixture created by ISE for module: SPIxIF.v
//
// Dependencies:    None
// 
// Revision:
//
//  0.01    08C18   MAM     File Created
//
//  1.00    12I09   MAM     Modified to support updated SPIxIF.v module
//
// Additional Comments:
// 
///////////////////////////////////////////////////////////////////////////////

module tb_SPIxIF;

// Inputs
reg     Rst;
reg     Clk;

reg     LSB;
reg     [1:0] Mode;
reg     [2:0] Rate;

reg     DAV;
wire    FRE;
reg     [8:0] TD;

wire    FWE;
wire    [7:0] RD;

wire    SSEL;
wire    SCK;
wire    MOSI;
//wire    MISO;

integer i      = 0;
integer SS_Len = 0;
    
	// Instantiate the Unit Under Test (UUT)
	
SPIxIF  uut (
            .Rst(Rst), 
            .Clk(Clk),
            
            .LSB(LSB), 
            .Mode(Mode), 
            .Rate(Rate), 

            .DAV(DAV), 
            .FRE(FRE), 
            .TD(TD), 

            .FWE(FWE), 
            .RD(RD), 

            .SS(SS), 
            .SCK(SCK), 
            .MOSI(MOSI), 
            .MISO(MOSI)
        );

initial begin
    // Initialize Inputs
    Rst  = 1;
    Clk  = 0;
    
    LSB  = 0;
    Mode = 0;
    Rate = 0;
    
    DAV  = 0;
    TD   = 0;
    
    // Wait 100 ns for global reset to finish
    
    #101 Rst = 0;
    
    // Add stimulus here
    
    $display("Testing: MSB first, all four SPI modes, fastest SPI SCK rate\n");
    
    Mode = 0; Rate = 0; LSB = 0;

    $display("\tTest - Mode 0\n");
    #1;
    if(SCK != 0) begin
        $display("\t\tError: SCK did not idle low in Mode 0\n");
        $stop;
    end else begin
        $display("\t\tPass: SCK idled low in Mode 0\n");
    end
    @(posedge Clk) #1;
    DAV = 1; TD = 9'h1AB;
    @(posedge FRE) DAV = 0;
    #1;
    if(SCK != 0) begin
        $display("\t\tError: SCK did not start low in Mode 0\n");
        $stop;
    end else begin
        $display("\t\tPass: SCK started low in Mode 0\n");
    end
    @(negedge FWE) Mode = 1;
    #1;
    if(SCK != 0) begin
        $display("\t\tError: SCK did not idle low in Mode 0\n");
        $stop;
    end else begin
        $display("\t\tPass: SCK idled low in Mode 0\n");
    end
    if(RD != TD[7:0]) begin
        $display("\t\tError: RD not equal to TD\n");
        $stop;
    end else begin
        $display("\t\tPass: RD equal to TD\n");
    end
    if(SS_Len != 16) begin
        $display("\t\tError: SS Length != 16; SCK rate incorrect\n");
        $stop;
    end else begin
        $display("\t\tPass: SS Length == 16; SCK rate correct\n");
    end
    
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;

    $display("\tTest - Mode 1\n");
    #1;
    if(SCK != 1) begin
        $display("\t\tError: SCK did not idle high in Mode 1\n");
        $stop;
    end else begin
        $display("\t\tPass: SCK idled high in Mode 1\n");
    end
    @(posedge Clk) #1;
    DAV = 1; TD = 9'h15A;
    @(posedge FRE) DAV = 0;
    #1;
    if(SCK != 1) begin
        $display("\t\tError: SCK did not start high in Mode 1\n");
        $stop;
    end else begin
        $display("\t\tPass: SCK started high in Mode 1\n");
    end
    @(negedge FWE) Mode = 2;
    if(SCK != 1) begin
        $display("\t\tError: SCK did not idle high in Mode 1\n");
        $stop;
    end else begin
        $display("\t\tPass: SCK idled high in Mode 1\n");
    end
    if(RD != TD[7:0]) begin
        $display("\t\tError: RD not equal to TD\n");
        $stop;
    end else begin
        $display("\t\tPass: RD equal to TD\n");
    end
    if(SS_Len != 16) begin
        $display("\t\tError: SS Length != 16; SCK rate incorrect\n");
        $stop;
    end else begin
        $display("\t\tPass: SS Length == 16; SCK rate correct\n");
    end

    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;

    $display("\tTest - Mode 2\n");
    #1;
    if(SCK != 0) begin
        $display("\t\tError: SCK did not idle low in Mode 2\n");
        $stop;
    end else begin
        $display("\t\tPass: SCK idled low in Mode 2\n");
    end
    @(posedge Clk) #1;
    DAV = 1; TD = 9'h1A5;
    @(posedge FRE) DAV = 0;
    #1;
    if(SCK != 1) begin
        $display("\t\tError: SCK did not start high in Mode 2\n");
        $stop;
    end else begin
        $display("\t\tPass: SCK started high in Mode 2\n");
    end
    @(negedge FWE) Mode = 3;
    if(SCK != 0) begin
        $display("\t\tError: SCK did not idle low in Mode 2\n");
        $stop;
    end else begin
        $display("\t\tPass: SCK idled low in Mode 2\n");
    end
    if(RD != TD[7:0]) begin
        $display("\t\tError: RD not equal to TD\n");
        $stop;
    end else begin
        $display("\t\tPass: RD equal to TD\n");
    end
    if(SS_Len != 16) begin
        $display("\t\tError: SS Length != 16; SCK rate incorrect\n");
        $stop;
    end else begin
        $display("\t\tPass: SS Length == 16; SCK rate correct\n");
    end
    
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;

    $display("\tTest - Mode 3\n");
    #1;
    if(SCK != 1) begin
        $display("\t\tError: SCK did not idle high in Mode 3\n");
        $stop;
    end else begin
        $display("\t\tPass: SCK idled high in Mode 3\n");
    end
    @(posedge Clk) #1;
    DAV = 1; TD = 9'h169;
    @(posedge FRE) DAV = 0;
    #1;
    if(SCK != 0) begin
        $display("\t\tError: SCK did not start low in Mode 3\n");
        $stop;
    end else begin
        $display("\t\tPass: SCK started low in Mode 3\n");
    end
    @(negedge FWE) Mode = 0;
    if(SCK != 1) begin
        $display("\t\tError: SCK did not idle high in Mode 3\n");
        $stop;
    end else begin
        $display("\t\tPass: SCK idled high in Mode 3\n");
    end
    if(RD != TD[7:0]) begin
        $display("\t\tError: RD not equal to TD\n");
        $stop;
    end else begin
        $display("\t\tPass: RD equal to TD\n");
    end
    if(SS_Len != 16) begin
        $display("\t\tError: SS Length != 16; SCK rate incorrect\n");
        $stop;
    end else begin
        $display("\t\tPass: SS Length == 16; SCK rate correct\n");
    end

    $display("Testing multi-cycle transfer\n");
    @(posedge Clk) #1;
    DAV = 1;
    TD = 9'h002;
    @(negedge FRE);
    TD = 9'h000;
    @(negedge FRE);
    TD = 9'h0AA;
    @(negedge FRE);
    TD = 9'h055;
    @(negedge FRE);
    TD = 9'h000;
    DAV = 0;
    @(negedge SS) #1;
    if(SS_Len != 64) begin
        $display("\tError: SS Length != 64; Incorrect number of transfers\n");
        $stop;
    end else begin
        $display("\tPass: SS Length == 64; Correct number of transfers\n");
    end

    $display("Testing multi-cycle transfer with (Rate == 1)\n");
    Rate = 1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    
    DAV = 1;
    TD = 9'h002;
    @(negedge FRE);
    TD = 9'h000;
    @(negedge FRE);
    TD = 9'h0AA;
    @(negedge FRE);
    TD = 9'h055;
    @(negedge FRE);
    TD = 9'h000;
    DAV = 0;
    @(negedge SS) #1;
    if(SS_Len != 128) begin
        $display("\tError: SS Length != 128; SS_Len = %d\n", SS_Len);
        $stop;
    end else begin
        $display("\tPass: SS Length == %d\n", SS_Len);
    end

    $display("Testing multi-cycle transfer with (Rate == 2)\n");
    Rate = 2;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    
    DAV = 1;
    TD = 9'h002;
    @(negedge FRE);
    TD = 9'h000;
    @(negedge FRE);
    TD = 9'h0AA;
    @(negedge FRE);
    TD = 9'h055;
    @(negedge FRE);
    TD = 9'h000;
    DAV = 0;
    @(negedge SS) #1;
    if(SS_Len != 256) begin
        $display("\tError: SS Length != 256; SS_Len = %d\n", SS_Len);
        $stop;
    end else begin
        $display("\tPass: SS Length == %d\n", SS_Len);
    end

    $display("Testing multi-cycle transfer with (Rate == 3)\n");
    Rate = 3;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    
    DAV = 1;
    TD = 9'h002;
    @(negedge FRE);
    TD = 9'h000;
    @(negedge FRE);
    TD = 9'h0AA;
    @(negedge FRE);
    TD = 9'h055;
    @(negedge FRE);
    TD = 9'h000;
    DAV = 0;
    @(negedge SS) #1;
    if(SS_Len != 512) begin
        $display("\tError: SS Length != 512; SS_Len = %d\n", SS_Len);
        $stop;
    end else begin
        $display("\tPass: SS Length == %d\n", SS_Len);
    end

    $display("Testing multi-cycle transfer with (Rate == 4)\n");
    Rate = 4;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    
    DAV = 1;
    TD = 9'h002;
    @(negedge FRE);
    TD = 9'h000;
    @(negedge FRE);
    TD = 9'h0AA;
    @(negedge FRE);
    TD = 9'h055;
    @(negedge FRE);
    TD = 9'h000;
    DAV = 0;
    @(negedge SS) #1;
    if(SS_Len != 1024) begin
        $display("\tError: SS Length != 1024; SS_Len = %d\n", SS_Len);
        $stop;
    end else begin
        $display("\tPass: SS Length == %d\n", SS_Len);
    end

    $display("Testing multi-cycle transfer with (Rate == 5)\n");
    Rate = 5;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    
    DAV = 1;
    TD = 9'h002;
    @(negedge FRE);
    TD = 9'h000;
    @(negedge FRE);
    TD = 9'h0AA;
    @(negedge FRE);
    TD = 9'h055;
    @(negedge FRE);
    TD = 9'h000;
    DAV = 0;
    @(negedge SS) #1;
    if(SS_Len != 2048) begin
        $display("\tError: SS Length != 2048; SS_Len = %d\n", SS_Len);
        $stop;
    end else begin
        $display("\tPass: SS Length == %d\n", SS_Len);
    end

    $display("Testing multi-cycle transfer with (Rate == 6)\n");
    Rate = 6;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    
    DAV = 1;
    TD = 9'h002;
    @(negedge FRE);
    TD = 9'h000;
    @(negedge FRE);
    TD = 9'h0AA;
    @(negedge FRE);
    TD = 9'h055;
    @(negedge FRE);
    TD = 9'h000;
    DAV = 0;
    @(negedge SS) #1;
    if(SS_Len != 4096) begin
        $display("\tError: SS Length != 4096; SS_Len = %d\n", SS_Len);
        $stop;
    end else begin
        $display("\tPass: SS Length == %d\n", SS_Len);
    end

    $display("Testing multi-cycle transfer with (Rate == 7)\n");
    Rate = 7;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    
    DAV = 1;
    TD = 9'h002;
    @(negedge FRE);
    TD = 9'h000;
    @(negedge FRE);
    TD = 9'h0AA;
    @(negedge FRE);
    TD = 9'h055;
    @(negedge FRE);
    TD = 9'h000;
    DAV = 0;
    @(negedge SS) #1;
    if(SS_Len != 8192) begin
        $display("\tError: SS Length != 8192; SS_Len = %d\n", SS_Len);
        $stop;
    end else begin
        $display("\tPass: SS Length == %d\n", SS_Len);
    end

    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;

    $stop;
end

////////////////////////////////////////////////////////////////////////////////
//
//  Define Clocks
//

always #5 Clk = ~Clk;
    
////////////////////////////////////////////////////////////////////////////////

always @(negedge SS) SS_Len = i;

always @(posedge Clk or negedge SS)
begin
    if(~SS)
        #10 i = 0;
    else
        i = i + 1;
end

endmodule
