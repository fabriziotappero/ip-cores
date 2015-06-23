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

module cde_clock_gater (
                input  wire  clk_in,
                input  wire  enable,
                input  wire  atg_clk_mode,
                output wire  clk_out
	       );
   

wire  latch_enable;
reg   latch_output;

assign latch_enable = enable | atg_clk_mode;

always @(latch_enable or clk_in)
begin
  if (~clk_in)
     latch_output = latch_enable;
  else
     latch_output = latch_output;
end

assign clk_out = latch_output && clk_in;



   
endmodule
