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


module async_mem_if(  async_dq, async_addr, async_ub_n, async_lb_n,
                      async_we_n, async_ce_n, async_oe_n,
                      wb_clk_i, wb_rst_i, wb_adr_i, wb_dat_i,
                      wb_we_i, wb_stb_i, wb_cyc_i, wb_sel_i,
                      wb_dat_o, wb_ack_o,
                      ce_setup, op_hold, ce_hold,
                      big_endian_if_i, lo_byte_if_i
                  );

  parameter AW = 32;
  parameter DW = 8;

  inout   [(DW-1):0]  async_dq;
  output  [(AW-1):0]  async_addr;
  output              async_ub_n;
  output              async_lb_n;
  output              async_we_n;
  output              async_ce_n;
  output              async_oe_n;
  input           wb_clk_i;
  input           wb_rst_i;
  input   [31:0]  wb_adr_i;
  input   [31:0]  wb_dat_i;
  input           wb_we_i;
  input           wb_stb_i;
  input           wb_cyc_i;
  input   [3:0]   wb_sel_i;
  output  [31:0]  wb_dat_o;
  output          wb_ack_o;
  input [3:0]     ce_setup;
  input [3:0]     op_hold;  // do not set to zero.
  input [3:0]     ce_hold;
  input           big_endian_if_i;
  input           lo_byte_if_i;


  //---------------------------------------------------
  // big endian bridge

  wire [31:0] beb_wb_dat_i;
  assign beb_wb_dat_i[7:0]    = big_endian_if_i ? wb_dat_i[31:24]  : wb_dat_i[7:0];
  assign beb_wb_dat_i[15:8]   = big_endian_if_i ? wb_dat_i[23:16]  : wb_dat_i[15:8];
  assign beb_wb_dat_i[23:16]  = big_endian_if_i ? wb_dat_i[15:8]   : wb_dat_i[23:16];
  assign beb_wb_dat_i[31:24]  = big_endian_if_i ? wb_dat_i[7:0]    : wb_dat_i[31:24];

  wire [31:0] beb_wb_dat_o;
  assign wb_dat_o[7:0]    = big_endian_if_i ? beb_wb_dat_o[31:24]  : beb_wb_dat_o[7:0];
  assign wb_dat_o[15:8]   = big_endian_if_i ? beb_wb_dat_o[23:16]  : beb_wb_dat_o[15:8];
  assign wb_dat_o[23:16]  = big_endian_if_i ? beb_wb_dat_o[15:8]   : beb_wb_dat_o[23:16];
  assign wb_dat_o[31:24]  = big_endian_if_i ? beb_wb_dat_o[7:0]    : beb_wb_dat_o[31:24];

  wire [3:0] beb_wb_sel_i;
  assign beb_wb_sel_i[0] = big_endian_if_i ? wb_sel_i[3] : wb_sel_i[0];
  assign beb_wb_sel_i[1] = big_endian_if_i ? wb_sel_i[2] : wb_sel_i[1];
  assign beb_wb_sel_i[2] = big_endian_if_i ? wb_sel_i[1] : wb_sel_i[2];
  assign beb_wb_sel_i[3] = big_endian_if_i ? wb_sel_i[0] : wb_sel_i[3];


  //---------------------------------------------------
  // wb_size_bridge
  wire [15:0] wb_lo_dat_o;
  wire [15:0] wb_lo_dat_i;
  wire [31:0] wb_lo_adr_o;
  wire        wb_lo_cyc_o;
  wire        wb_lo_stb_o;
  wire        wb_lo_we_o;
  wire [1:0]  wb_lo_sel_o;
  wire        wb_lo_ack_i;
  wire        wb_lo_err_i = 1'b0;
  wire        wb_lo_rty_i = 1'b0;


  wb_size_bridge i_wb_size_bridge(
                                    .wb_hi_clk_i(wb_clk_i),
                                    .wb_hi_rst_i(wb_rst_i),
                                    .wb_hi_dat_o(beb_wb_dat_o),
                                    .wb_hi_dat_i(beb_wb_dat_i),
                                    .wb_hi_adr_i( wb_adr_i ),
                                    .wb_hi_cyc_i(wb_cyc_i),
                                    .wb_hi_stb_i(wb_stb_i),
                                    .wb_hi_we_i(wb_we_i),
                                    .wb_hi_sel_i(beb_wb_sel_i),
                                    .wb_hi_ack_o(wb_ack_o),
                                    .wb_hi_err_o(),
                                    .wb_hi_rty_o(),

                                    .wb_lo_clk_o(),
                                    .wb_lo_rst_o(),
                                    .wb_lo_dat_i(wb_lo_dat_i),
                                    .wb_lo_dat_o(wb_lo_dat_o),
                                    .wb_lo_adr_o(wb_lo_adr_o),
                                    .wb_lo_cyc_o(wb_lo_cyc_o),
                                    .wb_lo_stb_o(wb_lo_stb_o),
                                    .wb_lo_we_o(wb_lo_we_o),
                                    .wb_lo_sel_o(wb_lo_sel_o),
                                    .wb_lo_ack_i(wb_lo_ack_i),
                                    .wb_lo_err_i(wb_lo_err_i),
                                    .wb_lo_rty_i(wb_lo_rty_i),

                                    .lo_byte_if_i(lo_byte_if_i)
                                  );


  // --------------------------------------------------------------------
  //  state machine inputs

  wire zero_ce_setup  = (ce_setup == 4'h0);
  wire zero_ce_hold   = (ce_hold  == 4'h0);
  wire wait_for_counter;


  // --------------------------------------------------------------------
  //  state machine

  localparam   STATE_DONT_CARE  = 4'b????;
  localparam   STATE_IDLE       = 4'b0001;
  localparam   STATE_CE_SETUP   = 4'b0010;
  localparam   STATE_OP_HOLD    = 4'b0100;
  localparam   STATE_CE_HOLD    = 4'b1000;

  reg [3:0] state;
  reg [3:0] next_state;

  always @(posedge wb_clk_i or posedge wb_rst_i)
    if(wb_rst_i)
      state <= STATE_IDLE;
    else
      state <= next_state;

  always @(*)
    case( state )
      STATE_IDLE:     if( wb_stb_i & wb_cyc_i )
                        if( zero_ce_setup )
                          next_state = STATE_OP_HOLD;
                        else
                          next_state = STATE_CE_SETUP;
                      else
                        next_state = STATE_IDLE;

      STATE_CE_SETUP: if( wait_for_counter )
                        next_state = STATE_CE_SETUP;
                      else
                        next_state = STATE_OP_HOLD;

      STATE_OP_HOLD:  if( wait_for_counter )
                        next_state = STATE_OP_HOLD;
                      else
                        if( zero_ce_hold )
                          next_state = STATE_IDLE;
                        else
                          next_state = STATE_CE_HOLD;

      STATE_CE_HOLD:  if( wait_for_counter )
                        next_state = STATE_CE_HOLD;
                      else
                        next_state = STATE_IDLE;

      default:        next_state = STATE_IDLE;
    endcase


  // --------------------------------------------------------------------
  //  state machine outputs

  wire assert_ce = (state != STATE_IDLE);
  wire assert_op = (state == STATE_OP_HOLD);

  assign wb_lo_ack_i =  ( (state == STATE_OP_HOLD) & ~wait_for_counter & zero_ce_hold) |
                        ( (state == STATE_CE_HOLD) & ~wait_for_counter );


  //---------------------------------------------------
  // async_dq_buffer
  reg [(DW-1):0] async_dq_buffer;
  wire async_dq_buffer_en  = (state == STATE_OP_HOLD);

  always @(posedge wb_clk_i)
    if(async_dq_buffer_en)
      async_dq_buffer <= async_dq;
    else
      async_dq_buffer <= async_dq_buffer;
      

  //---------------------------------------------------
  // bypass_mux

  wire  bypass_mux_en = (state == STATE_OP_HOLD) & zero_ce_hold;
  wire [(DW-1):0] bypass_mux;

  assign bypass_mux = bypass_mux_en ? async_dq : async_dq_buffer;


  // --------------------------------------------------------------------
  //  wait counter mux
  reg  [3:0] counter_mux;

  always @(*)
    case( next_state )
      STATE_CE_SETUP: counter_mux = ce_setup;
      STATE_OP_HOLD:  counter_mux = op_hold;
      STATE_CE_HOLD:  counter_mux = ce_hold;
      default:        counter_mux = 4'bxxxx;
    endcase


  // --------------------------------------------------------------------
  //  wait counter
  reg   [3:0] counter;
  wire        counter_load = ~(state == next_state);

  always @(posedge wb_clk_i)
    if( counter_load )
      counter <= counter_mux - 1'b1;
    else
      counter <= counter - 1'b1;

  assign wait_for_counter = (counter != 4'h0);


  //---------------------------------------------------
  // outputs

  generate
    if( DW == 16 )
      begin
        assign async_dq    = wb_lo_we_o ? wb_lo_dat_o : 16'hzz;
        assign async_addr  = wb_lo_adr_o[AW:1];
        assign wb_lo_dat_i = bypass_mux;
      end
    else
      begin
        assign async_dq    = wb_lo_we_o ? wb_lo_dat_o : 8'hz;
        assign async_addr  = wb_lo_adr_o[(AW-1):0];
        assign wb_lo_dat_i = {8'h00, bypass_mux};
      end
  endgenerate

  assign async_ub_n  = ~wb_lo_sel_o[1];
  assign async_lb_n  = ~wb_lo_sel_o[0];
  assign async_we_n  = ~( wb_lo_we_o & assert_op );
  assign async_ce_n  = ~( wb_stb_i & wb_cyc_i & assert_ce );
  assign async_oe_n  = ~( ~wb_lo_we_o & assert_op );


endmodule


