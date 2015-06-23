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


`include "timescale.v"


module
  i2c_to_wb_if
  #(
    parameter DW = 32,
    parameter AW = 8
  )
  (
    input                   i2c_data,
    input                   i2c_ack_done,
    input       [7:0]       i2c_byte_in,
    output reg  [7:0]       i2c_byte_out,
    output                  i2c_parallel_load,
    input                   tip_wr_ack,
    input                   tip_rd_ack,
    input                   tip_addr_ack,

    input       [(DW-1):0]  wb_data_i,
    output      [(DW-1):0]  wb_data_o,
    output      [(AW-1):0]  wb_addr_o,
    output  reg [3:0]       wb_sel_o,
    output                  wb_we_o,
    output                  wb_cyc_o,
    output                  wb_stb_o,
    input                   wb_ack_i,
    input                   wb_err_i,
    input                   wb_rty_i,

    input                   wb_clk_i,
    input                   wb_rst_i
  );


  // --------------------------------------------------------------------
  //  wires
  wire i2c_r_w_bit = i2c_byte_in[0];


  // --------------------------------------------------------------------
  //  state machine

  localparam   STATE_IDLE       = 5'b00001;
  localparam   STATE_WRITE      = 5'b00010;
  localparam   STATE_WRITE_WAIT = 5'b00100;
  localparam   STATE_READ       = 5'b01000;
  localparam   STATE_READ_WAIT  = 5'b10000;

  reg [4:0] state;
  reg [4:0] next_state;

  always @(posedge wb_clk_i or posedge wb_rst_i)
    if(wb_rst_i)
      state <= STATE_IDLE;
    else
      state <= next_state;

  always @(*)
    case( state )
      STATE_IDLE:       if( tip_addr_ack & i2c_ack_done )
                          if(i2c_r_w_bit)
                            next_state = STATE_READ;
                          else
                            next_state = STATE_WRITE_WAIT;
                        else
                          next_state = STATE_IDLE;

      STATE_WRITE:      if( wb_ack_i )
                          next_state = STATE_WRITE_WAIT;
                        else
                          next_state = STATE_WRITE;

      STATE_WRITE_WAIT: if( tip_addr_ack )
                          next_state = STATE_IDLE;
                        else
                          if( tip_wr_ack & i2c_ack_done )
                            next_state = STATE_WRITE;
                          else  
                            next_state = STATE_WRITE_WAIT;

      STATE_READ:       if( wb_ack_i )
                          next_state = STATE_READ_WAIT;
                        else
                          next_state = STATE_READ;

      STATE_READ_WAIT:  if( tip_addr_ack )
                          next_state = STATE_IDLE;
                        else
                          if( tip_rd_ack & i2c_ack_done )
                            if(i2c_data)
                              next_state = STATE_IDLE;
                            else  
                              next_state = STATE_READ;
                          else  
                            next_state = STATE_READ_WAIT;

      default:          next_state = STATE_IDLE;
    endcase


  // --------------------------------------------------------------------
  //  wishbone offset address

  reg [7:0] i2c_offset_r;
  always @(posedge wb_clk_i)
    if( tip_addr_ack )
      if(i2c_r_w_bit)
        i2c_offset_r <= 8'h00;
      else
        i2c_offset_r <= 8'hff;
    else if( i2c_ack_done )
      i2c_offset_r <= i2c_offset_r + 1;


  // --------------------------------------------------------------------
  //  byte lane select

  always @(*)
    case( i2c_offset_r[1:0] )
      2'b00:  wb_sel_o = 4'b0001;
      2'b01:  wb_sel_o = 4'b0010;
      2'b10:  wb_sel_o = 4'b0100;
      2'b11:  wb_sel_o = 4'b1000;
    endcase

  always @(*)
    case( wb_sel_o )
      4'b0001:  i2c_byte_out = wb_data_i[7:0];
      4'b0010:  i2c_byte_out = wb_data_i[15:8];
      4'b0100:  i2c_byte_out = wb_data_i[23:16];
      4'b1000:  i2c_byte_out = wb_data_i[31:24];
      default:  i2c_byte_out = wb_data_i[7:0];
    endcase


  // --------------------------------------------------------------------
  //  outputs
  
  assign i2c_parallel_load = (state == STATE_READ);

  assign wb_addr_o[7:0] = i2c_offset_r;
  assign wb_data_o      = {i2c_byte_in, i2c_byte_in, i2c_byte_in, i2c_byte_in};
  assign wb_cyc_o       = (state == STATE_WRITE) | (state == STATE_READ);
  assign wb_stb_o       = (state == STATE_WRITE) | (state == STATE_READ);
  assign wb_we_o        = (state == STATE_WRITE);


endmodule

