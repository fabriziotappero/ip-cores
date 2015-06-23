/**********************************************************************/
/*                                                                    */
/*                                                                    */
/*   Copyright (c) 2012-2015 Ouabache Design Works                    */
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
  cde_sram_byte 
    #( parameter 
      ADDR=10,
      WORDS=1024,
      WRITETHRU=0
     )
     (

 input wire 		   clk,
 input wire 		   cs,
 input wire 		   rd,
 input wire 		   wr,
 input wire 		   be,
      
 input wire [ ADDR-1 : 0]  addr,
 input wire [ 7 : 0] wdata,
 output reg [ 7 : 0] rdata);
// Memory Array
reg [7:0] mem[0:WORDS-1];

initial 
  begin
  $display("SRAM byte %m.mem");
  $display("  AddrBits=%d DataBits = 8  Words = %d  ",ADDR,WORDS);
  end

// Write function   
always@(posedge clk)
        if( wr && cs && be ) mem[addr[ADDR-1:0]] <= wdata[7:0];

  reg   [ADDR-1:0]          l_raddr;
  reg                       l_cycle;     

  always@(posedge clk)   
    begin
       l_raddr    <=  addr;   
       l_cycle    <=  rd && cs ;   
    end



generate
if( WRITETHRU) 
  begin
  // Read function gets new data if also a write cycle
  // latch the read addr for next cycle   


  // Read into a wire and then pass to rdata because some synth tools can't handle a memory in a always block
     
  wire  [7:0] tmp_rdata;
  assign         tmp_rdata  =      (l_cycle )?mem[{l_raddr[ADDR-1:0]}]:8'hff;
  always@(*)         rdata  =      tmp_rdata;   
  end
else
  begin 
  // Read function gets old data if also a write cycle
  always@(posedge clk)
        if( rd && cs ) rdata             <= mem[{addr[ADDR-1:0]}];
        else           rdata             <= 8'hff;
  end		   
endgenerate
  endmodule
