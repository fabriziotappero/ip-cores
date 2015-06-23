////////////////////////////////////////////////////////////////////////////////
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
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates
// Engineer:        Michael A. Morris
// 
// Create Date:     12:11:30 12/22/2007 
// Design Name:     HAWK Interface FPGA, 4020-0420, U35
// Module Name:     DPSFnmCE 
// Project Name:    4020 HAWK ZAOM Upgrade
// Target Devices:  XC2S150-5PQ208I
// Tool versions:   ISE 8.2i 
//
// Description: This module implements a parameterized version of a distributed
//              RAM synchronous FIFO. The address width, FIFO width and depth
//              are all specified by parameters. Default parameters settings 
//              describe a 16x16 FIFO with Full (FF), Empty (EF), and Half 
//              Full (HF) flags. The module also outputs the count words in the
//              FIFO.
//
// Dependencies:    None
//
// Revision History: 
//
//  0.01    07L22   MAM     File Created
//
//  0.10    08K05   MAM     Changed depth to a localparam based on addr
//
//  1.00    13G14   MAM     Converted to Verilog 2001 standard
//
// Additional Comments: 
//
////////////////////////////////////////////////////////////////////////////////

module DPSFnmCE #( 
    parameter addr  = 4,                // Sets depth of the FIFO: 2**addr
    parameter width = 16,               // Sets width of the FIFO
    parameter init  = "DPSFnmRAM.coe"   // Initializes FIFO memory
)(
    input   Rst,
    input   Clk,
    input   WE,
    input   RE,
    input   [(width - 1):0] DI,
    output  [(width - 1):0] DO,
    output  FF,
    output  EF,
    output  HF,
    output  [addr:0] Cnt
);

////////////////////////////////////////////////////////////////////////////////
//
//  Module Parameter List
//

localparam  depth = (2**addr);

////////////////////////////////////////////////////////////////////////////////
//
//  Module Level Declarations
//

    reg     [(width - 1):0] RAM [(depth - 1):0];
    
    reg     [ (addr - 1):0] A, DPRA;
    reg     [ (addr - 1):0] WCnt;
    reg     nEF, rFF;
    
    wire    Wr, Rd, CE;

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

//
//  Combinatorial Control Signals
//

assign Wr = WE & ~FF;
assign Rd = RE & ~EF;
assign CE = Wr ^ Rd;

//
//  Write Address Counter
//

always @(posedge Clk)
begin
    if(Rst)
        A <= #1 0;
    else if(Wr)
        A <= #1 A + 1;
end

//
//  Read Address Counter
//

always @(posedge Clk)
begin
    if(Rst)
       DPRA <= #1 0;
    else if(Rd)
        DPRA <= #1 DPRA + 1;
end

//
//   Word Counter
//

always @(posedge Clk)
begin
    if(Rst)
        WCnt <= #1 0;
    else if(Wr & ~Rd)
        WCnt <= #1 WCnt + 1;
    else if(Rd & ~Wr)
        WCnt <= #1 WCnt - 1;
end

//
//  External Word Count
//

assign Cnt = {FF, WCnt};

//
//  Empty Flag Register (Active Low)
//

always @(posedge Clk)
begin
    if(Rst)
        nEF <= #1 0;
    else if(CE)
        nEF <= #1 ~(RE & (Cnt == 1));
end

assign EF = ~nEF;

//
//  Full Flag Register
//

always @(posedge Clk)
begin
    if(Rst)
        rFF <= #1 0;
    else if(CE)
        rFF <= #1 (WE & (&WCnt));
end

assign FF = rFF;

//
//  Half-Full Flag
//

assign HF = Cnt[addr] | Cnt[(addr - 1)];

//
//  Dual-Port Synchronous RAM
//

initial
  $readmemh(init, RAM, 0, (depth - 1));

always @(posedge Clk)
begin
    if(Wr) 
        RAM[A] <= #1 DI;    // Synchronous Write
end

assign DO = RAM[DPRA];      // Asynchronous Read
        
endmodule
					