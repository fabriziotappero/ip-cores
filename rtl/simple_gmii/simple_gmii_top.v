//
// Simple GMII-Like Interface for TV80
//
// Copyright (c) 2005 Guy Hutchison (ghutchis@opencores.org)
//
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation 
// the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the 
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module simple_gmii_top (/*AUTOARG*/
  // Outputs
  rd_data, doe, int_n, tx_data, tx_dv, tx_er, 
  // Inputs
  clk, reset, iorq_n, rd_n, addr, wr_data, wr_n, rx_clk, rx_data, 
  rx_dv, rx_er, tx_clk
  );

  parameter txbuf_sz = 512, rxbuf_sz = 512;
  parameter wr_ptr_sz = 9;

  input                 clk;                    // To core0 of simple_gmii_core.v, ...
  input                 reset;                  // To core0 of simple_gmii_core.v, ...

  // TV80 Controls
  input                 iorq_n;                 // To regs0 of simple_gmii_regs.v
  input                 rd_n;                   // To regs0 of simple_gmii_regs.v
  input [15:0]          addr;                   // To regs0 of simple_gmii_regs.v
  input [7:0]           wr_data;                // To regs0 of simple_gmii_regs.v
  output [7:0]          rd_data;                // From regs0 of simple_gmii_regs.v
  input                 wr_n;                   // To regs0 of simple_gmii_regs.v
  output                doe;                    // From regs0 of simple_gmii_regs.v
  output                int_n;                  // From regs0 of simple_gmii_regs.v

  // GMII RX
  input                 rx_clk;                 // To core0 of simple_gmii_core.v
  input [7:0]           rx_data;                // To core0 of simple_gmii_core.v, ...
  input                 rx_dv;                  // To core0 of simple_gmii_core.v
  input                 rx_er;                  // To core0 of simple_gmii_core.v

  // GMII TX
  input                 tx_clk;                 // To core0 of simple_gmii_core.v
  output [7:0]          tx_data;
  output                tx_dv;
  output                tx_er;
  
  wire [1:0]            status_set;
  wire [15:0]           rx_len;
  wire [7:0]            rx_rd_data;
  wire [7:0]            tx_wr_data;
  wire                  tx_wr_stb; 
  wire                  en_preamble;
  wire                  start_transmit;
  wire                  rx_rd_stb;
  
   // RX Buf RAM
  wire                  rxbuf_we;
  wire [wr_ptr_sz-1:0]  rx_wr_ptr; 
  wire [wr_ptr_sz-1:0]  rx_rd_ptr;
  wire [7:0]            rxbuf_data;

   // TX Buf RAM
  wire                  wr_sel_tx_data;
  wire [wr_ptr_sz-1:0]  txi_wr_ptr;
  wire [7:0]            io_data_in;
  wire [wr_ptr_sz-1:0]  txo_xm_ptr;
  wire [7:0]            txbuf_data;

  simple_gmii_core #(txbuf_sz, rxbuf_sz, wr_ptr_sz) core0
    (
     // Outputs
     .status_set                        (status_set),
     .rx_len                            (rx_len),
     .rx_rd_data                        (rx_rd_data),

     // GMII TX Interface
     .tx_clk                            (tx_clk),
     .tx_data (tx_data),
     .tx_dv   (tx_dv),
     .tx_er   (tx_er),

     // GMII RX Interface
     .rx_data                           (rx_data),
     .rx_clk                            (rx_clk),
     .rx_dv                             (rx_dv),
     .rx_er                             (rx_er),

     // RX Buf RAM
     .rxbuf_we (rxbuf_we),
     .rx_wr_ptr (rx_wr_ptr),
     .rx_rd_ptr (rx_rd_ptr),
     .rxbuf_data (rxbuf_data),

     // TX Buf RAM
     .wr_sel_tx_data (wr_sel_tx_data),
     .txi_wr_ptr (txi_wr_ptr),
     //.io_data_in (io_data_in),
     .txo_xm_ptr (txo_xm_ptr),
     .txbuf_data (txbuf_data),
     
     // Register Interface
     .clk                               (clk),
     .reset                             (reset),
     .start_transmit                    (start_transmit),
     .rx_rd_stb                         (rx_rd_stb),
     //.tx_wr_data                        (tx_wr_data),
     .tx_wr_stb                         (tx_wr_stb),
     .en_preamble                       (en_preamble));

  ram_1r_1w #(8, rxbuf_sz, wr_ptr_sz) rxbuf
    (.clk     (rx_clk),
     .wr_en   (rxbuf_we),
     .wr_addr (rx_wr_ptr),
     .wr_data (rx_data),

     .rd_addr (rx_rd_ptr),
     .rd_data (rxbuf_data));

  ram_1r_1w #(8, txbuf_sz, wr_ptr_sz) txbuf
    (.clk     (clk),
     .wr_en   (wr_sel_tx_data),
     .wr_addr (txi_wr_ptr),
     .wr_data (tx_wr_data),

     .rd_addr (txo_xm_ptr),
     .rd_data (txbuf_data));  

  simple_gmii_regs regs0
    (
     // Outputs
     .rd_data                           (rd_data),
     .doe                               (doe),
     .status_msk                        (),
     .control                           (start_transmit),
     .rx_data_stb                       (rx_rd_stb),
     .tx_data                           (tx_wr_data),
     .tx_data_stb                       (tx_wr_stb),
     .cfg                               (en_preamble),
     .int_n                             (int_n),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .addr                              (addr[15:0]),
     .wr_data                           (wr_data),
     .rd_n                              (rd_n),
     .wr_n                              (wr_n),
     .iorq_n                            (iorq_n),
     .status_set                        (status_set[1:0]),
     .control_clr                       (start_transmit),  // auto-clear when set
     .rx_len0                           (rx_len[7:0]),
     .rx_len1                           (rx_len[15:8]),
     .rx_data                           (rx_rd_data));

endmodule // simple_gmii
