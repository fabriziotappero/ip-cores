//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores UART Interface Module                       ////
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
module uart_core 

     (  
        line_reset_n ,
        line_clk_16x ,

        app_reset_n ,
        app_clk ,

        // Reg Bus Interface Signal
        reg_cs,
        reg_wr,
        reg_addr,
        reg_wdata,
        reg_be,

        // Outputs
        reg_rdata,
        reg_ack,

       // Line Interface
        si,
        so

     );




parameter W  = 8'd8;
parameter DP = 8'd16;
parameter AW = (DP == 2)   ? 1 : 
	       (DP == 4)   ? 2 :
               (DP == 8)   ? 3 :
               (DP == 16)  ? 4 :
               (DP == 32)  ? 5 :
               (DP == 64)  ? 6 :
               (DP == 128) ? 7 :
               (DP == 256) ? 8 : 0;



input        line_reset_n         ; // line reset
input        line_clk_16x         ; // line clock

input        app_reset_n          ; // application reset
input        app_clk              ; // application clock

//---------------------------------
// Reg Bus Interface Signal
//---------------------------------
input             reg_cs         ;
input             reg_wr         ;
input [3:0]       reg_addr       ;
input [31:0]      reg_wdata      ;
input [3:0]       reg_be         ;

// Outputs
output [31:0]     reg_rdata      ;
output            reg_ack     ;

// Line Interface
input         si                  ; // uart si
output        so                  ; // uart so

// Wire Declaration

wire [W-1: 0]   tx_fifo_rd_data;
wire [W-1: 0]   rx_fifo_wr_data;
wire [W-1: 0]   app_rxfifo_rddata;
wire [1  : 0]   error_ind;

// Wire 
wire         cfg_tx_enable        ; // Tx Enable
wire         cfg_rx_enable        ; // Rx Enable
wire         cfg_stop_bit         ; // 0 -> 1 Stop, 1 -> 2 Stop
wire   [1:0] cfg_pri_mod          ; // priority mode, 0 -> nop, 1 -> Even, 2 -> Odd

wire        frm_error_o          ; // framing error
wire        par_error_o          ; // par error
wire        rx_fifo_full_err_o   ; // rx fifo full error
wire        rx_fifo_wr_full      ;
wire        app_rxfifo_empty     ;


uart_cfg u_cfg (

             . mclk          (app_clk),
             . reset_n       (app_reset_n),

        // Reg Bus Interface Signal
             . reg_cs        (reg_cs),
             . reg_wr        (reg_wr),
             . reg_addr      (reg_addr),
             . reg_wdata     (reg_wdata),
             . reg_be        (reg_be),

            // Outputs
            . reg_rdata      (reg_rdata),
            . reg_ack        (reg_ack),


       // configuration
            . cfg_tx_enable       (cfg_tx_enable),
            . cfg_rx_enable       (cfg_rx_enable),
            . cfg_stop_bit        (cfg_stop_bit),
            . cfg_pri_mod         (cfg_pri_mod),

            . frm_error_o         (frm_error_o),
            . par_error_o         (par_error_o),
            . rx_fifo_full_err_o  (rx_fifo_full_err_o)

        );





uart_txfsm u_txfsm (
               . reset_n           ( line_reset_n      ),
               . baud_clk_16x      ( line_clk_16x      ),

               . cfg_tx_enable     ( cfg_tx_enable     ),
               . cfg_stop_bit      ( cfg_stop_bit      ),
               . cfg_pri_mod       ( cfg_pri_mod       ),

       // FIFO control signal
               . fifo_empty        ( tx_fifo_rd_empty  ),
               . fifo_rd           ( tx_fifo_rd        ),
               . fifo_data         ( tx_fifo_rd_data   ),

          // Line Interface
               . so                ( so                )
          );


uart_rxfsm u_rxfsm (
               . reset_n           (  line_reset_n     ),
               . baud_clk_16x      (  line_clk_16x     ) ,

               . cfg_rx_enable     (  cfg_rx_enable    ),
               . cfg_stop_bit      (  cfg_stop_bit     ),
               . cfg_pri_mod       (  cfg_pri_mod      ),

               . error_ind         (  error_ind        ),

       // FIFO control signal
               .  fifo_aval        ( !rx_fifo_wr_full  ),
               .  fifo_wr          ( rx_fifo_wr        ),
               .  fifo_data        ( rx_fifo_wr_data   ),

          // Line Interface
               .  si               (si_ss              )
          );

async_fifo #(W,DP,0,0) u_rxfifo (                  
               .wr_clk             (line_clk_16x       ),
               .wr_reset_n         (line_reset_n       ),
               .wr_en              (rx_fifo_wr         ),
               .wr_data            (rx_fifo_wr_data    ),
               .full               (rx_fifo_wr_full    ), // sync'ed to wr_clk
               .wr_total_free_space(                   ),

               .rd_clk             (app_clk            ),
               .rd_reset_n         (app_reset_n        ),
               .rd_en              (!app_rxfifo_empty  ),
               .empty              (app_rxfifo_empty   ),  // sync'ed to rd_clk
               .rd_total_aval      (                   ),
               .rd_data            (app_rxfifo_rddata  )
                   );

async_fifo #(W,DP,0,0) u_txfifo  (
               .wr_clk             (app_clk            ),
               .wr_reset_n         (app_reset_n        ),
               .wr_en              (!app_rxfifo_empty  ),
               .wr_data            (app_rxfifo_rddata  ),
               .full               (                   ), // sync'ed to wr_clk
               .wr_total_free_space(                   ),

               .rd_clk             (line_clk_16x       ),
               .rd_reset_n         (line_reset_n       ),
               .rd_en              (tx_fifo_rd         ),
               .empty              (tx_fifo_rd_empty   ),  // sync'ed to rd_clk
               .rd_total_aval      (                   ),
               .rd_data            (tx_fifo_rd_data    )
                   );


double_sync_low   u_si_sync (
               . in_data           ( si                ),
               . out_clk           (line_clk_16x       ),
               . out_rst_n         (line_reset_n       ),
               . out_data          (si_ss              ) 
          );

wire   frm_error          = (error_ind == 2'b01);
wire   par_error          = (error_ind == 2'b10);
wire   rx_fifo_full_err   = (error_ind == 2'b11);

double_sync_low   u_frm_err (
               . in_data           ( frm_error        ),
               . out_clk           ( app_clk          ),
               . out_rst_n         ( app_reset_n      ),
               . out_data          ( frm_error_o      ) 
          );

double_sync_low   u_par_err (
               . in_data           ( par_error        ),
               . out_clk           ( app_clk          ),
               . out_rst_n         ( app_reset_n      ),
               . out_data          ( par_error_o      ) 
          );

double_sync_low   u_rxfifo_err (
               . in_data           ( rx_fifo_full_err ),
               . out_clk           ( app_clk          ),
               . out_rst_n         ( app_reset_n      ),
               . out_data          ( rx_fifo_full_err_o  ) 
          );


endmodule
