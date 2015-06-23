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
/*  io_probe for handling timing delays in dut                        */
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
  io_probe_def 
    #( parameter 
      IN_DELAY=5,
      MESG=" ",
      OUT_DELAY=15,
      OUT_WIDTH=10,
      RESET={WIDTH{1'bz}},
      WIDTH=1)
     (
 inout   wire    [ WIDTH-1 :  0]        signal,
 input   wire                 clk,
 input   wire    [ WIDTH-1 :  0]        drive_value,
 input   wire    [ WIDTH-1 :  0]        expected_value,
 input   wire    [ WIDTH-1 :  0]        mask);
reg   [WIDTH-1:0]          filtered_value;
reg   [WIDTH:1]            fail;
assign         signal = drive_value;
always @(posedge clk)   filtered_value <=   signal;
always @(posedge clk)   fail           <=   mask & (signal^ expected_value);  
initial
  begin
    cg.next(3);
    while(1)
      begin
      if(fail !== {WIDTH{1'b0}})        
           begin
           $display("%t %m              value %x   failure on bit(s)  %b",$realtime,filtered_value,fail );
           cg.fail(MESG);
           end
      cg.next(1);
      end // while (1)
  end // initial begin
  endmodule
