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
   *          $Id: uart_16550_rll.sv 108 2010-03-30 02:56:26Z hiroshi $         *
   ***************************************************************************** */

`ifdef SYN
/* empty */
`else
timeunit      1ps ;
timeprecision 1ps ;
`endif

module uart_16550_rll(interface wb_bus, uart_bus uart_bus) ;
   import uart_package:: * ;
   
   wire    clk_i  = wb_bus.clk_i ;
   wire    nrst_i = wb_bus.nrst_i ;
   wire    overrun ;
   wire    rec_buf_empty ;
   wire    trans_buf_empty ;
   wire    rec_clk_en ;
   wire    rec_sample_pulse ;
   wire    leading_edge ;
   wire    trans_clk_en ;
   wire    txd_out ;
   wire    rxd_clean ;
   wire    rxd_clean_out ;
   wire    timeout_signal ;
   
   fifo_bus
     fifo_pop_trans(.clk_i(clk_i)),
     fifo_push_rec(.clk_i(clk_i)) ;
   
   //   uart_bus uart_bus() ;
   u_reg_t u_reg ;
   codec_state_t rec_next_state ;
   u_codec_t trans_codec ;
   
   // -- loopback mode --
   assign  uart_bus.stx_o = u_reg.modem_control_reg.loopback == 1'b1 ? 1'b1 : txd_out ;
   assign  rxd_clean      = u_reg.modem_control_reg.loopback == 1'b1 ? txd_out : rxd_clean_out ;
   
   uart_register u_register(.clk_i(clk_i),
                            .nrst_i(nrst_i),
                            .wb_bus(wb_bus),
                            .uart_bus(uart_bus),
                            .u_reg(u_reg),
                            .fifo_pop_trans(fifo_pop_trans),
                            .fifo_push_rec(fifo_push_rec),
                            .timeout_signal(timeout_signal),
                            .overrun(overrun),
                            .rec_buf_empty(rec_buf_empty),
                            .trans_buf_empty(trans_buf_empty)) ;
   
   uart_transmitter u_trans(.clk_i(clk_i),
                            .nrst_i(nrst_i),
                            .trans_clk_en(trans_clk_en),
                            .txd_out(txd_out),
                            .fifo_pop(fifo_pop_trans.pop_master_mp),
                            .u_reg(u_reg),
                            .trans_codec(trans_codec),
                            .trans_buf_empty(trans_buf_empty)) ;
   
   uart_receiver u_rec(.clk_i(clk_i),
                       .nrst_i(nrst_i),
                       .rec_clk_en(rec_clk_en),
                       .rec_sample_pulse(rec_sample_pulse),
                       .rxd_clean(rxd_clean),
                       .leading_edge(leading_edge),
                       .timeout_signal(timeout_signal),
                       .fifo_push(fifo_push_rec.push_master_mp),
                       .u_reg(u_reg),
                       .next_state(rec_next_state),
                       .overrun(overrun),
                       .rec_buf_empty(rec_buf_empty)) ;
   
   uart_baud u_baud(.clk_i(clk_i),
                    .nrst_i(nrst_i),
                    .u_reg(u_reg),
                    .rec_next_state(rec_next_state),
                    .trans_codec(trans_codec),
                    .rxd_clean(rxd_clean),
                    .rec_clk_en(rec_clk_en),
                    .rec_sample_pulse(rec_sample_pulse),
                    .leading_edge(leading_edge),
                    .timeout_signal(timeout_signal),
                    .trans_clk_en(trans_clk_en)) ;
   
   uart_noize_shaver u_shaver(.clk_i(clk_i),
                              .nrst_i(nrst_i),
                              .rxd_i(uart_bus.srx_i),
                              .rxd_clean(rxd_clean_out)) ;
   
endmodule

/// END OF FILE ///
