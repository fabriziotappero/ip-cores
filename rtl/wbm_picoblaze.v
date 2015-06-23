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
// filename: wbm_picoblaze.v
// description: synthesizable wishbone master adapter for PicoBlaze (TM),
//              working together with "wb_wr" and "wb_rd" assembler subroutines
// todo4user: module should not be changed!
// version: 0.0.0
// changelog: - 0.0.0, initial release
//            - ...
////////////////////////////////////////////////////////////////////////////////


module wbm_picoblaze (
  rst,
  clk,
  
  wbm_cyc_o,
  wbm_stb_o,
  wbm_we_o,
  wbm_adr_o,
  wbm_dat_m2s_o,
  wbm_dat_s2m_i,
  wbm_ack_i,
  
  pb_port_id_i,
  pb_write_strobe_i,
  pb_out_port_i,
  pb_read_strobe_i,
  pb_in_port_o
);

  input rst; 
  wire  rst;
  input clk; 
  wire  clk;
  
  output wbm_cyc_o;
  wire   wbm_cyc_o;
  output wbm_stb_o; 
  reg    wbm_stb_o;
  output wbm_we_o; 
  reg    wbm_we_o;
  output[7:0] wbm_adr_o; 
  reg   [7:0] wbm_adr_o;
  output[7:0] wbm_dat_m2s_o;
  reg   [7:0] wbm_dat_m2s_o;
  input[7:0] wbm_dat_s2m_i;
  wire [7:0] wbm_dat_s2m_i;
  input wbm_ack_i;
  wire  wbm_ack_i;
  
  input[7:0] pb_port_id_i;
  wire [7:0] pb_port_id_i;
  input pb_write_strobe_i;
  wire  pb_write_strobe_i;
  input[7:0] pb_out_port_i;
  wire [7:0] pb_out_port_i;
  input pb_read_strobe_i;
  wire  pb_read_strobe_i;
  output[7:0] pb_in_port_o;
  reg   [7:0] pb_in_port_o;
  
  reg[7:0] wb_buffer;
  
  parameter[7:0] WB_ACK_FLAG = 8'h01;

  parameter[1:0] 
    S_IDLE = 2'b00,
    S_WAIT_ON_WB_ACK = 2'b01,
    S_SOFTWARE_HANDSHAKE = 2'b10,
    S_SOFTWARE_READ = 2'b11
  ;
  reg[1:0] state;
 
  assign wbm_cyc_o = wbm_stb_o;

  always@(posedge clk) begin
    
    case(state)
      S_IDLE:
        // setting up wishbone address, data and control signals from 
        // PicoBlaze (TM) signals
        if (pb_write_strobe_i) begin
          wbm_stb_o <= 1'b1;
          wbm_we_o <= 1'b1;
          wbm_adr_o <= pb_port_id_i;
          wbm_dat_m2s_o <= pb_out_port_i;
          state <= S_WAIT_ON_WB_ACK;
        end else if (pb_read_strobe_i) begin
          wbm_stb_o <= 1'b1;
          wbm_we_o <= 1'b0;
          wbm_adr_o <= pb_port_id_i;
          state <= S_WAIT_ON_WB_ACK;
        end
      S_WAIT_ON_WB_ACK:
        // waiting on slave peripheral to complete wishbone transfer cycle
        if (wbm_ack_i) begin
          wbm_stb_o <= 1'b0;
          wb_buffer <= wbm_dat_s2m_i;
          pb_in_port_o <= WB_ACK_FLAG;
          state <= S_SOFTWARE_HANDSHAKE;
        end
      S_SOFTWARE_HANDSHAKE:
        // software recognition of wishbone handshake
        if (pb_read_strobe_i)
          // transfer complete for a write access
          if (wbm_we_o) begin
            pb_in_port_o <= 8'h00;
            state <= S_IDLE;
          // presenting valid wishbone data to PicoBlaze (TM) port in read 
          // access
          end else begin
            pb_in_port_o <= wb_buffer;
            state <= S_SOFTWARE_READ;
          end 
      S_SOFTWARE_READ:
        // transfer complete for a read access after software recognition of
        // wishbone data
        if (pb_read_strobe_i) begin
          pb_in_port_o <= 8'h00;
          state <= S_IDLE;
        end
      default: ;
    endcase
  
    if (rst) begin
      wbm_stb_o <= 1'b0;
      pb_in_port_o <= 8'h00;
      state <= S_IDLE;
    end
      
  end

endmodule
