////////////////////////////////////////////////////////////////////////////
//
// Create Date:    02/11/07
// Last Change:    01/22/12
// Design Name:    DDR SDRAM memory controller
// Module Name:    ddr_sdram
// Description:    memory controller for DDR SDRAM
//		   hard coded for 8 Meg x 16 x 4 banks
//
// Revision:
// Revision 0.01 - File Created
//
// Development platform: Spartan-3E Starter kit
//
// Copyright (C) 2007, Rick Huang
//
// Modifications by Hellwig Geisse, 2012
//   - sd_CK_P and sd_CK_N supplied by this module
//   - DDR output registers for sd_CK_P and sd_CK_N added
//   - sd_CLK_O deleted
//   - debug output deleted
//   - burst mode sections of the state machine deleted
//     (have been commented out already)
//   - additional states SD_RD_DONE_1 and SD_WR_DONE_1 inserted
//     (in order to stretch the wACK_O signal, which is to be
//     recognized by external circuits clocked with 50 MHz)
//   - four "write byte" signals added to interface
//     (to allow 8 and 16 bit write operations too)
//   - mask registers UDM_reg_O and LDM_reg_O deleted
//   - DDR output registers for sd_UDM_O and sd_LDM_O added
//   - data_sample_en and its associated multiplexer removed
//     (apparently a debugging vehicle)
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
// MA  02110-1301  USA
//
////////////////////////////////////////////////////////////////////////////

module ddr_sdram(sd_CK_P, sd_CK_N,
                 sd_A_O, sd_BA_O, sd_D_IO, 
                 sd_RAS_O, sd_CAS_O, sd_WE_O,
                 sd_UDM_O, sd_LDM_O, 
                 sd_UDQS_IO, sd_LDQS_IO,
                 sd_CS_O, sd_CKE_O,
                 clk0, clk90,
                 clk180, clk270,
                 reset,
                 wADR_I, wSTB_I, wWE_I, wWRB_I,
                 wDAT_I, wDAT_O, wACK_O);
	// interface to DDR SDRAM memory
	output  sd_CK_P;
	output  sd_CK_N;
	output 	[12:0] sd_A_O;
	output 	[1:0]  sd_BA_O;
	inout 	[15:0] sd_D_IO;
	output	sd_RAS_O;
	output  sd_CAS_O;
	output  sd_WE_O;
	output	sd_UDM_O;
	output	sd_LDM_O;
	inout	sd_UDQS_IO;
	inout	sd_LDQS_IO;
	output	sd_CS_O;
	output	sd_CKE_O;
	// internal interface signals
	input 	clk0;
	input	clk90;
	input   clk180;
	input	clk270;
	input	reset;
	// A[25:24] = bank[1:0]
	// A[23:11] = row[12:0]
	// A[10: 2] = col[9:1]
	// (a specific combination of the 2+13+9=24 bits adresses
	// a 32-bit word which is transmitted as a burst of two
	// consecutive 16-bit halfwords in one clock cycle)
	input	[25:2] wADR_I;
	input 	wSTB_I;
	input	wWE_I;
	input	[3:0] wWRB_I;
	input	[31:0] wDAT_I;
	output	[31:0] wDAT_O;
	output	wACK_O;

	// Local data storage
	reg		[5:0] sd_state;
	reg		[3:0] init_state;
	reg		[5:0] wait_count;
	reg		[14:0] init_wait_count;
	reg		[12:0] sd_A_O;
	reg		[1:0] sd_BA_O;
	reg		[12:0] mode_reg;
	reg		sd_RAS_O;
	reg		sd_CAS_O;
	reg		sd_WE_O;
	reg		sd_CS_O;
	reg		sd_CKE_O;
	reg		wACK_O;

	reg		[9:0] refresh_counter;
	reg		[3:0] refresh_queue;	// Number of refresh command to queue
	reg		refresh_now;
	reg		refresh_ack;
	
	reg		[31:0] D_rd_reg;
	reg		DQS_state;
	reg		DQS_oe;			// 1 for output
	reg		D_oe;			// 1 for output enable

	reg		[31:0] D_wr_reg;	// Data write buffer
	reg		[3:0] D_mask_reg;	// data mask buffer


/***************************************************		
 * SD ram clock source
 ***************************************************/

        ODDR2 #(
                .DDR_ALIGNMENT("NONE"),
                .INIT(1'b0),
                .SRTYPE("SYNC")
        ) ODDR2_inst_CK_P (
                .Q(sd_CK_P),
                .C0(clk180),
                .C1(clk0),
                .CE(1'b1),
                .D0(1'b1),
                .D1(1'b0),
                .R(1'b0),
                .S(1'b0)
        );

        ODDR2 #(
                .DDR_ALIGNMENT("NONE"),
                .INIT(1'b0),
                .SRTYPE("SYNC")
        ) ODDR2_inst_CK_N (
                .Q(sd_CK_N),
                .C0(clk0),
                .C1(clk180),
                .CE(1'b1),
                .D0(1'b1),
                .D1(1'b0),
                .R(1'b0),
                .S(1'b0)
        );

/***************************************************		
 * De-duplex of the data path
 * For some reason, for read, the output is CL=2.5, not CL=2
 * Thus, catching of the data is 1/2 a cycle late.
 * Flip the clk0 and clk180, 1/2 cycle delay catched
 * on data_mux_latch
 ***************************************************/

	// Data from SDRAM will be loaded at {data_mux_out[31:0]}
	wire	[31:0] data_mux_out;
	wire	[15:0] iddr_conn;
	wire	[15:0] oddr_conn;


	generate
	genvar i;

		for(i=0;i<16;i=i+1)
		begin : iou
			IDDR2 #(
				.DDR_ALIGNMENT("NONE"), // Sets output alignment to "NONE", "C0" or "C1"
				.INIT_Q0(1'b0), 		// Sets initial state of the Q0 output to 1'b0 or 1'b1
				.INIT_Q1(1'b0), 		// Sets initial state of the Q1 output to 1'b0 or 1'b1
				.SRTYPE("SYNC") 		// Specifies "SYNC" or "ASYNC" set/reset
			) IDDR2_inst (
				.Q0(data_mux_out[i]), 				// C0 clock
				.Q1(data_mux_out[i+16]), 			// C1 clock
				.C0(clk180),		
				.C1(clk0),
				.CE(1'b1),				// Always enabled
				.D(iddr_conn[i]), 		// 1-bit DDR data input
				.R(1'b0), 				// 1-bit reset input
				.S(1'b0) 				// 1-bit set input
			);

			ODDR2 #(
				.DDR_ALIGNMENT("NONE"), // Sets output alignment to "NONE", "C0" or "C1"
				.INIT(1'b0), 			// Sets initial state of the Q output to 1'b0 or 1'b1
				.SRTYPE("SYNC") 		// Specifies "SYNC" or "ASYNC" set/reset
			) ODDR2_inst (
				.Q(oddr_conn[i]),		// 1-bit DDR output data
				.C0(clk90),			// 1-bit clock input
				.C1(clk270), 		// 1-bit clock input
				.CE(1'b1), 				// 1-bit clock enable input
				.D0(D_wr_reg[i]),		// (associated with C0)
				.D1(D_wr_reg[i+16]),	// (associated with C1)
				.R(1'b0), 				// 1-bit reset input
				.S(1'b0)				// 1-bit set input
			);

			IOBUF #(
				.DRIVE(4), 				// Specify the output drive strength
				.IBUF_DELAY_VALUE("0"), // Specify the amount of added input delay
				.IFD_DELAY_VALUE("AUTO"), // Specify the amount of added delay for input register, "AUTO", "0"-"8"
				.IOSTANDARD("DEFAULT"), // Specify the I/O standard
				.SLEW("SLOW") 			// Specify the output slew rate
			) IOBUF_inst (
				.O(iddr_conn[i]), 		// Buffer output
				.IO(sd_D_IO[i]), 		// Buffer inout port (connect directly to top-level port)
				.I(oddr_conn[i]), 		// Buffer input
				.T(~D_oe) 				// 3-state enable input
			);
		end
	endgenerate


	wire sd_UDQS_O;
	wire sd_LDQS_O;

		ODDR2 #(
			.DDR_ALIGNMENT("NONE"),
			.INIT(1'b0), 		
			.SRTYPE("SYNC") 
		) ODDR2_inst_UDQS (
			.Q(sd_UDQS_O),
			.C0(clk180),	
			.C1(clk0),
			.CE(1'b1), 	
			.D0(DQS_state),	
			.D1(1'b0),
			.R(1'b0), 		
			.S(1'b0)	
		);

		ODDR2 #(
			.DDR_ALIGNMENT("NONE"),
			.INIT(1'b0), 		
			.SRTYPE("SYNC") 
		) ODDR2_inst_LDQS (
			.Q(sd_LDQS_O),
			.C0(clk180),	
			.C1(clk0),
			.CE(1'b1), 	
			.D0(DQS_state),	
			.D1(1'b0),
			.R(1'b0), 		
			.S(1'b0)	
		);

		IOBUF #(
			.DRIVE(4), 	
			.IBUF_DELAY_VALUE("0"), 
			.IFD_DELAY_VALUE("AUTO"),
			.IOSTANDARD("DEFAULT"), 
			.SLEW("SLOW") 		
		) IOBUF_inst_UDQS (
			// .O() intentionally not connected
			.IO(sd_UDQS_IO), 
			.I(sd_UDQS_O),
			.T(~DQS_oe) 		
		);

		IOBUF #(
			.DRIVE(4), 	
			.IBUF_DELAY_VALUE("0"), 
			.IFD_DELAY_VALUE("AUTO"),
			.IOSTANDARD("DEFAULT"), 
			.SLEW("SLOW") 		
		) IOBUF_inst_LDQS (
			// .O() intentionally not connected
			.IO(sd_LDQS_IO), 
			.I(sd_LDQS_O),
			.T(~DQS_oe) 		
		);


	reg [31:0] data_mux_latch;
	always @ (posedge clk180)
	begin
		data_mux_latch <= data_mux_out;
	end

/***************************************************		
 * Data bus flow direction control
 ***************************************************/

	assign wDAT_O = D_rd_reg[31:0];

	// Mask output

	wire		UDM_conn;
	wire		LDM_conn;

        ODDR2 #(
                .DDR_ALIGNMENT("NONE"),
                .INIT(1'b0),
                .SRTYPE("SYNC")
        ) ODDR2_inst_UDM (
                .Q(UDM_conn),
                .C0(clk90),
                .C1(clk270),
                .CE(1'b1),
                .D0(~D_mask_reg[1]),
                .D1(~D_mask_reg[3]),
                .R(1'b0),
                .S(1'b0)
        );

        ODDR2 #(
                .DDR_ALIGNMENT("NONE"),
                .INIT(1'b0),
                .SRTYPE("SYNC")
        ) ODDR2_inst_LDM (
                .Q(LDM_conn),
                .C0(clk90),
                .C1(clk270),
                .CE(1'b1),
                .D0(~D_mask_reg[0]),
                .D1(~D_mask_reg[2]),
                .R(1'b0),
                .S(1'b0)
        );

        IOBUF #(
                .DRIVE(4),
                .IBUF_DELAY_VALUE("0"),
                .IFD_DELAY_VALUE("AUTO"),
                .IOSTANDARD("DEFAULT"),
                .SLEW("SLOW")
        ) IOBUF_inst_UDM (
                // .O() intentionally not connected
                .IO(sd_UDM_O),
                .I(UDM_conn),
                .T(1'b0)
        );

        IOBUF #(
                .DRIVE(4),
                .IBUF_DELAY_VALUE("0"),
                .IFD_DELAY_VALUE("AUTO"),
                .IOSTANDARD("DEFAULT"),
                .SLEW("SLOW")
        ) IOBUF_inst_LDM (
                // .O() intentionally not connected
                .IO(sd_LDM_O),
                .I(LDM_conn),
                .T(1'b0)
        );


/***************************************************		
 * Main tx/rx state machine
 ***************************************************/

        /* Timing */
	parameter WAIT_TIME = 5'd5;	
	parameter INIT_WAIT = 15'h3000;
	parameter INIT_CLK_EN_WAIT = 15'h10;		
	parameter WAIT_CMD_MAX = 6'b100000;
	parameter REFRESH_WAIT = WAIT_CMD_MAX - 6'd7;
	parameter ACCESS_WAIT = WAIT_CMD_MAX - 6'd1;
	parameter CAS_WAIT = WAIT_CMD_MAX - 6'd3;
	parameter AVG_REFRESH_DUR = 10'd700;

        /* Main state machine */
	parameter 	SD_IDLE = 0,
				SD_INIT = 1,
				SD_INIT_WAIT = 2,
				SD_PRECHG_ALL = 3,
				SD_PRECHG_ALL1 = 4,
				SD_AUTO_REF = 5,
				SD_AUTO_REF1 = 6,
				SD_AUTO_REF_ACK = 7,
				SD_LD_MODE = 8,
				SD_LD_MODE1 = 9,
				SD_RD_START = 10,
				SD_RD_COL = 11,
				SD_RD_CAS_WAIT = 12,
				SD_RD_LATCH = 13,
				SD_RD_LATCH1 = 14,
				SD_RD_DONE = 15,
				SD_WR_START = 16,
				SD_WR_COL = 17,
				SD_WR_CAS_WAIT = 18,
				SD_WR_LATCH = 19,
				SD_WR_LATCH1 = 20,
				SD_WR_DONE = 21,
				SD_RD_DONE_1 = 22,
				SD_WR_DONE_1 = 23;

        /* Initialization state machine */
	parameter	SI_START = 0,
				SI_PRECHG = 1,
				SI_LOAD_EX_MODE = 2,
				SI_LOAD_MODE = 3,
				SI_LOAD_MODE2 = 4,
				SI_PRECHG2 = 5,
				SI_AUTO_REF = 6,
				SI_AUTO_REF2 = 7,
				SI_DONE = 8;


always @ (posedge clk0) 
begin
	if(reset) 
	begin
		sd_state <= SD_INIT;
		init_state <= SI_START;
	end else
	begin
		wait_count <= wait_count + 1;

		case (sd_state)
			SD_INIT:						// Initialize, wait until INIT_WAIT
			begin
				case (init_state)
					SI_START:
					begin
						sd_state <= SD_INIT_WAIT;
						init_state <= SI_PRECHG;
						sd_RAS_O <= 1;
						sd_CAS_O <= 1;
						sd_WE_O <= 1;
						sd_CS_O <= 1;
						sd_CKE_O <= 0;
						init_wait_count <= 16'd0;
					end
					SI_PRECHG:
					begin
						sd_state <= SD_PRECHG_ALL;
						init_state <= SI_LOAD_EX_MODE;
					end
					SI_LOAD_EX_MODE:
					begin
						// Normal operation
						mode_reg <= 13'b0000000000000;
						sd_BA_O <= 2'b01;
						sd_state <= SD_LD_MODE;	
						init_state <= SI_LOAD_MODE;
					end
					SI_LOAD_MODE:
					begin
						// CAS = 2, Reset DLL, Burst = 2, sequential
						mode_reg <= {6'b000010, 3'b010, 1'b0, 3'b001};
						sd_BA_O <= 2'b00;
						sd_state <= SD_LD_MODE;	
						init_state <= SI_LOAD_MODE2;
					end
					SI_LOAD_MODE2:
					begin
						// CAS = 2, NO Reset DLL, Burst = 2, sequential
						mode_reg <= {6'b000000, 3'b010, 1'b0, 3'b001};
						sd_BA_O <= 2'b00;
						sd_state <= SD_LD_MODE;	
						init_state <= SI_PRECHG2;
					end
					SI_PRECHG2:
					begin
						sd_state <= SD_PRECHG_ALL;
						init_state <= SI_AUTO_REF;
					end
					SI_AUTO_REF:
					begin
						sd_state <= SD_AUTO_REF;
						init_state <= SI_AUTO_REF2;
					end
					SI_AUTO_REF2:
					begin
						sd_state <= SD_AUTO_REF;
						init_state <= SI_DONE;
					end
					SI_DONE:
					begin
						init_state <= SI_DONE;
						sd_state <= SD_IDLE;
					end
					default:
						init_state <= SI_START;
				endcase
			end
			// ** Waiting for SDRAM waking up *****************************
			SD_INIT_WAIT:
			begin
				init_wait_count <= init_wait_count + 1;
				if(init_wait_count == INIT_WAIT)
				begin
					sd_state <= SD_INIT;
				end
				if(init_wait_count == INIT_CLK_EN_WAIT)
				begin
					sd_CKE_O <= 1;				// Wake up the SDRAM
				end
			end
			// ** Precharge command ***************************************
			SD_PRECHG_ALL:
			begin
				sd_state <= SD_PRECHG_ALL1;
				sd_RAS_O <= 0;
				sd_CAS_O <= 1;
				sd_WE_O <= 0;
				sd_CS_O <= 0;
				sd_A_O[10] <= 1;				// Command for precharge all
			end
			SD_PRECHG_ALL1:
			begin
				sd_CS_O <= 1;
				sd_RAS_O <= 1;
				sd_CAS_O <= 1;
				sd_WE_O <= 1;
				sd_state <= SD_IDLE;			// Precharge takes 15nS before next command
			end
			// ** Load mode register **************************************
			SD_LD_MODE:
			begin
				sd_state <= SD_LD_MODE1;
				sd_RAS_O <= 0;
				sd_CAS_O <= 0;
				sd_WE_O <= 0;
				sd_CS_O <= 0;
				sd_A_O[12:0] <= mode_reg;
			end
			SD_LD_MODE1:
			begin
				sd_CS_O <= 1;
				sd_RAS_O <= 1;
				sd_CAS_O <= 1;
				sd_WE_O <= 1;					// Load Mode takes 12nS
				sd_state <= SD_IDLE;			// Add wait if needed
			end
			// ** Auto refresh command ************************************
			SD_AUTO_REF:
			begin
				sd_state <= SD_AUTO_REF1;
				sd_RAS_O <= 0;
				sd_CAS_O <= 0;
				sd_WE_O <= 1;
				sd_CS_O <= 0;
				wait_count <= REFRESH_WAIT;
			end
			SD_AUTO_REF1:
			begin
				sd_CS_O <= 1;					// Issue NOP during wait
				sd_RAS_O <= 1;
				sd_CAS_O <= 1;
				sd_WE_O <= 1;
				if(wait_count[5] == 1)			// Time up, return to idle
				begin
					sd_state <= SD_AUTO_REF_ACK;	
					refresh_ack <= 1;
				end
			end
			SD_AUTO_REF_ACK:					// Interlocking state
			begin
				sd_state <= SD_IDLE;	
				refresh_ack <= 0;
			end
			// ** Read cycle **********************************************
			SD_RD_START:
			begin
				sd_state <= SD_RD_COL;
				sd_RAS_O <= 0;
				sd_CAS_O <= 1;
				sd_WE_O <= 1;
				sd_CS_O <= 0;
				sd_BA_O[1:0] <= wADR_I[25:24];
				sd_A_O[12:0] <= wADR_I[23:11];
				wait_count <= ACCESS_WAIT;
				D_oe <= 0;						// Not driving the bus
				DQS_state <= 0;
			end
			SD_RD_COL:
			begin
				if(wait_count[5] != 1)
				begin
					sd_CS_O <= 1;			// NOP command during access wait		
					sd_RAS_O <= 1;
					sd_CAS_O <= 1;
					sd_WE_O <= 1;
				end else
				begin
					sd_CS_O <= 0;				// Access column 
					sd_RAS_O <= 1;
					sd_CAS_O <= 0;
					sd_WE_O <= 1;
					sd_state <= SD_RD_CAS_WAIT;	
					sd_A_O[9:1] <= wADR_I[10:2];
					sd_A_O[10] <= 1;			// Use auto-precharge
					sd_A_O[0] <= 0;
					wait_count <= CAS_WAIT;
					DQS_oe <= 0;			// Set DQS for input
				end
			end
			SD_RD_CAS_WAIT:
			begin								// Wait until DQS signal there is data
				if(wait_count[5] != 1)
				begin
					sd_CS_O <= 1;				// NOP command during access wait		
					sd_RAS_O <= 1;
					sd_CAS_O <= 1;
					sd_WE_O <= 1;
				end else
				begin
					sd_state <= SD_RD_LATCH;
				end
			end
			SD_RD_LATCH:
			begin
				D_rd_reg <= data_mux_latch[31:0];
				wACK_O <= 1;
				sd_state <= SD_RD_DONE;
			end
			SD_RD_DONE:
			begin
				wACK_O <= 1;
				sd_state <= SD_RD_DONE_1;
				DQS_state <= 0;
				DQS_oe <= 1;	// Set DQS back to output
			end
			SD_RD_DONE_1:
			begin
				wACK_O <= 0;
				sd_state <= SD_IDLE;
			end
			// ** Write cycle *********************************************
			SD_WR_START:
			begin							// Open the bank - ACTIVE command
				sd_state <= SD_WR_COL;
				sd_RAS_O <= 0;
				sd_CAS_O <= 1;
				sd_WE_O <= 1;
				sd_CS_O <= 0;
				sd_BA_O[1:0] <= wADR_I[25:24];
				sd_A_O[12:0] <= wADR_I[23:11];
				D_wr_reg <= wDAT_I;
				D_mask_reg <= wWRB_I;
				wait_count <= ACCESS_WAIT;
				DQS_state <= 0;
			end
			SD_WR_COL:
			begin
				if(wait_count[5] != 1)
				begin
					sd_CS_O <= 1;			// NOP command during access wait		
					sd_RAS_O <= 1;
					sd_CAS_O <= 1;
					sd_WE_O <= 1;
				end else
				begin
					sd_CS_O <= 0;			// Access column 
					sd_RAS_O <= 1;
					sd_CAS_O <= 0;
					sd_WE_O <= 0;
					DQS_oe <= 1;
					sd_state <= SD_WR_CAS_WAIT;	
					sd_A_O[9:1] <= wADR_I[10:2];
					sd_A_O[10] <= 1;		// Use auto-precharge
					sd_A_O[0] <= 0;
				end
			end
			SD_WR_CAS_WAIT:
			begin							// Wait until DQS signal there is data
				sd_state <= SD_WR_LATCH;
				DQS_state <= 1;			// Start with DQS low
				D_oe <= 1;				// Drive the data bus
				sd_CS_O <= 1;
				sd_RAS_O <= 1;
				sd_CAS_O <= 1;
				sd_WE_O <= 1;
			end
			SD_WR_LATCH:
			begin
				sd_state <= SD_WR_LATCH1;
				DQS_state <= 0;
			end
			SD_WR_LATCH1:
			begin
				sd_state <= SD_WR_DONE;
				DQS_state <= 0;
				wACK_O <= 1;
			end
			SD_WR_DONE:
			begin
				D_oe <= 0;
				wACK_O <= 1;
				sd_state <= SD_WR_DONE_1;
			end
			SD_WR_DONE_1:
			begin
				wACK_O <= 0;
				sd_state <= SD_IDLE;
			end
		    // Wishbone transfer is done during idle time
			SD_IDLE: 						/* Idle/sleep process */
			begin
				sd_RAS_O <= 1;				// Set for NOP by default
				sd_CAS_O <= 1;
				sd_WE_O <= 1;
				sd_CS_O <= 1;				
				if(init_state != SI_DONE)	// If still in init cycle, go back and work
					sd_state <= SD_INIT;
				else if(wSTB_I && !wWE_I)				// Start of a read command
					sd_state <= SD_RD_START;
				else if(wSTB_I && wWE_I)	// Start of a write command
					sd_state <= SD_WR_START;
				else if(refresh_now)					// Refresh is the last command
					sd_state <= SD_AUTO_REF;
			end

			default:
				sd_state <= SD_IDLE;
		endcase
	end
end

/* Seperate always block for refresh timer */
/* The idea is to queue as many as 8 refresh command as possible if the bus is
 * free */
always @ (posedge clk0) 
begin
	if(refresh_ack)
	begin
		refresh_now <= 0;
		refresh_queue <= refresh_queue + 4'd1;
	end else
	if(reset) 
	begin
		refresh_counter <= 0;
		refresh_queue <= 4'd0;
	end else
	begin
		refresh_counter <= refresh_counter + 1;
		if(refresh_counter == AVG_REFRESH_DUR)
		begin
			refresh_counter <= 0;
			if(refresh_queue != 4'd0)
				refresh_queue <= refresh_queue - 4'd1;
		end
		if(refresh_queue != 4'd7)
			refresh_now <= 1;
	end
end

endmodule
