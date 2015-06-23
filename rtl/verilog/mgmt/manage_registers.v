`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// MODULE NAME: manage_registers                                ////
////                                                              ////
//// DESCRIPTION: implement read & write logic for configuration  ////
////              and statistics registers                        ////
////                                                              ////
//// This file is part of the 10 Gigabit Ethernet IP core project ////
////  http://www.opencores.org/projects/ethmac10g/                ////
////                                                              ////
//// AUTHOR(S):                                                   ////
//// Zheng Cao                                                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (c) 2005 AUTHORS.  All rights reserved.            ////
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
//
// CVS REVISION HISTORY:
//
// $Log: not supported by cvs2svn $
// Revision 1.4  2006/06/15 12:12:27  fisher5090
// modify mgmt_miim_rdy timing sequence
//
// Revision 1.3  2006/06/15 08:25:42  fisher5090
// comments added
//
// Revision 1.2  2006/06/15 05:09:24  fisher5090
// bad coding style, but works, will be modified later
//
// Revision 1.1  2005/12/25 16:43:10  Zheng Cao
// 
// 
//
//////////////////////////////////////////////////////////////////////
module manage_registers(mgmt_clk, rxclk, txclk, reset, mgmt_opcode, mgmt_addr, mgmt_wr_data, mgmt_rd_data, mgmt_miim_sel, mgmt_req, 
mgmt_miim_rdy, rxStatRegPlus, txStatRegPlus, cfgRxRegData, cfgTxRegData, mdio_opcode, mdio_data_out, mdio_data_in, mdio_in_valid,
mgmt_config, mdio_out_valid);
input mgmt_clk; //management clock
input rxclk; //receive clock
input txclk; //transmit clock
input reset; //system reset
input[1:0] mgmt_opcode; //management opcode(read/write/mdio)
input[9:0] mgmt_addr; //management address, including addresses of configuration, statistics and MDIO registers
input[31:0] mgmt_wr_data; //Data to be writen to Configuration/MDIO registers
output[31:0] mgmt_rd_data; //Data read from Configuration/Statistics/MDIO registers
input mgmt_miim_sel; //select internal register or MDIO registers
input mgmt_req; //Valid when operate statistics/MDIO registers, one clock valid____|-|____
output mgmt_miim_rdy; //Indicate the Management Module is in IDLE Status
input[18:0] rxStatRegPlus; //From Receive Module, one bit is related to one receive statistics register
input[14:0] txStatRegPlus; //From Transmit Module, one bit is related to one transmit statistics register
output[52:0] cfgRxRegData; //To Receive Module, config receive module
output[9:0] cfgTxRegData; //To Transmit Module, config transmit module
output[1:0] mdio_opcode; //MDIO Opcode, equals mgmt_opcode
output mdio_out_valid; //Indicate mdio_data_out is valid
output[25:0] mdio_data_out; //Data to be writen to MDIO, {addr, data}
input[15:0] mdio_data_in; //Data read from MDIO
input mdio_in_valid; //Indicate mdio_data_in read from MDIO is valid
output[31:0] mgmt_config; //management configuration data, mainly used to set mdc frequency

parameter IDLE =0, MDIO_OPERATE =1, STAT_OPERATE =2, CONFIG_OPERATE =3;
parameter TP = 1;

/////////////////////////////////////////////
// Statistics Register Definition
/////////////////////////////////////////////

//--Receive Related
reg[63:0] frame_received_good;
reg[63:0] fcs_error;
reg[63:0] broadcast_received_good;
reg[63:0] multicast_received_good;
reg[63:0] frame_64_good;
reg[63:0] frame_65_127_good;
reg[63:0] frame_128_255_good;
reg[63:0] frame_256_511_good;
reg[63:0] frame_512_1023_good;
reg[63:0] frame_1024_max_good;
reg[63:0] control_frame_good;
reg[63:0] lt_out_range;
reg[63:0] tagged_frame_good;
reg[63:0] pause_frame_good;
reg[63:0] unsupported_control_frame;
reg[63:0] oversize_frame_good;
reg[63:0] undersize_frame;
reg[63:0] fragment_frame;
reg[63:0] total_bytes_recved;

//--Transmit Related
reg[63:0] total_bytes_transed;
reg[63:0] good_frame_transed;
reg[63:0] broadcast_frame_transed;
reg[63:0] multicast_frame_transed;
reg[63:0] underrun_error;
reg[63:0] control_frame_transed;
reg[63:0] frame_64_transed;
reg[63:0] frame_65_127_transed;
reg[63:0] frame_128_255_transed;
reg[63:0] frame_256_511_transed;
reg[63:0] frame_512_1023_transed;
reg[63:0] frame_1024_max_transed;
reg[63:0] tagged_frame_transed;
reg[63:0] pause_frame_transed;
reg[63:0] oversize_frame_transed;

/////////////////////////////////////////////
// Configuration Registers Definition
/////////////////////////////////////////////

reg[31:0] recv_config0;
reg[31:0] recv_config1;
reg[31:0] trans_config;
reg[31:0] flow_control_config;
reg[31:0] rs_config;
reg[31:0] mgmt_config;

/////////////////////////////////////////////
// Input registers
/////////////////////////////////////////////

reg[8:0] mgmt_addr_d1;
always@(posedge mgmt_clk or posedge reset)begin
      if(reset)
		  mgmt_addr_d1 <=#TP 0;
		else 
		  mgmt_addr_d1 <=#TP mgmt_addr[8:0];
end

reg mdio_in_valid_d1;
always@(posedge mgmt_clk or posedge reset) begin
      if(reset)
		  mdio_in_valid_d1 <=#TP 1'b0;
		else 
		  mdio_in_valid_d1 <=#TP mdio_in_valid;
end		 

/////////////////////////////////////////////
// State Machine
/////////////////////////////////////////////
reg[1:0] state;
reg read_done;
always@(posedge mgmt_clk or posedge reset)begin
    if (reset)
	    state <=#TP IDLE;
	 else begin
	    case (state)
		    IDLE: begin
			     if(mgmt_req & mgmt_miim_sel) // MDIO Operations
				    state <=#TP MDIO_OPERATE;
				  else if(~mgmt_miim_sel & mgmt_req & ~mgmt_addr[9]) // Operations on Statistics registers 
				    state <=#TP STAT_OPERATE;
				  else if(~mgmt_miim_sel & mgmt_addr[9]) // Operations on Configuration registers
				    state <=#TP CONFIG_OPERATE;
				  else
				    state <=#TP IDLE;
			 end
          MDIO_OPERATE: begin
              if(~mdio_in_valid & mdio_in_valid_d1) // MDIO read/write done
                state <=#TP IDLE;
              else
                state <=#TP MDIO_OPERATE;
          end					
          STAT_OPERATE: begin 
              if(read_done) // for statistics registers, only read operation happens 
                state <=#TP IDLE;
              else
                state <=#TP STAT_OPERATE;
          end
          CONFIG_OPERATE: begin
              if(mgmt_req & mgmt_miim_sel) //during operation on configuration registers, 
                                           //other request can be responsed. because such 
	                                   //operations only take one cycle time.  
		state <=#TP MDIO_OPERATE
   	      else if(~mgmt_miim_sel & mgmt_req & ~mgmt_addr[9]) 
	        state <=#TP STAT_OPERATE;
	      else if(~mgmt_miim_sel & mgmt_addr[9])
	        state <=#TP CONFIG_OPERATE;
	     else
     	        state <=#TP IDLE;
          end
      endcase
   end
end	

/////////////////////////////////////////////
// Write Statistics Registers
/////////////////////////////////////////////

//--Receive Related
always@(posedge rxclk or posedge reset) begin
      if (reset)
         frame_received_good <=#TP 1;
      else if(rxStatRegPlus[0])
         frame_received_good <=#TP frame_received_good + 1;
end // num of good frames have been received

always@(posedge rxclk or posedge reset) begin
      if (reset)
         fcs_error <=#TP 2;
      else if(rxStatRegPlus[1])
         fcs_error <=#TP fcs_error + 1;
end // num of frames that have failed in FCS checking

always@(posedge rxclk or posedge reset) begin
      if (reset)
         broadcast_received_good <=#TP 0;
      else if(rxStatRegPlus[2])
         broadcast_received_good <=#TP broadcast_received_good + 1;
end // num of broadcast frames that have been successfully received

always@(posedge rxclk or posedge reset) begin
      if (reset)
         multicast_received_good <=#TP 0;
      else if(rxStatRegPlus[3])
         multicast_received_good <=#TP multicast_received_good + 1;
end // num of multicast frames that have been successfully received

always@(posedge rxclk or posedge reset) begin
      if (reset)
         frame_64_good <=#TP 0;
      else if(rxStatRegPlus[4])
         frame_64_good <=#TP frame_64_good + 1;
end //num of frames that have been successfully received, with length equal to 64

always@(posedge rxclk or posedge reset) begin
      if (reset)
         frame_65_127_good <=#TP 0;
      else if(rxStatRegPlus[5])
         frame_65_127_good <=#TP frame_65_127_good + 1;
end //num of frames that have been successfully received, with length between 65 and 127

always@(posedge rxclk or posedge reset) begin
      if (reset)
         frame_128_255_good <=#TP 0;
      else if(rxStatRegPlus[6])
         frame_128_255_good <=#TP frame_128_255_good + 1;
end //num of frames that have been successfully received, with length between 128 and 255

always@(posedge rxclk or posedge reset) begin
      if (reset)
         frame_256_511_good <=#TP 0;
      else if(rxStatRegPlus[7])
         frame_256_511_good <=#TP frame_256_511_good + 1;
end //num of frames that have been successfully received, with length between 256 and 511

always@(posedge rxclk or posedge reset) begin
      if (reset)
         frame_512_1023_good <=#TP 0;
      else if(rxStatRegPlus[8])
         frame_512_1023_good <=#TP frame_512_1023_good + 1;
end //num of frames that have been successfully received, with length between 512 and 1023

always@(posedge rxclk or posedge reset) begin
      if (reset)
         frame_1024_max_good <=#TP 0;
      else if(rxStatRegPlus[9])
         frame_1024_max_good <=#TP frame_1024_max_good + 1;
end //num of frames that have been successfully received, with length between 1024 and max length

always@(posedge rxclk or posedge reset) begin
      if (reset)
	      control_frame_good <=#TP 0;
	   else if(rxStatRegPlus[10])
         control_frame_good <=#TP control_frame_good + 1;
end //num of control frames that have been successfully received

always@(posedge rxclk or posedge reset) begin
      if (reset)
	      lt_out_range <=#TP 0;
	   else if(rxStatRegPlus[11])
         lt_out_range <=#TP lt_out_range + 1;
end //num of frames whose length are too large

always@(posedge rxclk or posedge reset) begin
      if (reset)
	      tagged_frame_good <=#TP 0;
	   else if(rxStatRegPlus[12])
         tagged_frame_good <=#TP tagged_frame_good + 1;
end //num of tagged frames that have been successfully received

always@(posedge rxclk or posedge reset) begin
      if (reset)
	      pause_frame_good <=#TP 0;
	   else if(rxStatRegPlus[13])
         pause_frame_good <=#TP pause_frame_good + 1;
end //num of pause frames that have been successfully received

always@(posedge rxclk or posedge reset) begin
      if (reset)
	      unsupported_control_frame <=#TP 0;
	   else if(rxStatRegPlus[14])
         unsupported_control_frame <=#TP unsupported_control_frame + 1;
end //num of frames whose type filed haven't been defined in IEEE 802.3*

always@(posedge rxclk or posedge reset) begin
      if (reset)
	      oversize_frame_good <=#TP 0;
	   else if(rxStatRegPlus[15])
         oversize_frame_good <=#TP oversize_frame_good + 1;
end //num of frames which are good, only with large size

always@(posedge rxclk or posedge reset) begin
      if (reset)
	      undersize_frame <=#TP 0;
	   else if(rxStatRegPlus[16])
         undersize_frame <=#TP undersize_frame + 1;
end //num of frames whose length are too short

always@(posedge rxclk or posedge reset) begin
      if (reset)
	      fragment_frame <=#TP 0;
	   else if(rxStatRegPlus[17])
         fragment_frame <=#TP fragment_frame + 1;
end //num of fragment frames 

always@(posedge rxclk or posedge reset) begin
      if (reset)
	      total_bytes_recved <=#TP 0;
	   else if(rxStatRegPlus[18])
         total_bytes_recved <=#TP total_bytes_recved + 1;
end //bytes have been received

//--Transmit Related
always@(posedge txclk or posedge reset) begin
      if (reset)
	      total_bytes_transed <=#TP 0;
	   else if(txStatRegPlus[0])
         total_bytes_transed <=#TP total_bytes_transed + 1;
end //bytes have been transmitted

always@(posedge txclk or posedge reset) begin
      if (reset)
	      good_frame_transed <=#TP 0;
	   else if(txStatRegPlus[1])
         good_frame_transed <=#TP good_frame_transed + 1;
end //num of error free frames have been transmitted

always@(posedge txclk or posedge reset) begin
      if (reset)
	      broadcast_frame_transed <=#TP 0;
	   else if(txStatRegPlus[2])
         broadcast_frame_transed <=#TP broadcast_frame_transed + 1;
end //num of broadcast frames have been transmitted

always@(posedge txclk or posedge reset) begin
      if (reset)
	      multicast_frame_transed <=#TP 0;
	   else if(txStatRegPlus[3])
         multicast_frame_transed <=#TP multicast_frame_transed + 1;
end //num of multicast frames have been transmitted

always@(posedge txclk or posedge reset) begin
      if (reset)
	      underrun_error <=#TP 0;
	   else if(txStatRegPlus[4])
         underrun_error <=#TP underrun_error + 1;
end //num of underrun error frames have been transmitted

always@(posedge txclk or posedge reset) begin
      if (reset)
	      control_frame_transed <=#TP 0;
	   else if(txStatRegPlus[5])
         control_frame_transed <=#TP control_frame_transed + 1;
end //num of control frames have been transmitted

always@(posedge txclk or posedge reset) begin
      if (reset)
	      frame_64_transed <=#TP 0;
	   else if(txStatRegPlus[6])
         frame_64_transed <=#TP frame_64_transed + 1;
end //num of frames have been transmitted, with length equal 64

always@(posedge txclk or posedge reset) begin
      if (reset)
	      frame_65_127_transed <=#TP 0;
	   else if(txStatRegPlus[7])
         frame_65_127_transed <=#TP frame_65_127_transed + 1;
end //num of frames have been transmitted, with length are between 65 and 127

always@(posedge txclk or posedge reset) begin
      if (reset)
	      frame_128_255_transed <=#TP 0;
	   else if(txStatRegPlus[8])
         frame_128_255_transed <=#TP frame_128_255_transed + 1;
end //num of frames have been transmitted, with length are between 128 and 255

always@(posedge txclk or posedge reset) begin
      if (reset)
	      frame_256_511_transed <=#TP 0;
	   else if(txStatRegPlus[9])
         frame_256_511_transed <=#TP frame_256_511_transed + 1;
end //num of frames have been transmitted, with length are between 256 and 511

always@(posedge txclk or posedge reset) begin
      if (reset)
	      frame_512_1023_transed <=#TP 0;
	   else if(txStatRegPlus[10])
         frame_512_1023_transed <=#TP frame_512_1023_transed + 1;
end //num of frames have been transmitted, with length are between 512 and 1023

always@(posedge txclk or posedge reset) begin
      if (reset)
	      frame_1024_max_transed <=#TP 0;
	   else if(txStatRegPlus[11])
         frame_1024_max_transed <=#TP frame_1024_max_transed + 1;
end //num of frames have been transmitted, with length are between 1024 and max length

always@(posedge txclk or posedge reset) begin
      if (reset)
	      tagged_frame_transed <=#TP 0;
	   else if(txStatRegPlus[12])
         tagged_frame_transed <=#TP tagged_frame_transed + 1;
end //num of tagged frames have been transmitted

always@(posedge txclk or posedge reset) begin
      if (reset)
	      pause_frame_transed <=#TP 0;
	   else if(txStatRegPlus[13])
         pause_frame_transed <=#TP pause_frame_transed + 1;
end //num of pause frames have been transmitted

always@(posedge txclk or posedge reset) begin
      if (reset)
	      oversize_frame_transed <=#TP 0;
	   else if(txStatRegPlus[14])
         oversize_frame_transed <=#TP oversize_frame_transed + 1;
end //num of frames whose length are larger than max length

/////////////////////////////////////////////
// Read Statistics Registers
/////////////////////////////////////////////
reg[63:0] stat_rd_data;
always@(posedge mgmt_clk or posedge reset) begin
      if(reset)
		  stat_rd_data <=#TP 0;
      else if(~mgmt_miim_sel & mgmt_req & ~mgmt_addr[9])begin
		  case (mgmt_addr[7:0])
		      8'h00: stat_rd_data <= frame_received_good;
		      8'h01: stat_rd_data <= fcs_error;
		      8'h02: stat_rd_data <= broadcast_received_good;
		      8'h03: stat_rd_data <= multicast_received_good;
		      8'h04: stat_rd_data <= frame_64_good;
		      8'h05: stat_rd_data <= frame_65_127_good;
		      8'h06: stat_rd_data <= frame_128_255_good;
		      8'h07: stat_rd_data <= frame_256_511_good;
		      8'h08: stat_rd_data <= frame_512_1023_good;
		      8'h09: stat_rd_data <= frame_1024_max_good;
		      8'h0a: stat_rd_data <= control_frame_good;
		      8'h0b: stat_rd_data <= lt_out_range;
		      8'h0c: stat_rd_data <= tagged_frame_good;
		      8'h0d: stat_rd_data <= pause_frame_good;
		      8'h0e: stat_rd_data <= unsupported_control_frame;
		      8'h0f: stat_rd_data <= oversize_frame_good;
		      8'h10: stat_rd_data <= undersize_frame;
		      8'h11: stat_rd_data <= fragment_frame;
		      8'h12: stat_rd_data <= total_bytes_recved;
		      8'h13: stat_rd_data <= total_bytes_transed;
		      8'h20: stat_rd_data <= good_frame_transed;
		      8'h21: stat_rd_data <= broadcast_frame_transed;
		      8'h22: stat_rd_data <= multicast_frame_transed;
		      8'h23: stat_rd_data <= underrun_error;
		      8'h24: stat_rd_data <= control_frame_transed;
		      8'h25: stat_rd_data <= frame_64_transed;
		      8'h26: stat_rd_data <= frame_65_127_transed;
		      8'h27: stat_rd_data <= frame_128_255_transed;
		      8'h28: stat_rd_data <= frame_256_511_transed;
		      8'h29: stat_rd_data <= frame_512_1023_transed;
		      8'h2a: stat_rd_data <= frame_1024_max_transed;
		      8'h2b: stat_rd_data <= tagged_frame_transed;
		      8'h2c: stat_rd_data <= pause_frame_transed;
		      8'h2d: stat_rd_data <= oversize_frame_transed;
            default: stat_rd_data <= 0;
       endcase
    end
end	 
 
////////////////////////////////////////////////////////
// READ Statmachine
//
// Select which data to be writen to mgmt_rd_data
////////////////////////////////////////////////////////
reg[31:0] mgmt_rd_data;
reg mgmt_miim_rdy;
reg data_sel;
always@(posedge mgmt_clk or posedge reset) begin
      if(reset) begin
         mgmt_rd_data <=#TP 0;
			data_sel <=#TP 0; //0 select the lower 32bits of stat regs to mgmt_rd_data, while 1 select the higher 32bits
			read_done <=#TP 0; // when asserted, it indicates read operation has been finished
			mgmt_miim_rdy <=#TP 0;
		end	
		else begin
         case (state)
			    IDLE: begin
				     mgmt_rd_data <=#TP mgmt_rd_data;
				     data_sel <=#TP 1'b0;
			        read_done <=#TP 0;
			        mgmt_miim_rdy <=#TP 1;
					  if(mgmt_req & mgmt_miim_sel)
					    mgmt_miim_rdy <=#TP 0;
				 end
             STAT_OPERATE: begin // read statistics registers
				     mgmt_miim_rdy <=#TP 1;
			        read_done <=#TP 1'b0;
                 if (~data_sel) begin						
			          mgmt_rd_data <=#TP stat_rd_data[31:0];
					    data_sel <=#TP 1'b1;
					  end
					  else if(data_sel)begin
					    mgmt_rd_data <=#TP stat_rd_data[63:32];
						 data_sel <=#TP 1'b0;
			          read_done <=#TP 1'b1;
					  end 
				 end
				 CONFIG_OPERATE: begin // read configuration registers
				     case (mgmt_addr_d1[8:4])
					        5'h00: mgmt_rd_data <=#TP recv_config0;
                       5'h04: mgmt_rd_data <=#TP recv_config1;
                       5'h08: mgmt_rd_data <=#TP trans_config;
                       5'h0c: mgmt_rd_data <=#TP flow_control_config;
                       5'h10: mgmt_rd_data <=#TP rs_config;	
                       5'h14: mgmt_rd_data <=#TP mgmt_config;
							  default: mgmt_rd_data <=#TP mgmt_rd_data;
					  endcase
				 end	  
             MDIO_OPERATE: begin // read/write MDIO registers
				     if(~mdio_in_valid & mdio_in_valid_d1) begin
                    mgmt_rd_data[15:0] <=#TP mdio_data_in;
						  mgmt_rd_data[31:16] <=#TP 0;
						  mgmt_miim_rdy <=#TP 1'b1;
					  end
                 else begin
                    mgmt_rd_data <=#TP mgmt_rd_data;
						  mgmt_miim_rdy <=#TP 1'b0;
                 end						  
             end	
             default: begin
                 mgmt_rd_data <=#TP 0;
			        data_sel <=#TP 0;
			        read_done <=#TP 0;
		           mgmt_miim_rdy <=#TP 1;
             end	
          endcase
      end	
end		 

/////////////////////////////////////////////
// Write Configuration Registers
/////////////////////////////////////////////
reg[31:0] mgmt_wr_data_d1;
always@(posedge mgmt_clk or posedge reset) begin
      if(reset)
		   mgmt_wr_data_d1 <=#TP 0;
		else
		   mgmt_wr_data_d1 <=#TP mgmt_wr_data;
end

always@(posedge mgmt_clk or posedge reset)begin
      if(reset)begin
		  recv_config0 <=#TP 0;
        recv_config1 <=#TP 32'h10000000;
        trans_config <=#TP 32'h10000000;
        flow_control_config <=#TP 32'h60000000;
        rs_config <=#TP 0;
        mgmt_config <=#TP 32'h00100000;
		end
      else if(~mgmt_miim_sel & mgmt_addr[9]& ~mgmt_opcode[1]) begin // write configuration registers
        case (mgmt_addr[8:0]) 
          9'h000: recv_config0 <=#TP mgmt_wr_data;
          9'h040: recv_config1 <=#TP mgmt_wr_data;
          9'h080: trans_config <=#TP mgmt_wr_data;
          9'h0c0: flow_control_config <=#TP mgmt_wr_data;
          9'h100: rs_config <=#TP mgmt_wr_data;	
          9'h140: mgmt_config <=#TP mgmt_wr_data;
			 default: begin
			   recv_config0 <=#TP recv_config0;
            recv_config1 <=#TP recv_config1;
            trans_config <=#TP trans_config;
            flow_control_config <=#TP flow_control_config;
            rs_config <=#TP rs_config;
            mgmt_config <=#TP mgmt_config;
			 end	
        endcase
      end
end
		
///////////////////////////////////////////////////////
// Read Configuration Registers, 
// generates receive and transmit configuration vector
///////////////////////////////////////////////////////

assign cfgRxRegData = {recv_config1[31:27], recv_config1[15:0], recv_config0};
assign cfgTxRegData = {rs_config[27], trans_config[31:24],flow_control_config[30]}; 

///////////////////////////////////////////////
// Interface with MDIO module
// Generate control and data signals for MDIO
///////////////////////////////////////////////
reg[25:0] mdio_data_out; //output data, includes PHY address and data to be writen
always@(posedge mgmt_clk or posedge reset) begin
      if(reset)
		   mdio_data_out <=#TP 0;
		else if(mgmt_req & mgmt_miim_sel)
		   mdio_data_out <=#TP {mgmt_addr[9:0], mgmt_wr_data[15:0]};
		else
		   mdio_data_out <=#TP mdio_data_out;
end

reg[1:0] mdio_opcode; //MDIO operation code, 2'b10 is read, while 2'b01 is write
always@(posedge mgmt_clk or posedge reset) begin
      if(reset)
		  mdio_opcode <=#TP 0;
		else if(mgmt_req & mgmt_miim_sel)
		  mdio_opcode <=#TP mgmt_opcode;
end

reg[4:0] tmp_cnt; //used to longer the mdio_out_valid signal
always@(posedge mgmt_clk or posedge reset) begin
      if(reset)
		   tmp_cnt <=#TP 0;
		else if(mgmt_req & mgmt_miim_sel)
		   tmp_cnt <=#TP 0;
		else if(tmp_cnt == 30)
		   tmp_cnt <=#TP tmp_cnt;
		else	
		   tmp_cnt <=#TP tmp_cnt + 1;
end			

reg mdio_out_valid; //indicates a MDIO request is valid, lasts for 31 cycles(mgmt_clk)
always@(posedge mgmt_clk or posedge reset) begin
      if(reset)
			mdio_out_valid <=#TP 0;
		else if(mgmt_req & mgmt_miim_sel) 
		   mdio_out_valid <=#TP 1'b1;
		else if(tmp_cnt ==30)
		   mdio_out_valid <=#TP 1'b0;
		else
         mdio_out_valid <= #TP mdio_out_valid;		
end		

endmodule
