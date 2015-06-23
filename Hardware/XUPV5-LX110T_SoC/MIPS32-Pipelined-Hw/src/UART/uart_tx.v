`timescale 1ns / 1ps
/*
 * File         : uart_tx.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   25-Mar-2010  GEA       Initial design.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   Transmits bytes of data from the serial port. Capable of back-to-back
 *   transmission of data for maximum bandwidth utilization.
 *   'TxD_start' must only pulse with a 'uart_tick' pulse. 8N1.
 */
module uart_tx (
    input clock,
    input reset,
    input uart_tick,
    input [7:0] TxD_data,
    input TxD_start,    // Must happen with a uart_tick
    output ready,
    output reg TxD
    );

    localparam [3:0] IDLE=0, START=1, BIT_0=2, BIT_1=3, BIT_2=4, BIT_3=5,
                     BIT_4=6, BIT_5=7, BIT_6=8, BIT_7=9, STOP=10;

    reg [3:0] tx_state = IDLE;
    reg [7:0] TxD_data_r = 8'h00;    // Registered input data so it doesn't need to be held

    assign ready = (tx_state == IDLE) || (tx_state == STOP);

    always @(posedge clock) begin
        TxD_data_r <= (ready & TxD_start) ? TxD_data : TxD_data_r;
    end
   
    always @(posedge clock) begin
        if (reset) tx_state <= IDLE;
        else begin
            case (tx_state)
                IDLE:   if (TxD_start) tx_state <= START;
                START:  if (uart_tick) tx_state <= BIT_0;
                BIT_0:  if (uart_tick) tx_state <= BIT_1;
                BIT_1:  if (uart_tick) tx_state <= BIT_2;
                BIT_2:  if (uart_tick) tx_state <= BIT_3;
                BIT_3:  if (uart_tick) tx_state <= BIT_4;
                BIT_4:  if (uart_tick) tx_state <= BIT_5;
                BIT_5:  if (uart_tick) tx_state <= BIT_6;
                BIT_6:  if (uart_tick) tx_state <= BIT_7;
                BIT_7:  if (uart_tick) tx_state <= STOP;
                STOP:   if (uart_tick) tx_state <= (TxD_start) ? START : IDLE;
                default: tx_state <= 4'bxxxx;
            endcase
        end
    end

    always @(tx_state, TxD_data_r) begin
        case (tx_state)
            IDLE:   TxD <= 1;
            START:  TxD <= 0;
            BIT_0:  TxD <= TxD_data_r[0];
            BIT_1:  TxD <= TxD_data_r[1];
            BIT_2:  TxD <= TxD_data_r[2];
            BIT_3:  TxD <= TxD_data_r[3];
            BIT_4:  TxD <= TxD_data_r[4];
            BIT_5:  TxD <= TxD_data_r[5];
            BIT_6:  TxD <= TxD_data_r[6];
            BIT_7:  TxD <= TxD_data_r[7];
            STOP:   TxD <= 1;
            default: TxD <= 1'bx;
        endcase
    end

endmodule

