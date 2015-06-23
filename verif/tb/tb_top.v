//////////////////////////////////////////////////////////////////////
////                                                              ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////


`timescale  1ns/1ps

`include "tb_defines.v"

module tb_top;


reg    reset_n;
reg    reset;
reg    xtal_clk;
reg    ref_clk_125;
wire   app_clk;
reg    ref_clk_50;
reg    uart_clk_16x;


parameter XTAL_CLK_PERIOD = 10; // 100MHZ 40; // 25Mhz
parameter APP_CLK_PERIOD = 10;
parameter REF_CLK_125_PERIOD = 8;
parameter REF_CLK_50_PERIOD = 20;
parameter UART_REF_CLK_PERIOD = 20;

reg[31:0] events_log;

initial
begin
        reset_n = 1;
   #100 reset_n = 0;
   #100 reset_n = 1;
end


initial begin
  xtal_clk = 1'b0;
  forever #(XTAL_CLK_PERIOD/2.0) xtal_clk = ~xtal_clk;
end


//initial begin
//  app_clk = 1'b0;
//  forever #(APP_CLK_PERIOD/2.0) app_clk = ~app_clk;
//end

initial begin
  ref_clk_125 = 1'b0;
  forever #(REF_CLK_125_PERIOD/2.0) ref_clk_125 = ~ref_clk_125;
end

initial begin
  ref_clk_50 = 1'b0;
  forever #(REF_CLK_50_PERIOD/2.0) ref_clk_50 = ~ref_clk_50;
end


initial begin
  uart_clk_16x = 1'b0;
  forever #(UART_REF_CLK_PERIOD/2.0) uart_clk_16x = ~uart_clk_16x;
end


wire [3:0]   phy_txd            ;
wire [3:0]   phy_rxd            ;

//---------------------------------
// Reg Bus Interface Signal
//---------------------------------
reg                reg_cs     ;
reg [3:0]          reg_id     ;
reg                reg_wr         ;
reg  [14:0]        reg_addr       ;
reg  [31:0]        reg_wdata      ;
reg  [3:0]         reg_be         ;

// Outputs
wire  [31:0]        reg_rdata      ;
wire                reg_ack        ;

reg                 master_mode   ;
reg                 ea_in   ;   // 1--> Internal Memory


wire         spi_sck            ;
wire         spi_so             ;
wire         spi_si             ;
wire [3:0]   spi_cs_n           ;

wire         clkout             ;
wire         reset_out_n        ;

//----------------------------------------
// 8051 core ROM related signals
//---------------------------------------
wire  [15:0]   wb_xrom_adr       ; // instruction address
wire           wb_xrom_ack       ; // instruction acknowlage
wire           wb_xrom_err       ; // instruction error
wire           wb_xrom_wr        ; // instruction error
wire    [31:0] wb_xrom_rdata     ; // rom data input
wire   [31:0]  wb_xrom_wdata     ; // rom data input

wire           wb_xrom_stb       ; // instruction strobe
wire           wb_xrom_cyc       ; // instruction cycle


//----------------------------------------
// 8051 core RAM related signals
//---------------------------------------
wire   [15:0] wb_xram_adr        ; // data-ram address
wire          wb_xram_ack        ; // data-ram acknowlage
wire          wb_xram_err        ; // data-ram error
wire          wb_xram_wr         ; // data-ram error
wire   [3:0]  wb_xram_be         ; // data-ram error
wire   [31:0] wb_xram_rdata      ; // ram data input
wire   [31:0] wb_xram_wdata      ; // ram data input

wire          wb_xram_stb        ; // data-ram strobe
wire          wb_xram_cyc        ; // data-ram cycle

//----------------------------------------

turbo8051  u_core (

             . reset_n             (reset_n            ),
             . fastsim_mode        (1'b1               ),
             . mastermode          (master_mode        ),

             . xtal_clk            (xtal_clk           ),
             . clkout              (app_clk            ),
             . reset_out_n         (reset_out_n        ),

        // Reg Bus Interface Signal
             . ext_reg_cs          (reg_cs             ),
             . ext_reg_tid         (reg_id             ),
             . ext_reg_wr          (reg_wr             ),
             . ext_reg_addr        (reg_addr[14:0]     ),
             . ext_reg_wdata       (reg_wdata          ),
             . ext_reg_be          (reg_be             ),

            // Outputs
             . ext_reg_rdata       (reg_rdata          ),
             . ext_reg_ack         (reg_ack            ),


          // Line Side Interface TX Path
             .phy_tx_en            (phy_tx_en          ),
             .phy_txd              (phy_txd            ),
             .phy_tx_clk           (phy_tx_clk         ),

          // Line Side Interface RX Path
             .phy_rx_clk           (phy_rx_clk         ),
             .phy_rx_dv            (phy_rx_dv          ),
             .phy_rxd              (phy_rxd            ),

          //MDIO interface
             .MDC                  (MDC                ),
             .MDIO                 (MDIO               ),


       // UART Line Interface
             .si                   (si                 ),
             .so                   (so                 ),


             .spi_sck              (spi_sck            ),
             .spi_so               (spi_so             ),
             .spi_si               (spi_si             ),
             .spi_cs_n             (spi_cs_n           ),

         // External ROM interface
               .wb_xrom_adr        (wb_xrom_adr        ),
               .wb_xrom_ack        (wb_xrom_ack        ),
               .wb_xrom_err        (wb_xrom_err        ),
               .wb_xrom_wr         (wb_xrom_wr         ),
               .wb_xrom_rdata      (wb_xrom_rdata      ),
               .wb_xrom_wdata      (wb_xrom_wdata      ),
             
               .wb_xrom_stb        (wb_xrom_stb        ),
               .wb_xrom_cyc        (wb_xrom_cyc        ),

         // External RAM interface
               .wb_xram_adr        (wb_xram_adr        ),
               .wb_xram_ack        (wb_xram_ack        ),
               .wb_xram_err        (wb_xram_err        ),
               .wb_xram_wr         (wb_xram_wr         ),
               .wb_xram_be         (wb_xram_be         ),
               .wb_xram_rdata      (wb_xram_rdata      ),
               .wb_xram_wdata      (wb_xram_wdata      ),
             
               .wb_xram_stb        (wb_xram_stb        ),
               .wb_xram_cyc        (wb_xram_cyc        ),

               .ea_in              (ea_in               ) // internal ROM

        );


  oc8051_xrom oc8051_xrom1
      (
             .rst                ( !reset_n         ), 
             .clk                ( app_clk          ), 
             .addr               ( wb_xrom_adr      ), 
             .data               ( wb_xrom_rdata    ),
             .stb_i              ( wb_xrom_stb      ), 
             .cyc_i              ( wb_xrom_cyc      ), 
             .ack_o              ( wb_xrom_ack      )
      );

   defparam oc8051_xrom1.DELAY = 0;


//
// external data ram
//
oc8051_xram oc8051_xram1 (
          .clk               (app_clk       ), 
          .rst               (!reset_n      ), 
          .wr                (wb_xram_wr    ), 
          .be                (wb_xram_be    ), 
          .addr              (wb_xram_adr   ), 
          .data_in           (wb_xram_wdata ), 
          .data_out          (wb_xram_rdata ), 
          .ack               (wb_xram_ack   ), 
          .stb               (wb_xram_stb   )
      );


defparam oc8051_xram1.DELAY = 2;




tb_eth_top u_tb_eth (

               . REFCLK_50_MHz     (ref_clk_50         ), // 50 MHz Reference clock input
               . REFCLK_125_MHz    (ref_clk_125        ), // 125 MHz reference clock
               . transmit_enable   (1'b1               ), // transmit enable for testbench
              
          // Separate interfaces for each MII port type

          // Full MII, 4-bit interface
          // Transmit interface
               . MII_RXD           (phy_rxd[3:0]       ), // Receive data (output)
               . MII_RX_CLK        (phy_rx_clk         ), // Receive clock for MII (output)
               . MII_CRS           (phy_crs            ), // carrier sense (output)
               . MII_COL           (                   ), // Collision signal for MII (output)
               . MII_RX_DV         (phy_rx_dv          ), // Receive data valid for MII (output)

          // Receive interface
               . MII_TXD           (phy_txd[3:0]       ), // Transmit data (input)
               . MII_TX_EN         (phy_tx_en          ), // Tx enable (input)
               . MII_TX_CLK        (phy_tx_clk         ), // Transmit clock (output)

          // Reduced MII, 2-bit interface
          // Transmit interface
               . RMII_RXD          (                   ), // Receive data (output)
               . RMII_CRS_DV       (                   ), // carrier sense (output)
          // Receive interface
               . RMII_TXD          (                   ), // Transmit data (input)
               . RMII_TX_EN        (                   ), // Tx enable (input)

          // Serial MII interface
               . SMII_RXD          (                   ), // Receive data (output)
               . SMII_TXD          (                   ), // Transmit data (input)
               . SMII_SYNC         (                   ), // SMII SYNC signal (input)                
                     
          // GMII, 8-bit/10-bit interface
          // Transmit interface
               . GMII_RXD          (                   ), // Receive data (output)
               . GMII_RX_CLK       (                   ), // Receive clock for MII (output)
               . GMII_CRS          (                   ), // carrier sense (output)
               . GMII_COL          (                   ), // Collision signal for MII (output)
               . GMII_RX_DV        (                   ), // Receive data valid for MII (output)

          // Receive interface
               . GMII_TXD          (                   ), // Transmit data (input)
               . GMII_TX_EN        (                   ), // Tx enable (input)
               . GMII_TX_CLK       (                   ), // Transmit clock (output)
               . GMII_GTX_CLK      (                   ), // Gigabit Tx clock (input), 125 MHz

              // MII management interface
               .MDIO               (MDC                ), // serial I/O data
               .MDC                (MDC                )  // clock




      );

 uart_agent tb_uart (
               . test_clk          (uart_clk_16x       ),
               . sin               (si                 ),
               . dsr_n             (                   ),
               . cts_n             (                   ),
               . dcd_n             (                   ),

               . sout              (so                 ),
               . dtr_n             (1'b0               ),
               . rts_n             (1'b0               ),
               . out1_n            (1'b0               ),
               . out2_n            (1'b0               )
       );


//----------------------- SPI Agents

m25p20 i_m25p20_0 ( 
               .c                  (spi_sck            ),
               .s                  (spi_cs_n[0]        ), // Include selection logic
               .w                  (1'b1               ), // Write protect is always disabled
               .hold               (1'b1               ), // Hold support not used
               .data_in            (spi_so             ),
               .data_out           (spi_si             )
             );


AT45DB321 i_AT45DB321_0 ( 
               .CSB                (spi_cs_n[1]        ),
               .SCK                (spi_sck            ),
               .SI                 (spi_so             ),
               .WPB                (1'b1               ),
               .RESETB             (1'b1               ),
               .RDY_BUSYB          (                   ),
               .SO                 (spi_si             )
      );
/***************
spi_agent_3120 spi_agent_3120_0 ( 
               .cs_b               (spi_cs_n[2]        ),
               .spi_din            (spi_si             ),
               .spi_dout           (spi_so             ),
               .spi_clk            (spi_sck            )
       );

spi_agent_3120 spi_agent_3120_1 ( 
               .cs_b               (spi_cs_n[3]        ),
               .spi_din            (spi_si             ),
               .spi_dout           (spi_so             ),
               .spi_clk            (spi_sck            )
       );
*****************/

tb_glbl  tb_glbl ();


`ifdef DUMP_ENABLE
initial begin
   if ( $test$plusargs("DUMP") ) begin
          $fsdbDumpfile("../dump/test_1.fsdb");
      $fsdbDumpvars;
      $fsdbDumpon;
   end
end
`endif

initial begin

   if ( $test$plusargs("INTERNAL_ROM") )  begin
      ea_in       = 1;
      master_mode = 1;
   end else if ( $test$plusargs("EXTERNAL_ROM") ) begin
      ea_in       = 0;
      master_mode = 1;
   end else begin
      ea_in       = 0;
      master_mode = 0;
   end

  `TB_GLBL.init;

   // test case, which has control before reset
   if ( $test$plusargs("gmac_test_2") ) 
       gmac_test2();
   else if ( $test$plusargs("webserver") ) 
       webserver();

   #1000 wait(reset_out_n == 1);

   // test case, which has control after reset
   if ( $test$plusargs("gmac_test_1") ) 
       gmac_test1();
   else if ( $test$plusargs("uart_test_1") ) 
       uart_test1();
   else if ( $test$plusargs("spi_test_1") ) 
       spi_test1();
   else if ( !$test$plusargs("gmac_test_2") && 
	     !$test$plusargs("webserver")) begin
     // 8051 Test Cases
     #80000000
     $display("time ",$time, "\n faulire: end of time\n \n");
   end

   `TB_GLBL.test_stats;
   `TB_GLBL.test_finish;
   #1000 $finish;
end

wire [7:0] p2_out = u_core.u_8051_core.p2_o;
wire [7:0] p3_out = u_core.u_8051_core.p3_o;
always @(p2_out or p3_out)
begin
  if((p2_out == 8'haa) &&      // fib.c
     (p3_out == 8'haa )) begin
      $display("################################");
      $display("time ",$time, " Passed");
      $display("################################");
      #100
      $finish;
  end else if(p2_out == 8'h55) begin     // fib.c
      $display("");
      $display("time ",$time," Error: %h", p3_out);
      $display("");
      #100
      $finish;
  end
end




`include "gmac_test1.v"
`include "gmac_test2.v"
`include "webserver.v"
`include "uart_test1.v"
`include "spi_test1.v"
`include "tb_tasks.v"
`include "spi_tasks.v"


endmodule
`include "tb_glbl.v"
