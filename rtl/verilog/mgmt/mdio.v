`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////
//// 																					////
//// MODULE NAME: MDIO Interface 											////
//// 																					////
//// DESCRIPTION: Generate MDIO Signals                           ////
////																					////
//// This file is part of the 10 Gigabit Ethernet IP core project ////
////  http://www.opencores.org/projects/ethmac10g/						////
////																					////
//// AUTHOR(S):																	////
//// Zheng Cao			                                             ////
////							                                    		////
//////////////////////////////////////////////////////////////////////
////																					////
//// Copyright (c) 2005 AUTHORS.  All rights reserved.			   ////
////																					////
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
//// from http://www.opencores.org/lgpl.shtml   						////
////																					////
//////////////////////////////////////////////////////////////////////
//
// CVS REVISION HISTORY:
//
// $Log: not supported by cvs2svn $
// Revision 1.2  2006/06/15 05:09:24  fisher5090
// bad coding style, but works, will be modified later
//
// Revision 1.1  2005/12/25 16:43:10  Zheng Cao
// 
// 
//
//////////////////////////////////////////////////////////////////////

`define PRE 31'h7fffffff
`define ST 2'b01
`define TA 2'b10

module mdio(mgmt_clk, reset, mdc, mdio_t, mdio_i, mdio_o, mdio_opcode, mdio_in_valid, mdio_data_in, mdio_out_valid, mdio_data_out, mgmt_config);

input mgmt_clk; //Management Clock
input reset; //System reset
output mdc; //MDIO clock
output mdio_t; 
output mdio_o;
input mdio_i;
input[1:0] mdio_opcode; //MDIO Opcode, equals mgmt_opcode
output mdio_in_valid; //Indicate mdio_data_in read from MDIO is valid
output[15:0] mdio_data_in; //Data read from MDIO
input mdio_out_valid; //Indicate mdio_data_out is valid
input[25:0] mdio_data_out; //Data to be writen to MDIO, {addr, data}
input[31:0] mgmt_config; //management configuration data, mainly used to set mdc frequency

parameter IDLE =0, MDIO_WRITE =1, MDIO_READ =2;
parameter TP =1;

///////////////////////////////////////////
// MDIO Clock Gen
///////////////////////////////////////////
reg[4:0] clk_cnt;
always@(posedge mgmt_clk or posedge reset)begin
      if(reset)
		  clk_cnt <=#TP 0;
		else if(clk_cnt == mgmt_config[4:0])
		  clk_cnt <=#TP 0;
		else
		  clk_cnt <=#TP clk_cnt + 1;
end

reg mdc;
always@(posedge mgmt_clk or posedge reset)begin
      if(reset)
		  mdc <=#TP 0;
		else if(clk_cnt == mgmt_config[4:0])
		  mdc <=#TP ~mdc;
		else
        mdc <=#TP mdc;		
end

////////////////////////////////////////////
// MDIO data initialization
////////////////////////////////////////////
reg transmitting;
reg[62:0] mdio_data;

always@(posedge mgmt_clk or posedge reset)begin
      if(reset)begin
		  mdio_data <=#TP 0;
		end
		else if(mdio_out_valid)begin
		  mdio_data <=#TP {`PRE, `ST, mdio_opcode, mdio_data_out[25:16], `TA, mdio_data_out[15:0]};
		end
end

reg[62:0] mdio_data_reg;
always@(posedge mdc or posedge reset)begin
      if(reset)
		  mdio_data_reg <=#TP 0;
		else if(transmitting)
		  mdio_data_reg <=#TP mdio_data_reg <<1;
		else
		  mdio_data_reg <=#TP mdio_data;
end

////////////////////////////////////////////
// counter used for transmitting data
////////////////////////////////////////////

reg[6:0] trans_cnt;
always@(posedge mdc or posedge reset)begin
      if(reset)begin
		  trans_cnt <=#TP 0;
		end 
		else if(transmitting)begin
		  trans_cnt <=#TP trans_cnt + 1;
		end  
		else begin
		  trans_cnt <=#TP 0;
		end  
end
		
////////////////////////////////////////////
// MDIO SIGNAL DRIVER
////////////////////////////////////////////
wire mdio_operate_done; //indicates MDIO write/read operation has been finished
assign mdio_operate_done = (trans_cnt == 63);

reg receiving;
reg[1:0] state, nextstate;
always@(state, mdio_out_valid, mdio_opcode[1], mdio_operate_done, reset)begin
      if(reset)
		  nextstate <=#TP IDLE;
		else 
		  case(state)
		     IDLE: begin
			     if(mdio_out_valid & ~mdio_opcode[1])
                 nextstate <=#TP MDIO_WRITE;
              else if(mdio_out_valid & mdio_opcode[1])
                 nextstate <=#TP MDIO_READ;
				  else
				     nextstate <=#TP nextstate;
		     end
			  MDIO_WRITE: begin
              if(mdio_operate_done)
		          nextstate <=#TP IDLE;
		        else
                nextstate <=#TP MDIO_WRITE;
			  end
           MDIO_READ: begin
              if(mdio_operate_done)
		          nextstate <=#TP IDLE;
		        else
                nextstate <=#TP MDIO_READ;
			  end			  
		 endcase
end		  

always@(posedge mdc or posedge reset)begin
      if(reset)
		  state <=#TP IDLE;
		else
        state <=#TP nextstate;
end		  

////////////////////////////////////////////////////
// MDIO control
//--receiving indicates receiving data from PHY
//--transmitting indicates transmitting data to PHY
////////////////////////////////////////////////////

reg mdio_o;
reg mdio_t;
always@(posedge mdc or posedge reset)begin
      if(reset) begin
        mdio_o <=#TP 0;
        mdio_t <=#TP 0;
		  transmitting <=#TP 0;
		  receiving <=#TP 0;
      end
      else begin
        case (state)
            IDLE:begin
               mdio_o <=#TP 1'b1;
               mdio_t <=#TP 0;	
		         receiving <=#TP 0;
               transmitting <=#TP 0;					
            end
				MDIO_WRITE:begin
				   transmitting <=#TP 1;
					mdio_o <=#TP mdio_data_reg[62];
					mdio_t <=#TP 1'b0;
		         receiving <=#TP 0;
					if (trans_cnt == 63)begin
                  transmitting <=#TP 0;
               end					  
			   end	
            MDIO_READ:begin
					mdio_o <=#TP mdio_data_reg[62];
					mdio_t <=#TP 1'b0;
  				   transmitting <=#TP 1'b1;
		         receiving <=#TP 0;
               if (trans_cnt == 45)begin //transmitting TA
					  mdio_t <=#TP 1'b1;
					end			
					else if (trans_cnt == 63)begin //all data received
  				     transmitting <=#TP 1'b0;
					  mdio_o <=#TP 1'b1;
					end
               else if(trans_cnt >= 46)begin //receiving Data
					  mdio_t <=#TP 1'b1;
                 receiving <=#TP 1'b1;			
					end
			   end	
        endcase
    end
end

/////////////////////////////////////////////////
// Shift Registers to get data from PHY
/////////////////////////////////////////////////
reg mdio_in_valid;
always@(posedge mdc or posedge reset)begin
      if(reset)
		   mdio_in_valid <=#TP 1'b0;
      else if(mdio_operate_done)
         mdio_in_valid <=#TP 1'b1;
		else if(receiving)
		   mdio_in_valid <=#TP 1'b0;   
      else
         mdio_in_valid <=#TP 1'b0;
end

reg[15:0] mdio_data_in;
always@(posedge mdc or posedge reset)begin
      if(reset)begin
		   mdio_data_in <=#TP 0;
		end	
		else if(receiving)begin
		   mdio_data_in[0] <=#TP mdio_i;
		   mdio_data_in[1] <=#TP mdio_data_in[0];
		   mdio_data_in[2] <=#TP mdio_data_in[1];
		   mdio_data_in[3] <=#TP mdio_data_in[2];
		   mdio_data_in[4] <=#TP mdio_data_in[3];
		   mdio_data_in[5] <=#TP mdio_data_in[4];
		   mdio_data_in[6] <=#TP mdio_data_in[5];
		   mdio_data_in[7] <=#TP mdio_data_in[6];
		   mdio_data_in[8] <=#TP mdio_data_in[7];
		   mdio_data_in[9] <=#TP mdio_data_in[8];
		   mdio_data_in[10] <=#TP mdio_data_in[9];
		   mdio_data_in[11] <=#TP mdio_data_in[10];
		   mdio_data_in[12] <=#TP mdio_data_in[11];
		   mdio_data_in[13] <=#TP mdio_data_in[12];
		   mdio_data_in[14] <=#TP mdio_data_in[13];
		   mdio_data_in[15] <=#TP mdio_data_in[14];
	   end
		else
		   mdio_data_in <=#TP mdio_data_in;
end
        		
endmodule
