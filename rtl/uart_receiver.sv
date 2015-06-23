/* *****************************************************************************
   * title:         uart_16550_rll module                                      *
   * description:   RS232 Protocol 16550D uart (mostly supported)              *
   * languages:     systemVerilog                                              *
   *                                                                           *
   * Copyright (C) 2010 miyagi.hiroshi                                         *
   *                                                                           *
   * This library is free software; you can redistribute it and/or             *
   * modify it under the terms of the GNU Lesser General Public                *
   * License as published by the Free Software Foundation; either              *
   * version 2.1 of the License, or (at your option) any later version.        *
   *                                                                           *
   * This library is distributed in the hope that it will be useful,           *
   * but WITHOUT ANY WARRANTY; without even the implied warranty of            *
   * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU         *
   * Lesser General Public License for more details.                           *
   *                                                                           *
   * You should have received a copy of the GNU Lesser General Public          *
   * License along with this library; if not, write to the Free Software       *
   * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111*1307  USA *
   *                                                                           *
   *         ***  GNU LESSER GENERAL PUBLIC LICENSE  ***                       *
   *           from http://www.gnu.org/licenses/lgpl.txt                       *
   *****************************************************************************
   *                            redleaflogic,ltd                               *
   *                    miyagi.hiroshi@redleaflogic.biz                        *
   *          $Id: uart_receiver.sv 108 2010-03-30 02:56:26Z hiroshi $         *
   ***************************************************************************** */

`ifdef SYN
/* empty */
`else
timeunit      1ps ;
timeprecision 1ps ;
`endif

import uart_package:: * ;
module uart_receiver(
                     input wire     clk_i,
                     input wire     nrst_i,
                     input wire     rxd_clean,
                     input wire     rec_clk_en,
                     input wire     rec_sample_pulse,
                     input wire     leading_edge,
                     input wire     timeout_signal,
                     fifo_bus       fifo_push,
                     input  u_reg_t u_reg,
                     output codec_state_t next_state,
                     output  logic  rec_buf_empty,
                     output  logic  overrun
                     ) ;
   
   //   codec_state_t     next_state ;
   u_codec_t         rec_codec ;
   
   always @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        rec_codec.line <= #1 1'b1 ;
      else
        rec_codec.line <= #1 rxd_clean ;
   end
   
   // --- fifo push --  
   assign fifo_push.push_dat =  {rec_codec.parity_err,    // bit[10]
                                 rec_codec.framing_err,   //     9
                                 rec_codec.break_err,     //     8
                                 rec_codec.data_r}  ;     //     [7:0]
   logic push_dly ;
   always @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        push_dly <= #1 1'b0 ;
      else
        push_dly <= #1 next_state == STOP && rec_sample_pulse == 1'b1 ;
   end
   assign fifo_push.push = push_dly == 1'b1 ;
   
   // -- trasmitter state logic --
   uart_codec_state rec_state(.u_reg(u_reg),
                              .codec(rec_codec),
                              .receiver_mode(1'b1),
                              .timeout_signal(timeout_signal),
                              .next_state(next_state)) ;
   
   // -- state register --
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        rec_codec.state <= #1 IDLE ;
      else if(rec_clk_en == 1'b1 || leading_edge == 1'b1)
        rec_codec.state <= #1 next_state ;
      else
        rec_codec.state <= #1 rec_codec.state ;
   end
   
   // -- line input --
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0) begin
         rec_codec.data_r <= #1 8'h00 ;
         rec_codec.framing_err <= #1 1'b0 ;
         rec_codec.parity_err  <= #1 1'b0 ;
         rec_codec.break_err   <= #1 1'b0 ;
         overrun <= #1 1'b0 ;
      end
      else begin
         if(rec_sample_pulse == 1'b1)
           case (next_state)
             IDLE  : /* empty */ ;
             START : begin 
                overrun   <= #1 1'b0 ;
                rec_codec.framing_err <= #1 1'b0 ;
                rec_codec.parity_err  <= #1 1'b0 ;
                rec_codec.break_err   <= #1 1'b0 ;
             end
             SEL_0 : rec_codec.data_r[0] <= #1 rec_codec.line ;
             SEL_1 : rec_codec.data_r[1] <= #1 rec_codec.line ;
             SEL_2 : rec_codec.data_r[2] <= #1 rec_codec.line ;
             SEL_3 : rec_codec.data_r[3] <= #1 rec_codec.line ;
             SEL_4 : rec_codec.data_r[4] <= #1 rec_codec.line ;
             SEL_5 : rec_codec.data_r[5] <= #1 rec_codec.line ;
             SEL_6 : rec_codec.data_r[6] <= #1 rec_codec.line ;
             DATA_END : begin
                if(u_reg.line_control_reg.char_length == CHAR_7_BIT) begin
                   rec_codec.data_r[6] <= #1 rec_codec.line ;
                   rec_codec.data_r[7] <= #1 1'b0 ;
                end
                else begin
                   rec_codec.data_r[7] <= #1 rec_codec.line ;
                end
                overrun <= #1 fifo_push.full ;
             end
             PARITY : begin
                if(u_reg.line_control_reg.even_parity == 1'b1)
                  rec_codec.parity_err <= #1 (^rec_codec.data_r) ^ rec_codec.line ;
                else
                  rec_codec.parity_err <= #1 ~(^rec_codec.data_r) ^ rec_codec.line ;
             end
             STOP  : begin
                rec_codec.framing_err <= #1 rec_codec.line == 1'b0 &&
                                         rec_codec.data_r[7:0] != 8'h00 ;
                rec_codec.break_err <= #1 rec_codec.data_r[7:0] == 8'h00 &&
                                       rec_codec.line == 1'b0 &&
                                       rec_codec.parity_err == 1'b0 ;
             end
             default : /* empty */ ;
           endcase // case (state)
      end // if (sample_en == 1'b1)
   end // always_ff @ (posedge clk, negedge nrst)
   
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        rec_buf_empty <= 1'b0 ;
      else if(next_state == IDLE || next_state == STOP)
        rec_buf_empty <= #1 1'b1 ;
      else
        rec_buf_empty <= #1 1'b0 ;
   end
   
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        rec_codec.start <= #1 1'b0 ;
      else if(rec_codec.state == START)
        rec_codec.start <= #1 1'b0 ;
      else if(leading_edge == 1'b1)
        rec_codec.start <= #1 1'b1 ;
      else
        rec_codec.start <= #1 rec_codec.start ;
   end
   
endmodule

/// END OF FILE ///
