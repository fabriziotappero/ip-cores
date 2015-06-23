////////////////////////////////////////////////////////////////////////////////
// This sourcecode is released under BSD license.
// Please see http://www.opensource.org/licenses/bsd-license.php for details!
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2010, Stefan Fischer <Ste.Fis@OpenCores.org>
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without 
// modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, 
//    this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
// POSSIBILITY OF SUCH DAMAGE.
//
////////////////////////////////////////////////////////////////////////////////
// filename: wbs_uart.v
// description: synthesizable wishbone slave uart sio module using Xilinx (R)
//              macros and adding some functionality like a configurable 
//              baud rate and buffer level checking 
// todo4user: add other uart functionality as needed, i. e. interrupt logic or
//            modem control signals
// version: 0.0.0
// changelog: - 0.0.0, initial release
//            - ...
////////////////////////////////////////////////////////////////////////////////


module wbs_uart (
  rst,
  clk,
  
  wbs_cyc_i,
  wbs_stb_i,
  wbs_we_i,
  wbs_adr_i,
  wbs_dat_m2s_i,
  wbs_dat_s2m_o,
  wbs_ack_o,
  
  uart_rx_si_i,
  uart_tx_so_o
);

  input rst; 
  wire  rst;
  input clk; 
  wire  clk;
  
  input wbs_cyc_i;
  wire  wbs_cyc_i;
  input wbs_stb_i; 
  wire  wbs_stb_i;
  input wbs_we_i; 
  wire  wbs_we_i;
  input[7:0] wbs_adr_i; 
  wire [7:0] wbs_adr_i;
  input[7:0] wbs_dat_m2s_i;
  wire [7:0] wbs_dat_m2s_i;
  output[7:0] wbs_dat_s2m_o;
  reg   [7:0] wbs_dat_s2m_o;
  output wbs_ack_o;
  reg    wbs_ack_o;
  
  input uart_rx_si_i;
  wire  uart_rx_si_i;
  output uart_tx_so_o;
  wire   uart_tx_so_o;

  wire wb_reg_we;

  parameter ADDR_MSB = 1;
  parameter[7:0] UART_RXTX_ADDR = 8'h00;
  parameter[7:0] UART_SR_ADDR = 8'h01;
  parameter UART_SR_RX_F_FLAG = 0;
  parameter UART_SR_RX_HF_FLAG = 1;
  parameter UART_SR_RX_DP_FLAG = 2;
  parameter UART_SR_TX_F_FLAG = 4;
  parameter UART_SR_TX_HF_FLAG = 5;
  parameter[7:0] UART_BAUD_LO_ADDR = 8'h02;
  parameter[7:0] UART_BAUD_HI_ADDR = 8'h03;
  
  reg[15:0] baud_count;
  reg[15:0] baud_limit;
  
  reg en_16_x_baud;
  
  reg rx_read_buffer;
  wire rx_buffer_full;
  wire rx_buffer_half_full;
  wire rx_buffer_data_present;
  wire[7:0] rx_data_out;
  
  reg tx_write_buffer;
  wire tx_buffer_full;
  wire tx_buffer_half_full;
  
  // internal register write enable signal
  assign wb_reg_we = wbs_cyc_i && wbs_stb_i && wbs_we_i;
 
  always@(posedge clk) begin
    
    // baud rate configuration:
    // baud_limit = round( system clock frequency / (16 * baud rate) ) - 1
    // i. e. 9600 baud at 50 MHz system clock =>
    // baud_limit = round( 50.0E6 / (16 * 9600) ) - 1 = 325 = 0x0145

    // baud timer
    if (baud_count == baud_limit) begin
      baud_count <= 16'h0000;
      en_16_x_baud <= 1'b1;
    end else begin
      baud_count <= baud_count + 1;
      en_16_x_baud <= 1'b0;
    end
  
    rx_read_buffer <= 1'b0;
    tx_write_buffer <= 1'b0;
    
    wbs_dat_s2m_o <= 8'h00;
    // registered wishbone slave handshake (default)
    wbs_ack_o <= wbs_cyc_i && wbs_stb_i && (! wbs_ack_o);
    
    case(wbs_adr_i[ADDR_MSB:0])
      // receive/transmit buffer access
      UART_RXTX_ADDR[ADDR_MSB:0]: begin
        if (wbs_cyc_i && wbs_stb_i)
          // overwriting wishbone slave handshake for blocking transactions 
          // to rx/tx fifos by using buffer status flags
          if (wbs_we_i) begin
            tx_write_buffer <= (! tx_buffer_full) && (! wbs_ack_o);
            wbs_ack_o <= (! tx_buffer_full) && (! wbs_ack_o);
          end else begin
            rx_read_buffer <= rx_buffer_data_present && (! wbs_ack_o);
            wbs_ack_o <= rx_buffer_data_present && (! wbs_ack_o);
          end
        wbs_dat_s2m_o <= rx_data_out;
      end
      // status register access
      UART_SR_ADDR[ADDR_MSB:0]: begin
        wbs_dat_s2m_o[UART_SR_RX_F_FLAG] <= rx_buffer_full;
        wbs_dat_s2m_o[UART_SR_RX_HF_FLAG] <= rx_buffer_half_full;
        wbs_dat_s2m_o[UART_SR_RX_DP_FLAG] <= rx_buffer_data_present;
        wbs_dat_s2m_o[UART_SR_TX_F_FLAG] <= tx_buffer_full;
        wbs_dat_s2m_o[UART_SR_TX_HF_FLAG] <= tx_buffer_half_full;
      end
      // baud rate register access / low byte
      UART_BAUD_LO_ADDR[ADDR_MSB:0]: begin
        if (wb_reg_we) begin
          baud_limit[7:0] <= wbs_dat_m2s_i;
          baud_count <= 16'h0000;
        end 
        wbs_dat_s2m_o <= baud_limit[7:0];
      end
      // baud rate register access / high byte
      UART_BAUD_HI_ADDR[ADDR_MSB:0]: begin
        if (wb_reg_we)  begin
          baud_limit[15:8] <= wbs_dat_m2s_i;
          baud_count <= 16'h0000;
        end
        wbs_dat_s2m_o <= baud_limit[15:8];
      end
      default: ;
    endcase
  
    if (rst)
      wbs_ack_o <= 1'b0;
      
  end
  
  // Xilinx (R) uart macro instances
  //////////////////////////////////
  
  uart_rx inst_uart_rx (
    .serial_in(uart_rx_si_i),
    .data_out(rx_data_out),
    .read_buffer(rx_read_buffer),
    .reset_buffer(rst),
    .en_16_x_baud(en_16_x_baud),
    .buffer_data_present(rx_buffer_data_present),
    .buffer_full(rx_buffer_full),
    .buffer_half_full(rx_buffer_half_full),
    .clk(clk)
  );
  
  uart_tx inst_uart_tx (
    .data_in(wbs_dat_m2s_i),
    .write_buffer(tx_write_buffer),
    .reset_buffer(rst),
    .en_16_x_baud(en_16_x_baud),
    .serial_out(uart_tx_so_o),
    .buffer_full(tx_buffer_full),
    .buffer_half_full(tx_buffer_half_full),
    .clk(clk)
  );

endmodule
