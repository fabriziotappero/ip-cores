`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Original Design by Joshua Wise 
// 
// http://joshuawise.com/
// http://git.joshuawise.com/vterm.git/
// Create Date:    21:54:03 02/16/2011 
// Design Name: 
// Module Name:    PS2 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - Got Joshua Wise PS2 Controller Code
// Revision 0.02 - Modified to ABNT2 Keyboard
// Revision 0.03 - Correct a few bugs
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module PS2(
		 input clk,
		 input ps2clk,
		 input ps2data,
		 output write,
		 output [7:0] dataout,
		 output mod_led
    );
		reg [3:0] bitcount = 0;
		reg [7:0] key = 0;
		reg keyarrow = 0, keyup = 0, parity = 0;
		reg wr = 0;
		reg [7:0] data = 0;
		/* Clock debouncing */
		reg lastinclk = 0;
		reg [6:0] debounce = 0;
		reg fixedclk = 0;
		reg [11:0] resetcountdown = 0;
		
		reg [6:0] unshiftedrom [127:0];	initial $readmemh("MemoryInit/scancodes_abnt2mi.list", unshiftedrom);
		reg [6:0] shiftedrom [127:0];	initial $readmemh("MemoryInit/scancodes_abnt2ma.list", shiftedrom);
		
		reg mod_lshift = 0;
		reg mod_rshift = 0;
		reg mod_capslock = 0;
		wire mod_shifted = (mod_lshift | mod_rshift) ^ mod_capslock;
		
		reg nd = 0;
		reg lastnd = 0;
		
		always @(posedge clk) begin
			if (ps2clk != lastinclk) begin
					lastinclk 		<= ps2clk;
					debounce 		<= 1;
					resetcountdown <= 12'b111111111111;
			end else if (debounce == 0) begin
					fixedclk 		<= ps2clk;
					resetcountdown <= resetcountdown - 1;
			end else
					debounce 		<= debounce + 1;
			
			if (nd ^ lastnd) begin
					lastnd 			<= nd;
					wr 				<= 1;
			end else
					wr 				<= 0;
		end

		always @(negedge fixedclk) begin
			if (resetcountdown == 0)
					bitcount 		<= 0;
			else if (bitcount == 10) begin
					bitcount 		<= 0;
				if(parity != (^ key)) begin
						if(keyarrow) begin
								casex(key)
									8'hF0: keyup <= 1;
									8'hxx: keyarrow <= 0;
								endcase
						end
					else begin
						if(keyup) begin
								keyup 			<= 0;
								keyarrow 		<= 0;
								casex (key)
												8'h12: mod_lshift <= 0;
												8'h59: mod_rshift <= 0;
								endcase
								// handle this? I don't fucking know
						end
						else begin
							casex(key)
											8'hE0: keyarrow 			<= 1;	// handle these? I don't fucking know
											8'hF0: keyup 				<= 1;
											8'h12: mod_lshift 		<= 1;
											8'h59: mod_rshift 		<= 1;
											8'h58: mod_capslock 		<= ~mod_capslock;
											8'b0xxxxxxx: begin nd 	<= ~nd; data <= mod_shifted ? shiftedrom[key] : unshiftedrom[key]; end
											//8'b0xxxxxxx: begin nd <= ~nd; data <= key; end // Use isso para mostrar os ScanCodes
											8'b1xxxxxxx: begin /* Nada */ end
							endcase
						end
					end
				end
				else begin
						keyarrow 	<= 0;
						keyup 		<= 0;
				end
			end else
					bitcount 	<= bitcount + 1;

			case(bitcount)
								1: key[0] <= ps2data;
								2: key[1] <= ps2data;
								3: key[2] <= ps2data;
								4: key[3] <= ps2data;
								5: key[4] <= ps2data;
								6: key[5] <= ps2data;
								7: key[6] <= ps2data;
								8: key[7] <= ps2data;
								9: parity <= ps2data;
			endcase
		end

	assign write 	= wr;
	assign dataout = data;
	assign mod_led = mod_shifted;
endmodule
