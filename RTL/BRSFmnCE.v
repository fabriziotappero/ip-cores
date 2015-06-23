`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates 
// Engineer:        Michael A. Morris 
// 
// Create Date:     11:48:14 07/27/2008 
// Design Name:     Parameterizable Synchronous Block RAM FIFO
// Module Name:     BRSFmnCE.v
// Project Name:    C:\XProjects\VerilogComponentsLib\FIFO - Block RAM
// Target Devices:  SRAM FPGA: XC3S1400AN-5FFG676I, XC3S700AN-4FGG484I
// Tool versions:   Xilinx ISE10.1i SP3 
//
// Description:
//
//  This module implements a synchronous FIFO using Block RAM resources such as 
//  thos found in SRAM-based FPGAs. This module has been used in several
//  projects based on Xilinx Spartan 3AN FPGAs. It can be adapted to other deve-
//  lopment systems, but only Xilinx ISE has been used to date.
//
//  All components used in this module are inferred, including the Block RAM.
//  This allows the depth and width to be set by parameters. Furthermore, the
//  state of the memory, the write pointer, and FIFO flags can be initialized.
//  This allows FIFO to be preconditioned with a copyright notice, configura-
//  tion data, etc.
//
// Dependencies: None
//
// Revision:
// 
//  1.00    08G27   MAM     File Created
//
//  1.10    13H12   MAM     Prepared for release on Opencores.com. Converted to
//                          Verilog-2001 format.
//
// Additional Comments:
//
//  Note:   Initialization of the FIFO memory contents only occurs once. If
//          Reset is reasserted, current implementation cannot reinitialize
//          memory contents unless Reset also causes reload of the configuration
//          image of the SRAM-based FPGA.
//
////////////////////////////////////////////////////////////////////////////////

module BRSFmnCE #(
    parameter pAddr        = 10,            // Number of Address Bits
    parameter pWidth       = 8,             // Number of Data Bits
    parameter pRAMInitSize = 128,           // Amount Data to Init into FIFO RAM
    parameter pFRAM_Init   = "RAMINIT.mif"  // RAM Memory Initialization File
)(
    input   Rst,                        // System Reset - Synchronous
    input   Clk,                        // System Clock
    
    input   Clr,                        // FIFO Clear
    
    input   WE,                         // FIFO Write Enable
    input   [(pWidth - 1):0] DI,        // FIFO Input Data
    
    input   RE,                         // FIFO Read Enable
    output  reg [(pWidth - 1):0] DO,    // FIFO Output Data
    output  reg ACK,                    // FIFO Read Acknowledge
    
    output  reg FF,                     // FIFO Full Flag
    output  reg AF,                     // FIFO Almost Full Flag (Full - 1)
    output  HF,                         // FIFO Half Full Flag
    output  reg AE,                     // FIFO Almost Empty Flag (Count == 1)
    output  reg EF,                     // FIFO Empty Flag (Count == 0)
    
    output  [pAddr:0] Cnt               // FIFO Word Count
);

////////////////////////////////////////////////////////////////////////////////
//
//  Module Signal Declarations
//

    reg     [(pWidth - 1):0] FRAM [((2**pAddr) - 1):0];
    
    reg     [(pAddr - 1):0] WPtr, RPtr, WCnt;
    
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
//  Read Acknowledge
//

always @(posedge Clk)
begin
    if(Rst | Clr)
        ACK <= #1 0;
    else
        ACK <= #1 Rd;
end

//
//  Write Address Counter
//

always @(posedge Clk)
begin
    if(Rst)
        WPtr <= #1 pRAMInitSize;
    else if(Clr)
        WPtr <= #1 0;
    else if(Wr)
        WPtr <= #1 WPtr + 1;
end

//
//  Read Address Counter
//

always @(posedge Clk)
begin
    if(Rst | Clr)
        RPtr <= #1 0;
    else if(Rd)
        RPtr <= #1 RPtr + 1;
end

//
//   Word Counter
//

always @(posedge Clk)
begin
    if(Rst)
        WCnt <= #1 pRAMInitSize;
    else if(Clr)
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
//  Empty Flag Register
//

always @(posedge Clk)
begin
    if(Rst)
        EF <= #1 (pRAMInitSize == 0);
    else if(Clr)
        EF <= #1 1;
    else if(CE)
        EF <= #1 ((WE) ? 0 : (~|Cnt[pAddr:1]));
end

//
//  Almost Empty Flag Register
//

always @(posedge Clk)
begin
    if(Rst)
        AE <= #1 (pRAMInitSize == 1);
    else if(Clr)
        AE <= #1 0;
    else if(CE)
        AE <= #1 (Rd & (~|Cnt[pAddr:2]) & Cnt[1] & ~Cnt[0]) | (Wr & EF);
end        

//
//  Full Flag Register
//

always @(posedge Clk)
begin
    if(Rst)
        FF <= #1 (pRAMInitSize == (1 << pAddr));
    else if(Clr)
        FF <= #1 0;
    else if(CE)
        FF <= #1 ((RE) ? 0 : (&WCnt));
end

//
//  Almost Full Flag Register
//

always @(posedge Clk)
begin
    if(Rst)
        AF <= #1 (pRAMInitSize == ((1 << pAddr) - 1));
    else if(Clr)
        AF <= #1 0;
    else if(CE)
        AF <= #1 (Wr & (~Cnt[pAddr] & (&Cnt[(pAddr-1):1]) & ~Cnt[0]))
                 | (Rd & FF);
end        

//
//  Half-Full Flag
//

assign HF = ~EF & (Cnt[pAddr] | Cnt[(pAddr - 1)]);

////////////////////////////////////////////////////////////////////////////////
//
//  FIFO Block RAM
//

initial
    $readmemh(pFRAM_Init, FRAM, 0, ((1 << pAddr) - 1));

always @(posedge Clk)
begin
    if(Wr)
        FRAM[WPtr] <= #1 DI;
end

always @(posedge Clk)
begin
    DO <= #1 FRAM[RPtr];
end

endmodule
