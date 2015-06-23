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
/*  JTAG Hoset model for  simulations                                 */
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
  jtag_model_def 
    #( parameter 
      DIVCNT=4'h1,
      SIZE=4)
     (
 input   wire                 clk,
 input   wire                 reset,
 input   wire                 tdi,
 output   reg                 tclk,
 output   reg                 tdo,
 output   reg                 tms,
 output   reg                 trst_n);
reg         tclk_enable;               
reg [SIZE-1:0]   tclk_counter;
wire        next_tclk_edge;
wire        next_tclk_pos_edge;
wire        next_tclk_neg_edge;
assign next_tclk_edge = (tclk_counter == 4'h0);
assign next_tclk_pos_edge = next_tclk_edge && (!tclk) ;
assign next_tclk_neg_edge = next_tclk_edge && ( tclk) ;
always@(posedge clk)
  if(reset)         tclk_counter   <= DIVCNT; 
  else 
  if(|tclk_counter) tclk_counter   <= tclk_counter-4'h1;
  else              tclk_counter   <= DIVCNT;  
always@(posedge clk)
  if(reset)                 tclk   <= 1'b0;
  else 
  if(!tclk_enable)          tclk   <= tclk;
  else
  if( next_tclk_pos_edge )  tclk   <= 1'b1;
  else
  if( next_tclk_neg_edge )  tclk   <= 1'b0;
  else                      tclk   <= tclk;  

reg actual;
initial
    begin
    tclk_enable          <= 1'b0; 
    tclk                 <= 1'b0;
    tdo                  <= 1'b1;
    tms                  <= 1'b1;    
    trst_n               <= 1'b0;    
    end
task automatic next;
  input [31:0] num;
  repeat (num)       @ (posedge clk);       
endtask
task enable_tclk;
begin
    tclk_enable  <= 1'b1;
end
endtask 
task enable_trst_n;
begin
Clk_bit(1,1,actual);
Clk_bit(1,1,actual);
Clk_bit(1,1,actual);
Clk_bit(1,1,actual);
Clk_bit(1,1,actual);
    trst_n   <= 1'b1;
Clk_bit(1,1,actual);
end
endtask 
task enable_reset;
begin
Clk_bit(1,0,actual);
Clk_bit(1,0,actual);
Clk_bit(1,0,actual);
Clk_bit(1,0,actual);
Clk_bit(1,0,actual);
Clk_bit(1,0,actual);
Clk_bit(1,0,actual);
Clk_bit(1,0,actual);
end
endtask 
task init;
begin
Clk_bit(0,0,actual);
Clk_bit(0,0,actual);
Clk_bit(0,0,actual);
Clk_bit(0,0,actual);
Clk_bit(0,0,actual);
Clk_bit(0,0,actual);
Clk_bit(0,0,actual);
Clk_bit(0,0,actual);
end
endtask 

task Clk_bit;
   input         TMS;
   input         TDO;
   output        ACT;
   begin
   while (next_tclk_neg_edge  != 1) 
   begin
   next(1);
   end
   if(TMS)    tms <= 1'b1; 
   else       tms <= 1'b0;
   if     ( TDO == 1  ) tdo <= 1'b1;
   else if( TDO == 0  ) tdo <= 1'b0;
   else                 tdo <= 1'bx;
   while (next_tclk_pos_edge  != 1) 
   begin
   next(1);
   end
   ACT = tdi;
  end
endtask
/******************************************************************************/
/* LoadTapInst (<Inst>);                                                      */
/******************************************************************************/
task LoadTapInst;   // Load a Tap Instruction that uses the Boundary Register
  parameter [15:0] JTAG_INST_LENGTH =  4;
  input [JTAG_INST_LENGTH:1] Inst; // This task starts & ends with the Tap in the RT_IDLE state
  input [JTAG_INST_LENGTH:1] Inst_Return; // 
  integer i;
  reg   [JTAG_INST_LENGTH:1]  Ack;
  begin
   Clk_bit(1'b1,1'b0,actual); // Transition from RT_IDLE to SELECT_DR
   Clk_bit(1'b1,1'b0,actual); // Transition from SELECT_DR to SELECT_IR
   Clk_bit(1'b0,1'b0,actual); // Transition from SELECT_IR to CAPTURE_IR
   Clk_bit(1'b0,1'b0,actual); // Transition from CAPTURE_IR to SHIFT_IR
   for (i = 1; i <=  JTAG_INST_LENGTH; i = i+1)  // Shift in Inst
     begin
       Clk_bit(( i == JTAG_INST_LENGTH),Inst[i],Ack[i]);
     end
   $display  ("%t  %m  LoadTapInst  %b  Expected %b  Received %b  " ,$realtime,Inst,  Inst_Return,  Ack   );
   if (Ack !== Inst_Return)
   begin
   cg.fail  (" LoadTapInst receive error  ");
   end
   Clk_bit(1'b1,1'b0,actual); // Transition from EXIT1_IR to UPDATE_IR
   Clk_bit(1'b0,1'b0,actual);// Transition from UPDATE_IR to RT_IDLE
  end
endtask // LoadTapInst
//***************************************************************************/
//* Shift Register
//***************************************************************************/
task automatic  Shift_Register;    // Initialize boundary register with outputs disabled
                         // This tasks starts at RT_IDLE and ends at SHIFT_DR
  parameter [15:0] LENGTH =  100;
  input           length;
  input [LENGTH:1]  Dataout;
  integer length;
  integer i;
  reg [LENGTH:1]  DataBack;
  begin
    Clk_bit(1'b1,1'b0,actual);// Transition from RT_IDLE to SELECT_DR
    Clk_bit(1'b0,1'b0,actual);// Transition from SELECT_DR to CAPTURE_DR
    Clk_bit(1'b0,1'b0,actual);// Transition from CAPTURE_DR to SHIFT_DR 
    for (i = 1; i <= length; i = i+1)
       Clk_bit((i==length),Dataout[i],DataBack[i]);
    $display  ("%t  %m    Shift_data  -%d  wr-%h  rd-%h    ",$realtime,length,Dataout[LENGTH:1],DataBack[LENGTH:1]);
    Clk_bit(1'b1,1'b0,actual);//Transition from EXIT1-DR to UPDATE-DR 
    Clk_bit(1'b0,1'b0,actual);// Transition from UPDATE-DR to IDLE
  end
endtask // ShiftRegister
task automatic  Shift_Cmp_32;    // Initialize boundary register with outputs disabled
                         // This tasks starts at RT_IDLE and ends at SHIFT_DR
  parameter [15:0] LENGTH =  32;
  input [LENGTH:1]  Dataout;
  input [LENGTH:1]  DataExp;
  integer i;
  reg [LENGTH:1]  DataBack;
  begin
    Clk_bit(1'b1,1'b0,actual);// Transition from RT_IDLE to SELECT_DR
    Clk_bit(1'b0,1'b0,actual);// Transition from SELECT_DR to CAPTURE_DR
    Clk_bit(1'b0,1'b0,actual);// Transition from CAPTURE_DR to SHIFT_DR 
    for (i = 1; i <= LENGTH; i = i+1)
       Clk_bit((i==LENGTH),Dataout[i],DataBack[i]);
    $display  ("%t  %m    Shift_data_register    wr-%h  exp-%h rd-%h    ",$realtime,Dataout,DataExp,DataBack  );
   if (DataBack  !== DataExp )
   begin
   cg.fail  (" Shift_cmp  receive error  ");
   end
    Clk_bit(1'b1,1'b0,actual);//Transition from EXIT1-DR to UPDATE-DR 
    Clk_bit(1'b0,1'b0,actual);// Transition from UPDATE-DR to IDLE
  end
endtask // ShiftRegister
  endmodule
