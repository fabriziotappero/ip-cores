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


module tb_dut(
                input tb_clk,
                input tb_rst
              );


  wire        wb_hi_clk = tb_clk;
  wire        wb_hi_rst = tb_rst;

  wire [31:0] wb_hi_dat_i, wb_hi_dat_o;
  wire [31:0] wb_hi_adr_o;
  wire        wb_hi_cyc_o, wb_hi_stb_o;
  wire        wb_hi_we_o;
  wire [ 3:0] wb_hi_sel_o;
  wire        wb_hi_ack_i, wb_hi_err_i, wb_hi_rty_i;

  wire        wb_lo_clk_o;
  wire        wb_lo_rst_o;

  wire [15:0] wb_lo_dat_i, wb_lo_dat_o;
  wire [31:0] wb_lo_adr_o;
  wire        wb_lo_cyc_o, wb_lo_stb_o;
  wire        wb_lo_we_o;
  wire [1:0]  wb_lo_sel_o;
  wire        wb_lo_ack_i, wb_lo_err_i, wb_lo_rty_i;
  wire        lo_byte_if_i;


  // --------------------------------------------------------------------
  //  wb_hi_master_model
  wb_master_model wbm(
                        .clk(wb_hi_clk),
                        .rst(wb_hi_rst),
                        .adr(wb_hi_adr_o),
                        .din(wb_hi_dat_i),
                        .dout(wb_hi_dat_o),
                        .cyc(wb_hi_cyc_o),
                        .stb(wb_hi_stb_o),
                        .we(wb_hi_we_o),
                        .sel(wb_hi_sel_o),
                        .ack(wb_hi_ack_i),
                        .err(wb_hi_err_i),
                        .rty(wb_hi_rty_i)
                      );


  // --------------------------------------------------------------------
  //  wb_hi_size_bridge
  wb_size_bridge i_wb_size_bridge(
                                    .wb_hi_clk_i(wb_hi_clk),
                                    .wb_hi_rst_i(wb_hi_rst),
                                    .wb_hi_dat_o(wb_hi_dat_i),
                                    .wb_hi_dat_i(wb_hi_dat_o),
                                    .wb_hi_adr_i(wb_hi_adr_o),
                                    .wb_hi_cyc_i(wb_hi_cyc_o),
                                    .wb_hi_we_i(wb_hi_we_o),
                                    .wb_hi_stb_i(wb_hi_stb_o),
                                    .wb_hi_sel_i(wb_hi_sel_o),
                                    .wb_hi_ack_o(wb_hi_ack_i),
                                    .wb_hi_err_o(wb_hi_err_i),
                                    .wb_hi_rty_o(wb_hi_rty_i),
  
                                    .wb_lo_clk_o(wb_lo_clk_o),
                                    .wb_lo_rst_o(wb_lo_rst_o),
                                    .wb_lo_dat_o(wb_lo_dat_o),
                                    .wb_lo_dat_i(wb_lo_dat_i),
                                    .wb_lo_adr_o(wb_lo_adr_o),
                                    .wb_lo_cyc_o(wb_lo_cyc_o),
                                    .wb_lo_we_o(wb_lo_we_o),
                                    .wb_lo_stb_o(wb_lo_stb_o),
                                    .wb_lo_sel_o(wb_lo_sel_o),
                                    .wb_lo_ack_i(wb_lo_ack_i),
                                    .wb_lo_err_i(wb_lo_err_i),
                                    .wb_lo_rty_i(wb_lo_rty_i),
                                    .lo_byte_if_i(lo_byte_if_i)
                                  );
  
  
  // --------------------------------------------------------------------
  //  wb_slave_model
  
  wire slave_08_bit_hit = (wb_lo_adr_o[31:24] == 8'h60) & wb_lo_cyc_o;
  
  wire [15:0] slave_08_bit_dat_o;
  wire [15:0] slave_16_bit_dat_o;
  
  assign wb_lo_dat_i[15:0] = slave_08_bit_hit ? slave_08_bit_dat_o : slave_16_bit_dat_o;
  
  wire slave_08_bit_ack_o;
  wire slave_08_bit_err_o; 
  wire slave_08_bit_rty_o; 
  
  wire slave_16_bit_ack_o;
  wire slave_16_bit_err_o; 
  wire slave_16_bit_rty_o; 
  
  assign wb_lo_ack_i = slave_08_bit_hit ? slave_08_bit_ack_o : slave_16_bit_ack_o;
  assign wb_lo_err_i = slave_08_bit_hit ? slave_08_bit_err_o : slave_16_bit_err_o;
  assign wb_lo_rty_i = slave_08_bit_hit ? slave_08_bit_rty_o : slave_16_bit_rty_o;
  
  wire slave_08_bit_cyc_i = wb_lo_cyc_o & slave_08_bit_hit; 
  wire slave_08_bit_stb_i = wb_lo_stb_o & slave_08_bit_hit; 
  
  wire slave_16_bit_cyc_i = wb_lo_cyc_o & ~slave_08_bit_hit;
  wire slave_16_bit_stb_i = wb_lo_stb_o & ~slave_08_bit_hit; 
  
  assign lo_byte_if_i = slave_08_bit_hit;
  
  wb_slave_model #(.DWIDTH(8), .AWIDTH(5), .ACK_DELAY(2), .SLAVE_RAM_INIT( "wb_slave_08_bit.txt") )
  wb_slave_08_bit(
                    .clk_i(wb_lo_clk_o),
                    .rst_i(wb_lo_rst_o),
                    .dat_o(slave_08_bit_dat_o[7:0]),
                    .dat_i(wb_lo_dat_o[7:0]),
                    .adr_i(wb_lo_adr_o[4:0]),
                    .cyc_i(slave_08_bit_cyc_i),
                    .stb_i(slave_08_bit_stb_i),
                    .we_i(wb_lo_we_o),
                    .sel_i(wb_lo_sel_o[0]),
                    .ack_o(slave_08_bit_ack_o),
                    .err_o(slave_08_bit_err_o),
                    .rty_o(slave_08_bit_rty_o)
                  );
                  
  
  wb_slave_model #(.DWIDTH(16), .AWIDTH(5), .ACK_DELAY(2), .SLAVE_RAM_INIT( "wb_slave_16_bit.txt") )
  wb_slave_16_bit(
                    .clk_i(wb_lo_clk_o),
                    .rst_i(wb_lo_rst_o),
                    .dat_o(slave_16_bit_dat_o),
                    .dat_i(wb_lo_dat_o[15:0]),
                    .adr_i(wb_lo_adr_o[4:0]),
                    .cyc_i(slave_16_bit_cyc_i),
                    .stb_i(slave_16_bit_stb_i),
                    .we_i(wb_lo_we_o),
                    .sel_i(wb_lo_sel_o),
                    .ack_o(slave_16_bit_ack_o),
                    .err_o(slave_16_bit_err_o),
                    .rty_o(slave_16_bit_rty_o)
                  );
                

endmodule


