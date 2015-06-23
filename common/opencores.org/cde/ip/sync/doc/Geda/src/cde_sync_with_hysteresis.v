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



module cde_sync_with_hysteresis 
#( parameter  WIDTH           = 1,
   parameter  DEBOUNCE_SIZE   = 4,
   parameter  DEBOUNCE_DELAY  = 4'b1111
 )

(

input wire                clk,
input wire                reset,

input  wire [WIDTH - 1:0] data_in,
output reg  [WIDTH - 1:0] data_out,

output reg  [WIDTH - 1:0] data_rise, 
output reg  [WIDTH - 1:0] data_fall

  

);


reg [WIDTH - 1:0]         hysteresis_data; 
reg [WIDTH - 1:0]         clean_data; 
reg [DEBOUNCE_SIZE-1:0]        debounce_counter;

always@(posedge clk ) 
  if(reset)  
     begin
     data_out  <= data_in;
     data_rise <= {WIDTH{1'b0}};
     data_fall <= {WIDTH{1'b0}};
     end
  else
     begin
     data_out  <= clean_data;
     data_rise <= clean_data &( data_out  ^ clean_data);
     data_fall <= data_out   &( data_out  ^ clean_data);
     end



   




always@(posedge clk ) 
       if(reset)
	 begin
	    clean_data             <= data_in;
            hysteresis_data        <= data_in;
            debounce_counter       <= {DEBOUNCE_SIZE{1'b0}};
         end
       else
         begin
         // if the current input data differs from hysteresis 
         // then reset counter and update hysteresie
         
         if(data_in != hysteresis_data )
	      begin 
	      clean_data           <= clean_data;
              hysteresis_data      <= data_in;
              debounce_counter     <= {DEBOUNCE_SIZE{1'b0}};
	      end
        // if counter reaches DEBOUNCE_DELAY then the signal is clean
         else 
         if(debounce_counter == DEBOUNCE_DELAY)
	      begin
              clean_data           <= hysteresis_data;
	      hysteresis_data      <= hysteresis_data; 
              debounce_counter     <= debounce_counter;
              end		 
           // data_in did not change but counter did not reach limit. Increment counter
         else
	      begin
              clean_data           <= clean_data;
	      hysteresis_data      <= hysteresis_data; 
              debounce_counter     <= debounce_counter+1;		 
              end 
         end 
   





   

endmodule

