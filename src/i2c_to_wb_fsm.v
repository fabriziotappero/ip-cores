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
  i2c_to_wb_fsm
  (
    input         i2c_data,
    input         i2c_data_rise,
    input         i2c_data_fall,

    input         i2c_clk,
    input         i2c_clk_rise,
    input         i2c_clk_fall,

    input         i2c_r_w_bit,
    input         i2c_ack_out,
    output        i2c_ack_done,

    output        tip_addr_byte,
    output        tip_read_byte,
    output        tip_write_byte,
    output        tip_wr_ack,
    output        tip_rd_ack,
    output        tip_addr_ack,

    output  [7:0] state_out,
    output        i2c_error,

    input         wb_clk_i,
    input         wb_rst_i
  );

  // --------------------------------------------------------------------
  //  wires
  wire xmt_byte_done;

  wire tip_ack;


  // --------------------------------------------------------------------
  //  start & stop & ack

  wire start_detected = i2c_data_fall & i2c_clk;
  wire stop_detected  = i2c_data_rise & i2c_clk;


  // --------------------------------------------------------------------
  //  state machine

  localparam   STATE_IDLE       = 8'b00000001;
  localparam   STATE_ADDR_BYTE  = 8'b00000010;
  localparam   STATE_ADDR_ACK   = 8'b00000100;
  localparam   STATE_WRITE      = 8'b00001000;
  localparam   STATE_WR_ACK     = 8'b00010000;
  localparam   STATE_READ       = 8'b00100000;
  localparam   STATE_RD_ACK     = 8'b01000000;
  localparam   STATE_ERROR      = 8'b10000000;

  reg [7:0] state;
  reg [7:0] next_state;

  always @(posedge wb_clk_i or posedge wb_rst_i)
    if(wb_rst_i)
      state <= STATE_IDLE;
    else
      state <= next_state;

  always @(*)
    case( state )
      STATE_IDLE:       if( start_detected )
                          next_state = STATE_ADDR_BYTE;
                        else
                          next_state = STATE_IDLE;

      STATE_ADDR_BYTE:  if( xmt_byte_done )
                          next_state = STATE_ADDR_ACK;
                        else if( stop_detected )
                          next_state = STATE_ERROR;
                        else
                          next_state = STATE_ADDR_BYTE;

      STATE_ADDR_ACK:   if(i2c_ack_out)
                          next_state = STATE_IDLE;
                        else
                          if( i2c_ack_done )
                            if( i2c_r_w_bit )
                              next_state = STATE_READ;
                            else
                              next_state = STATE_WRITE;
                          else if( start_detected | stop_detected )
                            next_state = STATE_ERROR;
                          else
                            next_state = STATE_ADDR_ACK;

      STATE_WRITE:      if( xmt_byte_done )
                          next_state = STATE_WR_ACK;
                        else if( start_detected )
                          next_state = STATE_ADDR_BYTE;
                        else if( stop_detected )
                          next_state = STATE_IDLE;
                        else
                          next_state = STATE_WRITE;

      STATE_WR_ACK:     if( i2c_ack_done )
                          next_state = STATE_WRITE;
                        else if( start_detected | stop_detected )
                          next_state = STATE_ERROR;
                        else
                          next_state = STATE_WR_ACK;

      STATE_READ:       if( xmt_byte_done )
                          next_state = STATE_RD_ACK;
                        else if( start_detected )
                          next_state = STATE_ADDR_BYTE;
                        else if( stop_detected )
                          next_state = STATE_IDLE;
                        else
                          next_state = STATE_READ;

      STATE_RD_ACK:     if( i2c_ack_done )
                          if(i2c_data)
                            next_state = STATE_IDLE;
                          else
                            next_state = STATE_READ;
                        else if( start_detected | stop_detected )
                          next_state = STATE_ERROR;
                        else
                          next_state = STATE_RD_ACK;

      STATE_ERROR:      next_state = STATE_IDLE;

      default:          next_state = STATE_ERROR;
    endcase


  // --------------------------------------------------------------------
  //  bit counter
  reg [3:0] bit_count;

  assign  xmt_byte_done = (bit_count == 4'h7) & i2c_clk_rise;
  assign  tip_ack       = (bit_count == 4'h8);
  assign  i2c_ack_done  = tip_ack & i2c_clk_rise;

  always @(posedge wb_clk_i)
    if( wb_rst_i | i2c_ack_done | start_detected )
      bit_count <= 4'hf;
    else if( i2c_clk_fall )
      bit_count <= bit_count + 1;


  // --------------------------------------------------------------------
  //  debug
  wire i2c_start_error = (state == STATE_ADDR_BYTE) & start_detected;


  // --------------------------------------------------------------------
  //  outputs

  assign state_out = state;

  assign  tip_addr_byte   = (state == STATE_ADDR_BYTE);
  assign  tip_addr_ack    = (state == STATE_ADDR_ACK);
  assign  tip_read_byte   = (state == STATE_READ);
  assign  tip_write_byte  = tip_addr_byte               | (state == STATE_WRITE);
  assign  tip_wr_ack      = tip_addr_ack                | (state == STATE_WR_ACK);
  assign  tip_rd_ack      = (state == STATE_RD_ACK);

  assign i2c_error = (state == STATE_ERROR) | i2c_start_error;

endmodule


