//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

`timescale 1ns/10ps


module wb_size_bridge(
                        input         wb_hi_clk_i,
                        input         wb_hi_rst_i,
                        output [31:0] wb_hi_dat_o,
                        input  [31:0] wb_hi_dat_i,
                        input  [31:0] wb_hi_adr_i,
                        input         wb_hi_cyc_i,
                        input         wb_hi_stb_i,
                        input         wb_hi_we_i,
                        input  [3:0]  wb_hi_sel_i,
                        output        wb_hi_ack_o,
                        output        wb_hi_err_o,
                        output        wb_hi_rty_o,

                        output        wb_lo_clk_o,
                        output        wb_lo_rst_o,
                        input  [15:0] wb_lo_dat_i,
                        output [15:0] wb_lo_dat_o,
                        output [31:0] wb_lo_adr_o,
                        output        wb_lo_cyc_o,
                        output        wb_lo_stb_o,
                        output        wb_lo_we_o,
                        output [1:0]  wb_lo_sel_o,
                        input         wb_lo_ack_i,
                        input         wb_lo_err_i,
                        input         wb_lo_rty_i,
                        
                        input         lo_byte_if_i
                      );

  // --------------------------------------------------------------------
  //  state machine encoder
  reg [2:0] state_enc;
  
  wire state_enc_3_more_chunks  = state_enc[2];
  wire state_enc_1_more_chunks  = state_enc[1];
  wire state_enc_error          = state_enc[0];
  
  always @(*)
    case( { lo_byte_if_i, wb_hi_sel_i } )
      5'b1_0001:  state_enc = { 1'b0, 1'b0, 1'b0 };
      5'b1_0010:  state_enc = { 1'b0, 1'b0, 1'b0 };
      5'b1_0100:  state_enc = { 1'b0, 1'b0, 1'b0 };
      5'b1_1000:  state_enc = { 1'b0, 1'b0, 1'b0 };
      5'b1_0011:  state_enc = { 1'b0, 1'b1, 1'b0 };
      5'b1_1100:  state_enc = { 1'b0, 1'b1, 1'b0 };
      5'b1_1111:  state_enc = { 1'b1, 1'b0, 1'b0 };
      5'b0_0001:  state_enc = { 1'b0, 1'b0, 1'b0 };
      5'b0_0010:  state_enc = { 1'b0, 1'b0, 1'b0 };
      5'b0_0100:  state_enc = { 1'b0, 1'b0, 1'b0 };
      5'b0_1000:  state_enc = { 1'b0, 1'b0, 1'b0 };
      5'b0_0011:  state_enc = { 1'b0, 1'b0, 1'b0 };
      5'b0_1100:  state_enc = { 1'b0, 1'b0, 1'b0 };
      5'b0_1111:  state_enc = { 1'b0, 1'b1, 1'b0 };
      default:   state_enc = { 1'b0, 1'b0, 1'b1 };
    endcase
    
    
  // --------------------------------------------------------------------
  //  state machine

  localparam   STATE_DONT_CARE     = 4'b????;
  localparam   STATE_PASS_THROUGH  = 4'b0001;
  localparam   STATE_1_MORE_CHUNK  = 4'b0010;
  localparam   STATE_2_MORE_CHUNK  = 4'b0100;
  localparam   STATE_3_MORE_CHUNK  = 4'b1000;

  reg [3:0] state;
  reg [3:0] next_state;

  always @(posedge wb_hi_clk_i or posedge wb_hi_rst_i)
    if(wb_hi_rst_i)
      state <= STATE_PASS_THROUGH;
    else
      state <= next_state;

  always @(*)
    case( state )
      STATE_PASS_THROUGH: if( state_enc_1_more_chunks & wb_lo_ack_i & wb_hi_stb_i & wb_hi_cyc_i )
                            next_state = STATE_1_MORE_CHUNK;
                          else if( state_enc_3_more_chunks & wb_lo_ack_i & wb_hi_stb_i & wb_hi_cyc_i )
                            next_state = STATE_3_MORE_CHUNK;
                          else
                            next_state = STATE_PASS_THROUGH;

      STATE_3_MORE_CHUNK: if( wb_lo_ack_i )
                            next_state = STATE_2_MORE_CHUNK;
                          else
                            next_state = STATE_3_MORE_CHUNK;
                            
      STATE_2_MORE_CHUNK: if( wb_lo_ack_i )
                            next_state = STATE_1_MORE_CHUNK;
                          else
                            next_state = STATE_2_MORE_CHUNK;

      STATE_1_MORE_CHUNK: if( wb_lo_ack_i )
                            next_state = STATE_PASS_THROUGH;
                          else
                            next_state = STATE_1_MORE_CHUNK;
                        
      default:            next_state = STATE_PASS_THROUGH;
    endcase
    

  // --------------------------------------------------------------------
  //  byte enable & select
  reg [3:0] byte_enable;
  localparam   BYTE_N_ENABLED  = 4'b0000;
  localparam   BYTE_0_ENABLED  = 4'b0001;
  localparam   BYTE_1_ENABLED  = 4'b0010;
  localparam   BYTE_2_ENABLED  = 4'b0100;
  localparam   BYTE_3_ENABLED  = 4'b1000;
  
  reg [1:0] byte_select;
  localparam   BYTE_0_SELECTED  = 2'b00;
  localparam   BYTE_1_SELECTED  = 2'b01;
  localparam   BYTE_2_SELECTED  = 2'b10;
  localparam   BYTE_3_SELECTED  = 2'b11;
  localparam   BYTE_X_SELECTED  = 2'b??;

  always @(*)
    casez( { lo_byte_if_i, wb_hi_sel_i, state } )
      { 1'b1, 4'b0001, STATE_PASS_THROUGH }:  byte_enable = BYTE_0_ENABLED;
      { 1'b1, 4'b0010, STATE_PASS_THROUGH }:  byte_enable = BYTE_1_ENABLED;
      { 1'b1, 4'b0100, STATE_PASS_THROUGH }:  byte_enable = BYTE_2_ENABLED;
      { 1'b1, 4'b1000, STATE_PASS_THROUGH }:  byte_enable = BYTE_3_ENABLED;
      
      { 1'b1, 4'b0011, STATE_PASS_THROUGH }:  byte_enable = BYTE_0_ENABLED;
      { 1'b1, 4'b0011, STATE_1_MORE_CHUNK }:  byte_enable = BYTE_1_ENABLED;
      
      { 1'b1, 4'b1100, STATE_PASS_THROUGH }:  byte_enable = BYTE_2_ENABLED;
      { 1'b1, 4'b1100, STATE_1_MORE_CHUNK }:  byte_enable = BYTE_3_ENABLED;
      
      { 1'b1, 4'b1111, STATE_PASS_THROUGH }:  byte_enable = BYTE_0_ENABLED;
      { 1'b1, 4'b1111, STATE_3_MORE_CHUNK }:  byte_enable = BYTE_1_ENABLED;
      { 1'b1, 4'b1111, STATE_2_MORE_CHUNK }:  byte_enable = BYTE_2_ENABLED;
      { 1'b1, 4'b1111, STATE_1_MORE_CHUNK }:  byte_enable = BYTE_3_ENABLED;
      
      { 1'b0, 4'b????, STATE_DONT_CARE }:     byte_enable = BYTE_N_ENABLED;
      default:                                byte_enable = BYTE_N_ENABLED;
    endcase

  always @(*)
    case( byte_enable )
      BYTE_0_ENABLED:  byte_select = BYTE_0_SELECTED;
      BYTE_1_ENABLED:  byte_select = BYTE_1_SELECTED;
      BYTE_2_ENABLED:  byte_select = BYTE_2_SELECTED;
      BYTE_3_ENABLED:  byte_select = BYTE_3_SELECTED;
      default:  byte_select = 2'bxx;
    endcase
    

  // --------------------------------------------------------------------
  //  word enable & select
  reg [1:0] word_enable;
  localparam   WORD_N_ENABLED  = 2'b00;
  localparam   WORD_0_ENABLED  = 2'b01;
  localparam   WORD_1_ENABLED  = 2'b10;
  
  reg word_select;
  localparam   WORD_0_SELECTED  = 1'b0;
  localparam   WORD_1_SELECTED  = 1'b1;
  localparam   WORD_X_SELECTED  = 1'b?;

  always @(*)
    casez( { lo_byte_if_i, wb_hi_sel_i, state } )
      { 1'b0, 4'b0011, STATE_PASS_THROUGH }:  word_enable = WORD_0_ENABLED;
      { 1'b0, 4'b1100, STATE_PASS_THROUGH }:  word_enable = WORD_1_ENABLED;
      { 1'b0, 4'b0001, STATE_PASS_THROUGH }:  word_enable = WORD_0_ENABLED;
      { 1'b0, 4'b0010, STATE_PASS_THROUGH }:  word_enable = WORD_0_ENABLED;
      { 1'b0, 4'b0100, STATE_PASS_THROUGH }:  word_enable = WORD_1_ENABLED;
      { 1'b0, 4'b1000, STATE_PASS_THROUGH }:  word_enable = WORD_1_ENABLED;
            
      { 1'b0, 4'b1111, STATE_PASS_THROUGH }:  word_enable = WORD_0_ENABLED;
      { 1'b0, 4'b1111, STATE_1_MORE_CHUNK }:  word_enable = WORD_1_ENABLED;
      
      { 1'b1, 4'b????, STATE_DONT_CARE }:     word_enable = WORD_N_ENABLED;
      default:                                word_enable = WORD_N_ENABLED;
    endcase

  always @(*)
    case( word_enable )
      WORD_0_ENABLED: word_select = WORD_0_SELECTED;
      WORD_1_ENABLED: word_select = WORD_1_SELECTED;
      default:        word_select = 1'bx;
    endcase
    

  // --------------------------------------------------------------------
  //  write mux
  reg [1:0] byte_write_mux_enc;
  
  always @(*)
    casez( {lo_byte_if_i, byte_select, word_select} )
      { 1'b1, BYTE_0_SELECTED, WORD_X_SELECTED }: byte_write_mux_enc = 2'b00;
      { 1'b1, BYTE_1_SELECTED, WORD_X_SELECTED }: byte_write_mux_enc = 2'b01;
      { 1'b1, BYTE_2_SELECTED, WORD_X_SELECTED }: byte_write_mux_enc = 2'b10;
      { 1'b1, BYTE_3_SELECTED, WORD_X_SELECTED }: byte_write_mux_enc = 2'b11;
      { 1'b0, BYTE_X_SELECTED, WORD_0_SELECTED }: byte_write_mux_enc = 2'b00;
      { 1'b0, BYTE_X_SELECTED, WORD_1_SELECTED }: byte_write_mux_enc = 2'b10;
      default:                                    byte_write_mux_enc = 2'b00;
    endcase
  
  reg [7:0] byte_write_mux;

  always @(*)
    case( byte_write_mux_enc )
      2'b00:    byte_write_mux = wb_hi_dat_i[7:0];
      2'b01:    byte_write_mux = wb_hi_dat_i[15:8];
      2'b10:    byte_write_mux = wb_hi_dat_i[23:16];
      2'b11:    byte_write_mux = wb_hi_dat_i[31:24];
      default:  byte_write_mux = wb_hi_dat_i[7:0];
    endcase
    
  reg [7:0] word_write_mux;

  always @(*)
    case( word_select )
      WORD_0_SELECTED:  word_write_mux = wb_hi_dat_i[15:8];
      WORD_1_SELECTED:  word_write_mux = wb_hi_dat_i[31:24];
      default:          word_write_mux = wb_hi_dat_i[15:8];
    endcase
    
    
  // --------------------------------------------------------------------
  //  read buffer & bypass mux 
  
  // low side input mux
  wire [7:0] read_word_lo_mux = wb_lo_dat_i[7:0];
  wire [7:0] read_word_hi_mux = ( word_enable[0] | word_enable[1] )? wb_lo_dat_i[15:8] : wb_lo_dat_i[7:0];
  
  reg [31:0] read_buffer;
  
  wire read_buffer_0_enable = (byte_enable[0] | word_enable[0]) & ~wb_hi_we_i;
  wire read_buffer_1_enable = (byte_enable[1] | word_enable[0]) & ~wb_hi_we_i;
  wire read_buffer_2_enable = (byte_enable[2] | word_enable[1]) & ~wb_hi_we_i;
  wire read_buffer_3_enable = (byte_enable[3] | word_enable[1]) & ~wb_hi_we_i;
  
  always @(posedge wb_hi_clk_i)
    if( read_buffer_0_enable )
      read_buffer[7:0] <= read_word_lo_mux;
      
  always @(posedge wb_hi_clk_i)
    if( read_buffer_1_enable )
      read_buffer[15:8] <= read_word_hi_mux;
      
  always @(posedge wb_hi_clk_i)
    if( read_buffer_2_enable )
      read_buffer[23:16] <= read_word_lo_mux;
      
  always @(posedge wb_hi_clk_i)
    if( read_buffer_3_enable )
      read_buffer[31:24] <= read_word_hi_mux;
      
  wire [31:0] read_buffer_mux;
  
  // bypass read mux
  assign read_buffer_mux[7:0]   = read_buffer_0_enable ? read_word_lo_mux : read_buffer[7:0];
  assign read_buffer_mux[15:8]  = read_buffer_1_enable ? read_word_hi_mux : read_buffer[15:8];
  assign read_buffer_mux[23:16] = read_buffer_2_enable ? read_word_lo_mux : read_buffer[23:16];
  assign read_buffer_mux[31:24] = read_buffer_3_enable ? read_word_hi_mux : read_buffer[31:24];
      
      
  // --------------------------------------------------------------------
  //  misc logic
  wire [1:0] lo_addr_bits;
  assign lo_addr_bits = ( |byte_enable ) ? byte_select : { word_select, 1'b0 };
  
  wire all_done = ( ~(|state_enc) & (state == STATE_PASS_THROUGH) ) |
                  ( |state_enc & (state == STATE_1_MORE_CHUNK) );
                  
  reg [1:0] wb_lo_sel_r;                                  
  always @(*)
    casez( { lo_byte_if_i, wb_hi_sel_i, state } )      
      { 1'b0, 4'b0001, STATE_PASS_THROUGH }:  wb_lo_sel_r = 2'b01;
      { 1'b0, 4'b0010, STATE_PASS_THROUGH }:  wb_lo_sel_r = 2'b10;
      { 1'b0, 4'b0100, STATE_PASS_THROUGH }:  wb_lo_sel_r = 2'b01;
      { 1'b0, 4'b1000, STATE_PASS_THROUGH }:  wb_lo_sel_r = 2'b10;
      default:                                wb_lo_sel_r = 2'b11;
    endcase
    

    
  // --------------------------------------------------------------------
  //  output port assignments
  assign wb_hi_dat_o = read_buffer_mux;
  assign wb_hi_err_o = (wb_lo_err_i | state_enc_error) & wb_hi_stb_i & wb_hi_cyc_i;
  assign wb_hi_rty_o = wb_lo_rty_i;
  assign wb_hi_ack_o = all_done & wb_hi_stb_i & wb_hi_cyc_i & wb_lo_ack_i;
  
  assign wb_lo_adr_o = { wb_hi_adr_i[31:2], lo_addr_bits };
  assign wb_lo_clk_o = wb_hi_clk_i;
  assign wb_lo_rst_o = wb_hi_rst_i;
  assign wb_lo_cyc_o = wb_hi_cyc_i;
  assign wb_lo_stb_o = wb_hi_stb_i;
  assign wb_lo_we_o  = wb_hi_we_i & wb_hi_stb_i & wb_hi_cyc_i;
  assign wb_lo_dat_o = {word_write_mux, byte_write_mux};
  assign wb_lo_sel_o = wb_lo_sel_r;
  

endmodule


