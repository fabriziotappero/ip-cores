///////////////////////////////////////////////////////////////////////////
//
// Filename: 	rtcclock.v
//		
// Project:	A Wishbone Controlled Real--time Clock Core
//
// Purpose:	Implement a real time clock, including alarm, count--down
//		timer, stopwatch, variable time frequency, and more.
//
//
// Creator:	Dan Gisselquist, Ph.D.
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
// with this program.  (It's in the $(ROOT)/doc directory.  Run make with no
// target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	GPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/gpl.html
//
//
///////////////////////////////////////////////////////////////////////////
module	rtcclock(i_clk, 
		// Wishbone interface
		i_wb_cyc, i_wb_stb, i_wb_we, i_wb_addr, i_wb_data,
		//	o_wb_ack, o_wb_stb, o_wb_data, // no reads here
		// // Button inputs
		// i_btn,
		// Output registers
		o_data, // multiplexed based upon i_wb_addr
		// Output controls
		o_sseg, o_led, o_interrupt,
		// Time setting hack(s)
		i_hack);
	input	i_clk;
	input	i_wb_cyc, i_wb_stb, i_wb_we;
	input	[2:0]	i_wb_addr;
	input	[31:0]	i_wb_data;
	// input		i_btn;
	output	reg	[31:0]	o_data;
	output	reg	[31:0]	o_sseg;
	output	wire	[15:0]	o_led;
	output	wire		o_interrupt;
	input			i_hack;

	reg	[31:0]	clock, stopwatch, ckspeed;
	reg	[25:0]	timer;
	
	wire	ck_sel, tm_sel, sw_sel, sp_sel, al_sel;
	assign	ck_sel = ((i_wb_cyc)&&(i_wb_stb)&&(i_wb_addr[2:0]==3'b000));
	assign	tm_sel = ((i_wb_cyc)&&(i_wb_stb)&&(i_wb_addr[2:0]==3'b001));
	assign	sw_sel = ((i_wb_cyc)&&(i_wb_stb)&&(i_wb_addr[2:0]==3'b010));
	assign	al_sel = ((i_wb_cyc)&&(i_wb_stb)&&(i_wb_addr[2:0]==3'b011));
	assign	sp_sel = ((i_wb_cyc)&&(i_wb_stb)&&(i_wb_addr[2:0]==3'b100));

	reg	[39:0]	ck_counter;
	reg		ck_carry;
	always @(posedge i_clk)
		{ ck_carry, ck_counter } <= ck_counter + { 8'h00, ckspeed };

	wire		ck_pps;
	reg		ck_prepps, ck_ppm, ck_pph, ck_ppd;
	reg	[7:0]	ck_sub;
	initial	clock = 32'h00000000;
	assign	ck_pps = (ck_carry)&&(ck_prepps);
	always @(posedge i_clk)
	begin
		if (ck_carry)
			ck_sub <= ck_sub + 1;
		ck_prepps <= (ck_sub == 8'hff);

		if (ck_pps)
		begin // advance the seconds
			if (clock[3:0] >= 4'h9)
				clock[3:0] <= 4'h0;
			else
				clock[3:0] <= clock[3:0] + 4'h1;
			if (clock[7:0] >= 8'h59)
				clock[7:4] <= 4'h0;
			else if (clock[3:0] >= 4'h9)
				clock[7:4] <= clock[7:4] + 4'h1;
		end
		ck_ppm <= (clock[7:0] == 8'h59);

		if ((ck_pps)&&(ck_ppm))
		begin // advance the minutes
			if (clock[11:8] >= 4'h9)
				clock[11:8] <= 4'h0;
			else
				clock[11:8] <= clock[11:8] + 4'h1;
			if (clock[15:8] >= 8'h59)
				clock[15:12] <= 4'h0;
			else if (clock[11:8] >= 4'h9)
				clock[15:12] <= clock[15:12] + 4'h1;
		end
		ck_pph <= (clock[15:0] == 16'h5959);

		if ((ck_pps)&&(ck_pph))
		begin // advance the hours
			if (clock[21:16] >= 6'h23)
			begin
				clock[19:16] <= 4'h0;
				clock[21:20] <= 2'h0;
			end else if (clock[19:16] >= 4'h9)
			begin
				clock[19:16] <= 4'h0;
				clock[21:20] <= clock[21:20] + 2'h1;
			end else begin
				clock[19:16] <= clock[19:16] + 4'h1;
			end
		end
		// ppd <= (clock{15:8] == 8'h59);

		if ((ck_sel)&&(i_wb_we))
		begin
			if (8'hff != i_wb_data[7:0])
			begin
				clock[7:0] <= i_wb_data[7:0];
				ck_ppm <= (i_wb_data[7:0] == 8'h59);
			end
			if (8'hff != i_wb_data[15:8])
			begin
				clock[15:8] <= i_wb_data[15:8];
				ck_pph <= (i_wb_data[15:8] == 8'h59);
			end
			if (6'h3f != i_wb_data[21:16])
				clock[21:16] <= i_wb_data[21:16];
			clock[31:22] <= i_wb_data[31:22];
			if (8'h00 == i_wb_data[7:0])
				ck_sub <= 8'h00;
		end
	end

	// Clock updates take several clocks, so let's make sure we
	// are only looking at a valid clock value before testing it.
	reg	[21:0]		ck_last_clock;
	always @(posedge i_clk)
		ck_last_clock <= clock[21:0];
		

	reg	tm_pps, tm_ppm, tm_int;
	wire	tm_stopped, tm_running, tm_alarm;
	assign	tm_stopped = ~timer[24];
	assign	tm_running =  timer[24];
	assign	tm_alarm   =  timer[25];
	reg	[23:0]		tm_start;
	reg	[7:0]		tm_sub;
	initial	tm_start = 24'h00;
	initial	timer    = 26'h00;
	initial	tm_int   = 1'b0;
	initial	tm_pps   = 1'b0;
	always @(posedge i_clk)
	begin
		if (ck_carry)
		begin
			tm_sub <= tm_sub + 1;
			tm_pps <= (tm_sub == 8'hff);
		end else
			tm_pps <= 1'b0;
		
		if ((~tm_alarm)&&(tm_running)&&(tm_pps))
		begin // If we are running ...
			timer[25] <= 1'b0;
			if (timer[23:0] == 24'h00)
				timer[25] <= 1'b1;
			else if (timer[3:0] != 4'h0)
				timer[3:0] <= timer[3:0]-4'h1;
			else begin // last digit is a zero
				timer[3:0] <= 4'h9;
				if (timer[7:4] != 4'h0)
					timer[7:4] <= timer[7:4]-4'h1;
				else begin // last two digits are zero
					timer[7:4] <= 4'h5;
					if (timer[11:8] != 4'h0)
						timer[11:8] <= timer[11:8]-4'h1;
					else begin // last three digits are zero
						timer[11:8] <= 4'h9;
						if (timer[15:12] != 4'h0)
							timer[15:12] <= timer[15:12]-4'h1;
						else begin
							timer[15:12] <= 4'h5;
							if (timer[19:16] != 4'h0)
								timer[19:16] <= timer[19:16]-4'h1;
							else begin
							//
								timer[19:16] <= 4'h9;
								timer[23:20] <= timer[23:20]-4'h1;
							end
						end
					end
				end
			end
		end

		if((~tm_alarm)&&(tm_running))
		begin
			timer[25] <= (timer[23:0] == 24'h00);
			tm_int <= (timer[23:0] == 24'h00);
		end else tm_int <= 1'b0;
		if (tm_alarm)
			timer[24] <= 1'b0;

		if ((tm_sel)&&(i_wb_we)&&(tm_running)) // Writes while running
			// Only allowed to stop the timer, nothing more
			timer[24] <= i_wb_data[24];
		else if ((tm_sel)&&(i_wb_we)&&(tm_stopped)) // Writes while off
		begin
			timer[24] <= i_wb_data[24];
			if ((timer[24])||(i_wb_data[24]))
				timer[25] <= 1'b0;
			if (i_wb_data[23:0] != 24'h0000)
			begin
				timer[23:0] <= i_wb_data[23:0];
				tm_start <= i_wb_data[23:0];
				tm_sub <= 8'h00;
			end else if (timer[23:0] == 24'h00)
			begin // Resetting timer to last valid timer start val
				timer[23:0] <= tm_start;
				tm_sub <= 8'h00;
			end
			// Any write clears the alarm
			timer[25] <= 1'b0;
		end
	end

	//
	// Stopwatch functionality
	//
	// Setting bit '0' starts the stop watch, clearing it stops it.
	// Writing to the register with bit '1' high will clear the stopwatch,
	// and return it to zero provided that the stopwatch is stopped either
	// before or after the write.  Hence, writing a '2' to the device
	// will always stop and clear it, whereas writing a '3' to the device
	// will only clear it if it was already stopped.
	reg		sw_pps, sw_ppm, sw_pph;
	reg	[7:0]	sw_sub;
	wire	sw_running;
	assign	sw_running = stopwatch[0];
	initial	stopwatch = 32'h00000;
	always @(posedge i_clk)
	begin
		sw_pps <= 1'b0;
		if (sw_running)
		begin
			if (ck_carry)
			begin
				sw_sub <= sw_sub + 1;
				sw_pps <= (sw_sub == 8'hff);
			end
		end

		stopwatch[7:1] <= sw_sub[7:1];

		if (sw_pps)
		begin // Second hand
			if (stopwatch[11:8] >= 4'h9)
				stopwatch[11:8] <= 4'h0;
			else
				stopwatch[11:8] <= stopwatch[11:8] + 4'h1;

			if (stopwatch[15:8] >= 8'h59)
				stopwatch[15:12] <= 4'h0;
			else if (stopwatch[11:8] >= 4'h9)
				stopwatch[15:12] <= stopwatch[15:12] + 4'h1;
			sw_ppm <= (stopwatch[15:8] == 8'h59);
		end else sw_ppm <= 1'b0;

		if (sw_ppm)
		begin // Minutes
			if (stopwatch[19:16] >= 4'h9)
				stopwatch[19:16] <= 4'h0;
			else
				stopwatch[19:16] <= stopwatch[19:16]+4'h1;

			if (stopwatch[23:16] >= 8'h59)
				stopwatch[23:20] <= 4'h0;
			else if (stopwatch[19:16] >= 4'h9)
				stopwatch[23:20] <= stopwatch[23:20]+4'h1;
			sw_pph <= (stopwatch[23:16] == 8'h59);
		end else sw_pph <= 1'b0;

		if (sw_pph)
		begin // And hours
			if (stopwatch[27:24] >= 4'h9)
				stopwatch[27:24] <= 4'h0;
			else
				stopwatch[27:24] <= stopwatch[27:24]+4'h1;

			if((stopwatch[27:24] >= 4'h9)&&(stopwatch[31:28] < 4'hf))
				stopwatch[31:28] <= stopwatch[27:24]+4'h1;
		end

		if ((sw_sel)&&(i_wb_we))
		begin
			stopwatch[0] <= i_wb_data[0];
			if((i_wb_data[1])&&((~stopwatch[0])||(~i_wb_data[0])))
			begin
				stopwatch[31:1] <= 31'h00;
				sw_sub <= 8'h00;
				sw_pps <= 1'b0;
				sw_ppm <= 1'b0;
				sw_pph <= 1'b0;
			end
		end
	end

	//
	// The alarm code
	//
	// Set the alarm register to the time you wish the board to "alarm".
	// The "alarm" will take place once per day at that time.  At that
	// time, the RTC code will generate a clock interrupt, and the CPU/host
	// can come and see that the alarm tripped.
	//
	// 
	reg	[21:0]		alarm_time;
	reg			al_int,		// The alarm interrupt line
				al_enabled,	// Whether the alarm is enabled
				al_tripped;	// Whether the alarm has tripped
	initial	al_enabled= 1'b0;
	initial	al_tripped= 1'b0;
	always @(posedge i_clk)
	begin
		if ((al_sel)&&(i_wb_we))
		begin
			// Only adjust the alarm hours if the requested hours
			// are valid.  This allows writes to the register,
			// without a prior read, to leave these configuration
			// bits alone.
			if (i_wb_data[21:16] != 6'h3f)
				alarm_time[21:16] <= i_wb_data[21:16];
			// Here's the same thing for the minutes: only adjust
			// the alarm minutes if the new bits are not all 1's. 
			if (i_wb_data[15:8] != 8'hff)
				alarm_time[15:8] <= i_wb_data[15:8];
			// Here's the same thing for the seconds: only adjust
			// the alarm minutes if the new bits are not all 1's. 
			if (i_wb_data[7:0] != 8'hff)
				alarm_time[7:0] <= i_wb_data[7:0];
			al_enabled <= i_wb_data[24];
			// Reset the alarm if a '1' is written to the tripped
			// register, or if the alarm is disabled.
			if ((i_wb_data[25])||(~i_wb_data[24]))
				al_tripped <= 1'b0;
		end

		al_int <= 1'b0;
		if ((ck_last_clock != alarm_time)&&(clock[21:0] == alarm_time)
			&&(al_enabled))
		begin
			al_tripped <= 1'b1;
			al_int <= 1'b1;
		end
	end

	//
	// The ckspeed register is equal to 2^48 divded by the number of
	// clock ticks you expect per second.  Adjust high for a slower
	// clock, lower for a faster clock.  In this fashion, a single
	// real time clock RTL file can handle tracking the clock in any
	// device.  Further, because this is only the lower 32 bits of a 
	// 48 bit counter per seconds, the clock jitter is kept below
	// 1 part in 65 thousand.
	//
	initial	ckspeed = 32'd2814750; // 2af31e = 2^48 / 100e6 MHz
	// In the case of verilator, comment the above and uncomment the line
	// below.  The clock constant below is "close" to simulation time,
	// meaning that my verilator simulation is running about 300x slower
	// than board time.
	// initial	ckspeed = 32'd786432000;
	always @(posedge i_clk)
		if ((sp_sel)&&(i_wb_we))
			ckspeed <= i_wb_data;

	// 
	// If you want very fine precision control over your clock, you need
	// to be able to transfer time from one location to another.  This
	// is the beginning of that means: by setting a wire, i_hack, high
	// on a particular input, you can then read (later) what the clock
	// time was on that input.
	//
	// What's missing from this high precision adjustment mechanism is a
	// means of actually adjusting this time based upon the time 
	// difference you measure here between the hack time and some time
	// on another clock, but we'll get there.
	//
	reg		r_hack_carry;
	reg	[29:0]	hack_time;
	reg	[39:0]	hack_counter;
	initial	hack_time    = 30'h0000;
	initial	hack_counter = 40'h0000;
	always @(posedge i_clk)
		if (i_hack)
		begin
			hack_time <= { clock[21:0], ck_sub };
			hack_counter <= ck_counter;
			r_hack_carry <= ck_carry;
			// if ck_carry is set, the clock register is in the
			// middle of a two clock update.  In that case ....
		end else if (r_hack_carry)
		begin // update again on the next clock to get the correct
			// hack time.
			hack_time <= { clock[21:0], ck_sub };
			r_hack_carry <= 1'b0;
		end

	reg	[15:0]	h_sseg;
	reg	[3:0]	dmask;
	always @(posedge i_clk)
		case(clock[27:24])
		4'h1: begin h_sseg <= timer[15:0];
			if (tm_alarm) dmask <= 4'hf;
			else begin
				dmask[3] <= (12'h000 != timer[23:12]); // timer[15:12]
				dmask[2] <= (16'h000 != timer[23: 8]); // timer[11: 8]
				dmask[1] <= (20'h000 != timer[23: 4]); // timer[ 7: 4]
				dmask[0] <= 1'b1; // Always on
			end end
		4'h2: begin h_sseg <= stopwatch[19:4];
				dmask[3] <= (12'h00  != stopwatch[27:16]);
				dmask[2] <= (16'h000 != stopwatch[27:12]);
				dmask[1] <= 1'b1; // Always on, stopwatch[11:8]
				dmask[0] <= 1'b1; // Always on, stopwatch[7:4]
			end
		4'h3: begin h_sseg <= ck_last_clock[15:0];
				dmask[3:0] <= 4'hf;
			end
		default: begin // 4'h0
			h_sseg <= { 2'b00, ck_last_clock[21:8] };
			dmask[2:0] <= 3'hf;
			dmask[3] <= (2'b00 != ck_last_clock[21:20]);
			end
		endcase

	wire	[31:0]	w_sseg;
	assign	w_sseg[ 0] =  (~ck_sub[7]);
	assign	w_sseg[ 8] =  (clock[27:24] == 4'h2);
	assign	w_sseg[16] = ((clock[27:24] == 4'h0)&&(~ck_sub[7]))||(clock[27:24] == 4'h3);
	assign	w_sseg[24] = 1'b0;
	hexmap	ha(i_clk, h_sseg[ 3: 0], w_sseg[ 7: 1]);
	hexmap	hb(i_clk, h_sseg[ 7: 4], w_sseg[15: 9]);
	hexmap	hc(i_clk, h_sseg[11: 8], w_sseg[23:17]);
	hexmap	hd(i_clk, h_sseg[15:12], w_sseg[31:25]);

	always @(posedge i_clk)
		if ((tm_alarm || al_tripped)&&(ck_sub[7]))
			o_sseg <= 32'h0000;
		else
			o_sseg <= { 
				(dmask[3])?w_sseg[31:24]:8'h00,
				(dmask[2])?w_sseg[23:16]:8'h00,
				(dmask[1])?w_sseg[15: 8]:8'h00,
				(dmask[0])?w_sseg[ 7: 0]:8'h00 };

	reg	[17:0]	ledreg;
	always @(posedge i_clk)
		if ((ck_pps)&&(ck_ppm))
			ledreg <= 18'h00;
		else if (ck_carry)
			ledreg <= ledreg + 18'h11;
	assign	o_led = (tm_alarm||al_tripped)?{ (16){ck_sub[7]}}:
				{ ledreg[17:10],
				ledreg[10], ledreg[11], ledreg[12], ledreg[13],
				ledreg[14], ledreg[15], ledreg[16], ledreg[17] };

	assign	o_interrupt = tm_int || al_int;

	always @(posedge i_clk)
		case(i_wb_addr[2:0])
		3'b000: o_data <= { clock[31:22], ck_last_clock };
		3'b001: o_data <= { 6'h00, timer };
		3'b010: o_data <= stopwatch;
		3'b011: o_data <= { 6'h00, al_tripped, al_enabled, 2'b00, alarm_time };
		3'b100: o_data <= ckspeed;
		3'b101: o_data <= { 2'b00, hack_time };
		3'b110: o_data <= hack_counter[39:8];
		3'b111: o_data <= { hack_counter[7:0], 24'h00 };
		endcase

endmodule
