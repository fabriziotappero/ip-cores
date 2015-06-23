//////////////////////////////////////////////////////////////////////
////                                                              ////
////  lcd_display.v                                               ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   - Memory mapped main controller.                           ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
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
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "lcd_defines.v"

module lcd (
	input clk,
	input reset,
	
	input [`DAT_WIDTH-1:0] dat,
	input [`ADDR_WIDTH-1:0] addr,
	input we,
	
	output busy,
	output [3:0] SF_D,
	output LCD_E,
	output LCD_RS,
	output LCD_RW
	);

//
// TX sub FSM
//
parameter tx_state_high_setup	= 3'b000;
parameter tx_state_high_hold	= 3'b001;
parameter tx_state_oneus	= 3'b010;
parameter tx_state_low_setup	= 3'b011;
parameter tx_state_low_hold	= 3'b100;
parameter tx_state_fortyus	= 3'b101;	
parameter tx_state_done		= 3'b110;

reg	[2:0]	tx_state = tx_state_done; // Current tx fsm state
reg	[7:0]	tx_byte; // transmitting byte
wire		tx_init; // init transmission
reg  		tx_done = 0;


//
// MAIN FSM
//
parameter display_state_init		= 5'b00000;
parameter init_state_fifteenms		= 5'b00001;
parameter init_state_one		= 5'b00010;
parameter init_state_two		= 5'b00011;
parameter init_state_three		= 5'b00100;
parameter init_state_four		= 5'b00101;
parameter init_state_five		= 5'b00110;
parameter init_state_six		= 5'b00111;
parameter init_state_seven		= 5'b01000;
parameter init_state_eight		= 5'b01001;
parameter display_state_function_set	= 5'b11000;
parameter display_state_entry_set	= 5'b11001;
parameter display_state_set_display	= 5'b11010;
parameter display_state_clr_display	= 5'b11011;
parameter display_state_pause_setup	= 5'b10000;
parameter display_state_pause		= 5'b10001;
parameter display_state_set_addr	= 5'b11100;
parameter display_state_char_write	= 5'b11101;
parameter display_state_done		= 5'b10010;

reg [4:0] display_state = display_state_init; // current main fsm state




//
// RAM Interface
//
assign busy = (display_state != display_state_done);

reg [`DAT_WIDTH-1:0] wr_dat;
reg [`ADDR_WIDTH-1:0] wr_addr;
																			
///
/// FSM and councurrent assignments definitions for LCD driving
/// 
reg [3:0] SF_D0 = 4'b0000;
reg [3:0] SF_D1 = 4'b0000;
reg       LCD_E0 = 1'b0;
reg       LCD_E1 = 1'b0;
wire      output_selector;

assign output_selector = display_state[4];

assign SF_D = (output_selector == 1'b1) ?	SF_D0 : //transmit
						SF_D1;  //initialize

assign LCD_E = (output_selector == 1'b1) ?	LCD_E0 ://transmit
						LCD_E1; //initialize

assign LCD_RW = 1'b0; // write only

//when to transmit a command/data and when not to
assign tx_init = !tx_done & display_state[4] & display_state[3];

// register select
assign LCD_RS =	(display_state == display_state_function_set) ? 1'b0 :
                (display_state == display_state_entry_set)    ? 1'b0 :
                (display_state == display_state_set_display)  ? 1'b0 :
                (display_state == display_state_clr_display)  ? 1'b0 :
                (display_state == display_state_set_addr)     ? 1'b0 :
                                                                1'b1;


reg  [`INIT_DELAY_COUNTER_WIDTH-1:0] main_delay_value = 0;
reg  [`INIT_DELAY_COUNTER_WIDTH-1:0] tx_delay_value = 0;

wire delay_done;

reg main_delay_load = 0;
reg tx_delay_load = 0;



delay_counter  #(
	.counter_width(`INIT_DELAY_COUNTER_WIDTH)
) delay_counter (
	.clk   ( clk ),
	.reset ( reset ),
	.count ( (main_delay_load) ? main_delay_value : tx_delay_value),
	.load  ( main_delay_load | tx_delay_load ),
	.done  ( delay_done )
);									  
																					  



// main (display) state machine
always @(posedge clk, posedge reset)
begin
	if(reset==1'b1) begin
		display_state <= display_state_init;
		main_delay_load <= 0;
		main_delay_value <= 0;
	end else begin
		main_delay_load <= 0;
		main_delay_value <= 0;

		case (display_state)
			//refer to intialize state machine below
			display_state_init:
			begin
				tx_byte <= 8'b00000000;
				display_state <= init_state_fifteenms;
				main_delay_load <= 1'b1;
				main_delay_value <= 750000;
			end

			init_state_fifteenms: 
			begin
				main_delay_load <= 1'b0;
				if(delay_done) begin
					display_state <= init_state_one;
					main_delay_load <= 1'b1;
					main_delay_value <= 11;
				end
			end	

			init_state_one: 
			begin
				main_delay_load <= 1'b0;
				SF_D1 <= 4'b0011;
				LCD_E1 <= 1'b1;
				if(delay_done) begin
					display_state <= init_state_two;
					main_delay_load <= 1'b1;
					main_delay_value <= 205000;
				end 
			end

			init_state_two: 
			begin
				main_delay_load <= 1'b0;
				LCD_E1 <= 1'b0;
				if(delay_done) begin
					display_state <= init_state_three;
					main_delay_load <= 1'b1;
					main_delay_value <= 11;
				end
			end

			init_state_three: 
			begin
				main_delay_load <= 1'b0;
				SF_D1 <= 4'b0011;
				LCD_E1 <= 1'b1;
				if(delay_done) begin
					display_state <= init_state_four;
					main_delay_load <= 1'b1;
					main_delay_value <= 5000;
				end
			end

			init_state_four: 
			begin
				main_delay_load <= 1'b0;
				LCD_E1 <= 1'b0;
				if(delay_done) begin
					display_state <= init_state_five;
					main_delay_load <= 1'b1;
					main_delay_value <= 11;
				end
			end

			init_state_five: 
			begin
				main_delay_load <= 1'b0;
				SF_D1 <= 4'b0011;
				LCD_E1 <= 1'b1;
				if(delay_done) begin
					display_state <= init_state_six;
					main_delay_load <= 1'b1;
					main_delay_value <= 2000;
				end
			end

			init_state_six: 
			begin
				main_delay_load <= 1'b0;
				LCD_E1 <= 1'b0;
				if(delay_done) begin
					display_state <= init_state_seven;
					main_delay_load <= 1'b1;
					main_delay_value <= 11;
				end
			end

			init_state_seven: 
			begin
				main_delay_load <= 1'b0;
				SF_D1 <= 4'b0010;
				LCD_E1 <= 1'b1;
				if(delay_done) begin
					display_state <= init_state_eight;
					main_delay_load <= 1'b1;
					main_delay_value <= 2000;
				end
			end

			init_state_eight: 
			begin
				main_delay_load <= 1'b0;
				LCD_E1 <= 1'b0;
				if(delay_done) begin
					display_state <= display_state_function_set;
				end
			end

			//every other state but pause uses the transmit state machine
			display_state_function_set:
			begin
				tx_byte <= 8'b00101000;
				if(tx_done)
					display_state <= display_state_entry_set;
			end
				
			display_state_entry_set:
			begin
				tx_byte <= 8'b00000110;
				if(tx_done)
					display_state <= display_state_set_display;
			end
			
			display_state_set_display:
			begin
				tx_byte <= 8'b00001100;
				if(tx_done)
					display_state <= display_state_clr_display;
			end
				
			display_state_clr_display:
			begin
				tx_byte <= 8'b00000001;
				if(tx_done) begin
					display_state <= display_state_pause_setup;
					main_delay_load <= 1;
					main_delay_value <= 82000;
				end
			end

			display_state_pause_setup:
			begin
				display_state <= display_state_pause;
			end

			display_state_pause:
			begin
				tx_byte <= 8'b00000000;
				if(delay_done) 
					display_state <= display_state_done;
			end

			display_state_done:
			begin
				tx_byte <= 8'b00000000;
				if (we) begin
					display_state <= display_state_set_addr;
					wr_addr <= addr;
					wr_dat <= dat;
				end else
					display_state <= display_state_done;
			end

			display_state_set_addr:
			begin
				tx_byte <= { 1'b1 , wr_addr};
				if(tx_done) begin
					display_state <= display_state_char_write;
				end
			end

			display_state_char_write:
			begin
				tx_byte <= wr_dat;
				if(tx_done)
					display_state <= display_state_done;

			end

		endcase
	end
end


// transmit (tx) state machine, specified by datasheet
always @(posedge clk, posedge reset)
begin
	if(reset==1'b1)
		tx_state <= tx_state_done;
	else
	begin
		case (tx_state)
			tx_state_high_setup: // 40 ns
			begin
				LCD_E0 <= 1'b0;
				SF_D0 <= tx_byte[7 : 4];
				tx_delay_load <= 1'b0;
				if(delay_done) begin
					tx_state <= tx_state_high_hold;
					tx_delay_load <= 1'b1;
					tx_delay_value <= 12;
				end
			end

			tx_state_high_hold: // 230 ns
			begin
				LCD_E0 <= 1'b1;
				SF_D0 <= tx_byte[7 : 4];
				tx_delay_load <= 1'b0;
				if(delay_done) begin
					tx_state <= tx_state_oneus;
					tx_delay_load <= 1'b1;
					tx_delay_value <= 50;
				end
			end

			tx_state_oneus: 
			begin
				LCD_E0 <= 1'b0;
				tx_delay_load <= 1'b0;
				if(delay_done) begin
					tx_state <= tx_state_low_setup;
					tx_delay_load <= 1'b1;
					tx_delay_value <= 2;
				end
			end

			tx_state_low_setup: // 40 ns
			begin
				LCD_E0 <= 1'b0;
				SF_D0 <= tx_byte[3 : 0];
				tx_delay_load <= 1'b0;
				if(delay_done) begin
					tx_state <= tx_state_low_hold;
					tx_delay_load <= 1'b1;
					tx_delay_value <= 12;
				end
			end

			tx_state_low_hold: // 230 ns
			begin
				LCD_E0 <= 1'b1;
				SF_D0 <= tx_byte[3 : 0];
				tx_delay_load <= 1'b0;
				if(delay_done) begin
					tx_state <= tx_state_fortyus;
					tx_delay_load <= 1'b1;
					tx_delay_value <= 2000;
				end
			end

			tx_state_fortyus: 
			begin
				LCD_E0 <= 1'b0;
				tx_delay_load <= 1'b0;
				if(delay_done) begin
					tx_state <= tx_state_done;
					tx_done <= 1'b1;
				end
			end

			tx_state_done: 
			begin
				LCD_E0 <= 1'b0;
				tx_done <= 1'b0;
				tx_delay_load <= 1'b0;
				if(tx_init == 1'b1) begin
					tx_state <= tx_state_high_setup;
					tx_delay_load <= 1'b1;
					tx_delay_value <= 2;
				end
			end
		endcase
	end
end
endmodule
