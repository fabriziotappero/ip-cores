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
  cde_sram_def 
    #( parameter 
      ADDR=10,
      WIDTH=8,
      WORDS=1024,
      WRITETHRU=0,
      INIT_FILE="NONE",
      MEM="NONE",
      INSTANCE_NAME="../../../../../children/")
     (
 input   wire                 clk,
 input   wire                 cs,
 input   wire                 rd,
 input   wire                 wr,
 input   wire    [ ADDR-1 :  0]        addr,
 input   wire    [ WIDTH-1 :  0]        wdata,
 output   reg    [ WIDTH-1 :  0]        rdata);
// Memory Array
reg [WIDTH-1:0] mem[0:WORDS-1];
// If used as Rom then load a memory image at startup
initial 
  begin
   if( MEM  == "NONE")
     begin
     end
   else
        begin
 	$readmemh(MEM, mem);
	end
  end
// Write function   
// Write function   
always@(posedge clk)
        if( wr && cs ) mem[addr[ADDR-1:0]] <= wdata[WIDTH-1:0];
generate
if( WRITETHRU) 
  begin
  // Read function gets new data if also a write cycle
  // latch the read addr for next cycle   
  reg   [ADDR-1:0]          l_raddr;  

  reg                       l_cycle;     

  always@(posedge clk)   
        l_cycle    <=  rd && cs  ;   
       

  always@(posedge clk)      l_raddr    <= addr;   
  // Read into a wire and then pass to rdata because some synth tools can't handle a memory in a always block
  wire  [WIDTH-1:0] tmp_rdata;
  assign                    tmp_rdata  =      (l_cycle )?mem[{l_raddr[ADDR-1:0]}]:{WIDTH{1'b1}};
  always@(*)                rdata  =      tmp_rdata;   
  end
else
  begin 
  // Read function gets old data if also a write cycle
  always@(posedge clk)
        if( rd && cs ) rdata             <= mem[{addr[ADDR-1:0]}];
        else           rdata             <= {WIDTH{1'b1}};
  end		   
endgenerate
  endmodule
