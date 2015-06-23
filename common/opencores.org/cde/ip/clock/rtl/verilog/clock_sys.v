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
cde_clock_sys
#(parameter   FREQ        = 48,  
              PLL_MULT    =  2,
              PLL_DIV     =  4,
              PLL_SIZE    =  4,
              CLOCK_SRC   =  0,
              RESET_SENSE =  0
)  

(
input  wire   a_clk_pad_in,
input  wire   b_clk_pad_in,
input  wire   pwron_pad_in,
output  wire  div_clk_out,
output  reg   one_usec,
output  wire  reset

);

wire       ckIn;
wire       dll_clk;
reg        ref_reset;
   
reg [6:0]  counter;   
reg [3:0]  reset_cnt;

wire       pwron_reset;
wire       pwron_reset_n;
wire       dll_reset;
   
assign pwron_reset_n = !pwron_reset;
   

   
generate

if( CLOCK_SRC) 

  begin
  assign ckIn = b_clk_pad_in;
  end
else
  begin 
  assign ckIn = a_clk_pad_in;
  end		   

endgenerate


generate

if( RESET_SENSE) 

  begin
  assign pwron_reset = !pwron_pad_in;
  end
else
  begin 
  assign pwron_reset = pwron_pad_in;
  end		   

endgenerate




   
     

   

always@(posedge ckIn or posedge pwron_reset)
  if( pwron_reset)   reset_cnt     <= 4'b1111;
  else
  if(|reset_cnt)     reset_cnt     <= reset_cnt-4'b0001;
  else               reset_cnt     <= 4'b0000;
   


always@(posedge ckIn or posedge pwron_reset)
  if( pwron_reset)   ref_reset     <= 1'b1;
  else               ref_reset     <= |reset_cnt;


always@(posedge dll_clk)
  if(dll_reset)                       
       begin
       one_usec  <=  1'b0;
       counter   <=  FREQ*PLL_MULT/2;
       end
  else if(counter == 7'b0000001)
       begin
       one_usec  <= !one_usec;
       counter   <=  FREQ*PLL_MULT/2;
       end
  else
       begin
       one_usec  <=  one_usec;	  
       counter   <=  counter -7'b0000001;
       end
       


cde_clock_dll 
  #(.MULT   (PLL_MULT),
    .DIV    (PLL_DIV),
    .SIZE   (PLL_SIZE)
   ) 
dll ( 
        .ref_clk            (ckIn),
        .reset              (pwron_reset),
        .dll_clk_out        (dll_clk),      
        .div_clk_out        (div_clk_out)
    );



cde_sync_with_reset 
  #(.WIDTH  (1),
    .DEPTH  (2),
    .RST_VAL(1'b1)
   ) 
  ref_rsync(
    .clk                 (div_clk_out),
    .reset_n             (pwron_reset_n),
    .data_in             (ref_reset),
    .data_out            (reset)
       );


cde_sync_with_reset 
  #(.WIDTH  (1),
    .DEPTH  (2),
    .RST_VAL(1'b1)
   ) 
  dll_rsync(
    .clk                 (dll_clk),
    .reset_n             (pwron_reset_n),
    .data_in             (ref_reset),
    .data_out            (dll_reset)
       );
   

   
endmodule
