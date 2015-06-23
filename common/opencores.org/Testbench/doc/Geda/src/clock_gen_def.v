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



module clock_gen_def
#(parameter STOP_WIDTH = 1,
  parameter BAD_WIDTH  = 1
)
 
 (input  wire                  clk,
  input  wire                  START,
  input  wire [STOP_WIDTH-1:0] STOP,
  input  wire [BAD_WIDTH-1:0]  BAD,
  output reg                   FINISH,
  output reg                   FAIL,
  output reg                   reset
 );

reg           task_reset;
reg           task_FAIL;
reg           task_FINISH;





   
always@(posedge clk or negedge START)
  if(!START)  FINISH <= 0;
  else        FINISH <= (|STOP) || FINISH || task_FINISH;



always@(posedge clk or negedge START)
  if(!START)  FAIL <= 0;
  else        FAIL <= task_FAIL || (|BAD);
   

always@(posedge clk or negedge START)
  if(!START)  reset <= 1'b1;
  else        reset <= task_reset;



   
   

task automatic next;
  input [31:0] num;
  repeat (num)       @ (posedge clk);       
endtask // next





initial
  begin
     task_FINISH <= 0;
     task_FAIL   <= 0;     
     task_reset  <= 0;     
  end
   
   

task reset_on;
  task_reset = 1;       
endtask // reset_on

task reset_off;
  begin
  task_reset = 0;
  end       
endtask // reset_off

   

   
task automatic fail;
  input [799:0] message;
  begin
  task_FAIL   <= 1;   
  $display("%t  Simulation FAILURE:  %s ",$realtime,message  ); 
  @(posedge clk);
  task_FAIL   <= 0;      
  end
endtask   

   


   


task exit;
   begin
      @(posedge clk);
      task_FINISH <= 1;
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
     end
endtask      







   

   
   
endmodule



