/****************************************************************************************
*
*    File Name:  MT58L64L32P.V
*      Version:  1.5
*         Date:  June 29th, 2001
*        Model:  Behavioral
*    Simulator:  Model Technology
*
* Dependencies:  None
*
*       Author:  Son P. Huynh
*        Email:  sphuynh@micron.com
*        Phone:  (208) 368-3825
*      Company:  Micron Technology, Inc.
*       Part #:  MT58L64L32P (64K x 32)
*
*  Description:  This is Micron's Synburst SRAM (Pipelined SCD)
*
*   Limitation:  
*
*   Disclaimer:  THESE DESIGNS ARE PROVIDED "AS IS" WITH NO WARRANTY 
*                WHATSOEVER AND MICRON SPECIFICALLY DISCLAIMS ANY 
*                IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR
*                A PARTICULAR PURPOSE, OR AGAINST INFRINGEMENT.
*
*                Copyright (c) 1997 Micron Semiconductor Products, Inc.
*                All rights researved
*
* Rev  Author          Phone           Date        Changes
* ---  --------------  --------------  ----------  --------------------------------------
* 1.5  Son P. Huynh    (208) 368-3825  04/30/1999  Update timing parameters
*      Micron Technology, Inc.
*
****************************************************************************************/

// DO NOT CHANGE THE TIMESCALE
// MAKE SURE YOUR SIMULATOR USE "PS" RESOLUTION
`timescale 1ns / 100ps

module mt58l64l32p (Dq, Addr, Mode, Adv_n, Clk, Adsc_n, Adsp_n, Bwa_n, Bwb_n, Bwc_n, Bwd_n, Bwe_n, Gw_n, Ce_n, Ce2, Ce2_n, Oe_n, Zz);

    // Constant Parameters
    parameter                       addr_bits =     16;         //  16 bits
    parameter                       data_bits =     32;         //  32 bits
    parameter                       mem_sizes =  65535;         //  64 K
    
    // Timing Parameters for -5 (200 Mhz)
    parameter                       tKQHZ     =      2.5;       // Clock to output HiZ

    // Port Delcarations
    inout     [(data_bits - 1) : 0] Dq;                         // Data IO
    input     [(addr_bits - 1) : 0] Addr;                       // Address
    input                           Mode;                       // Burst Mode
    input                           Adv_n;                      // Synchronous Address Advance
    input                           Clk;                        // Clock
    input                           Adsc_n;                     // Synchronous Address Status Controller
    input                           Adsp_n;                     // Synchronous Address Status Processor
    input                           Bwa_n;                      // Synchronous Byte Write Enables
    input                           Bwb_n;                      // Synchronous Byte Write Enables
    input                           Bwc_n;                      // Synchronous Byte Write Enables
    input                           Bwd_n;                      // Synchronous Byte Write Enables
    input                           Bwe_n;                      // Byte Write Enable
    input                           Gw_n;                       // Global Write
    input                           Ce_n;                       // Synchronous Chip Enable
    input                           Ce2;                        // Synchronous Chip Enable
    input                           Ce2_n;                      // Synchronous Chip Enable
    input                           Oe_n;                       // Output Enable
    input                           Zz;                         // Snooze Mode

    // Memory Arrays
    reg [((data_bits / 4) - 1) : 0] bank0 [0 : mem_sizes];      // Memory Bank 0
    reg [((data_bits / 4) - 1) : 0] bank1 [0 : mem_sizes];      // Memory Bank 1
    reg [((data_bits / 4) - 1) : 0] bank2 [0 : mem_sizes];      // Memory Bank 2
    reg [((data_bits / 4) - 1) : 0] bank3 [0 : mem_sizes];      // Memory Bank 3

    // Declare Connection Variables
    reg       [(data_bits - 1) : 0] dout;                       // Output Registers
    reg       [(addr_bits - 1) : 0] addr_reg_in;                // Address Register In
    reg       [(addr_bits - 1) : 0] addr_reg_read;              // Address Register for Read Operation
    reg                     [1 : 0] bcount;                     // 2-bit Burst Counter

    reg                             ce_reg;
    reg                             pipe_reg;
    reg                             bwa_reg;
    reg                             bwb_reg;
    reg                             bwc_reg;
    reg                             bwd_reg;
    reg                             sys_clk;

    wire                            ce      = (~Ce_n & Ce2 & ~Ce2_n);
    wire                            bwa_n   = ((Bwa_n | Bwe_n) & Gw_n | (~Ce_n & ~Adsp_n));
    wire                            bwb_n   = ((Bwb_n | Bwe_n) & Gw_n | (~Ce_n & ~Adsp_n));
    wire                            bwc_n   = ((Bwc_n | Bwe_n) & Gw_n | (~Ce_n & ~Adsp_n));
    wire                            bwd_n   = ((Bwd_n | Bwe_n) & Gw_n | (~Ce_n & ~Adsp_n));
    wire                            clr     = (~Adsc_n | (~Adsp_n & ~Ce_n));

    wire      [(addr_bits - 1) : 0] addr_reg_write;             // Address Register for Write Operation
    wire                            baddr1;                     // Burst Address 1
    wire                            baddr0;                     // Burst Address 0

    // Initial Conditions
    initial begin
        ce_reg = 1'b0;
        sys_clk = 1'b0;
        pipe_reg = 1'b0;
        $timeformat (-9, 1, " ns", 10);                         // Format time unit
    end

    // System Clock
    always begin
        @ (posedge Clk) begin
            sys_clk = ~Zz;
        end
        @ (negedge Clk) begin
            sys_clk = 1'b0;
        end
    end

    always @ (posedge sys_clk) begin
        // Address Register
        if (clr) addr_reg_in   <= Addr;
                 addr_reg_read <= {addr_reg_in[addr_bits - 1 : 2], baddr1, baddr0};

        // Binary Counter and Logic
        if      ( Mode  &  clr) bcount <= 0;                    // Interleaved Burst
        else if (~Mode  &  clr) bcount <= Addr [1 : 0];         // Linear Burst
        else if (~Adv_n & ~clr) bcount <= (bcount + 1);         // Advance Counter

        // Byte Write Register    
        bwa_reg <= ~bwa_n;
        bwb_reg <= ~bwb_n;
        bwc_reg <= ~bwc_n;
        bwd_reg <= ~bwd_n;

        // Enable Register
        if (clr) ce_reg <= ce;

        // Pipelined Enable
        pipe_reg <= ce_reg;

    end

    // Burst Address Decode
    assign addr_reg_write = {addr_reg_in [(addr_bits - 1) : 2], baddr1, baddr0};
    assign baddr1 = Mode ? (bcount [1] ^ addr_reg_in [1]) : bcount [1];
    assign baddr0 = Mode ? (bcount [0] ^ addr_reg_in [0]) : bcount [0];

    // Write Driver
    always @ (posedge Clk) begin
        #0.1;
        if (ce_reg & bwa_reg) begin
            bank0 [addr_reg_write] <= Dq [((data_bits / 4) - 1) : 0];
        end
        if (ce_reg & bwb_reg) begin
            bank1 [addr_reg_write] <= Dq [((data_bits / 2) - 1) : (data_bits / 4)];
        end
        if (ce_reg & bwc_reg) begin
            bank2 [addr_reg_write] <= Dq [(((data_bits / 4) * 3) - 1) : (data_bits / 2)];
        end
        if (ce_reg & bwd_reg) begin
            bank3 [addr_reg_write] <= Dq [(data_bits - 1) : ((data_bits / 4) * 3)];
        end
    end

    // Output Register
    always @ (posedge Clk) begin
        #0.1;
        if (~(bwa_reg | bwb_reg | bwc_reg | bwd_reg)) begin
            dout [((data_bits / 4) - 1) : 0] <= bank0 [addr_reg_read];
            dout [((data_bits / 2) - 1) : (data_bits / 4)] <= bank1 [addr_reg_read];
            dout [(((data_bits / 4) * 3) - 1) : (data_bits / 2)] <= bank2 [addr_reg_read];
            dout [(data_bits - 1) : ((data_bits / 4) * 3)] <= bank3 [addr_reg_read];
        end
    end

    // Output Buffer
    assign #tKQHZ Dq = (~Oe_n & ~Zz & ce_reg & pipe_reg & ~(bwa_reg | bwb_reg | bwc_reg | bwd_reg)) ? dout : {data_bits{1'bz}};

    // Timing Check for -5 (200 Mhz)
    specify
        specparam   // Clock
                    tKC     =  5.0,
                    tKH     =  1.6,
                    tKL     =  1.6,
                    // Setup Times
                    tAS     =  1.5,
                    tADSS   =  1.5,
                    tAAS    =  1.5,
                    tWS     =  1.5,
                    tDS     =  1.5,
                    tCES    =  1.5,
                    // Hold Times
                    tAH     =  0.5,
                    tADSH   =  0.5,
                    tAAH    =  0.5,
                    tWH     =  0.5,
                    tDH     =  0.5,
                    tCEH    =  0.5;

        $width      (negedge Clk, tKL);
        $width      (posedge Clk, tKH);
        $period     (negedge Clk, tKC);
        $period     (posedge Clk, tKC);
        $setuphold  (posedge Clk, Adsp_n, tADSS, tADSH);
        $setuphold  (posedge Clk, Adsc_n, tADSS, tADSH);
        $setuphold  (posedge Clk, Addr,   tAS,   tAH);
        $setuphold  (posedge Clk, Bwa_n,  tWS,   tWH);
        $setuphold  (posedge Clk, Bwb_n,  tWS,   tWH);
        $setuphold  (posedge Clk, Bwc_n,  tWS,   tWH);
        $setuphold  (posedge Clk, Bwd_n,  tWS,   tWH);
        $setuphold  (posedge Clk, Bwe_n,  tWS,   tWH);
        $setuphold  (posedge Clk, Gw_n,   tWS,   tWH);
        $setuphold  (posedge Clk, Ce_n,   tCES,  tCEH);
        $setuphold  (posedge Clk, Ce2,    tCES,  tCEH);
        $setuphold  (posedge Clk, Ce2_n,  tCES,  tCEH);
        $setuphold  (posedge Clk, Adv_n,  tAAS,  tAAH);
    endspecify                        

endmodule

