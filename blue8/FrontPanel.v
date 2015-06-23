/*
    This file is part of Blue8.

    Foobar is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Blue8.  If not, see <http://www.gnu.org/licenses/>.

    Blue8 by Al Williams alw@al-williams.com
*/

`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    20:52:58 12/21/05
// Design Name:    
// Module Name:    FrontPanel
// Project Name:   
// Target Device:  
// Tool versions:  
// Description:
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 

////////////////////////////////////////////////////////////////////////////////
// I rearranged these from version 1
`define p_sw 4'b100      // when points==4 show switches
`define p_acc 4'b10    // when points==2 show acc
`define p_ir 4'b1000    // when points==8 show ir
`define p_pc 4'b1   // when points==1 show pc


// after operating for awhile I'm not sure the original order was best
// Seems like regsel should be #1 followed by loadpc, exam, deposit, step, start
`define i_lpc 6'b10    // load pc
`define i_exam 6'b100  // examine
`define i_deposit 6'b1000 // deposit
`define i_regsel 6'b1  // register select
`define i_step 6'b10000   // single step
`define i_start 6'b100000  // run/stop


module FrontPanel(input wire clockin, input wire pb0, input wire pb1, input wire pb2, input wire pb3, 
    input wire [7:0] sw, output wire [7:0] led, output wire [6:0] display, output dp, 
	 output [3:0] digsel, output wire clear, output wire start, output wire stop,
	 output wire lpc, output wire exam, output wire dep, input wire xrun,
	 output wire [15:0] swreg, input wire [15:0] irin, input wire [15:0] acin, input wire [11:0] pcin,
	 input wire Q, input wire setswreg, input wire [15:0] databus);
   
    wire select;  // select input buttons
	 reg [5:0] inselect;  // state

    wire [15:0] ledbus;
	 reg [3:0] points;
	 wire [3:0] pts;   // decimal points
	 wire act, ent;
	 wire step;
	

	 assign pts=(pb0?`p_sw:points);





    DisplayHex hexdisp(clockin,clear,ledbus[7:0],ledbus[15:8],~pts,display[0],display[1],
	   display[2],display[3],display[4],display[5],display[6],dp,digsel[0],digsel[1],digsel[2],digsel[3]);

	 // switches get latched in 8 bits at a time
	 reg [15:0] switches;
    assign swreg=switches;

// very strange. This gave unpredicatble results with setswreg controling the mux but works
// with ent controlling!
	 always @(posedge clockin or posedge clear) begin   
	     if (clear) switches<=0;
		  else if (setswreg | ent) 
		   begin
		     switches[15:8]<=ent?switches[7:0]:databus[15:8];
		     switches[7:0]<=ent?sw:databus[7:0];
			  end
	 end

    assign ledbus=((points==`p_sw||pb0==1'b1)?switches:((points==`p_acc)?acin:((points==`p_ir)?irin:((points==`p_pc)?pcin:0))));

	 //reg pb3s0, pb3s1;

	 assign clear=pb3;
//	assign clear=pb3s0 | pb3s1;
//	always @(posedge clockin)
//	   begin
//		pb3s1<=pb3s0;
//	   pb3s0<=pb3;
  //    end

	 Debouncer dselect(clockin,clear,pb2,,select,);
	 Debouncer daction(clockin, clear, pb1,,act,);
	 Debouncer denter(clockin, clear, pb0,,ent,);

	 assign led[7]=Q;   
    assign led[6]=xrun;
	 assign led[5]=inselect[5];
	 assign led[4]=inselect[4];
	 assign led[3]=inselect[3];
	 assign led[2]=inselect[2];
	 assign led[1]=inselect[1];
	 assign led[0]=inselect[0];

	 // I don't want to use the cycle names here because we always 
	 // want them to go 1, 2, 3, 4... even if the meanings of 1, 2, 3, 4 change
	 always @(posedge clockin or posedge clear) begin
	   if (clear) inselect<=6'b1;
		else if (select) case (inselect)
		  6'b1:  inselect<=6'b10;  
		  6'b10:  inselect<=6'b100;
		  6'b100:  inselect<=6'b1000;
		  6'b1000:  inselect<=6'b10000;
		  6'b10000:  inselect<=6'b100000;
		  6'b100000:  inselect<=6'b1;
		  default: inselect<=6'b1;
      endcase
     end


assign lpc=act&(inselect==`i_lpc);
assign exam=act&(inselect==`i_exam);
assign dep=act&(inselect==`i_deposit);
// state 1000 is register display select
// Note we use 1 here and not a particular define because we always want to start at 1
always @(posedge clockin or posedge clear) begin
  if (clear) points=4'b1;
  else 
    if (act & (inselect==`i_regsel)) begin
    points=points<<1;
    if (points==4'b0) points=4'b1;
    end
end


// state 10000 is step 
assign step=(inselect==`i_step) & act;

assign start=((~xrun) & act & (inselect==`i_start)) | step;
assign stop=(xrun & act & (inselect==`i_start)) | step;  // potential for harmless stop before start glitch?





endmodule
