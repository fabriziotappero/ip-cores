//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Wishbone Interface for DES coprocesor                       ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Javier Castillo, jcastilo@opencores.org               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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
//
`include "timescale.v"

module des_top(clk,reset,wb_stb_i,wb_dat_o,wb_dat_i,wb_ack_o,
               wb_adr_i,wb_we_i,wb_cyc_i,wb_sel_i);

input         clk;
input         reset;
input         wb_stb_i;
output [31:0] wb_dat_o;
input  [31:0] wb_dat_i;
output        wb_ack_o;
input  [7:0]  wb_adr_i;
input         wb_we_i;
input         wb_cyc_i;
input  [3:0]  wb_sel_i;

reg  [31:0]  wb_dat_o;
reg          wb_ack_o;

wire [63:0]  data_i;
reg  [63:0]  data_o;
wire         ready_i;
reg  [63:0]  key_o;


reg  [31:0]  control_reg;
reg  [63:0]  cypher_data_reg;

des des(.clk(clk),
        .reset(~control_reg[0]),
		.load_i(control_reg[1]),
		.decrypt_i(control_reg[3]),
		.ready_o(ready_i),
		.data_o(data_i),
		.data_i(data_o),
		.key_i(key_o)
	   );

always @(posedge clk or posedge reset)
begin
     if(reset==1)
     begin
       wb_ack_o<=#1 0;
       wb_dat_o<=#1 0;
       control_reg <= #1 32'h60;
       cypher_data_reg <= #1 64'h0;
       key_o <= #1 32'h0;
       data_o <= #1 32'h0;
     end
     else
     begin

        control_reg[31:4]<= #1 28'h6;	   	   

       if(ready_i)
       begin
        control_reg[2] <= #1 1'b1;  
        cypher_data_reg <= #1 data_i;
       end
         
       if(wb_stb_i && wb_cyc_i && wb_we_i && ~wb_ack_o)
       begin
         wb_ack_o<=#1 1;
         case(wb_adr_i)
             8'h0:
             begin
                 //Writing control register
                 control_reg[3:0]<= #1 wb_dat_i[3:0];
             end
             8'h4:
              begin
                 data_o[63:32]<= #1 wb_dat_i;
             end                 
             8'h8:
             begin
                 data_o[31:0]<= #1 wb_dat_i;
             end                 
             8'hC:
             begin
                 key_o[63:32]<= #1 wb_dat_i;
             end                 
             8'h10:
             begin
                 key_o[31:0]<= #1 wb_dat_i;
             end                 
         endcase
       end
       else if(wb_stb_i && wb_cyc_i && ~wb_we_i && ~wb_ack_o)
       begin
           wb_ack_o<=#1 1;
           case(wb_adr_i)
             8'h0:
             begin
                 wb_dat_o<= #1 control_reg;
                 control_reg[2]<=1'b0;
             end
             8'h14:
             begin
                 wb_dat_o<= #1 cypher_data_reg[63:32];
             end
             8'h18:
             begin
                 wb_dat_o<= #1 cypher_data_reg[31:0];
             end
           endcase
       end
       else
       begin
           wb_ack_o<=#1 0;
           control_reg[1]<= #1 1'b0;
       end

     end
end


endmodule

