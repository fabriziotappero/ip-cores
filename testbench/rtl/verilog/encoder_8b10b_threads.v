
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "encoder_8b10b_threads.v"                        ////
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
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "timescale_tb.v"

package encoder_8b10b_threads;

  import tb_utils::hexformat;
   
  import packet::Packet;
  import packet::PacketMailBox;
 
  import ethernet_frame::EthernetFrame;
  import ethernet_frame::FrameMailBox;
 
  typedef struct packed { reg [7:0] ABCDEFGH; reg k; reg [9:0] abcdeifghj; reg rd; } EbTb_Data;
 	   
  typedef mailbox #(EbTb_Data) Encoder8bMailBox;
    
  virtual class SendThread;
   
   virtual task run(Encoder8bMailBox mbx);
    endtask 

   virtual task pass_to_checker(EbTb_Data EncoderData, Encoder8bMailBox mbx);
      mbx.put(EncoderData);
   endtask
   
  endclass


   virtual class CheckThread;
     virtual task run(Encoder8bMailBox expected_mbx);
     endtask
   endclass

  
  //******************************************************************************
  // 8B/10B code tables
  //******************************************************************************

   integer K_eb_table[12];
 
   integer K_tb_table_RD[12];
   integer K_tb_table_nRD[12];
   
   integer D_tb_table_RD[256];
   integer D_tb_table_nRD[256];

   integer DEBUG = 1;
   
   function automatic void init(output reg encode_rd, output reg decode_rd, output int result);
      
      integer error = 0;
      
      integer File_P = $fopen("data/8b10b.dat", "r");
      
      if (File_P) begin
	
	 integer k, eb_symbol, tb_symbol, ntb_symbol, RD;
	
	 integer d_count = 0; integer k_count = 0;
	 
	 while (!$feof(File_P) && !error) begin          
	    
	    integer tfg = $fscanf(File_P, "%d %b %b %b %d", k, eb_symbol, tb_symbol, ntb_symbol, RD);
	    
	    if (DEBUG) $display("%m: Read %b, %b, %b, %b, %b", k, eb_symbol, tb_symbol, ntb_symbol, RD);
	    
	    if (k) 
	      begin
		 if (k_count > 12) begin $display("%m: Error read too many Special (K) symbols from file"); error = 1; end
	    
		 K_eb_table[k_count] = eb_symbol; K_tb_table_RD[k_count] = tb_symbol;  K_tb_table_nRD[k_count] = ntb_symbol;
		 
		 k_count += 1;		 
	      end
	    else
	      begin
		 if (d_count > 255) begin $display("%m: Error read too many Data (D) symbols from file"); error = 1; end
		 
		 D_tb_table_RD[d_count] = tb_symbol; D_tb_table_nRD[d_count] = ntb_symbol; 
		 
		 d_count += 1;
	      end 
	 end
	 
	 $fclose(File_P);  
      end 
      else 
	$display("%m: unable to open file 8b10.txt");

      if (DEBUG) begin
	 $display("%m: 8B/10B Data Symbols");

	 for (int eb_symbol=0; eb_symbol < 256; eb_symbol++) 
	   $display("%m: Read 0x%02h, %10b, %10b", eb_symbol, D_tb_table_RD[eb_symbol], D_tb_table_nRD[eb_symbol]);
	 
	 $display("%m: 8B/10B Special (K) Symbols");
	 
	 for (int eb_symbol=0; eb_symbol < 12; eb_symbol++)      
	   $display("%m: Read 0x%02h, %10b, %10b",  K_eb_table[eb_symbol], K_tb_table_RD[eb_symbol], K_tb_table_nRD[eb_symbol]);
      end
         
      // On starup the transmitter (encoder) should assume -ve disparity
      encode_rd = 1'b0; 

      // On startup, the receiver (decoder) should assume +ve or -ve disparity
      // See IEEE 802.3-2008 Clause 35 - 36.2.4.4
      // I've chosen positive disparity here
      decode_rd = 1'b1;
      
      result = ~error;
      
   endfunction // automatic

   //******************************************************************************
   // 8B/10B random
   //******************************************************************************
     
     function automatic void random(int seed=-1, output int value);
      
      if (seed >= 0) begin int tmp = $urandom(seed); end
      
      value = $urandom() & 'hff;
      
    endfunction

 
   //******************************************************************************
   // 8B/10B disparity - calculate number 1's and 0's in a 10B symbol
   //******************************************************************************
   
     function void disparity_calc(input reg [9:0] tb_symbol, 
				  output int count_0s, output int count_1s);
      
      count_0s = 0; count_1s = 0;
      
      for (int x=0; x < 10; x++)
	if ((tb_symbol >> x) & 1) count_1s +=1; else count_0s +=1;
      
     endfunction
   
  //******************************************************************************
  // 8B/10B encode function
  //******************************************************************************
   
   function automatic void encode(input  reg [7:0] eb_symbol, 
				  input  reg k, 
				  input  reg encode_rd_in, 
				  output reg encode_rd_out, 
				  output reg [9:0] tb_symbol);
      int count0s = 0; int count1s = 0;
      
      tb_symbol = (~k &  encode_rd_in) ? D_tb_table_nRD[eb_symbol] :
		  (~k & ~encode_rd_in) ? D_tb_table_RD[eb_symbol]  :
		  ( k &  encode_rd_in) ? K_tb_table_nRD[eb_symbol] : K_tb_table_RD[eb_symbol];

      // Determine disparity of 10B symbol
      disparity_calc(tb_symbol, count0s, count1s);
      
      encode_rd_out = (count1s == count0s) ? encode_rd_in : (count1s < count0s) ? 0 : 1;
      
  endfunction 

  //******************************************************************************
  // 8B/10B decode function
  //******************************************************************************

   function automatic void decode_K(input  reg[9:0] tb_symbol_in,     
				    input  reg decode_rd_in, 
				    output reg [7:0] eb_symbol,     
				    output reg decode_rd_out, 
				    output reg decode_rd_err, 
				    output reg K_match);
      
      reg K_tb_RD_match,  K_tb_nRD_match;
      
      K_match = 0; decode_rd_err = 0;

      decode_rd_out = decode_rd_in;
      
      // Scan through all 12 Special (K) symbols to see if 
      for (int x=0; x < 12; x++) begin

	 // +ve disparity K 10B symbol match ?
	 K_tb_RD_match  = (K_tb_table_RD[x] == tb_symbol_in);

	 // -ve disparity K 10B symbol match ?
	 K_tb_nRD_match = (K_tb_table_nRD[x] == tb_symbol_in);
	 
	 // Is there a march in either the +ve or -ve disparity 10B Special (K) tables
	 if (K_tb_RD_match | K_tb_nRD_match) begin
	    
	    int count0s = 0; int count1s = 0;
	    
	    disparity_calc(tb_symbol_in, count0s, count1s);
	    
	    if (count1s != count0s) begin
	       
	       // Yes, so determine if the disparity is as expected
	       decode_rd_err = (decode_rd_in) ? K_tb_RD_match : K_tb_nRD_match;
	       
	       // Determine resultant RD
	       decode_rd_out = (decode_rd_err) ? decode_rd_in : ~decode_rd_in;
	    end
	    else begin decode_rd_out = decode_rd_in; end
	    
	    // Return 8B symbol
	    eb_symbol = K_eb_table[x]; K_match = 1'b1; break;
	 end
      end
   
   endfunction

   function automatic void decode_D(input reg[9:0] tb_symbol_in,  input  reg decode_rd_in, 
				    output reg [7:0] eb_symbol_out, output reg decode_rd_out, 
				    output reg decode_rd_err, output reg D_match);
      
      reg D_tb_RD_match,  D_tb_nRD_match;  
      
      D_match = 0; decode_rd_err = 0;

      decode_rd_out = decode_rd_in;
      
      // Search for the tb_symbol in the current
      for (int eb_symbol = 0; eb_symbol < 256; eb_symbol++) begin
	 
	 // +ve disparity 10B Data symbol match ?
	 D_tb_RD_match  = (D_tb_table_RD[eb_symbol] == tb_symbol_in);
	 
	 // -ve disparity 10B Data symbol match ?
	 D_tb_nRD_match = (D_tb_table_nRD[eb_symbol] == tb_symbol_in);

	 // Is there a march in either the +ve or -ve disparity 10B Data tables
	 if (D_tb_RD_match | D_tb_nRD_match) begin
	    
	    int count0s = 0; int count1s = 0;
	    
	    disparity_calc(tb_symbol_in, count0s, count1s);
  
	    // If the number of 1's and 0's the same ?
	    if  (count1s != count0s) begin
	       
	       // No, so determine if a RD error has occured
	       decode_rd_err = (decode_rd_in) ? D_tb_RD_match : D_tb_nRD_match;
	       
	       // Determine mre RD
	       decode_rd_out = (decode_rd_err) ? decode_rd_in : ~decode_rd_in;
	    end
	    // Equal No 1's and 0's so Leave the RD the same - see IEEE 802.3-2006 Clause 36, 36.2.4.4 c)
	    else begin decode_rd_out = decode_rd_in; end
	    
	    // Return 8B symbol
	    D_match = 1; eb_symbol_out = eb_symbol; break;
	 end
      end
   endfunction
      
   function automatic void decode(input  reg [9:0] tb_symbol_in,   
				  input  reg decode_rd_in, 
				  output reg decode_rd_out,  
				  output reg K_out,        
				  output reg [7:0] eb_symbol_out,       
				  output reg decode_rd_err, 
				  output reg decode_code_err);
      reg K = 1'b0; reg D = 1'b0;
      
      decode_rd_out = decode_rd_in;
      
      // Attempt to decode this as a Special 10B Kx.y Symbol
      decode_K(tb_symbol_in, decode_rd_in, eb_symbol_out, decode_rd_out, decode_rd_err, K);
      
      // If not a Special 10B K Symbol, try and decode as a 10B Dx.y data symbol
      if (!K) decode_D(tb_symbol_in, decode_rd_in, eb_symbol_out, decode_rd_out, decode_rd_err, D);

      //$display("%m: K = %d,  D = %d", K, D);

      // Determine if this is Kx.y symbol or a Dx.y symbol
      K_out = (K & ~D) ? 1'b1 : 1'b0;
   
      // Signal a decoding error.
      decode_code_err = (K ^ D) ? 1'b0 : 1'b1;
      
   endfunction // automatic

   
   function automatic void split(input reg [7:0] eb_symbol, output reg [4:0] x, output reg [2:0] y);
      
      // Determine 3B/4B and 5B/6B symbol names (i.e. x and y = as in Dx.y or Kx.y)
      x =  (eb_symbol & 8'b00011111); 
      
      y =  (eb_symbol >> 5);
      
   endfunction // automatic

      
   //******************************************************************************
   // Encoder 8B Send Thread
   //******************************************************************************
   
     class Encoder8bSendThread extends SendThread;
   
     virtual encoder_8b_send_intf sender;
      
     // Do nothing constructor.
     function new(); endfunction

     static function Encoder8bSendThread NEW(
        virtual encoder_8b_send_intf sender
     );
        Encoder8bSendThread x = new();
        x.sender       = sender;
        return x;
     endfunction
   
 
   reg [15:0] config_reg_send = 16'hefbe;

   reg 	      encoder_rd, decoder_rd, errors;
        
   enum logic [2:0] { XMIT_STATE_IDLE          = 0,
		      XMIT_STATE_CONFIGURATION = 1,
		      XMIT_STATE_DATA          = 2,
		      XMIT_STATE_FRAME         = 3} xmit_state;
   
   virtual task run(Encoder8bMailBox mbx);

      integer iteration = 0;
      
      int seed = -1; int random_number;
   
      while(1)
	begin  
	   // Generate burst of Ethernet frames 
	   xmit_state = (iteration >= 10) ? XMIT_STATE_FRAME : XMIT_STATE_IDLE;
	   
	   iteration = (iteration >= 10) ? 0 : iteration;
	      
	   case (xmit_state)
	     
	     XMIT_STATE_IDLE:
	       begin
		  // Does nothing - send model sends IDLEs when no data
	       end
	     
	     XMIT_STATE_CONFIGURATION:
	       begin
		  // Push config reg to DUT
		  sender.push_config(config_reg_send);
		  
		  // Pass encoder data to checker thread
		  //pass_to_checker16(config_reg_send, mbx);
	       end
	     
	     XMIT_STATE_DATA:
	       begin
		  reg [7:0] encoder_8B_symbol;
      
		  for (int v=0; v < 100; v++)
		    begin
		       // Generate random data to send
		       encoder_8b10b_threads::random(seed, encoder_8B_symbol);
		       
		       //$display("%m: pushing %8b", encoder_8B_symbol);
		       
		       
		       // Push 8B data symbol to DUT via eb_send_intf interface
		       sender.push_8B_symbol(encoder_8B_symbol);
		  
		       // Pass encoder data to checker thread
		       //pass_to_checker8(encoder_8B_symbol, mbx);
		    end
	       end // case: XMIT_STATE_DATA
	    

	     XMIT_STATE_FRAME:
	       begin
		  integer num_frames; EthernetFrame frame;
		  
		  encoder_8b10b_threads::random(seed, num_frames);

		  num_frames &='hf;
		  
		  for(int i=0; i<num_frames; i++)
		    begin
		       int len; encoder_8b10b_threads::random(seed, len);

		       len &= 'hf;
		       
		       $display("\nSending Ethernet frame: %0d, length: %0d\n", i, len);
		       
		       frame = new(.length(len));
		       
		       $display("Transmit: %s\n", frame.repr_verbose(/*len*/));
		       
		       sender.queue_frame(EthernetFrame'(frame));
		       
		       //pass_to_checker(frame, mbx);
		       
		    end
		  
	       end
	     
	   endcase; // case(xmit_state)

	   // Sleep so that Idle symbols are transmitted
	   sender.sleep(500);

	   iteration += 1;
	end
    endtask

  
   virtual task pass_to_checker8(reg [7:0] encoder_8B_symbol, Encoder8bMailBox mbx);
      
      reg encoder_k = 0;  EbTb_Data EncoderData;
      
      reg [9:0] encoder_tb_symbol; 
      
      reg [4:0] x; reg[2:0] y;
      
      // Split 8B symbol into 3B/4B and 5B/6B components
      encoder_8b10b_threads::split(encoder_8B_symbol, x, y);
      
      // Encode 8B symbol -> 10B symbol
      encoder_8b10b_threads::encode(encoder_8B_symbol, encoder_k, encoder_rd, encoder_rd, encoder_tb_symbol);
      
      //$display("%m: Encoder [8B_symbol = %08b, K = %01b, RD = %01b  10B_symbol = %010b] :  %s%02d.%01d",
      //       encoder_8B_symbol, encoder_k, encoder_rd,  encoder_tb_symbol, ((encoder_k) ? "K" : "D"), x, y);
      
      // Pack encoder data 
      EncoderData = { encoder_8B_symbol, encoder_k, encoder_tb_symbol, encoder_rd } ;

      mbx.put(EncoderData);
      
   endtask
       
   virtual task pass_to_checker16(reg [15:0] symbol_16, Encoder8bMailBox mbx);
      
      pass_to_checker8(symbol_16[7:0], mbx); pass_to_checker8(symbol_16[15:8], mbx);
      
   endtask
      
   endclass

 
   //******************************************************************************
   // 10B Check Thread
   //******************************************************************************

   class Encoder10bCheckThread extends CheckThread;
     virtual encoder_10b_check_intf checkeri;
   
     // Do nothing constructor.
     function new(); endfunction

     static function Encoder10bCheckThread NEW(
        virtual encoder_10b_check_intf checkeri
     );
        Encoder10bCheckThread x = new();
        x.checkeri = checkeri; 
        return x;
     endfunction

   
   virtual task run(Encoder8bMailBox expected_mbx);
      
      string mod_name = string'(checkeri.whoami());

      // Encoder thread declarations
      reg [9:0] encoder_10B_symbol; reg [7:0] encoder_8B_symbol;
      
      reg encoder_k, encoder_rd;
      
      integer  encoder_x, encoder_y; EbTb_Data encoder_data;
      
      // Checker declarations
      reg [9:0] checker_10B_symbol; reg [7:0] checker_8B_symbol;

      reg checker_k, checker_rd, checker_rd_err, checker_code_err;

      integer  checker_x, checker_y, checker_errors;
      
      integer iteration = 0;

      reg null_rd;
      
      // Initialise checker 8B/10B generation
      encoder_8b10b_threads::init(null_rd, checker_rd, checker_errors);

      // Forever
      while(1) 
	begin

	   /*
	    
	    // Decode the 10B symbol from the checker model
	   encoder_8b10b_threads::decode(checker_10B_symbol, checker_rd, checker_rd, checker_k, 
				checker_8B_symbol, checker_rd_err, checker_code_err);
	   
	   // Pull data passed from Encoder thread
	   expected_mbx.get(encoder_data);
	   
	   // Extract out data passed from Encoder thread
	   {encoder_8B_symbol, encoder_k, encoder_10B_symbol, encoder_rd} = encoder_data;

	   encoder_8b10b_threads::split(encoder_8B_symbol, encoder_x, encoder_y);
	   encoder_8b10b_threads::split(checker_8B_symbol, checker_x, checker_y);
	   
	   $display("%m: %08d: Encoder [8B_symbol = %08b, K = %01b, RD = %01b  10B_symbol = %010b] --> Checker [RD = %01b, 8B_symbol = %08b, K = %01b, RD_err = %01b, CODE_err = %01b] :  Encoder[%s%02d.%01d] Checker[%s%02d.%01d]",
		    iteration, encoder_8B_symbol, encoder_k, encoder_rd,  encoder_10B_symbol,
		    checker_rd,  checker_8B_symbol, checker_k,  
		    checker_rd_err, checker_code_err, 
		    ((encoder_k) ? "K" : "D"), encoder_x, encoder_y, 
		    ((checker_k) ? "K" : "D"), checker_x, checker_y,);
	    
	    iteration+=1;
	    */
	end // while (1)
   endtask
   
   endclass
     
  //******************************************************************************
  // This structure specifies a traffic stream to be sent between two points.
  //******************************************************************************
  typedef struct {
    SendThread  sender;
    CheckThread checkeri;
  } FlowEntry;


  //******************************************************************************
  // Traffic send/check task.
  //******************************************************************************
  class Flow;
    FlowEntry flow_table[$];

    function void add(SendThread s, CheckThread c);
      FlowEntry f = '{s, c};

      $display("%m");
       
      flow_table.push_back(f);
    endfunction

    function void clear();
      flow_table = {};
    endfunction

    task run(ref int errors);
      
      FlowEntry   f; Encoder8bMailBox mbx;
      
      $display("%m: Starting traffic.");

      // Launch all the send/receive threads...
      for(int i=0; i<flow_table.size(); i++)
        begin
           f = flow_table[i];
	   
           mbx = new();

           fork
              f.sender.run(mbx);
	      
              //if (f.checker) begin f.checker.run(mbx); end
	      
           join_none
	   
           #0; // Wait for the forked threads to start before changing their parameters!!!
        end
      
      wait fork;

	 $display("%m: %0t: All threads completed.", $time);
	 
    endtask
  endclass

endpackage

