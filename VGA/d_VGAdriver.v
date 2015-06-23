//==================================================================//
// File:    d_VGAdriver.v                                           //
// Version: 0.0.0.3                                                 //
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
// Copyright (C) Stephen Pickett                                    //
//   Jun 09, 2005                                                   //
//                                                                  //
// This program is free software; you can redistribute it and/or    //
// modify it under the terms of the GNU General Public License      //
// as published by the Free Software Foundation; either version 2   //
// of the License, or (at your option) any later version.           //
//                                                                  //
// This program is distributed in the hope that it will be useful,  //
// but WITHOUT ANY WARRANTY; without even the implied warranty of   //
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the    //
// GNU General Public License for more details.                     //
//                                                                  //
// If you have not received a copy of the GNU General Public License//
// along with this program; write to:                               //
//     Free Software Foundation, Inc.,                              //
//     51 Franklin Street, Fifth Floor,                             //
//     Boston, MA  02110-1301, USA.                                 //
//                                                                  //
//------------------------------------------------------------------//
// Revisions:                                                       //
// Ver 0.0.0.1     Apr 28, 2005   Under Development                 //
//     0.0.0.2     Jun 09, 2005   Cleaning                          //
//     0.0.0.3     Jun 10, 2005   Re-structuerd the VCNT and HCNT   //
//                                so they line up with the PXLs.    //
//                                                                  //
//==================================================================//

module Driver_VGA(
    CLK_50MHZ, MASTER_RST,
    CLK_VGA,
    VGA_RAM_DATA, VGA_RAM_ADDR,
    VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS,
    VGA_RAM_ACCESS_OK,
    H_SYNC, V_SYNC, VGA_OUTPUT,
    XCOORD, YCOORD,
    TRIGGER_LEVEL,
    VERT_OFFSET,
    HORZ_OFFSET,
    SHOW_LEVELS,
    HCNT, VCNT,
    RGB_CHAR
    );
    
//==================================================================//
// PARAMETER DEFINITIONS                                            //
//==================================================================//
parameter P_black   = 3'b000;
parameter P_yellow  = 3'b110;
parameter P_cyan    = 3'b011;
parameter P_green   = 3'b010;
parameter P_white   = 3'b111;

//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//
//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input CLK_50MHZ;                // System wide clock
input MASTER_RST;               // System wide reset
input CLK_VGA;
output H_SYNC;                  // The H_SYNC timing signal to the VGA monitor
output V_SYNC;                  // The V_SYNC timing signal to the VGA monitor
output[2:0]  VGA_OUTPUT;        // The 3-bit VGA output
input[11:0]  XCOORD, YCOORD;
input[15:0]  VGA_RAM_DATA;
output[17:0] VGA_RAM_ADDR;
output VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS;
output VGA_RAM_ACCESS_OK;
input[9:0] TRIGGER_LEVEL, HORZ_OFFSET, VERT_OFFSET;
input SHOW_LEVELS;
output[9:0] HCNT, VCNT;
input[2:0] RGB_CHAR;




//----------------------//
// WIRES / NODES        //
//----------------------//
reg H_SYNC, V_SYNC;
reg [2:0]  VGA_OUTPUT;
wire CLK_50MHZ, MASTER_RST;
wire CLK_VGA;
wire[11:0] XCOORD, YCOORD;
wire[15:0] VGA_RAM_DATA;
reg[17:0]  VGA_RAM_ADDR;
reg VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS;
reg VGA_RAM_ACCESS_OK;
wire[9:0] TRIGGER_LEVEL, HORZ_OFFSET, VERT_OFFSET;
wire SHOW_LEVELS;
wire[9:0] HCNT, VCNT;
wire[2:0] RGB_CHAR;


//----------------------//
// REGISTERS            //
//----------------------//
wire CLK_25MHZ = CLK_VGA;
reg [9:0] hcnt;     // Counter - generates the H_SYNC signal
reg [9:0] vcnt;     // Counter - counts the H_SYNC pulses to generate V_SYNC signal
reg[2:0]  vga_out;

//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//
assign HCNT = hcnt;
assign VCNT = vcnt;


//------------------------------------------------------------------//
// SYNC TIMING COUNTERS                                             //
//------------------------------------------------------------------//
always @ (posedge CLK_25MHZ or posedge MASTER_RST) begin
    if (MASTER_RST == 1'b1) begin
        hcnt <= 10'd0;
        vcnt <= 10'd430;
    end else if (hcnt == 10'd0799) begin
        hcnt <= 10'd0;
        if (vcnt == 10'd0)
            vcnt <= 10'd520;
        else
            vcnt <= vcnt - 1'b1;
    end else
        hcnt <= hcnt + 1'b1;
end


//------------------------------------------------------------------//
// HORIZONTAL SYNC TIMING                                           //
//------------------------------------------------------------------//
always @ (hcnt)
    if (hcnt >= 10'd656 && hcnt <= 10'd751)
        H_SYNC = 1'b0;
    else
        H_SYNC = 1'b1;


//------------------------------------------------------------------//
// VERTICAL SYNC TIMING                                             //
//------------------------------------------------------------------//
always @ (vcnt)
    if (vcnt == 10'd430 || vcnt == 10'd429)
        V_SYNC = 1'b0;
    else
        V_SYNC = 1'b1;


//------------------------------------------------------------------//
// VGA DATA SIGNAL TIMING                                           //
//------------------------------------------------------------------//
always @ (hcnt or vcnt or XCOORD or YCOORD or MASTER_RST or vga_out or SHOW_LEVELS or TRIGGER_LEVEL or VERT_OFFSET or HORZ_OFFSET or RGB_CHAR) begin
    if(MASTER_RST == 1'b1) begin
        VGA_OUTPUT = P_black;
    //------------------------------------------------------------------------------//
    // UNSEEN BORDERS                                                               //
    end else if( (vcnt >= 10'd400) && (vcnt <= 10'd440) ) begin
        VGA_OUTPUT = P_black;
    end else if( (hcnt >= 10'd640) ) begin
        VGA_OUTPUT = P_black;
    //------------------------------------------------------------------------------//
    // MOUSE CURSORS                                                                //
    end else if(vcnt == YCOORD) begin
        VGA_OUTPUT = P_green;
    end else if(hcnt == XCOORD) begin
        VGA_OUTPUT = P_green;
    //------------------------------------------------------------------------------//
    // TRIGGER SPRITE         (shows as ------T------ )                             //
    end else if(SHOW_LEVELS == 1'b1 && vcnt == (TRIGGER_LEVEL) && hcnt != 10'd556 && hcnt != 10'd558) begin
        VGA_OUTPUT = P_yellow;
    end else if(SHOW_LEVELS == 1'b1 && vcnt == (TRIGGER_LEVEL+1'b1) && hcnt >= 10'd556 && hcnt <= 10'd558) begin
        VGA_OUTPUT = P_yellow;
    end else if(SHOW_LEVELS == 1'b1 && vcnt == (TRIGGER_LEVEL-1'b1) && hcnt == 10'd557) begin
        VGA_OUTPUT = P_yellow;
    //------------------------------------------------------------------------------//
    // VERTICAL OFFSET SPRITE         (shows as ------V------ )                     //
    end else if(SHOW_LEVELS == 1'b1 && vcnt == (VERT_OFFSET) && hcnt != 10'd560) begin
        VGA_OUTPUT = P_yellow;
    end else if(SHOW_LEVELS == 1'b1 && vcnt == (VERT_OFFSET+1'b1) && (hcnt == 10'd559 || hcnt == 10'd561)) begin
        VGA_OUTPUT = P_yellow;
    end else if(SHOW_LEVELS == 1'b1 && vcnt == (VERT_OFFSET-1'b1) && hcnt == 10'd560) begin
        VGA_OUTPUT = P_yellow;
   //------------------------------------------------------------------------------//
    // HORIZONTAL1 OFFSET SPRITE         (shows as ------H------ )                 //
    end else if(SHOW_LEVELS == 1'b1 && hcnt == (HORZ_OFFSET) && vcnt != 10'd102 && vcnt != 10'd100) begin
        VGA_OUTPUT = P_yellow;
    end else if(SHOW_LEVELS == 1'b1 && hcnt == (HORZ_OFFSET+1'b1) && (vcnt == 10'd100 || vcnt == 10'd101 || vcnt == 10'd102)) begin
        VGA_OUTPUT = P_yellow;
    end else if(SHOW_LEVELS == 1'b1 && hcnt == (HORZ_OFFSET-1'b1) && (vcnt == 10'd100 || vcnt == 10'd101 || vcnt == 10'd102)) begin
        VGA_OUTPUT = P_yellow;
    //------------------------------------------------------------------------------//
    // TOP, BOTTOM, LEFT AND RIGHT GRID LINES                                       //
    end else if(vcnt == 10'd0 || vcnt == 10'd399 || vcnt == 10'd441) begin
        VGA_OUTPUT = P_cyan;
    end else if(hcnt == 10'd0 || hcnt == 10'd639) begin
        VGA_OUTPUT = P_cyan;
    //------------------------------------------------------------------------------//
    // CHARACTER DISPLAY
    end else if(vcnt <= 10'd520 && vcnt >= 10'd441) begin
        VGA_OUTPUT = RGB_CHAR;
    //------------------------------------------------------------------------------//
    // THE WAVEFORM                                                                 //
    end else if(vga_out != 0) begin
        VGA_OUTPUT = vga_out;
    //------------------------------------------------------------------------------//
    // MIDDLE GRID LINES (dashed at 8pxls)                                          //
    end else if(vcnt == 10'd199 && hcnt[3] == 1'b1) begin
        VGA_OUTPUT = P_cyan;
    end else if((hcnt == 10'd319) && (vcnt <= 10'd399) && (vcnt[3] == 1'b1)) begin
        VGA_OUTPUT = P_cyan;
    //------------------------------------------------------------------------------//
    // OTHER HORIZONTAL LINES (dashed at 4pxls)                                     //
    end else if((vcnt == 10'd39 || vcnt == 10'd79 || vcnt == 10'd119 || vcnt == 10'd159 || vcnt == 10'd239 || vcnt == 10'd279 || vcnt == 10'd319 || vcnt == 10'd359) && (hcnt[2] == 1'b1)) begin
        VGA_OUTPUT = P_cyan;
    //------------------------------------------------------------------------------//
    // OTHER VERTICAL LINES (dashed at 4pxls)                                       //
    end else if(((hcnt[5:0] == 6'b111111) && (vcnt <= 10'd399)) && (vcnt[2] == 1'b1)) begin
        VGA_OUTPUT = P_cyan;
    //------------------------------------------------------------------------------//
    // OTHERWISE...                                                                 //
    end else
        VGA_OUTPUT = P_black;
end

//------------------------------------------------------------------//
// RAM DATA READING                                                 //
//------------------------------------------------------------------//
// on reset, ram_addr = 24 and add 25 on each pxl
//     row 0: ram_addr = 24 and 25 for each pxl
//     row 1: ram_addr = 24 and 25 for each pxl
//       ...
//     row 15: ram_addr = 24 and 25 for each pxl
//     row 16: ram_addr = 23 and 25 for each pxl *
//     row 17: ram_addr = 23 and 25 for each pxl *
//       ...
reg[4:0]  ram_vcnt;
reg[15:0] ram_vshift;

always @ (posedge CLK_25MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        ram_vshift <= 16'h8000;
    end else if(vcnt > 10'd399) begin
        ram_vshift <= 16'h8000;
    end else if(/*(vcnt <= 10'd399) && */(hcnt == 10'd640)) begin
        if(ram_vshift == 16'h0001)
            ram_vshift <= 16'h8000;
        else
            ram_vshift <= (ram_vshift >> 1);
    end else
        ram_vshift <= ram_vshift;
end

always @ (posedge CLK_25MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        ram_vcnt <= 5'd24;//5'b0
    end else if(vcnt > 10'd399) begin
        ram_vcnt <= 5'd24;
    end else if(/*(vcnt >= 10'd30) &&*/ (hcnt == 10'd640) && (ram_vshift == 16'h0001)) begin
        if(ram_vcnt == 5'd0)
            ram_vcnt <= 5'd24;
        else
            ram_vcnt <= ram_vcnt - 1'b1;
    end else begin
        ram_vcnt <= ram_vcnt;
    end
end



always @ (hcnt or ram_vcnt) begin
    VGA_RAM_ADDR = ram_vcnt + (hcnt * 7'd25);
//    VGA_RAM_ADDR = vcnt * hcnt;
end


always @ (VGA_RAM_DATA or ram_vshift) begin
    if((VGA_RAM_DATA & ram_vshift) != 16'b0)
        vga_out = P_white;
    else
        vga_out = 3'b0;
end


always begin
    VGA_RAM_CS = 1'b0;  // #CS
    VGA_RAM_OE = 1'b0;  // #OE
    VGA_RAM_WE = 1'b1;  // #WE
end


//------------------------------------------------------------------//
// ALL CLEAR?                                                       //
//------------------------------------------------------------------//
always @ (vcnt) begin
    if(vcnt > 10'd399)
        VGA_RAM_ACCESS_OK = 1'b1;
    else
        VGA_RAM_ACCESS_OK = 1'b0;
end


endmodule
