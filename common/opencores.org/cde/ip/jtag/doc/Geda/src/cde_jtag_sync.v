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
cde_jtag_sync
#(parameter JTAG_SEL        = 2   // number of select signals
  )  

  
(
 input wire 		clk, // system clock

   

 input wire 		jtag_clk, // clock
 input wire 		test_logic_reset, // async reset


 input wire 		tdi, // scan-in of jtag_register
 input wire [JTAG_SEL-1:0] 	select, // '1' when jtag accessing this register 
 output wire 		tdo, // scan-out of jtag register
 input wire 		capture_dr,
 input wire 		shift_dr,
 input wire 		update_dr,
 

 output wire 		syn_clk, 
 input wire 		syn_tdi, // scan-in of jtag_register
 output wire [JTAG_SEL-1:0] syn_select, // '1' when jtag accessing this register 
 output wire 		syn_tdo, // scan-out of jtag register
 output wire 		syn_capture_dr,
 output wire 		syn_shift_dr,
 output wire 		syn_update_dr

);

   assign    syn_clk             = clk;
   assign    syn_select          = select;
   assign    syn_tdo             = tdi;
   assign    tdo                 = syn_tdi;   
   assign    syn_capture_dr      = capture_dr;   
   assign    syn_shift_dr        = shift_dr  ;
   assign    syn_update_dr       = update_dr;

   



endmodule
