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
   *          $Id: uart_test.sv 112 2010-03-30 04:37:33Z hiroshi $         *
   ***************************************************************************** */
   
#(STEP*100) ;
$display("char7 pari non, buad rate setup 19200bps") ;
$fdisplay(file_a, "char7 pari non, buad rate setup 19200bps") ;

UART_R = 0 ; // all cleaer register

$display("fifo trigger level 14byte") ;
$fdisplay(file_a, "fifo trigger level 14byte") ;
UART_R.fifo_control_reg.define_fifo_trigger_level = BYTE_14  ;
wb_DUT.write( UART_R.fifo_control_reg, UART_FIFO_CONTROL) ;
wb_BENCH.write(UART_R.fifo_control_reg, UART_FIFO_CONTROL) ;


UART_R.line_control_reg.divisor_access = 1'b1 ;
UART_R.baud_reg = 8'd64 ; // 19200bps
wb_BENCH.write(UART_R.line_control_reg,  UART_LINE_CONTROL) ;
wb_BENCH.write(UART_R.baud_reg,  UART_BAUD) ;
wb_DUT.write(UART_R.line_control_reg,  UART_LINE_CONTROL) ;
wb_DUT.write(UART_R.baud_reg,  UART_BAUD) ;
// --
UART_R.line_control_reg.divisor_access = 1'b0 ;
UART_R.line_control_reg.char_length = CHAR_7_BIT ;
UART_R.line_control_reg.parity_enable   = 1'b0 ;
UART_R.line_control_reg.even_parity = 1'b1 ;
wb_BENCH.write(UART_R.line_control_reg,  UART_LINE_CONTROL) ;
wb_DUT.write(  UART_R.line_control_reg,  UART_LINE_CONTROL) ;

UART_R.interrupt_enable_reg.trans_holding_reg_empty = 1'b1 ;
wb_DUT.write(UART_R.interrupt_enable_reg, UART_INTERRUPT_ENABLE) ;
wb_DUT.nop() ;
wdat = 1 ;

for(i=0;i<8;i+=1) begin
   wb_DUT.write(wdat<<i, UART_TXD) ;
end

@(posedge intr_o) ;
#(STEP*13000) ;

for(i=0;i<8;i+=1) begin
   wb_BENCH.read(rdat, UART_RXD) ;
   $display("read data = %x", rdat) ;
   $fdisplay(file_a, "read data = %x", rdat) ;
end

$display("fifo clear") ;
$fdisplay(file_a, "fifo clear") ;
UART_R.fifo_control_reg.transmitter_fifo_reset = 1'b1 ;
UART_R.fifo_control_reg.receiver_fifo_reset = 1'b1 ;
wb_DUT.write( UART_R.fifo_control_reg, UART_FIFO_CONTROL) ;
wb_BENCH.write(UART_R.fifo_control_reg, UART_FIFO_CONTROL) ;


$display("char7 pari even") ;
$fdisplay(file_a, "char7 pari even") ;
UART_R.line_control_reg.parity_enable   = 1'b1 ;
UART_R.line_control_reg.even_parity = 1'b1 ;
wb_BENCH.write(UART_R.line_control_reg,  UART_LINE_CONTROL) ;
wb_DUT.write(  UART_R.line_control_reg,  UART_LINE_CONTROL) ;


wb_DUT.nop() ;
wdat = 1 ;
for(i=0;i<8;i+=1) begin
   wb_DUT.write(wdat<<i, UART_TXD) ;
end

@(posedge intr_o) ;
#(STEP*13000) ;

$display("char7 pari odd") ;
$fdisplay(file_a, "char7 pari odd") ;

UART_R.line_control_reg.even_parity = 1'b0 ;
wb_BENCH.write(UART_R.line_control_reg,  UART_LINE_CONTROL) ;
wb_DUT.write(  UART_R.line_control_reg,  UART_LINE_CONTROL) ;
wb_DUT.nop() ;
wdat = 1 ;
for(i=0;i<8;i+=1) begin
   wb_DUT.write(wdat<<i, UART_TXD) ;
end

@(posedge intr_o) ;
#(STEP*13000) ;

for(i=0;i<16;i+=1) begin
   wb_BENCH.read(rdat, UART_RXD) ;
   $display("read data = %x", rdat) ;
   $fdisplay(file_a, "read data = %x", rdat) ;
end

#(STEP*300) ;

$display("fifo clear") ;
$fdisplay(file_a, "fifo clear") ;
UART_R.fifo_control_reg.transmitter_fifo_reset = 1'b1 ;
UART_R.fifo_control_reg.receiver_fifo_reset = 1'b1 ;
wb_DUT.write(  UART_R.fifo_control_reg, UART_FIFO_CONTROL) ;
wb_BENCH.write(UART_R.fifo_control_reg, UART_FIFO_CONTROL) ;


UART_R.interrupt_enable_reg.trans_holding_reg_empty = 1'b1 ;
wb_BENCH.write(UART_R.interrupt_enable_reg, UART_INTERRUPT_ENABLE) ;

UART_R.interrupt_enable_reg.trans_holding_reg_empty = 1'b0 ;
UART_R.interrupt_enable_reg.rec_data_available = 1'b1 ;
wb_DUT.write(UART_R.interrupt_enable_reg, UART_INTERRUPT_ENABLE) ;


wb_DUT.read(rdat, UART_INTERRUPT_IDENT) ;


wb_DUT.nop() ;

for(i=0;i<4;i+=1) begin
   wb_BENCH.write(wdat<<i, UART_TXD) ;
end


@(posedge intr_o) ;

$display("timeout intr -> accept") ;
$fdisplay(file_a, "timeout intr -> accept") ;
wb_DUT.read(rdat, UART_LINE_STATUS) ;
$display("line_status = %b", rdat) ;
$fdisplay(file_a, "line_status = %b", rdat) ;

wb_DUT.read(rdat, UART_INTERRUPT_IDENT) ;
$display("interrupt_ident = %b", rdat) ;
$fdisplay(file_a, "interrupt_ident = %b", rdat) ;

wb_DUT.read(rdat, UART_RXD) ;
wb_DUT.read(rdat, UART_INTERRUPT_IDENT) ;
$display("interrupt_ident = %b", rdat) ;
$fdisplay(file_a, "interrupt_ident = %b", rdat) ;

#(STEP*500) ;


