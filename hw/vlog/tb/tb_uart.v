//////////////////////////////////////////////////////////////////
//                                                              //
//  Testbench UART                                              //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Provides a target to test the wishbone UART against.        //
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

`include "global_timescale.vh"
`include "system_config_defines.vh"
`include "global_defines.vh"


module tb_uart (
input                       i_uart_cts_n,          // Clear To Send
output reg                  o_uart_txd,
output                      o_uart_rts_n,          // Request to Send
input                       i_uart_rxd 

);

assign o_uart_rts_n = 1'd0;  // allow the other side to transmit all the time

// -------------------------------------------------------------------------
// Baud Rate Configuration
// -------------------------------------------------------------------------

// Baud period in nanoseconds
localparam UART_BAUD         = `AMBER_UART_BAUD;            // Hz
localparam UART_BIT_PERIOD   = 1000000000 / UART_BAUD;      // nS

// -------------------------------------------------------------------------

reg             clk_uart;
reg             clk_uart_rst_n;

reg [1:0]       rx_state;
reg [2:0]       rx_bit;
reg [7:0]       rx_byte;
reg [3:0]       rx_tap;
reg [3:0]       rx_bit_count;
wire            rx_bit_start;
wire            rx_start_negedge;
reg             rx_start_negedge_d1;

reg [1:0]       tx_state;
reg [2:0]       tx_bit;
reg [7:0]       tx_byte;
reg [3:0]       tx_bit_count;
wire            tx_bit_start;
wire            tx_start;
wire            loopback;
wire            tx_push;
reg             tx_push_r;
wire            tx_push_toggle;
wire [7:0]      txd;

wire            txfifo_empty;
wire            txfifo_full;
reg  [7:0]      tx_fifo [15:0];
reg  [4:0]      txfifo_wp;
reg  [4:0]      txfifo_rp;


// ======================================================
// UART Clock
// ======================================================

// runs at 10x baud rate
initial
    begin
    clk_uart        = 1'd0;
    forever #(UART_BIT_PERIOD*100/2) clk_uart = ~clk_uart;
    end

initial
    begin
    // in reset
    clk_uart_rst_n  = 1'd0;
    // out of reset
    #(UART_BIT_PERIOD*1000) clk_uart_rst_n  = 1'd1;
    end

        
// ======================================================
// UART Receive
// ======================================================
always @( posedge clk_uart or negedge clk_uart_rst_n )
    if ( ~clk_uart_rst_n )
        rx_bit_count <= 'd0;
    else if ( rx_bit_count == 4'd9 )                
        rx_bit_count <= 'd0;
    // align the bit count to the centre each incoming bit    
    else if ( rx_start_negedge )                
        rx_bit_count <= 'd0;
    else
        rx_bit_count <= rx_bit_count + 1'd1;

assign rx_bit_start     = rx_bit_count == 4'd0;      
assign rx_start_negedge = rx_tap[3] && !rx_tap[2] && rx_state == 2'd0;

always @( posedge clk_uart or negedge clk_uart_rst_n )
    if ( ~clk_uart_rst_n )
        begin
        rx_state            <= 'd0;
        rx_bit              <= 'd0;
        rx_byte             <= 'd0;
        rx_tap              <= 'd0;
        rx_start_negedge_d1 <= 'd0;
        end
    else                    
        begin
        rx_tap <= { rx_tap[2:0], i_uart_rxd };
        rx_start_negedge_d1 <= rx_start_negedge;
        
        if ( rx_bit_start )
            begin
            case ( rx_state ) 
        
                // wait for start bit edge at end of tap
                // then sample bits at start of tap, approx
                // in the center of each bit
                2'd0: if ( rx_start_negedge_d1 )
                        rx_state <= 2'd1;
                
                // 8 bits in a word        
                2'd1: if ( rx_bit == 3'd7 )
                        rx_state <= 2'd2;
                        
                // stop bit
                2'd2: rx_state <= 2'd0;
                        
            endcase
        
            if ( rx_state == 2'd1 )
                begin
                rx_bit  <= rx_bit + 1'd1;
                // UART sends LSB first
                rx_byte <= {i_uart_rxd, rx_byte[7:1]};
                end
                
            // Ignore carriage returns so don't get a blank line
            // between every printed line in silumations   
            if ( rx_state == 2'd2 && rx_byte != 8'h0d && rx_byte != 8'h0c )
                $write("%c", rx_byte);
            end    
        end

       
// ========================================================
// UART Transmit
// ========================================================

// Get control bits from the wishbone uart test register
assign tx_start     = `U_TEST_MODULE.tb_uart_control_reg[0];
assign loopback     = `U_TEST_MODULE.tb_uart_control_reg[1];

always @* `U_TEST_MODULE.tb_uart_status_reg[1:0] = {txfifo_full, txfifo_empty};

assign tx_push      = `U_TEST_MODULE.tb_uart_push;
assign txd          = `U_TEST_MODULE.tb_uart_txd_reg;

assign tx_bit_start = tx_bit_count == 4'd0;      
assign txfifo_empty = txfifo_wp == txfifo_rp;
assign txfifo_full  = txfifo_wp == {~txfifo_rp[4], txfifo_rp[3:0]};


// Detect when the tx_push signal changes value. It is on a different
// clock domain so this is needed to detect it cleanly
always @( posedge clk_uart or negedge clk_uart_rst_n )
    if ( ~clk_uart_rst_n )
        tx_push_r <= 'd0;
    else
        tx_push_r <= tx_push;
        
assign tx_push_toggle =  tx_push ^ tx_push_r; 


always @( posedge clk_uart or negedge clk_uart_rst_n )
    if ( ~clk_uart_rst_n )
        tx_bit_count <= 'd0;
    else if ( tx_bit_count == 4'd9 )                
        tx_bit_count <= 'd0;
    else
        tx_bit_count <= tx_bit_count + 1'd1;


// Transmit FIFO. 8 entries
always @( posedge clk_uart or negedge clk_uart_rst_n )
    if ( ~clk_uart_rst_n )
        begin
        txfifo_wp               <=    'd0;
        end
    else if ( !loopback && tx_push_toggle && !txfifo_full )
        begin
        tx_fifo[txfifo_wp[3:0]] <=    txd;
        txfifo_wp               <=    txfifo_wp + 1'd1;
        end
    else if ( !loopback && tx_push_toggle && txfifo_full )
        begin
        `TB_WARNING_MESSAGE
        $display("TB UART FIFO overflow");
        end
    // loopback received byte into tx buffer    
    else if ( loopback && rx_state == 2'd2 && rx_bit_start )
        begin
        tx_fifo[txfifo_wp[3:0]] <=    rx_byte;
        txfifo_wp               <=    txfifo_wp + 1'd1;
        end

        
always @( posedge clk_uart or negedge clk_uart_rst_n )
    if ( ~clk_uart_rst_n )
        begin
        tx_state            <= 'd0;
        tx_bit              <= 'd0;
        tx_byte             <= 'd0;
        o_uart_txd          <= 1'd1;
        txfifo_rp           <= 'd0;
        end
    else                    
        begin
        if ( tx_bit_start )
            begin
            case ( tx_state ) 
        
                // wait for trigger to start transmitting
                2'd0: if ( tx_start && !txfifo_empty && !i_uart_cts_n )
                        begin
                        tx_state    <= 2'd1;
                        tx_byte     <= tx_fifo[txfifo_rp[3:0]];
                        txfifo_rp   <= txfifo_rp + 1'd1;
                        // transmit start bit
                        o_uart_txd  <= 1'd0;
                        end
                        
                // 8 bits in a word        
                2'd1: if ( !i_uart_cts_n )   
                        begin
                        if ( tx_bit == 3'd7 )
                            tx_state <= 2'd2;
                        tx_bit      <= tx_bit + 1'd1;
                        tx_byte     <= {1'd0, tx_byte[7:1]};
                        // UART sends LSB first
                        o_uart_txd  <= tx_byte[0];
                        end
                        
                // stop bit
                2'd2:   begin
                        tx_state    <= 2'd0;
                        o_uart_txd  <= 1'd1;
                        end
            endcase
            end    
        end


endmodule

