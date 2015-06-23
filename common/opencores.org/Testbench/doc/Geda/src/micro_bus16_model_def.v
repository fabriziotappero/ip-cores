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
module micro_bus16_model_def
#(parameter OUT_DELAY    = 15,
  parameter OUT_WIDTH    = 10
  )
 (
  input wire                  clk, 
  input wire                  reset,
  output reg [23:0]           addr,
  output reg [15:0]           wdata,
  output reg [1:0]            cs,
  output reg                  rd,
  output reg                  wr,
  output reg                  ub,
  output reg                  lb,
  inout  wire [15:0]           rdata
);
   reg [15:0]  exp_rdata;
   reg [15:0]  mask_rdata;
always@(posedge clk)
  if(reset)
    begin
      addr  <= 24'h0000;
      wdata <=  16'h0000;
      wr    <=  1'b0;
      rd    <=  1'b0;
      cs    <=  2'b00;
      ub    <=  1'b0;
      lb    <=  1'b0;
      exp_rdata    <=  16'h0000;
      mask_rdata    <=  16'h0000;       
   end
io_probe_def 
 #(.MESG         ("micro rdata Error"),
   .WIDTH        (16),
   .RESET        ({16{1'bz}}),
   .OUT_DELAY    (OUT_DELAY),
   .OUT_WIDTH    (OUT_WIDTH)
  )
rdata_tpb
  (
  .clk            (  clk        ),
  .drive_value    (16'bzzzzzzzzzzzzzzzz  ), 
  .expected_value (  exp_rdata  ),
  .mask           (  mask_rdata ),
  .signal         (  rdata      )
  );      
  // Tasks
task automatic next;
  input [31:0] num;
  repeat (num)       @ (posedge clk);       
endtask // next
  // idle cycle
  task u_idle;
    begin
      addr  <= 24'h000000;
      wdata <= 16'h0000;
      rd    <= 1'b0;
      cs    <= 2'b00;       
      wr    <= 1'b0;
      ub    <= 1'b0;
      lb    <= 1'b0;       
      mask_rdata <= 16'h0000;	
      next(1);
    end
  endtask
  // write cycle
  task u_write;
    input [23:0] a;
    input  [15:0] d;
    begin
      $display("%t %m cycle %x %x",$realtime,a,d );
      addr  <= a;
      wdata <= d;
      rd    <= 1'b0;
      cs    <= 2'b01;       
      wr    <= 1'b1;
      ub    <= 1'b1;
      lb    <= 1'b1;       
      next(4);
      rd    <= 1'b0;
      cs    <= 2'b00;       
      wr    <= 1'b0;
      ub    <= 1'b0;
      lb    <= 1'b0;       
      next(1);
    end
  endtask
  // read cycle
  task u_read;
    input   [23:0]  a;
    output  [15:0]   d;
     begin
      addr  <= a;
      wdata <= 16'h0000;
      rd    <= 1'b1;
      cs    <= 2'b01;	
      wr    <= 1'b0;
      ub    <= 1'b1;
      lb    <= 1'b1;       
      next(4);
      d     <= rdata;  
      $display("%t %m  cycle %x %x",$realtime,a,rdata );
      rd    <= 1'b1;
      next(1);
      rd    <= 1'b0;
      ub    <= 1'b0;
      lb    <= 1'b0;       
      cs    <= 2'b00;
      next(1);       	
    end
  endtask
  // Compare cycle (read data from location and compare with expected data)
  task u_cmp;
    input  [23:0] a;
    input  [15:0] d_exp;
     begin
      addr      <= a;
      wdata     <= 16'h0000;
      rd        <= 1'b1;
      ub        <= 1'b1;
      lb        <= 1'b1;       
      cs        <= 2'b01;       	
      wr        <= 1'b0;
      exp_rdata <= d_exp;
      next(5);
      mask_rdata  <= 16'hffff;
      next(1);
      $display("%t %m   cycle %x %x",$realtime,a,d_exp );
      mask_rdata <= 16'h0000;	
      rd         <= 1'b0;
      ub         <= 1'b0;
      lb         <= 1'b0;       	
      cs         <= 2'b00;
      next(1);       		
   end
  endtask
endmodule
