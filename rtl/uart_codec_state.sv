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
   *          $Id: uart_codec_state.sv 108 2010-03-30 02:56:26Z hiroshi $         *
   ***************************************************************************** */

`ifdef SYN
/* empty */
`else
timeunit      1ps ;
timeprecision 1ps ;
`endif
import uart_package:: * ;
module uart_codec_state(input  u_reg_t       u_reg,
                        input  u_codec_t     codec,
                        input  wire          receiver_mode,
                        input  wire          timeout_signal,
                        output codec_state_t next_state
                        ) ;
   
   //   import uart_package:: * ;
   
   // -- count state -------------------
   // -  IDLE --> START -> SEND0..SEND6->SEND7->PARITY->STOP
   // -   ^         ^               |      |     ^      ^ |
   // -   |         |               +------+---->+------+ |
   // -   +---------+-------------------------------------+
   // - IDLE -> START  :: transmit data : start bit
   // - STOP -> START  :: transmit data : start bit
   // - START -> SEND0 :: alway
   // - SEND1 -> SEND2 :: alway
   // -  .......
   // - SEND6 -> PARITY :: 7bit && parity  
   // - SEND6 -> STOP   :: 7bit    
   // - SEND6 -> SEND7 :: 8bit 
   // - SEND7 -> PARITY :: 8bit && parity  
   // - SEND7 -> STOP   :: 8bit  
   // - STOP  -> IDLE   :: not start bit
   // ----------------------------------
   always_comb begin
      case (codec.state)
        IDLE : begin
           if(codec.start == 1'b1)
             next_state = START ;
           else
             next_state = IDLE ;
        end
        
        TIMEOUT : begin
           if(codec.start == 1'b1)
             next_state = START ;
           else if(timeout_signal == 1'b1 || u_reg.line_status_reg.data_ready == 1'b0)
             next_state = IDLE ;
           else
             next_state = TIMEOUT ;
        end
        
        START : next_state = SEL_0 ;
        SEL_0 : next_state = SEL_1 ;
        SEL_1 : next_state = SEL_2 ;
        SEL_2 : next_state = SEL_3 ;
        SEL_3 : next_state = SEL_4 ;
        SEL_4 : next_state = SEL_5 ;
        SEL_5 : begin
           if(u_reg.line_control_reg.char_length == CHAR_7_BIT)
             next_state = DATA_END ;
           else
             next_state = SEL_6 ;
        end
        
        SEL_6 : next_state = DATA_END ;
        
        DATA_END : begin
           if(u_reg.line_control_reg.parity_enable == 1'b1)
             next_state = PARITY ;
           else
             next_state = STOP ;
        end
        
        PARITY :  next_state = STOP ;

        STOP : begin
           if(codec.start == 1'b1)
             next_state = START ;
           else if(u_reg.line_status_reg.data_ready == 1'b1 && receiver_mode == 1'b1) 
             next_state = TIMEOUT ;
           else
             next_state = IDLE ;
        end
        default : next_state = IDLE ;
      endcase
   end
endmodule
