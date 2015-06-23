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
   *          $Id: uart_transmitter.sv 108 2010-03-30 02:56:26Z hiroshi $         *
   ***************************************************************************** */
   
`ifdef SYN
/* empty */
`else
timeunit      1ps ;
timeprecision 1ps ;
`endif
import uart_package:: * ;
module uart_transmitter(input wire    clk_i,
                        input wire    nrst_i,
                        input wire    trans_clk_en,
                        output wire   txd_out,
                        fifo_bus      fifo_pop,
                        input u_reg_t u_reg,
                        output u_codec_t trans_codec,
                        output logic  trans_buf_empty) ;
   
   codec_state_t   next_state ;
   //   u_codec_t       trans_codec ;
   logic                              pop ;
   
   assign fifo_pop.pop = pop ;
   
   // -- break signal output --
   assign txd_out = u_reg.line_control_reg.break_control_bit == 1'b1 ? 1'b0 : trans_codec.line ;
   
   // -- trasmitter state logic --
   uart_codec_state trans_state(.u_reg(u_reg),
                                .codec(trans_codec),
                                .receiver_mode(1'b0),
                                .timeout_signal(1'b1),
                                .next_state(next_state)) ;
   
   // -- state register --
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        trans_codec.state <= #1 IDLE ;
      else if(trans_clk_en == 1'b1 || trans_codec.state == IDLE)
        trans_codec.state <= #1 next_state ;
      else
        trans_codec.state <= #1 trans_codec.state ;
   end
   
   // -- line output --
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0) begin
         trans_codec.data_r <= #1 8'h00 ;
         trans_codec.line   <= #1 1'b1 ;
         trans_codec.framing_err <= #1 1'b0 ;
         trans_codec.parity_err  <= #1 1'b0 ;
         trans_codec.break_err   <= #1 1'b0 ;
      end
      else if(trans_clk_en == 1'b1)
        case (trans_codec.state)
          IDLE : trans_codec.line <= #1 1'b1 ;
          
          START : begin
             trans_codec.data_r <= #1 fifo_pop.pop_dat[7:0] ;
             trans_codec.line   <= #1 1'b0 ;
          end
          
          SEL_0 : trans_codec.line <= #1 trans_codec.data_r[0] ;
          SEL_1 : trans_codec.line <= #1 trans_codec.data_r[1] ;
          SEL_2 : trans_codec.line <= #1 trans_codec.data_r[2] ;
          SEL_3 : trans_codec.line <= #1 trans_codec.data_r[3] ;
          SEL_4 : trans_codec.line <= #1 trans_codec.data_r[4] ;
          SEL_5 : trans_codec.line <= #1 trans_codec.data_r[5] ;
          SEL_6 : trans_codec.line <= #1 trans_codec.data_r[6] ;
          
          DATA_END : begin
             if(u_reg.line_control_reg.char_length == CHAR_7_BIT)
               trans_codec.line <= #1 trans_codec.data_r[6] ;
             else
               trans_codec.line <= #1 trans_codec.data_r[7] ;
          end
          
          PARITY : begin
             case ({u_reg.line_control_reg.even_parity,
                    u_reg.line_control_reg.stick_parity})
               2'b00  : trans_codec.line <= #1 u_reg.line_control_reg.char_length == CHAR_7_BIT
                                            ?  ~(^trans_codec.data_r[6:0])
                                              : ~(^trans_codec.data_r[7:0]) ;
               2'b01  : trans_codec.line <= #1  1'b1 ;
               2'b10  : trans_codec.line <= #1 u_reg.line_control_reg.char_length == CHAR_7_BIT
                                            ?  (^trans_codec.data_r[6:0])
                                              :  (^trans_codec.data_r[7:0]) ;
               2'b11  : trans_codec.line <= #1  1'b0 ;
               default : trans_codec.line <= #1 1'b0 ;
             endcase
          end
          
          STOP : trans_codec.line   <= #1 1'b1 ;
          
          default : trans_codec.line <= #1 1'b1 ;
        endcase // case (state)
   end // always_ff @ (posedge clk, negedge nrst)
   
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        pop <= 1'b0 ;
      else if(trans_codec.state == START && trans_clk_en == 1'b1)
        pop <= 1'b1 ;
      else
        pop <= 1'b0 ;
   end
   
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        trans_codec.start <= 1'b0 ;
      else if(fifo_pop.empty == 1'b0)
        trans_codec.start <= 1'b1 ;
      else
        trans_codec.start <= 1'b0 ;
   end
   
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        trans_buf_empty <= 1'b0 ;
      else if(next_state == IDLE || next_state == STOP)
        trans_buf_empty <= #1 1'b1 ;
      else
        trans_buf_empty <= #1 1'b0 ;
   end
   
endmodule

/// END OF FILE ///
