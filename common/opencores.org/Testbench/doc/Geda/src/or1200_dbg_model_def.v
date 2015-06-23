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
  or1200_dbg_model_def 
     (
    reg                 dbg_ewt_i,
    reg                 dbg_stall_i,
    reg                 dbg_stb_i,
    reg                 dbg_we_i,
    reg    [ 31 :  0]        dbg_adr_i,
    reg    [ 31 :  0]        dbg_dat_i,
    wire                 dbg_ack_o,
    wire                 dbg_bp_o,
    wire    [ 1 :  0]        dbg_is_o,
    wire    [ 10 :  0]        dbg_wp_o,
    wire    [ 3 :  0]        dbg_lss_o,
    wire    [ 31 :  0]        dbg_dat_o,
 input   wire                 clk,
 input   wire                 reset);
   reg [31:0]  exp_rdata;
   reg [31:0]  mask_rdata;
always@(posedge clk)
  if(reset)
    begin
      dbg_adr_i      <=  32'h00000000;
      dbg_dat_i      <=  32'h00000000;
      dbg_we_i       <=  1'b0;
      dbg_stb_i      <=  1'b0;
      dbg_stall_i    <=  1'b1;
      dbg_ewt_i      <=  1'b0;
      exp_rdata      <=  32'h00000000;
      mask_rdata     <=  32'h00000000;       
      end // if (reset)
io_probe_in 
 #(.MESG         ("or1200 rdata Error"),
   .WIDTH        (32)
  )
rdata_tpb
  (
  .clk            (  clk        ),
  .expected_value (  exp_rdata  ),
  .mask           (  mask_rdata ),
  .signal         (  dbg_dat_o  )
  );      
  // Tasks
task automatic next;
  input [31:0] num;
  repeat (num)       @ (posedge clk);       
endtask // next
  // write cycle
  task u_write;
    input [31:0] a;
    input  [31:0] d;
    begin
      $display("%t %m cycle %x %x",$realtime,a,d );
      dbg_adr_i      <=  a;
      dbg_dat_i      <=  d;
      dbg_we_i       <=  1'b1;
      dbg_stb_i      <=  1'b1;
      next(1);
      dbg_adr_i      <=  32'h00000000;
      dbg_dat_i      <=  32'h00000000;
      dbg_we_i       <=  1'b0;
      dbg_stb_i      <=  1'b0;
    end
  endtask
// read cycle
  task u_read;
    input   [31:0]  a;
    output  [31:0]   d;
     begin
      dbg_adr_i      <=  a;
      dbg_we_i       <=  1'b0;
      dbg_stb_i      <=  1'b1;
      next(4);
      d              <= dbg_dat_o;  
      $display("%t %m  cycle %x %x",$realtime,a,dbg_dat_o );
      next(1);
      dbg_adr_i      <=  32'h00000000;
      dbg_we_i       <=  1'b0;
      dbg_stb_i      <=  1'b0;
      next(1);       	
    end
  endtask
// compare cycle
  task u_cmp;
    input   [31:0]  a;
    input  [31:0]   d_exp;
     begin
      dbg_adr_i      <=  a;
      dbg_we_i       <=  1'b0;
      dbg_stb_i      <=  1'b1;
      exp_rdata      <=  d_exp;
      next(4);
      mask_rdata     <= 32'hffffffff;
      next(1);
      $display("%t %m  cycle %x %x",$realtime,a,d_exp );
      mask_rdata     <= 32'h00000000;
      next(1);
      dbg_adr_i      <=  32'h00000000;
      dbg_we_i       <=  1'b0;
      dbg_stb_i      <=  1'b0;
      next(1);       	
    end
  endtask
  endmodule
