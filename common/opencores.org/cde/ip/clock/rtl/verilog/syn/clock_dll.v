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
cde_clock_dll
#(parameter   DIV=4  ,  
  parameter   MULT=2 ,
  parameter   SIZE=4
) ( 
input   wire        ref_clk,         // input clock
input   wire        reset,           // input reset
output  wire         dll_clk_out,     // output clock at higher frequency
output  wire         div_clk_out      // output clock at synthesized frequency
    );


assign dll_clk_out = ref_clk;
assign div_clk_out = ref_clk;



endmodule


