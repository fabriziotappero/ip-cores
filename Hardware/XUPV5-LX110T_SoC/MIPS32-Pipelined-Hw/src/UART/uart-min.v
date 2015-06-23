`timescale 1ns / 1ps
/*
 * File         : uart-min.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   24-May-2010  GEA       Initial design.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   115200 baud 8-N-1 serial port, using only Tx and Rx.
 *   (8 data bits, no parity, 1 stop bit, no flow control.)
 *   Configurable baud rate determined by clocking module, 16x oversampling
 *   for Rx data, Rx filtering, and configurable FIFO buffers for receiving
 *   and transmitting.
 *
 *   Described as '_min' due to lack of overflow and other status signals
 *   as well as the use of only Tx and Rx signals.
 */
module uart_min(
    input clock,
    input reset,
    input write,
    input [7:0] data_in,   // tx going into uart, out of serial port
    input read,
    output [7:0] data_out, // rx coming in from serial port, out of uart
    output data_ready,
    output [8:0] rx_count,
    /*------------------------*/
    input RxD,
    output TxD
    );

    localparam DATA_WIDTH = 8; // Bit-width of FIFO data (should be 8)
    localparam ADDR_WIDTH = 8; // 2^ADDR_WIDTH words of FIFO space

    /* Clocking Signals */
    wire uart_tick, uart_tick_16x;

    /* Receive Signals */
    wire [7:0] rx_data;     // Raw bytes coming in from uart
    wire rx_data_ready;     // Synchronous pulse indicating this (^)
    wire rx_fifo_empty;

    /* Send Signals */
    reg tx_fifo_deQ = 0;
    reg tx_start = 0;
    wire tx_free;
    wire tx_fifo_empty;
    wire [7:0] tx_fifo_data_out;

    assign data_ready = ~rx_fifo_empty;
   
    always @(posedge clock) begin
        if (reset) begin
            tx_fifo_deQ <= 0;
            tx_start <= 0;
        end
        else begin
            if (~tx_fifo_empty & tx_free & uart_tick) begin
                tx_fifo_deQ <= 1;
                tx_start <= 1;
            end
            else begin
                tx_fifo_deQ <= 0;
                tx_start <= 0;
            end
        end
    end

    uart_clock clocks (
        .clock          (clock), 
        .uart_tick      (uart_tick), 
        .uart_tick_16x  (uart_tick_16x)
    );

    uart_tx tx (
        .clock          (clock),
        .reset          (reset),
        .uart_tick      (uart_tick), 
        .TxD_data       (tx_fifo_data_out), 
        .TxD_start      (tx_start), 
        .ready          (tx_free), 
        .TxD            (TxD)
    );

    uart_rx rx (
        .clock          (clock),
        .reset          (reset),
        .RxD            (RxD), 
        .uart_tick_16x  (uart_tick_16x), 
        .RxD_data       (rx_data), 
        .data_ready     (rx_data_ready)
    );
   
    FIFO_NoFull_Count #(
        .DATA_WIDTH     (DATA_WIDTH),
        .ADDR_WIDTH     (ADDR_WIDTH))
        tx_buffer (
        .clock          (clock), 
        .reset          (reset), 
        .enQ            (write), 
        .deQ            (tx_fifo_deQ), 
        .data_in        (data_in), 
        .data_out       (tx_fifo_data_out), 
        .empty          (tx_fifo_empty),
        .count          ()
    );
    
    FIFO_NoFull_Count #(
        .DATA_WIDTH     (DATA_WIDTH),
        .ADDR_WIDTH     (ADDR_WIDTH))
        rx_buffer (
        .clock          (clock), 
        .reset          (reset), 
        .enQ            (rx_data_ready), 
        .deQ            (read), 
        .data_in        (rx_data), 
        .data_out       (data_out), 
        .empty          (rx_fifo_empty),
        .count          (rx_count)
    );
    
endmodule

