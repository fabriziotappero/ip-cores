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
  cde_sram_word
    #( parameter 
      ADDR=10,
      WORDS=1024,
      WRITETHRU=0
     )
     (
 input wire 		  clk,
 input wire 		  cs,
 input wire 		  rd,
 input wire 		  wr,
 input wire [ ADDR-1 : 0] addr,
 input wire [ 15 : 0] 	  wdata,
 input wire [  1 : 0]     be,
 output reg [ 15 : 0] 	  rdata);

  always@(posedge clk)
        if( rd && cs ) rdata             <= wdata  ;
        else           rdata             <= 16'hffff;


  endmodule
