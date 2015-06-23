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
module 
cde_jtag_rpc_in_reg 
#(parameter BITS        = 16,   // number of bits in the register (2 or more)
  parameter RESET_VALUE = 'h0   // reset value of register
  )    
  
(

   
input  wire   clk,              // clock
input  wire   reset,            // async reset
input  wire   tdi,              // scan-in of jtag_register
input  wire   select,           // '1' when jtag accessing this register 
output wire   tdo,              // scan-out of jtag register
input  wire   capture_dr,
input  wire   shift_dr,
input  wire  [BITS-1:0] capture_value   // value to latch on a capture_dr


 
);




   
// shift  buffer and shadow
reg [BITS-1:0]  buffer;

always @(posedge clk or posedge reset)
  if (reset)                            buffer <= RESET_VALUE;
  else 
  if (select && capture_dr)             buffer <= capture_value;
  else 
  if (select && shift_dr)               buffer <= { tdi, buffer[BITS-1:1] };
  else                                  buffer <= buffer;


   

 assign tdo = buffer[0];



endmodule
