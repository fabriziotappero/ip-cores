/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009 Sebastien Bourdeauducq
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

module hpdmc_mgmt #(
	parameter sdram_depth = 26,
	parameter sdram_columndepth = 9
) (
	input sys_clk,
	input sdram_rst,
	
	input [2:0] tim_rp,
	input [2:0] tim_rcd,
	input [10:0] tim_refi,
	input [3:0] tim_rfc,
	
	input stb,
	input we,
	input [sdram_depth-3-1:0] address, /* in 64-bit words */
	output reg ack,
	
	output reg read,
	output reg write,
	output [3:0] concerned_bank,
	input read_safe,
	input write_safe,
	input [3:0] precharge_safe,
	
	output sdram_cs_n,
	output sdram_we_n,
	output sdram_cas_n,
	output sdram_ras_n,
	output [12:0] sdram_adr,
	output [1:0] sdram_ba
);

/*
 * Address Mapping :
 * |    ROW ADDRESS   |    BANK NUMBER    |  COL ADDRESS  | for 32-bit words
 * |depth-1 coldepth+2|coldepth+1 coldepth|coldepth-1    0|
 * (depth for 32-bit words, which is sdram_depth-2)
 */

parameter rowdepth = sdram_depth-2-1-(sdram_columndepth+2)+1;

wire [sdram_depth-2-1:0] address32 = {address, 1'b0};

wire [sdram_columndepth-1:0] col_address = address32[sdram_columndepth-1:0];
wire [1:0] bank_address = address32[sdram_columndepth+1:sdram_columndepth];
wire [rowdepth-1:0] row_address = address32[sdram_depth-2-1:sdram_columndepth+2];

reg [3:0] bank_address_onehot;
always @(*) begin
	case(bank_address)
		2'b00: bank_address_onehot <= 4'b0001;
		2'b01: bank_address_onehot <= 4'b0010;
		2'b10: bank_address_onehot <= 4'b0100;
		2'b11: bank_address_onehot <= 4'b1000;
	endcase
end

/* Track open rows */
reg [3:0] has_openrow;
reg [rowdepth-1:0] openrows[0:3];
reg [3:0] track_close;
reg [3:0] track_open;

always @(posedge sys_clk) begin
	if(sdram_rst) begin
		has_openrow = 4'h0;
	end else begin
		has_openrow = (has_openrow | track_open) & ~track_close;
		
		if(track_open[0]) openrows[0] <= row_address;
		if(track_open[1]) openrows[1] <= row_address;
		if(track_open[2]) openrows[2] <= row_address;
 		if(track_open[3]) openrows[3] <= row_address;
	end
end

/* Bank precharge safety */
assign concerned_bank = bank_address_onehot;
wire current_precharge_safe =
	 (precharge_safe[0] | ~bank_address_onehot[0])
	&(precharge_safe[1] | ~bank_address_onehot[1])
	&(precharge_safe[2] | ~bank_address_onehot[2])
	&(precharge_safe[3] | ~bank_address_onehot[3]);


/* Check for page hits */
wire bank_open = has_openrow[bank_address];
wire page_hit = bank_open & (openrows[bank_address] == row_address);

/* Address drivers */
reg sdram_adr_loadrow;
reg sdram_adr_loadcol;
reg sdram_adr_loadA10;
assign sdram_adr =
	 ({13{sdram_adr_loadrow}}	& row_address)
	|({13{sdram_adr_loadcol}}	& col_address)
	|({13{sdram_adr_loadA10}}	& 13'd1024);

assign sdram_ba = bank_address;

/* Command drivers */
reg sdram_cs;
reg sdram_we;
reg sdram_cas;
reg sdram_ras;
assign sdram_cs_n = ~sdram_cs;
assign sdram_we_n = ~sdram_we;
assign sdram_cas_n = ~sdram_cas;
assign sdram_ras_n = ~sdram_ras;

/* Timing counters */

/* The number of clocks we must wait following a PRECHARGE command (usually tRP). */
reg [2:0] precharge_counter;
reg reload_precharge_counter;
wire precharge_done = (precharge_counter == 3'd0);
always @(posedge sys_clk) begin
	if(reload_precharge_counter)
		precharge_counter <= tim_rp;
	else if(~precharge_done)
		precharge_counter <= precharge_counter - 3'd1;
end

/* The number of clocks we must wait following an ACTIVATE command (usually tRCD). */
reg [2:0] activate_counter;
reg reload_activate_counter;
wire activate_done = (activate_counter == 3'd0);
always @(posedge sys_clk) begin
	if(reload_activate_counter)
		activate_counter <= tim_rcd;
	else if(~activate_done)
		activate_counter <= activate_counter - 3'd1;
end

/* The number of clocks we have left before we must refresh one row in the SDRAM array (usually tREFI). */
reg [10:0] refresh_counter;
reg reload_refresh_counter;
wire must_refresh = refresh_counter == 11'd0;
always @(posedge sys_clk) begin
	if(sdram_rst)
		refresh_counter <= 11'd0;
	else begin
		if(reload_refresh_counter)
			refresh_counter <= tim_refi;
		else if(~must_refresh)
			refresh_counter <= refresh_counter - 11'd1;
	end
end

/* The number of clocks we must wait following an AUTO REFRESH command (usually tRFC). */
reg [3:0] autorefresh_counter;
reg reload_autorefresh_counter;
wire autorefresh_done = (autorefresh_counter == 4'd0);
always @(posedge sys_clk) begin
	if(reload_autorefresh_counter)
		autorefresh_counter <= tim_rfc;
	else if(~autorefresh_done)
		autorefresh_counter <= autorefresh_counter - 4'd1;
end

/* FSM that pushes commands into the SDRAM */

reg [3:0] state;
reg [3:0] next_state;

parameter IDLE			= 4'd0;
parameter ACTIVATE		= 4'd1;
parameter READ			= 4'd2;
parameter WRITE			= 4'd3;
parameter PRECHARGEALL		= 4'd4;
parameter AUTOREFRESH		= 4'd5;
parameter AUTOREFRESH_WAIT	= 4'd6;

always @(posedge sys_clk) begin
	if(sdram_rst)
		state <= IDLE;
	else begin
		//$display("state: %d -> %d", state, next_state);
		state <= next_state;
	end
end

always @(*) begin
	next_state = state;
	
	reload_precharge_counter = 1'b0;
	reload_activate_counter = 1'b0;
	reload_refresh_counter = 1'b0;
	reload_autorefresh_counter = 1'b0;
	
	sdram_cs = 1'b0;
	sdram_we = 1'b0;
	sdram_cas = 1'b0;
	sdram_ras = 1'b0;
	
	sdram_adr_loadrow = 1'b0;
	sdram_adr_loadcol = 1'b0;
	sdram_adr_loadA10 = 1'b0;
	
	track_close = 4'b0000;
	track_open = 4'b0000;
	
	read = 1'b0;
	write = 1'b0;
	
	ack = 1'b0;
	
	case(state)
		IDLE: begin
			if(must_refresh)
				next_state = PRECHARGEALL;
			else begin
				if(stb) begin
					if(page_hit) begin
						if(we) begin
							if(write_safe) begin
								/* Write */
								sdram_cs = 1'b1;
								sdram_ras = 1'b0;
								sdram_cas = 1'b1;
								sdram_we = 1'b1;
								sdram_adr_loadcol = 1'b1;
								
								write = 1'b1;
								ack = 1'b1;
							end
						end else begin
							if(read_safe) begin
								/* Read */
								sdram_cs = 1'b1;
								sdram_ras = 1'b0;
								sdram_cas = 1'b1;
								sdram_we = 1'b0;
								sdram_adr_loadcol = 1'b1;
								
								read = 1'b1;
								ack = 1'b1;
							end
						end
					end else begin
						if(bank_open) begin
							if(current_precharge_safe) begin
								/* Precharge Bank */
								sdram_cs = 1'b1;
								sdram_ras = 1'b1;
								sdram_cas = 1'b0;
								sdram_we = 1'b1;
								
								track_close = bank_address_onehot;
								reload_precharge_counter = 1'b1;
								next_state = ACTIVATE;
							end
						end else begin
							/* Activate */
							sdram_cs = 1'b1;
							sdram_ras = 1'b1;
							sdram_cas = 1'b0;
							sdram_we = 1'b0;
							sdram_adr_loadrow = 1'b1;
				
							track_open = bank_address_onehot;
							reload_activate_counter = 1'b1;
							if(we)
								next_state = WRITE;
							else
								next_state = READ;
						end
					end
				end
			end
		end
		
		ACTIVATE: begin
			if(precharge_done) begin
				sdram_cs = 1'b1;
				sdram_ras = 1'b1;
				sdram_cas = 1'b0;
				sdram_we = 1'b0;
				sdram_adr_loadrow = 1'b1;
				
				track_open = bank_address_onehot;
				reload_activate_counter = 1'b1;
				if(we)
					next_state = WRITE;
				else
					next_state = READ;
			end
		end
		READ: begin
			if(activate_done) begin
				if(read_safe) begin
					sdram_cs = 1'b1;
					sdram_ras = 1'b0;
					sdram_cas = 1'b1;
					sdram_we = 1'b0;
					sdram_adr_loadcol = 1'b1;
					
					read = 1'b1;
					ack = 1'b1;
					next_state = IDLE;
				end
			end
		end
		WRITE: begin
			if(activate_done) begin
				if(write_safe) begin
					sdram_cs = 1'b1;
					sdram_ras = 1'b0;
					sdram_cas = 1'b1;
					sdram_we = 1'b1;
					sdram_adr_loadcol = 1'b1;
					
					write = 1'b1;
					ack = 1'b1;
					next_state = IDLE;
				end
			end
		end
		
		PRECHARGEALL: begin
			if(precharge_safe == 4'b1111) begin
				sdram_cs = 1'b1;
				sdram_ras = 1'b1;
				sdram_cas = 1'b0;
				sdram_we = 1'b1;
				sdram_adr_loadA10 = 1'b1;
	
				reload_precharge_counter = 1'b1;
				
				track_close = 4'b1111;
				
				next_state = AUTOREFRESH;
			end
		end
		AUTOREFRESH: begin
			if(precharge_done) begin
				sdram_cs = 1'b1;
				sdram_ras = 1'b1;
				sdram_cas = 1'b1;
				sdram_we = 1'b0;
				reload_refresh_counter = 1'b1;
				reload_autorefresh_counter = 1'b1;
				next_state = AUTOREFRESH_WAIT;
			end
		end
		AUTOREFRESH_WAIT: begin
			if(autorefresh_done)
				next_state = IDLE;
		end
		
	endcase
end

endmodule
