//////////////////////////////////////////////////////////////////////
////                                                              ////
////  $Id: wb_regfile.v,v 1.3 2008-07-26 19:15:32 hharte Exp $    ////
////  wb_regfile.v - Small Wishbone register file for testing     ////
////                                                              ////
////  This file is part of the Wishbone LPC Bridge project        ////
////  http://www.opencores.org/projects/wb_lpc/                   ////
////                                                              ////
////  Author:                                                     ////
////      - Howard M. Harte (hharte@opencores.org)                ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 Howard M. Harte                           ////
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

module wb_regfile (clk_i, nrst_i, wb_adr_i, wb_dat_o, wb_dat_i, wb_sel_i, wb_we_i,
                   wb_stb_i, wb_cyc_i, wb_ack_o, wb_err_o, ws_i, datareg0, datareg1);

    input          clk_i;
    input          nrst_i;
    input    [3:0] wb_adr_i;
    output reg [31:0] wb_dat_o;
    input   [31:0] wb_dat_i;
    input    [3:0] wb_sel_i;
    input          wb_we_i;
    input          wb_stb_i;
    input          wb_cyc_i;
    output reg     wb_ack_o;
    output         wb_err_o;
    input    [7:0] ws_i;	 
    output  [31:0] datareg0;
    output  [31:0] datareg1;
    reg      [7:0] waitstate;

    //
    // generate wishbone register bank writes
    wire wb_acc = wb_cyc_i & wb_stb_i;    // WISHBONE access
    wire wb_wr  = wb_acc & wb_we_i;       // WISHBONE write access

    reg [7:0]   datareg0_0;
    reg [7:0]   datareg0_1;
    reg [7:0]   datareg0_2;
    reg [7:0]   datareg0_3;

    reg [7:0]   datareg1_0;
    reg [7:0]   datareg1_1;
    reg [7:0]   datareg1_2;
    reg [7:0]   datareg1_3;

    always @(posedge clk_i or negedge nrst_i)
        if (~nrst_i)                // reset registers
            begin
                datareg0_0 <= 8'h00;
                datareg0_1 <= 8'h01;
                datareg0_2 <= 8'h02;
                datareg0_3 <= 8'h03;
                datareg1_0 <= 8'h10;
                datareg1_1 <= 8'h11;
                datareg1_2 <= 8'h12;
                datareg1_3 <= 8'h13;
                wb_ack_o <= 1'b0;
                waitstate <= 4'b0;
					 wb_dat_o <= 32'h00000000;
            end
        else if(wb_wr)          // wishbone write cycle
            case (wb_sel_i)
                4'b0000:
                    case (wb_adr_i)         // synopsys full_case parallel_case
                        4'b0000: datareg0_0 <= wb_dat_i[7:0];
                        4'b0001: datareg0_1 <= wb_dat_i[7:0];
                        4'b0010: datareg0_2 <= wb_dat_i[7:0];
                        4'b0011: datareg0_3 <= wb_dat_i[7:0];
                        4'b0100: datareg1_0 <= wb_dat_i[7:0];
                        4'b0101: datareg1_1 <= wb_dat_i[7:0];
                        4'b0110: datareg1_2 <= wb_dat_i[7:0];
                        4'b0111: datareg1_3 <= wb_dat_i[7:0];
                    endcase
                4'b0001:
                    case (wb_adr_i)         // synopsys full_case parallel_case
                        4'b0000: datareg0_0 <= wb_dat_i[7:0];
                        4'b0001: datareg0_1 <= wb_dat_i[7:0];
                        4'b0010: datareg0_2 <= wb_dat_i[7:0];
                        4'b0011: datareg0_3 <= wb_dat_i[7:0];
                        4'b0100: datareg1_0 <= wb_dat_i[7:0];
                        4'b0101: datareg1_1 <= wb_dat_i[7:0];
                        4'b0110: datareg1_2 <= wb_dat_i[7:0];
                        4'b0111: datareg1_3 <= wb_dat_i[7:0];
                    endcase
                4'b0011:
                    {datareg0_1, datareg0_0} <= wb_dat_i[15:0];
//                  case (wb_adr_i)         // synopsys full_case parallel_case
//                      3'b000: {datareg0_1, datareg0_0} <= wb_dat_i[15:0];
//                  endcase
                4'b1111:
                    {datareg0_3, datareg0_2, datareg0_1, datareg0_0} <= wb_dat_i[31:0];
//                  case (wb_adr_i)         // synopsys full_case parallel_case
//                      3'b000: {datareg0_3, datareg0_2, datareg0_1, datareg0_0} <= wb_dat_i[31:0];
//                  endcase

            endcase
    // generate dat_o
    always @(posedge clk_i)
        case (wb_sel_i)
            4'b0000:
                case (wb_adr_i)     // synopsys full_case parallel_case
                    4'b0000: wb_dat_o[7:0] <= datareg0_0;
                    4'b0001: wb_dat_o[7:0] <= datareg0_1;
                    4'b0010: wb_dat_o[7:0] <= datareg0_2;
                    4'b0011: wb_dat_o[7:0] <= datareg0_3;
                    4'b0100: wb_dat_o[7:0] <= datareg1_0;
                    4'b0101: wb_dat_o[7:0] <= datareg1_1;
                    4'b0110: wb_dat_o[7:0] <= datareg1_2;
                    4'b0111: wb_dat_o[7:0] <= datareg1_3;
                endcase
            4'b0001:
                case (wb_adr_i)     // synopsys full_case parallel_case
                    4'b0000: wb_dat_o[7:0] <= datareg0_0;
                    4'b0001: wb_dat_o[7:0] <= datareg0_1;
                    4'b0010: wb_dat_o[7:0] <= datareg0_2;
                    4'b0011: wb_dat_o[7:0] <= datareg0_3;
                    4'b0100: wb_dat_o[7:0] <= datareg1_0;
                    4'b0101: wb_dat_o[7:0] <= datareg1_1;
                    4'b0110: wb_dat_o[7:0] <= datareg1_2;
                    4'b0111: wb_dat_o[7:0] <= datareg1_3;
                endcase
            4'b0011:
                    wb_dat_o[15:0] <= {datareg0_1, datareg0_0};
            4'b1111:
                    wb_dat_o[31:0] <= {datareg0_3, datareg0_2, datareg0_1, datareg0_0};
        endcase
        
   // generate ack_o
    always @(posedge clk_i or negedge nrst_i)
        if (nrst_i) begin            // not in reset
            if (ws_i == 0) begin
                wb_ack_o <= wb_acc & !wb_ack_o;
                end else
            if((waitstate == 4'b0) && (ws_i != 0)) begin
                wb_ack_o <= 1'b0;
                if(wb_acc) begin
                    waitstate <= waitstate + 1;
                end
            end
            else begin
                if(wb_acc) waitstate <= waitstate + 1;
                if(waitstate == ws_i) begin
                    if(wb_acc) wb_ack_o <= 1'b1;
                    waitstate <= 1'b0;
                end
            end
        end

    assign datareg0 = { datareg0_3, datareg0_2, datareg0_1, datareg0_0 };
    assign datareg1 = { datareg1_3, datareg1_2, datareg1_1, datareg1_0 };

    // Generate an error for registers 0x8-0xF
    assign wb_err_o = wb_ack_o & wb_adr_i[3];

endmodule
