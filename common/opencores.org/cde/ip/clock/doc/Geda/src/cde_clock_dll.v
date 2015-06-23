/**********************************************************************/
/*                                                                    */
/*                                                                    */
/*   Copyright (c) 2012 Ouabache Design Works                         */
/*                                                                    */
/*          All Rights Reserved Worldwide                             */
/*                                                                    */
/*   Licensed under the Apache License,Version2.0 (the'License');     */
/*   you may not use this file except in compliance with the License. */
/*   You may obtain a copy of the License at                          */
/*                                                                    */
/*       http://www.apache.org/licenses/LICENSE-2.0                   */
/*                                                                    */
/*   Unless required by applicable law or agreed to in                */
/*   writing, software distributed under the License is               */
/*   distributed on an 'AS IS' BASIS, WITHOUT WARRANTIES              */
/*   OR CONDITIONS OF ANY KIND, either express or implied.            */
/*   See the License for the specific language governing              */
/*   permissions and limitations under the License.                   */
/**********************************************************************/

`timescale 1 ns / 10ps 

module 
cde_clock_dll
#(parameter   DIV=4  ,  
  parameter   MULT=2 ,
  parameter   SIZE=4
) ( 
input   wire        ref_clk,         // input clock
input   wire        reset,           // input reset
output  reg         dll_clk_out,     // output clock at higher frequency
output  reg         div_clk_out      // output clock at synthesized frequency
    );


localparam   MIN_CLK_DELAY = 0.01;
   

//****************************************************************************
// Measure the clock in period.  Use the and the multiplication
//   factor to determine the period for the output clock
//****************************************************************************
real  last_edge_time;
real  this_edge_time;   // $realtime when the input clock edges occur
real  ref_clk_period;   // input clock period
real  dll_clk_out_period;   // output clock period
real  clk_delay;

   
initial last_edge_time = 0;
initial dll_clk_out_period = 1;

always @(posedge ref_clk)
  begin
    this_edge_time   = $realtime;
    ref_clk_period   =  this_edge_time - last_edge_time;
    dll_clk_out_period   = (ref_clk_period) / MULT;
    last_edge_time   =  this_edge_time;
  end




   
//*****************************************************************************
//  Create a new clock
//*****************************************************************************


reg [SIZE-1:0]  divider;
   
   
initial
  begin
    dll_clk_out = 1'b0;
    forever
      begin
        clk_delay = (dll_clk_out_period/2);
        if (clk_delay < MIN_CLK_DELAY)    
        clk_delay = MIN_CLK_DELAY;
        #(clk_delay) dll_clk_out = ~dll_clk_out;
      end
  end

     
always@(posedge dll_clk_out)
  if ( reset)                 divider   <= DIV/2;
  else if ( divider ==  'b1)  divider   <= DIV/2;
  else                        divider   <= divider - 'b1;
  
always@(posedge dll_clk_out)
  if(reset)  div_clk_out                       <= 1'b0;
  else if   (divider ==  'b1)   div_clk_out    <= !div_clk_out;
  else       div_clk_out                       <= div_clk_out;



endmodule


