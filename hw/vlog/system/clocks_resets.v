//////////////////////////////////////////////////////////////////
//                                                              //
//  Clock and Resets                                            //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Takes in the 200MHx board clock and generates the main      //
//  system clock. For the FPGA this is done with a PLL.         //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////
`include "system_config_defines.vh"
`include "global_timescale.vh"


//
// Clocks and Resets Module
//

module clocks_resets  (
input                       i_brd_rst,
input                       i_brd_clk_n,  
input                       i_brd_clk_p,  
input                       i_ddr_calib_done,
output                      o_sys_rst,
output                      o_sys_clk,
output                      o_clk_200

);


wire                        calib_done_33mhz;
wire                        rst0;

assign o_sys_rst = rst0 || !calib_done_33mhz;



`ifdef XILINX_FPGA

    localparam                  RST_SYNC_NUM = 25;
    wire                        pll_locked;
    wire                        clkfbout_clkfbin;
    reg [RST_SYNC_NUM-1:0]      rst0_sync_r    /* synthesis syn_maxfan = 10 */;
    reg [RST_SYNC_NUM-1:0]      ddr_calib_done_sync_r    /* synthesis syn_maxfan = 10 */;
    wire                        rst_tmp;
    wire                        pll_clk;

    (* KEEP = "TRUE" *)  wire brd_clk_ibufg;


    IBUFGDS # (  
         .DIFF_TERM  ( "TRUE"     ), 
         .IOSTANDARD ( "LVDS_25"  ))  // SP605 on chip termination of LVDS clock
         u_ibufgds_brd
        (
         .I  ( i_brd_clk_p    ),
         .IB ( i_brd_clk_n    ),
         .O  ( brd_clk_ibufg  )
         );
         
         
    assign rst0             = rst0_sync_r[RST_SYNC_NUM-1];
    assign calib_done_33mhz = ddr_calib_done_sync_r[RST_SYNC_NUM-1];
    assign o_clk_200        = brd_clk_ibufg;


    `ifdef XILINX_SPARTAN6_FPGA
    // ======================================
    // Xilinx Spartan-6 PLL
    // ======================================
        PLL_ADV #
            (
             .BANDWIDTH          ( "OPTIMIZED"        ),
             .CLKIN1_PERIOD      ( 5                  ),
             .CLKIN2_PERIOD      ( 1                  ),
             .CLKOUT0_DIVIDE     ( 1                  ), 
             .CLKOUT1_DIVIDE     (                    ),
             .CLKOUT2_DIVIDE     ( `AMBER_CLK_DIVIDER ),   // = 800 MHz / LP_CLK_DIVIDER
             .CLKOUT3_DIVIDE     ( 1                  ),
             .CLKOUT4_DIVIDE     ( 1                  ),
             .CLKOUT5_DIVIDE     ( 1                  ),
             .CLKOUT0_PHASE      ( 0.000              ),
             .CLKOUT1_PHASE      ( 0.000              ),
             .CLKOUT2_PHASE      ( 0.000              ),
             .CLKOUT3_PHASE      ( 0.000              ),
             .CLKOUT4_PHASE      ( 0.000              ),
             .CLKOUT5_PHASE      ( 0.000              ),
             .CLKOUT0_DUTY_CYCLE ( 0.500              ),
             .CLKOUT1_DUTY_CYCLE ( 0.500              ),
             .CLKOUT2_DUTY_CYCLE ( 0.500              ),
             .CLKOUT3_DUTY_CYCLE ( 0.500              ),
             .CLKOUT4_DUTY_CYCLE ( 0.500              ),
             .CLKOUT5_DUTY_CYCLE ( 0.500              ),
             .COMPENSATION       ( "INTERNAL"         ),
             .DIVCLK_DIVIDE      ( 1                  ),
             .CLKFBOUT_MULT      ( 4                  ),   // 200 MHz clock input, x4 to get 800 MHz MCB
             .CLKFBOUT_PHASE     ( 0.0                ),
             .REF_JITTER         ( 0.005000           )
             )
            u_pll_adv
              (
               .CLKFBIN     ( clkfbout_clkfbin  ),
               .CLKINSEL    ( 1'b1              ),
               .CLKIN1      ( brd_clk_ibufg     ),
               .CLKIN2      ( 1'b0              ),
               .DADDR       ( 5'b0              ),
               .DCLK        ( 1'b0              ),
               .DEN         ( 1'b0              ),
               .DI          ( 16'b0             ),           
               .DWE         ( 1'b0              ),
               .REL         ( 1'b0              ),
               .RST         ( i_brd_rst          ),
               .CLKFBDCM    (                   ),
               .CLKFBOUT    ( clkfbout_clkfbin  ),
               .CLKOUTDCM0  (                   ),
               .CLKOUTDCM1  (                   ),
               .CLKOUTDCM2  (                   ),
               .CLKOUTDCM3  (                   ),
               .CLKOUTDCM4  (                   ),
               .CLKOUTDCM5  (                   ),
               .CLKOUT0     (                   ),
               .CLKOUT1     (                   ),
               .CLKOUT2     ( pll_clk           ),
               .CLKOUT3     (                   ),
               .CLKOUT4     (                   ),
               .CLKOUT5     (                   ),
               .DO          (                   ),
               .DRDY        (                   ),
               .LOCKED      ( pll_locked        )
               );
    `endif


    `ifdef XILINX_VIRTEX6_FPGA
    // ======================================
    // Xilinx Virtex-6 PLL
    // ======================================
        MMCM_ADV #
        (
         .CLKIN1_PERIOD      ( 5                    ),   // 200 MHz
         .CLKOUT2_DIVIDE     ( `AMBER_CLK_DIVIDER   ),
         .CLKFBOUT_MULT_F    ( 6                    )    // 200 MHz x 6 = 1200 MHz
         )
        u_pll_adv
          (
           .CLKFBOUT     ( clkfbout_clkfbin ),
           .CLKFBOUTB    (                  ),
           .CLKFBSTOPPED (                  ),
           .CLKINSTOPPED (                  ),
           .CLKOUT0      (                  ),
           .CLKOUT0B     (                  ),
           .CLKOUT1      (                  ),
           .CLKOUT1B     (                  ),
           .CLKOUT2      ( pll_clk          ),
           .CLKOUT2B     (                  ),
           .CLKOUT3      (                  ),
           .CLKOUT3B     (                  ),
           .CLKOUT4      (                  ),
           .CLKOUT5      (                  ),
           .CLKOUT6      (                  ),
           .DRDY         (                  ),
           .LOCKED       ( pll_locked       ),
           .PSDONE       (                  ),
           .DO           (                  ),
           .CLKFBIN      ( clkfbout_clkfbin ),
           .CLKIN1       ( brd_clk_ibufg    ),
           .CLKIN2       ( 1'b0             ),
           .CLKINSEL     ( 1'b1             ),
           .DCLK         ( 1'b0             ),
           .DEN          ( 1'b0             ),
           .DWE          ( 1'b0             ),
           .PSCLK        ( 1'd0             ),
           .PSEN         ( 1'd0             ),
           .PSINCDEC     ( 1'd0             ),
           .PWRDWN       ( 1'd0             ),
           .RST          ( i_brd_rst         ),
           .DI           ( 16'b0            ),
           .DADDR        ( 7'b0             ) 
           );
    `endif


    BUFG u_bufg_sys_clk (
         .O ( o_sys_clk  ),
         .I ( pll_clk    )
         );


    // ======================================
    // Synchronous reset generation
    // ======================================
    assign rst_tmp = i_brd_rst | ~pll_locked;

      // synthesis attribute max_fanout of rst0_sync_r is 10
    always @(posedge o_sys_clk or posedge rst_tmp)
        if (rst_tmp)
          rst0_sync_r <= {RST_SYNC_NUM{1'b1}};
        else
          // logical left shift by one (pads with 0)
          rst0_sync_r <= rst0_sync_r << 1;

    always @(posedge o_sys_clk or posedge rst_tmp)
        if (rst_tmp)
            ddr_calib_done_sync_r <= {RST_SYNC_NUM{1'b0}};
        else
            ddr_calib_done_sync_r <= {ddr_calib_done_sync_r[RST_SYNC_NUM-2:0], i_ddr_calib_done};

    `endif



`ifndef XILINX_FPGA

real      brd_clk_period = 6000;  // use starting value of 6000pS
real      pll_clk_period = 1000;  // use starting value of 1000pS
real      brd_temp;
reg       pll_clk_beh;
reg       sys_clk_beh;
integer   pll_div_count = 0;

// measure input clock period
initial
    begin
    @ (posedge i_brd_clk_p)
    brd_temp = $time;
    @ (posedge i_brd_clk_p)
    brd_clk_period = $time - brd_temp;
    pll_clk_period = brd_clk_period / 4;
    end
    
// Generate an 800MHz pll clock based off the input clock
always @( posedge i_brd_clk_p )
    begin
    pll_clk_beh = 1'd1;
    # ( pll_clk_period / 2 )
    pll_clk_beh = 1'd0;
    # ( pll_clk_period / 2 )

    pll_clk_beh = 1'd1;
    # ( pll_clk_period / 2 )
    pll_clk_beh = 1'd0;
    # ( pll_clk_period / 2 )

    pll_clk_beh = 1'd1;
    # ( pll_clk_period / 2 )
    pll_clk_beh = 1'd0;
    # ( pll_clk_period / 2 )

    pll_clk_beh = 1'd1;
    # ( pll_clk_period / 2 )
    pll_clk_beh = 1'd0;

    end

// Divide the pll clock down to get the system clock
always @( pll_clk_beh )
    begin
    if ( pll_div_count == (
        `AMBER_CLK_DIVIDER 
        * 2 ) - 1 )
        pll_div_count <= 'd0;
    else    
        pll_div_count <= pll_div_count + 1'd1;
        
    if ( pll_div_count == 0 )
        sys_clk_beh = 1'd1;
    else if ( pll_div_count == 
        `AMBER_CLK_DIVIDER 
        )
        sys_clk_beh = 1'd0;
    end

assign o_sys_clk        = sys_clk_beh;
assign rst0             = i_brd_rst;
assign calib_done_33mhz = 1'd1;
assign o_clk_200        = i_brd_clk_p;

`endif


endmodule


