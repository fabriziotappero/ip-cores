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
   *          $Id: uart_register.sv 108 2010-03-30 02:56:26Z hiroshi $         *
   ***************************************************************************** */

`ifdef SYN
/* empty */
`else
timeunit      1ps ;
timeprecision 1ps ;
`endif

import uart_package:: * ;
module uart_register
  (
   input wire     clk_i,
   input wire     nrst_i,
   wb_bus         wb_bus,
   uart_bus       uart_bus,
   output u_reg_t u_reg,
   fifo_bus       fifo_pop_trans,
   fifo_bus       fifo_push_rec,
   input wire     timeout_signal,
   input wire     overrun,
   input wire     rec_buf_empty,
   input wire     trans_buf_empty
   ) ;
   
   localparam   WRITE                  = 1'b1 ;
   localparam   READ                   = 1'b0 ;
   localparam   ENABLE                 = 1'b1 ;
   localparam   DISABLE                = 1'b0 ;
   
   fifo_bus
     fifo_pop_rec(.clk_i(clk_i)),
     fifo_push_trans(.clk_i(clk_i)) ;
   
   logic [31:0]   rdat ;
   
   wire [31:0]    dat_i  = wb_bus.dat_i ;
   wire           we_i   = wb_bus.we_i ;
   
`ifdef ALIGN_4B
   wire           uart_stb = wb_bus.cyc_i == 1'b1 && wb_bus.stb_i == 1'b1 && wb_bus.sel_i == 4'b1111 ;
   wire           stb_rxd_fifo = uart_stb == 1'b1 && wb_bus.adr_i[4:2] == UART_RXD && u_reg.line_control_reg.divisor_access == 1'b0 ;
   wire           stb_txd_fifo = uart_stb == 1'b1 && wb_bus.adr_i[4:2] == UART_TXD && u_reg.line_control_reg.divisor_access == 1'b0 ;
   wire           stb_interrupt_enable_reg  = uart_stb == 1'b1 && wb_bus.adr_i[4:2] == UART_INTERRUPT_ENABLE ;
   wire           stb_interrupt_ident_reg   = uart_stb == 1'b1 && wb_bus.adr_i[4:2] == UART_INTERRUPT_IDENT ;
   wire           stb_fifo_control_reg      = uart_stb == 1'b1 && wb_bus.adr_i[4:2] == UART_FIFO_CONTROL ;
   wire           stb_line_control_reg      = uart_stb == 1'b1 && wb_bus.adr_i[4:2] == UART_LINE_CONTROL ;
   wire           stb_modem_control_reg     = uart_stb == 1'b1 && wb_bus.adr_i[4:2] == UART_MODEM_CONTROL ;
   wire           stb_line_status_reg       = uart_stb == 1'b1 && wb_bus.adr_i[4:2] == UART_LINE_STATUS ;
   wire           stb_modem_status_reg      = uart_stb == 1'b1 && wb_bus.adr_i[4:2] == UART_MODEM_STATUS ;
   wire           stb_scratch_reg           = uart_stb == 1'b1 && wb_bus.adr_i[4:2] == UART_SCRATCH ;
   wire           stb_baud_reg = uart_stb == 1'b1 && wb_bus.adr_i[4:2] == UART_BAUD && u_reg.line_control_reg.divisor_access == 1'b1 ;
`else
   wire           uart_stb = wb_bus.cyc_i == 1'b1 && wb_bus.stb_i == 1'b1 ;
   wire           stb_rxd_fifo = wb_bus.sel_i[0] == 1'b1 && uart_stb == 1'b1 && wb_bus.adr_i[2:0] == UART_RXD && u_reg.line_control_reg.divisor_access == 1'b0 ;
   wire           stb_txd_fifo = wb_bus.sel_i[0] == 1'b1 && uart_stb == 1'b1 && wb_bus.adr_i[2:0] == UART_TXD && u_reg.line_control_reg.divisor_access == 1'b0 ;
   wire           stb_interrupt_enable_reg  = wb_bus.sel_i[1] == 1'b1 && uart_stb == 1'b1 && wb_bus.adr_i[2:0] == UART_INTERRUPT_ENABLE ;
   wire           stb_interrupt_ident_reg   = wb_bus.sel_i[2] == 1'b1 && uart_stb == 1'b1 && wb_bus.adr_i[2:0] == UART_INTERRUPT_IDENT ;
   wire           stb_fifo_control_reg      = wb_bus.sel_i[2] == 1'b1 && uart_stb == 1'b1 && wb_bus.adr_i[2:0] == UART_FIFO_CONTROL ;
   wire           stb_line_control_reg      = wb_bus.sel_i[3] == 1'b1 && uart_stb == 1'b1 && wb_bus.adr_i[2:0] == UART_LINE_CONTROL ;
   wire           stb_modem_control_reg     = wb_bus.sel_i[0] == 1'b1 && uart_stb == 1'b1 && wb_bus.adr_i[2:0] == UART_MODEM_CONTROL ;
   wire           stb_line_status_reg       = wb_bus.sel_i[1] == 1'b1 && uart_stb == 1'b1 && wb_bus.adr_i[2:0] == UART_LINE_STATUS ;
   wire           stb_modem_status_reg      = wb_bus.sel_i[2] == 1'b1 && uart_stb == 1'b1 && wb_bus.adr_i[2:0] == UART_MODEM_STATUS ;
   wire           stb_scratch_reg           = wb_bus.sel_i[3] == 1'b1 && uart_stb == 1'b1 && wb_bus.adr_i[2:0] == UART_SCRATCH ;
   wire           stb_baud_reg = wb_bus.sel_i[0] == 1'b1 && uart_stb == 1'b1 && wb_bus.adr_i[2:0] == UART_BAUD && u_reg.line_control_reg.divisor_access == 1'b1 ;
`endif   
   // -- assign wb_bus.intr_o = u_reg.interrupt_identification.intr_active == 1'b1 ;
   assign wb_bus.intr_o = u_reg.interrupt_pending_reg.modem_status ||
                          u_reg.interrupt_pending_reg.transmitter_holding_register_empty ||
                          u_reg.interrupt_pending_reg.timeout_indication ||
                          u_reg.interrupt_pending_reg.receiver_data_available ||
                          u_reg.interrupt_pending_reg.receiver_line_status ;
   
   assign wb_bus.dat_o  = rdat ;
   assign wb_bus.ack_o  = uart_stb == 1'b1 ; // no wait
   assign dat_i         = wb_bus.dat_i ;
   
   // -- uart line :: read for manual -> 4.6 Modem Control Register (MCR) --
   assign uart_bus.dtr_o = u_reg.modem_control_reg.dtr == 1'b0 ;
   assign uart_bus.rts_o = u_reg.modem_control_reg.rts == 1'b0 ;
   
   wire           cts = u_reg.modem_control_reg.loopback == 1'b1 ? uart_bus.rts_o : uart_bus.cts_i == 1'b0 ;
   wire           dsr = u_reg.modem_control_reg.loopback == 1'b1 ? uart_bus.dtr_o : uart_bus.dsr_i == 1'b0 ;
   wire           ri  = u_reg.modem_control_reg.loopback == 1'b1 ? u_reg.modem_control_reg.out1 : uart_bus.ri_i == 1'b0 ;
   wire           dcd = u_reg.modem_control_reg.loopback == 1'b1 ? u_reg.modem_control_reg.out2 : uart_bus.dcd_i == 1'b0 ;

`ifdef ALIGN_4B   
   // -- data read selector --   
   always_comb begin
      unique case ({
                    stb_baud_reg,
                    stb_scratch_reg,
                    stb_rxd_fifo,
                    stb_interrupt_enable_reg,
                    stb_interrupt_ident_reg,
                    stb_line_control_reg,
                    stb_modem_control_reg,
                    stb_line_status_reg,
                    stb_modem_status_reg
                    })
        9'h100 : rdat = {24'h0, u_reg.baud_reg} ;
        9'h080 : rdat = {24'h0, u_reg.scratch_reg} ;
        9'h040 : rdat = {24'h0, fifo_pop_rec.pop_dat[7:0]} ;
        9'h020 : rdat = {24'h0, u_reg.interrupt_enable_reg} ;
        9'h010 : rdat = {24'h0, u_reg.interrupt_ident_reg} ;
        9'h008 : rdat = {24'h0, u_reg.line_control_reg} ; 
        9'h004 : rdat = {24'h0, u_reg.modem_control_reg} ;
        9'h002 : rdat = {24'h0, u_reg.line_status_reg} ;
        9'h001 : rdat = {24'h0, u_reg.modem_status_reg} ;
        default : rdat = 32'h0 ;
      endcase
   end
`else // ALINE_1B
   assign rdat[7:0]  =  stb_rxd_fifo == 1'b1             ? fifo_pop_rec.pop_dat[7:0]  : 8'h0 |
                        stb_baud_reg == 1'b1             ? u_reg.baud_reg             : 8'h0 ;
   assign rdat[15:8] =  stb_interrupt_enable_reg == 1'b1 ? u_reg.interrupt_enable_reg : 8'h0 |
                        stb_line_status_reg == 1'b1      ? u_reg.line_status_reg      : 8'h0 ;
   assign rdat[23:16] = stb_interrupt_ident_reg          ? u_reg.interrupt_ident_reg  : 8'h0 |
                        stb_modem_status_reg == 1'b1     ? u_reg.modem_status_reg     : 8'h0 ;
   assign rdat[31:24] = stb_line_control_reg == 1'b1     ? u_reg.line_control_reg     : 8'h0 |
                        stb_scratch_reg == 1'b1          ? u_reg.scratch_reg          : 8'h0 ;
`endif
   
   // -- fifo signal --
   wire         fifo_rec_reset    =  u_reg.fifo_control_reg.receiver_fifo_reset == 1'b1 ;
   wire         fifo_trans_reset  =  u_reg.fifo_control_reg.transmitter_fifo_reset == 1'b1 ; 
   wire         all_error_rec ;
   
   // -- recevied fifo --
   uart_fifo #(.DATA_WIDTH(11), .ADDR_WIDTH(4)) fifo_rec
     (
      .clk_i(clk_i),
      .nrst_i(nrst_i),
      .clear(fifo_rec_reset),
      .almost_empty_level(u_reg.fifo_control_reg.define_fifo_trigger_level),
      .fifo_pop(fifo_pop_rec.pop_slave_mp),
      .fifo_push(fifo_push_rec.push_slave_mp),
      .all_error(all_error_rec)
      ) ;
   
   // -- transmitter fifo --
   uart_fifo #(.DATA_WIDTH(11), .ADDR_WIDTH(4)) fifo_trans
     (
      .clk_i(clk_i),
      .nrst_i(nrst_i),
      .clear(fifo_trans_reset),
      .almost_empty_level(u_reg.fifo_control_reg.define_fifo_trigger_level),
      .fifo_pop(fifo_pop_trans.pop_slave_mp),
      .fifo_push(fifo_push_trans.push_slave_mp),
      .all_error() /* N.C. */
      ) ;
   
   // -------------------
   // -- UART REGISTER --
   // -------------------
   
   assign fifo_push_trans.push = stb_txd_fifo == 1'b1 && we_i == WRITE ;
   assign fifo_push_trans.push_dat = dat_i[7:0] ;
   assign fifo_pop_rec.pop = stb_rxd_fifo == 1'b1 && we_i == READ ;
   
   // -- interrupt enable register --
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        u_reg.interrupt_enable_reg <= 'h0 ;
      else if(stb_interrupt_enable_reg == 1'b1 && we_i == WRITE)
        u_reg.interrupt_enable_reg <= dat_i[7:0] ;
      else
        u_reg.interrupt_enable_reg <= u_reg.interrupt_enable_reg[7:0] ;
   end
   
   // -- fifo control register write only --
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        u_reg.fifo_control_reg <= 'hc0 ;
      else if(stb_fifo_control_reg == 1'b1 && we_i == WRITE)
        u_reg.fifo_control_reg <= dat_i[7:0] ;
      else begin
        u_reg.fifo_control_reg[7:3] <= u_reg.fifo_control_reg[7:3] ;
        u_reg.fifo_control_reg[2:1] <= 2'b00 ;                        // -- fifo_cleaer
        u_reg.fifo_control_reg[0] <= u_reg.fifo_control_reg[0] ;
      end
   end
   
   // -- line control register --
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        u_reg.line_control_reg <= 'h03 ;
      else if(stb_line_control_reg == 1'b1 && we_i == WRITE)
        u_reg.line_control_reg <= dat_i[7:0] ;
      else
        u_reg.line_control_reg <= u_reg.line_control_reg[7:0] ;
   end
   
   // -- modem control register --
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        u_reg.modem_control_reg <= 'h0 ;
      else if(stb_modem_control_reg == 1'b1 && we_i == WRITE)
        u_reg.modem_control_reg <= dat_i[7:0] ;
      else
        u_reg.modem_control_reg <= u_reg.modem_control_reg[7:0] ;
   end
   
   // -- scratch register --
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        u_reg.scratch_reg <= 'h0 ;
      else if(stb_scratch_reg == 1'b1 && we_i == WRITE)
        u_reg.scratch_reg <= dat_i[7:0] ;
      else
        u_reg.scratch_reg <= u_reg.scratch_reg[7:0] ;
   end
   
   // -- scratch register --
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        u_reg.baud_reg <= 'h0 ;
      else if(stb_baud_reg == 1'b1 && we_i == WRITE)
        u_reg.baud_reg <= dat_i[7:0] ;
      else
        u_reg.baud_reg <= u_reg.baud_reg[7:0] ;
   end
   
   // -- read for manual - 4.7 Line Status Register (LSR)
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0) begin
         {u_reg.line_status_reg.data_ready, 
          u_reg.line_status_reg.trans_fifo_empty, 
          u_reg.line_status_reg.trans_empty} <= #1 3'h0 ;
      end 
      else begin
         u_reg.line_status_reg.data_ready       <= #1 fifo_pop_rec.empty == 1'b0 ;
         u_reg.line_status_reg.trans_fifo_empty <= #1 fifo_push_trans.empty ;
         u_reg.line_status_reg.trans_empty      <= #1 fifo_push_trans.empty | trans_buf_empty ;
      end        
   end // always_ff @ (posedge clk_i, negedge nrst_i)
   
   // -- overrun error --
   logic overrun_err_r ;
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        overrun_err_r <= #1 1'b1 ;
      else
        overrun_err_r <= #1 overrun ;
   end
   wire overrun_err_set = overrun & ~overrun_err_r ;
   wire overrun_err_clr = we_i == READ && stb_line_status_reg == 1'b1 ;
   
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        u_reg.line_status_reg.overrun_err <= #1 1'b0 ;
      else if(overrun_err_set == 1'b1)
        u_reg.line_status_reg.overrun_err <= #1 1'b1 ;
      else if(overrun_err_clr == 1'b1)
        u_reg.line_status_reg.overrun_err <= #1 1'b0 ;
      else
        u_reg.line_status_reg.overrun_err <= #1 u_reg.line_status_reg.overrun_err ;
   end  
   
   // -- parity error --
   logic parity_err_r ;
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        parity_err_r <= #1 1'b1 ;
      else
        parity_err_r <= #1  fifo_pop_rec.pop_dat[10] ;
   end
   wire parity_err_set = fifo_pop_rec.pop_dat[10] & ~parity_err_r ;
   wire parity_err_clr = we_i == READ && stb_line_status_reg == 1'b1 ;
   
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        u_reg.line_status_reg.parity_err <= #1 1'b0 ;
      else if(parity_err_set == 1'b1)
        u_reg.line_status_reg.parity_err <= #1 1'b1 ;
      else if(parity_err_clr == 1'b1)
        u_reg.line_status_reg.parity_err <= #1 1'b0 ;
      else
        u_reg.line_status_reg.parity_err <= #1 u_reg.line_status_reg.parity_err ;
   end  
   
   // -- framing error --
   logic framing_err_r ;
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        framing_err_r <= #1 1'b1 ;
      else
        framing_err_r <= #1  fifo_pop_rec.pop_dat[9] ;
   end
   wire framing_err_set = fifo_pop_rec.pop_dat[9] & ~framing_err_r ;
   wire framing_err_clr = we_i == READ && stb_line_status_reg == 1'b1 ;
   
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        u_reg.line_status_reg.framing_err <= #1 1'b0 ;
      else if(framing_err_set == 1'b1)
        u_reg.line_status_reg.framing_err <= #1 1'b1 ;
      else if(framing_err_clr == 1'b1)
        u_reg.line_status_reg.framing_err <= #1 1'b0 ;
      else
        u_reg.line_status_reg.framing_err <= #1 u_reg.line_status_reg.framing_err ;
   end  
   
   // -- break interrupt indicator --
   logic break_intr_r ;
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        break_intr_r <= #1 1'b1 ;
      else
        break_intr_r <= #1  fifo_pop_rec.pop_dat[8] ;
   end
   wire break_intr_set = fifo_pop_rec.pop_dat[8] & ~break_intr_r ;
   wire break_intr_clr = we_i == READ && stb_line_status_reg == 1'b1 ;
   
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        u_reg.line_status_reg.break_intr <= #1 1'b0 ;
      else if(break_intr_set == 1'b1)
        u_reg.line_status_reg.break_intr <= #1 1'b1 ;
      else if(break_intr_clr == 1'b1)
        u_reg.line_status_reg.break_intr <= #1 1'b0 ;
      else
        u_reg.line_status_reg.break_intr <= #1 u_reg.line_status_reg.break_intr ;
   end  
   
   // -- parity error or framing error or break indication --
   logic all_error_r ;
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        all_error_r <= #1 1'b1 ;
      else
        all_error_r <= #1  all_error_rec | overrun ;
   end
   wire all_error_set = all_error_rec & ~all_error_r ;
   wire all_error_clr = we_i == READ && stb_line_status_reg == 1'b1 ;
   
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        u_reg.line_status_reg.all_error <= #1 1'b0 ;
      else if(all_error_set == 1'b1)
        u_reg.line_status_reg.all_error <= #1 1'b1 ;
      else if(all_error_clr == 1'b1)
        u_reg.line_status_reg.all_error <= #1 1'b0 ;
      else
        u_reg.line_status_reg.all_error <= #1 u_reg.line_status_reg.all_error ;
   end  
   
   // -- read for manual - 4.8 Modem Status Register (MSR)
   wire [3:0] modem_cont = {dcd, ri, dsr, cts} ;
   logic [3:0] modem_contl ;
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
       modem_contl <= #1 4'h0 ;
      else
        modem_contl <= #1 modem_cont ;
   end
   
   wire [3:0]  modem_pulse = modem_cont ^ modem_contl ;
   
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        u_reg.modem_status_reg[3:0] <= #1 0 ;
      else if(stb_modem_status_reg == 1'b1 && we_i == READ)
        u_reg.modem_status_reg[3:0] <= #1 0 ;
      else if(modem_pulse != 4'h0) begin
         u_reg.modem_status_reg[3:0] <= #1 modem_pulse ;
      end
      else
        u_reg.modem_status_reg[3:0] <= #1 u_reg.modem_status_reg[3:0] ;
   end
   
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        u_reg.modem_status_reg[7:4] <= #1 0 ;
      else
        u_reg.modem_status_reg[7:4] <= modem_cont ;
   end
   
   // -- read for manual - 4.3 Interrupt Identification Register (IIR) --
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0) begin
         u_reg.interrupt_ident_reg.interrupt_identification <= #1 NO_INTERRUPT ;
         u_reg.interrupt_ident_reg.ignored_74_value_hC <= #1 4'hC ;
      end
      else begin
         priority casex({u_reg.interrupt_pending_reg.receiver_line_status,
                       u_reg.interrupt_pending_reg.receiver_data_available,
                       u_reg.interrupt_pending_reg.timeout_indication,
                       u_reg.interrupt_pending_reg.transmitter_holding_register_empty,
                       u_reg.interrupt_pending_reg.modem_status}) 
           5'b1xxxx : u_reg.interrupt_ident_reg.interrupt_identification <= #1 REC_LINE_STATUS ;
           5'b01xxx : u_reg.interrupt_ident_reg.interrupt_identification <= #1 REC_DATA_AVAILABLE ;
           5'b001xx : u_reg.interrupt_ident_reg.interrupt_identification <= #1 TIME_OUT ;
           5'b0001x : u_reg.interrupt_ident_reg.interrupt_identification <= #1 TRANS_REG_EMPTY ;
           5'b00001 : u_reg.interrupt_ident_reg.interrupt_identification <= #1 MODEM_STATUS ;
           default : u_reg.interrupt_ident_reg <= #1 {4'hC, NO_INTERRUPT} ;
         endcase // case (u_reg.interrupt_pending_reg.receiver_line_status,...
      end // else: !if(nrst_i == 1'b0)
   end
   
   // -- interrupt paending register --
   wire receiver_data_available_reset ;
   logic [4:0] interrupt_pending_reg_set_r ;
   wire [4:0] interrupt_pending_reg_reset
              = {
                 (stb_modem_status_reg == 1'b1 && we_i == 1'b0),
                 ((stb_txd_fifo == 1'b1 && we_i == WRITE) || (stb_interrupt_ident_reg == 1'b1 && we_i == READ)),
                 (stb_rxd_fifo == 1'b1 && we_i == READ),
                 (receiver_data_available_reset == 1'b1),
                 (stb_line_status_reg == 1'b1 && we_i == READ)
                 } ;
   

   wire       modem_status_intr = |modem_pulse[3:0] ;
   wire       transmitter_holding_regster_empty_intr = fifo_pop_trans.empty & trans_buf_empty ;
   wire       timeout_indication_intr = timeout_signal ;
   wire       receiver_data_available_intr = fifo_push_rec.almost_full ;
   //   wire       receiver_line_status_intr = all_error_rec | overrun ;
   wire       receiver_line_status_intr ;
   assign     receiver_line_status_intr = u_reg.line_status_reg.break_intr |
                                          u_reg.line_status_reg.framing_err |
                                          u_reg.line_status_reg.parity_err |
                                          u_reg.line_status_reg.overrun_err ;
   
   wire [4:0] interrupt_pending_reg_set_w
              = {
                 (modem_status_intr == 1'b1                      && u_reg.interrupt_enable_reg.modem_status == 1'b1),
                 (transmitter_holding_regster_empty_intr == 1'b1 && u_reg.interrupt_enable_reg.trans_holding_reg_empty == 1'b1),
                 (timeout_indication_intr == 1'b1                && u_reg.interrupt_enable_reg.rec_data_available == 1'b1),
                 (receiver_data_available_intr == 1'b1           && u_reg.interrupt_enable_reg.rec_data_available == 1'b1),
                 (receiver_line_status_intr == 1'b1              && u_reg.interrupt_enable_reg.rec_line_status == 1'b1)
                 } ;

   wire [4:0] interrupt_pending_reg_set = interrupt_pending_reg_set_w & ~(interrupt_pending_reg_set_r) ;
   
   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        interrupt_pending_reg_set_r <= #1 5'h0 ;
      else
        interrupt_pending_reg_set_r <= #1 interrupt_pending_reg_set_w ;
   end
   assign receiver_data_available_reset = interrupt_pending_reg_set_r[1] & ~interrupt_pending_reg_set_w[1] ;

   always_ff @(posedge clk_i, negedge nrst_i) begin
      if(nrst_i == 1'b0)
        u_reg.interrupt_pending_reg <= #1 5'h00 ;
      else if(interrupt_pending_reg_set != 0)
        u_reg.interrupt_pending_reg <= #1 u_reg.interrupt_pending_reg | interrupt_pending_reg_set ;
      else if(interrupt_pending_reg_reset != 0)
        u_reg.interrupt_pending_reg <= #1 u_reg.interrupt_pending_reg & ~(interrupt_pending_reg_reset) ;
      else
        u_reg.interrupt_pending_reg <= #1 u_reg.interrupt_pending_reg ;
   end  
   
endmodule

/// END OF FILE ///
