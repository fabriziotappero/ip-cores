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


module cde_sync_def
#( parameter  WIDTH   = 1,
   parameter  DEPTH   = 2
 )

(

input wire                clk,
input  wire [WIDTH - 1:0] data_in,
output wire [WIDTH - 1:0] data_out
  

);


reg [WIDTH - 1:0] sync_data [DEPTH:0]; 


always @(*)
  begin
    sync_data[0] = data_in;
  end
  


integer i;

always @(posedge clk) 
  begin
  for (i = 1 ; i <= DEPTH ; i = i + 1)   sync_data[i] <= sync_data[i-1];
  end


assign data_out = sync_data[DEPTH];

endmodule
