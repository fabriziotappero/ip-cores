`timescale 1ns / 1ps

module lcd_controller(
    input rst,
    input clk,
    input rs_in,
	 input [7:0] data_in,
    input strobe_in,
    input [7:0] period_clk_ns,
    output lcd_e,
    output [3:0] lcd_nibble,
    output lcd_rs,
    output lcd_rw,
    output disable_flash,
    output reg done
    );

	// States for FSM that initialize the LCD
	localparam lcd_init_rst = 1;
	localparam lcd_init_wait = 2;	
	localparam lcd_init_write_03_01 = 3;
	localparam lcd_init_wait_4ms = 4;
	localparam lcd_init_write_03_02 = 5;
	localparam lcd_init_wait_100us = 6;
	localparam lcd_init_write_03_03 = 7;
	localparam lcd_init_wait_40us = 8;
	localparam lcd_init_write_02 = 9;
	localparam lcd_init_wait_50us = 10;
	localparam lcd_init_state_done = 11;
	localparam lcd_init_strobe = 12;
	reg [3:0] lcd_init_states, lcd_init_state_next; // Declare two variables of 4 bits to hold the FSM states
	reg [23:0] counter_wait_lcd_init;	
	reg [8:0] counter_wait_strobe_lcd_init, counter_wait_stabilize_lcd_init;
	reg [23:0] time_wait_lcd_init;
	reg [3:0] lcd_init_data_out;  // FSM output LCD_DATA
	reg lcd_init_e_out;           // FSM output LCD_E
	reg lcd_init_done;
	
	// States for FSM that send data to LCD
	localparam lcd_data_rst = 1;
	localparam lcd_data_wait_1us = 2;
	localparam lcd_data_wr_nibble_high = 3;
	localparam lcd_data_wr_nibble_low = 4;	
	localparam lcd_data_strobe = 5;
	localparam lcd_data_wait_40us = 6;
	localparam lcd_data_done = 7;
	reg [19:0] time_wait_lcd_data;
	reg [19:0] counter_wait_lcd_data;	
	reg [8:0] counter_wait_strobe_lcd_data, counter_wait_stabilize_lcd_data;
	reg [3:0] lcd_data_states, lcd_data_state_next;	// Declare two variables of 4 bits to hold the FSM states
	reg [3:0] lcd_data_data_out;	// FSM output LCD_DATA
	reg lcd_data_e_out;				// FSM output LCD_E
			
	/*
		Initialize LCD...
	*/
	always @ (posedge clk)
	begin
		if (rst)	// Reset synchronous
			begin
				lcd_init_states <= lcd_init_rst;
				counter_wait_lcd_init <= 0;
				counter_wait_strobe_lcd_init <= 0;
				counter_wait_stabilize_lcd_init <= 0;
				lcd_init_e_out <= 0;
				lcd_init_done <= 0;
				lcd_init_data_out <= 0;
			end
		else
			begin
				case (lcd_init_states)
					lcd_init_rst:
						begin
							// Wait for 15ms to power-up LCD
							time_wait_lcd_init <= 15000000;
							lcd_init_states <= lcd_init_wait;
							lcd_init_state_next <= lcd_init_write_03_01;
						end
					
					// Wait for a configured time in (ns) and go to other state in (lcd_init_state_next)
					lcd_init_wait:
						begin
							counter_wait_lcd_init <= counter_wait_lcd_init + period_clk_ns;
							if (counter_wait_lcd_init >= time_wait_lcd_init)
								begin
									lcd_init_states <= lcd_init_state_next;
									counter_wait_lcd_init <= 0;
								end
						end
					
					// Strobe the LCD for at least 240 ns
					lcd_init_strobe:
						begin
							// We need to wait at least 40ns to stabilize the data before strobing the data... 
							counter_wait_stabilize_lcd_init <= counter_wait_stabilize_lcd_init + period_clk_ns;
							if (counter_wait_stabilize_lcd_init >= 40)
								begin
									lcd_init_e_out <= 1;
									
									// After we got a strobe high hold for more 240 ns
									counter_wait_strobe_lcd_init <= counter_wait_strobe_lcd_init + period_clk_ns;
									if (counter_wait_strobe_lcd_init >= 240)
										begin
											lcd_init_states <= lcd_init_state_next;
											counter_wait_stabilize_lcd_init <= 0;
											counter_wait_strobe_lcd_init <= 0;
											lcd_init_e_out <= 0;
										end
								end																			
						end
					
					lcd_init_write_03_01:
						// Send 0x3 and pulse LCD_E for 240ns 
						begin
							lcd_init_data_out <= 4'h3;
							lcd_init_states <= lcd_init_strobe;	// Strobe for at least 230 ns						
							lcd_init_state_next <= lcd_init_wait_4ms;							
						end
					
					lcd_init_wait_4ms:
						begin
							time_wait_lcd_init <= 4100000;	// Wait for 4.1ms
							lcd_init_states <= lcd_init_wait;
							lcd_init_state_next <= lcd_init_write_03_02;
						end
					
					lcd_init_write_03_02:
						// Send 0x3 and pulse LCD_E for 240ns 
						begin
							lcd_init_data_out <= 4'h3;
							lcd_init_states <= lcd_init_strobe;	// Strobe for at least 230 ns						
							lcd_init_state_next <= lcd_init_wait_100us;							
						end
					
					lcd_init_wait_100us:
						begin
							time_wait_lcd_init <= 100000;	// Wait for 100us
							lcd_init_states <= lcd_init_wait;
							lcd_init_state_next <= lcd_init_write_03_03;
						end
					
					lcd_init_write_03_03:
						// Send 0x3 and pulse LCD_E for 240ns 
						begin
							lcd_init_data_out <= 4'h3;
							lcd_init_states <= lcd_init_strobe;	// Strobe for at least 230 ns						
							lcd_init_state_next <= lcd_init_wait_40us;							
						end
					
					lcd_init_wait_40us:
						begin
							time_wait_lcd_init <= 40000;	// Wait for 40us
							lcd_init_states <= lcd_init_wait;
							lcd_init_state_next <= lcd_init_write_02;
						end
					
					lcd_init_write_02:
						// Send 0x2 and pulse LCD_E for 240ns 
						begin
							lcd_init_data_out <= 4'h2;
							lcd_init_states <= lcd_init_strobe;	// Strobe for at least 230 ns						
							lcd_init_state_next <= lcd_init_wait_50us;							
						end
					
					lcd_init_wait_50us:
						begin
							time_wait_lcd_init <= 50000;	// Wait for 50us
							lcd_init_states <= lcd_init_wait;
							lcd_init_state_next <= lcd_init_state_done;							
						end
					
					lcd_init_state_done:
						begin
							lcd_init_done <= 1;
							lcd_init_state_next <= lcd_init_state_done;
						end
				endcase
			end
	end
	
	// On the most cases you can only write to the display...
	assign lcd_rw = 0;
	assign lcd_rs = rs_in;
	assign disable_flash = 1;
	
	// Will assign the output of the FSM init or the FSM data depending if initialization is already done
	assign lcd_e = (!lcd_init_done) ? lcd_init_e_out : lcd_data_e_out;
	assign lcd_nibble = (!lcd_init_done) ? lcd_init_data_out : lcd_data_data_out ;	
	
	/*
		FSM that deals to send data to the LCD (nibble High + nibble Low)
	*/
	always @ (posedge clk)
	begin
		if (~lcd_init_done)
			begin
				lcd_data_e_out <= 0;
				lcd_data_data_out <= 0;
				lcd_data_states <= lcd_data_rst;
				done <= 0; 
				counter_wait_stabilize_lcd_data <= 0;
				counter_wait_lcd_data <= 0;
				counter_wait_strobe_lcd_data <= 0;
			end
		else
			begin
				case (lcd_data_states)
					lcd_data_rst:
						begin
							done <= 0;
							// Start to send data when strobe_in =1
							if (strobe_in == 1)
								begin
									lcd_data_states <= lcd_data_wr_nibble_high;
								end 
							else
								lcd_data_states <= lcd_data_rst;
						end
					
					lcd_data_wr_nibble_high:
						begin
							// First send the high nibble
							lcd_data_data_out <= data_in[7:4];
							lcd_data_states <= lcd_data_strobe;
							lcd_data_state_next <= lcd_data_wait_1us;							
						end
					
					lcd_data_strobe:
						begin
							// We need to wait at least 40ns to stabilize the data before strobing the data... 
							counter_wait_stabilize_lcd_data <= counter_wait_stabilize_lcd_data + period_clk_ns;
							if (counter_wait_stabilize_lcd_data >= 40)
								begin
									lcd_data_e_out <= 1;
									
									// After we got a strobe high hold for more 240 ns
									counter_wait_strobe_lcd_data <= counter_wait_strobe_lcd_data + period_clk_ns;
									if (counter_wait_strobe_lcd_data >= 240)
										begin
											lcd_data_states <= lcd_data_state_next;
											counter_wait_stabilize_lcd_data <= 0;
											counter_wait_strobe_lcd_data <= 0;
											lcd_data_e_out <= 0;
										end
								end
						end
					
					// Wait for 1us before sending the low nibble
					lcd_data_wait_1us:
						begin
							counter_wait_lcd_data <= counter_wait_lcd_data + period_clk_ns;
							if (counter_wait_lcd_data >= 1000)
								begin
									lcd_data_states <= lcd_data_wr_nibble_low;
									counter_wait_lcd_data <= 0;
								end
						end
						
					lcd_data_wr_nibble_low:
						begin
							// After send the low nibble
							lcd_data_data_out <= data_in[3:0];
							lcd_data_states <= lcd_data_strobe;
							lcd_data_state_next <= lcd_data_wait_40us;							
						end
					
					// Wait for 40us before sending the next byte
					lcd_data_wait_40us:
						begin
							counter_wait_lcd_data <= counter_wait_lcd_data + period_clk_ns;
							if (counter_wait_lcd_data >= 40000)
								begin
									lcd_data_states <= lcd_data_done;
									counter_wait_lcd_data <= 0;
								end
						end
					
					lcd_data_done:
						begin
							// Signal that we done sending the data
							done <= 1;
							lcd_data_states <= lcd_data_rst;
						end
					
				endcase
			end
	end

endmodule
