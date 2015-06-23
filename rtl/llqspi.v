///////////////////////////////////////////////////////////////////////////
//
// Filename: 	llqspi.v
//
// Project:	Wishbone Controlled Quad SPI Flash Controller
//
// Purpose:	Reads/writes a word (user selectable number of bytes) of data
//		to/from a Quad SPI port.  The port is understood to be 
//		a normal SPI port unless the driver requests four bit mode.
//		When not in use, unlike our previous SPI work, no bits will
//		toggle.
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
`define	QSPI_IDLE	3'h0
`define	QSPI_START	3'h1
`define	QSPI_BITS	3'h2
`define	QSPI_READY	3'h3
`define	QSPI_HOLDING	3'h4
`define	QSPI_STOP	3'h5
`define	QSPI_STOP_B	3'h6

// Modes
`define	QSPI_MOD_SPI	2'b00
`define	QSPI_MOD_QOUT	2'b10
`define	QSPI_MOD_QIN	2'b11

module	llqspi(i_clk,
		// Module interface
		i_wr, i_hold, i_word, i_len, i_spd, i_dir,
			o_word, o_valid, o_busy,
		// QSPI interface
		o_sck, o_cs_n, o_mod, o_dat, i_dat);
	input			i_clk;
	// Chip interface
	//	Can send info
	//		i_dir = 1, i_spd = 0, i_hold = 0, i_wr = 1,
	//			i_word = { 1'b0, 32'info to send },
	//			i_len = # of bytes in word-1
	input			i_wr, i_hold;
	input		[31:0]	i_word;
	input		[1:0]	i_len;	// 0=>8bits, 1=>16 bits, 2=>24 bits, 3=>32 bits
	input			i_spd; // 0 -> normal QPI, 1 -> QSPI
	input			i_dir; // 0 -> read, 1 -> write to SPI
	output	reg	[31:0]	o_word;
	output	reg		o_valid, o_busy;
	// Interface with the QSPI lines
	output	reg		o_sck;
	output	reg		o_cs_n;
	output	reg	[1:0]	o_mod;
	output	reg	[3:0]	o_dat;
	input		[3:0]	i_dat;

	// Timing:
	//
	//	Tick	Clk	BSY/WR	CS_n	BIT/MO	STATE
	//	 0	1	0/0	1	 -	
	//	 1	1	0/1	1	 -
	//	 2	1	1/0	0	 -	QSPI_START
	//	 3	0	1/0	0	 -	QSPI_START
	//	 4	0	1/0	0	 0	QSPI_BITS
	//	 5	1	1/0	0	 0	QSPI_BITS
	//	 6	0	1/0	0	 1	QSPI_BITS
	//	 7	1	1/0	0	 1	QSPI_BITS
	//	 8	0	1/0	0	 2	QSPI_BITS
	//	 9	1	1/0	0	 2	QSPI_BITS
	//	10	0	1/0	0	 3	QSPI_BITS
	//	11	1	1/0	0	 3	QSPI_BITS
	//	12	0	1/0	0	 4	QSPI_BITS
	//	13	1	1/0	0	 4	QSPI_BITS
	//	14	0	1/0	0	 5	QSPI_BITS
	//	15	1	1/0	0	 5	QSPI_BITS
	//	16	0	1/0	0	 6	QSPI_BITS
	//	17	1	1/1	0	 6	QSPI_BITS
	//	18	0	1/1	0	 7	QSPI_READY
	//	19	1	0/1	0	 7	QSPI_READY
	//	20	0	1/0/V	0	 8	QSPI_BITS
	//	21	1	1/0	0	 8	QSPI_BITS
	//	22	0	1/0	0	 9	QSPI_BITS
	//	23	1	1/0	0	 9	QSPI_BITS
	//	24	0	1/0	0	10	QSPI_BITS
	//	25	1	1/0	0	10	QSPI_BITS
	//	26	0	1/0	0	11	QSPI_BITS
	//	27	1	1/0	0	11	QSPI_BITS
	//	28	0	1/0	0	12	QSPI_BITS
	//	29	1	1/0	0	12	QSPI_BITS
	//	30	0	1/0	0	13	QSPI_BITS
	//	31	1	1/0	0	13	QSPI_BITS
	//	32	0	1/0	0	14	QSPI_BITS
	//	33	1	1/0	0	14	QSPI_BITS
	//	34	0	1/0	0	15	QSPI_READY
	//	35	1	1/0	0	15	QSPI_READY
	//	36	1	1/0/V	0	 -	QSPI_STOP
	//	37	1	1/0	0	 -	QSPI_STOPB
	//	38	1	1/0	1	 -	QSPI_IDLE
	//	39	1	0/0	1	 -
	// Now, let's switch from single bit to quad mode
	//	40	1	0/0	1	 -	QSPI_IDLE
	//	41	1	0/1	1	 -	QSPI_IDLE
	//	42	1	1/0	0	 -	QSPI_START
	//	43	0	1/0	0	 -	QSPI_START
	//	44	0	1/0	0	 0	QSPI_BITS
	//	45	1	1/0	0	 0	QSPI_BITS
	//	46	0	1/0	0	 1	QSPI_BITS
	//	47	1	1/0	0	 1	QSPI_BITS
	//	48	0	1/0	0	 2	QSPI_BITS
	//	49	1	1/0	0	 2	QSPI_BITS
	//	50	0	1/0	0	 3	QSPI_BITS
	//	51	1	1/0	0	 3	QSPI_BITS
	//	52	0	1/0	0	 4	QSPI_BITS
	//	53	1	1/0	0	 4	QSPI_BITS
	//	54	0	1/0	0	 5	QSPI_BITS
	//	55	1	1/0	0	 5	QSPI_BITS
	//	56	0	1/0	0	 6	QSPI_BITS
	//	57	1	1/1/QR	0	 6	QSPI_BITS
	//	58	0	1/1/QR	0	 7	QSPI_READY
	//	59	1	0/1/QR	0	 7	QSPI_READY
	//	60	0	1/0/?/V	0	 8-11	QSPI_BITS
	//	61	1	1/0/?	0	 8-11	QSPI_BITS
	//	62	0	1/0/?	0	 12-15	QSPI_BITS
	//	63	1	1/0/?	0	 12-15	QSPI_BITS
	//	64	1	1/0/?/V	0	-	QSPI_STOP
	//	65	1	1/0/?	0	-	QSPI_STOPB
	//	66	1	1/0/?	1	-	QSPI_IDLE
	//	67	1	0/0	1	-	QSPI_IDLE
	// Now let's try something entirely in Quad read mode, from the
	// beginning
	//	68	1	0/1/QR	1	-	QSPI_IDLE
	//	69	1	1/0	0	-	QSPI_START
	//	70	0	1/0	0	-	QSPI_START
	//	71	0	1/0	0	0-3	QSPI_BITS
	//	72	1	1/0	0	0-3	QSPI_BITS
	//	73	0	1/1/QR	0	4-7	QSPI_BITS
	//	74	1	0/1/QR	0	4-7	QSPI_BITS
	//	75	0	1/?/?/V	0	8-11	QSPI_BITS
	//	76	1	1/?/?	0	8-11	QSPI_BITS
	//	77	0	1/1/QR	0	12-15	QSPI_BITS
	//	78	1	0/1/QR	0	12-15	QSPI_BITS
	//	79	0	1/?/?/V	0	16-19	QSPI_BITS
	//	80	1	1/0	0	16-19	QSPI_BITS
	//	81	0	1/0	0	20-23	QSPI_BITS
	//	82	1	1/0	0	20-23	QSPI_BITS
	//	83	1	1/0/V	0	-	QSPI_STOP
	//	84	1	1/0	0	-	QSPI_STOPB
	//	85	1	1/0	1	-	QSPI_IDLE
	//	86	1	0/0	1	-	QSPI_IDLE

	wire	i_miso;
	assign	i_miso = i_dat[1];

	reg		r_spd, r_dir;
	reg	[5:0]	spi_len;
	reg	[31:0]	r_word;
	reg	[30:0]	r_input;
	reg	[2:0]	state;
	initial	state = `QSPI_IDLE;
	initial	o_sck   = 1'b1;
	initial	o_cs_n  = 1'b1;
	initial	o_dat   = 4'hd;
	initial	o_valid = 1'b0;
	initial	o_busy  = 1'b0;
	initial	r_input = 31'h000;
	always @(posedge i_clk)
		if ((state == `QSPI_IDLE)&&(o_sck))
		begin
			o_cs_n <= 1'b1;
			o_valid <= 1'b0;
			o_busy  <= 1'b0;
			o_mod <= `QSPI_MOD_SPI;
			if (i_wr)
			begin
				r_word <= i_word;
				state <= `QSPI_START;
				r_spd <= i_spd;
				r_dir <= i_dir;
				spi_len<= { 1'b0, i_len, 3'b000 } + 6'h8;
				o_cs_n <= 1'b0;
				o_busy <= 1'b1;
				o_sck <= 1'b1;
			end
		end else if (state == `QSPI_START)
		begin // We come in here with sck high, stay here 'til sck is low
			o_sck <= 1'b0;
			if (o_sck == 1'b0)
			begin
				state <= `QSPI_BITS;
				spi_len<= spi_len - ( (r_spd)? 6'h4 : 6'h1 );
				if (r_spd)
					r_word <= { r_word[27:0], 4'h0 };
				else
					r_word <= { r_word[30:0], 1'b0 };
			end
			o_mod <= (r_spd) ? { 1'b1, r_dir } : `QSPI_MOD_SPI;
			o_cs_n <= 1'b0;
			o_busy <= 1'b1;
			o_valid <= 1'b0;
			if (r_spd)
			begin
				o_dat <= r_word[31:28];
				// r_word <= { r_word[27:0], 4'h0 };
			end else begin
				o_dat <= { 3'b110, r_word[31] };
				// r_word <= { r_word[30:0], 1'b0 };
			end
		end else if (~o_sck)
		begin
			o_sck <= 1'b1;
			o_busy <= ((state != `QSPI_READY)||(~i_wr));
			o_valid <= 1'b0;
		end else if (state == `QSPI_BITS)
		begin
			// Should enter into here with at least a spi_len
			// of one, perhaps more
			o_sck <= 1'b0;
			o_busy <= 1'b1;
			if (r_spd)
			begin
				o_dat <= r_word[31:28];
				r_word <= { r_word[27:0], 4'h0 };
				spi_len <= spi_len - 6'h4;
				if (spi_len == 6'h4)
					state <= `QSPI_READY;
			end else begin
				o_dat <= { 3'b110, r_word[31] };
				r_word <= { r_word[30:0], 1'b0 };
				spi_len <= spi_len - 6'h1;
				if (spi_len == 6'h1)
					state <= `QSPI_READY;
			end

			o_valid <= 1'b0;
			if (~o_mod[1])
				r_input <= { r_input[29:0], i_miso };
			else if (o_mod[1])
				r_input <= { r_input[26:0], i_dat };
		end else if (state == `QSPI_READY)
		begin
			o_valid <= 1'b0;
			o_cs_n <= 1'b0;
			o_busy <= 1'b1;
			// This is the state on the last clock (both low and
			// high clocks) of the data.  Data is valid during
			// this state.  Here we chose to either STOP or
			// continue and transmit more.
			o_sck <= (i_hold); // No clocks while holding
			if((~o_busy)&&(i_wr))// Acknowledge a new request
			begin
				state <= `QSPI_BITS;
				o_busy <= 1'b1;
				o_sck <= 1'b0;

				// Read the new request off the bus
				r_spd <= i_spd;
				r_dir <= i_dir;
				// Set up the first bits on the bus
				o_mod <= (i_spd) ? { 1'b1, i_dir } : `QSPI_MOD_SPI;
				if (i_spd)
				begin
					o_dat <= i_word[31:28];
					r_word <= { i_word[27:0], 4'h0 };
					// spi_len <= spi_len - 4;
					spi_len<= { 1'b0, i_len, 3'b000 } + 6'h8
						- 6'h4;
				end else begin
					o_dat <= { 3'b110, i_word[31] };
					r_word <= { i_word[30:0], 1'b0 };
					spi_len<= { 1'b0, i_len, 3'b000 } + 6'h8
						- 6'h1;
				end

				// Read a bit upon any transition
				o_valid <= 1'b1;
				if (~o_mod[1])
				begin
					r_input <= { r_input[29:0], i_miso };
					o_word  <= { r_input[30:0], i_miso };
				end else if (o_mod[1])
				begin
					r_input <= { r_input[26:0], i_dat };
					o_word  <= { r_input[27:0], i_dat };
				end
			end else begin
				o_sck <= 1'b1;
				state <= (i_hold)?`QSPI_HOLDING : `QSPI_STOP;
				o_busy <= (~i_hold);

				// Read a bit upon any transition
				o_valid <= 1'b1;
				if (~o_mod[1])
				begin
					r_input <= { r_input[29:0], i_miso };
					o_word  <= { r_input[30:0], i_miso };
				end else if (o_mod[1])
				begin
					r_input <= { r_input[26:0], i_dat };
					o_word  <= { r_input[27:0], i_dat };
				end
			end
		end else if (state == `QSPI_HOLDING)
		begin
			// We need this state so that the o_valid signal
			// can get strobed with our last result.  Otherwise
			// we could just sit in READY waiting for a new command.
			//
			// Incidentally, the change producing this state was
			// the result of a nasty race condition.  See the
			// commends in wbqspiflash for more details.
			//
			o_valid <= 1'b0;
			o_cs_n <= 1'b0;
			o_busy <= 1'b0;
			if((~o_busy)&&(i_wr))// Acknowledge a new request
			begin
				state  <= `QSPI_BITS;
				o_busy <= 1'b1;
				o_sck  <= 1'b0;

				// Read the new request off the bus
				r_spd <= i_spd;
				r_dir <= i_dir;
				// Set up the first bits on the bus
				o_mod<=(i_spd)?{ 1'b1, i_dir } : `QSPI_MOD_SPI;
				if (i_spd)
				begin
					o_dat <= i_word[31:28];
					r_word <= { i_word[27:0], 4'h0 };
					spi_len<= { 1'b0, i_len, 3'b100 };
				end else begin
					o_dat <= { 3'b110, i_word[31] };
					r_word <= { i_word[30:0], 1'b0 };
					spi_len<= { 1'b0, i_len, 3'b111 };
				end
			end else begin
				o_sck <= 1'b1;
				state <= (i_hold)?`QSPI_HOLDING : `QSPI_STOP;
				o_busy <= (~i_hold);
			end
		end else if (state == `QSPI_STOP)
		begin
			o_sck   <= 1'b1; // Stop the clock
			o_valid <= 1'b0; // Output may have just been valid, but no more
			o_busy  <= 1'b1; // Still busy till port is clear
			state <= `QSPI_STOP_B;
			o_mod <= `QSPI_MOD_SPI;
		end else if (state == `QSPI_STOP_B)
		begin
			o_cs_n <= 1'b1;
			o_sck <= 1'b1;
			// Do I need this????
			// spi_len <= 3; // Minimum CS high time before next cmd
			state <= `QSPI_IDLE;
			o_valid <= 1'b0;
			o_busy <= 1'b1;
			o_mod <= `QSPI_MOD_SPI;
		end else begin // Invalid states, should never get here
			state   <= `QSPI_STOP;
			o_valid <= 1'b0;
			o_busy  <= 1'b1;
			o_cs_n  <= 1'b1;
			o_sck   <= 1'b1;
			o_mod   <= `QSPI_MOD_SPI;
			o_dat   <= 4'hd;
		end

endmodule

