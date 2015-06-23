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


module tb_dut(
                input tb_clk,
                input tb_rst
              );


  // --------------------------------------------------------------------
  // test bench variables
  reg test_it;
  

  // --------------------------------------------------------------------
  // wires
  wire i2c_data;
  wire i2c_clk;
    
  
  // --------------------------------------------------------------------
  //  async_mem_master
	pullup p1(i2c_data); // pullup scl line
	pullup p2(i2c_clk); // pullup sda line
  
  i2c_master_model
    i2c(  
      .i2c_data(i2c_data),
      .i2c_clk(i2c_clk)
    );
    
    
  // --------------------------------------------------------------------
  //  i2c_to_wb_top
  wire i2c_data_out;
  wire i2c_clk_out;
  wire i2c_data_oe;
  wire i2c_clk_oe;
//   wire [31:0] wb_data_i = 32'hd4c3b2a1;
  wire [31:0] wb_data_i;
  wire [31:0] wb_data_o;
  wire [31:0] wb_addr_o;
  wire [3:0] wb_sel_o;
  wire wb_we_o;
  wire wb_cyc_o;
  wire wb_stb_o;
//   wire wb_ack_i = 1'b1;
//   wire wb_err_i = 1'b0;
//   wire wb_rty_i = 1'b0;
  wire wb_ack_i;
  wire wb_err_i;
  wire wb_rty_i;
  
  // tristate buffers
  assign i2c_data = i2c_data_oe ? i2c_data_out  : 1'bz;
  assign i2c_clk  = i2c_clk_oe  ? i2c_clk_out   : 1'bz;
    
  i2c_to_wb_top
    i_i2c_to_wb_top(
      .i2c_data_in(i2c_data),
      .i2c_clk_in(i2c_clk),
      .i2c_data_out(i2c_data_out),
      .i2c_clk_out(i2c_clk_out),
      .i2c_data_oe(i2c_data_oe),
      .i2c_clk_oe(i2c_clk_oe),
      
      .wb_data_i(wb_data_i),
      .wb_data_o(wb_data_o),
      .wb_addr_o(wb_addr_o[7:0]),
      .wb_sel_o(wb_sel_o),
      .wb_we_o(wb_we_o),
      .wb_cyc_o(wb_cyc_o),
      .wb_stb_o(wb_stb_o),
      .wb_ack_i(wb_ack_i),
      .wb_err_i(wb_err_i),
      .wb_rty_i(wb_rty_i),
          
      .wb_clk_i(tb_clk),
      .wb_rst_i(tb_rst)
  );
  
  
  // --------------------------------------------------------------------
  //  wb_slave_model
  wb_slave_model #(.DWIDTH(32), .AWIDTH(8), .ACK_DELAY(0), .SLAVE_RAM_INIT("wb_slave_32_bit.txt") )
    i_wb_slave_model(  
      .clk_i(tb_clk), 
      .rst_i(tb_rst), 
      .dat_o(wb_data_i), 
      .dat_i(wb_data_o), 
      .adr_i(wb_addr_o),
      .cyc_i(wb_cyc_o), 
      .stb_i(wb_stb_o), 
      .we_i(wb_we_o), 
      .sel_i(wb_sel_o),
      .ack_o(wb_ack_i), 
      .err_o(wb_err_i), 
      .rty_o(wb_rty_i) 
    );
    
  
  // --------------------------------------------------------------------
  //  glitch_generator 
  glitch_generator i_g1( i2c_data );
  glitch_generator i_g2( i2c_clk );
  
  
  // --------------------------------------------------------------------
  //  outputs
  
  
  
endmodule

