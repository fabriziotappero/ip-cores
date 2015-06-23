//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores MAC Interface Module                        ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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
//`timescale 1ns/100ps

/***************************************************************
  Description:

  md_intf.v: This verilog file is for the mdio interface of the mac
		This block enables the station to communicate with the
		PHYs. This interface is kicked of by a go command from
		the application. This intiates the read and write operation
		to the PHY. Upon completion of the operation it returns
		a indication called command done with the status of such
		operation.

***************************************************************/
/************** MODULE DECLARATION ****************************/

module g_md_intf(
                  scan_mode,
		  reset_n,        
		  mdio_clk,
		  mdio_in,
		  mdio_outen_reg,
		  mdio_out_reg,
		  mdio_regad,
		  mdio_phyad,
		  mdio_op,
		  go_mdio,
		  mdio_datain,
		  mdio_dataout,
		  mdio_cmd_done,
		  mdio_stat,
		  mdc
		  );


parameter FIVE       = 5'h5;
parameter SIXTEEN    = 5'd16;
parameter THIRTY_TWO = 5'd31;
parameter WRITE      = 1;

/******* INPUT & OUTPUT DECLARATIONS *************************/

  input scan_mode ; // scan_mode = 1
  input reset_n;       // reset from mac application interface
  input mdio_in;             // Input signal used to read data from PHY
  input mdio_clk;            // Input signal used to read data from PHY
  input[4:0] mdio_regad;     // register address for the current PHY operation
  input[4:0] mdio_phyad;     // Phy address to which the current operation is intended
  input mdio_op;             // 1 = READ  0 = WRITE
  input go_mdio;             // This is go command from the application for a MDIO
			     // transfer
  input[15:0] mdio_datain;   // 16 bit Write value from application to MDIO block
  output[15:0] mdio_dataout; // 16 bit Read value for a MDIO transfer
  output mdio_cmd_done;      // This is from MDIO to indicate mdio command completion
  output mdio_stat;          // Status of completion. 0 = No error 1= Error
  output mdio_out_reg;           // Output signal used to write data to PHY
  output mdio_outen_reg;        // Enable signal 1= Output mode on 0 = Input mode
  output mdc;                // This is the MDIO clock

/******* WIRE & REG DECLARATION FOR INPUT AND OUTPUTS ********/
 wire mdc;
 wire [15:0] mdio_dataout;
 wire go_mdio_sync;
 reg mdio_stat;
 reg mdio_cmd_done;
 reg mdio_out_en;
 reg mdio_out;

 half_dup_dble_reg U_dble_reg1 (
			 //outputs
			 .sync_out_pulse(go_mdio_sync),
			 //inputs
			 .in_pulse(go_mdio),
			 .dest_clk(mdio_clk),
			 .reset_n(reset_n)
			 );


 

/*** REG & WIRE DECLARATIONS FOR LOCAL SIGNALS ***************/
 reg[3:0] mdio_cur_st;
 reg[3:0] mdio_nxt_st;
 parameter mdio_idle_st= 4'd0,
		mdio_idle1_st = 4'd1,
		mdio_sfd1_st= 4'd2,
		mdio_sfd2_st= 4'd3,
		mdio_op1_st=  4'd4,
		mdio_op2_st=  4'd5,
		mdio_phyaddr_st= 4'd6,
		mdio_regaddr_st= 4'd7,
		mdio_turnar_st=  4'd8,
		mdio_wrturn_st=  4'd9,
		mdio_rdturn_st=  4'd10,
		mdio_read_st=    4'd11,
		mdio_write_st=   4'd12,
		mdio_complete_st= 4'd13,
		mdio_preamble_st= 4'd14;
	
 reg operation;
 reg phyaddr_mux_sel;
 reg regaddr_mux_sel;
 reg write_data_mux_sel;
 reg read_data_mux_sel;
 wire[4:0] inc_temp_count;
 reg[4:0] temp_count;
 reg reset_temp_count;
 reg inc_count;
 reg[4:0] phy_addr;
 reg[4:0] reg_addr;
 reg[15:0] transmit_data;
 reg[15:0] receive_data;
 reg       set_mdio_stat,clr_mdio_stat;

/***************** WIRE ASSIGNMENTS *************************/
 assign mdc = mdio_clk;
 assign mdio_dataout = receive_data;

/******** SEQUENTIAL LOGIC **********************************/

 always @(mdio_cur_st or go_mdio_sync or inc_temp_count or 
	  transmit_data or operation or phy_addr or reg_addr or temp_count or mdio_in)
   begin
     mdio_nxt_st = mdio_cur_st;
     inc_count = 1'b0;
     //mdio_cmd_done = 1'b0;
     mdio_out = 1'b0;
     mdio_out_en = 1'b0;
     set_mdio_stat = 1'b0;
     clr_mdio_stat = 1'b0;
     phyaddr_mux_sel = 1'b0;
     read_data_mux_sel = 1'b0;
     regaddr_mux_sel = 1'b0;
     reset_temp_count = 1'b0;
     write_data_mux_sel = 1'b0;
     
      casex(mdio_cur_st )       // synopsys parallel_case full_case
	
	mdio_idle_st:
	  // This state waits for signal go_mdio
	  // upon this command from config block
	  // mdio state machine starts to send
	  // SOF delimter
	  begin
	    if(~go_mdio_sync)
	      mdio_nxt_st = mdio_idle1_st; //mdio_sfd1_st;
	    else
	      mdio_nxt_st = mdio_idle_st;
	  end
	
      mdio_idle1_st:
	 begin
	   if (go_mdio_sync)
	     mdio_nxt_st = mdio_preamble_st;
	   else
	     mdio_nxt_st = mdio_idle1_st;
	 end    
      
      mdio_preamble_st:  
	begin
	  clr_mdio_stat = 1'b1;
	  mdio_out_en = 1'b1;
	  mdio_out = 1'b1;
	  if (temp_count == THIRTY_TWO)
	    begin
	      mdio_nxt_st = mdio_sfd1_st;
	      reset_temp_count = 1'b1;
	    end
	  else
	    begin
	      inc_count = 1'b1;     
	      mdio_nxt_st = mdio_preamble_st;
	    end
	end

	mdio_sfd1_st:
	  // This state shifts the first bit
	  // of Start of Frame De-limiter
	  begin
	    mdio_out_en = 1'b1;
	    mdio_out = 1'b0;
	    mdio_nxt_st = mdio_sfd2_st;
	  end

	mdio_sfd2_st:
	  // This state shifts the second bit
	  // of Start of Frame De-limiter
	  begin
	    mdio_out_en = 1'b1;
	    mdio_out = 1'b1;
	    mdio_nxt_st = mdio_op1_st;
	  end
    
	mdio_op1_st:
	  // This state shifts the first bit
	  // of type of operation read/write
	  begin
	    mdio_out_en = 1'b1;
	    if(operation)
	     mdio_out = 1'b0;
	    else
	     mdio_out = 1'b1;
	    //mdio_out = 1'b0; naveen 120199
	    mdio_nxt_st = mdio_op2_st;
	  end

	mdio_op2_st:
	  // This state shifts the second bit
	  // of type of operation read/write and
	  // determines the appropriate next state
	  // needed for such operation
	  begin
	    mdio_out_en = 1'b1;
	    mdio_nxt_st = mdio_phyaddr_st;
	    if(operation)
	     mdio_out = 1'b1;
	    else
	     mdio_out = 1'b0;
	  end

	mdio_phyaddr_st:
	  // This state shifts the phy-address on the mdio
	  begin
	    mdio_out_en = 1'b1;
	    phyaddr_mux_sel = 1'b1;
	    if(inc_temp_count == FIVE)
	     begin
	      reset_temp_count = 1'b1;
	      mdio_out = phy_addr[4];
	      mdio_nxt_st = mdio_regaddr_st;
	     end
	    else
	     begin
	      inc_count = 1'b1;
	      mdio_out = phy_addr[4];
	      mdio_nxt_st = mdio_phyaddr_st;
	     end
	  end

	mdio_regaddr_st:
	  // This state shifts the register in the phy to which
	  // this operation is intended
	  begin
	    mdio_out_en = 1'b1;
	    regaddr_mux_sel = 1'b1;
	    if(inc_temp_count == FIVE)
	     begin
	      reset_temp_count = 1'b1;
	      mdio_out = reg_addr[4];
	      mdio_nxt_st = mdio_turnar_st;
	     end
	    else
	     begin
	      inc_count = 1'b1;
	      mdio_out = reg_addr[4];
	      mdio_nxt_st = mdio_regaddr_st;
	     end
	  end

	mdio_turnar_st:
	  // This state determines whether the output enable
	  // needs to on or of based on the type of command
	  begin
	    //mdio_out_en = 1'b1;naveen 011299
	    mdio_out = 1'b1;
	    if(operation)
	    begin
	     mdio_out_en = 1'b1;
	     mdio_nxt_st = mdio_wrturn_st;
	    end 
	    else
	     begin
	     mdio_out_en = 1'b0;
	     mdio_nxt_st = mdio_rdturn_st;
	     end
	  end

	mdio_wrturn_st:
	  // This state is used for write turn around
	  begin
	    mdio_out_en = 1'b1;
	    mdio_out = 1'b0;
	    mdio_nxt_st = mdio_write_st;
	  end

	mdio_rdturn_st:
	  // This state is used to read turn around state
	  // the output enable is switched off
	  begin
	    if (mdio_in)
		set_mdio_stat = 1'b1;
	    mdio_out_en = 1'b0;
	    mdio_nxt_st = mdio_read_st;
	  end

	mdio_write_st:
	  // This state transfers the 16 bits of data to the
	  // PHY
	  begin
	    mdio_out_en = 1'b1;
	    write_data_mux_sel = 1'b1;
	    if(inc_temp_count == SIXTEEN)
	     begin
	      reset_temp_count = 1'b1;
	      mdio_out = transmit_data[15];
	      mdio_nxt_st = mdio_complete_st;
	     end
	    else
	     begin
	      inc_count = 1'b1;
	      mdio_out = transmit_data[15];
	      mdio_nxt_st = mdio_write_st;
	     end
	  end

	mdio_read_st:
	  // This state receives the 16 bits of data from the 
	  // PHY
	  begin
	    mdio_out_en = 1'b0;
	    read_data_mux_sel = 1'b1;
	    if(inc_temp_count == SIXTEEN)
	     begin
	      reset_temp_count = 1'b1;
	      mdio_nxt_st = mdio_complete_st;
	     end
	    else
	     begin
	      inc_count = 1'b1;
	      mdio_nxt_st = mdio_read_st;
	     end
	  end

	mdio_complete_st:
	  // This completes the mdio transfers indicates to the
	  // application of such complete
	  begin
	    mdio_nxt_st = mdio_idle_st;
	    mdio_out_en = 1'b0;
	    read_data_mux_sel = 1'b0;
	    //mdio_cmd_done = 1'b1;
//	    mdio_stat = 1'b0;
	  end
      endcase
   end
always @(mdio_cur_st)
 mdio_cmd_done  = (mdio_cur_st == 4'd13);


always @(posedge mdio_clk or negedge reset_n)
begin
    if (!reset_n)
      mdio_stat <= 1'b0;
    else if (set_mdio_stat)
      mdio_stat <= 1'b1;
    else if (clr_mdio_stat)
      mdio_stat <= 1'b0;
end


// This latches the PHY address, Register address and the
// Transmit data and the type of operation
//
 always @(posedge mdio_clk or negedge reset_n)
  begin
   if(!reset_n)
     begin
       phy_addr <= 5'd0;
       reg_addr <= 5'd0;
       transmit_data <= 16'd0;
       operation <= 1'b0;
       receive_data <= 16'd0;
     end
   else
     begin
       if(go_mdio_sync)
	 begin
	   phy_addr <= mdio_phyad;
	   reg_addr <= mdio_regad;
	   if(mdio_op == WRITE)
	     begin
	       operation <= 1'b1;
	       transmit_data <= mdio_datain;
	     end
	 end
       else
	 begin
	   operation <= 1'b0;
	   phy_addr <= phy_addr;
	   transmit_data <= transmit_data;
	   reg_addr <= reg_addr;
	 //  receive_data <= receive_data; naveen 011299
	 end // else: !if(go_mdio)
	 
	   if(phyaddr_mux_sel)
	     begin
	     /*
	       phy_addr[0] <= phy_addr[1];
	       phy_addr[1] <= phy_addr[2];
	       phy_addr[2] <= phy_addr[3];
	       phy_addr[3] <= phy_addr[4];
	     */
	       phy_addr[4] <= phy_addr[3];
	       phy_addr[3] <= phy_addr[2];
	       phy_addr[2] <= phy_addr[1];
	       phy_addr[1] <= phy_addr[0]; 
	     end
	   if(regaddr_mux_sel)
	     begin
	       reg_addr[4] <= reg_addr[3];
	       reg_addr[3] <= reg_addr[2];
	       reg_addr[2] <= reg_addr[1];
	       reg_addr[1] <= reg_addr[0];
	     end
	   if(write_data_mux_sel)
	     begin
	       transmit_data[15] <= transmit_data[14];
	       transmit_data[14] <= transmit_data[13];
	       transmit_data[13] <= transmit_data[12];
	       transmit_data[12] <= transmit_data[11];
	       transmit_data[11] <= transmit_data[10];
	       transmit_data[10] <= transmit_data[9];
	       transmit_data[9] <= transmit_data[8];
	       transmit_data[8] <= transmit_data[7];
	       transmit_data[7] <= transmit_data[6];
	       transmit_data[6] <= transmit_data[5];
	       transmit_data[5] <= transmit_data[4];
	       transmit_data[4] <= transmit_data[3];
	       transmit_data[3] <= transmit_data[2];
	       transmit_data[2] <= transmit_data[1];
	       transmit_data[1] <= transmit_data[0];
	     end
	   if(read_data_mux_sel)
	     begin
	       receive_data[0] <= mdio_in;
	       receive_data[1] <= receive_data[0];
	       receive_data[2] <= receive_data[1];
	       receive_data[3] <= receive_data[2];
	       receive_data[4] <= receive_data[3];
	       receive_data[5] <= receive_data[4];
	       receive_data[6] <= receive_data[5];
	       receive_data[7] <= receive_data[6];
	       receive_data[8] <= receive_data[7];
	       receive_data[9] <= receive_data[8];
	       receive_data[10] <= receive_data[9];
	       receive_data[11] <= receive_data[10];
	       receive_data[12] <= receive_data[11];
	       receive_data[13] <= receive_data[12];
	       receive_data[14] <= receive_data[13];
	       receive_data[15] <= receive_data[14];
	     end
	// end // else: !if(go_mdio) naveen 011298
     end // else: !if(!reset_n)
  end // always @ (posedge mdio_clk or negedge reset_n)

 // Temporary counter used to shift the data on the mdio line
 // This is also used to receive data on the line
 assign inc_temp_count = temp_count + 5'h1; 

 always @(posedge mdio_clk or negedge reset_n)
   begin
     if(!reset_n)
	mdio_cur_st <= mdio_idle_st;
     else
	mdio_cur_st <= mdio_nxt_st;
   end // always @ (posedge mdio_clk or negedge reset_n)

   reg 	mdio_outen_reg, mdio_out_reg;
  
  //----------------------------------------------
  // Scan fix done for negedge FF-Dinesh-A for A200
  // Note: Druring Scan Mode inverted mdio_clk used for 
  // mdio_outen_reg & mdio_out_reg
  //----------------------------------------------- 
  wire mdio_clk_scan = (scan_mode) ? !mdio_clk : mdio_clk;

   always @(negedge mdio_clk_scan or negedge reset_n)
   begin
     if(!reset_n)
     begin	    
	mdio_outen_reg <= 1'b0;
	mdio_out_reg <= 1'b0;
     end
     else
     begin
	mdio_outen_reg <= mdio_out_en;
	mdio_out_reg <= mdio_out;
     end
	
   end // always @ (posedge mdio_clk or negedge reset_n)

 always @(posedge mdio_clk or negedge reset_n)
   begin
     if(!reset_n)
	temp_count <= 5'b0;
     else
       begin
	 if(reset_temp_count)
	   temp_count <= 5'b0;
	 else if(inc_count)
	   temp_count <= inc_temp_count;
       end // else: !if(reset_n)
   end // always @ (posedge mdio_clk or negedge reset_n)
 


endmodule


