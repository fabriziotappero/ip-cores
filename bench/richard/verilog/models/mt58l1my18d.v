/****************************************************************************************
*
*    File Name:  MT58L1MY18D.V
*      Version:  1.3
*         Date:  March 8th, 1999
*        Model:  BUS Functional
*    Simulator:  Model Technology
*
* Dependencies:  None
*
*       Author:  Son P. Huynh
*        Email:  sphuynh@micron.com
*        Phone:  (208) 368-3825
*      Company:  Micron Technology, Inc.
*       Part #:  MT58L1MY18D (1Mb x 18)
*
*  Description:  This is Micron's Syncburst SRAM (Pipelined DCD)
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
* Rev  Author                        Date        Changes
* ---  ----------------------------  ----------  ---------------------------------------
* 1.3  Son P. Huynh    208-368-3825  03/08/1999  Improve model functionality
*      Micron Technology, Inc.
*
****************************************************************************************/

// DO NOT CHANGE THE TIMESCALE
// MAKE SURE YOUR SIMULATOR USE "PS" RESOLUTION
`timescale 1ns / 100ps

module mt58l1my18d (Dq, Addr, Mode, Adv_n, Clk, Adsc_n, Adsp_n, Bwa_n, Bwb_n, Bwe_n, Gw_n, Ce_n, Ce2, Ce2_n, Oe_n, Zz);

    parameter                       addr_bits =      20;        //  20 bits
    parameter                       data_bits =      18;        //  18 bits
    parameter                       mem_sizes = 1048575;        //   1 Mb
    parameter                       reg_delay =     0.1;        // 100 ps
    parameter                       out_delay =     0.1;        // 100 ps
    parameter                       tKQHZ     =     3.5;        //  -6 device

    inout     [(data_bits - 1) : 0] Dq;                         // Data IO
    input     [(addr_bits - 1) : 0] Addr;                       // Address
    input                           Mode;                       // Burst Mode
    input                           Adv_n;                      // Synchronous Address Advance
    input                           Clk;                        // Clock
    input                           Adsc_n;                     // Synchronous Address Status Controller
    input                           Adsp_n;                     // Synchronous Address Status Processor
    input                           Bwa_n;                      // Synchronous Byte Write Enables
    input                           Bwb_n;                      // Synchronous Byte Write Enables
    input                           Bwe_n;                      // Byte Write Enable
    input                           Gw_n;                       // Global Write
    input                           Ce_n;                       // Synchronous Chip Enable
    input                           Ce2;                        // Synchronous Chip Enable
    input                           Ce2_n;                      // Synchronous Chip Enable
    input                           Oe_n;                       // Output Enable
    input                           Zz;                         // Snooze Mode

    reg [((data_bits / 2) - 1) : 0] bank0 [0 : mem_sizes];      // Memory Bank 0
    reg [((data_bits / 2) - 1) : 0] bank1 [0 : mem_sizes];      // Memory Bank 1

    reg       [(data_bits - 1) : 0] din;                        // Input Registers
    reg       [(data_bits - 1) : 0] dout;                       // Output Registers
    reg       [(addr_bits - 1) : 0] addr_reg_in;                // Address Register In
    reg       [(addr_bits - 1) : 0] addr_reg_read;              // Address Register for Read Operation
    reg                     [1 : 0] bcount;                     // 2-bit Burst Counter

    reg                             ce_reg;
    reg                             pipe_reg;
    reg                             bwa_reg;
    reg                             bwb_reg;
    reg                             sys_clk;

    wire                            ce      = (~Ce_n & ~Ce2_n & Ce2);
    wire                            bwa_n   = (((Bwa_n | Bwe_n) & Gw_n) | (~Ce_n & ~Adsp_n));
    wire                            bwb_n   = (((Bwb_n | Bwe_n) & Gw_n) | (~Ce_n & ~Adsp_n));
    wire                            clr     = (~Adsc_n | (~Adsp_n & ~Ce_n));

    wire      [(addr_bits - 1) : 0] addr_reg_write;             // Address Register for Write Operation
    wire                            baddr1;                     // Burst Address 1
    wire                            baddr0;                     // Burst Address 0

    // Initialize
    initial begin
        ce_reg = 1'b0;
        sys_clk = 1'b0;
        pipe_reg = 1'b0;
        $timeformat (-9, 1, " ns", 10);                         // Format time unit
    end


task mem_fill;
input	x;

integer		a, n, x;

begin

a=0;
for(n=0;n<x;n=n+1)
   begin
	bank0[n] = a;
	bank1[n] = a+1;
	a=a+2;
   end

end
endtask

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
                 addr_reg_read <= {addr_reg_in [(addr_bits - 1) : 2], baddr1, baddr0};

        // Binary Counter and Logic
        if      ( Mode  &  clr) bcount <= 0;                    // Interleaved Burst
        else if (~Mode  &  clr) bcount <= Addr [1 : 0];         // Linear Burst
        else if (~Adv_n & ~clr) bcount <= (bcount + 1);         // Advance Counter

        // Byte Write Register    
        bwa_reg <= ~bwa_n;
        bwb_reg <= ~bwb_n;

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
        #reg_delay;
        if (ce_reg & bwa_reg) begin
            din [data_bits / 2 - 1 :  0] <= Dq [data_bits / 2 - 1 :  0];
            bank0 [addr_reg_write] <= Dq [data_bits / 2 - 1 :  0];
        end
        if (ce_reg & bwb_reg) begin
            din [data_bits - 1 : data_bits / 2] <= Dq [data_bits - 1 : data_bits / 2];
            bank1 [addr_reg_write] <= Dq [data_bits - 1 : data_bits / 2];
        end
    end

    // Output Registers
    always @ (posedge Clk) begin
        #out_delay;
        if (~(bwa_reg | bwb_reg)) begin
            dout [data_bits / 2 - 1 :  0] <= bank0 [addr_reg_read];
            dout [data_bits - 1 : data_bits / 2] <= bank1 [addr_reg_read];      
        end else begin
            dout [data_bits - 1 : 0] <= {data_bits{1'bz}};
        end
    end

    // Output Buffers
    assign #(tKQHZ) Dq = (~Oe_n & ~Zz & pipe_reg & ~(bwa_reg | bwb_reg)) ? dout : {data_bits{1'bz}};

    // Timing Check (6 ns clock cycle / 166 MHz)
    // Please download latest datasheet from our Web site:
    //      http://www.micron.com/mti
    specify
        specparam   tKC     =  6.0,     // Clock        - Clock cycle time
                    tKH     =  2.3,     //                Clock HIGH time
                    tKL     =  2.3,     //                Clock LOW time
                    tAS     =  1.5,     // Setup Times  - Address
                    tADSS   =  1.5,     //                Address Status
                    tAAS    =  1.5,     //                Address Advance
                    tWS     =  1.5,     //                Byte Write Enables
                    tDS     =  1.5,     //                Data-in
                    tCES    =  1.5,     //                Chip Enable
                    tAH     =  0.5,     // Hold Times   - Address                                  
                    tADSH   =  0.5,     //                Address Status
                    tAAH    =  0.5,     //                Address Advance
                    tWH     =  0.5,     //                Byte Write Enables
                    tDH     =  0.5,     //                Data-in                                  
                    tCEH    =  0.5;     //                Chip Enable

        $width      (negedge Clk, tKL);
        $width      (posedge Clk, tKH);
        $period     (negedge Clk, tKC);
        $period     (posedge Clk, tKC);
        $setuphold  (posedge Clk, Adsp_n, tADSS, tADSH);
        $setuphold  (posedge Clk, Adsc_n, tADSS, tADSH);
        $setuphold  (posedge Clk, Addr,   tAS,   tAH);
        $setuphold  (posedge Clk, Bwa_n,  tWS,   tWH);
        $setuphold  (posedge Clk, Bwb_n,  tWS,   tWH);
        $setuphold  (posedge Clk, Bwe_n,  tWS,   tWH);
        $setuphold  (posedge Clk, Gw_n,   tWS,   tWH);
        $setuphold  (posedge Clk, Ce_n,   tCES,  tCEH);
        $setuphold  (posedge Clk, Ce2,    tCES,  tCEH);
        $setuphold  (posedge Clk, Ce2_n,  tCES,  tCEH);
        $setuphold  (posedge Clk, Adv_n,  tAAS,  tAAH);
    endspecify                        

endmodule

