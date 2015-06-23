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
/*  Microprocessor bus functional model (BFM) for simulations         */
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
  micro_bus_model_def 
    #( parameter 
      OUT_DELAY=15,
      OUT_WIDTH=10,
      addr_width=16)
     (
 inout   wire    [ 7 :  0]        rdata,
 input   wire                 clk,
 input   wire                 reset,
 output   reg                 cs,
 output   reg                 rd,
 output   reg                 wr,
 output   reg    [ 7 :  0]        wdata,
 output   reg    [ addr_width-1 :  0]        addr);
reg     [ 7 :  0]              exp_rdata;
reg     [ 7 :  0]              mask_rdata;
io_probe_in
#( .MESG ("micro rdata  Error"),
   .WIDTH (8))
rdata_tpb 
   (
    .clk      ( clk  ),
    .expected_value      ( exp_rdata[7:0] ),
    .mask      ( mask_rdata[7:0] ),
    .signal      ( rdata[7:0] ));
  always@(posedge clk)
  if(reset)
    begin
      addr  <= 16'h0000;
      wdata <=  8'h00;
      wr    <=  1'b0;
      rd    <=  1'b0;
      cs    <=  1'b1;
      exp_rdata    <=  8'h00;
      mask_rdata    <=  8'h00;       
   end
  // Tasks
task automatic next;
  input [31:0] num;
  repeat (num)       @ (posedge clk);       
endtask // next
  // write cycle
  task u_write;
    input [addr_width-1:0] a;
    input  [7:0] d;
    begin
      $display("%t %m cycle %x %x",$realtime,a,d );
      addr  <= a;
      wdata <= d;
      rd    <= 1'b0;
      wr    <= 1'b1;
      next(1);
      wr     <= 1'b0; 
      next(1);
    end
  endtask
  // read cycle
  task u_read;
    input   [addr_width-1:0]  a;
    output  [7:0]   d;
     begin
      addr  <= a;
      wdata <= 8'h00;
      rd    <= 1'b1;
      wr    <= 1'b0;
      next(2);
      d     <= rdata;  
      $display("%t %m  cycle %x %x",$realtime,a,rdata );
      rd    <= 1'b1;
      next(1);
      rd    <= 1'b0;
    end
  endtask
  // Compare cycle (read data from location and compare with expected data)
  task u_cmp;
    input  [addr_width-1:0] a;
    input  [7:0] d_exp;
     begin
      addr      <= a;
      wdata     <= 8'h00;
      rd        <= 1'b1;
      wr        <= 1'b0;
      exp_rdata <= d_exp;
      next(1);
      mask_rdata  <= 8'hff;
      next(1);
      $display("%t %m   cycle %x %x",$realtime,a,d_exp );
      mask_rdata <= 8'h00;	
      rd         <= 1'b0;
   end
  endtask
  endmodule
