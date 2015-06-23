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
 input wire [ ADDR : 1]   addr,
 input wire [ 15 : 0] 	  wdata,
 input wire [  1 : 0]     be,
 output reg [ 15 : 0] 	  rdata);
// Memory Array
reg [7:0] meml[0:WORDS-1];
reg [7:0] memh[0:WORDS-1];
// If used as Rom then load a memory image at startup
initial 
  begin
  $display("SRAM def %m.mem");
  $display("  AddrBits=%d DataBits = 16  Words = %d  ",ADDR,WORDS);
  end

// Write function   
always@(posedge clk)
        if( wr && cs && be[0]) meml[addr[ADDR:1]] <= wdata[7:0];



   always@(posedge clk)
        if( wr && cs && be[1]) memh[addr[ADDR:1]] <= wdata[15:8];


  reg   [ADDR:1]          l_raddr;
  reg                       l_cycle;     

  always@(posedge clk)   
    begin
       l_raddr    <= addr;   
       l_cycle    <=  rd && cs  ;   
     end  


   
generate
if( WRITETHRU) 
  begin
  // Read function gets new data if also a write cycle
  // latch the read addr for next cycle   

  // Read into a wire and then pass to rdata because some synth tools can't handle a memory in a always block
  wire  [15:0] tmp_rdata;
  assign            tmp_rdata  =      (l_cycle )?{memh[{l_raddr[ADDR:1]}],meml[{l_raddr[ADDR:1]}]}:16'hffff;
  always@(*)            rdata  =      tmp_rdata;   
  end
else
  begin 
  // Read function gets old data if also a write cycle
  always@(posedge clk)
        if( rd && cs ) rdata             <= {memh[{addr[ADDR:1]}],meml[{addr[ADDR:1]}]}          ;
        else           rdata             <= 16'hffff;
  end		   
endgenerate
  endmodule
