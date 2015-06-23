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
  uart_tx 
    #( parameter 
      DIV=0,
      DIV_SIZE=4,
      PRESCALE=5'b01100,
      PRE_SIZE=5,
      SIZE=8,
      TX_FIFO_SIZE=3,
      TX_FIFO_WORDS=8)
     (
 input   wire                 clk,
 input   wire                 cts_pad_in,
 input   wire                 parity_enable,
 input   wire                 reset,
 input   wire                 rts_in,
 input   wire                 rxd_data_avail_stb,
 input   wire                 rxd_force_parity,
 input   wire                 rxd_pad_in,
 input   wire                 rxd_parity,
 input   wire                 txd_break,
 input   wire                 txd_force_parity,
 input   wire                 txd_load,
 input   wire                 txd_parity,
 input   wire    [ DIV_SIZE-1 :  0]        divider_in,
 input   wire    [ SIZE-1 :  0]        txd_data_in,
 output   reg                 cts_out,
 output   reg                 rts_pad_out,
 output   wire                 rxd_data_avail,
 output   wire                 rxd_parity_error,
 output   wire                 rxd_stop_error,
 output   wire                 txd_buffer_empty,
 output   wire                 txd_buffer_empty_NIRQ,
 output   wire                 txd_pad_out,
 output   wire    [ SIZE-1 :  0]        rxd_data_out);
reg                        xmit_start;
wire                        baud_clk;
wire                        baud_clk_div;
wire                        cde_buffer_empty;
wire                        fifo_empty;
wire                        fifo_full;
wire                        fifo_over_run;
wire                        fifo_pop;
wire                        fifo_under_run;
wire                        rxd_pad_synced;
wire                        txd_break_n;
wire                        xmit_enable;
wire     [ 7 :  0]              fifo_data_out;
cde_serial_xmit
cde_serial_xmit 
   (
    .buffer_empty      ( cde_buffer_empty  ),
    .clk      ( clk  ),
    .data      ( fifo_data_out  ),
    .edge_enable      ( xmit_enable  ),
    .load      ( xmit_start  ),
    .parity_enable      ( parity_enable  ),
    .parity_force      ( txd_force_parity  ),
    .parity_type      ( txd_parity  ),
    .reset      ( reset  ),
    .ser_out      ( txd_pad_out  ),
    .start_value      ( 1'b0  ),
    .stop_value      ( txd_break_n  ));
cde_divider_def
#( .SIZE (PRE_SIZE))
divider 
   (
    .clk      ( clk  ),
    .divider_in      ( PRESCALE  ),
    .divider_out      ( baud_clk  ),
    .enable      ( 1'b1  ),
    .reset      ( reset  ));
cde_fifo_def
#( .SIZE (TX_FIFO_SIZE),
   .WIDTH (SIZE),
   .WORDS (TX_FIFO_WORDS))
fifo 
   (
    .clk      ( clk  ),
    .din      ( txd_data_in  ),
    .dout      ( fifo_data_out  ),
    .empty      ( fifo_empty  ),
    .full      ( fifo_full  ),
    .over_run      ( fifo_over_run  ),
    .pop      ( fifo_pop  ),
    .push      ( txd_load  ),
    .reset      ( reset  ),
    .under_run      ( fifo_under_run  ));
cde_sync_def
filter 
   (
    .clk      ( clk  ),
    .data_in      ( rxd_pad_in  ),
    .data_out      ( rxd_pad_synced  ));
serial_rcvr_def
serial_rcvr 
   (
    .clk      ( clk  ),
    .data_avail      ( rxd_data_avail  ),
    .data_out      ( rxd_data_out  ),
    .edge_enable      ( baud_clk_div  ),
    .pad_in      ( rxd_pad_synced  ),
    .parity_enable      ( parity_enable  ),
    .parity_error      ( rxd_parity_error  ),
    .parity_force      ( rxd_force_parity  ),
    .parity_type      ( rxd_parity  ),
    .rcv_stb      ( rxd_data_avail_stb  ),
    .reset      ( reset  ),
    .stop_error      ( rxd_stop_error  ));
cde_divider_def
#( .SIZE (4))
x_divider 
   (
    .clk      ( clk  ),
    .divider_in      ( 4'b1111  ),
    .divider_out      ( xmit_enable  ),
    .enable      ( baud_clk_div  ),
    .reset      ( reset  ));
assign  txd_break_n  = !txd_break ;
always@(posedge clk)
  if(reset)            rts_pad_out  <= 1'b0;
  else                 rts_pad_out  <= rts_in;
always@(posedge clk)
  if(reset)            cts_out      <= 1'b0;
  else                 cts_out      <= cts_pad_in;
generate
if(DIV == 0)
  begin   
assign    baud_clk_div = baud_clk;
  end
else   
begin
cde_divider_def
#(.SIZE(DIV_SIZE))  
baud_divider  (
         .clk             ( clk          ),
         .reset           ( reset        ),
         .divider_in      ( divider_in   ),
         .enable          ( baud_clk     ),
         .divider_out     ( baud_clk_div )
         );
end  
endgenerate
always@(posedge clk)
  if(reset)
    begin
       xmit_start     <= 1'b0;
    end
  else
  if( !fifo_empty &&   cde_buffer_empty &&  !xmit_start )  
    begin
       xmit_start     <= 1'b1;
    end
  else
    begin
       xmit_start     <= 1'b0;
    end
assign txd_buffer_empty =      !fifo_full;
assign fifo_pop =  !fifo_empty &&   cde_buffer_empty && ! xmit_start;
always@(posedge serial_rcvr.frame_rdy)
   begin
   $display("%t %m              Received   %h   stop error %b parity error %b",
            $realtime,serial_rcvr.shift_buffer, serial_rcvr.frame_error,serial_rcvr.frame_parity_error );
   end
always@(posedge clk)
   begin
   if(!reset &&  xmit_start)
     begin
     $display("%t %m              Sending    %h",    $realtime,fifo_data_out );
     end
   end
  endmodule
