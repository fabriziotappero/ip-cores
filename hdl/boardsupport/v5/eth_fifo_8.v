//-----------------------------------------------------------------------------
// Title      : 10/100/1G Ethernet FIFO for 8-bit client I/F
// Project    : Virtex-5 Ethernet MAC Wrappers
//-----------------------------------------------------------------------------
// File       : eth_fifo_8.v
// Author     : Xilinx
//-----------------------------------------------------------------------------
// Copyright (c) 2004-2008 by Xilinx, Inc. All rights reserved.
// This text/file contains proprietary, confidential
// information of Xilinx, Inc., is distributed under license
// from Xilinx, Inc., and may be used, copied and/or
// disclosed only pursuant to the terms of a valid license
// agreement with Xilinx, Inc. Xilinx hereby grants you
// a license to use this text/file solely for design, simulation,
// implementation and creation of design files limited
// to Xilinx devices or technologies. Use with non-Xilinx
// devices or technologies is expressly prohibited and
// immediately terminates your license unless covered by
// a separate agreement.
//
// Xilinx is providing this design, code, or information
// "as is" solely for use in developing programs and
// solutions for Xilinx devices. By providing this design,
// code, or information as one possible implementation of
// this feature, application or standard, Xilinx is making no
// representation that this implementation is free from any
// claims of infringement. You are responsible for
// obtaining any rights you may require for your implementation.
// Xilinx expressly disclaims any warranty whatsoever with
// respect to the adequacy of the implementation, including
// but not limited to any warranties or representations that this
// implementation is free from claims of infringement, implied
// warranties of merchantability or fitness for a particular
// purpose.
//
// Xilinx products are not intended for use in life support
// appliances, devices, or systems. Use in such applications are
// expressly prohibited.
//
// This copyright and support notice must be retained as part
// of this text at all times. (c) Copyright 2004-2008 Xilinx, Inc.
// All rights reserved.
//-----------------------------------------------------------------------------
// Description: This is the top level wrapper for the 10/100/1G Ethernet FIFO.
//              The top level wrapper consists of individual fifos on the 
//              transmitter path and on the receiver path.
//
//              Each path consists of an 8 bit local link to 8 bit client
//              interface FIFO.
//-----------------------------------------------------------------------------


`timescale 1ps / 1ps


module eth_fifo_8   
    (
        // Transmit FIFO MAC TX Interface
        tx_clk,              // MAC transmit clock
        tx_reset,            // Synchronous reset (tx_clk)
        tx_enable,           // Clock enable for tx_clk
        tx_data,             // Data to MAC transmitter
        tx_data_valid,       // Valid signal to MAC transmitter
        tx_ack,              // Ack signal from MAC transmitter
        tx_underrun,         // Underrun signal to MAC transmitter
        tx_collision,        // Collsion signal from MAC transmitter
        tx_retransmit,       // Retransmit signal from MAC transmitter
        
        // Transmit FIFO Local-link Interface
        tx_ll_clock,         // Local link write clock
        tx_ll_reset,         // synchronous reset (tx_ll_clock)
        tx_ll_data_in,       // Data to Tx FIFO
        tx_ll_sof_in_n,      // sof indicator to FIFO
        tx_ll_eof_in_n,      // eof indicator to FIFO
        tx_ll_src_rdy_in_n,  // src ready indicator to FIFO
        tx_ll_dst_rdy_out_n, // dst ready indicator from FIFO
        tx_fifo_status,      // FIFO memory status
        tx_overflow,         // FIFO overflow indicator from FIFO
        
        // Receive FIFO MAC RX Interface
        rx_clk,              // MAC receive clock 
        rx_reset,            // Synchronous reset (rx_clk)
        rx_enable,           // Clock enable for rx_clk
        rx_data,             // Data from MAC receiver
        rx_data_valid,       // Valid signal from MAC receiver
        rx_good_frame,       // Good frame indicator from MAC receiver
        rx_bad_frame,        // Bad frame indicator from MAC receiver
        rx_overflow,         // FIFO overflow indicator from FIFO
     
        // Receive FIFO Local-link Interface
        rx_ll_clock,         // Local link read clock
        rx_ll_reset,         // synchronous reset (rx_ll_clock)
        rx_ll_data_out,      // Data from Rx FIFO
        rx_ll_sof_out_n,     // sof indicator from FIFO
        rx_ll_eof_out_n,     // eof indicator from FIFO
        rx_ll_src_rdy_out_n, // src ready indicator from FIFO
        rx_ll_dst_rdy_in_n,  // dst ready indicator to FIFO
        rx_fifo_status       // FIFO memory status
        );

  //---------------------------------------------------------------------------
  // Define Interface Signals
  //---------------------------------------------------------------------------

   parameter FULL_DUPLEX_ONLY = 0;      

   // Transmit FIFO MAC TX Interface
   input        tx_clk;
   input        tx_reset;
   input        tx_enable;
   output [7:0] tx_data;
   output 	tx_data_valid;
   input 	tx_ack;
   output 	tx_underrun;
   input 	tx_collision;
   input 	tx_retransmit;
   
   // Transmit FIFO Local-link Interface  
   input 	tx_ll_clock;
   input 	tx_ll_reset;
   input  [7:0]	tx_ll_data_in;
   input 	tx_ll_sof_in_n;
   input 	tx_ll_eof_in_n;
   input 	tx_ll_src_rdy_in_n;
   output 	tx_ll_dst_rdy_out_n;
   output [3:0] tx_fifo_status;
   output 	tx_overflow;

   // Receive FIFO MAC RX Interface   
   input 	rx_clk;
   input 	rx_reset;
   input 	rx_enable;
   input [7:0] 	rx_data;
   input 	rx_data_valid;
   input 	rx_good_frame;
   input 	rx_bad_frame;
   output 	rx_overflow;
   
   // Receive FIFO Local-link Interface
   input 	rx_ll_clock;
   input 	rx_ll_reset;
   output [7:0] rx_ll_data_out;
   output 	rx_ll_sof_out_n;
   output 	rx_ll_eof_out_n;
   output 	rx_ll_src_rdy_out_n;
   input 	rx_ll_dst_rdy_in_n;
   output [3:0] rx_fifo_status;
   
	  

   assign tx_underrun = 1'b0;
   
   // Transmitter FIFO
   defparam tx_fifo_i.FULL_DUPLEX_ONLY = FULL_DUPLEX_ONLY;
   tx_client_fifo_8 tx_fifo_i ( 
        .rd_clk           (tx_clk),
        .rd_sreset        (tx_reset),
        .rd_enable        (tx_enable),
        .tx_data          (tx_data),
        .tx_data_valid    (tx_data_valid),
        .tx_ack           (tx_ack),
        .tx_collision     (tx_collision),
        .tx_retransmit    (tx_retransmit),
        .overflow         (tx_overflow),
        .wr_clk           (tx_ll_clock),
        .wr_sreset        (tx_ll_reset),
        .wr_data          (tx_ll_data_in),
        .wr_sof_n         (tx_ll_sof_in_n),
        .wr_eof_n         (tx_ll_eof_in_n),
        .wr_src_rdy_n     (tx_ll_src_rdy_in_n),
        .wr_dst_rdy_n     (tx_ll_dst_rdy_out_n),
        .wr_fifo_status   (tx_fifo_status)
        );
  

   // Receiver FIFO
   rx_client_fifo_8 rx_fifo_i (
        .wr_clk          (rx_clk),
        .wr_enable       (rx_enable),
        .wr_sreset       (rx_reset),
        .rx_data         (rx_data),
        .rx_data_valid   (rx_data_valid),
        .rx_good_frame   (rx_good_frame),
        .rx_bad_frame    (rx_bad_frame),
        .overflow        (rx_overflow),
        .rd_clk          (rx_ll_clock),
        .rd_sreset       (rx_ll_reset),
        .rd_data_out     (rx_ll_data_out),
        .rd_sof_n        (rx_ll_sof_out_n),
        .rd_eof_n        (rx_ll_eof_out_n),
        .rd_src_rdy_n    (rx_ll_src_rdy_out_n),
        .rd_dst_rdy_n    (rx_ll_dst_rdy_in_n),
        .rx_fifo_status  (rx_fifo_status)
        );

endmodule
