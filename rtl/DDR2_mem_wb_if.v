`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UPT
// Engineer: Oana Boncalo & Alexandru Amaricai
// 
// Create Date:    09:51:04 03/18/2013 
// Design Name: 
// Module Name:    DDR2_mem_wb_if 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module DDR2_mem_wb_if #
  (
   parameter APPDATA_WIDTH           = 128     // # of usr read/write data bus bits.                                 
	)
	(
	 input clk,
	 input rst,  
	 //wishbone if signals
	 input 									cyc_wb,
	 input									stb_wb,
	 input	[30:0] 						address_wb,
	 input	[(APPDATA_WIDTH/8)-1:0]	sel_wb, //write mask	 
	 input	[APPDATA_WIDTH-1:0]		wr_data_wb, // write data
	 input									we_wb,
	 input 	[2:0]							cti_wb,
	 input   [1:0]							bte_wb,
	 //to wishbone from memory interface
	 output	reg							ack_mem, 
	 output 									err_mem, rty_mem,
	 output [APPDATA_WIDTH-1:0]	rd_data_wb, // rd data
	 
	 //signals to/from memory user interface
	 output  reg[30:0] 						  	bus_if_addr,
	 output  reg [APPDATA_WIDTH-1:0]       bus_if_wr_data0, bus_if_wr_data1,
	 output  reg [(APPDATA_WIDTH/8)-1:0]   bus_if_wr_mask_data0, bus_if_wr_mask_data1,
	 output 	reg								  	mem_rd_cmd, 
	 output	reg								  	mem_wr_cmd,
	 input									  		rd_valid,
	 input									  		end_op,
	 input  [APPDATA_WIDTH-1:0]        		bus_if_rd_data,
	 input	                              app_wdf_afull,
    input	                              app_af_afull,
	 input		                           phy_init_done,
	 input											rd_failed, //signals the abnormal termination of a RD op
	 output [3:0] 									wb_state,
	 output											is_burst_flag_o
    );

	//for wishbone if state machine
	localparam WB_IDLE	= 4'b0000;
	localparam WR_LATCH_D0	= 4'b0001;
	localparam WR_WAIT_D1	= 4'b0010;
	localparam WR_LATCH_D1	= 4'b0011;
	localparam WR_WAIT_END_OP	= 4'b0100;
	localparam RD_REQ		= 4'b0101;
	localparam RD_WAIT_RSP= 4'b0110;
	localparam RD_RSP		= 4'b0111;
	localparam RD_WR_ERROR	= 4'b1000;
	localparam WB_END_BURST		= 4'b1001;

	reg [3:0]                 				wb_state_reg;
	reg											is_burst_flag;
	//rd/wr commands to memory
	wire	  									   rd_cmd; 
	wire										   wr_cmd;
	wire [APPDATA_WIDTH-1:0]	rd_data_to_latch;
	reg  [APPDATA_WIDTH-1:0]	rd_data_wb_reg;
	reg 								is_burst;
	reg	[3:0]						counter;
	//reg								err_flag;


	
	assign rd_cmd = cyc_wb & stb_wb & (!we_wb);
	assign wr_cmd = cyc_wb & stb_wb &  we_wb;
	assign rty_mem = (!phy_init_done) && ((wr_cmd  && (app_af_afull || app_wdf_afull)) || (rd_cmd && app_af_afull))? 1'b1: 1'b0;
	
	assign wb_state = wb_state_reg;
	always @(posedge clk)
	begin
		if (rst)
		begin
			wb_state_reg <= WB_IDLE;
			mem_wr_cmd <= 1'b0;
			mem_rd_cmd <= 1'b0;
			//counter <= 0;
		end
		else 
			case (wb_state_reg)
				WB_IDLE: 
					begin
						mem_wr_cmd <= 1'b0;
						mem_rd_cmd <= 1'b0;
						if (wr_cmd && !rty_mem)
							wb_state_reg <= WR_LATCH_D0;
						if (rd_cmd && !rty_mem)
							wb_state_reg <= RD_REQ;
					end
				WR_LATCH_D0:
					begin
						//latch data0 & mask, address
						//generate ack
						wb_state_reg <= WR_WAIT_D1;	
						//counter <= 15;
					end
				WR_WAIT_D1:
					begin
						if (cti_wb == 3'b000) //single write
							begin
								//no need for second data proceed with WR
								mem_wr_cmd <= 1'b1;
								wb_state_reg <= WR_WAIT_END_OP;
							end
						else
							begin
								if (wr_cmd)
									wb_state_reg <= WR_LATCH_D1;
								else if (counter == 0)
									wb_state_reg <= RD_WR_ERROR;
							end
					end
				WR_LATCH_D1:
					begin
						//latch data1 & mask and generate ack
						mem_wr_cmd <= 1'b1; // start write to mem
						wb_state_reg <= WR_WAIT_END_OP;	
					end
				WR_WAIT_END_OP:
					begin
						//wait for memory to signal end of wr to fifos
						mem_wr_cmd <= 1'b0;
						if (end_op)
							wb_state_reg <= WB_IDLE;
					end
				RD_REQ: 
					begin
						//latch address from mem
						mem_rd_cmd <= 1'b1;
						wb_state_reg <= RD_WAIT_RSP;
					end
				RD_WAIT_RSP: 
					begin
						//check if rsp. available
						mem_rd_cmd <= 1'b0;
						if (rd_failed)
						begin
							wb_state_reg <= RD_WR_ERROR; //todo: revise if WB_IDLE is not more suitable
						end
						else
						begin
							if (rd_valid)
								wb_state_reg <= RD_RSP;
						end
					end
				RD_RSP:
					begin
						//based on (cti_wb == 3'b000) value - single read
						//deactivate ack /latch second data word for bus transfer
						wb_state_reg <= WB_IDLE;
					end
				RD_WR_ERROR:
					begin
						wb_state_reg <= WB_IDLE;
					end
				endcase
	end
	//latch address
	always @(posedge clk, posedge rst)
	begin
		if (rst == 1'b1)
			bus_if_addr <= 0;
		else
			if ((wb_state_reg == WR_LATCH_D0) || (wb_state_reg == RD_REQ))
				bus_if_addr <= address_wb;
	end
	//latch data0
	always @(posedge clk, posedge rst)
	begin
		if (rst == 1'b1)
		begin
			bus_if_wr_data0 <= 0;
			bus_if_wr_mask_data0 <= 0;
		end
		else
			if (wb_state_reg == WR_LATCH_D0)
			begin
				bus_if_wr_data0 <= wr_data_wb;
				bus_if_wr_mask_data0 <= sel_wb;
			end
	end
	//latch data1
	always @(posedge clk, posedge rst)
	begin
		if (rst == 1'b1)
		begin
			bus_if_wr_data1 <= 0;
			bus_if_wr_mask_data1 <= 0;
		end
		else
			case (wb_state_reg)
				WR_LATCH_D0:
				begin
					bus_if_wr_data1 <= 0;
					bus_if_wr_mask_data1 <= 0;
				end
				WR_LATCH_D1:
				begin
					bus_if_wr_data1 <= wr_data_wb;
					bus_if_wr_mask_data1 <= sel_wb;
				end
			endcase
	end
	//generate ack for write & rd
	//assign ack_mem = ((wb_state_reg == WR_WAIT_D1 && wr_cmd) || ((wb_state_reg == WR_WAIT_END_OP && wr_cmd) && (end_op == 1'b1)) || ((wb_state_reg == RD_WAIT_RSP) && rd_valid) || ((wb_state_reg == RD_RSP)  && is_burst) )? 1'b1: 1'b0;
	//latch rd data
	always @(posedge clk, posedge rst)
	begin
		if (rst == 1'b1)
		begin
			rd_data_wb_reg <= 0;
		end
		else
			rd_data_wb_reg <= rd_data_to_latch;
	end
	//assign rd_data_to_latch = rd_valid && ((wb_state_reg == RD_WAIT_RSP) || ((wb_state_reg == RD_RSP) && is_burst_flag))? bus_if_rd_data: rd_data_wb_reg;
	assign rd_data_to_latch = (rd_valid && ack_mem)? bus_if_rd_data: rd_data_wb_reg;
	assign rd_data_wb = rd_data_to_latch;
	//assign rd_data_to_latch = rd_valid? bus_if_rd_data: rd_data_wb_reg;
	
	//single/burst op signaling
	assign is_burst_flag_o = is_burst_flag;
	
	always @(posedge clk, posedge rst)
	begin
		if (rst == 1'b1)
		begin
			is_burst_flag <= 0;
		end
		else
				is_burst_flag <= is_burst;
	end
	always @*
	begin
		is_burst = is_burst_flag;
		if ((wb_state_reg == WR_LATCH_D0) || (wb_state_reg == RD_REQ))
				if (cti_wb != 3'b000)
					is_burst = 1'b1;
				else
					is_burst = 1'b0;
		if (wb_state_reg == WB_IDLE)
			is_burst = 1'b0;
	end
	always @*
	begin
		ack_mem = 1'b0;
		if ((cyc_wb && stb_wb) &&((wb_state_reg == WR_WAIT_D1 && wr_cmd) || ((wb_state_reg == WR_WAIT_END_OP && wr_cmd)&& (end_op == 1'b1))))
			ack_mem = 1'b1;
		if ((cyc_wb && stb_wb) &&( ((wb_state_reg == RD_WAIT_RSP) && rd_valid) || ((wb_state_reg == RD_RSP)  && is_burst) ))
			ack_mem = 1'b1;
	end
	//wishbone error signaling
	assign err_mem = (wb_state_reg == RD_WR_ERROR)? 1'b1: 1'b0;
	//assign is_burst = (cti_wb == 3'b010);
	//timeout counter for WR
	always @(posedge clk, posedge rst)
	begin
		if (rst == 1'b1)
		begin
			counter <= 0;
		end
		else
			if ((wb_state_reg == WR_LATCH_D0))
				counter <= 15;
			else
				if (wb_state_reg == WR_WAIT_D1)
					counter <= counter - 1'b1;
	end
endmodule
