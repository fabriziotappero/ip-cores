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
   *          $Id: uart_package.sv 108 2010-03-30 02:56:26Z hiroshi $         *
   ***************************************************************************** */

package uart_package ;
`ifdef SYN
 /* empty */
`else
   timeunit      1ps ;
   timeprecision 1ps ;
`endif

   localparam   UART_RXD               =  'h0 ;
   localparam   UART_TXD               =  'h0 ;
   localparam   UART_INTERRUPT_ENABLE  =  'h1 ;
   localparam   UART_INTERRUPT_IDENT   =  'h2 ;
   localparam   UART_FIFO_CONTROL      =  'h2 ;
   localparam   UART_LINE_CONTROL      =  'h3 ;
   localparam   UART_MODEM_CONTROL     =  'h4 ;
   localparam   UART_LINE_STATUS       =  'h5 ;
   localparam   UART_MODEM_STATUS      =  'h6 ;
   localparam   UART_SCRATCH           =  'h7 ;
   localparam   UART_BAUD              =  'h0 ;
   
typedef enum logic [3:0] {
                          IDLE,
                          TIMEOUT,
                          STOP,
                          START,
                          SEL_0,
                          SEL_1,
                          SEL_2,
                          SEL_3,
                          SEL_4,
                          SEL_5,
                          SEL_6,
                          DATA_END,
                          PARITY
                          } codec_state_t ;

// -- read for manual - 4.5 Line Control Register (LCR) --
typedef enum logic [1:0] {
                          CHAR_8_BIT   = 2'b11,
                          CHAR_7_BIT   = 2'b10,
                          CHAR_6_BIT   = 2'b01,
                          CHAR_5_BIT   = 2'b00
                          } char_length_t ;

// -- read for manual - 4.3 Interrupt Identification Register (IIR) --
typedef enum logic [3:0] {
                          REC_LINE_STATUS     = 4'b0110,
                          REC_DATA_AVAILABLE  = 4'b0100,
                          TIME_OUT            = 4'b1100,
                          TRANS_REG_EMPTY     = 4'b0010,
                          MODEM_STATUS        = 4'b0000,
                          NO_INTERRUPT        = 4'b0001   // -- bit 0 -> "1" no interrupt pending
                          } interrupt_identification_t ;

typedef struct packed {
                       logic [3:0] ignored_74_bit ;
                       logic modem_status ;
                       logic rec_line_status ;
                       logic trans_holding_reg_empty ;
                       logic rec_data_available ;
                       } interrupt_enable_reg_t ;

typedef struct packed {
                       logic [3:0] ignored_74_value_hC ;
                       interrupt_identification_t  interrupt_identification ;
                       } interrupt_identification_reg_t ;

typedef struct packed {
                       logic modem_status ;
                       logic transmitter_holding_register_empty ;
                       logic timeout_indication ;
                       logic receiver_data_available ;
                       logic receiver_line_status ;
                       } interrupt_pending_reg_t ;

// -- read for manual - 4.4 FIFO Control Register (FCR) --
typedef enum logic [1:0] {
                          BYTE_1  = 2'b00,
                          BYTE_4  = 2'b01,
                          BYTE_8  = 2'b10,
                          BYTE_14 = 2'b11
                          } define_fifo_trigger_level_t ;

typedef struct packed {
                       define_fifo_trigger_level_t define_fifo_trigger_level ;
                       logic [2:0]                 ignored_53_bit ;
                       logic                       transmitter_fifo_reset ;
                       logic                       receiver_fifo_reset ;
                       logic                       ignored_0_bit ;
                       } fifo_control_reg_t ;

typedef struct packed {
                       logic         divisor_access ;
                       logic         break_control_bit ;
                       logic         stick_parity ;
                       logic         even_parity ;
                       logic         parity_enable ;
                       logic         stop_bit_count ;
                       char_length_t char_length ;
                       } line_control_reg_t ;

typedef struct packed {
                       logic [2:0]  ignored_75_bit ;
                       logic loopback ;
                       logic out2 ;
                       logic out1 ;
                       logic rts ;
                       logic dtr ;
                       } modem_control_reg_t ;

typedef struct packed {
                       logic        all_error ;
                       logic        trans_empty ;
                       logic        trans_fifo_empty ;
                       logic        break_intr ;
                       logic        framing_err ;
                       logic        parity_err ;
                       logic        overrun_err ;
                       logic        data_ready ;
                       } line_status_reg_t ;

typedef struct packed {
                       logic dcd ;
                       logic ri ;
                       logic dsr ;
                       logic cts ;
                       logic dcd_indicator ;
                       logic ri_indicator ;
                       logic dsr_indicator ;
                       logic cts_indicator ;
                       } modem_status_reg_t ;

typedef struct packed{
                      interrupt_enable_reg_t          interrupt_enable_reg ;
                      interrupt_identification_reg_t  interrupt_ident_reg ;
                      fifo_control_reg_t              fifo_control_reg ;
                      modem_control_reg_t             modem_control_reg ;
                      line_control_reg_t              line_control_reg ;
                      line_status_reg_t               line_status_reg ;
                      modem_status_reg_t              modem_status_reg ;
                      interrupt_pending_reg_t         interrupt_pending_reg ;
                      logic [7:0]                     scratch_reg ;
                      logic [7:0]                     baud_reg ;
                      } u_reg_t ;

typedef struct packed{
                      logic [7:0]   data_r ;
                      logic         start ;
                      logic         line ;
                      logic         framing_err ;
                      logic         parity_err ;
                      logic         break_err ;
                      codec_state_t state ;
                      } u_codec_t ;
endpackage : uart_package

