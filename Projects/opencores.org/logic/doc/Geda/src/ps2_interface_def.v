////////////////////////////////////////////////////////////////////
//     --------------                                             //
//    /      SOC     \                                            //
//   /       GEN      \                                           //
//  /     COMPONENT    \                                          //
//  ====================                                          //
//  |digital done right|                                          //
//  |__________________|                                          //
//                                                                //
//                                                                //
//                                                                //
//    Copyright (C) <2009>  <Ouabache DesignWorks>                //
//                                                                //
//                                                                //  
//   This source file may be used and distributed without         //  
//   restriction provided that this copyright statement is not    //  
//   removed from the file and that any derivative work contains  //  
//   the original copyright notice and the associated disclaimer. //  
//                                                                //  
//   This source file is free software; you can redistribute it   //  
//   and/or modify it under the terms of the GNU Lesser General   //  
//   Public License as published by the Free Software Foundation; //  
//   either version 2.1 of the License, or (at your option) any   //  
//   later version.                                               //  
//                                                                //  
//   This source is distributed in the hope that it will be       //  
//   useful, but WITHOUT ANY WARRANTY; without even the implied   //  
//   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //  
//   PURPOSE.  See the GNU Lesser General Public License for more //  
//   details.                                                     //  
//                                                                //  
//   You should have received a copy of the GNU Lesser General    //  
//   Public License along with this source; if not, download it   //  
//   from http://www.opencores.org/lgpl.shtml                     //  
//                                                                //  
////////////////////////////////////////////////////////////////////
 module 
  ps2_interface_def 
    #( parameter 
      CLK_HOLD_DELAY=100,
      DATA_SETUP_DELAY=20,
      DEBOUNCE_DELAY=4'b1111,
      FREQ=24)
     (
 input   wire                 clk,
 input   wire                 ps2_clk_pad_in,
 input   wire                 ps2_data_pad_in,
 input   wire                 reset,
 input   wire                 rx_clear,
 input   wire                 tx_write,
 input   wire    [ 7 :  0]        tx_data,
 output   reg                 rx_frame_error,
 output   reg                 rx_full,
 output   reg                 rx_parity_cal,
 output   reg                 rx_parity_error,
 output   reg                 rx_parity_rcv,
 output   reg                 rx_read,
 output   reg                 tx_ack_error,
 output   reg    [ 7 :  0]        rx_data,
 output   wire                 busy,
 output   wire                 ps2_clk_pad_oe,
 output   wire                 ps2_data_pad_oe,
 output   wire                 tx_buffer_empty);
reg                        force_startbit;
reg                        sending;
reg                        usec_delay_done;
reg                        usec_tick;
reg     [ 10 :  0]              frame;
reg     [ 3 :  0]              bit_count;
reg     [ 6 :  0]              usec_delay_count;
reg     [ 7 :  0]              usec_prescale_count;
wire                        cde_serial_rcvr_reset;
wire                        cde_serial_xmit_edge_enable;
wire                        cde_serial_xmit_load;
wire                        enable_usec_delay;
wire                        load_tx_data;
wire                        ps2_clk_fall;
wire                        ps2_clk_rise;
wire                        ps2_clk_s;
wire                        ps2_data_s;
wire                        shift_frame;
wire                        start_xmit;
wire                        x_frame_err;
wire                        x_last_cnt;
wire                        x_parity_calc;
wire                        x_parity_samp;
wire                        x_stop_cnt;
wire     [ 7 :  0]              x_shift_buffer;
cde_serial_rcvr
cde_serial_rcvr 
   (
    .clk      ( clk  ),
    .edge_enable      ( ps2_clk_fall  ),
    .frame_err      ( x_frame_err  ),
    .last_cnt      ( x_last_cnt  ),
    .parity_calc      ( x_parity_calc  ),
    .parity_enable      ( 1'b1  ),
    .parity_force      ( 1'b0  ),
    .parity_samp      ( x_parity_samp  ),
    .parity_type      ( 1'b1  ),
    .reset      ( cde_serial_rcvr_reset  ),
    .ser_in      ( ps2_data_s  ),
    .shift_buffer      ( x_shift_buffer  ),
    .stop_cnt      ( x_stop_cnt  ));
cde_serial_xmit
cde_serial_xmit 
   (
    .buffer_empty      ( tx_buffer_empty  ),
    .clk      ( clk  ),
    .data      ( ~tx_data  ),
    .edge_enable      ( cde_serial_xmit_edge_enable  ),
    .load      ( cde_serial_xmit_load  ),
    .parity_enable      ( 1'b1  ),
    .parity_force      ( 1'b0  ),
    .parity_type      ( 1'b0  ),
    .reset      ( reset  ),
    .ser_out      ( ps2_data_pad_oe  ),
    .start_value      ( 1'b1  ),
    .stop_value      ( 1'b0  ));
cde_sync_with_hysteresis
#( .DEBOUNCE_DELAY (DEBOUNCE_DELAY))
clk_filter 
   (
    .clk      ( clk  ),
    .data_fall      ( ps2_clk_fall  ),
    .data_in      ( ps2_clk_pad_in  ),
    .data_out      ( ps2_clk_s  ),
    .data_rise      ( ps2_clk_rise  ),
    .reset      ( reset  ));
cde_sync_with_hysteresis
#( .DEBOUNCE_DELAY (DEBOUNCE_DELAY))
data_filter 
   (
    .clk      ( clk  ),
    .data_fall      (      ),
    .data_in      ( ps2_data_pad_in  ),
    .data_out      ( ps2_data_s  ),
    .data_rise      (      ),
    .reset      ( reset  ));
assign cde_serial_xmit_edge_enable =( load_tx_data && force_startbit) || ps2_clk_fall ;
assign cde_serial_xmit_load        =  load_tx_data && force_startbit;
assign cde_serial_rcvr_reset       =  reset ||(ps2_clk_s && ps2_data_s && !busy);
always@(posedge clk)
    begin
       if (reset)                                  tx_ack_error <= 1'b0 ;
       else
       if (tx_write)                               tx_ack_error <= 1'b0 ;
       else
       if ((bit_count == 4'b1010)&& ps2_clk_fall)  tx_ack_error <= ps2_data_s && sending ;
       else                                        tx_ack_error <= tx_ack_error ;
    end      
ps2_interface_def_fsm
  #(.NUMBITS(11))
fsm
(
    .clk                        ( clk                         ),          
    .reset                      ( reset                       ),          
    .ps2_idle                   ( ps2_data_s &&   ps2_clk_s   ),  
    .ps2_clk_fall               ( ps2_clk_fall                ),  
    .bit_count                  ( bit_count                   ),
    .write                      ( tx_write                    ),        
    .force_startbit             ( force_startbit              ),
    .usec_delay_done            ( usec_delay_done             ),
    .load_tx_data               ( load_tx_data                ),
    .ps2_clk_oe                 ( ps2_clk_pad_oe              ),
    .busy                       ( busy                        ),
    .shift_frame                ( shift_frame                 ),
    .enable_usec_delay          ( enable_usec_delay           )
);
always@(posedge clk )
if(reset)  
         begin
         usec_prescale_count        <= FREQ-1;
         usec_tick                  <= 1'b0;  
 end
   else
        begin 
         if(enable_usec_delay )
   begin
            if(usec_prescale_count == 0) 
              begin
               usec_prescale_count  <= FREQ-1;
               usec_tick            <= 1'b1;   
      end
            else
      begin
               usec_prescale_count  <= usec_prescale_count - 1;
               usec_tick            <= 1'b0;  
              end
            end 
         else
            begin
            usec_prescale_count     <= FREQ-1;
            usec_tick               <= 1'b0;  
            end 
         end 
always@(posedge clk )
if(reset)                                       force_startbit  <= 1'b0;
   else 
        if(usec_delay_count <= DATA_SETUP_DELAY)        force_startbit  <= 1;
        else                                            force_startbit  <= 0;
 always@(posedge clk )
if(reset)  
          begin
          usec_delay_count        <=  CLK_HOLD_DELAY + DATA_SETUP_DELAY;
          usec_delay_done         <=  0;
          end
   else
        if(enable_usec_delay )
  begin
          if(usec_delay_count == 7'b0000000) 
            begin
            usec_delay_count      <=  usec_delay_count;
            usec_delay_done       <=  1;
    end
          else      
  if(usec_tick)  
    begin
            usec_delay_count      <=  usec_delay_count - 1;
            usec_delay_done       <=  0;
            end
          else
            begin
            usec_delay_count      <=  usec_delay_count;
            usec_delay_done       <=  usec_delay_done;
            end  
          end 
        else
          begin
          usec_delay_count        <=  CLK_HOLD_DELAY + DATA_SETUP_DELAY;
          usec_delay_done         <=  1'b0;
          end 
    always@(posedge clk ) 
      if(reset)               bit_count  <= 4'b0000;
      else
      if(!busy)               bit_count  <= 4'b0000;
      else 
      if(shift_frame)         bit_count  <= bit_count + 1;
      else                    bit_count  <= bit_count; 
    always@(posedge clk ) 
      if(reset)               sending    <= 1'b0;
      else
      if(tx_write)            sending    <= 1'b1;
      else 
      if(busy)                sending    <= sending;
      else                    sending    <= 1'b0; 
   always@(posedge clk)
     if(reset)                    
       begin
        rx_data          <=  8'h00;
        rx_read          <=  1'b0;  
        rx_full          <=  1'b0;
        rx_parity_error  <=  1'b0;
        rx_parity_rcv    <=  1'b0;
rx_parity_cal    <=  1'b0;
        rx_frame_error   <=  1'b0;   
end
     else
     if(rx_clear)      
        begin
        rx_full          <=  1'b0;
        rx_read          <=  1'b0;
        rx_parity_error  <=  1'b0;
rx_parity_cal    <=  1'b0;
        rx_frame_error   <=  1'b0;
        end
     else                    
     if(x_last_cnt && !sending )      
       begin
rx_data          <=   x_shift_buffer;
rx_read          <=  1'b1;  
        rx_full          <=  1'b1;
        rx_parity_error  <=  x_parity_samp ^ x_parity_calc;
        rx_parity_rcv    <=  x_parity_samp;
rx_parity_cal    <=  x_parity_calc;
rx_frame_error   <=  x_frame_err;
        end
     else 
        begin
        rx_full          <=  rx_full;
        rx_read          <=  1'b0;
        rx_parity_error  <=  rx_parity_error;
rx_frame_error   <=  rx_frame_error;
        rx_parity_rcv    <=  rx_parity_rcv;   
        rx_parity_cal    <=  rx_parity_cal;   
rx_data          <=  rx_data;  
        end
  always@(posedge clk)
  if(rx_read)
  $display ("%t %m host    rec    %h parity_rcv %b parity_cal %b parity_error   %b",$realtime,rx_data,rx_parity_rcv,rx_parity_cal,rx_parity_error);
  always@(posedge clk)
  if(!tx_write && load_tx_data && !enable_usec_delay )
  $display ("%t %m host   send    %h ",$realtime,tx_data);
  endmodule
module  ps2_interface_def_fsm
#(parameter NUMBITS=11)
(
input  wire        ps2_idle,  
input  wire        ps2_clk_fall,
input  wire        clk,          
input  wire        reset,          
input  wire [3:0]  bit_count,
input  wire        write,        
input  wire        usec_delay_done,
input  wire        force_startbit,
output reg         load_tx_data,
output reg         ps2_clk_oe,  
output reg         busy,  
output reg         shift_frame,  
output reg         enable_usec_delay  
);
reg  [3:0]         state;   
reg  [3:0]         next_state;      
reg                next_ps2_clk_oe;
always@(posedge clk)
     begin
      if(reset) 
        begin
         busy               <= 0;
         state              <= 4'b0000;
         ps2_clk_oe         <= 0;
         load_tx_data       <= 0;
         shift_frame        <= 0;
         enable_usec_delay  <= 0; 
     end
      else
        begin
         busy               <= !(next_state == 4'b0000);  
         state              <=   next_state;
         ps2_clk_oe         <=   next_ps2_clk_oe;
         load_tx_data       <= ( state == 4'b1000);   
         shift_frame        <= ((next_state == 4'b0010)|| (next_state == 4'b1011));
         enable_usec_delay  <= (!write && ((next_state == 4'b1001) || (next_state == 4'b1000)));   
     end
    end
always @(*)
begin
   next_state         = 4'b0000;
   next_ps2_clk_oe    = 0;
   case (state)
   (4'b0000 ):
              begin
              if(ps2_clk_fall )             next_state            = 4'b0010;
              else 
              if(write)                     next_state            = 4'b1000;               
              else                          next_state            = 4'b0000;
              end 
   (4'b0010):                      next_state            = 4'b0001;
   (4'b0001):
               begin
               if(bit_count == NUMBITS)     next_state            = 4'b0011;
               else 
               if(ps2_clk_fall)             next_state            = 4'b0010;
               else                         next_state            = 4'b0001;
               end 
   (4'b0011):                    next_state            = 4'b0000;
   (4'b1000):
              begin
                                            next_ps2_clk_oe       = 1;
              if(force_startbit )           next_state            = 4'b1001;
              else                          next_state            = 4'b1000;
              end
   (4'b1001):
              begin
                                            next_ps2_clk_oe     = 1;
              if(usec_delay_done)           next_state          = 4'b1010;
              else                          next_state          = 4'b1001;
              end 
   (4'b1010):
               begin
                                            next_ps2_clk_oe     = 0;
               if(ps2_clk_fall)             next_state          = 4'b1011;
               else                         next_state          = 4'b1010;
               end
  (4'b1011):
               begin
                                           next_state           = 4'b1100;
               end
  (4'b1100):
           begin
               if(bit_count == NUMBITS-1)
                         begin
                                           next_state           = 4'b1101;
                         end
               else                                             
                         begin
                         if(ps2_clk_fall)  next_state           = 4'b1011;
                         else              next_state           = 4'b1100;
                         end
           end 
     (4'b1101):
               begin
               if(ps2_clk_fall)            next_state     = 4'b1110;  
               else                        next_state     = 4'b1101;
               end
     (4'b1110):
               begin
               if(ps2_idle)                next_state      = 4'b0000;
               else                        next_state      = 4'b1110;
               end 
           default :                       next_state  = 4'b0000;
     endcase // case (state)
     end 
endmodule 
