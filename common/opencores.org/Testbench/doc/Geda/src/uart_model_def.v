/**********************************************************************/
/*                                                                    */
/*             -------                                                */
/*            /   SOC  \                                              */
/*           /    GEN   \                                             */
/*          /     SIM    \                                            */
/*          ==============                                            */
/*          |            |                                            */
/*          |____________|                                            */
/*                                                                    */
/*  Clock and Reset generator for simulations                          */
/*                                                                    */
/*                                                                    */
/*  Author(s):                                                        */
/*      - John Eaton, jt_eaton@opencores.org                          */
/*                                                                    */
/**********************************************************************/
/*                                                                    */
/*    Copyright (C) <2010>  <Ouabache Design Works>                   */
/*                                                                    */
/*  This source file may be used and distributed without              */
/*  restriction provided that this copyright statement is not         */
/*  removed from the file and that any derivative work contains       */
/*  the original copyright notice and the associated disclaimer.      */
/*                                                                    */
/*  This source file is free software; you can redistribute it        */
/*  and/or modify it under the terms of the GNU Lesser General        */
/*  Public License as published by the Free Software Foundation;      */
/*  either version 2.1 of the License, or (at your option) any        */
/*  later version.                                                    */
/*                                                                    */
/*  This source is distributed in the hope that it will be            */
/*  useful, but WITHOUT ANY WARRANTY; without even the implied        */
/*  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR           */
/*  PURPOSE.  See the GNU Lesser General Public License for more      */
/*  details.                                                          */
/*                                                                    */
/*  You should have received a copy of the GNU Lesser General         */
/*  Public License along with this source; if not, download it        */
/*  from http://www.opencores.org/lgpl.shtml                          */
/*                                                                    */
/**********************************************************************/
 module 
  uart_model_def 
    #( parameter 
      CLKCNT=4'h5,
      SIZE=4)
     (
 input   wire                 clk,
 input   wire                 reset,
 input   wire                 txd_in,
 output   wire                 rxd_out);
reg                        exp_rx_parity_err;
reg                        mask_rx_parity_err;
reg     [ 7 :  0]              exp_rx_shift_buffer;
reg     [ 7 :  0]              mask_rx_shift_buffer;
wire                        drv_rx_parity_err;
wire                        prb_rx_parity_err;
wire     [ 7 :  0]              drv_rx_shift_buffer;
wire     [ 7 :  0]              prb_rx_shift_buffer;
io_probe_def
#( .MESG ("uart parity Error"),
   .WIDTH (1))
rx_parity_err_prb 
   (
    .clk      ( clk  ),
    .drive_value      ( drv_rx_parity_err  ),
    .expected_value      ( exp_rx_parity_err  ),
    .mask      ( mask_rx_parity_err  ),
    .signal      ( prb_rx_parity_err  ));
io_probe_def
#( .MESG ("uart data receive  Error"),
   .WIDTH (8))
rx_shift_buffer_prb 
   (
    .clk      ( clk  ),
    .drive_value      ( drv_rx_shift_buffer[7:0] ),
    .expected_value      ( exp_rx_shift_buffer[7:0] ),
    .mask      ( mask_rx_shift_buffer[7:0] ),
    .signal      ( prb_rx_shift_buffer[7:0] ));
reg              rx_parity_enable;               // 0 = no parity bit sent; 1= parity bit sent
reg              rx_parity    ; 
reg              rx_force_parity    ; 
reg              rx_stop_value;                  // value out for stop bit 
reg              rx_start_detect;
reg [7:0]        rx_shift_buffer;
reg              rx_parity_calc;
reg              rx_parity_samp;
reg              rx_parity_error;
reg              rx_frame_err;
reg              exp_rx_frame_err;
reg              mask_rx_frame_err;
reg              rx_frame_rdy;
reg              rx_baud_enable;   
wire             rx_stop_cnt;
wire             rx_last_cnt;
wire [7:0]       next_rx_shift_buffer;   
wire             next_rx_parity_calc;  
wire             next_rx_parity_samp;   
wire             next_rx_frame_err;
reg              rxd_pad_sig;
reg [1:0]        rx_rdy_del;   
reg [SIZE-1:0]   rx_baudgen;
reg              edge_enable;
reg  [SIZE-1:0]  divide_cnt;
   wire xmit_enable;
reg         txd_parity_enable; 
reg         txd_force_parity; 
reg         txd_parity;
reg         txd_load;         
reg         txd_break;                  
reg  [7:0]  txd_data_in;                        
wire        txd_buffer_empty;                
//
//   watch for start bit
//  
always@(posedge clk)
  if(reset)
  begin
   rx_parity_enable     <= 1'b0; 
   rx_parity            <= 1'b0;
   rx_force_parity      <= 1'b0;
   rx_stop_value        <= 1'b1;    
   exp_rx_frame_err     <= 1'b0; 
   exp_rx_parity_err    <= 1'b0; 
   exp_rx_shift_buffer  <= 8'h00;
   mask_rx_frame_err    <= 1'b0; 
   mask_rx_parity_err   <= 1'b0; 
   mask_rx_shift_buffer <= 8'h00;     
   txd_parity_enable    <= 1'b0;
   txd_force_parity     <= 1'b0;
   txd_parity           <= 1'b0;
   txd_load             <= 1'b0;
   txd_break            <= 1'b0;                 
   txd_data_in          <= 8'h00;                     
  end
wire    prb_rx_frame_err; 
assign  prb_rx_shift_buffer =  rx_shift_buffer;  
assign  prb_rx_frame_err    =  rx_frame_err; 
assign  prb_rx_parity_err   =  rx_parity_error;    
assign  drv_rx_shift_buffer =  8'bzzzzzzzz;
assign  drv_rx_parity_err   =  1'bz;
/*
io_probe_def 
#(.MESG   ("uart data receive error"),
  .WIDTH  (8)
  )
rx_shift_buffer_prb   
(
  .clk           ( clk ),
  .drive_value   ( drv_rx_shift_buffer ), 
  .expected_value( exp_rx_shift_buffer ),
  .mask          ( mask_rx_shift_buffer),
  .signal        ( prb_rx_shift_buffer )
);      
io_probe_def 
#(.MESG   ("uart parity error"))
rx_parity_err_prb   
(
  .clk           ( clk ),
  .drive_value   ( drv_rx_parity_err ), 
  .expected_value( exp_rx_parity_err ),
  .mask          ( mask_rx_parity_err),
  .signal        ( prb_rx_parity_err )
);      
*/
always@(posedge clk)
if(reset)                 rx_baudgen <= CLKCNT;
else 
if(rx_baudgen == 4'h0)    rx_baudgen <= CLKCNT;
else                      rx_baudgen <= rx_baudgen - 1'h1;  
always@(posedge clk)
if(reset)                 edge_enable <= 1'b0;
else                      edge_enable <= (rx_baudgen == {SIZE{1'b0}});
always@(posedge clk)
if(reset)                                              rxd_pad_sig <= 1'b1;
else                                                   rxd_pad_sig <= txd_in;
always@(posedge clk)
if(reset)                                              rx_start_detect <= 1'b0;
else
if(rx_start_detect)  
  begin
    if(rx_stop_cnt  && edge_enable )                      rx_start_detect <= !rxd_pad_sig;
    else
    if(rx_last_cnt)                                       rx_start_detect <= 1'b0;
    else                                               rx_start_detect <= 1'b1;
  end
else
if(!rxd_pad_sig )                                      rx_start_detect <= 1'b1;
else                                                   rx_start_detect <= rx_start_detect;
always@(posedge clk)
  if(reset)
    begin
    rx_frame_rdy <= 1'b0;
    rx_rdy_del   <= 2'b00;
    end
  else
    begin
    rx_frame_rdy <=  rx_rdy_del[1] ;
    rx_rdy_del   <=  {rx_rdy_del[0],rx_last_cnt};
    end
uart_model_serial_rcvr
#(.WIDTH(8),  .SIZE(4) )  
serial_rcvr
 (
     .clk              ( clk                ), 
     .reset            ( reset              ),
     .edge_enable      ( rx_baud_enable        ),                 
     .parity_enable    ( rx_parity_enable      ),               
     .parity_type      ( {rx_force_parity, rx_parity }    ),                 
     .stop_cnt         ( rx_stop_cnt           ),                  
     .last_cnt         ( rx_last_cnt           ),                  
     .stop_value       ( rx_stop_value         ),                  
     .ser_in           ( txd_in             ),                      
     .shift_buffer     ( next_rx_shift_buffer  ),
     .parity_calc      ( next_rx_parity_calc   ),
     .parity_samp      ( next_rx_parity_samp   ),
     .frame_err        ( next_rx_frame_err     )
);  
always@(posedge clk)
  if( reset || (!rx_start_detect))    rx_baud_enable    <= 1'b0;
  else
  if(!edge_enable)                    rx_baud_enable    <= 1'b0;  
  else                                rx_baud_enable    <=  ( divide_cnt == 4'b1000 );       
always@(posedge clk)
  if( reset || (!rx_start_detect))    divide_cnt    <= 4'b1111;
  else
  if(!edge_enable)                    divide_cnt    <= divide_cnt;
  else
  if(!(|divide_cnt))                  divide_cnt    <= 4'b1111;
  else                                divide_cnt    <= divide_cnt - 'b1;
always@(posedge clk)
  if(reset)
     begin
          rx_shift_buffer   <=  8'h00;  
          rx_parity_calc    <=  1'b0;
          rx_parity_samp    <=  1'b0;
          rx_parity_error   <=  1'b0;
          rx_frame_err      <=  1'b0;
     end
  else
  if(rx_last_cnt )
      begin
          rx_shift_buffer   <=  next_rx_shift_buffer;  
          rx_parity_calc    <=  next_rx_parity_calc;
          rx_parity_samp    <=  next_rx_parity_samp;
	  rx_parity_error   <=  (next_rx_parity_samp ^ next_rx_parity_calc) && rx_parity_enable;
          rx_frame_err      <=  next_rx_frame_err;
      end
  else
     begin
          rx_shift_buffer   <=  rx_shift_buffer;  
          rx_parity_calc    <=  rx_parity_calc;
          rx_parity_samp    <=  rx_parity_samp;
          rx_parity_error   <=  rx_parity_error;
          rx_frame_err      <=  rx_frame_err;
      end
/////////////////  Xmit
uart_model_divider
#(.SIZE(4))  
x_divider  (
         .clk             ( clk             ),
         .reset           ( reset           ),
	 .divider_in      ( 4'b1111         ),
         .enable          ( edge_enable     ),
	 .divider_out     ( xmit_enable     )
         );
uart_model_serial_xmit
serial_xmit (
               .clk              ( clk                              ),
               .reset            ( reset                            ),
               .edge_enable      ( xmit_enable                      ),                 
               .parity_enable    ( txd_parity_enable                ),               
               .two_stop_enable  ( 1'b0                             ),             
               .parity_type      ( {txd_force_parity, txd_parity }  ),                 
               .load             ( txd_load                         ),                        
               .start_value      ( 1'b0                             ),                 
               .stop_value       (!txd_break                        ),                  
               .data             ( txd_data_in                      ),                        
               .buffer_empty     ( txd_buffer_empty                 ),                
               .ser_out          ( rxd_out                          )            
                );
task next;
  input [31:0] num;
  repeat (num)       @ (posedge clk);       
endtask
task wait_tx;
begin
  while(!txd_buffer_empty) next(1);
end
endtask // wait_tx
task send_byte;
  input [7:0] byte_out;
begin
  while(!txd_buffer_empty) next(1);
  $display("%t %m        %2h",$realtime ,byte_out  );
  txd_data_in  = byte_out;
  next(1);
  txd_load   = 1'b1;
  next(1);
  txd_load   = 1'b0;
  next(1);
end
endtask // send_byte
task rcv_byte;
  input [7:0] byte_in;
   begin
   exp_rx_shift_buffer <= byte_in;  
   while(!rx_frame_rdy)  next(1);
   $display("%t %m check   %h   %h ",$realtime,rx_shift_buffer,byte_in); 
   mask_rx_frame_err    <= 1'b1; 
   mask_rx_parity_err   <= 1'b1; 
   mask_rx_shift_buffer <= 8'hff;        
   next(1);
   mask_rx_frame_err    <= 1'b0; 
   mask_rx_parity_err   <= 1'b0; 
   mask_rx_shift_buffer <= 8'h00;        
end
endtask
  endmodule
/**********************************************************************/
/*                                                                    */
/*             -------                                                */
/*            /   SOC  \                                              */
/*           /    GEN   \                                             */
/*          /     LIB    \                                            */
/*          ==============                                            */
/*          |            |                                            */
/*          |____________|                                            */
/*                                                                    */
/*  Generic model for a serial asynchronous receiver                  */
/*                                                                    */
/*  Author(s):                                                        */
/*      - John Eaton, jt_eaton@opencores.org                          */
/*                                                                    */
/**********************************************************************/
/*                                                                    */
/*    Copyright (C) <2010>  <Ouabache Design Works>                   */
/*                                                                    */
/*  This source file may be used and distributed without              */
/*  restriction provided that this copyright statement is not         */
/*  removed from the file and that any derivative work contains       */
/*  the original copyright notice and the associated disclaimer.      */
/*                                                                    */
/*  This source file is free software; you can redistribute it        */
/*  and/or modify it under the terms of the GNU Lesser General        */
/*  Public License as published by the Free Software Foundation;      */
/*  either version 2.1 of the License, or (at your option) any        */
/*  later version.                                                    */
/*                                                                    */
/*  This source is distributed in the hope that it will be            */
/*  useful, but WITHOUT ANY WARRANTY; without even the implied        */
/*  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR           */
/*  PURPOSE.  See the GNU Lesser General Public License for more      */
/*  details.                                                          */
/*                                                                    */
/*  You should have received a copy of the GNU Lesser General         */
/*  Public License along with this source; if not, download it        */
/*  from http://www.opencores.org/lgpl.shtml                          */
/*                                                                    */
/**********************************************************************/
module 
uart_model_serial_rcvr
#(parameter   WIDTH=8,           // Number of data bits
  parameter   SIZE=4             // binary size of shift_cnt, must be able to hold  WIDTH + 4 states       
 )(
input  wire               clk,
input  wire               reset,
input  wire               edge_enable,                 // one pulse per bit time for 16 x data rate timing
input  wire               parity_enable,               // 0 = no parity bit sent, 1= parity bit sent
input  wire   [1:0]       parity_type,                 // 00= odd,01=even,10=force a 0,11= force a 1
input  wire               stop_value,                  // value out for stop bit
input  wire               ser_in,                      // from pad_ring
output  reg   [WIDTH-1:0] shift_buffer,
output  reg               stop_cnt,
output  reg               last_cnt,
output  reg               parity_calc,
output  reg               parity_samp,
output  reg               frame_err
);  
reg           [SIZE-1:0]  shift_cnt;
//
//   shift_cnt controls the serial bit out
//  
//   0           Start bit  
//   1-> WIDTH   Data bit lsb first
//   WIDTH+1     Parity bit if enabled
//   2^SIZE-2    Second stop bit if enabled
//   2^SIZE-1    Last stop bit and idle
always@(posedge clk)
  if( reset )                                 
    begin
    shift_cnt       <= {SIZE{1'b1}};
    last_cnt        <= 1'b0;
    end
  else
  if(!edge_enable)
    begin    
    shift_cnt       <= shift_cnt;
    last_cnt        <= 1'b0;       
    end
  else
  if(( shift_cnt ==  {SIZE{1'b1}}))      
   begin    
    shift_cnt       <= {SIZE{1'b0}};
    last_cnt        <= 1'b0;      
   end
  else
  if ( shift_cnt == WIDTH)               
    case( parity_enable )        
      (1'b0):                 
        begin
        shift_cnt   <= {SIZE{1'b1}};
        last_cnt    <= 1'b1;
        end
      (1'b1):
        begin                      
        shift_cnt   <= shift_cnt + 1'b1;
        last_cnt    <= 1'b0;
        end 
   endcase // case (parity_enable)
  else
  if ( shift_cnt == (WIDTH+1))
     begin      
     shift_cnt      <= {SIZE{1'b1}};
     last_cnt       <= 1'b1;
     end
  else  
     begin             
     shift_cnt      <= shift_cnt + 1'b1;
     last_cnt       <= 1'b0;
     end
//
//
//   load shift_buffer during start_bit
//   shift down every bit
//   
//   
always@(posedge clk)
  if(reset)                                                        shift_buffer <= {WIDTH{1'b0}};
  else
  if(!edge_enable)                                                 shift_buffer <= shift_buffer;
  else
  if(shift_cnt == {SIZE{1'b1}})                                    shift_buffer <= {WIDTH{1'b0}};
  else
  if(shift_cnt <= WIDTH-1 )                                        shift_buffer <= {ser_in,shift_buffer[WIDTH-1:1]};
  else                                                             shift_buffer <= shift_buffer;
//
//
//   calculate parity on the fly
//   seed reg with 0 for odd and 1 for even
//   force reg to 0 or 1 if needed  
//   
always@(posedge clk)
  if(reset)                                                        parity_calc <= 1'b0;
  else
  if(!edge_enable)                                                 parity_calc <= parity_calc;
  else
  if(parity_type[1] || (shift_cnt == {SIZE{1'b1}}))                parity_calc <= parity_type[0];
  else
  if(shift_cnt <= WIDTH-1 )                                        parity_calc <= parity_calc ^ ser_in;
  else                                                             parity_calc <= parity_calc;
//   
//   sample parity bit and hold it until next start bit
//   
always@(posedge clk)
  if(reset)                                                        parity_samp <= 1'b0;
  else
  if(!edge_enable)                                                 parity_samp <= parity_samp;
  else
  if(shift_cnt == {SIZE{1'b1}})                                    parity_samp <= 1'b0;
  else
  if(shift_cnt == WIDTH  )                                         parity_samp <= ser_in;
  else                                                             parity_samp <= parity_samp;
//   
//   check for stop bit error
//   
always@(posedge clk)
  if(reset)                                                        frame_err <= 1'b0;
  else
  if(!edge_enable)                                                 frame_err <= frame_err;
  else
  if(shift_cnt == {SIZE{1'b1}})                                    frame_err <= 1'b0;
  else
  if(shift_cnt == WIDTH+1  )                                       frame_err <= ser_in ^ stop_value;
  else                                                             frame_err <= frame_err;
always@(*)
  if(  shift_cnt ==  {SIZE{1'b1}})                                 stop_cnt    = 1'b1;
  else                                                             stop_cnt    = 1'b0;
endmodule
/**********************************************************************/
/*                                                                    */
/*             -------                                                */
/*            /   SOC  \                                              */
/*           /    GEN   \                                             */
/*          /     LIB    \                                            */
/*          ==============                                            */
/*          |            |                                            */
/*          |____________|                                            */
/*                                                                    */
/*  Generic model for a serial asynchronous transmitter               */
/*                                                                    */
/*  Author(s):                                                        */
/*      - John Eaton, jt_eaton@opencores.org                          */
/*                                                                    */
/**********************************************************************/
/*                                                                    */
/*    Copyright (C) <2010>  <Ouabache Design Works>                   */
/*                                                                    */
/*  This source file may be used and distributed without              */
/*  restriction provided that this copyright statement is not         */
/*  removed from the file and that any derivative work contains       */
/*  the original copyright notice and the associated disclaimer.      */
/*                                                                    */
/*  This source file is free software; you can redistribute it        */
/*  and/or modify it under the terms of the GNU Lesser General        */
/*  Public License as published by the Free Software Foundation;      */
/*  either version 2.1 of the License, or (at your option) any        */
/*  later version.                                                    */
/*                                                                    */
/*  This source is distributed in the hope that it will be            */
/*  useful, but WITHOUT ANY WARRANTY; without even the implied        */
/*  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR           */
/*  PURPOSE.  See the GNU Lesser General Public License for more      */
/*  details.                                                          */
/*                                                                    */
/*  You should have received a copy of the GNU Lesser General         */
/*  Public License along with this source; if not, download it        */
/*  from http://www.opencores.org/lgpl.shtml                          */
/*                                                                    */
/**********************************************************************/
module 
uart_model_serial_xmit
#(parameter   WIDTH=8,   // Number of data bits
  parameter   SIZE=4     // binary size of shift_cnt, must be able to hold  WIDTH + 4 states       
 )  
(
input  wire              clk,
input  wire              reset,
input  wire              edge_enable,                 // one pulse per bit time for data rate timing
input  wire              parity_enable,               // 0 = no parity bit sent, 1= parity bit sent
input  wire              two_stop_enable,             // 0 = 1 stop bit, 1 = 2 stop bits
input  wire  [1:0]       parity_type,                 // 00= odd,01=even,10=force a 0,11= force a 1
input  wire              load,                        // start transmiting data
input  wire              start_value,                 // value out at start bit time
input  wire              stop_value,                  // value out for stop bit also used for break
input  wire [WIDTH-1:0]  data,                        // data byte
output  reg              buffer_empty,                // ready for next byte
output  reg              ser_out                      // to pad_ring
                         );
reg [SIZE-1:0] 	         shift_cnt;
reg [WIDTH-1:0] 	 shift_buffer;
reg 	  	         parity_calc;
reg                      delayed_edge_enable;
//
//   shift_cnt controls the serial bit out
//  
//   0           Start bit  
//   1-> WIDTH   Data bit lsb first
//   WIDTH+1     Parity bit if enabled
//   2^SIZE-2    Second stop bit if enabled
//   2^SIZE-1    Last stop bit and idle
always@(posedge clk)
  if(reset || buffer_empty)                                        shift_cnt   <= {SIZE{1'b1}};
  else
  if(!edge_enable)                                                 shift_cnt   <= shift_cnt;
  else
  if(( shift_cnt ==  {SIZE{1'b1}}  ) &&  ! buffer_empty )          shift_cnt   <= {SIZE{1'b0}};
  else
  if ( shift_cnt == WIDTH)               
    case({two_stop_enable,parity_enable})        
      (2'b00):                                                     shift_cnt   <= {SIZE{1'b1}};
      (2'b01):                                                     shift_cnt   <= shift_cnt + 1'b1;
      (2'b10):                                                     shift_cnt   <= {SIZE{1'b1}} - 1'b1;
      (2'b11):                                                     shift_cnt   <= shift_cnt + 1'b1;
    endcase // case ({two_stop_enable,parity_enable})
  else
  if ( shift_cnt == (WIDTH+1))               
    case( two_stop_enable)       
      (1'b0):                                                      shift_cnt   <= {SIZE{1'b1}};
      (1'b1):                                                      shift_cnt   <= {SIZE{1'b1}} - 1'b1;
    endcase
  else                                                             shift_cnt   <= shift_cnt + 1'b1;
//
//    
//   Clear buffer_empty upon load pulse
//   set it back at the start of the final stop pulse
//   if load happens BEFORE the next edge_enable then data transfer will have no pauses 
//   logic ensures that having load happen on a edge_enable will work
//   
always@(posedge clk)
   if(reset)                                                       delayed_edge_enable <= 1'b0;
   else                                                            delayed_edge_enable <= edge_enable && ! load;
always@(posedge clk)
if(reset)                                                          buffer_empty <= 1'b1;
else
if(load)                                                           buffer_empty <= 1'b0;
else
if((shift_cnt == {SIZE{1'b1}}) && delayed_edge_enable)    
                                                                   buffer_empty <= 1'b1;
else                                                               buffer_empty <= buffer_empty;
//
//
//   load shift_buffer during start_bit
//   shift down every bit
//   
//   
always@(posedge clk)
  if(reset)                                                        shift_buffer <= {WIDTH{1'b0}};
  else
  if(!edge_enable)                                                 shift_buffer <= shift_buffer;
  else
  if(shift_cnt == {SIZE{1'b0}})                                    shift_buffer <= data;
  else                                                             shift_buffer <= {1'b0,shift_buffer[WIDTH-1:1]};
//
//
//   calculate parity on the fly
//   seed reg with 0 for odd and 1 for even
//   force reg to 0 or 1 if needed  
//   
always@(posedge clk)
  if(reset)                                                        parity_calc <= 1'b0;
  else
  if(!edge_enable)                                                 parity_calc <= parity_calc;
  else
  if(parity_type[1] || (shift_cnt == {SIZE{1'b0}}))                parity_calc <= parity_type[0];
  else                                                             parity_calc <= parity_calc ^ shift_buffer[0];
//   send start_bit,data,parity and stop  based on shift_cnt
   always@(posedge clk)
     if(reset)                                                     ser_out <= stop_value;
     else
     if( shift_cnt == {SIZE{1'b0}} )                               ser_out <= start_value;
     else
     if( shift_cnt == {SIZE{1'b1}} )                               ser_out <= stop_value;
     else
     if( shift_cnt == ({SIZE{1'b1}}+1'b1) )                        ser_out <= stop_value;
     else
     if( shift_cnt == (WIDTH+1) )                                  ser_out <= parity_calc;
     else                                                          ser_out <= shift_buffer[0];
endmodule
/**********************************************************************/
/*                                                                    */
/*             -------                                                */
/*            /   SOC  \                                              */
/*           /    GEN   \                                             */
/*          /     LIB    \                                            */
/*          ==============                                            */
/*          |            |                                            */
/*          |____________|                                            */
/*                                                                    */
/*  Generic model for a rate divider                                  */
/*                                                                    */
/*  Author(s):                                                        */
/*      - John Eaton, jt_eaton@opencores.org                          */
/*                                                                    */
/**********************************************************************/
/*                                                                    */
/*    Copyright (C) <2010>  <Ouabache Design Works>                   */
/*                                                                    */
/*  This source file may be used and distributed without              */
/*  restriction provided that this copyright statement is not         */
/*  removed from the file and that any derivative work contains       */
/*  the original copyright notice and the associated disclaimer.      */
/*                                                                    */
/*  This source file is free software; you can redistribute it        */
/*  and/or modify it under the terms of the GNU Lesser General        */
/*  Public License as published by the Free Software Foundation;      */
/*  either version 2.1 of the License, or (at your option) any        */
/*  later version.                                                    */
/*                                                                    */
/*  This source is distributed in the hope that it will be            */
/*  useful, but WITHOUT ANY WARRANTY; without even the implied        */
/*  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR           */
/*  PURPOSE.  See the GNU Lesser General Public License for more      */
/*  details.                                                          */
/*                                                                    */
/*  You should have received a copy of the GNU Lesser General         */
/*  Public License along with this source; if not, download it        */
/*  from http://www.opencores.org/lgpl.shtml                          */
/*                                                                    */
/**********************************************************************/
module 
uart_model_divider
#(parameter   SIZE=4,
  parameter   SAMPLE=0,            
  parameter   RESET=1            
 )  
(
input  wire              clk,
input  wire              reset,
input  wire              enable,
input  wire [SIZE-1:0]   divider_in,
output  reg              divider_out
                         );
reg  [SIZE-1:0]        divide_cnt;
always@(posedge clk)
  if(reset)            divider_out    <= RESET;
  else
  if(!enable)          divider_out    <= 1'b0;  
  else                 divider_out    <=  ( divide_cnt == SAMPLE );       
always@(posedge clk)
  if(reset)            divide_cnt    <= divider_in;
  else
  if(!enable)          divide_cnt    <= divide_cnt;
  else
  if(!(|divide_cnt))   divide_cnt    <= divider_in;
  else                 divide_cnt    <= divide_cnt - 'b1;
endmodule
