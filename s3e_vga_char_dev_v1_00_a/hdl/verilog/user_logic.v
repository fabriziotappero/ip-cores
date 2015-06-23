`include "SVGA_DEFINES.v"

//----------------------------------------------------------------------------
// user_logic.v - module
//----------------------------------------------------------------------------
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//----------------------------------------------------------------------------
// Filename:          user_logic.v
// Version:           1.00.a
// Description:       User logic module.
// Date:              Wed Sep 12 16:22:49 2007 (by Create and Import Peripheral Wizard)
// Verilog Standard:  Verilog-2001
//----------------------------------------------------------------------------
// Naming Conventions:
//   active low signals:                    "*_n"
//   clock signals:                         "clk", "clk_div#", "clk_#x"
//   reset signals:                         "rst", "rst_n"
//   generics:                              "C_*"
//   user defined types:                    "*_TYPE"
//   state machine next state:              "*_ns"
//   state machine current state:           "*_cs"
//   combinatorial signals:                 "*_com"
//   pipelined or register delay signals:   "*_d#"
//   counter signals:                       "*cnt*"
//   clock enable signals:                  "*_ce"
//   internal version of output port:       "*_i"
//   device pins:                           "*_pin"
//   ports:                                 "- Names begin with Uppercase"
//   processes:                             "*_PROCESS"
//   component instantiations:              "<ENTITY_>I_<#|FUNC>"
//----------------------------------------------------------------------------

module user_logic
(
  // -- ADD USER PORTS BELOW THIS LINE ---------------
  // --USER ports added here 
  fifty_clock_in,
  VGA_HSYNCH,
  VGA_VSYNCH,
  VGA_OUT_RED,
  VGA_OUT_GREEN,
  VGA_OUT_BLUE,
  // -- ADD USER PORTS ABOVE THIS LINE ---------------

  // -- DO NOT EDIT BELOW THIS LINE ------------------
  // -- Bus protocol ports, do not add to or delete 
  Bus2IP_Clk,                     // Bus to IP clock
  Bus2IP_Reset,                   // Bus to IP reset
  Bus2IP_Data,                    // Bus to IP data bus for user logic
  Bus2IP_BE,                      // Bus to IP byte enables for user logic
  Bus2IP_RdCE,                    // Bus to IP read chip enable for user logic
  Bus2IP_WrCE,                    // Bus to IP write chip enable for user logic
  IP2Bus_Data,                    // IP to Bus data bus for user logic
  IP2Bus_Ack,                     // IP to Bus acknowledgement
  IP2Bus_Retry,                   // IP to Bus retry response
  IP2Bus_Error,                   // IP to Bus error response
  IP2Bus_ToutSup                  // IP to Bus timeout suppress
  // -- DO NOT EDIT ABOVE THIS LINE ------------------
); // user_logic

// -- ADD USER PARAMETERS BELOW THIS LINE ------------
// --USER parameters added here 
// -- ADD USER PARAMETERS ABOVE THIS LINE ------------

// -- DO NOT EDIT BELOW THIS LINE --------------------
// -- Bus protocol parameters, do not add to or delete
parameter C_DWIDTH                       = 32;
parameter C_NUM_CE                       = 2;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

// -- ADD USER PORTS BELOW THIS LINE -----------------
// --USER ports added here 
input fifty_clock_in;
output VGA_HSYNCH;
output VGA_VSYNCH;
output VGA_OUT_RED;
output VGA_OUT_GREEN;
output VGA_OUT_BLUE;
// -- ADD USER PORTS ABOVE THIS LINE -----------------

// -- DO NOT EDIT BELOW THIS LINE --------------------
// -- Bus protocol ports, do not add to or delete
input                                     Bus2IP_Clk;
input                                     Bus2IP_Reset;
input      [0 : C_DWIDTH-1]               Bus2IP_Data;
input      [0 : C_DWIDTH/8-1]             Bus2IP_BE;
input      [0 : C_NUM_CE-1]               Bus2IP_RdCE;
input      [0 : C_NUM_CE-1]               Bus2IP_WrCE;
output     [0 : C_DWIDTH-1]               IP2Bus_Data;
output                                    IP2Bus_Ack;
output                                    IP2Bus_Retry;
output                                    IP2Bus_Error;
output                                    IP2Bus_ToutSup;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

//----------------------------------------------------------------------------
// Implementation
//----------------------------------------------------------------------------

  // --USER nets declarations added here, as needed for user logic

  // Nets for user logic slave model s/w accessible register example
  reg        [0 : C_DWIDTH-1]               slv_reg0;
  reg        [0 : C_DWIDTH-1]               slv_reg1;
  wire       [0 : 1]                        slv_reg_write_select;
  wire       [0 : 1]                        slv_reg_read_select;
  reg        [0 : C_DWIDTH-1]               slv_ip2bus_data;
  wire                                      slv_read_ack;
  wire                                      slv_write_ack;
  integer                                   byte_index, bit_index;

  // --USER logic implementation added here

  // ------------------------------------------------------
  // Example code to read/write user logic slave model s/w accessible registers
  // 
  // Note:
  // The example code presented here is to show you one way of reading/writing
  // software accessible registers implemented in the user logic slave model.
  // Each bit of the Bus2IP_WrCE/Bus2IP_RdCE signals is configured to correspond
  // to one software accessible register by the top level template. For example,
  // if you have four 32 bit software accessible registers in the user logic, you
  // are basically operating on the following memory mapped registers:
  // 
  //    Bus2IP_WrCE or   Memory Mapped
  //       Bus2IP_RdCE   Register
  //            "1000"   C_BASEADDR + 0x0
  //            "0100"   C_BASEADDR + 0x4
  //            "0010"   C_BASEADDR + 0x8
  //            "0001"   C_BASEADDR + 0xC
  // 
  // ------------------------------------------------------
  
  assign
    slv_reg_write_select = Bus2IP_WrCE[0:1],
    slv_reg_read_select  = Bus2IP_RdCE[0:1],
    slv_write_ack        = Bus2IP_WrCE[0] || Bus2IP_WrCE[1],
    slv_read_ack         = Bus2IP_RdCE[0] || Bus2IP_RdCE[1];

  // implement slave model register(s)
  always @( posedge Bus2IP_Clk )
    begin: SLAVE_REG_WRITE_PROC

      if ( Bus2IP_Reset == 1 )
        begin
          slv_reg0 <= 0;
          slv_reg1 <= 0;
        end
      else
        case ( slv_reg_write_select )
          2'b10 :
            for ( byte_index = 0; byte_index <= (C_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg0[bit_index] <= Bus2IP_Data[bit_index];
          2'b01 :
            for ( byte_index = 0; byte_index <= (C_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg1[bit_index] <= Bus2IP_Data[bit_index];
          default : ;
        endcase

    end // SLAVE_REG_WRITE_PROC

  // implement slave model register read mux
  always @( slv_reg_read_select or slv_reg0 or slv_reg1 )
    begin: SLAVE_REG_READ_PROC

      case ( slv_reg_read_select )
        2'b10 : slv_ip2bus_data <= slv_reg0;
        2'b01 : slv_ip2bus_data <= slv_reg1;
        default : slv_ip2bus_data <= 0;
      endcase

    end // SLAVE_REG_READ_PROC

  // ------------------------------------------------------------
  // Example code to drive IP to Bus signals
  // ------------------------------------------------------------

  assign IP2Bus_Data        = slv_ip2bus_data;
  assign IP2Bus_Ack         = slv_write_ack || slv_read_ack;
  assign IP2Bus_Error       = 0;
  assign IP2Bus_Retry       = 0;
  assign IP2Bus_ToutSup     = 0;
  
  S3E_VGA_CHAR_DEVICE S3E_VGA_CHAR_DEVICE(.SYSTEM_CLOCK(fifty_clock_in), .VGA_HSYNCH(VGA_HSYNCH), 
		.VGA_VSYNCH(VGA_VSYNCH), .VGA_OUT_RED(VGA_OUT_RED), .VGA_OUT_GREEN(VGA_OUT_GREEN), 
		.VGA_OUT_BLUE(VGA_OUT_BLUE), .address(slv_reg0[0:13]), .character(slv_reg0[14:25]), .loadit(1));

endmodule

//------------------------------------------------------------------------

module S3E_VGA_CHAR_DEVICE
(
SYSTEM_CLOCK,

VGA_HSYNCH,
VGA_VSYNCH,
VGA_OUT_RED,
VGA_OUT_GREEN,
VGA_OUT_BLUE,

address,
character,
loadit
);

input				SYSTEM_CLOCK;				// 100MHz LVTTL SYSTEM CLOCK

output 			VGA_HSYNCH;					// horizontal sync for the VGA output connector
output			VGA_VSYNCH;					// vertical sync for the VGA output connector
output		 	VGA_OUT_RED;				// RED DAC data
output		 	VGA_OUT_GREEN;				// GREEN DAC data
output		 	VGA_OUT_BLUE;				// BLUE DAC data

input [13:0] address;
input [11:0] character;
input loadit;

wire				system_clock_buffered;	// buffered SYSTEM CLOCK
wire				pixel_clock;				// generated from SYSTEM CLOCK
wire				reset;						// reset asserted when DCMs are NOT LOCKED

wire				vga_red_data;				// red video data
wire				vga_green_data;			// green video data
wire				vga_blue_data;				// blue video data

// internal video timing signals
wire 				h_synch;						// horizontal synch for VGA connector
wire 				v_synch;						// vertical synch for VGA connector
wire 				blank;						// composite blanking
wire [10:0]		pixel_count;				// bit mapped pixel position within the line
wire [9:0]		line_count;					// bit mapped line number in a frame lines within the frame
wire [2:0]		subchar_pixel;				// pixel position within the character
wire [2:0]		subchar_line;				// identifies the line number within a character block
wire [6:0]		char_column;				// character number on the current line
wire [6:0]		char_line;					// line number on the screen

// instantiate the character generator
CHAR_DISPLAY CHAR_DISPLAY
(
char_column,
char_line,
subchar_line,
subchar_pixel,
pixel_clock,
reset,
vga_red_data,
vga_green_data,
vga_blue_data,
address,
character,
loadit
);

// instantiate the clock generation module
CLOCK_GEN CLOCK_GEN 
(
SYSTEM_CLOCK,
system_clock_buffered,
pixel_clock,
reset
);

// instantiate the video timing generator
SVGA_TIMING_GENERATION SVGA_TIMING_GENERATION
(
pixel_clock,
reset,
h_synch,
v_synch,
blank,
pixel_count,
line_count,
subchar_pixel,
subchar_line,
char_column,
char_line
);

// instantiate the video output mux
VIDEO_OUT VIDEO_OUT
(
pixel_clock,
reset,
vga_red_data,
vga_green_data,
vga_blue_data,
h_synch,
v_synch,
blank,

VGA_HSYNCH,
VGA_VSYNCH,
VGA_OUT_RED,
VGA_OUT_GREEN,
VGA_OUT_BLUE
);

endmodule // MAIN

//---------------------------------------------------------

module CHAR_DISPLAY
(
char_column,
char_line,
subchar_line,
subchar_pixel,
pixel_clock,
reset,
vga_red_data,
vga_green_data,
vga_blue_data,
address,
character,
loadit
);

input [6:0]		char_column;		// character number on the current line
input [6:0]		char_line;			// line number on the screen
input [2:0]		subchar_line;		// the line number within a character block 0-8
input [2:0]		subchar_pixel;		// the pixel number within a character block 0-8
input				pixel_clock;
input				reset;
output 			vga_red_data;
output 			vga_green_data;
output 			vga_blue_data;

input [13:0] address;
input [11:0] character;
input loadit;

//// Label Definitions ////

// Note: all labels must match their defined length--shorter labels will be padded with solid blocks,
// and longer labels will be truncated

wire				write_enable;			// character memory is written to on a clock rise when high
assign write_enable = loadit;

// The character write address
reg [13:0] 	char_addr;

//wire [13:0] 	my_char_read_addr = {char_line[6:0], char_column[6:0]};
//wire [13:0] 	my_char_read_addr = {char_line[6:0], char_column[5:0]};
wire [13:0] 	my_char_read_addr = (char_line[6:0] * 75) + char_column[6:0];

wire				pixel_on;				// high => output foreground color, low => output background color
reg [13:0] 		char_write_data;		// the data that will be written to character memory at the clock rise
reg				char_addr_is_0;

reg [3:0]		hex;						// the 4 bit value to be converted into ASCII
wire [7:0]		ascii;					// the result of the conversion to ASCII
integer			i, ii;					// iterators

wire fore_red;
wire fore_green;
wire fore_blue;
wire back_red;
wire back_green;
wire back_blue;

// write the appropriate character data to memory
always @ (char_line or char_column) begin
	char_write_data <= character;
	char_addr <= address[13:0];
end


wire				background_red;		// the red component of the background color
wire				background_green;		// the green component of the background color
wire				background_blue;		// the blue component of the background color
wire				foreground_red;		// the red component of the foreground color
wire				foreground_green;		// the green component of the foreground color
wire				foreground_blue;		// the blue component of the foreground color

// use the result of the character generator module to choose between the foreground and background color
assign vga_red_data = (pixel_on) ? foreground_red : background_red;
assign vga_green_data = (pixel_on) ? foreground_green : background_green;
assign vga_blue_data = (pixel_on) ? foreground_blue : background_blue;

assign foreground_red = (back_red) ? 0 : fore_red;			// If the invert signal is 1, then foreground is 0
assign foreground_green = (back_red) ? 0 : fore_green;
assign foreground_blue = (back_red) ? 0 : fore_blue;

assign background_red = (back_red) ? fore_red : 0;			// If invert is 1, then the background is the values passed
assign background_green = (back_red) ? fore_green : 0;
assign background_blue = (back_red) ? fore_blue : 0;

// the character generator block includes the character RAM
// and the character generator ROM
CHAR_GEN CHAR_GEN
(
reset,				// reset signal
char_addr,			// write address
char_write_data,	// write data
write_enable,		// write enable
pixel_clock,		// write clock
my_char_read_addr,// read address of current character
subchar_line,		// current line of pixels within current character
subchar_pixel,		// current column of pixels withing current character
pixel_clock,		// read clock
pixel_on,			// read data
fore_red,
fore_green,
fore_blue,
back_red,
back_green,
back_blue
);

endmodule //CHAR_DISPLAY

//-------------------------------------------------------

module CHAR_GEN(
// control
reset,
// write side
char_write_addr,
char_write_data,
char_write_enable,
char_write_clock,
// read side
char_address,
subchar_line,
subchar_pixel,
pixel_clock,
pixel_on,

fore_red,
fore_green,
fore_blue,
back_red,
back_green,
back_blue
);

input				pixel_clock;
input				reset;
input [2:0]  	subchar_line;			// line number within 8 line block
input [13:0] 	char_address;			// character address "0" is upper left character
input [2:0]  	subchar_pixel;			// pixel position within 8 pixel block
input [13:0]   char_write_addr;
input [11:0] 	char_write_data;
input				char_write_enable;
input 			char_write_clock;
output			pixel_on;

output fore_red;
output fore_green;
output fore_blue;
output back_red;
output back_green;
output back_blue;

reg 				latch_data;
reg 				latch_low_data;
reg 				shift_high;
reg 				shift_low;
reg [3:0] 		latched_low_char_data;
reg [7:0] 		latched_char_data;
reg 				pixel_on;

wire [11:0] 		ascii_code;
wire [10:0] 	chargen_rom_address = {ascii_code[7:0], subchar_line[2:0]};
wire [7:0] 		char_gen_rom_data;
 
// instantiate the CHARACTER RAM
CHAR_RAM CHAR_RAM
(
char_write_clock,
char_write_enable,
char_write_addr,
char_write_data,

pixel_clock,
char_address,
ascii_code
);

//assign back_red = ascii_code[10];
//assign back_green = ascii_code[9];
//assign back_blue = ascii_code[8];

//assign back_red = 0;
assign back_green = 0;
assign back_blue = 0;

assign fore_red = ascii_code[8];
assign fore_green = ascii_code[9];
assign fore_blue = ascii_code[10];
assign back_red = ascii_code[11];

// instantiate the character generator ROM
CHAR_GEN_ROM CHAR_GEN_ROM
(
pixel_clock,
chargen_rom_address,
char_gen_rom_data
);

// LATCH THE CHARTACTER DATA FROM THE CHAR GEN ROM AND CREATE A SERIAL CHAR DATA STREAM
always @ (posedge pixel_clock or posedge reset)begin
			if (reset) begin
				latch_data <= 1'b0;
				end
			else if (subchar_pixel == 3'b110) begin
				latch_data <= 1'b1;
				end
			else if (subchar_pixel == 3'b111) begin
				latch_data <= 1'b0;
				end
			end

always @ (posedge pixel_clock or posedge reset)begin
			if (reset) begin
				latch_low_data <= 1'b0;
				end
			else if (subchar_pixel == 3'b010) begin
				latch_low_data <= 1'b1;
				end
			else if (subchar_pixel == 3'b011) begin
				latch_low_data <= 1'b0;
				end
			end

always @ (posedge pixel_clock or posedge reset)begin
			if (reset) begin
				shift_high <= 1'b1;
				end
			else if (subchar_pixel == 3'b011) begin
				shift_high <= 1'b0;
				end
			else if (subchar_pixel == 3'b111) begin
				shift_high <= 1'b1;
				end
			end

always @ (posedge pixel_clock or posedge reset)begin
			if (reset) begin
				shift_low <= 1'b0;
				end
			else if (subchar_pixel == 3'b011) begin
				shift_low <= 1'b1;
				end
			else if (subchar_pixel == 3'b111) begin
				shift_low <= 1'b0;
				end
			end

// serialize the CHARACTER MODE data
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
 		begin
			pixel_on = 1'b0;
			latched_low_char_data = 4'h0;
			latched_char_data  = 8'h00;
		end

	else if (shift_high)
		begin
			pixel_on = latched_char_data [7];
			latched_char_data [7] = latched_char_data [6];
			latched_char_data [6] = latched_char_data [5];
			latched_char_data [5] = latched_char_data [4];
			latched_char_data [4] = latched_char_data [7];
				if(latch_low_data) begin
					latched_low_char_data [3:0] = latched_char_data [3:0];
					end
				else begin
					latched_low_char_data [3:0] = latched_low_char_data [3:0];
					end
			end

	else if (shift_low)
		begin
			pixel_on = latched_low_char_data [3];
			latched_low_char_data [3] = latched_low_char_data [2];
			latched_low_char_data [2] = latched_low_char_data [1];
			latched_low_char_data [1] = latched_low_char_data [0];
			latched_low_char_data [0] = latched_low_char_data [3];
				if (latch_data) begin
					latched_char_data [7:0] = char_gen_rom_data[7:0];
					end
				else begin
					latched_char_data [7:0] = latched_char_data [7:0];
					end
				end
	 else 
	 	begin
		latched_low_char_data [3:0] = latched_low_char_data [3:0];
		latched_char_data [7:0] = latched_char_data [7:0];
		pixel_on = pixel_on;
		end
	end

endmodule //CHAR_GEN

//--------------------------------------------------------------

/*
-------------------------------------------
Code  00h     defines a solid block
Codes 01h-04h define block graphics
Codes 05h-1Fh define line graphics		
Codes 20h-7Eh define the ASCII characters
Code  7Fh     defines a hash pattern
Codes 80h-FFh user defined characters
-------------------------------------------
*/

module CHAR_GEN_ROM
(
pixel_clock,
address,
data
);

input				pixel_clock;
input [10:0]	address;
output reg [7:0] 	data;

always @(posedge pixel_clock) begin
	case(address)
	
		//// Solid Block ////
		
		// 00h: solid block
		11'h000: data <= 8'hFF;
		11'h001: data <= 8'hFF;
		11'h002: data <= 8'hFF;
		11'h003: data <= 8'hFF;
		11'h004: data <= 8'hFF;
		11'h005: data <= 8'hFF;
		11'h006: data <= 8'hFF;
		11'h007: data <= 8'hFF;
		
		//// Block graphics ////
		
		// 01h: Left block up, right block down
		11'h008: data <= 8'hF0;
		11'h009: data <= 8'hF0;
		11'h00A: data <= 8'hF0;
		11'h00B: data <= 8'hF0;
		11'h00C: data <= 8'h0F;
		11'h00D: data <= 8'h0F;
		11'h00E: data <= 8'h0F;
		11'h00F: data <= 8'h0F;
		// 02h: Left block down, right block up
		11'h010: data <= 8'h0F;
		11'h011: data <= 8'h0F;
		11'h012: data <= 8'h0F;
		11'h013: data <= 8'h0F;
		11'h014: data <= 8'hF0;
		11'h015: data <= 8'hF0;
		11'h016: data <= 8'hF0;
		11'h017: data <= 8'hF0;
		// 03h: Both blocks down
		11'h018: data <= 8'h00;
		11'h019: data <= 8'h00;
		11'h01A: data <= 8'h00;
		11'h01B: data <= 8'h00;
		11'h01C: data <= 8'hFF;
		11'h01D: data <= 8'hFF;
		11'h01E: data <= 8'hFF;
		11'h01F: data <= 8'hFF;
		// 04h: Both blocks up
		11'h020: data <= 8'hFF;
		11'h021: data <= 8'hFF;
		11'h022: data <= 8'hFF;
		11'h023: data <= 8'hFF;
		11'h024: data <= 8'h00;
		11'h025: data <= 8'h00;
		11'h026: data <= 8'h00;
		11'h027: data <= 8'h00;
		
		//// Line Graphics ////
		
		// 05h: corner upper left
		11'h028: data <= 8'hFF;
		11'h029: data <= 8'h80;
		11'h02A: data <= 8'h80;
		11'h02B: data <= 8'h80;
		11'h02C: data <= 8'h80;
		11'h02D: data <= 8'h80;
		11'h02E: data <= 8'h80;
		11'h02F: data <= 8'h80;
		// 06h: corner upper right
		11'h030: data <= 8'hFF;
		11'h031: data <= 8'h01;
		11'h032: data <= 8'h01;
		11'h033: data <= 8'h01;
		11'h034: data <= 8'h01;
		11'h035: data <= 8'h01;
		11'h036: data <= 8'h01;
		11'h037: data <= 8'h01;
		// 07h: corner lower left
		11'h038: data <= 8'h80;
		11'h039: data <= 8'h80;
		11'h03A: data <= 8'h80;
		11'h03B: data <= 8'h80;
		11'h03C: data <= 8'h80;
		11'h03D: data <= 8'h80;
		11'h03E: data <= 8'h80;
		11'h03F: data <= 8'hFF;
		// 08h: corner lower right
		11'h040: data <= 8'h01;
		11'h041: data <= 8'h01;
		11'h042: data <= 8'h01;
		11'h043: data <= 8'h01;
		11'h044: data <= 8'h01;
		11'h045: data <= 8'h01;
		11'h046: data <= 8'h01;
		11'h047: data <= 8'hFF;
		// 09h: cross junction
		11'h048: data <= 8'h10;
		11'h049: data <= 8'h10;
		11'h04A: data <= 8'h10;
		11'h04B: data <= 8'hFF;
		11'h04C: data <= 8'h10;
		11'h04D: data <= 8'h10;
		11'h04E: data <= 8'h10;
		11'h04F: data <= 8'h10;
		// 0Ah: "T" junction
		11'h050: data <= 8'hFF;
		11'h051: data <= 8'h10;
		11'h052: data <= 8'h10;
		11'h053: data <= 8'h10;
		11'h054: data <= 8'h10;
		11'h055: data <= 8'h10;
		11'h056: data <= 8'h10;
		11'h057: data <= 8'h10;
		// 0Bh: "T" juntion rotated 90 clockwise
		11'h058: data <= 8'h01;
		11'h059: data <= 8'h01;
		11'h05A: data <= 8'h01;
		11'h05B: data <= 8'hFF;
		11'h05C: data <= 8'h01;
		11'h05D: data <= 8'h01;
		11'h05E: data <= 8'h01;
		11'h05F: data <= 8'h01;
		// 0Ch: "T" juntion rotated 180
		11'h060: data <= 8'h10;
		11'h061: data <= 8'h10;
		11'h062: data <= 8'h10;
		11'h063: data <= 8'h10;
		11'h064: data <= 8'h10;
		11'h065: data <= 8'h10;
		11'h066: data <= 8'h10;
		11'h067: data <= 8'hFF;
		// 0Dh: "T" junction rotated 270 clockwise
		11'h068: data <= 8'h80;
		11'h069: data <= 8'h80;
		11'h06A: data <= 8'h80;
		11'h06B: data <= 8'hFF;
		11'h06C: data <= 8'h80;
		11'h06D: data <= 8'h80;
		11'h06E: data <= 8'h80;
		11'h06F: data <= 8'h80;
		// 0Eh: arrow pointing right
		11'h070: data <= 8'h08;
		11'h071: data <= 8'h04;
		11'h072: data <= 8'h02;
		11'h073: data <= 8'hFF;
		11'h074: data <= 8'h02;
		11'h075: data <= 8'h04;
		11'h076: data <= 8'h08;
		11'h077: data <= 8'h00;
		// 0Fh: arrow pointing left
		11'h078: data <= 8'h10;
		11'h079: data <= 8'h20;
		11'h07A: data <= 8'h40;
		11'h07B: data <= 8'hFF;
		11'h07C: data <= 8'h40;
		11'h07D: data <= 8'h20;
		11'h07E: data <= 8'h10;
		11'h07F: data <= 8'h00;
		// 10h: first (top) horizontal line
		11'h080: data <= 8'hFF;
		11'h081: data <= 8'h00;
		11'h082: data <= 8'h00;
		11'h083: data <= 8'h00;
		11'h084: data <= 8'h00;
		11'h085: data <= 8'h00;
		11'h086: data <= 8'h00;
		11'h087: data <= 8'h00;
		// 11h: second horizontal line
		11'h088: data <= 8'h00;
		11'h089: data <= 8'hFF;
		11'h08A: data <= 8'h00;
		11'h08B: data <= 8'h00;
		11'h08C: data <= 8'h00;
		11'h08D: data <= 8'h00;
		11'h08E: data <= 8'h00;
		11'h08F: data <= 8'h00;
		// 12h: third horizontal line
		11'h090: data <= 8'h00;
		11'h091: data <= 8'h00;
		11'h092: data <= 8'hFF;
		11'h093: data <= 8'h00;
		11'h094: data <= 8'h00;
		11'h095: data <= 8'h00;
		11'h096: data <= 8'h00;
		11'h097: data <= 8'h00;
		// 13h: fourth horizontal line
		11'h098: data <= 8'h00;
		11'h099: data <= 8'h00;
		11'h09A: data <= 8'h00;
		11'h09B: data <= 8'hFF;
		11'h09C: data <= 8'h00;
		11'h09D: data <= 8'h00;
		11'h09E: data <= 8'h00;
		11'h09F: data <= 8'h00;
		// 14h: fifth horizontal line
		11'h0A0: data <= 8'h00;
		11'h0A1: data <= 8'h00;
		11'h0A2: data <= 8'h00;
		11'h0A3: data <= 8'h00;
		11'h0A4: data <= 8'hFF;
		11'h0A5: data <= 8'h00;
		11'h0A6: data <= 8'h00;
		// 15h: sixth horizontal line
		11'h0A7: data <= 8'h00;
		11'h0A8: data <= 8'h00;
		11'h0A9: data <= 8'h00;
		11'h0AA: data <= 8'h00;
		11'h0AB: data <= 8'h00;
		11'h0AC: data <= 8'h00;
		11'h0AD: data <= 8'hFF;
		11'h0AE: data <= 8'h00;
		11'h0AF: data <= 8'h00;
		// 16h: seventh horizontal line
		11'h0B0: data <= 8'h00;
		11'h0B1: data <= 8'h00;
		11'h0B2: data <= 8'h00;
		11'h0B3: data <= 8'h00;
		11'h0B4: data <= 8'h00;
		11'h0B5: data <= 8'h00;
		11'h0B6: data <= 8'hFF;
		11'h0B7: data <= 8'h00;
		// 17h: eighth (bottom) horizontal line
		11'h0B8: data <= 8'h00;
		11'h0B9: data <= 8'h00;
		11'h0BA: data <= 8'h00;
		11'h0BB: data <= 8'h00;
		11'h0BC: data <= 8'h00;
		11'h0BD: data <= 8'h00;
		11'h0BE: data <= 8'h00;
		11'h0BF: data <= 8'hFF;
		// 18h: first (left) vertical line
		11'h0C0: data <= 8'h80;
		11'h0C1: data <= 8'h80;
		11'h0C2: data <= 8'h80;
		11'h0C3: data <= 8'h80;
		11'h0C4: data <= 8'h80;
		11'h0C5: data <= 8'h80;
		11'h0C6: data <= 8'h80;
		11'h0C7: data <= 8'h80;
		// 19h: second vertical line
		11'h0C8: data <= 8'h40;
		11'h0C9: data <= 8'h40;
		11'h0CA: data <= 8'h40;
		11'h0CB: data <= 8'h40;
		11'h0CC: data <= 8'h40;
		11'h0CD: data <= 8'h40;
		11'h0CE: data <= 8'h40;
		11'h0CF: data <= 8'h40;
		// 1Ah: third vertical line
		11'h0D0: data <= 8'h20;
		11'h0D1: data <= 8'h20;
		11'h0D2: data <= 8'h20;
		11'h0D3: data <= 8'h20;
		11'h0D4: data <= 8'h20;
		11'h0D5: data <= 8'h20;
		11'h0D6: data <= 8'h20;
		11'h0D7: data <= 8'h20;
		// 1Bh: fourth vertical line
		11'h0D8: data <= 8'h10;
		11'h0D9: data <= 8'h10;
		11'h0DA: data <= 8'h10;
		11'h0DB: data <= 8'h10;
		11'h0DC: data <= 8'h10;
		11'h0DD: data <= 8'h10;
		11'h0DE: data <= 8'h10;
		11'h0DF: data <= 8'h10;
		// 1Ch: fifth vertical line
		11'h0E0: data <= 8'h08;
		11'h0E1: data <= 8'h08;
		11'h0E2: data <= 8'h08;
		11'h0E3: data <= 8'h08;
		11'h0E4: data <= 8'h08;
		11'h0E5: data <= 8'h08;
		11'h0E6: data <= 8'h08;
		11'h0E7: data <= 8'h08;
		// 1Dh: sixth vertical line
		11'h0E8: data <= 8'h04;
		11'h0E9: data <= 8'h04;
		11'h0EA: data <= 8'h04;
		11'h0EB: data <= 8'h04;
		11'h0EC: data <= 8'h04;
		11'h0ED: data <= 8'h04;
		11'h0EE: data <= 8'h04;
		11'h0EF: data <= 8'h04;
		// 1Eh: seventh vertical line
		11'h0F0: data <= 8'h02;
		11'h0F1: data <= 8'h02;
		11'h0F2: data <= 8'h02;
		11'h0F3: data <= 8'h02;
		11'h0F4: data <= 8'h02;
		11'h0F5: data <= 8'h02;
		11'h0F6: data <= 8'h02;
		11'h0F7: data <= 8'h02;
		// 1Fh: eighth (right) vertical line
		11'h0F8: data <= 8'h01;
		11'h0F9: data <= 8'h01;
		11'h0FA: data <= 8'h01;
		11'h0FB: data <= 8'h01;
		11'h0FC: data <= 8'h01;
		11'h0FD: data <= 8'h01;
		11'h0FE: data <= 8'h01;
		11'h0FF: data <= 8'h01;
		
		//// ASCII Characters ////
		
		// 20h: space
		11'h100: data <= 8'h00;
		11'h101: data <= 8'h00;
		11'h102: data <= 8'h00;
		11'h103: data <= 8'h00;
		11'h104: data <= 8'h00;
		11'h105: data <= 8'h00;
		11'h106: data <= 8'h00;
		11'h107: data <= 8'h00;
		// 21h: !
		11'h108: data <= 8'h10;
		11'h109: data <= 8'h10;
		11'h10A: data <= 8'h10;
		11'h10B: data <= 8'h10;
		11'h10C: data <= 8'h00;
		11'h10D: data <= 8'h00;
		11'h10E: data <= 8'h10;
		11'h10F: data <= 8'h00;
		// 22h: "
		11'h110: data <= 8'h28;
		11'h111: data <= 8'h28;
		11'h112: data <= 8'h28;
		11'h113: data <= 8'h00;
		11'h114: data <= 8'h00;
		11'h115: data <= 8'h00;
		11'h116: data <= 8'h00;
		11'h117: data <= 8'h00;
		// 23h: #
		11'h118: data <= 8'h28;
		11'h119: data <= 8'h28;
		11'h11A: data <= 8'h7C;
		11'h11B: data <= 8'h28;
		11'h11C: data <= 8'h7C;
		11'h11D: data <= 8'h28;
		11'h11E: data <= 8'h28;
		11'h11F: data <= 8'h00;
		// 24h: $
		11'h120: data <= 8'h10;
		11'h121: data <= 8'h3C;
		11'h122: data <= 8'h50;
		11'h123: data <= 8'h38;
		11'h124: data <= 8'h14;
		11'h125: data <= 8'h78;
		11'h126: data <= 8'h10;
		11'h127: data <= 8'h00;
		// 25h: %
		11'h128: data <= 8'h60;
		11'h129: data <= 8'h64;
		11'h12A: data <= 8'h08;
		11'h12B: data <= 8'h10;
		11'h12C: data <= 8'h20;
		11'h12D: data <= 8'h46;
		11'h12E: data <= 8'h06;
		11'h12F: data <= 8'h00;
		// 26h: &
		11'h130: data <= 8'h30;
		11'h131: data <= 8'h48;
		11'h132: data <= 8'h50;
		11'h133: data <= 8'h20;
		11'h134: data <= 8'h54;
		11'h135: data <= 8'h48;
		11'h136: data <= 8'h34;
		11'h137: data <= 8'h00;
		// 27h: '
		11'h138: data <= 8'h30;
		11'h139: data <= 8'h10;
		11'h13A: data <= 8'h20;
		11'h13B: data <= 8'h00;
		11'h13C: data <= 8'h00;
		11'h13D: data <= 8'h00;
		11'h13E: data <= 8'h00;
		11'h13F: data <= 8'h00;
		// 28h: (
		11'h140: data <= 8'h08;
		11'h141: data <= 8'h10;
		11'h142: data <= 8'h20;
		11'h143: data <= 8'h20;
		11'h144: data <= 8'h20;
		11'h145: data <= 8'h10;
		11'h146: data <= 8'h08;
		11'h147: data <= 8'h00;
		// 29h: )
		11'h148: data <= 8'h20;
		11'h149: data <= 8'h10;
		11'h14A: data <= 8'h08;
		11'h14B: data <= 8'h08;
		11'h14C: data <= 8'h08;
		11'h14D: data <= 8'h10;
		11'h14E: data <= 8'h20;
		11'h14F: data <= 8'h00;
		// 2Ah: *
		11'h150: data <= 8'h00;
		11'h151: data <= 8'h10;
		11'h152: data <= 8'h54;
		11'h153: data <= 8'h38;
		11'h154: data <= 8'h54;
		11'h155: data <= 8'h10;
		11'h156: data <= 8'h00;
		11'h157: data <= 8'h00;
		// 2Bh: +
		11'h158: data <= 8'h00;
		11'h159: data <= 8'h10;
		11'h15A: data <= 8'h10;
		11'h15B: data <= 8'h7C;
		11'h15C: data <= 8'h10;
		11'h15D: data <= 8'h10;
		11'h15E: data <= 8'h00;
		11'h15F: data <= 8'h00;
		// 2Ch: ,
		11'h160: data <= 8'h00;
		11'h161: data <= 8'h00;
		11'h162: data <= 8'h00;
		11'h163: data <= 8'h00;
		11'h164: data <= 8'h00;
		11'h165: data <= 8'h30;
		11'h166: data <= 8'h10;
		11'h167: data <= 8'h20;
		// 2Dh: -
		11'h168: data <= 8'h00;
		11'h169: data <= 8'h00;
		11'h16A: data <= 8'h00;
		11'h16B: data <= 8'h7C;
		11'h16C: data <= 8'h00;
		11'h16D: data <= 8'h00;
		11'h16E: data <= 8'h00;
		11'h16F: data <= 8'h00;
		// 2Eh: .
		11'h170: data <= 8'h00;
		11'h171: data <= 8'h00;
		11'h172: data <= 8'h00;
		11'h173: data <= 8'h00;
		11'h174: data <= 8'h00;
		11'h175: data <= 8'h30;
		11'h176: data <= 8'h30;
		11'h177: data <= 8'h00;
		// 2Fh: /
		11'h178: data <= 8'h00;
		11'h179: data <= 8'h04;
		11'h17A: data <= 8'h08;
		11'h17B: data <= 8'h10;
		11'h17C: data <= 8'h20;
		11'h17D: data <= 8'h40;
		11'h17E: data <= 8'h00;
		11'h17F: data <= 8'h00;
		// 30h: 0
		11'h180: data <= 8'h38;
		11'h181: data <= 8'h44;
		11'h182: data <= 8'h4C;
		11'h183: data <= 8'h54;
		11'h184: data <= 8'h64;
		11'h185: data <= 8'h44;
		11'h186: data <= 8'h38;
		11'h187: data <= 8'h00;
		// 31h: 1
		11'h188: data <= 8'h10;
		11'h189: data <= 8'h30;
		11'h18A: data <= 8'h10;
		11'h18B: data <= 8'h10;
		11'h18C: data <= 8'h10;
		11'h18D: data <= 8'h10;
		11'h18E: data <= 8'h38;
		11'h18F: data <= 8'h00;
		// 32h: 2
		11'h190: data <= 8'h38;
		11'h191: data <= 8'h44;
		11'h192: data <= 8'h04;
		11'h193: data <= 8'h08;
		11'h194: data <= 8'h10;
		11'h195: data <= 8'h20;
		11'h196: data <= 8'h7C;
		11'h197: data <= 8'h00;
		// 33h: 3
		11'h198: data <= 8'h7C;
		11'h199: data <= 8'h08;
		11'h19A: data <= 8'h10;
		11'h19B: data <= 8'h08;
		11'h19C: data <= 8'h04;
		11'h19D: data <= 8'h44;
		11'h19E: data <= 8'h38;
		11'h19F: data <= 8'h00;
		// 34h: 4
		11'h1A0: data <= 8'h08;
		11'h1A1: data <= 8'h18;
		11'h1A2: data <= 8'h28;
		11'h1A3: data <= 8'h48;
		11'h1A4: data <= 8'h7C;
		11'h1A5: data <= 8'h08;
		11'h1A6: data <= 8'h08;
		11'h1A7: data <= 8'h00;
		// 35h: 5
		11'h1A8: data <= 8'h7C;
		11'h1A9: data <= 8'h40;
		11'h1AA: data <= 8'h78;
		11'h1AB: data <= 8'h04;
		11'h1AC: data <= 8'h04;
		11'h1AD: data <= 8'h44;
		11'h1AE: data <= 8'h38;
		11'h1AF: data <= 8'h00;
		// 36h: 6
		11'h1B0: data <= 8'h18;
		11'h1B1: data <= 8'h20;
		11'h1B2: data <= 8'h40;
		11'h1B3: data <= 8'h78;
		11'h1B4: data <= 8'h44;
		11'h1B5: data <= 8'h44;
		11'h1B6: data <= 8'h38;
		11'h1B7: data <= 8'h00;
		// 37h: 7
		11'h1B8: data <= 8'h7C;
		11'h1B9: data <= 8'h04;
		11'h1BA: data <= 8'h08;
		11'h1BB: data <= 8'h10;
		11'h1BC: data <= 8'h20;
		11'h1BD: data <= 8'h20;
		11'h1BE: data <= 8'h20;
		11'h1BF: data <= 8'h00;
		// 38h: 8
		11'h1C0: data <= 8'h38;
		11'h1C1: data <= 8'h44;
		11'h1C2: data <= 8'h44;
		11'h1C3: data <= 8'h38;
		11'h1C4: data <= 8'h44;
		11'h1C5: data <= 8'h44;
		11'h1C6: data <= 8'h38;
		11'h1C7: data <= 8'h00;
		// 39h: 9
		11'h1C8: data <= 8'h38;
		11'h1C9: data <= 8'h44;
		11'h1CA: data <= 8'h44;
		11'h1CB: data <= 8'h3C;
		11'h1CC: data <= 8'h04;
		11'h1CD: data <= 8'h08;
		11'h1CE: data <= 8'h30;
		11'h1CF: data <= 8'h00;
		// 3Ah: :
		11'h1D0: data <= 8'h00;
		11'h1D1: data <= 8'h30;
		11'h1D2: data <= 8'h30;
		11'h1D3: data <= 8'h00;
		11'h1D4: data <= 8'h00;
		11'h1D5: data <= 8'h30;
		11'h1D6: data <= 8'h30;
		11'h1D7: data <= 8'h00;
		// 3Bh: ;
		11'h1D8: data <= 8'h00;
		11'h1D9: data <= 8'h30;
		11'h1DA: data <= 8'h30;
		11'h1DB: data <= 8'h00;
		11'h1DC: data <= 8'h00;
		11'h1DD: data <= 8'h30;
		11'h1DE: data <= 8'h10;
		11'h1DF: data <= 8'h20;
		// 3Ch: <
		11'h1E0: data <= 8'h08;
		11'h1E1: data <= 8'h10;
		11'h1E2: data <= 8'h20;
		11'h1E3: data <= 8'h40;
		11'h1E4: data <= 8'h20;
		11'h1E5: data <= 8'h10;
		11'h1E6: data <= 8'h08;
		11'h1E7: data <= 8'h00;
		// 3Dh: =
		11'h1E8: data <= 8'h00;
		11'h1E9: data <= 8'h00;
		11'h1EA: data <= 8'h7C;
		11'h1EB: data <= 8'h00;
		11'h1EC: data <= 8'h7C;
		11'h1ED: data <= 8'h00;
		11'h1EE: data <= 8'h00;
		11'h1EF: data <= 8'h00;
		// 3Eh: >
		11'h1F0: data <= 8'h20;
		11'h1F1: data <= 8'h10;
		11'h1F2: data <= 8'h08;
		11'h1F3: data <= 8'h04;
		11'h1F4: data <= 8'h08;
		11'h1F5: data <= 8'h10;
		11'h1F6: data <= 8'h20;
		11'h1F7: data <= 8'h00;
		// 3Fh: ?
		11'h1F8: data <= 8'h38;
		11'h1F9: data <= 8'h44;
		11'h1FA: data <= 8'h04;
		11'h1FB: data <= 8'h08;
		11'h1FC: data <= 8'h10;
		11'h1FD: data <= 8'h00;
		11'h1FE: data <= 8'h10;
		11'h1FF: data <= 8'h00;
		// 40h: @
		11'h200: data <= 8'h38;
		11'h201: data <= 8'h44;
		11'h202: data <= 8'h04;
		11'h203: data <= 8'h34;
		11'h204: data <= 8'h54;
		11'h205: data <= 8'h54;
		11'h206: data <= 8'h38;
		11'h207: data <= 8'h00;
		// 41h: A
		11'h208: data <= 8'h38;
		11'h209: data <= 8'h44;
		11'h20A: data <= 8'h44;
		11'h20B: data <= 8'h44;
		11'h20C: data <= 8'h7C;
		11'h20D: data <= 8'h44;
		11'h20E: data <= 8'h44;
		11'h20F: data <= 8'h00;
		// 42h: B
		11'h210: data <= 8'h78;
		11'h211: data <= 8'h44;
		11'h212: data <= 8'h44;
		11'h213: data <= 8'h78;
		11'h214: data <= 8'h44;
		11'h215: data <= 8'h44;
		11'h216: data <= 8'h78;
		11'h217: data <= 8'h00;
		// 43h: C
		11'h218: data <= 8'h38;
		11'h219: data <= 8'h44;
		11'h21A: data <= 8'h40;
		11'h21B: data <= 8'h40;
		11'h21C: data <= 8'h40;
		11'h21D: data <= 8'h44;
		11'h21E: data <= 8'h38;
		11'h21F: data <= 8'h00;
		// 44h: D
		11'h220: data <= 8'h70;
		11'h221: data <= 8'h48;
		11'h222: data <= 8'h44;
		11'h223: data <= 8'h44;
		11'h224: data <= 8'h44;
		11'h225: data <= 8'h48;
		11'h226: data <= 8'h70;
		11'h227: data <= 8'h00;
		// 45h: E
		11'h228: data <= 8'h7C;
		11'h229: data <= 8'h40;
		11'h22A: data <= 8'h40;
		11'h22B: data <= 8'h78;
		11'h22C: data <= 8'h40;
		11'h22D: data <= 8'h40;
		11'h22E: data <= 8'h7C;
		11'h22F: data <= 8'h00;
		// 46h: F
		11'h230: data <= 8'h7C;
		11'h231: data <= 8'h40;
		11'h232: data <= 8'h40;
		11'h233: data <= 8'h78;
		11'h234: data <= 8'h40;
		11'h235: data <= 8'h40;
		11'h236: data <= 8'h40;
		11'h237: data <= 8'h00;
		// 47h: G
		11'h238: data <= 8'h38;
		11'h239: data <= 8'h44;
		11'h23A: data <= 8'h40;
		11'h23B: data <= 8'h5C;
		11'h23C: data <= 8'h44;
		11'h23D: data <= 8'h44;
		11'h23E: data <= 8'h3C;
		11'h23F: data <= 8'h00;
		// 48h: H
		11'h240: data <= 8'h44;
		11'h241: data <= 8'h44;
		11'h242: data <= 8'h44;
		11'h243: data <= 8'h7C;
		11'h244: data <= 8'h44;
		11'h245: data <= 8'h44;
		11'h246: data <= 8'h44;
		11'h247: data <= 8'h00;
		// 49h: I
		11'h248: data <= 8'h38;
		11'h249: data <= 8'h10;
		11'h24A: data <= 8'h10;
		11'h24B: data <= 8'h10;
		11'h24C: data <= 8'h10;
		11'h24D: data <= 8'h10;
		11'h24E: data <= 8'h38;
		11'h24F: data <= 8'h00;
		// 4Ah: J
		11'h250: data <= 8'h1C;
		11'h251: data <= 8'h08;
		11'h252: data <= 8'h08;
		11'h253: data <= 8'h08;
		11'h254: data <= 8'h08;
		11'h255: data <= 8'h48;
		11'h256: data <= 8'h30;
		11'h257: data <= 8'h00;
		// 4Bh: K
		11'h258: data <= 8'h44;
		11'h259: data <= 8'h48;
		11'h25A: data <= 8'h50;
		11'h25B: data <= 8'h60;
		11'h25C: data <= 8'h50;
		11'h25D: data <= 8'h48;
		11'h25E: data <= 8'h44;
		11'h25F: data <= 8'h00;
		// 4Ch: L
		11'h260: data <= 8'h40;
		11'h261: data <= 8'h40;
		11'h262: data <= 8'h40;
		11'h263: data <= 8'h40;
		11'h264: data <= 8'h40;
		11'h265: data <= 8'h40;
		11'h266: data <= 8'h7C;
		11'h267: data <= 8'h00;
		// 4Dh: M
		11'h268: data <= 8'h44;
		11'h269: data <= 8'h6C;
		11'h26A: data <= 8'h54;
		11'h26B: data <= 8'h54;
		11'h26C: data <= 8'h44;
		11'h26D: data <= 8'h44;
		11'h26E: data <= 8'h44;
		11'h26F: data <= 8'h00;
		// 4Eh: N
		11'h270: data <= 8'h44;
		11'h271: data <= 8'h44;
		11'h272: data <= 8'h64;
		11'h273: data <= 8'h54;
		11'h274: data <= 8'h4C;
		11'h275: data <= 8'h44;
		11'h276: data <= 8'h44;
		11'h277: data <= 8'h00;
		// 4Fh: O
		11'h278: data <= 8'h38;
		11'h279: data <= 8'h44;
		11'h27A: data <= 8'h44;
		11'h27B: data <= 8'h44;
		11'h27C: data <= 8'h44;
		11'h27D: data <= 8'h44;
		11'h27E: data <= 8'h38;
		11'h27F: data <= 8'h00;
		// 50h: P
		11'h280: data <= 8'h78;
		11'h281: data <= 8'h44;
		11'h282: data <= 8'h44;
		11'h283: data <= 8'h78;
		11'h284: data <= 8'h40;
		11'h285: data <= 8'h40;
		11'h286: data <= 8'h40;
		11'h287: data <= 8'h00;
		// 51h: Q
		11'h288: data <= 8'h38;
		11'h289: data <= 8'h44;
		11'h28A: data <= 8'h44;
		11'h28B: data <= 8'h44;
		11'h28C: data <= 8'h54;
		11'h28D: data <= 8'h48;
		11'h28E: data <= 8'h34;
		11'h28F: data <= 8'h00;
		// 52h: R
		11'h290: data <= 8'h78;
		11'h291: data <= 8'h44;
		11'h292: data <= 8'h44;
		11'h293: data <= 8'h78;
		11'h294: data <= 8'h50;
		11'h295: data <= 8'h48;
		11'h296: data <= 8'h44;
		11'h297: data <= 8'h00;
		// 53h: S
		11'h298: data <= 8'h3C;
		11'h299: data <= 8'h40;
		11'h29A: data <= 8'h40;
		11'h29B: data <= 8'h38;
		11'h29C: data <= 8'h04;
		11'h29D: data <= 8'h04;
		11'h29E: data <= 8'h78;
		11'h29F: data <= 8'h00;
		// 54h: T
		11'h2A0: data <= 8'h7C;
		11'h2A1: data <= 8'h10;
		11'h2A2: data <= 8'h10;
		11'h2A3: data <= 8'h10;
		11'h2A4: data <= 8'h10;
		11'h2A5: data <= 8'h10;
		11'h2A6: data <= 8'h10;
		11'h2A7: data <= 8'h00;
		// 55h: U
		11'h2A8: data <= 8'h44;
		11'h2A9: data <= 8'h44;
		11'h2AA: data <= 8'h44;
		11'h2AB: data <= 8'h44;
		11'h2AC: data <= 8'h44;
		11'h2AD: data <= 8'h44;
		11'h2AE: data <= 8'h38;
		11'h2AF: data <= 8'h00;
		// 56h: V
		11'h2B0: data <= 8'h44;
		11'h2B1: data <= 8'h44;
		11'h2B2: data <= 8'h44;
		11'h2B3: data <= 8'h44;
		11'h2B4: data <= 8'h44;
		11'h2B5: data <= 8'h28;
		11'h2B6: data <= 8'h10;
		11'h2B7: data <= 8'h00;
		// 57h: W
		11'h2B8: data <= 8'h44;
		11'h2B9: data <= 8'h44;
		11'h2BA: data <= 8'h44;
		11'h2BB: data <= 8'h54;
		11'h2BC: data <= 8'h54;
		11'h2BD: data <= 8'h54;
		11'h2BE: data <= 8'h28;
		11'h2BF: data <= 8'h00;
		// 58h: X
		11'h2C0: data <= 8'h44;
		11'h2C1: data <= 8'h44;
		11'h2C2: data <= 8'h28;
		11'h2C3: data <= 8'h10;
		11'h2C4: data <= 8'h28;
		11'h2C5: data <= 8'h44;
		11'h2C6: data <= 8'h44;
		11'h2C7: data <= 8'h00;
		// 59h: Y
		11'h2C8: data <= 8'h44;
		11'h2C9: data <= 8'h44;
		11'h2CA: data <= 8'h44;
		11'h2CB: data <= 8'h28;
		11'h2CC: data <= 8'h10;
		11'h2CD: data <= 8'h10;
		11'h2CE: data <= 8'h10;
		11'h2CF: data <= 8'h00;
		// 5Ah: Z
		11'h2D0: data <= 8'h7C;
		11'h2D1: data <= 8'h04;
		11'h2D2: data <= 8'h08;
		11'h2D3: data <= 8'h10;
		11'h2D4: data <= 8'h20;
		11'h2D5: data <= 8'h40;
		11'h2D6: data <= 8'h7C;
		11'h2D7: data <= 8'h00;
		// 5Bh: [
		11'h2D8: data <= 8'h38;
		11'h2D9: data <= 8'h20;
		11'h2DA: data <= 8'h20;
		11'h2DB: data <= 8'h20;
		11'h2DC: data <= 8'h20;
		11'h2DD: data <= 8'h20;
		11'h2DE: data <= 8'h38;
		11'h2DF: data <= 8'h00;
		// 5Ch: \
		11'h2E0: data <= 8'h00;
		11'h2E1: data <= 8'h40;
		11'h2E2: data <= 8'h20;
		11'h2E3: data <= 8'h10;
		11'h2E4: data <= 8'h08;
		11'h2E5: data <= 8'h04;
		11'h2E6: data <= 8'h00;
		11'h2E7: data <= 8'h00;
		// 5Dh: ]
		11'h2E8: data <= 8'h38;
		11'h2E9: data <= 8'h08;
		11'h2EA: data <= 8'h08;
		11'h2EB: data <= 8'h08;
		11'h2EC: data <= 8'h08;
		11'h2ED: data <= 8'h08;
		11'h2EE: data <= 8'h38;
		11'h2EF: data <= 8'h00;
		// 5Eh: ^
		11'h2F0: data <= 8'h10;
		11'h2F1: data <= 8'h28;
		11'h2F2: data <= 8'h44;
		11'h2F3: data <= 8'h00;
		11'h2F4: data <= 8'h00;
		11'h2F5: data <= 8'h00;
		11'h2F6: data <= 8'h00;
		11'h2F7: data <= 8'h00;
		// 5Fh: _
		11'h2F8: data <= 8'h00;
		11'h2F9: data <= 8'h00;
		11'h2FA: data <= 8'h00;
		11'h2FB: data <= 8'h00;
		11'h2FC: data <= 8'h00;
		11'h2FD: data <= 8'h00;
		11'h2FE: data <= 8'h7C;
		11'h2FF: data <= 8'h00;
		// 60h: `
		11'h300: data <= 8'h20;
		11'h301: data <= 8'h10;
		11'h302: data <= 8'h08;
		11'h303: data <= 8'h00;
		11'h304: data <= 8'h00;
		11'h305: data <= 8'h00;
		11'h306: data <= 8'h00;
		11'h307: data <= 8'h00;
		// 61h: a
		11'h308: data <= 8'h00;
		11'h309: data <= 8'h00;
		11'h30A: data <= 8'h38;
		11'h30B: data <= 8'h04;
		11'h30C: data <= 8'h3C;
		11'h30D: data <= 8'h44;
		11'h30E: data <= 8'h3C;
		11'h30F: data <= 8'h00;
		// 62h: b
		11'h310: data <= 8'h40;
		11'h311: data <= 8'h40;
		11'h312: data <= 8'h58;
		11'h313: data <= 8'h64;
		11'h314: data <= 8'h44;
		11'h315: data <= 8'h44;
		11'h316: data <= 8'h78;
		11'h317: data <= 8'h00;
		// 63h: c
		11'h318: data <= 8'h00;
		11'h319: data <= 8'h00;
		11'h31A: data <= 8'h38;
		11'h31B: data <= 8'h40;
		11'h31C: data <= 8'h40;
		11'h31D: data <= 8'h44;
		11'h31E: data <= 8'h38;
		11'h31F: data <= 8'h00;
		// 64h: d
		11'h320: data <= 8'h04;
		11'h321: data <= 8'h04;
		11'h322: data <= 8'h34;
		11'h323: data <= 8'h4C;
		11'h324: data <= 8'h44;
		11'h325: data <= 8'h44;
		11'h326: data <= 8'h3C;
		11'h327: data <= 8'h00;
		// 65h: e
		11'h328: data <= 8'h00;
		11'h329: data <= 8'h00;
		11'h32A: data <= 8'h38;
		11'h32B: data <= 8'h44;
		11'h32C: data <= 8'h7C;
		11'h32D: data <= 8'h40;
		11'h32E: data <= 8'h38;
		11'h32F: data <= 8'h00;
		// 66h: f
		11'h330: data <= 8'h18;
		11'h331: data <= 8'h24;
		11'h332: data <= 8'h20;
		11'h333: data <= 8'h70;
		11'h334: data <= 8'h20;
		11'h335: data <= 8'h20;
		11'h336: data <= 8'h20;
		11'h337: data <= 8'h00;
		// 67h: g
		11'h338: data <= 8'h00;
		11'h339: data <= 8'h00;
		11'h33A: data <= 8'h3C;
		11'h33B: data <= 8'h44;
		11'h33C: data <= 8'h44;
		11'h33D: data <= 8'h3C;
		11'h33E: data <= 8'h04;
		11'h33F: data <= 8'h38;
		// 68h: h
		11'h340: data <= 8'h40;
		11'h341: data <= 8'h40;
		11'h342: data <= 8'h58;
		11'h343: data <= 8'h64;
		11'h344: data <= 8'h44;
		11'h345: data <= 8'h44;
		11'h346: data <= 8'h44;
		11'h347: data <= 8'h00;
		// 69h: i
		11'h348: data <= 8'h10;
		11'h349: data <= 8'h10;
		11'h34A: data <= 8'h30;
		11'h34B: data <= 8'h10;
		11'h34C: data <= 8'h10;
		11'h34D: data <= 8'h10;
		11'h34E: data <= 8'h38;
		11'h34F: data <= 8'h00;
		// 6Ah: j
		11'h350: data <= 8'h00;
		11'h351: data <= 8'h08;
		11'h352: data <= 8'h00;
		11'h353: data <= 8'h18;
		11'h354: data <= 8'h08;
		11'h355: data <= 8'h08;
		11'h356: data <= 8'h48;
		11'h357: data <= 8'h30;
		// 6Bh: k
		11'h358: data <= 8'h40;
		11'h359: data <= 8'h40;
		11'h35A: data <= 8'h48;
		11'h35B: data <= 8'h50;
		11'h35C: data <= 8'h60;
		11'h35D: data <= 8'h50;
		11'h35E: data <= 8'h48;
		11'h35F: data <= 8'h00;
		// 6Ch: l
		11'h360: data <= 8'h30;
		11'h361: data <= 8'h10;
		11'h362: data <= 8'h10;
		11'h363: data <= 8'h10;
		11'h364: data <= 8'h10;
		11'h365: data <= 8'h10;
		11'h366: data <= 8'h38;
		11'h367: data <= 8'h00;
		// 6Dh: m
		11'h368: data <= 8'h00;
		11'h369: data <= 8'h00;
		11'h36A: data <= 8'h68;
		11'h36B: data <= 8'h54;
		11'h36C: data <= 8'h54;
		11'h36D: data <= 8'h44;
		11'h36E: data <= 8'h44;
		11'h36F: data <= 8'h00;
		// 6Eh: n
		11'h370: data <= 8'h00;
		11'h371: data <= 8'h00;
		11'h372: data <= 8'h58;
		11'h373: data <= 8'h64;
		11'h374: data <= 8'h44;
		11'h375: data <= 8'h44;
		11'h376: data <= 8'h44;
		11'h377: data <= 8'h00;
		// 6Fh: o
		11'h378: data <= 8'h00;
		11'h379: data <= 8'h00;
		11'h37A: data <= 8'h38;
		11'h37B: data <= 8'h44;
		11'h37C: data <= 8'h44;
		11'h37D: data <= 8'h44;
		11'h37E: data <= 8'h38;
		11'h37F: data <= 8'h00;
		// 70h: p
		11'h380: data <= 8'h00;
		11'h381: data <= 8'h00;
		11'h382: data <= 8'h78;
		11'h383: data <= 8'h44;
		11'h384: data <= 8'h78;
		11'h385: data <= 8'h40;
		11'h386: data <= 8'h40;
		11'h387: data <= 8'h40;
		// 71h: q
		11'h388: data <= 8'h00;
		11'h389: data <= 8'h00;
		11'h38A: data <= 8'h00;
		11'h38B: data <= 8'h34;
		11'h38C: data <= 8'h4C;
		11'h38D: data <= 8'h3C;
		11'h38E: data <= 8'h04;
		11'h38F: data <= 8'h04;
		// 72h: r
		11'h390: data <= 8'h00;
		11'h391: data <= 8'h00;
		11'h392: data <= 8'h58;
		11'h393: data <= 8'h64;
		11'h394: data <= 8'h40;
		11'h395: data <= 8'h40;
		11'h396: data <= 8'h40;
		11'h397: data <= 8'h00;
		// 73h: s
		11'h398: data <= 8'h00;
		11'h399: data <= 8'h00;
		11'h39A: data <= 8'h38;
		11'h39B: data <= 8'h40;
		11'h39C: data <= 8'h38;
		11'h39D: data <= 8'h04;
		11'h39E: data <= 8'h78;
		11'h39F: data <= 8'h00;
		// 74h: t
		11'h3A0: data <= 8'h00;
		11'h3A1: data <= 8'h20;
		11'h3A2: data <= 8'h20;
		11'h3A3: data <= 8'h70;
		11'h3A4: data <= 8'h20;
		11'h3A5: data <= 8'h20;
		11'h3A6: data <= 8'h24;
		11'h3A7: data <= 8'h18;
		// 75h: u
		11'h3A8: data <= 8'h00;
		11'h3A9: data <= 8'h00;
		11'h3AA: data <= 8'h44;
		11'h3AB: data <= 8'h44;
		11'h3AC: data <= 8'h44;
		11'h3AD: data <= 8'h4C;
		11'h3AE: data <= 8'h34;
		11'h3AF: data <= 8'h00;
		// 76h: v
		11'h3B0: data <= 8'h00;
		11'h3B1: data <= 8'h00;
		11'h3B2: data <= 8'h44;
		11'h3B3: data <= 8'h44;
		11'h3B4: data <= 8'h44;
		11'h3B5: data <= 8'h28;
		11'h3B6: data <= 8'h10;
		11'h3B7: data <= 8'h00;
		// 77h: w
		11'h3B8: data <= 8'h00;
		11'h3B9: data <= 8'h00;
		11'h3BA: data <= 8'h44;
		11'h3BB: data <= 8'h44;
		11'h3BC: data <= 8'h54;
		11'h3BD: data <= 8'h54;
		11'h3BE: data <= 8'h28;
		11'h3BF: data <= 8'h00;
		// 78h: x
		11'h3C0: data <= 8'h00;
		11'h3C1: data <= 8'h00;
		11'h3C2: data <= 8'h44;
		11'h3C3: data <= 8'h28;
		11'h3C4: data <= 8'h10;
		11'h3C5: data <= 8'h28;
		11'h3C6: data <= 8'h44;
		11'h3C7: data <= 8'h00;
		// 79h: y
		11'h3C8: data <= 8'h00;
		11'h3C9: data <= 8'h00;
		11'h3CA: data <= 8'h00;
		11'h3CB: data <= 8'h44;
		11'h3CC: data <= 8'h44;
		11'h3CD: data <= 8'h3C;
		11'h3CE: data <= 8'h04;
		11'h3CF: data <= 8'h38;
		// 7Ah: z
		11'h3D0: data <= 8'h00;
		11'h3D1: data <= 8'h00;
		11'h3D2: data <= 8'h7C;
		11'h3D3: data <= 8'h08;
		11'h3D4: data <= 8'h10;
		11'h3D5: data <= 8'h20;
		11'h3D6: data <= 8'h7C;
		11'h3D7: data <= 8'h00;
		// 7Bh: {
		11'h3D8: data <= 8'h08;
		11'h3D9: data <= 8'h10;
		11'h3DA: data <= 8'h10;
		11'h3DB: data <= 8'h20;
		11'h3DC: data <= 8'h10;
		11'h3DD: data <= 8'h10;
		11'h3DE: data <= 8'h08;
		11'h3DF: data <= 8'h00;
		// 7Ch: |
		11'h3E0: data <= 8'h10;
		11'h3E1: data <= 8'h10;
		11'h3E2: data <= 8'h10;
		11'h3E3: data <= 8'h10;
		11'h3E4: data <= 8'h10;
		11'h3E5: data <= 8'h10;
		11'h3E6: data <= 8'h10;
		11'h3E7: data <= 8'h00;
		// 7Dh: }
		11'h3E8: data <= 8'h20;
		11'h3E9: data <= 8'h10;
		11'h3EA: data <= 8'h10;
		11'h3EB: data <= 8'h08;
		11'h3EC: data <= 8'h10;
		11'h3ED: data <= 8'h10;
		11'h3EE: data <= 8'h20;
		11'h3EF: data <= 8'h00;
		// 7Eh: ~
		11'h3F0: data <= 8'h00;
		11'h3F1: data <= 8'h00;
		11'h3F2: data <= 8'h60;
		11'h3F3: data <= 8'h92;
		11'h3F4: data <= 8'h0C;
		11'h3F5: data <= 8'h00;
		11'h3F6: data <= 8'h00;
		11'h3F7: data <= 8'h00;
		
		//// Hash Pattern ////
		
		// 7Fh: hash pattern
		11'h3F8: data <= 8'h55;
		11'h3F9: data <= 8'hAA;
		11'h3FA: data <= 8'h55;
		11'h3FB: data <= 8'hAA;
		11'h3FC: data <= 8'h55;
		11'h3FD: data <= 8'hAA;
		11'h3FE: data <= 8'h55;
		11'h3FF: data <= 8'hAA;
		
		//// User Defined Characters ////
		
		// 80h: vertical to the left
		11'h400: data <= 8'hF0;
		11'h401: data <= 8'hF0;
		11'h402: data <= 8'hF0;
		11'h403: data <= 8'hF0;
		11'h404: data <= 8'hF0;
		11'h405: data <= 8'hF0;
		11'h406: data <= 8'hF0;
		11'h407: data <= 8'hF0;
		
		// 81h: vertical to the right
		11'h408: data <= 8'h0F;
		11'h409: data <= 8'h0F;
		11'h40A: data <= 8'h0F;
		11'h40B: data <= 8'h0F;
		11'h40C: data <= 8'h0F;
		11'h40D: data <= 8'h0F;
		11'h40E: data <= 8'h0F;
		11'h40F: data <= 8'h0F;
		
		// 82h: circle
		11'h410: data <= 8'h00;
		11'h411: data <= 8'h18;
		11'h412: data <= 8'h3C;
		11'h413: data <= 8'h7E;
		11'h414: data <= 8'h7E;
		11'h415: data <= 8'h3C;
		11'h416: data <= 8'h18;
		11'h417: data <= 8'h00;
		
		// 83h: Upper left block only
		11'h418: data <= 8'hF0;
		11'h419: data <= 8'hF0;
		11'h41A: data <= 8'hF0;
		11'h41B: data <= 8'hF0;
		11'h41C: data <= 8'h00;
		11'h41D: data <= 8'h00;
		11'h41E: data <= 8'h00;
		11'h41F: data <= 8'h00;
		
		// 84h: Upper right block only
		11'h420: data <= 8'h0F;
		11'h421: data <= 8'h0F;
		11'h422: data <= 8'h0F;
		11'h423: data <= 8'h0F;
		11'h424: data <= 8'h00;
		11'h425: data <= 8'h00;
		11'h426: data <= 8'h00;
		11'h427: data <= 8'h00;
		
		// 85h: Lower left block only
		11'h428: data <= 8'h00;
		11'h429: data <= 8'h00;
		11'h42A: data <= 8'h00;
		11'h42B: data <= 8'h00;
		11'h42C: data <= 8'hF0;
		11'h42D: data <= 8'hF0;
		11'h42E: data <= 8'hF0;
		11'h42F: data <= 8'hF0;
		
		// 86h: Lower right block only
		11'h430: data <= 8'h00;
		11'h431: data <= 8'h00;
		11'h432: data <= 8'h00;
		11'h433: data <= 8'h00;
		11'h434: data <= 8'h0F;
		11'h435: data <= 8'h0F;
		11'h436: data <= 8'h0F;
		11'h437: data <= 8'h0F;
		
		// 87h: One horizontal line
		11'h438: data <= 8'h00;
		11'h439: data <= 8'h00;
		11'h43A: data <= 8'h00;
		11'h43B: data <= 8'h00;
		11'h43C: data <= 8'h00;
		11'h43D: data <= 8'h00;
		11'h43E: data <= 8'h00;
		11'h43F: data <= 8'hFF;
		
		// 88h: Two horizontal lines
		11'h440: data <= 8'h00;
		11'h441: data <= 8'h00;
		11'h442: data <= 8'h00;
		11'h443: data <= 8'h00;
		11'h444: data <= 8'h00;
		11'h445: data <= 8'h00;
		11'h446: data <= 8'hFF;
		11'h447: data <= 8'hFF;
		
		// 89h: Three horizontal lines
		11'h448: data <= 8'h00;
		11'h449: data <= 8'h00;
		11'h44A: data <= 8'h00;
		11'h44B: data <= 8'h00;
		11'h44C: data <= 8'h00;
		11'h44D: data <= 8'hFF;
		11'h44E: data <= 8'hFF;
		11'h44F: data <= 8'hFF;
		
		// 8Ah: Four horizontal lines
		11'h450: data <= 8'h00;
		11'h451: data <= 8'h00;
		11'h452: data <= 8'h00;
		11'h453: data <= 8'h00;
		11'h454: data <= 8'hFF;
		11'h455: data <= 8'hFF;
		11'h456: data <= 8'hFF;
		11'h457: data <= 8'hFF;
		
		// 8Bh: Five horizontal lines
		11'h458: data <= 8'h00;
		11'h459: data <= 8'h00;
		11'h45A: data <= 8'h00;
		11'h45B: data <= 8'hFF;
		11'h45C: data <= 8'hFF;
		11'h45D: data <= 8'hFF;
		11'h45E: data <= 8'hFF;
		11'h45F: data <= 8'hFF;
		
		// 8Ch: Six horizontal lines
		11'h460: data <= 8'h00;
		11'h461: data <= 8'h00;
		11'h462: data <= 8'hFF;
		11'h463: data <= 8'hFF;
		11'h464: data <= 8'hFF;
		11'h465: data <= 8'hFF;
		11'h466: data <= 8'hFF;
		11'h467: data <= 8'hFF;
		
		// 8Dh: Seven horizontal lines
		11'h468: data <= 8'h00;
		11'h469: data <= 8'hFF;
		11'h46A: data <= 8'hFF;
		11'h46B: data <= 8'hFF;
		11'h46C: data <= 8'hFF;
		11'h46D: data <= 8'hFF;
		11'h46E: data <= 8'hFF;
		11'h46F: data <= 8'hFF;
		
		// 8Eh: One vertical line
		11'h470: data <= 8'h80;
		11'h471: data <= 8'h80;
		11'h472: data <= 8'h80;
		11'h473: data <= 8'h80;
		11'h474: data <= 8'h80;
		11'h475: data <= 8'h80;
		11'h476: data <= 8'h80;
		11'h477: data <= 8'h80;
		
		// 8Fh: Two vertical lines
		/*11'h478: data <= 8'hc0;
		11'h479: data <= 8'hc0;
		11'h47A: data <= 8'hc0;
		11'h47B: data <= 8'hc0;
		11'h47C: data <= 8'hc0;
		11'h47D: data <= 8'hc0;
		11'h47E: data <= 8'hc0;
		11'h47F: data <= 8'hc0;*/
	endcase                              
end

endmodule //CHAR_GEN_ROM

//------------------------------------------

module CHAR_RAM
(
clka,
wea,
addra,
dia,

clkb,
addrb,
dob
);

input  clka;
input  wea;
input  [13:0] addra;
input  [11:0] dia;

input  clkb;
input  [13:0] addrb;
output [11:0] dob;

//reg    [11:0] ram [16383:0];
//reg    [11:0] ram [8191:0];
reg    [11:0] ram [4095:0];
reg    [13:0] read_addrb;

always @(posedge clka) begin
	if (wea)
		ram[addra] <= dia;
end

always @(posedge clkb) begin
	read_addrb <= addrb;
end

assign dob = ram[read_addrb];

// fill the character RAM with spaces
integer index;
initial begin
//	for (index = 0; index <= 16383; index = index + 1) begin
	for (index = 0; index <= 4095; index = index + 1) begin
		ram[index] = 8'h20; // ASCII space
	end
	
	//for (index = 9998; index <= 16383; index = index + 1) begin
	//	ram[index] = 8'h20; // ASCII space
	//end                     
end

endmodule //CHAR_RAM

//------------------------------------

module CLOCK_GEN 
(
SYSTEM_CLOCK,

system_clock_buffered,
pixel_clock,
reset
);

input			SYSTEM_CLOCK;				// 100MHz LVTTL SYSTEM CLOCK

output 		system_clock_buffered;	// buffered SYSTEM_CLOCK
output		pixel_clock;				// adjusted SYSTEM_CLOCK
output		reset;						// reset asserted when DCMs are NOT LOCKED

wire			low  = 1'b0;
wire			high = 1'b1;

// signals associated with the system clock DCM
wire 			system_dcm_reset;
wire 			system_dcm_locked;
wire			system_clock_in;
wire			system_clock_unbuffered;
wire			pixel_clock_unbuffered;
wire 			system_clock_buffered;
wire			pixel_clock;

//IBUFG SYSTEM_CLOCK_BUF (
//.O  (system_clock_in),
//.I  (SYSTEM_CLOCK)
//);

BUFG SYSTEM_CLOCK_BUF (
.O  (system_clock_in),
.I  (SYSTEM_CLOCK)
);

//assign system_clock_in = SYSTEM_CLOCK;

// instantiate the clock input buffers for the internal clocks
BUFG SYS_CLOCK_BUF (
.O  (system_clock_buffered),
.I  (system_clock_unbuffered)
);

//assign system_clock_buffered = system_clock_unbuffered;

BUFG PIXEL_CLOCK_BUF (
.O  (pixel_clock),
.I  (pixel_clock_unbuffered)
);

//assign pixel_clock = pixel_clock_unbuffered;

assign reset = !system_dcm_locked;

DCM SYSTEM_DCM (
.CLKFB		(system_clock_buffered),
.CLKIN		(system_clock_in),
.DSSEN		(low),
.PSCLK		(low),
.PSEN			(low),
.PSINCDEC	(low),
.RST			(system_dcm_reset),
.CLK0			(system_clock_unbuffered),
.CLK90		(),
.CLK180		(),
.CLK270		(),
.CLK2X		(),
.CLK2X180	(),
.CLKDV		(),
.CLKFX		(pixel_clock_unbuffered),
.CLKFX180	(),
.LOCKED		(system_dcm_locked),
.PSDONE		(),
.STATUS		()
);
defparam SYSTEM_DCM.CLKDV_DIVIDE = 2.0; // divide the system clock (50 MHz) by 2.0 to determine CLKDV (25 MHz)
defparam SYSTEM_DCM.CLKFX_DIVIDE = `CLK_DIVIDE; // the denominator of the clock multiplier used to determine CLKFX
defparam SYSTEM_DCM.CLKFX_MULTIPLY = `CLK_MULTIPLY; // the numerator of the clock multiplier used to determine CLKFX
defparam SYSTEM_DCM.CLKIN_DIVIDE_BY_2 = "FALSE";
defparam SYSTEM_DCM.CLKIN_PERIOD = 20.0; // period of input clock in ns
defparam SYSTEM_DCM.CLKOUT_PHASE_SHIFT = "NONE"; // phase shift of NONE
defparam SYSTEM_DCM.CLK_FEEDBACK = "1X"; // feedback of NONE, 1X 
defparam SYSTEM_DCM.DFS_FREQUENCY_MODE = "LOW"; // LOW frequency mode for frequency synthesis
defparam SYSTEM_DCM.DLL_FREQUENCY_MODE = "LOW"; // LOW frequency mode for DLL
defparam SYSTEM_DCM.DUTY_CYCLE_CORRECTION = "TRUE"; // Duty cycle correction, TRUE
defparam SYSTEM_DCM.PHASE_SHIFT = 0; // Amount of fixed phase shift from -255 to 255
defparam SYSTEM_DCM.STARTUP_WAIT = "FALSE"; // Delay configuration DONE until DCM LOCK FALSE

SRL16 RESET_SYSTEM_DCM (
.Q		(system_dcm_reset),
.CLK	(system_clock_in),
.D 	(low),
.A0	(high),
.A1	(high),
.A2	(high),
.A3	(high)
);
defparam RESET_SYSTEM_DCM.INIT = "000F";

endmodule //CLOCK_GEN

//---------------------------------------------------

module SVGA_TIMING_GENERATION
(
pixel_clock,
reset,
h_synch,
v_synch,
blank,
pixel_count,
line_count,
subchar_pixel,
subchar_line,
char_column,
char_line
);

input 			pixel_clock;			// pixel clock
input 			reset;					// reset
output 			h_synch;			// horizontal synch for VGA connector
output 			v_synch;			// vertical synch for VGA connector
output			blank;					// composite blanking
output [10:0]	pixel_count;			// counts the pixels in a line
output [9:0]	line_count;				// counts the display lines
output [2:0]	subchar_pixel;			// pixel position within the character
output [2:0]	subchar_line;			// identifies the line number within a character block
output [6:0]	char_column;			// character number on the current line
output [6:0]	char_line;				// line number on the screen

reg [9:0]		line_count;				// counts the display lines
reg [10:0]		pixel_count;			// counts the pixels in a line	
reg				h_synch;					// horizontal synch
reg				v_synch;					// vertical synch

reg				h_blank;					// horizontal blanking
reg				v_blank;					// vertical blanking
reg				blank;					// composite blanking

reg [2:0] 		subchar_line;			// identifies the line number within a character block
reg [9:0] 		char_column_count;	// a counter used to define the character column number
reg [9:0] 		char_line_count;		// a counter used to define the character line number
reg 				reset_char_line; 		// flag to reset the character line during VBI
reg				reset_char_column;	// flag to reset the character column during HBI
reg [2:0]		subchar_pixel;			// pixel position within the character
reg [6:0]		char_column;			// character number on the current line
reg [6:0]		char_line;				// line number on the screen

// CREATE THE HORIZONTAL LINE PIXEL COUNTER
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
		// on reset set pixel counter to 0
		pixel_count <= 11'd0;
	
	else if (pixel_count == (`H_TOTAL - 1))
		// last pixel in the line, so reset pixel counter
		pixel_count <= 11'd0;
	
	else
		pixel_count <= pixel_count + 1;
end

// CREATE THE HORIZONTAL SYNCH PULSE
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
		// on reset remove h_synch
		h_synch <= 1'b0;
	
	else if (pixel_count == (`H_ACTIVE + `H_FRONT_PORCH - 1))
		// start of h_synch
		h_synch <= 1'b1;
	
	else if (pixel_count == (`H_TOTAL - `H_BACK_PORCH - 1))
		// end of h_synch
		h_synch <= 1'b0;
end

// CREATE THE VERTICAL FRAME LINE COUNTER
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
		// on reset set line counter to 0
		line_count <= 10'd0;
	
	else if ((line_count == (`V_TOTAL - 1)) & (pixel_count == (`H_TOTAL - 1)))
		// last pixel in last line of frame, so reset line counter
		line_count <= 10'd0;
	
	else if ((pixel_count == (`H_TOTAL - 1)))
		// last pixel but not last line, so increment line counter
		line_count <= line_count + 1;
end

// CREATE THE VERTICAL SYNCH PULSE
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
		// on reset remove v_synch
		v_synch = 1'b0;

	else if ((line_count == (`V_ACTIVE + `V_FRONT_PORCH - 1) &
		   (pixel_count == `H_TOTAL - 1))) 
		// start of v_synch
		v_synch = 1'b1;
	
	else if ((line_count == (`V_TOTAL - `V_BACK_PORCH - 1)) &
		   (pixel_count == (`H_TOTAL - 1)))
		// end of v_synch
		v_synch = 1'b0;
end


// CREATE THE HORIZONTAL BLANKING SIGNAL
// the "-2" is used instead of "-1" because of the extra register delay
// for the composite blanking signal 
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
		// on reset remove the h_blank
		h_blank <= 1'b0;

	else if (pixel_count == (`H_ACTIVE -2)) 
		// start of HBI
		h_blank <= 1'b1;
	
	else if (pixel_count == (`H_TOTAL -2))
		// end of HBI
		h_blank <= 1'b0;
end


// CREATE THE VERTICAL BLANKING SIGNAL
// the "-2" is used instead of "-1"  in the horizontal factor because of the extra
// register delay for the composite blanking signal 
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
		// on reset remove v_blank
		v_blank <= 1'b0;

	else if ((line_count == (`V_ACTIVE - 1) &
		   (pixel_count == `H_TOTAL - 2))) 
		// start of VBI
		v_blank <= 1'b1;
	
	else if ((line_count == (`V_TOTAL - 1)) &
		   (pixel_count == (`H_TOTAL - 2)))
		// end of VBI
		v_blank <= 1'b0;
end


// CREATE THE COMPOSITE BANKING SIGNAL
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
		// on reset remove blank
		blank <= 1'b0;

	// blank during HBI or VBI
	else if (h_blank || v_blank)
		blank <= 1'b1;
		
	else
		// active video do not blank
		blank <= 1'b0;
end


/* 
   CREATE THE CHARACTER COUNTER.
   CHARACTERS ARE DEFINED WITHIN AN 8 x 8 PIXEL BLOCK.

	A 640  x 480 video mode will display 80  characters on 60 lines.
	A 800  x 600 video mode will display 100 characters on 75 lines.
	A 1024 x 768 video mode will display 128 characters on 96 lines.

	"subchar_line" identifies the row in the 8 x 8 block.
	"subchar_pixel" identifies the column in the 8 x 8 block.
*/

// CREATE THE VERTICAL FRAME LINE COUNTER
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
 		// on reset set line counter to 0
		subchar_line <= 3'b000;

	else if  ((line_count == (`V_TOTAL - 1)) & (pixel_count == (`H_TOTAL - 1) - `CHARACTER_DECODE_DELAY))
		// reset line counter
		subchar_line <= 3'b000;

	else if (pixel_count == (`H_TOTAL - 1) - `CHARACTER_DECODE_DELAY)
		// increment line counter
		subchar_line <= line_count + 1;
end

// subchar_pixel defines the pixel within the character line
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
		// reset to 5 so that the first character data can be latched
		subchar_pixel <= 3'b101;
	
	else if (pixel_count == ((`H_TOTAL - 1) - `CHARACTER_DECODE_DELAY))
		// reset to 5 so that the first character data can be latched
		subchar_pixel <= 3'b101;
	
	else
		subchar_pixel <= subchar_pixel + 1;
end


wire [9:0] char_column_count_iter = char_column_count + 1;

always @ (posedge pixel_clock or posedge reset) begin
	if (reset) begin
		char_column_count <= 10'd0;
		char_column <= 7'd0;
	end
	
	else if (reset_char_column) begin
		// reset the char column count during the HBI
		char_column_count <= 10'd0;
		char_column <= 7'd0;
	end
	
	else begin
		char_column_count <= char_column_count_iter;
		char_column <= char_column_count_iter[9:3];
	end
end

wire [9:0] char_line_count_iter = char_line_count + 1;

always @ (posedge pixel_clock or posedge reset) begin
	if (reset) begin
		char_line_count <= 10'd0;
		char_line <= 7'd0;
	end
	
	else if (reset_char_line) begin
		// reset the char line count during the VBI
		char_line_count <= 10'd0;
		char_line <= 7'd0;
	end
	
	else if (pixel_count == ((`H_TOTAL - 1) - `CHARACTER_DECODE_DELAY)) begin
		// last pixel but not last line, so increment line counter
		char_line_count <= char_line_count_iter;
		char_line <= char_line_count_iter[9:3];
	end
end

// CREATE THE CONTROL SIGNALS FOR THE CHARACTER ADDRESS COUNTERS
/* 
	The HOLD and RESET signals are advanced from the beginning and end
	of HBI and VBI to compensate for the internal character generation
	pipeline.
*/
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
		reset_char_column <= 1'b0;

	else if (pixel_count == ((`H_ACTIVE - 1) - `CHARACTER_DECODE_DELAY))
		// start of HBI
		reset_char_column <= 1'b1;
	
	else if (pixel_count == ((`H_TOTAL - 1) - `CHARACTER_DECODE_DELAY))
	 	// end of HBI					
		reset_char_column <= 1'b0;
end

always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
		reset_char_line <= 1'b0;

	else if ((line_count == (`V_ACTIVE - 1)) &
		   (pixel_count == ((`H_ACTIVE - 1) - `CHARACTER_DECODE_DELAY)))
		// start of VBI
		reset_char_line <= 1'b1;
	
	else if ((line_count == (`V_TOTAL - 1)) &
		   (pixel_count == ((`H_TOTAL - 1) - `CHARACTER_DECODE_DELAY)))
		// end of VBI					
		reset_char_line <= 1'b0;
end
endmodule //SVGA_TIMING_GENERATION

//----------------------------------------------

module VIDEO_OUT
(
pixel_clock,
reset,
vga_red_data,
vga_green_data,
vga_blue_data,
h_synch,
v_synch,
blank,

VGA_HSYNCH,
VGA_VSYNCH,
VGA_OUT_RED,
VGA_OUT_GREEN,
VGA_OUT_BLUE
);

input				pixel_clock;
input				reset;
input				vga_red_data;
input				vga_green_data;
input				vga_blue_data;
input				h_synch;
input				v_synch;
input				blank;

output			VGA_HSYNCH;
output			VGA_VSYNCH;
output			VGA_OUT_RED;
output			VGA_OUT_GREEN;
output			VGA_OUT_BLUE;

reg				VGA_HSYNCH;
reg				VGA_VSYNCH;
reg				VGA_OUT_RED;
reg				VGA_OUT_GREEN;
reg				VGA_OUT_BLUE;

// make the external video connections
always @ (posedge pixel_clock or posedge reset) begin
	if (reset) begin
		// shut down the video output during reset
		VGA_HSYNCH 				<= 1'b1;
		VGA_VSYNCH 				<= 1'b1;
		VGA_OUT_RED				<= 1'b0;
		VGA_OUT_GREEN			<= 1'b0;
		VGA_OUT_BLUE			<= 1'b0;
	end
	
	else if (blank) begin
		// output black during the blank signal
		VGA_HSYNCH	 			<= h_synch;
		VGA_VSYNCH 	 			<= v_synch;
		VGA_OUT_RED				<= 1'b0;
		VGA_OUT_GREEN			<= 1'b0;
		VGA_OUT_BLUE			<= 1'b0;
	end
	
	else begin
		// output color data otherwise
		VGA_HSYNCH	 			<= h_synch;
		VGA_VSYNCH 	 			<= v_synch;
		VGA_OUT_RED				<= vga_red_data;
		VGA_OUT_GREEN			<= vga_green_data;
		VGA_OUT_BLUE			<= vga_blue_data;
	end
end

endmodule // VIDEO_OUT