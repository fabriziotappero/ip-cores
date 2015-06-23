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
   *          $Id: uart_baud.sv 108 2010-03-30 02:56:26Z hiroshi $         *
   ***************************************************************************** */

`ifdef SYN
/* empty */
`else
timeunit      1ps ;
timeprecision 1ps ;
`endif
import uart_package:: * ;
module uart_baud
  (
   input wire clk_i,
   input wire nrst_i,
   input u_reg_t u_reg,
   input codec_state_t  rec_next_state,
   input u_codec_t  trans_codec,
   input wire  rxd_clean,
   output wire rec_clk_en,
   output wire rec_sample_pulse,
   output wire leading_edge,
   output wire timeout_signal,
   output wire trans_clk_en
   ) ;

   // -------------------
   // -- receiver baud --
   // -------------------
   // -- leading edge generate --
   logic [3:0] rec_count ;
   logic [7:0] rec_divisor ;
   logic       rxd_l ;
   logic [5:0] timeout_c ;
   
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        rxd_l <= #1 1'b1 ;
      else
        rxd_l <= #1 rxd_clean ;
   end

   wire rec_count_enable = rec_count == 4'hf ;
   wire rec_count_sample = rec_count == 4'h8 ;
   assign leading_edge = (rxd_l & ~rxd_clean) && (rec_next_state == IDLE ||
                                                  rec_next_state == TIMEOUT ||
                                                  rec_next_state == STOP) ;
   
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        rec_count <= #1 4'h0 ;
      else if(rec_next_state == IDLE || rec_count_enable == 1'b1 || leading_edge == 1'b1)
        rec_count <= #1 4'h0 ;
      else
        rec_count <= #1 rec_count + 4'h1 ;
   end
   wire rec_count_end      = rec_divisor == u_reg.baud_reg && rec_count_enable == 1'b1 ;
   // sample pulse position -> baud_reg/2 
   assign rec_sample_pulse = rec_divisor == {1'b0, u_reg.baud_reg[7:1]} && rec_count_sample == 1'b1 ;
   assign rec_clk_en       = rec_count_end ;
   
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        rec_divisor <= #1 8'h00 ;
      else if(rec_count_end == 1'b1 || rec_next_state == IDLE || leading_edge == 1'b1)
        rec_divisor <= #1 8'h00 ;
      else if(rec_count_enable == 1'b1)
        rec_divisor <= #1 rec_divisor + 8'h01 ;
      else
        rec_divisor <= #1 rec_divisor ;
   end

   // -- timeout counter --
   // about 4 character :: read for manual -> 4.3 Interrupt Identification Register (IIR)
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        timeout_c <= #1 6'h00 ;
      else if(timeout_signal == 1'b1 || rec_next_state == IDLE || leading_edge == 1'b1)
        timeout_c <= #1 6'h00 ;
      else if(rec_count_end == 1'b1)
        timeout_c <= #1 timeout_c + 6'h01 ;
      else
        timeout_c <= #1 timeout_c ;
   end
   assign timeout_signal = timeout_c == 6'h28 && rec_count_end == 1'b1 ;
   
   // ----------------------
   // -- transmitter baud --
   // ----------------------
   logic [3:0] trans_count ;
   logic [7:0] trans_divisor ;

   wire        trans_count_enable = trans_count == 4'hf ;
   
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        trans_count <= #1 4'h0 ;
      else if(trans_codec.state == IDLE || trans_count_enable == 1'b1)
        trans_count <= #1 4'h0 ;
      else
        trans_count <= trans_count + 4'h1 ;
   end
   
   wire trans_count_end = trans_divisor == u_reg.baud_reg && trans_count_enable == 1'b1 ;
   assign trans_clk_en = trans_count_end ;
   
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        trans_divisor <= #1 8'h00 ;
      else if(trans_count_end == 1'b1 || trans_codec.state == IDLE)
        trans_divisor <= #1 8'h00 ;
      else if(trans_count_enable == 1'b1)
        trans_divisor <= #1 trans_divisor + 8'h01 ;
      else
        trans_divisor <= #1 trans_divisor ;
   end
   
endmodule
