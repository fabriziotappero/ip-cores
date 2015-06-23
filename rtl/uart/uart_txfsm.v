//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores UART Interface Module                       ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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


// UART tx state machine

module uart_txfsm (
             reset_n        ,
             baud_clk_16x   ,

             cfg_tx_enable  ,
             cfg_stop_bit   ,
             cfg_pri_mod    ,

       // FIFO control signal
             fifo_empty     ,
             fifo_rd        ,
             fifo_data      ,

          // Line Interface
             so  
          );


input             reset_n        ; // active low reset signal
input             baud_clk_16x   ; // baud clock-16x

input             cfg_tx_enable  ; // transmit interface enable
input             cfg_stop_bit   ; // stop bit 
                                   // 0 --> 1 stop, 1 --> 2 Stop
input   [1:0]     cfg_pri_mod    ;// Priority Mode
                                   // 2'b00 --> None
                                   // 2'b10 --> Even priority
                                   // 2'b11 --> Odd priority

//--------------------------------------
//   FIFO control signal
//--------------------------------------
input             fifo_empty     ; // fifo empty
output            fifo_rd        ; // fifo read, assumed no back to back read
input  [7:0]      fifo_data      ; // fifo read data

// Line Interface
output            so             ;  // txd pin


reg  [2:0]         txstate       ; // tx state
reg                so            ; // txd pin
reg  [7:0]         txdata        ; // local txdata
reg                fifo_rd       ; // Fifo read enable
reg  [2:0]         cnt           ; // local data cont
reg  [3:0]         divcnt        ; // clock div count

parameter idle_st      = 3'b000;
parameter xfr_data_st  = 3'b001;
parameter xfr_pri_st   = 3'b010;
parameter xfr_stop_st1 = 3'b011;
parameter xfr_stop_st2 = 3'b100;


always @(negedge reset_n or posedge baud_clk_16x)
begin
   if(reset_n == 1'b0) begin
      txstate  <= idle_st;
      so       <= 1'b1;
      cnt      <= 3'b0;
      txdata   <= 8'h0;
      fifo_rd  <= 1'b0;
      divcnt   <= 4'b0;
   end
   else begin
      divcnt <= divcnt+1;
      if(divcnt == 4'b0000) begin // Do at once in 16 clock
         case(txstate)
          idle_st      : begin
               if(!fifo_empty && cfg_tx_enable) begin
                  so       <= 1'b0 ; // Start bit
                  cnt      <= 3'b0;
                  fifo_rd  <= 1'b1;
                  txdata   <= fifo_data;
                  txstate  <= xfr_data_st;  
               end
            end

          xfr_data_st  : begin
              fifo_rd  <= 1'b0;
              so   <= txdata[cnt];
              cnt  <= cnt+1;
              if(cnt == 7) begin
                 if(cfg_pri_mod == 2'b00) begin // No Priority
                    txstate  <= xfr_stop_st1;  
                 end
                 else begin
                    txstate <= xfr_pri_st;  
                 end
              end
           end

          xfr_pri_st   : begin
               if(cfg_pri_mod == 2'b10)  // even priority
                   so <= ^txdata;
               else begin // Odd Priority
                   so <= ~(^txdata);
               end
               txstate  <= xfr_stop_st1;  
            end

          xfr_stop_st1  : begin // First Stop Bit
               so <= 1;
               if(cfg_stop_bit == 0)  // 1 Stop Bit
                    txstate <= idle_st;
               else // 2 Stop Bit 
                  txstate  <= xfr_stop_st2;
            end

          xfr_stop_st2  : begin // Second Stop Bit
               so <= 1;
               txstate <= idle_st;
            end
         endcase
      end
     else begin
        fifo_rd  <= 1'b0;
     end
   end
end


endmodule
