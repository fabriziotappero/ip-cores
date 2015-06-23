//////////////////////////////////////////////////////////////////////
////                                                              ////
////  spi_top.v                                                   ////
////                                                              ////
////  This file is part of the SPI IP core project                ////
////  http://www.opencores.org/projects/spi/                      ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Srot (simons@opencores.org)                     ////
////                                                              ////
////  All additional information is avaliable in the Readme.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2002 Authors                                   ////
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


`include "spi_defines.v"
`include "timescale.v"

module spi_flash_top
  (
   // Wishbone signals
   wb_clk_i, wb_rst_i, wb_adr_i, wb_dat_i, wb_dat_o, wb_sel_i,
   wb_we_i, wb_stb_i, wb_cyc_i, wb_ack_o, 
   // SPI signals
   ss_pad_o, sclk_pad_o, mosi_pad_o, miso_pad_i
   );
   
   parameter divider_len = 2;
   parameter divider = 0;
   
   parameter Tp = 1;
   
   // Wishbone signals
   input                            wb_clk_i;         // master clock input
   input                            wb_rst_i;         // synchronous active high reset
   input [4:2] 			    wb_adr_i;         // lower address bits
   input [31:0] 		    wb_dat_i;         // databus input
   output [31:0] 		    wb_dat_o;         // databus output
   input [3:0] 			    wb_sel_i;         // byte select inputs
   input                            wb_we_i;          // write enable input
   input                            wb_stb_i;         // stobe/core select signal
   input                            wb_cyc_i;         // valid bus cycle input
   output                           wb_ack_o;         // bus cycle acknowledge output
   
   // SPI signals                                     
   output [`SPI_SS_NB-1:0] 	    ss_pad_o;         // slave select
   output                           sclk_pad_o;       // serial clock
   output                           mosi_pad_o;       // master out slave in
   input                            miso_pad_i;       // master in slave out
   
   reg [31:0] 			    wb_dat_o;
   reg                              wb_ack_o;
   
   // Internal signals
   //  reg       [`SPI_DIVIDER_LEN-1:0] divider;          // Divider register
   wire [`SPI_CTRL_BIT_NB-1:0] 	    ctrl;             // Control and status register
   reg [`SPI_SS_NB-1:0] 	    ss;               // Slave select register
   wire [`SPI_MAX_CHAR-1:0] 	    rx;               // Rx register

   wire [5:0] 			    char_len;
   reg 				    char_len_ctrl;    // char len
   reg 				    go;               // go
   
   wire 			    spi_ctrl_sel;     // ctrl register select
   wire 			    spi_tx_sel;       // tx_l register select
   wire 			    spi_ss_sel;       // ss register select
   wire                             tip;              // transfer in progress
   wire                             pos_edge;         // recognize posedge of sclk
   wire                             neg_edge;         // recognize negedge of sclk
   wire                             last_bit;         // marks last character bit

  wire                             rx_negedge;       // miso is sampled on negative edge
  wire                             tx_negedge;       // mosi is driven on negative edge
  wire                             lsb;              // lsb first on line
  wire                             ass;              // automatic slave select
   
   // Address decoder
   assign spi_ctrl_sel    = wb_cyc_i & wb_stb_i & (wb_adr_i[`SPI_OFS_BITS] == `SPI_CTRL);
   assign spi_tx_sel      = wb_cyc_i & wb_stb_i & (wb_adr_i[`SPI_OFS_BITS] == `SPI_TX_0);
   assign spi_ss_sel      = wb_cyc_i & wb_stb_i & (wb_adr_i[`SPI_OFS_BITS] == `SPI_SS);
  
   // Read from registers
   // Wb data out
   always @(posedge wb_clk_i or posedge wb_rst_i)
  begin
     if (wb_rst_i)
       wb_dat_o <= #Tp 32'b0;
     else
       case (wb_adr_i[`SPI_OFS_BITS])
	 `SPI_RX_0:    wb_dat_o <= rx;	 
	 `SPI_CTRL:    wb_dat_o <= {18'd0, ctrl};
	 `SPI_DEVIDE:  wb_dat_o <= divider;
	 `SPI_SS:      wb_dat_o <= {{32-`SPI_SS_NB{1'b0}}, ss};
	default:      wb_dat_o  <= rx;
       endcase
  end
  
   // Wb acknowledge
   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i)
	  wb_ack_o <= #Tp 1'b0;
    else
      wb_ack_o <= #Tp wb_cyc_i & wb_stb_i & ~wb_ack_o;
     end
   
   // Ctrl register
   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i)
	  {go,char_len_ctrl} <= #Tp 2'b01;
	else if(spi_ctrl_sel && wb_we_i && !tip)
	  begin
             if (wb_sel_i[0])
               char_len_ctrl <= #Tp wb_dat_i[5];
             if (wb_sel_i[1])
	       go <= #Tp wb_dat_i[8];
	  end
	else if(tip && last_bit && pos_edge)
	  go <= #Tp 1'b0;
     end

   assign char_len = char_len_ctrl ? 6'd32 : 6'd8;   
`ifdef SPI_CTRL_ASS
   assign ass = 1'b1;
`else
   assign ass = 1'b0;
`endif
`ifdef SPI_CTRL_LSB
   assign lsb = 1'b1;
`else
   assign lsb = 1'b0;
`endif
`ifdef SPI_CTRL_RX_NEGEDGE
   assign rx_negedge = 1'b1;
`else
   assign rx_negedge = 1'b0;
`endif
`ifdef SPI_CTRL_TX_NEGEDGE
   assign tx_negedge = 1'b1;
`else
   assign tx_negedge = 1'b0;
`endif

   assign ctrl = {ass,1'b0,lsb,tx_negedge,rx_negedge,go,1'b0,1'b0,char_len};
   
   // Slave select register
   always @(posedge wb_clk_i or posedge wb_rst_i)
     if (wb_rst_i)
       ss <= #Tp {`SPI_SS_NB{1'b0}};
     else if(spi_ss_sel && wb_we_i && !tip)
       if (wb_sel_i[0])
         ss <= #Tp wb_dat_i[`SPI_SS_NB-1:0];
   
   assign ss_pad_o = ~((ss & {`SPI_SS_NB{tip & ass}}) | (ss & {`SPI_SS_NB{!ass}}));
 
   spi_flash_clgen
     #
     (
      .divider_len(divider_len),
      .divider(divider)
      )
     clgen 
       (
	.clk_in(wb_clk_i), 
	.rst(wb_rst_i), 
	.go(go), 
	.enable(tip), 
	.last_clk(last_bit),
	.clk_out(sclk_pad_o), 
	.pos_edge(pos_edge), 
        .neg_edge(neg_edge)
	);
  
   spi_flash_shift  shift 
     (
      .clk(wb_clk_i), 
      .rst(wb_rst_i), 
      .len(char_len[`SPI_CHAR_LEN_BITS-1:0]),
      .latch(spi_tx_sel & wb_we_i), 
      .byte_sel(wb_sel_i),
      .go(go), 
      .pos_edge(pos_edge), 
      .neg_edge(neg_edge),
      .lsb(lsb),
      .rx_negedge(rx_negedge), 
      .tx_negedge(tx_negedge), 
      .tip(tip), 
      .last(last_bit), 
      .p_in(wb_dat_i), 
      .p_out(rx), 
      .s_clk(sclk_pad_o), 
      .s_in(miso_pad_i), 
      .s_out(mosi_pad_o)
      );
   
endmodule
  
