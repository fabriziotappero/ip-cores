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

module asram_if(
                  inout   [15:0]  sram_dq,    //  SRAM Data bus 16 Bits
                  output  [17:0]  sram_addr,  //  SRAM Address bus 18 Bits
                  output          sram_ub_n,  //  SRAM High-byte Data Mask
                  output          sram_lb_n,  //  SRAM Low-byte Data Mask
                  output          sram_we_n,  //  SRAM Write Enable
                  output          sram_ce_n,  //  SRAM Chip Enable
                  output          sram_oe_n,  //  SRAM Output Enable
                  input           wb_clk_i,   // WISHBONE interface
                  input           wb_rst_i,
                  input   [18:0]  wb_adr_i,
                  input   [31:0]  wb_dat_i,
                  input           wb_we_i,
                  input           wb_stb_i,
                  input           wb_cyc_i,
                  input   [3:0]   wb_sel_i,
                  output  [31:0]  wb_dat_o,
                  output          wb_ack_o
                );

                
  //---------------------------------------------------
  // wb_size_bridge  
  wire [15:0] wb_lo_dat_o;
  wire [31:0] wb_lo_adr_o;
  wire        wb_lo_cyc_o;
  wire        wb_lo_stb_o;
  wire        wb_lo_we_o;
  wire [1:0]  wb_lo_sel_o;
  wire        wb_lo_ack_i = 1'b1;
  wire        wb_lo_err_i = 1'b0;
  wire        wb_lo_rty_i = 1'b0;
  
  wb_size_bridge i_wb_size_bridge(
                                    .wb_hi_clk_i(wb_clk_i),
                                    .wb_hi_rst_i(wb_rst_i),
                                    .wb_hi_dat_o(wb_dat_o),
                                    .wb_hi_dat_i(wb_dat_i),
                                    .wb_hi_adr_i( {13'h0000, wb_adr_i} ),
                                    .wb_hi_cyc_i(wb_cyc_i),
                                    .wb_hi_stb_i(wb_stb_i),
                                    .wb_hi_we_i(wb_we_i),
                                    .wb_hi_sel_i(wb_sel_i),
                                    .wb_hi_ack_o(wb_ack_o),
                                    .wb_hi_err_o(),
                                    .wb_hi_rty_o(),
            
                                    .wb_lo_clk_o(),
                                    .wb_lo_rst_o(),
                                    .wb_lo_dat_i(sram_dq),
                                    .wb_lo_dat_o(wb_lo_dat_o),
                                    .wb_lo_adr_o(wb_lo_adr_o),
                                    .wb_lo_cyc_o(wb_lo_cyc_o),
                                    .wb_lo_stb_o(wb_lo_stb_o),
                                    .wb_lo_we_o(wb_lo_we_o),
                                    .wb_lo_sel_o(wb_lo_sel_o),
                                    .wb_lo_ack_i(wb_lo_ack_i),
                                    .wb_lo_err_i(wb_lo_err_i),
                                    .wb_lo_rty_i(wb_lo_rty_i),
                                    
                                    .lo_byte_if_i(1'b0)
                                  );
                
                
  //---------------------------------------------------
  // outputs  
  assign sram_dq    = wb_lo_we_o ? wb_lo_dat_o : 16'hzz;
  assign sram_addr  = wb_lo_adr_o[18:1];
  assign sram_ub_n  = ~wb_lo_sel_o[1];
  assign sram_lb_n  = ~wb_lo_sel_o[0];
  assign sram_we_n  = ~wb_lo_we_o;
  assign sram_ce_n  = 1'b0;
  assign sram_oe_n  = wb_lo_we_o;
                
  
endmodule


