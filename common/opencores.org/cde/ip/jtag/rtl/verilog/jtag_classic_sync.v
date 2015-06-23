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
cde_jtag_classic_sync
#(parameter JTAG_SEL        = 1   // number of select signals
  )  

  
(
 input wire 		clk, // system clock

   
 input wire 		update_dr_clk, // clock
 input wire             shiftcapture_dr_clk, // clock
 input wire 		test_logic_reset, // async reset
 input wire 		tdi, // scan-in of jtag_register
 input wire  [JTAG_SEL-1:0] 	select, // '1' when jtag accessing this register 
 output wire [JTAG_SEL-1:0] tdo, // scan-out of jtag register
 input wire 		capture_dr,
 input wire 		shift_dr,


 output wire 		syn_clk,
 output reg             syn_reset,              
 input wire [JTAG_SEL-1:0] 	syn_tdo_i, // scan-in of jtag_register
 output reg [JTAG_SEL-1:0] 	syn_select, // '1' when jtag accessing this register 
 output reg 		syn_tdi_o, // scan-out of jtag register
 output reg 		syn_capture_dr,
 output reg 		syn_shift_dr,
 output reg 		syn_update_dr

);



   reg 			  synced_reset;

   always@(posedge clk or posedge test_logic_reset  )
   if(test_logic_reset)
      begin
      synced_reset <= 1'b1;
      syn_reset    <= 1'b1;
      end
   else
      begin
      synced_reset <= test_logic_reset; 
      syn_reset    <= synced_reset;
      end
   

   reg 			  synced_shift_dr;
   reg 			  synced_capture_dr;


   
   
   always@(posedge clk)
     if(!shiftcapture_dr_clk)
       begin
       synced_shift_dr    <= shift_dr ;
       synced_capture_dr  <= capture_dr ;
       end
     
     else
       begin
       synced_shift_dr    <= synced_shift_dr ;
       synced_capture_dr  <= synced_capture_dr ;
       end


   reg [1:0]  synced_shiftcapture_dr_clk;
   

   always@(posedge clk)	      
     synced_shiftcapture_dr_clk <= {synced_shiftcapture_dr_clk[0],shiftcapture_dr_clk};


   reg [1:0]  synced_update_dr_clk;
   

   always@(posedge clk)	      
     synced_update_dr_clk <= {synced_update_dr_clk[0],update_dr_clk};
   


   always@(posedge clk)
     if(synced_shiftcapture_dr_clk == 2'b01)
       begin
       syn_shift_dr      <= synced_shift_dr ;
       syn_capture_dr    <= synced_capture_dr ;
       end
     else
       begin
       syn_shift_dr      <= 1'b0 ;
       syn_capture_dr    <= 1'b0 ;
       end


   
   always@(posedge clk)
     if(synced_update_dr_clk == 2'b01)
       begin
       syn_update_dr      <= 1'b1 ;
       end
     else
       begin
       syn_update_dr      <= 1'b0 ;
       end



   always@(posedge clk)
     if(!shiftcapture_dr_clk && (shift_dr || capture_dr  ))
       begin
       syn_tdi_o         <= tdi ;
       end
     
     else
       begin
       syn_tdi_o         <= syn_tdi_o ;
       end


   





   

   always@(posedge clk)
     if(synced_update_dr_clk == 2'b01)
       begin
       syn_select      <= select;
       end
   else if(synced_shiftcapture_dr_clk == 2'b01)
       begin
       syn_select      <= select;	  
       end
   
     else
       begin
       syn_select      <= syn_select;	  
       end

   


   



   assign    syn_clk             = clk;
   assign    tdo                 = syn_tdo_i;   

   



endmodule
