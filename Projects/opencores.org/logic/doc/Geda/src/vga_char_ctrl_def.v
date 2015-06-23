////////////////////////////////////////////////////////////////////
//     --------------                                             //
//    /      SOC     \                                            //
//   /       GEN      \                                           //
//  /     COMPONENT    \                                          //
//  ====================                                          //
//  |digital done right|                                          //
//  |__________________|                                          //
//                                                                //
//                                                                //
//                                                                //
//    Copyright (C) <2009>  <Ouabache DesignWorks>                //
//                                                                //
//                                                                //  
//   This source file may be used and distributed without         //  
//   restriction provided that this copyright statement is not    //  
//   removed from the file and that any derivative work contains  //  
//   the original copyright notice and the associated disclaimer. //  
//                                                                //  
//   This source file is free software; you can redistribute it   //  
//   and/or modify it under the terms of the GNU Lesser General   //  
//   Public License as published by the Free Software Foundation; //  
//   either version 2.1 of the License, or (at your option) any   //  
//   later version.                                               //  
//                                                                //  
//   This source is distributed in the hope that it will be       //  
//   useful, but WITHOUT ANY WARRANTY; without even the implied   //  
//   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //  
//   PURPOSE.  See the GNU Lesser General Public License for more //  
//   details.                                                     //  
//                                                                //  
//   You should have received a copy of the GNU Lesser General    //  
//   Public License along with this source; if not, download it   //  
//   from http://www.opencores.org/lgpl.shtml                     //  
//                                                                //  
////////////////////////////////////////////////////////////////////
 module 
  vga_char_ctrl_def 
    #( parameter 
      CHARACTER_DECODE_DELAY=4,
      CHAR_RAM_ADDR=13,
      CHAR_RAM_WIDTH=8,
      CHAR_RAM_WORDS=4800,
      CHAR_RAM_WRITETHRU=0,
      H_ACTIVE=640,
      H_BACK_PORCH=48,
      H_FRONT_PORCH=16,
      H_SYNCH=96,
      H_TOTAL=800,
      V_ACTIVE=480,
      V_BACK_PORCH=31,
      V_FRONT_PORCH=11,
      V_SYNCH=2,
      V_TOTAL=524)
     (
 input   wire                 add_h_load,
 input   wire                 add_l_load,
 input   wire                 ascii_load,
 input   wire                 clk,
 input   wire                 reset,
 input   wire    [ 7 :  0]        back_color,
 input   wire    [ 7 :  0]        char_color,
 input   wire    [ 7 :  0]        cursor_color,
 input   wire    [ 7 :  0]        wdata,
 output   reg    [ 13 :  0]        address,
 output   wire                 hsync_n_pad_out,
 output   wire                 vsync_n_pad_out,
 output   wire    [ 1 :  0]        blue_pad_out,
 output   wire    [ 2 :  0]        green_pad_out,
 output   wire    [ 2 :  0]        red_pad_out);
reg                        cursor_on;
wire     [ 10 :  0]              pixel_count;
wire     [ 13 :  0]              char_read_addr;
wire     [ 2 :  0]              subchar_line;
wire     [ 2 :  0]              subchar_pixel;
wire     [ 6 :  0]              char_column;
wire     [ 6 :  0]              char_line;
wire     [ 7 :  0]              ascii_code;
wire     [ 9 :  0]              line_count;
cde_sram_dp
#( .ADDR (CHAR_RAM_ADDR),
   .WIDTH (CHAR_RAM_WIDTH),
   .WORDS (CHAR_RAM_WORDS),
   .WRITETHRU (CHAR_RAM_WRITETHRU))
char_ram 
   (
    .clk      ( clk  ),
    .cs      ( 1'b1  ),
    .raddr      ( char_read_addr[12:0] ),
    .rd      ( 1'b1  ),
    .rdata      ( ascii_code[7:0] ),
    .waddr      ( address[12:0] ),
    .wdata      ( wdata[7:0] ),
    .wr      ( ascii_load  ));
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
wire pixel_on;
wire h_synch;
wire v_synch;
wire blank;
// instantiate the character generator
vga_char_ctrl_def_char_display 
#(.H_ACTIVE(H_ACTIVE))
 CHAR_DISPLAY
  (
  .clk               ( clk           ),
  .reset             ( reset         ),
  .char_column       ( char_column   ),
  .char_line         ( char_line     ),
  .subchar_line      ( subchar_line  ),
  .subchar_pixel     ( subchar_pixel ),
  .pixel_on          ( pixel_on      ),
  .char_read_addr    ( char_read_addr),
  .char_write_addr   ( address       ),
  .char_write_data   ( wdata         ),
  .char_write_enable ( ascii_load    ),
  .ascii_code        ( ascii_code    )
);
// instantiate the video timing generator
vga_char_ctrl_def_svga_timing_generation 
 #(.CHARACTER_DECODE_DELAY(CHARACTER_DECODE_DELAY),
   .H_ACTIVE(H_ACTIVE),        
   .H_FRONT_PORCH(H_FRONT_PORCH),        
   .H_SYNCH(H_SYNCH),        
   .H_BACK_PORCH(H_BACK_PORCH),        
   .H_TOTAL(H_TOTAL),        
   .V_ACTIVE(V_ACTIVE),        
   .V_FRONT_PORCH(V_FRONT_PORCH),        
   .V_SYNCH(V_SYNCH),       
   .V_BACK_PORCH(V_BACK_PORCH),        
   .V_TOTAL(V_TOTAL)        
  )
 SVGA_TIMING_GENERATION
(
  .clk            ( clk          ),
  .reset          ( reset        ),
  .h_synch        ( h_synch      ),
  .v_synch        ( v_synch      ),
  .blank          ( blank        ),
  .pixel_count    ( pixel_count  ),
  .line_count     ( line_count   ),
  .subchar_pixel  ( subchar_pixel),
  .subchar_line   ( subchar_line ),
  .char_column    ( char_column  ),
  .char_line      ( char_line    )
);
// instantiate the video output mux
vga_char_ctrl_def_video_out 
 VIDEO_OUT
(
  .clk                ( clk             ),
  .reset              ( reset           ),
  .h_synch            ( h_synch         ),
  .v_synch            ( v_synch         ),
  .blank              ( blank           ),
  .char_color         ( char_color      ),
  .back_color         ( back_color      ),
  .cursor_color       ( cursor_color    ),
  .pixel_on           ( pixel_on        ),
  .cursor_on          ( cursor_on       ),
  .hsync_n_out        ( hsync_n_pad_out ),
  .vsync_n_out        ( vsync_n_pad_out ),
  .red_out            ( red_pad_out     ),
  .green_out          ( green_pad_out   ),
  .blue_out           ( blue_pad_out    )
);
always @ (posedge clk )
   if (reset)    cursor_on <=  1'b0;
   else          cursor_on <= (char_read_addr ==  address) ;
always@(posedge clk)
  if(reset)       address <= 14'b00000000000000;
  else
  if(add_l_load)  address[7:0] <= wdata;
  else
  if(add_h_load)  address[13:8] <= wdata[5:0];   
  else
  if(ascii_load)  address  <= address+ 14'b0000000000001;   
  else            address  <= address;   
  endmodule
module vga_char_ctrl_def_char_display
#(parameter H_ACTIVE=0
)
(
input wire          clk,
input wire          reset,
input wire [6:0]    char_column,    // character number on the current line
input wire [6:0]    char_line,      // line number on the screen
input wire [2:0]    subchar_line,   // the line number within a character block 0-8
input wire [2:0]    subchar_pixel,  // the pixel number within a character block 0-8
input wire [7:0]    ascii_code,
output wire         pixel_on,                    
output reg [13:0]   char_read_addr,
input wire [13:0]   char_write_addr,
input wire [7:0]    char_write_data,
input wire          char_write_enable
 );
always @ (*) 
     begin
     char_read_addr    = (char_line[6:0] * H_ACTIVE / 8 ) + {7'b0000000,char_column[6:0]};
     end
// the character generator block includes the character RAM
// and the character generator ROM
vga_char_ctrl_def_char_gen 
 CHAR_GEN
(
 .clk                ( clk               ),  
 .reset              ( reset             ),  // reset signal
 .char_write_addr    ( char_write_addr   ),  // write address
 .char_write_data    ( char_write_data   ),  // write data
 .char_write_enable  ( char_write_enable ),  // write enable
 .char_read_addr     ( char_read_addr    ),  // read address of current character
 .subchar_line       ( subchar_line      ),  // current line of pixels within current character
 .subchar_pixel      ( subchar_pixel     ),  // current column of pixels withing current character
 .pixel_on           ( pixel_on          ),   
 .ascii_code         ( ascii_code        )   
);
endmodule //CHAR_DISPLAY
module vga_char_ctrl_def_char_gen
(
input wire           clk, 
input wire           reset,
input wire [13:0]    char_write_addr,
input wire [7:0]     char_write_data,
input wire           char_write_enable,
input wire [13:0]    char_read_addr,               // character address "0" is upper left character
input wire [2:0]     subchar_line,               // line number within 8 line block
input wire [2:0]     subchar_pixel,               // pixel position within 8 pixel block   
input wire [7:0]     ascii_code,
output reg           pixel_on 
			 );
reg                   latch_data;
reg                   latch_low_data;
reg                   shift_high;
reg                   shift_low;
reg [3:0]             latched_low_char_data;
reg [7:0]             latched_char_data;
wire [10:0]           chargen_rom_address = {ascii_code[7:0], subchar_line[2:0]};
wire [7:0]            char_gen_rom_data;
// instantiate the character generator ROM
cde_sram_dp  #(
    .ADDR        (11),      
    .WIDTH       (8),       
    .WORDS       (1152)    
  )  
char_gen_rom
(
      .clk       ( clk      ),
      .cs        (1'b1              ),      
      .waddr     (11'b00000000000 ),
      .raddr     ( chargen_rom_address),
      .wr        (1'b0              ),
      .rd        (1'b1              ),
      .wdata     (8'h00             ),      
      .rdata     ( char_gen_rom_data[7:0]  )
  );
// LATCH THE CHARTACTER DATA FROM THE CHAR GEN ROM AND CREATE A SERIAL CHAR DATA STREAM
always @ (posedge clk )begin
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
always @ (posedge clk )begin
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
always @ (posedge clk )begin
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
always @ (posedge clk )begin
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
always @ (posedge clk ) begin
     if (reset)
           begin
               pixel_on              <= 1'b0;
               latched_low_char_data <= 4'h0;
               latched_char_data     <= 8'h00;
          end
     else if (shift_high)
          begin
               pixel_on              <= latched_char_data [7];
               latched_char_data [7] <= latched_char_data [6];
               latched_char_data [6] <= latched_char_data [5];
               latched_char_data [5] <= latched_char_data [4];
               latched_char_data [4] <= latched_char_data [7];
                    if(latch_low_data) begin
                         latched_low_char_data [3:0] <= latched_char_data [3:0];
                         end
                    else begin
                         latched_low_char_data [3:0] <= latched_low_char_data [3:0];
                         end
               end
     else if (shift_low)
          begin
               pixel_on                  <= latched_low_char_data [3];
               latched_low_char_data [3] <= latched_low_char_data [2];
               latched_low_char_data [2] <= latched_low_char_data [1];
               latched_low_char_data [1] <= latched_low_char_data [0];
               latched_low_char_data [0] <= latched_low_char_data [3];
               if  (latch_data)   latched_char_data [7:0] <= char_gen_rom_data[7:0];
               else               latched_char_data [7:0] <= latched_char_data [7:0];
          end
      else 
          begin
          latched_low_char_data [3:0]  <= latched_low_char_data [3:0];
          latched_char_data [7:0]      <= latched_char_data [7:0];
          pixel_on                     <= pixel_on;
          end
     end
endmodule //CHAR_GEN
//---------------------------------------------------
module vga_char_ctrl_def_svga_timing_generation
#(parameter CHARACTER_DECODE_DELAY=4,
  parameter H_ACTIVE=640,        
  parameter H_FRONT_PORCH=16,        
  parameter H_SYNCH=96,        
  parameter H_BACK_PORCH=48,        
  parameter H_TOTAL=800,        
  parameter V_ACTIVE=480,        
  parameter V_FRONT_PORCH=11,        
  parameter V_SYNCH=2,        
  parameter V_BACK_PORCH=31,        
  parameter V_TOTAL=524        
)
(
input                clk,          // pixel clock
input                reset,        // reset
output reg           h_synch,      // horizontal synch for VGA connector
output reg           v_synch,      // vertical synch for VGA connector
output reg           blank,        // composite blanking
output reg [10:0]    pixel_count,  // counts the pixels in a line
output reg [9:0]     line_count,   // counts the display lines
output reg [2:0]     subchar_pixel,// pixel position within the character
output reg [2:0]     subchar_line, // identifies the line number within a character block
output reg [6:0]     char_column,  // character number on the current line
output reg [6:0]     char_line     // line number on the screen
 );
reg                    h_blank;                         // horizontal blanking
reg                    v_blank;                         // vertical blanking
reg [9:0]           char_column_count;     // a counter used to define the character column number
reg [9:0]           char_line_count;          // a counter used to define the character line number
reg                     reset_char_line;           // flag to reset the character line during VBI
reg                    reset_char_column;     // flag to reset the character column during HBI
// CREATE THE HORIZONTAL LINE PIXEL COUNTER
always @ (posedge clk) begin
     if (reset)
          // on reset set pixel counter to 0
          pixel_count <= 11'd0;
     else if (pixel_count == (H_TOTAL - 1))
          // last pixel in the line, so reset pixel counter
          pixel_count <= 11'd0;
     else
          pixel_count <= pixel_count + 1;
end
// CREATE THE HORIZONTAL SYNCH PULSE
always @ (posedge clk ) begin
     if (reset)
          // on reset remove h_synch
          h_synch <= 1'b0;
     else if (pixel_count == (H_ACTIVE + H_FRONT_PORCH - 1))
          // start of h_synch
          h_synch <= 1'b1;
     else if (pixel_count == (H_TOTAL - H_BACK_PORCH - 1))
          // end of h_synch
          h_synch <= 1'b0;
end
// CREATE THE VERTICAL FRAME LINE COUNTER
always @ (posedge clk ) begin
     if (reset)
          // on reset set line counter to 0
          line_count <= 10'd0;
     else if ((line_count == (V_TOTAL - 1)) & (pixel_count == (H_TOTAL - 1)))
          // last pixel in last line of frame, so reset line counter
          line_count <= 10'd0;
     else if ((pixel_count == (H_TOTAL - 1)))
          // last pixel but not last line, so increment line counter
          line_count <= line_count + 1;
end
// CREATE THE VERTICAL SYNCH PULSE
always @ (posedge clk ) begin
     if (reset)
          // on reset remove v_synch
          v_synch <= 1'b0;
     else if ((line_count == (V_ACTIVE + V_FRONT_PORCH - 1) &
             (pixel_count == H_TOTAL - 1))) 
          // start of v_synch
          v_synch <= 1'b1;
     else if ((line_count == (V_TOTAL - V_BACK_PORCH - 1)) &
             (pixel_count == (H_TOTAL - 1)))
          // end of v_synch
          v_synch <= 1'b0;
end
// CREATE THE HORIZONTAL BLANKING SIGNAL
// the "-2" is used instead of "-1" because of the extra register delay
// for the composite blanking signal 
always @ (posedge clk ) begin
     if (reset)
          // on reset remove the h_blank
          h_blank <= 1'b0;
     else if (pixel_count == (H_ACTIVE -2)) 
          // start of HBI
          h_blank <= 1'b1;
     else if (pixel_count == (H_TOTAL -2))
          // end of HBI
          h_blank <= 1'b0;
end
// CREATE THE VERTICAL BLANKING SIGNAL
// the "-2" is used instead of "-1"  in the horizontal factor because of the extra
// register delay for the composite blanking signal 
always @ (posedge clk ) begin
     if (reset)
          // on reset remove v_blank
          v_blank <= 1'b0;
     else if ((line_count == (V_ACTIVE - 1) &
             (pixel_count ==  H_TOTAL - 2))) 
          // start of VBI
          v_blank <= 1'b1;
     else if ((line_count == (V_TOTAL - 1)) &
             (pixel_count == (H_TOTAL - 2)))
          // end of VBI
          v_blank <= 1'b0;
end
// CREATE THE COMPOSITE BANKING SIGNAL
always @ (posedge clk ) begin
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
always @ (posedge clk ) begin
     if (reset)
           // on reset set line counter to 0
          subchar_line <= 3'b000;
     else if  ((line_count == (V_TOTAL - 1)) & (pixel_count == (H_TOTAL - 1) - CHARACTER_DECODE_DELAY))
          // reset line counter
          subchar_line <= 3'b000;
     else if (pixel_count == (H_TOTAL - 1) - CHARACTER_DECODE_DELAY)
          // increment line counter
          subchar_line <= line_count[2:0] + 3'b001;
end
// subchar_pixel defines the pixel within the character line
always @ (posedge clk ) begin
     if (reset)
          // reset to 5 so that the first character data can be latched
          subchar_pixel <= 3'b101;
     else if (pixel_count == ((H_TOTAL - 1) - CHARACTER_DECODE_DELAY))
          // reset to 5 so that the first character data can be latched
          subchar_pixel <= 3'b101;
     else
          subchar_pixel <= subchar_pixel + 1;
end
wire [9:0] char_column_count_iter = char_column_count + 1;
always @ (posedge clk ) begin
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
always @ (posedge clk ) begin
     if (reset) begin
          char_line_count <= 10'd0;
          char_line <= 7'd0;
     end
     else if (reset_char_line) begin
          // reset the char line count during the VBI
          char_line_count <= 10'd0;
          char_line <= 7'd0;
     end
     else if (pixel_count == ((H_TOTAL - 1) - CHARACTER_DECODE_DELAY)) begin
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
always @ (posedge clk ) begin
     if (reset)
          reset_char_column <= 1'b0;
     else if (pixel_count == ((H_ACTIVE - 2) - CHARACTER_DECODE_DELAY))
          // start of HBI
          reset_char_column <= 1'b1;
     else if (pixel_count == ((H_TOTAL - 1) - CHARACTER_DECODE_DELAY))
           // end of HBI                         
          reset_char_column <= 1'b0;
end
always @ (posedge clk ) begin
     if (reset)
          reset_char_line <= 1'b0;
     else if ((line_count == (V_ACTIVE - 1)) &
             (pixel_count == ((H_ACTIVE - 1) - CHARACTER_DECODE_DELAY)))
          // start of VBI
          reset_char_line <= 1'b1;
     else if ((line_count == (V_TOTAL - 1)) &
             (pixel_count == ((H_TOTAL - 1) - CHARACTER_DECODE_DELAY)))
          // end of VBI                         
          reset_char_line <= 1'b0;
end
endmodule //SVGA_TIMING_GENERATION
module vga_char_ctrl_def_video_out
(
input   wire        clk,
input   wire        reset,
input   wire        h_synch,
input   wire        v_synch,
input   wire        blank,
input   wire        pixel_on,
input   wire        cursor_on,
input   wire [7:0]  char_color,
input   wire [7:0]  cursor_color,
input   wire [7:0]  back_color,
output   reg        hsync_n_out,
output   reg        vsync_n_out,
output   reg  [2:0] red_out,
output   reg  [2:0] green_out,
output   reg  [1:0] blue_out
 );
// make the external video connections
always @ (posedge clk ) begin
     if (reset) begin
          // shut down the video output during reset
          hsync_n_out                <= 1'b1;
          vsync_n_out                <= 1'b1;
     end
     else begin
          // output color data otherwise
          hsync_n_out                <= !h_synch;
          vsync_n_out                <= !v_synch;
     end
end
// make the external video connections
always @ (posedge clk ) 
     begin
     if (reset) 
        begin
        // shut down the video output during reset
        red_out     <=    3'b000;
        green_out   <=    3'b000;
        blue_out    <=    2'b00;	
        end
     else 
     if (blank) 
        begin
        // output black during the blank signal
        red_out     <=    3'b000;
        green_out   <=    3'b000;
        blue_out    <=    2'b00;	
        end
     else 
     if (cursor_on) 
        begin
        // output black during the blank signal
        red_out     <=    cursor_color[7:5];
        green_out   <=    cursor_color[4:2];
        blue_out    <=    cursor_color[1:0];
        end
     else 
     if (pixel_on) 
        begin
        // output black during the blank signal
        red_out     <=    char_color[7:5];
        green_out   <=    char_color[4:2];
        blue_out    <=    char_color[1:0];
        end
     else 
        begin
        // output black during the blank signal
        red_out     <=    back_color[7:5];
        green_out   <=    back_color[4:2];
        blue_out    <=    back_color[1:0];
        end     
     end
endmodule // VIDEO_OUT
