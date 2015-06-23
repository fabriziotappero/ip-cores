//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "encoder_8b_tx_model.v"                           ////
////                                                              ////
////  This file is part of the :                                  ////
////                                                              ////
//// "1000BASE-X IEEE 802.3-2008 Clause 36 - PCS project"         ////
////                                                              ////
////  http://opencores.org/project,1000base-x                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - D.W.Pegler Cambridge Broadband Networks Ltd           ////
////                                                              ////
////      { peglerd@gmail.com, dwp@cambridgebroadand.com }        ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 AUTHORS. All rights reserved.             ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// This module is based on the coding method described in       ////
//// IEEE Std 802.3-2008 Clause 36 "Physical Coding Sublayer(PCS) ////
//// and Physical Medium Attachment (PMA) sublayer, type          ////
//// 1000BASE-X"; see :                                           ////
////                                                              ////
//// http://standards.ieee.org/about/get/802/802.3.html           ////
//// and                                                          ////
//// doc/802.3-2008_section3.pdf, Clause/Section 36.              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "timescale_tb.v"

module encoder_8b_tx_model #(
  parameter DEBUG       = 0,
  parameter out_delay   = 5,
  parameter in_delay    = 2
)(
  interface send_intf,

   // --- Clocks
   input SBYTECLK,
	
   input disparity_in,
 	  
   // --- Eight bit input bus	  
   output [7:0] ebi,

  
   output K
);

   import ethernet_frame::EthernetFrame;
   
   reg [7:0] 	tmp_ebi;
   reg          tmp_K;
   reg 		disparity;

   assign #out_delay ebi = tmp_ebi;
   assign #out_delay K   = tmp_K;
 
   // Single transmit data queue
   reg [7:0] encoder_8b_data_queue[$];

   // Config data queue
   reg [15:0] encoder_8b_config_queue[$];
   
   // Single transmit queue
   EthernetFrame transmit_queue[$];
  
   //----------------------------------------------------------------------------
  // Send interface functions
  //----------------------------------------------------------------------------

   function automatic string send_intf.whoami();
      string buffer;
      $sformat(buffer, "%m");
      return buffer.substr(0, buffer.len()-17);
   endfunction
   
   function automatic void send_intf.push_8B_symbol(reg [7:0] symbol);

      encoder_8b_data_queue.push_back(symbol);
      
   endfunction // automatic

   
   function automatic void send_intf.push_config(reg [15:0] config_reg);
      
      encoder_8b_config_queue.push_back(config_reg);
      
   endfunction // automatic

   
   // Queue frame for transmission.
   function automatic void send_intf.queue_frame(EthernetFrame frame);
      
      EthernetFrame f = frame;
      
      transmit_queue.push_back(f);
  
  endfunction // automatic
   
	
  // Wait for all frames to be transmitted.
   task automatic send_intf.sleep(time timeout);
      time start_time = $time;
      time end_time = start_time + timeout;
      
      while(1)
      begin
         @(posedge SBYTECLK);
	 
         if ($time > end_time)  break;
      end
  endtask

   //----------------------------------------------------------------------------
   //
   //----------------------------------------------------------------------------
   
`define K28_5 8'b10111100   

   task automatic encoder_8b_push_symbol(input K, input [7:0] ebi);
      tmp_K = K; tmp_ebi = ebi;
      @(posedge SBYTECLK);
   endtask
   

   //----------------------------------------------------------------------------
   // Test Sequence Functions
   //----------------------------------------------------------------------------

   task automatic encoder_8b_push_test_sequence();
      
      encoder_8b_push_symbol(1'b1, `K28_5);
   endtask
   
   //----------------------------------------------------------------------------
   // IDLE Sequence Functions
   //----------------------------------------------------------------------------

`define D5_6  8'b11000101
`define D16_2 8'b01010000
     
   reg [7:0] I1[2] = '{ `K28_5, `D5_6  };
   reg [7:0] I2[2] = '{ `K28_5, `D16_2 };

   task automatic encoder_8b_push_idle_sequence();

      for (int x=0; x<2; x++)
	encoder_8b_push_symbol(~x, (disparity_in) ? I1[x] : I2[x]);
      
   endtask // automatic
   
    
   //----------------------------------------------------------------------------
   // Config Sequence Functions
   //----------------------------------------------------------------------------
   
`define D21_5 8'b10110101
`define D2_2  8'b01000010
   
   reg [7:0] C1[2] = '{ `K28_5, `D21_5 };
   reg [7:0] C2[2] = '{ `K28_5, `D2_2  };
   
   reg 	     c_toggle = 0;
   
   task automatic encoder_8b_push_config_sequence(reg [15:0] config_reg);

      //$display("%m: pushing config_reg: %016b", config_reg);

      for (int x=0; x<2; x++)

	// If disparity after K28.5 is +ve then choose
	// D2.2 to flip disparity
	// If disparity after K28.5 is -ve then choose
	// D31.5 to leave the disparity as -ve.: +(--+-)+
	// Doing this ensures that in a burst of /C/ sequences,
	// The disparity on before K28_5 is -ve so +comma is
	// always chosen!
	encoder_8b_push_symbol(~x, (c_toggle) ? C2[x] : C1[x]);

      // Push Config Register value
      encoder_8b_push_symbol(1'b0, config_reg[7:0]);
      
      // Push Config Register value
      encoder_8b_push_symbol(1'b0, config_reg[15:8]);

      c_toggle = ~c_toggle;
      
   endtask // automatic
   
   //----------------------------------------------------------------------------
   // Frame transmit Functions
   //----------------------------------------------------------------------------
   
`define K23_7  8'b11110111
`define K27_7  8'b11111011
`define K29_7  8'b11111101

   task automatic encoder_8b_transmit_frame();
      
      EthernetFrame frame;
      
      integer burst_size = transmit_queue.size;

      integer burst_count = 0;
      
      while (transmit_queue.size())
	begin
	   // Select frame at front of the queue
	   frame = transmit_queue[0];

	   // If this a burst insert /R/ before /S/
	   if ((burst_size > 1) && (burst_count))
	     encoder_8b_push_symbol(1'b1, `K23_7);
	   	  
	     // Transmit SFD
	   encoder_8b_push_symbol(1'b1, `K27_7);
	   
	   // Push frame
	   for (int index=0; index<frame.len(); index++)
	     encoder_8b_push_symbol(1'b0, frame.raw[index]);
	   
	   // Push EPD
	   encoder_8b_push_symbol(1'b1, `K29_7);

	   // Keep track of the number of frames transmitted in a burst.
	   burst_count += 1;
	   
	   void'(transmit_queue.pop_front());
	end
   endtask // automatic
   
   //----------------------------------------------------------------------------
   // Transmit Process.
   //----------------------------------------------------------------------------
   task automatic encoder_8b_push();

      // Is there any ctrl data to bus
      if (encoder_8b_config_queue.size())     

	// Push sequence C1/C2/Config_Reg
	encoder_8b_push_config_sequence(encoder_8b_config_queue.pop_front());

      // Are there any frames to transmit ?
      else if (transmit_queue.size())

	// Push SPD + frame + EFD
	encoder_8b_transmit_frame();
		      
      // Is there any Data to push
      else if (encoder_8b_data_queue.size()) 

	// Push data 
	encoder_8b_push_symbol(1'b0, encoder_8b_data_queue.pop_front());
      
      else
	// Otherwise push the Idle sequence I1 or I2
	encoder_8b_push_idle_sequence();

   endtask // automatic

  
   //----------------------------------------------------------------------------
   //----------------------------------------------------------------------------
   
  initial
    begin
       tmp_ebi = 8'h00; tmp_K = 0;

       // Get initial disparity
       disparity = disparity_in;
       
       /// Obtain initial sync...
       @(posedge SBYTECLK);
      
       while(1)
	 begin
	    encoder_8b_push();

	    // Get disparity at end of every symbol push
	    disparity = disparity_in;
	 end
         
    end

endmodule

