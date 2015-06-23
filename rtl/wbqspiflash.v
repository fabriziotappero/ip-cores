///////////////////////////////////////////////////////////////////////////
//
// Filename: 	wbspiflash.v
//
// Project:	Wishbone Controlled Quad SPI Flash Controller
//
// Purpose:	Access a Quad SPI flash via a WISHBONE interface.  This
//		includes both read and write (and erase) commands to the SPI
//		flash.  All read/write commands are accomplished using the
//		high speed (4-bit) interface.  Further, the device will be
//		left/kept in the 4-bit read interface mode between accesses,
//		for a minimum read latency.
//
//	Wishbone Registers (See spec sheet for more detail):
//	0: local config(r) / erase commands(w) / deep power down cmds / etc.
//	R: (Write in Progress), (dirty-block), (spi_port_busy), 1'b0, 9'h00,
//		{ last_erased_sector, 14'h00 } if (WIP)
//		else { current_sector_being_erased, 14'h00 }
//		current if write in progress, last if written
//	W: (1'b1 to erase), (12'h ignored), next_erased_block, 14'h ignored)
//	1: Configuration register
//	2: Status register (R/w)
//	3: Read ID (read only)
//	(19 bits): Data (R/w, but expect writes to take a while)
//		
//
// Creator:	Dan Gisselquist
//		Gisselquist Tecnology, LLC
//
///////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2015, Gisselquist Technology, LLC
//
// This program is free software (firmware): you can redistribute it and/or
// modify it under the terms of  the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program.  (It's in the $(ROOT)/doc directory, run make with no
// target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	GPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/gpl.html
//
//
///////////////////////////////////////////////////////////////////////////
`define	WBQSPI_RESET		0
`define	WBQSPI_RESET_QUADMODE	1
`define	WBQSPI_IDLE		2
`define	WBQSPI_RDIDLE		3	// Idle, but in fast read mode
`define	WBQSPI_WBDECODE		4
`define	WBQSPI_WAIT_WIP_CLEAR	5
`define	WBQSPI_CHECK_WIP_CLEAR	6
`define	WBQSPI_CHECK_WIP_DONE	7
`define	WBQSPI_WEN		8
`define	WBQSPI_PP		9	// Program page
`define	WBQSPI_QPP		10	// Program page, 4 bit mode
`define	WBQSPI_WR_DATA		11
`define	WBQSPI_WR_BUS_CYCLE	12
`define	WBQSPI_RD_DUMMY		13
`define	WBQSPI_QRD_ADDRESS	14
`define	WBQSPI_QRD_DUMMY	15
`define	WBQSPI_READ_CMD		16
`define	WBQSPI_READ_DATA	17
`define	WBQSPI_WAIT_TIL_RDIDLE	18
`define	WBQSPI_READ_ID_CMD	19
`define	WBQSPI_READ_ID		20
`define	WBQSPI_READ_STATUS	21
`define	WBQSPI_READ_CONFIG	22
`define	WBQSPI_WRITE_STATUS	23
`define	WBQSPI_WRITE_CONFIG	24
`define	WBQSPI_ERASE_WEN	25
`define	WBQSPI_ERASE_CMD	26
`define	WBQSPI_ERASE_BLOCK	27
`define	WBQSPI_CLEAR_STATUS	28
`define	WBQSPI_IDLE_CHECK_WIP	29
`define	WBQSPI_WAIT_TIL_IDLE	30

module	wbqspiflash(i_clk_100mhz,
		// Internal wishbone connections
		i_wb_cyc, i_wb_data_stb, i_wb_ctrl_stb, i_wb_we,
		i_wb_addr, i_wb_data,
		// Wishbone return values
		o_wb_ack, o_wb_stall, o_wb_data,
		// Quad Spi connections to the external device
		o_qspi_sck, o_qspi_cs_n, o_qspi_mod, o_qspi_dat, i_qspi_dat,
		o_interrupt);
	input			i_clk_100mhz;
	// Wishbone, inputs first
	input			i_wb_cyc, i_wb_data_stb, i_wb_ctrl_stb, i_wb_we;
	input		[19:0]	i_wb_addr;
	input		[31:0]	i_wb_data;
	// then outputs
	output	reg		o_wb_ack;
	output	reg		o_wb_stall;
	output	reg	[31:0]	o_wb_data;
	// Quad SPI control wires
	output	wire		o_qspi_sck, o_qspi_cs_n;
	output	wire	[1:0]	o_qspi_mod;
	output	wire	[3:0]	o_qspi_dat;
	input		[3:0]	i_qspi_dat;
	// Interrupt line
	output	reg		o_interrupt;

	reg		spi_wr, spi_hold, spi_spd, spi_dir;
	reg	[31:0]	spi_in;
	reg	[1:0]	spi_len;
	wire	[31:0]	spi_out;
	wire		spi_valid, spi_busy;
	wire		w_qspi_sck, w_qspi_cs_n;
	wire	[3:0]	w_qspi_dat;
	wire	[1:0]	w_qspi_mod;
	llqspi	lldriver(i_clk_100mhz,
			spi_wr, spi_hold, spi_in, spi_len, spi_spd, spi_dir,
				spi_out, spi_valid, spi_busy,
			w_qspi_sck, w_qspi_cs_n, w_qspi_mod, w_qspi_dat,
				i_qspi_dat);

	// Erase status tracking
	reg		write_in_progress, write_protect;
	reg	[5:0]	erased_sector;
	reg		dirty_sector;
	initial	begin
		write_in_progress = 1'b0;
		erased_sector = 6'h00;
		dirty_sector  = 1'b1;
		write_protect = 1'b1;
	end

	reg	[7:0]	last_status;
	reg		quad_mode_enabled;
	reg		spif_cmd, spif_override;
	reg	[19:0]	spif_addr;
	reg	[31:0]	spif_data;
	reg	[5:0]	state;
	reg		spif_ctrl, spif_req;
	wire	[5:0]	spif_sector;
	assign	spif_sector = spif_addr[19:14];

	initial	state = `WBQSPI_RESET;
	initial o_wb_ack   = 1'b0;
	initial o_wb_stall = 1'b1;
	initial spi_wr     = 1'b0;
	initial	spi_len    = 2'b00;
	initial	quad_mode_enabled = 1'b0;
	initial o_interrupt = 1'b0;
	always @(posedge i_clk_100mhz)
	begin
	spif_override <= 1'b0;
	if (state == `WBQSPI_RESET)
	begin
		// From a reset, we should
		//	Enable the Quad I/O mode
		//	Disable the Write protection bits in the status register
		//	Chip should already be up and running, so we can start
		//	immediately ....
		o_wb_ack <= 1'b0;
		o_wb_stall <= 1'b1;
		spi_wr   <= 1'b0;
		spi_hold <= 1'b0;
		spi_spd  <= 1'b0;
		spi_dir  <= 1'b0;
		last_status <= 8'h00;
		state <= `WBQSPI_RESET_QUADMODE;
		spif_req <= 1'b0;
		spif_override <= 1'b1;
		last_status <= 8'hfc; //
			// This guarantees that we aren't starting in quad
			// I/O mode, where the FPGA configuration scripts may
			// have left us.
	end else if (state == `WBQSPI_RESET_QUADMODE)
	begin
		// Okay, so here's the problem: we don't know whether or not
		// the Xilinx loader started us up in Quad Read I/O idle mode.
		// So, thus we need to 
		// Not ready to handle the bus yet, so stall any requests
		o_wb_ack   <= 1'b0;
		o_wb_stall <= 1'b1;

		// Do something ...
		if (last_status == 8'h00)
		begin
			spif_override <= 1'b0;
			state <= `WBQSPI_IDLE;
		end else begin
			last_status <= last_status - 8'h1;
			spif_override <= 1'b1;
			spif_cmd  <= last_status[3]; // Toggle CS_n
			spif_ctrl <= last_status[0]; // Toggle clock too
		end
	end else if (state == `WBQSPI_IDLE)
	begin
		o_interrupt <= 1'b0;
		o_wb_stall <= 1'b0;
		o_wb_ack <= 1'b0;
		spif_cmd   <= i_wb_we;
		spif_addr  <= i_wb_addr;
		spif_data  <= i_wb_data;
		spif_ctrl  <= (i_wb_ctrl_stb)&&(~i_wb_data_stb);
		spif_req   <= (i_wb_ctrl_stb)||(i_wb_data_stb);
		spi_wr <= 1'b0; // Keep the port idle, unless told otherwise
		spi_hold <= 1'b0;
		spi_spd  <= 1'b0;
		spi_dir <= 1'b0; // Write (for now, 'cause of cmd)
		// Data register access
		if ((i_wb_data_stb)&&(i_wb_cyc))
		begin

			if (i_wb_we) // Request to write a page
			begin
				if((~write_protect)&&(~write_in_progress))
				begin // 00
					spi_wr <= 1'b1;
					spi_len <= 2'b00; // 8 bits
					// Send a write enable command
					spi_in <= { 8'h06, 24'h00 };
					state <= `WBQSPI_WEN;

					o_wb_ack <= 1'b0;
					o_wb_stall <= 1'b1;
				end else if (write_protect)
				begin // whether or not write-in_progress ...
					// Do nothing on a write protect
					// violation
					//
					o_wb_ack <= 1'b1;
					o_wb_stall <= 1'b0;
				end else begin // write is in progress, wait
					// for it to complete
					state <= `WBQSPI_WAIT_WIP_CLEAR;
					o_wb_ack <= 1'b0;
					o_wb_stall <= 1'b1;
				end
			end else if (~write_in_progress)
			begin // Read access, normal mode(s)
				o_wb_ack   <= 1'b0;
				o_wb_stall <= 1'b1;
				spi_wr     <= 1'b1;	// Write cmd to device
				if (quad_mode_enabled)
				begin
					spi_in <= { 8'heb, 2'b00, i_wb_addr[19:0], 2'b00 };
					state <= `WBQSPI_QRD_ADDRESS;
					spi_len    <= 2'b00; // single byte, cmd only
				end else begin
					spi_in <= { 8'h0b, 2'b00, i_wb_addr[19:0], 2'b00 };
					state <= `WBQSPI_RD_DUMMY;
					spi_len    <= 2'b11; // cmd+addr,32bits
				end
			end else begin
				// A write is in progress ... need to stall
				// the bus until the write is complete.
				state <= `WBQSPI_WAIT_WIP_CLEAR;
				o_wb_ack   <= 1'b0;
				o_wb_stall <= 1'b1;
			end
		end else if ((i_wb_cyc)&&(i_wb_ctrl_stb)&&(i_wb_we))
		begin
			o_wb_stall <= 1'b1;
			case(i_wb_addr[1:0])
			2'b00: begin // Erase command register
				write_protect <= ~i_wb_data[28];
				o_wb_stall <= 1'b0;

				if((i_wb_data[31])&&(~write_in_progress))
				begin
					// Command an erase--ack it immediately

					o_wb_ack <= 1'b1;
					o_wb_stall <= 1'b0;

					if ((i_wb_data[31])&&(~write_protect))
					begin
						spi_wr <= 1'b1;
						spi_len <= 2'b00;
						// Send a write enable command
						spi_in <= { 8'h06, 24'h00 };
						state <= `WBQSPI_ERASE_CMD;
						o_wb_stall <= 1'b1;
					end
				end else if (i_wb_data[31])
				begin
					state <= `WBQSPI_WAIT_WIP_CLEAR;
					o_wb_ack   <= 1'b1;
					o_wb_stall <= 1'b1;
				end else
					o_wb_ack   <= 1'b1;
					o_wb_stall <= 1'b0;
				end
			2'b01: begin
				// Write the configuration register
				o_wb_ack <= 1'b1;
				o_wb_stall <= 1'b1;

				// Need to send a write enable command first
				spi_wr <= 1'b1;
				spi_len <= 2'b00; // 8 bits
				// Send a write enable command
				spi_in <= { 8'h06, 24'h00 };
				state <= `WBQSPI_WRITE_CONFIG;
				end
			2'b10: begin
				// Write the status register
				o_wb_ack <= 1'b1; // Ack immediately
				o_wb_stall <= 1'b1; // Stall other cmds
				// Need to send a write enable command first
				spi_wr <= 1'b1;
				spi_len <= 2'b00; // 8 bits
				// Send a write enable command
				spi_in <= { 8'h06, 24'h00 };
				state <= `WBQSPI_WRITE_STATUS;
				end
			2'b11: begin // Write the ID register??? makes no sense
				o_wb_ack <= 1'b1;
				o_wb_stall <= 1'b0;
				end
			endcase
		end else if ((i_wb_cyc)&&(i_wb_ctrl_stb)) // &&(~i_wb_we))
		begin
			case(i_wb_addr[1:0])
			2'b00: begin // Read local register
				if (write_in_progress) // Read status
				begin// register, is write still in progress?
					state <= `WBQSPI_READ_STATUS;
					spi_wr <= 1'b1;
					spi_len <= 2'b01;// 8 bits out, 8 bits in
					spi_in <= { 8'h05, 24'h00};

					o_wb_ack <= 1'b0;
					o_wb_stall <= 1'b1;
				end else begin // Return w/o talking to device
					o_wb_ack <= 1'b1;
					o_wb_stall <= 1'b0;
					o_wb_data <= { write_in_progress,
						dirty_sector, spi_busy,
						~write_protect,
						quad_mode_enabled,
						7'h00, 
						erased_sector, 14'h000 };
				end end
			2'b01: begin // Read configuration register
				state <= `WBQSPI_READ_CONFIG;
				spi_wr <= 1'b1;
				spi_len <= 2'b01;
				spi_in <= { 8'h35, 24'h00};

				o_wb_ack <= 1'b0;
				o_wb_stall <= 1'b1;
				end
			2'b10: begin // Read status register
				state <= `WBQSPI_READ_STATUS;
				spi_wr <= 1'b1;
				spi_len <= 2'b01; // 8 bits out, 8 bits in
				spi_in <= { 8'h05, 24'h00};

				o_wb_ack <= 1'b0;
				o_wb_stall <= 1'b1;
				end
			2'b11: begin // Read ID register
				state <= `WBQSPI_READ_ID_CMD;
				spi_wr <= 1'b1;
				spi_len <= 2'b00;
				spi_in <= { 8'h9f, 24'h00};

				o_wb_ack <= 1'b0;
				o_wb_stall <= 1'b1;
				end
			endcase
		end else if ((~i_wb_cyc)&&(write_in_progress))
		begin
			state <= `WBQSPI_IDLE_CHECK_WIP;
			spi_wr <= 1'b1;
			spi_len <= 2'b01; // 8 bits out, 8 bits in
			spi_in <= { 8'h05, 24'h00};

			o_wb_ack <= 1'b0;
			o_wb_stall <= 1'b1;
		end
	end else if (state == `WBQSPI_RDIDLE)
	begin
		spi_wr <= 1'b0;
		o_wb_stall <= 1'b0;
		o_wb_ack <= 1'b0;
		spif_cmd   <= i_wb_we;
		spif_addr  <= i_wb_addr;
		spif_data  <= i_wb_data;
		spif_ctrl  <= (i_wb_ctrl_stb)&&(~i_wb_data_stb);
		spif_req   <= (i_wb_ctrl_stb)||(i_wb_data_stb);
		spi_hold <= 1'b0;
		spi_spd<= 1'b1;
		spi_dir <= 1'b0; // Write (for now)
		if ((i_wb_cyc)&&(i_wb_data_stb)&&(~i_wb_we))
		begin // Continue our read ... send the new address / mode
			o_wb_stall <= 1'b1;
			spi_wr <= 1'b1;
			spi_len <= 2'b10; // Write address, but not mode byte
			spi_in <= { 2'h0, i_wb_addr[19:0], 2'h0, 8'ha0 };
			state <= `WBQSPI_QRD_DUMMY;
		end else if((i_wb_cyc)&&(i_wb_ctrl_stb)&&(~i_wb_we)&&(i_wb_addr[1:0] == 2'b00))
		begin
			// A local read that doesn't touch the device, so leave
			// the device in its current state
			o_wb_stall <= 1'b0;
			o_wb_ack <= 1'b1;
			o_wb_data <= { write_in_progress,
					dirty_sector, spi_busy,
					~write_protect,
					quad_mode_enabled,
					7'h00, 
					erased_sector, 14'h000 };
		end else if((i_wb_cyc)&&((i_wb_ctrl_stb)||(i_wb_data_stb)))
		begin // Need to release the device from quad mode for all else
			o_wb_ack   <= 1'b0;
			o_wb_stall <= 1'b1;
			spi_wr <= 1'b1;
			spi_len <= 2'b11;
			spi_in <= 32'h00;
			state <= `WBQSPI_WBDECODE;
		end
	end else if (state == `WBQSPI_WBDECODE)
	begin
		// We were in quad SPI read mode, and had to get out.
		// Now we've got a command (not data read) to read and
		// execute.  Accomplish what we would've done while in the
		// IDLE state here, save only that we don't have to worry
		// about data reads, and we need to operate on a stored
		// version of the bus command
		o_wb_stall <= 1'b1;
		o_wb_ack <= 1'b0;
		spi_wr <= 1'b0; // Keep the port idle, unless told otherwise
		spi_hold <= 1'b0;
		spi_spd <= 1'b0;
		spi_dir <= 1'b0;
		spif_req<= (spif_req) && (i_wb_cyc);
		if ((~spi_busy)&&(o_qspi_cs_n)&&(~spi_wr)) // only in full idle ...
		begin
			// Data register access
			if (~spif_ctrl)
			begin
				if (spif_cmd) // Request to write a page
				begin
					if((~write_protect)&&(~write_in_progress))
					begin // 00
						spi_wr <= 1'b1;
						spi_len <= 2'b00; // 8 bits
						// Send a write enable command
						spi_in <= { 8'h06, 24'h00 };
						state <= `WBQSPI_WEN;
	
						o_wb_ack <= 1'b0;
						o_wb_stall <= 1'b1;
					end else if (write_protect)
					begin // whether or not write-in_progress ...
						// Do nothing on a write protect
						// violation
						//
						o_wb_ack <= spif_req;
						o_wb_stall <= 1'b0;
						state <= `WBQSPI_IDLE;
					end else begin // write is in progress, wait
						// for it to complete
						state <= `WBQSPI_WAIT_WIP_CLEAR;
						o_wb_ack <= 1'b0;
						o_wb_stall <= 1'b1;
					end
				// end else if (~write_in_progress) // always true
				// but ... we wouldn't get here on a normal read access
				end else begin
					// Something's wrong, we should never get here
					// Attempt to go to idle to recover
					state <= `WBQSPI_IDLE;
				end
			end else if ((spif_ctrl)&&(spif_cmd))
			begin
				o_wb_stall <= 1'b1;
				case(spif_addr[1:0])
				2'b00: begin // Erase command register
					o_wb_ack   <= spif_req;
					o_wb_stall <= 1'b0;
					state <= `WBQSPI_IDLE;
					write_protect <= ~spif_data[28];
					// Are we commanding an erase?
					// We're in read mode, writes cannot
					// be in progress, so ...
					if (spif_data[31]) // Command an erase
					begin
						// Since we're not going back
						// to IDLE, we must stall the
						// bus here
						o_wb_stall <= 1'b1;
						spi_wr <= 1'b1;
						spi_len <= 2'b00;
						// Send a write enable command
						spi_in <= { 8'h06, 24'h00 };
						state <= `WBQSPI_ERASE_CMD;
					end end
				2'b01: begin
					// Write the configuration register
					o_wb_ack <= spif_req;
					o_wb_stall <= 1'b1;

					// Need to send a write enable command first
					spi_wr <= 1'b1;
					spi_len <= 2'b00; // 8 bits
					// Send a write enable command
					spi_in <= { 8'h06, 24'h00 };
					state <= `WBQSPI_WRITE_CONFIG;
					end
				2'b10: begin
					// Write the status register
					o_wb_ack <= spif_req; // Ack immediately
					o_wb_stall <= 1'b1; // Stall other cmds
					// Need to send a write enable command first
					spi_wr <= 1'b1;
					spi_len <= 2'b00; // 8 bits
					// Send a write enable command
					spi_in <= { 8'h06, 24'h00 };
					state <= `WBQSPI_WRITE_STATUS;
					end
				2'b11: begin // Write the ID register??? makes no sense
					o_wb_ack <= spif_req;
					o_wb_stall <= 1'b0;
					state <= `WBQSPI_IDLE;
					end
				endcase
			end else begin // on (~spif_we)
				case(spif_addr[1:0])
				2'b00: begin // Read local register
					// Nonsense case--would've done this
					// already
					state <= `WBQSPI_IDLE;
					o_wb_ack <= spif_req;
					o_wb_stall <= 1'b0;
					end
				2'b01: begin // Read configuration register
					state <= `WBQSPI_READ_CONFIG;
					spi_wr <= 1'b1;
					spi_len <= 2'b01;
					spi_in <= { 8'h35, 24'h00};

					o_wb_ack <= 1'b0;
					o_wb_stall <= 1'b1;
					end
				2'b10: begin // Read status register
					state <= `WBQSPI_READ_STATUS;
					spi_wr <= 1'b1;
					spi_len <= 2'b01; // 8 bits out, 8 bits in
					spi_in <= { 8'h05, 24'h00};

					o_wb_ack <= 1'b0;
					o_wb_stall <= 1'b1;
					end
				2'b11: begin // Read ID register
					state <= `WBQSPI_READ_ID_CMD;
					spi_wr <= 1'b1;
					spi_len <= 2'b00;
					spi_in <= { 8'h9f, 24'h00};

					o_wb_ack <= 1'b0;
					o_wb_stall <= 1'b1;
					end
				endcase
			end
		end
	end else if (state == `WBQSPI_WAIT_WIP_CLEAR)
	begin
		o_wb_stall <= 1'b1;
		o_wb_ack   <= 1'b0;
		spi_wr <= 1'b0;
		spif_req<= (spif_req) && (i_wb_cyc);
		if (~spi_busy)
		begin
			spi_wr   <= 1'b1;
			spi_in   <= { 8'h05, 24'h0000 };
			spi_hold <= 1'b1;
			spi_len  <= 2'b01; // 16 bits write, so we can read 8
			state <= `WBQSPI_CHECK_WIP_CLEAR;
			spi_spd  <= 1'b0; // Slow speed
			spi_dir  <= 1'b0;
		end
	end else if (state == `WBQSPI_CHECK_WIP_CLEAR)
	begin
		o_wb_stall <= 1'b1;
		o_wb_ack   <= 1'b0;
		// Repeat as often as necessary until we are clear
		spi_wr <= 1'b1;
		spi_in <= 32'h0000; // Values here are actually irrelevant
		spi_hold <= 1'b1;
		spi_len <= 2'b00; // One byte at a time
		spi_spd  <= 1'b0; // Slow speed
		spi_dir  <= 1'b0;
		spif_req<= (spif_req) && (i_wb_cyc);
		if ((spi_valid)&&(~spi_out[0]))
		begin
			state <= `WBQSPI_CHECK_WIP_DONE;
			spi_wr   <= 1'b0;
			spi_hold <= 1'b0;
			write_in_progress <= 1'b0;
			last_status <= spi_out[7:0];
		end
	end else if (state == `WBQSPI_CHECK_WIP_DONE)
	begin
		o_wb_stall <= 1'b1;
		o_wb_ack   <= 1'b0;
		// Let's let the SPI port come back to a full idle,
		// and the chip select line go low before continuing
		spi_wr   <= 1'b0;
		spi_len  <= 2'b00;
		spi_hold <= 1'b0;
		spi_spd  <= 1'b0; // Slow speed
		spi_dir  <= 1'b0;
		spif_req<= (spif_req) && (i_wb_cyc);
		if ((o_qspi_cs_n)&&(~spi_busy)) // Chip select line is high, we can continue
		begin
			spi_wr   <= 1'b0;
			spi_hold <= 1'b0;

			casez({ spif_cmd, spif_ctrl, spif_addr[1:0] })
			4'b00??: begin // Read data from ... somewhere
				spi_wr     <= 1'b1;	// Write cmd to device
				if (quad_mode_enabled)
				begin
					spi_in <= { 8'heb, 2'b00, spif_addr[19:0], 2'b00 };
					state <= `WBQSPI_QRD_ADDRESS;
					// spi_len    <= 2'b00; // single byte, cmd only
				end else begin
					spi_in <= { 8'h0b, 2'b00, spif_addr[19:0], 2'b00 };
					state <= `WBQSPI_RD_DUMMY;
					spi_len    <= 2'b11; // Send cmd and addr
				end end
			4'b10??: begin // Write data to ... anywhere
				spi_wr <= 1'b1;
				spi_len <= 2'b00; // 8 bits
				// Send a write enable command
				spi_in <= { 8'h06, 24'h00 };
				state <= `WBQSPI_WEN;
				end
			4'b0110: begin // Read status register
				state <= `WBQSPI_READ_STATUS;
				spi_wr <= 1'b1;
				spi_len <= 2'b01; // 8 bits out, 8 bits in
				spi_in <= { 8'h05, 24'h00};
				end
			4'b0111: begin
				state <= `WBQSPI_READ_ID_CMD;
				spi_wr <= 1'b1;
				spi_len <= 2'b00;
				spi_in <= { 8'h9f, 24'h00};
				end
			default: begin //
				o_wb_stall <= 1'b1;
				o_wb_ack <= spif_req;
				state <= `WBQSPI_WAIT_TIL_IDLE;
				end
			endcase
		// spif_cmd   <= i_wb_we;
		// spif_addr  <= i_wb_addr;
		// spif_data  <= i_wb_data;
		// spif_ctrl  <= (i_wb_ctrl_stb)&&(~i_wb_data_stb);
		// spi_wr <= 1'b0; // Keep the port idle, unless told otherwise
		end
	end else if (state == `WBQSPI_WEN)
	begin // We came here after issuing a write enable command
		spi_wr <= 1'b0;
		o_wb_ack <= 1'b0;
		o_wb_stall <= 1'b1;
		spif_req<= (spif_req) && (i_wb_cyc);
		if ((~spi_busy)&&(o_qspi_cs_n)&&(~spi_wr)) // Let's come to a full stop
			state <= (quad_mode_enabled)?`WBQSPI_QPP:`WBQSPI_PP;
			// state <= `WBQSPI_PP;
	end else if (state == `WBQSPI_PP)
	begin // We come here under a full stop / full port idle mode
		// Issue our command immediately
		spi_wr <= 1'b1;
		spi_in <= { 8'h02, 2'h0, spif_addr, 2'b00 };
		spi_len <= 2'b11;
		spi_hold <= 1'b1;
		spi_spd  <= 1'b0;
		spi_dir  <= 1'b0; // Writing
		spif_req<= (spif_req) && (i_wb_cyc);

		// Once we get busy, move on
		if (spi_busy)
			state <= `WBQSPI_WR_DATA;
		if (spif_sector == erased_sector)
			dirty_sector <= 1'b1;
	end else if (state == `WBQSPI_QPP)
	begin // We come here under a full stop / full port idle mode
		// Issue our command immediately
		spi_wr <= 1'b1;
		spi_in <= { 8'h32, 2'h0, spif_addr, 2'b00 };
		spi_len <= 2'b11;
		spi_hold <= 1'b1;
		spi_spd  <= 1'b0;
		spi_dir  <= 1'b0; // Writing
		spif_req<= (spif_req) && (i_wb_cyc);

		// Once we get busy, move on
		if (spi_busy)
		begin
			// spi_wr is irrelevant here ...
			// Set the speed value once, but wait til we get busy
			// to do so.
			spi_spd <= 1'b1;
			state <= `WBQSPI_WR_DATA;
		end
		if (spif_sector == erased_sector)
			dirty_sector <= 1'b1;
	end else if (state == `WBQSPI_WR_DATA)
	begin
		o_wb_stall <= 1'b1;
		o_wb_ack   <= 1'b0;
		spi_wr   <= 1'b1; // write without waiting
		spi_in   <= {
			spif_data[ 7: 0],
			spif_data[15: 8],
			spif_data[23:16],
			spif_data[31:24] };
		spi_len  <= 2'b11; // Write 4 bytes
		spi_hold <= 1'b1;
		if (~spi_busy)
		begin
			o_wb_ack <= spif_req; // Ack when command given
			state <= `WBQSPI_WR_BUS_CYCLE;
		end
		spif_req<= (spif_req) && (i_wb_cyc);
	end else if (state == `WBQSPI_WR_BUS_CYCLE)
	begin
		o_wb_ack <= 1'b0; // Turn off our ack and stall flags
		o_wb_stall <= 1'b1;
		spi_wr <= 1'b0;
		spi_hold <= 1'b1;
		write_in_progress <= 1'b1;
		spif_req<= (spif_req) && (i_wb_cyc);
		if (~i_wb_cyc)
		begin
			state <= `WBQSPI_WAIT_TIL_IDLE;
			spi_hold <= 1'b0;
		end else if (spi_wr)
		begin // Give the SPI a chance to get busy on the last write
			// Do nothing here.
		end else if ((i_wb_data_stb)&&(i_wb_we)
				&&(i_wb_addr == (spif_addr+1))
				&&(i_wb_addr[19:6]==spif_addr[19:6]))
		begin
			spif_cmd  <= 1'b1;
			spif_data <= i_wb_data;
			spif_addr <= i_wb_addr;
			spif_ctrl  <= 1'b0;
			spif_req<= 1'b1;
			// We'll keep the bus stalled on this request
			// for a while
			state <= `WBQSPI_WR_DATA;
			o_wb_ack   <= 1'b0;
			o_wb_stall <= 1'b0;
		end else if ((i_wb_data_stb|i_wb_ctrl_stb)&&(~o_wb_ack)) // Writing out of bounds
		begin
			spi_hold <= 1'b0;
			spi_wr   <= 1'b0;
			state <= `WBQSPI_WAIT_TIL_IDLE;
		end // Otherwise we stay here
	end else if (state == `WBQSPI_RD_DUMMY)
	begin
		o_wb_ack   <= 1'b0;
		o_wb_stall <= 1'b1;

		spi_wr <= 1'b1; // Non-stop
		// Need to read one byte of dummy data,
		// just to consume 8 clocks
		spi_in <= { 8'h00, 24'h00 };
		spi_len <= 2'b00; // Read 8 bits
		spi_spd <= 1'b0;
		spi_hold <= 1'b0;
		spif_req<= (spif_req) && (i_wb_cyc);
		
		if ((~spi_busy)&&(~o_qspi_cs_n))
			// Our command was accepted
			state <= `WBQSPI_READ_CMD;
	end else if (state == `WBQSPI_QRD_ADDRESS)
	begin
		// We come in here immediately upon issuing a QRD read
		// command (8-bits), but we have to pause to give the
		// address (24-bits) and mode (8-bits) in quad speed.
		o_wb_ack   <= 1'b0;
		o_wb_stall <= 1'b1;

		spi_wr <= 1'b1; // Non-stop
		spi_in <= { 2'b0, spif_addr, 2'b0, 8'ha0 };
		spi_len <= 2'b10; // Write address, not mode byte
		spi_spd <= 1'b1;
		spi_dir <= 1'b0; // Still writing
		spi_hold <= 1'b0;
		spif_req<= (spif_req) && (i_wb_cyc);
		
		if ((~spi_busy)&&(spi_spd))
			// Our command was accepted
			state <= `WBQSPI_QRD_DUMMY;
	end else if (state == `WBQSPI_QRD_DUMMY)
	begin
		o_wb_ack   <= 1'b0;
		o_wb_stall <= 1'b1;

		spi_wr <= 1'b1; // Non-stop
		spi_in <= { 8'ha0, 24'h00 }; // Mode byte, then 2 bytes dummy
		spi_len <= 2'b10; // Write 8 bits
		spi_spd <= 1'b1;
		spi_dir <= 1'b0; // Still writing
		spi_hold <= 1'b0;
		spif_req<= (spif_req) && (i_wb_cyc);
		
		if ((~spi_busy)&&(spi_in[31:28] == 4'ha))
			// Our command was accepted
			state <= `WBQSPI_READ_CMD;
	end else if (state == `WBQSPI_READ_CMD)
	begin // Issue our first command to read 32 bits.
		o_wb_ack   <= 1'b0;
		o_wb_stall <= 1'b1;

		spi_wr <= 1'b1;
		spi_in <= { 8'hff, 24'h00 }; // Empty
		spi_len <= 2'b11; // Read 32 bits
		spi_dir <= 1'b1; // Now reading
		spi_hold <= 1'b0;
		spif_req<= (spif_req) && (i_wb_cyc);
		if ((spi_valid)&&(spi_len == 2'b11))
			state <= `WBQSPI_READ_DATA;
	end else if (state == `WBQSPI_READ_DATA)
	begin
		// Pipelined read support
		spi_wr <=((i_wb_cyc)&&(i_wb_data_stb)&&(~i_wb_we)&&(i_wb_addr== (spif_addr+1)));
		spi_in <= 32'h00;
		spi_len <= 2'b11;
		// Don't adjust the speed here, it was set in the setup
		spi_dir <= 1'b1;	// Now we get to read
		// Don't let the device go to idle until the bus cycle ends.
		//	This actually prevents a *really* nasty race condition,
		//	where the strobe comes in after the lower level device
		//	has decided to stop waiting.  The write is then issued,
		//	but no one is listening.  By leaving the device open,
		//	the device is kept in a state where a valid strobe
		//	here will be useful.  Of course, we don't accept
		//	all commands, just reads.  Further, the strobe needs
		//	to be high for two clocks cycles without changing
		//	anything on the bus--one for us to notice it and pull
		//	our head out of the sand, and a second for whoever
		//	owns the bus to realize their command went through.
		spi_hold <= 1'b1;
		spif_req<= (spif_req) && (i_wb_cyc);
		if ((spi_valid)&&(~spi_in[31]))
		begin // Single pulse acknowledge and write data out
			o_wb_ack <= spif_req;
			o_wb_stall <= (~spi_wr);
			// adjust endian-ness to match the PC
			o_wb_data <= { spi_out[7:0], spi_out[15:8],
				spi_out[23:16], spi_out[31:24] };
			state <= (spi_wr)?`WBQSPI_READ_DATA
				: ((spi_spd) ? `WBQSPI_WAIT_TIL_RDIDLE : `WBQSPI_WAIT_TIL_IDLE);
			spif_req <= spi_wr;
			spi_hold <= (~spi_wr);
			if (spi_wr)
				spif_addr <= i_wb_addr;
		end else if (~i_wb_cyc)
		begin // FAIL SAFE: If the bus cycle ends, forget why we're
			// here, just go back to idle
			state <= ((spi_spd) ? `WBQSPI_WAIT_TIL_RDIDLE : `WBQSPI_WAIT_TIL_IDLE);
			spi_hold <= 1'b0;
			o_wb_ack <= 1'b0;
			o_wb_stall <= 1'b1;
		end else begin
			o_wb_ack <= 1'b0;
			o_wb_stall <= 1'b1;
		end
	end else if (state == `WBQSPI_WAIT_TIL_RDIDLE)
	begin // Wait 'til idle, but then go to fast read idle instead of full
		spi_wr     <= 1'b0;	// idle
		spi_hold   <= 1'b0;
		o_wb_stall <= 1'b1;
		o_wb_ack   <= 1'b0;
		spif_req   <= 1'b0;
		if ((~spi_busy)&&(o_qspi_cs_n)&&(~spi_wr)) // Wait for a full
		begin // clearing of the SPI port before moving on
			state <= `WBQSPI_RDIDLE;
			o_wb_stall <= 1'b0; 
			o_wb_ack   <= 1'b0;// Shouldn't be acking anything here
		end
	end else if (state == `WBQSPI_READ_ID_CMD)
	begin // We came into here immediately after issuing a 0x9f command
		// Now we need to read 32 bits of data.  Result should be
		// 0x0102154d (8'h manufacture ID, 16'h device ID, followed
		// by the number of extended bytes available 8'h4d).
		o_wb_ack <= 1'b0;
		o_wb_stall<= 1'b1;

		spi_wr <= 1'b1; // No data to send, but need four bytes, since
		spi_len <= 2'b11; // 32 bits of data are ... useful
		spi_in <= 32'h00; // Irrelevant
		spi_spd <= 1'b0; // Slow speed
		spi_dir <= 1'b1; // Reading
		spi_hold <= 1'b0;
		spif_req <= (spif_req) && (i_wb_cyc);
		if ((~spi_busy)&&(~o_qspi_cs_n)&&(spi_len == 2'b11))
			// Our command was accepted, now go read the result
			state <= `WBQSPI_READ_ID;
	end else if (state == `WBQSPI_READ_ID)
	begin
		o_wb_ack <= 1'b0; // Assuming we're still waiting
		o_wb_stall <= 1'b1;

		spi_wr <= 1'b0; // No more writes, we've already written the cmd
		spi_hold <= 1'b0;
		spif_req <= (spif_req) && (i_wb_cyc);

		// Here, we just wait until the result comes back
		// The problem is, the result may be the previous result.
		// So we use spi_len as an indicator
		spi_len <= 2'b00;
		if((spi_valid)&&(spi_len==2'b00))
		begin // Put the results out as soon as possible
			o_wb_data <= spi_out[31:0];
			o_wb_ack <= spif_req;
			spif_req <= 1'b0;
		end else if ((~spi_busy)&&(o_qspi_cs_n))
		begin
			state <= `WBQSPI_IDLE;
			o_wb_stall <= 1'b0;
		end
	end else if (state == `WBQSPI_READ_STATUS)
	begin // We enter after the command has been given, for now just
		// read and return
		spi_wr <= 1'b0;
		o_wb_ack <= 1'b0;
		spi_hold <= 1'b0;
		spif_req <= (spif_req) && (i_wb_cyc);
		if (spi_valid)
		begin
			o_wb_ack <= spif_req;
			o_wb_stall <= 1'b1;
			spif_req <= 1'b0;
			last_status <= spi_out[7:0];
			write_in_progress <= spi_out[0];
			if (spif_addr[1:0] == 2'b00) // Local read, checking
			begin // status, 'cause we're writing
				o_wb_data <= { spi_out[0],
					dirty_sector, spi_busy,
					~write_protect,
					quad_mode_enabled,
					7'h00, 
					erased_sector, 14'h000 };
			end else begin
				o_wb_data <= { 24'h00, spi_out[7:0] };
			end
		end

		if ((~spi_busy)&&(~spi_wr))
			state <= `WBQSPI_IDLE;
	end else if (state == `WBQSPI_READ_CONFIG)
	begin // We enter after the command has been given, for now just
		// read and return
		spi_wr <= 1'b0;
		o_wb_ack <= 1'b0;
		o_wb_stall <= 1'b1;
		spi_hold <= 1'b0;
		spif_req <= (spif_req) && (i_wb_cyc);

		if (spi_valid)
		begin
			o_wb_data <= { 24'h00, spi_out[7:0] };
			quad_mode_enabled <= spi_out[1];
		end

		if ((~spi_busy)&&(~spi_wr))
		begin
			state <= `WBQSPI_IDLE;
			o_wb_ack   <= spif_req;
			o_wb_stall <= 1'b0;
			spif_req <= 1'b0;
		end
	end else if (state == `WBQSPI_WRITE_CONFIG)
	begin // We enter immediately after commanding a WEN
		o_wb_ack   <= 1'b0;
		o_wb_stall <= 1'b1;

		spi_len <= 2'b10;
		spi_in <= { 8'h01, last_status, spif_data[7:0], 8'h00 };
		spi_wr <= 1'b0;
		spi_hold <= 1'b0;
		spif_req <= (spif_req) && (i_wb_cyc);
		if ((~spi_busy)&&(~spi_wr))
		begin
			spi_wr <= 1'b1;
			state <= `WBQSPI_WAIT_TIL_IDLE;
			write_in_progress <= 1'b1;
			quad_mode_enabled <= spif_data[1];
		end
	end else if (state == `WBQSPI_WRITE_STATUS)
	begin // We enter immediately after commanding a WEN
		o_wb_ack   <= 1'b0;
		o_wb_stall <= 1'b1;

		spi_len <= 2'b01;
		spi_in <= { 8'h01, spif_data[7:0], 16'h00 };
		// last_status <= i_wb_data[7:0]; // We'll read this in a moment
		spi_wr <= 1'b0;
		spi_hold <= 1'b0;
		spif_req <= (spif_req) && (i_wb_cyc);
		if ((~spi_busy)&&(~spi_wr))
		begin
			spi_wr <= 1'b1;
			last_status <= spif_data[7:0];
			write_in_progress <= 1'b1;
			if(((last_status[6])||(last_status[5]))
				&&((~spif_data[6])&&(~spif_data[5])))
				state <= `WBQSPI_CLEAR_STATUS;
			else
				state <= `WBQSPI_WAIT_TIL_IDLE;
		end
	end else if (state == `WBQSPI_ERASE_CMD)
	begin // Know that WIP is clear on entry, WEN has just been commanded
		spi_wr     <= 1'b0;
		o_wb_ack   <= 1'b0;
		o_wb_stall <= 1'b1;
		spi_hold   <= 1'b0;
		spi_spd <= 1'b0;
		spi_dir <= 1'b0;
		spif_req <= (spif_req) && (i_wb_cyc);

		// Here's the erase command
		spi_in <= { 8'hd8, 2'h0, spif_data[19:14], 14'h000, 2'b00 };
		spi_len <= 2'b11; // 32 bit write
		// together with setting our copy of the WIP bit
		write_in_progress <= 1'b1;
		// keeping track of which sector we just erased
		erased_sector <= spif_data[19:14];
		// and marking this erase sector as no longer dirty
		dirty_sector <= 1'b0;

		// Wait for a full stop before issuing this command
		if ((~spi_busy)&&(~spi_wr)&&(o_qspi_cs_n))
		begin // When our command is accepted, move to the next state
			spi_wr <= 1'b1;
			state <= `WBQSPI_ERASE_BLOCK;
		end
	end else if (state == `WBQSPI_ERASE_BLOCK)
	begin
		spi_wr     <= 1'b0;
		spi_hold   <= 1'b0;
		o_wb_stall <= 1'b1;
		o_wb_ack   <= 1'b0;
		spif_req <= (spif_req) && (i_wb_cyc);
		// When the port clears, we can head back to idle
		if ((~spi_busy)&&(~spi_wr))
		begin
			o_wb_ack <= spif_req;
			state <= `WBQSPI_IDLE;
		end
	end else if (state == `WBQSPI_CLEAR_STATUS)
	begin // Issue a clear status command
		spi_wr <= 1'b1;
		spi_hold <= 1'b0;
		spi_len <= 2'b00; // 8 bit command
		spi_in <= { 8'h30, 24'h00 };
		spi_spd <= 1'b0;
		spi_dir <= 1'b0;
		last_status[6:5] <= 2'b00;
		spif_req <= (spif_req) && (i_wb_cyc);
		if ((spi_wr)&&(~spi_busy))
			state <= `WBQSPI_WAIT_TIL_IDLE;
	end else if (state == `WBQSPI_IDLE_CHECK_WIP)
	begin // We are now in read status register mode

		// No bus commands have (yet) been given
		o_wb_stall <= 1'b1;
		o_wb_ack   <= 1'b0;
		spif_req <= (spif_req) && (i_wb_cyc);

		// Stay in this mode unless/until we get a command, or
		// 	the write is over
		spi_wr <= (((~i_wb_cyc)||((~i_wb_data_stb)&&(~i_wb_ctrl_stb)))
				&&(write_in_progress));
		spi_len <= 2'b00; // 8 bit reads
		spi_spd <= 1'b0;  // SPI, not quad
		spi_dir <= 1'b1;  // Read
		if (spi_valid)
		begin
			write_in_progress <= spi_out[0];
			if ((~spi_out[0])&&(write_in_progress))
				o_interrupt <= 1'b1;
		end else
			o_interrupt <= 1'b0;

		if ((~spi_wr)&&(~spi_busy)&&(o_qspi_cs_n))
		begin // We can now go to idle and process a command
			o_wb_stall <= 1'b0;
			o_wb_ack   <= 1'b0;
			state <= `WBQSPI_IDLE;
		end
	end else // if (state == `WBQSPI_WAIT_TIL_IDLE) or anything else
	begin
		spi_wr     <= 1'b0;
		spi_hold   <= 1'b0;
		o_wb_stall <= 1'b1;
		o_wb_ack   <= 1'b0;
		spif_req   <= 1'b0;
		if ((~spi_busy)&&(o_qspi_cs_n)&&(~spi_wr)) // Wait for a full
		begin // clearing of the SPI port before moving on
			state <= `WBQSPI_IDLE;
			o_wb_stall <= 1'b0; 
			o_wb_ack   <= 1'b0; // Shouldn't be acking anything here
		end
	end
	end

	// Command and control during the reset sequence
	assign	o_qspi_cs_n = (spif_override)?spif_cmd :w_qspi_cs_n;
	assign	o_qspi_sck  = (spif_override)?spif_ctrl:w_qspi_sck;
	assign	o_qspi_mod  = (spif_override)?   2'b01 :w_qspi_mod;
	assign	o_qspi_dat  = (spif_override)?   4'b00 :w_qspi_dat;
endmodule
