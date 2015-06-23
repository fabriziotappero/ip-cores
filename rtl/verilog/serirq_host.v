//////////////////////////////////////////////////////////////////////
////                                                              ////
////  $Id: serirq_host.v,v 1.2 2008-12-27 19:46:18 hharte Exp $   ////
////  serirq_host.v - SERIRQ Host Controller                      ////
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

`include "../../rtl/verilog/serirq_defines.v"

module serirq_host(clk_i, nrst_i, 
                   serirq_mode_i, irq_o,
                   serirq_o, serirq_i, serirq_oe
);
    // Wishbone Slave Interface
    input              clk_i;
    input              nrst_i;      // Active low reset.
    input              serirq_mode_i; // Mode selection, 0=Continuous, 1=Quiet
    
    // SERIRQ Master Interface
    output reg         serirq_o;    // SERIRQ output
    input              serirq_i;    // SERIRQ Input
    output reg         serirq_oe;   // SERIRQ Output Enable

    output reg  [31:0] irq_o;       // IRQ Output Bus

    reg         [12:0] state;       // Current state
    reg          [4:0] irq_cnt;     // IRQ Frame counter
    reg          [2:0] start_cnt;   // START counter
    reg          [2:0] stop_cnt;    // STOP counter
    reg                current_mode;

    always @(posedge clk_i or negedge nrst_i)
        if(~nrst_i)
        begin
            state <= `SERIRQ_ST_IDLE;
            serirq_oe <= 1'b0;
            serirq_o <= 4'b1;
            irq_cnt <= 5'h00;
                start_cnt <= 3'b000;
                stop_cnt <= 2'b00;
                irq_o <= 32'hFFFFFFFF;
                current_mode <= `SERIRQ_MODE_CONTINUOUS;
        end
        else begin
            case(state)
                `SERIRQ_ST_IDLE:
                    begin
                        serirq_oe <= 1'b0;
                        start_cnt <= 3'b000;
                        stop_cnt <= 2'b00;
                        serirq_o <= 1'b1;
                        if((current_mode == `SERIRQ_MODE_QUIET) && (serirq_i == 1'b0)) begin
                            start_cnt <= 3'b010;
                            serirq_o <= 1'b0;
                            serirq_oe <= 1'b1;
                            state <= `SERIRQ_ST_START;
                        end
                        else if(current_mode == `SERIRQ_MODE_CONTINUOUS)
                        begin
                            start_cnt <= 3'b000;
                            state <= `SERIRQ_ST_START;
                        end
                        else if((current_mode == `SERIRQ_MODE_QUIET) && (serirq_mode_i == `SERIRQ_MODE_CONTINUOUS)) 
                        begin // Switch to Continuous mode by starting a new cycle to inform the slaves.
                            start_cnt <= 3'b000;
                            state <= `SERIRQ_ST_START;
                        end
                        else
                            state <= `SERIRQ_ST_IDLE;
                    end
                `SERIRQ_ST_START:
                    begin
                        serirq_o <= 1'b0;
                        serirq_oe <= 1'b1;
                        irq_cnt <= 5'h00;
                        start_cnt <= start_cnt + 1;
                        if(start_cnt == 3'b111) begin
                            state <= `SERIRQ_ST_START_R;
                        end
                        else begin
                            state <= `SERIRQ_ST_START;
                        end
                    end
                `SERIRQ_ST_START_R:
                    begin
                        serirq_o <= 1'b1;
                        state <= `SERIRQ_ST_START_T;
                    end
                `SERIRQ_ST_START_T:
                    begin
                        serirq_oe <= 1'b0;
                        state <= `SERIRQ_ST_IRQ;
                    end
                `SERIRQ_ST_IRQ:
                    begin
                        state <= `SERIRQ_ST_IRQ_R;
                    end
                `SERIRQ_ST_IRQ_R:
                    begin
                        irq_o[irq_cnt] <= (serirq_i == 1'b0 ? 1'b0 : 1'b1);
                        state <= `SERIRQ_ST_IRQ_T;
                    end
                `SERIRQ_ST_IRQ_T:
                    begin
                        if(irq_cnt == 5'h1f) begin
                            state <= `SERIRQ_ST_STOP;
                        end else begin
                            state <= `SERIRQ_ST_IRQ;
                            irq_cnt <= irq_cnt + 1;
                        end
                    end
                `SERIRQ_ST_STOP:
                    begin
                        serirq_o <= 1'b0;
                        serirq_oe <= 1'b1;
                        stop_cnt <= stop_cnt + 1;
                        if(stop_cnt == (serirq_mode_i ? 2'b01 : 2'b10)) begin
                            state <= `SERIRQ_ST_STOP_R;
                        end
                        else begin
                            state <= `SERIRQ_ST_STOP;
                        end
                    end
                `SERIRQ_ST_STOP_R:
                    begin
                        serirq_o <= 1'b1;
                        state <= `SERIRQ_ST_STOP_T;
                    end
                `SERIRQ_ST_STOP_T:
                    begin
                        serirq_oe <= 1'b0;
                        state <= `SERIRQ_ST_IDLE;
                        current_mode <= serirq_mode_i;
                    end
            endcase
        end
endmodule

                            
