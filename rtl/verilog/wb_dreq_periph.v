//////////////////////////////////////////////////////////////////////
////                                                              ////
////  $Id: wb_dreq_periph.v,v 1.2 2008-03-05 05:50:59 hharte Exp $////
////  wb_dreq_periph.v - Wishbone DMA Requestor for LPC Peripheral////
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

`timescale 1 ns / 1 ns

`include "../../rtl/verilog/wb_lpc_defines.v"

module wb_dreq_periph(clk_i, nrst_i,
                      dma_chan_i, dma_req_i,
                      ldrq_o
);
    // Wishbone Slave Interface
    input       clk_i;
    input       nrst_i;             // Active low reset.

    // Private DMA Interface
    input [2:0] dma_chan_i;
    input       dma_req_i;

    // LPC Bus DMA Request Output
    output reg  ldrq_o;
    
    reg [1:0]   adr_cnt;
    reg [3:0]   state;
    
    always @(posedge clk_i or negedge nrst_i)
        if(~nrst_i)
        begin
            state <= `LDRQ_ST_IDLE;
            ldrq_o <= 1'b1; // LDRQ# Idle
            adr_cnt <= 2'b00;
        end
        else begin
            case(state)
                `LDRQ_ST_IDLE:
                    begin
                        if(dma_req_i) begin
                            ldrq_o <= 1'b0;
                            state <= `LDRQ_ST_ADDR;
                            adr_cnt <= 2'h2;
                        end
                    end
                `LDRQ_ST_ADDR:
                    begin
                        ldrq_o <= dma_chan_i[adr_cnt];
                        adr_cnt <= adr_cnt - 1;
                        
                        if(adr_cnt == 2'h0)
                            state <= `LDRQ_ST_ACT;
                    end
                `LDRQ_ST_ACT:
                    begin
                        ldrq_o <= 1'b1;
                        state <= `LDRQ_ST_DONE;
                    end
                `LDRQ_ST_DONE:
                    begin
                        ldrq_o <= 1'b1;
                        state <= `LDRQ_ST_IDLE;
                    end
            endcase
        end

endmodule

