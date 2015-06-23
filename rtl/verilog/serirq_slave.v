//////////////////////////////////////////////////////////////////////
////                                                              ////
////  $Id: serirq_slave.v,v 1.2 2008-12-27 19:46:18 hharte Exp $  ////
////  serirq_slave.v - Wishbone Slave to SERIRQ Host Bridge       ////
////                                                              ////
////  This file is part of the Wishbone LPC Bridge project        ////
////  http://www.opencores.org/projects/lpc/                      ////
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

module serirq_slave(clk_i, nrst_i, 
                    irq_i,
                    serirq_o, serirq_i, serirq_oe
);
    // Wishbone Slave Interface
    input             clk_i;
    input             nrst_i;       // Active low reset.
    
    // SERIRQ Master Interface
    output reg        serirq_o;     // SERIRQ output
    input             serirq_i;     // SERIRQ Input
    output reg        serirq_oe;    // SERIRQ Output Enable

    input      [31:0] irq_i;        // IRQ Input Bus
    reg        [31:0] current_irq;

    reg        [12:0] state;        // Current state
    reg         [4:0] irq_cnt;      // IRQ Frame counter

    reg found_stop;
    reg found_start;
    reg serirq_mode;

    wire irq_changed = (serirq_mode & (current_irq != irq_i));
     
    always @(posedge clk_i or negedge nrst_i)
        if(~nrst_i)
        begin
            state <= `SERIRQ_ST_IDLE;
            serirq_oe <= 1'b0;
            serirq_o <= 4'b1;
            irq_cnt <= 5'h00;
            current_irq <= irq_i;
        end
        else begin
            case(state)
                `SERIRQ_ST_IDLE:
                    begin
                        serirq_oe <= 1'b0;
                        irq_cnt <= 5'h00;
                        serirq_o <= 1'b1;

                        if(found_start == 1'b1) // Wait for Start cycle
                        begin
                            current_irq <= irq_i;
                            if(irq_i[irq_cnt] == 1'b0) begin
                                serirq_oe <= 1'b1;
                                serirq_o <= 1'b0;
                            end
                            state <= `SERIRQ_ST_IRQ_R;
                        end
                        else if(irq_changed) begin
                            current_irq <= irq_i;
                            serirq_o <= 1'b0;
                            serirq_oe <= 1'b1;
                            state <= `SERIRQ_ST_IDLE;
                        end else
                            state <= `SERIRQ_ST_IDLE;
                    end
                `SERIRQ_ST_IRQ:
                    begin
                        if(irq_i[irq_cnt] == 1'b0) begin
                            serirq_oe <= 1'b1;
                            serirq_o <= 1'b0;
                        end
                            if(found_stop == 1'b0)
                                state <= `SERIRQ_ST_IRQ_R;
                            else
                                state <= `SERIRQ_ST_IDLE;
                    end
                `SERIRQ_ST_IRQ_R:
                    begin
                        serirq_o <= 1'b1;
                        if(found_stop == 1'b0)
                            state <= `SERIRQ_ST_IRQ_T;
                        else
                            state <= `SERIRQ_ST_IDLE;
                    end
                `SERIRQ_ST_IRQ_T:
                    begin
                        serirq_oe <= 1'b0;
                        if(irq_cnt == 5'h1f)
                        begin
                            state <= `SERIRQ_ST_WAIT_STOP;
                        end
                        else begin
                            irq_cnt <= irq_cnt + 1;
                            if(found_stop == 1'b0)
                                state <= `SERIRQ_ST_IRQ;
                            else
                                state <= `SERIRQ_ST_IDLE;
                        end
                    end
                    `SERIRQ_ST_WAIT_STOP:
                        begin
                            if(found_stop == 1'b0)
                                state <= `SERIRQ_ST_WAIT_STOP;
                            else
                                state <= `SERIRQ_ST_IDLE;
                        end
            endcase
        end

    reg [3:0] stop_clk_cnt;

    // Look for STOP cycles
    always @(posedge clk_i or negedge nrst_i)
        if(~nrst_i)
        begin
            found_stop <= 1'b0;
            found_start <= 1'b0;
            serirq_mode <= `SERIRQ_MODE_CONTINUOUS;
            stop_clk_cnt <= 4'h0;
        end
        else begin
            if(serirq_i == 1'b0) begin
                stop_clk_cnt <= stop_clk_cnt + 1;
            end
            else begin
                case (stop_clk_cnt) 
                    4'h2:
                        begin
                            found_stop <= 1'b1;
                            found_start <= 1'b0;
                            serirq_mode <= `SERIRQ_MODE_QUIET;
                        end
                    4'h3:
                        begin
                            found_stop <= 1'b1;
                            found_start <= 1'b0;
                            serirq_mode <= `SERIRQ_MODE_CONTINUOUS;
                        end
                    4'h4:
                        begin
                            found_stop <= 1'b0;
                            found_start <= 1'b1;
                        end
                    4'h6:
                        begin
                            found_stop <= 1'b0;
                            found_start <= 1'b1;
                        end
                    4'h8:
                        begin
                            found_stop <= 1'b0;
                            found_start <= 1'b1;
                        end
                    default:
                        begin
                            found_stop <= 1'b0;
                            found_start <= 1'b0;
                        end
                    endcase
                    stop_clk_cnt <= 4'h0;
            end
        end
endmodule

