//////////////////////////////////////////////////////////////////////
////                                                              ////
////  $Id: wb_fpb.v,v 1.1 2008-12-15 06:40:29 hharte Exp $        ////
////  wb_fpb.v - "Front Panel Board" with Wishbone                ////
////             Slave interface.                                 ////
////                                                              ////
////  This file is part of the Vector Graphic Z80 SBC Project     ////
////  http://www.opencores.org/projects/vg_z80_sbc/               ////
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

//+---------------------------------------------------------------------------+
//|
//|
//+---------------------------------------------------------------------------+
module wb_fpb(
    clk_i, nrst_i, wbs_adr_i, wbs_dat_o, wbs_dat_i, wbs_sel_i, wbs_we_i,
    wbs_stb_i, wbs_cyc_i, wbs_ack_o,
    prog_out_port,
    sense_sw_i,
    lcd_e,
    lcd_rs,
    lcd_rw,
    lcd_dat
);

    // Wishbone Slave Interface
    input          clk_i;
    input          nrst_i;
    input    [4:0] wbs_adr_i;
    output reg [7:0] wbs_dat_o;
    input    [7:0] wbs_dat_i;
    input    [3:0] wbs_sel_i;
    input          wbs_we_i;
    input          wbs_stb_i;
    input          wbs_cyc_i;
    output reg     wbs_ack_o;

    output         lcd_e;
    output         lcd_rs;
    output         lcd_rw;
    output reg [3:0] lcd_dat;
    
    // Programmed Output Port (8-bit)
    output reg [7:0] prog_out_port;
    
    // Sense Switches
    input      [7:0] sense_sw_i;

    //
    // generate wishbone register bank writes
    wire wbs_acc = wbs_cyc_i & wbs_stb_i;    // WISHBONE access
    wire wbs_wr  = wbs_acc & wbs_we_i;       // WISHBONE write access
    wire wbs_rd  = wbs_acc & !wbs_we_i;      // WISHBONE read access

    assign lcd_e = wbs_acc;
    assign lcd_rw = 1'b0;
    assign lcd_rs = wbs_adr_i[0];

    always @(posedge clk_i or negedge nrst_i)
        if(~nrst_i) // Reset
        begin
            wbs_ack_o <= 1'b0;
            prog_out_port <= 8'hFF;
            lcd_dat <= 4'h0;
        end
        else begin
            
            if(wbs_wr)  // Wishbone Write, decode address to determine register offset.
                case(wbs_adr_i)
                    5'h00: begin   //
                        lcd_dat <= wbs_dat_i[3:0];
                    end
                    5'h01: begin   //
                        lcd_dat <= wbs_dat_i[3:0];
                    end
                    5'h02: begin   //
                    end
                    5'h1F: begin   // Programmed Output Port
                        prog_out_port <= wbs_dat_i;
                    end
                endcase

            if(wbs_rd) begin
                case(wbs_adr_i) // Wishbone Read, decode address to determine register offset.
                    5'h00: begin   //
                        wbs_dat_o <= 8'hE0;
                    end
                    5'h01: begin   //
                        wbs_dat_o <= 8'hE1;
                    end
                    5'h02: begin   //
                        wbs_dat_o <= 8'hE2;
                    end
                    5'h1F: begin   // Sense Switches Input Port
                        wbs_dat_o <= sense_sw_i;
                    end
                endcase
            end
          
            wbs_ack_o <= wbs_acc & !wbs_ack_o;
        end

endmodule

                            
