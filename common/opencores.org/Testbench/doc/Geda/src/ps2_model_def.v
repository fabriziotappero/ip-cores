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
  ps2_model_def 
    #( parameter 
      CLKCNT=10'h1f0,
      SIZE=10)
     (
 inout   wire                 ps2_clk,
 inout   wire                 ps2_data,
 input   wire                 clk,
 input   wire                 reset);
reg                        exp_device_rx_parity;
reg                        mask_device_rx_parity;
reg     [ 7 :  0]              exp_device_rx_data;
reg     [ 7 :  0]              mask_device_rx_data;
wire                        drv_device_rx_parity;
wire                        prb_device_rx_parity;
wire     [ 7 :  0]              drv_device_rx_data;
wire     [ 7 :  0]              prb_device_rx_data;
io_probe_def
#( .MESG ("ps2 data receive  Error"),
   .WIDTH (8))
device_rx_data_tpb 
   (
    .clk      ( clk  ),
    .drive_value      ( drv_device_rx_data[7:0] ),
    .expected_value      ( exp_device_rx_data[7:0] ),
    .mask      ( mask_device_rx_data[7:0] ),
    .signal      ( prb_device_rx_data[7:0] ));
io_probe_def
#( .MESG ("ps2 parity receive  Error"),
   .WIDTH (1))
device_rx_parity_tpb 
   (
    .clk      ( clk  ),
    .drive_value      ( drv_device_rx_parity  ),
    .expected_value      ( exp_device_rx_parity  ),
    .mask      ( mask_device_rx_parity  ),
    .signal      ( prb_device_rx_parity  ));
//********************************************************************
//*** TAP Controller State Machine
//********************************************************************
// TAP state parameters
parameter RESET            = 2'b00, 
          WAIT_63US        = 2'b01,
          CLOCK            = 2'b10, 
          IDLE             = 2'b11;
reg        device_rx_parity;
reg [7:0]  device_rx_data;
wire       device_rx_read;
reg        ps2_data_out;
reg        dev_host;
reg [1:0]  tap_state, next_tap_state;   
reg [SIZE-1:0]  count;
reg 	   clk_out;
reg [4:0]  bit_cnt;
reg 	   ack;
reg [10:0] frame;
reg        clk_fall;
reg        clk_rise;
reg        device_write;
reg [7:0]  device_tx_data;
reg        device_tx_parity; 
reg        device_ack; 
reg        device_stop; 
assign    drv_device_rx_data   = 8'bzzzzzzzz;
assign    prb_device_rx_parity = device_rx_parity;
assign    prb_device_rx_data   = device_rx_data;
assign    drv_device_rx_parity = 1'bz;
/*
io_probe_def 
#(.MESG     ( "ps2 data receive error"),
  .WIDTH    ( 8))
device_rx_data_tpb (
   .clk            (  clk                 ),
   .drive_value    (  drv_device_rx_data  ), 
   .expected_value (  exp_device_rx_data  ),
   .mask           (  mask_device_rx_data ), 
   .signal         (  prb_device_rx_data  )
 );      
io_probe_def 
#(.MESG     ( "ps2 parity receive error"))
device_rx_parity_tpb (
   .clk            (  clk                   ),
   .drive_value    (  drv_device_rx_parity  ), 
   .expected_value (  exp_device_rx_parity  ),
   .mask           (  mask_device_rx_parity ), 
   .signal         (  prb_device_rx_parity  )
 );      
*/   
assign   ps2_clk  = clk_out ? 1'b0 : 1'bz  ;
assign   ps2_data = ps2_data_out ? 1'b0 : 1'bz  ;
always @(posedge clk  or posedge reset )
  begin
    if (reset)  
    begin
    tap_state <=  RESET;
    ps2_data_out <=  1'b0;
    end
    else 
    begin
    tap_state  <=  next_tap_state;
    ps2_data_out <=  (  (tap_state == CLOCK) &&    (dev_host?  frame[0] : ack)           );
    end
  end
always @(posedge clk  or posedge reset )
  begin
    if (reset)                    dev_host <=  1'b0;
    else 
    if( device_write)                     dev_host <=  1'b1;
    else 
    if( bit_cnt == 5'h16  )       dev_host <=  1'b0;
    else                          dev_host <=  dev_host ;
  end
always@(*) ack =  (((bit_cnt == 5'h14)||  (bit_cnt == 5'h15)) && device_ack )   ;
// next state decode for tap controller
always @(*)
  begin
  if(device_write)    next_tap_state    =  CLOCK;
    else
    case (tap_state)	// synopsys parallel_case
      RESET:
            begin
            next_tap_state    =   ps2_clk  ? RESET : WAIT_63US ;
            end
      WAIT_63US: 
            begin
            next_tap_state    =   ps2_clk   ?  CLOCK : WAIT_63US ;
            end
      CLOCK:  
            begin
            next_tap_state    =  ((bit_cnt == 5'h16)&& (count == 'h0))  ? IDLE  : CLOCK;
            end
      IDLE:  
            begin
            next_tap_state    =   ps2_data    ? IDLE : WAIT_63US;
            end
    endcase
    end
always @(posedge clk  or posedge reset )
  begin
    if (reset)  
      begin
      count    <=  CLKCNT;
      clk_out  <=  1'b0;
      bit_cnt  <=  5'h00;
      clk_fall <=  1'b0;
      clk_rise <=  1'b0;	 
      end
    else 
    if((next_tap_state != CLOCK))
      begin
      count    <=  CLKCNT;
      clk_out  <=  1'b0;
      bit_cnt  <=  5'h00;
      clk_fall <=  1'b0;
      clk_rise <=  1'b0;       
      end
    else 
    if((count == 'h0) )
      begin
      count     <=   CLKCNT;
      clk_out   <=  !clk_out;
      bit_cnt   <=   bit_cnt+5'b0001;
      clk_fall  <=  !clk_out;
      clk_rise  <=   clk_out;
      end
    else
      begin
      count     <=  count - 'h1;
      clk_out   <=  clk_out;
      bit_cnt   <=  bit_cnt;
      clk_fall  <=  1'b0;
      clk_rise  <=  1'b0;	 
      end
  end
always @(posedge clk  or posedge reset )
  begin
    if (reset)  
      begin
	 frame <= {device_ack,10'h000};
      end
    else
     if(device_write)
      begin
	 frame <= {!device_stop,device_tx_parity,~device_tx_data,1'b1};
      end
    else 
     if((tap_state == WAIT_63US) || (tap_state == IDLE))
      begin
	 frame <= {device_ack,10'h000};
      end
    else
     if((tap_state == CLOCK) &&  clk_fall  && !dev_host )          frame <= { ps2_data,frame[10:1]};
    else
     if((tap_state == CLOCK) &&  clk_rise  &&  dev_host )          frame <= { 1'b0,frame[10:1]};
    else        frame <= frame;
  end
always @(posedge clk  or posedge reset )
  begin
    if (reset)  
      begin
	 device_rx_data   <= 8'h00;
	 device_rx_parity <= 1'b0;
      end
     else
     if(tap_state == WAIT_63US) 
      begin
	 device_rx_data   <= 8'h00;
	 device_rx_parity <= 1'b0;
      end
    else 
      if((bit_cnt == 5'h12) && clk_rise)
      begin
	 device_rx_data   <= frame[10:3];
	 device_rx_parity <= ps2_data;
      end	
      else
	      begin
	 device_rx_data   <= device_rx_data;
	 device_rx_parity <= device_rx_parity;
      end
  end
assign device_rx_read    =  (bit_cnt == 5'h13) && !dev_host && clk_fall;
initial
  begin
   device_write           <=  1'b0;    
   device_tx_data         <=  8'h00;
   device_tx_parity       <=  1'b0; 
   device_ack             <=  1'b1; 
   device_stop            <=  1'b1;  
   exp_device_rx_data     <=  8'h00;    
   mask_device_rx_data    <=  8'h00;    
   exp_device_rx_parity   <=  1'b0;    
   mask_device_rx_parity  <=  1'b0;    
  end
task next;
  input [31:0] num;
  repeat (num)       @ (posedge clk);       
endtask
task send_byte;
  input [7:0] byte_out;
begin
  while(tap_state != IDLE) next(1);
  $display("%t %m      %2h parity  %b",$realtime ,byte_out,device_tx_parity  );
  device_tx_data  <= byte_out;
  next(1);
  device_write   <= 1'b1;
  next(1);
  device_write   <= 1'b0;
end
endtask // send_byte
task rcv_byte;
  input [7:0] byte_in;
  input        parity;
   begin
   exp_device_rx_data  <=  byte_in;    
   exp_device_rx_parity   <=  parity;    
   while(!device_rx_read)  next(1);
   $display("%t           checking    %h         %b",$realtime,byte_in,parity); 
   mask_device_rx_data <=  8'hff;    
   mask_device_rx_parity  <=  1'b1;    
   next(1);
   mask_device_rx_data <=  8'h00;    
   mask_device_rx_parity  <=  1'b0;    
end
endtask
always@(posedge clk)
  if( device_rx_read)  
  $display ("%t %m device  rec    %h parity  %b",$realtime,device_rx_data,device_rx_parity);
always@(posedge clk)
  if(device_write)
  $display ("%t %m device send    %h parity  %b  stop %b ",$realtime,device_tx_data,device_tx_parity,device_stop);
  endmodule
