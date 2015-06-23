
//-----------------------------------------------------------------------------
//
// (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : V5-Block Plus for PCI Express
// File       : bram_common.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------


module bram_common #
(
   parameter NUM_BRAMS = 16,
   parameter ADDR_WIDTH = 13,
   parameter READ_LATENCY = 3,
   parameter WRITE_LATENCY = 1,
   parameter WRITE_PIPE = 0,
   parameter READ_ADDR_PIPE = 0,
   parameter READ_DATA_PIPE = 0, 
   parameter BRAM_OREG = 1 //parameter to enable use of output register on BRAM
) 

(
   input                         clka, // Port A Clk,  
   input                         ena,  // Port A enable
   input                         wena, // read/write enable
   input    [63:0]               dina, // Port A Write data 
   output   [63:0]               douta,// Port A Write data 
   input    [ADDR_WIDTH - 1:0]   addra,// Write Address for TL RX Buffers,
   input                         clkb, // Port B Clk,  
   input                         enb,  // Port B enable
   input                         wenb, // read/write enable
   input    [63:0]               dinb, // Port B Write data 
   output   [63:0]               doutb,// Port B Write data 
   input    [ADDR_WIDTH - 1:0]   addrb // Write Address for TL RX Buffers,
);

  
 
   // width of the BRAM: used bits
   localparam BRAM_WIDTH = 64/NUM_BRAMS; 
   // unused bits of the databus
   localparam UNUSED_DATA = 32 - BRAM_WIDTH;

   parameter UNUSED_ADDR = (BRAM_WIDTH == 64) ? 6: (BRAM_WIDTH == 32)
                                              ? 5: (BRAM_WIDTH == 16)
                                              ? 4: (BRAM_WIDTH == 8) 
                                              ? 3: (BRAM_WIDTH == 4) 
                                              ? 2: (BRAM_WIDTH == 2)
                                              ? 1:0;
 
    parameter BRAM_WIDTH_PARITY = (BRAM_WIDTH == 32) ? 36: (BRAM_WIDTH == 16)? 18: (BRAM_WIDTH == 8)? 9: BRAM_WIDTH; 
                           
   //used address bits. This will be used to determine the slice of the 
   //address bits from the upper level
   localparam USED_ADDR = 15 - UNUSED_ADDR;
   
   wire [31:0]ex_dat_a = 32'b0;
   wire [31:0]ex_dat_b = 32'b0;
   
    generate
    genvar i;
    if (NUM_BRAMS == 1)
        begin: generate_sdp
        // single BRAM implies Simple Dual Port and width of 64
        RAMB36SDP
        #(
            .DO_REG (BRAM_OREG)
        )  
        ram_sdp_inst 
        (
            .DI (dina),
            .WRADDR (addra[8:0]),
            .WE ({8{wena}}),
            .WREN (ena),
            .WRCLK (clka),
            .DO (doutb),
            .RDADDR (addrb[8:0]),
            .RDEN (enb),
            .REGCE (1'b1),
            .SSR (1'b0),
            .RDCLK (clkb),

            .DIP (8'h00),
            .DBITERR(),
            .SBITERR(),
            .DOP(),
            .ECCPARITY()   
        );
        end
    
    else  if (NUM_BRAMS ==2)
    for (i=0; i < NUM_BRAMS; i = i+1) 
            begin:generate_tdp2
            RAMB36
            #(
                .READ_WIDTH_A (BRAM_WIDTH_PARITY),
                .WRITE_WIDTH_A (BRAM_WIDTH_PARITY),
                .READ_WIDTH_B (BRAM_WIDTH_PARITY),
                .WRITE_WIDTH_B (BRAM_WIDTH_PARITY),
                .WRITE_MODE_A("READ_FIRST"),
                .WRITE_MODE_B("READ_FIRST"),
                .DOB_REG (BRAM_OREG)
            )  
            ram_tdp2_inst
            (
                .DOA       (douta[(i+1)*BRAM_WIDTH-1: i*BRAM_WIDTH]),
                .DIA       (dina[(i+1)*BRAM_WIDTH-1: i*BRAM_WIDTH]),
                .ADDRA     ({ 1'b0, addra[USED_ADDR - 1:0], {UNUSED_ADDR{1'b0}} }),
                .WEA       ({4{wena}}),
                .ENA       (ena),
                .CLKA      (clka),
                .DOB       (doutb[(i+1)*BRAM_WIDTH-1: i*BRAM_WIDTH]),
                .DIB       (dinb [(i+1)*BRAM_WIDTH-1: i*BRAM_WIDTH]),
                .ADDRB     ({ 1'b0, addrb[USED_ADDR - 1:0], {UNUSED_ADDR{1'b0}} }),
                .WEB       (4'b0),
                .ENB       (enb),
                .REGCEB    (1'b1),
                .REGCEA    (1'b1),
        //        .REGCLKB   (clkb),
                .SSRA      (1'b0),
                .SSRB      (1'b0),
                .CLKB      (clkb)
            ); 
            end
    else    
    for (i=0; i < NUM_BRAMS; i = i+1) 
        begin:generate_tdp
        RAMB36
        #(
            .READ_WIDTH_A (BRAM_WIDTH_PARITY),
            .WRITE_WIDTH_A (BRAM_WIDTH_PARITY),
            .READ_WIDTH_B (BRAM_WIDTH_PARITY),
            .WRITE_WIDTH_B (BRAM_WIDTH_PARITY),
            .WRITE_MODE_A("READ_FIRST"),
            .WRITE_MODE_B("READ_FIRST"),
            .DOB_REG (BRAM_OREG)
        )  
        ram_tdp_inst
        (
            .DOA       ({ ex_dat_a[UNUSED_DATA-1:0], douta[(i+1)*BRAM_WIDTH-1: i*BRAM_WIDTH] }),
            .DIA       ({ {UNUSED_DATA{1'b0}} ,dina[(i+1)*BRAM_WIDTH-1: i*BRAM_WIDTH] }),
            .ADDRA     ({ 1'b0, addra[USED_ADDR - 1:0], {UNUSED_ADDR{1'b0}} }),
            .WEA       ({4{wena}}),
            .ENA       (ena),
            .CLKA      (clka),
            .DOB       ({ ex_dat_b[UNUSED_DATA-1:0], doutb[(i+1)*BRAM_WIDTH-1: i*BRAM_WIDTH] }),
            .DIB       ({ {UNUSED_DATA{1'b0}}, dinb [(i+1)*BRAM_WIDTH-1: i*BRAM_WIDTH] }),
            .ADDRB     ({ 1'b0, addrb[USED_ADDR - 1:0], {UNUSED_ADDR{1'b0}} }),
            .WEB       (4'b0),
            .ENB       (enb),
            .REGCEB    (1'b1),
            .REGCEA    (1'b1),
           // .REGCLKB   (clkb),
            .SSRA      (1'b0),
            .SSRB      (1'b0),
            .CLKB      (clkb)
        ); 
        end
   endgenerate


endmodule
