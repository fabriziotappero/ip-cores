//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ps2_io_ctrl.v                                               ////
////                                                              ////
////  This file is part of the "ps2" project                      ////
////  http://www.opencores.org/cores/ps2/                         ////
////                                                              ////
////  Author(s):                                                  ////
////      - mihad@opencores.org                                   ////
////      - Miha Dolenc                                           ////
////                                                              ////
////  All additional information is avaliable in the README.txt   ////
////  file.                                                       ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Miha Dolenc, mihad@opencores.org          ////
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
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.1.1.1  2002/02/18 16:16:56  mihad
// Initial project import - working
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module ps2_io_ctrl
(
    clk_i,
    rst_i,
    ps2_ctrl_clk_en_i_,
    ps2_ctrl_data_en_i_,
    ps2_clk_pad_i,
    ps2_clk_pad_oe_o,
    ps2_data_pad_oe_o,
    inhibit_if_i,
    ps2_ctrl_clk_o
);

input clk_i,
      rst_i,
      ps2_ctrl_clk_en_i_,
      ps2_ctrl_data_en_i_,
      ps2_clk_pad_i,
      inhibit_if_i ;

output ps2_clk_pad_oe_o,
       ps2_data_pad_oe_o,
       ps2_ctrl_clk_o ;

reg    ps2_clk_pad_oe_o,
       ps2_data_pad_oe_o ;

always@(posedge clk_i or posedge rst_i)
begin
    if ( rst_i )
    begin
        ps2_clk_pad_oe_o  <= #1 1'b0 ;
        ps2_data_pad_oe_o <= #1 1'b0 ;
    end
    else
    begin
        ps2_clk_pad_oe_o  <= #1 !ps2_ctrl_clk_en_i_ || inhibit_if_i ;
        ps2_data_pad_oe_o <= #1 !ps2_ctrl_data_en_i_ ;
    end
end

reg inhibit_if_previous ;
always@(posedge clk_i or posedge rst_i)
begin
    if ( rst_i )
        inhibit_if_previous <= #1 1'b1 ;
    else
        inhibit_if_previous <= #1 inhibit_if_i ;
end

assign ps2_ctrl_clk_o = ps2_clk_pad_i || ps2_clk_pad_oe_o && inhibit_if_previous ;
endmodule // ps2_io_ctrl
