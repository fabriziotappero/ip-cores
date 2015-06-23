//==================================================================//
// File:    d_TopLevel.v                                            //
// Version: 0.0.0.3                                                 //
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
// Copyright (C) Stephen Pickett                                    //
//   Jun 08, 2005                                                   //
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
// Ver 0.0.0.1     Apr   , 2005   Under Development                 //
// Ver 0.0.0.2     Jun 08, 2005    Updates                          //
// Ver 0.0.0.3     Jun 19, 2005    Added Character Display          //
//                                                                  //
//==================================================================//

module TopLevel(
    CLK_50MHZ_IN, MASTER_RST,
    H_SYNC, V_SYNC, VGA_OUTPUT,
    PS2C, PS2D,
//    TIME_BASE,
    ADC_DATA, CLK_ADC,
    VGA_RAM_ADDR, VGA_RAM_DATA,
    VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS,
    
    SEG_OUT, SEG_SEL, leds, SHOW_LEVELS_BUTTON
    );

//==================================================================//
// DEFINITIONS                                                      //
//==================================================================//

//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//

//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input CLK_50MHZ_IN, MASTER_RST;
output H_SYNC, V_SYNC;
output[2:0] VGA_OUTPUT;
//input[5:0] TIME_BASE;
inout PS2C, PS2D;
input[8:0] ADC_DATA;
output CLK_ADC;
output[17:0] VGA_RAM_ADDR;
inout[15:0] VGA_RAM_DATA;
output VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS;

output[7:0] leds;
output[6:0] SEG_OUT;
output[3:0] SEG_SEL;
input SHOW_LEVELS_BUTTON;
wire SHOW_LEVELS_BUTTON;


//----------------------//
// WIRES / NODES        //
//----------------------//
wire      CLK_50MHZ_IN, MASTER_RST;
wire      H_SYNC, V_SYNC;
wire[2:0] VGA_OUTPUT;
wire[5:0] TIME_BASE;
wire      PS2C, PS2D;
wire[8:0] ADC_DATA;
wire      CLK_ADC;
wire[17:0] VGA_RAM_ADDR;
wire[15:0] VGA_RAM_DATA;
wire       VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS;


//----------------------//
// VARIABLES            //
//----------------------//
assign TIME_BASE = 6'b0;


//==================================================================//
// TEMP                                                             //
//==================================================================//
reg[8:0] fake_adcData;

wire[17:0] VGA_RAM_ADDRESS_w;
wire[15:0] VGA_RAM_DATA_w;
wire L_BUTTON, R_BUTTON, M_BUTTON;

wire VGA_RAM_ACCESS_OK;
wire CLK_50MHZ, CLK_64MHZ, CLK180_64MHZ;
reg CLK_VGA;
wire[6:0] SEG_OUT;
wire[3:0] SEG_SEL;

wire[7:0] data_charRamRead;
reg[7:0] data_charRamRead_buf;
wire[7:0] mask_charMap;
reg[7:0] mask_charMap_buf;


always @ (posedge CLK_50MHZ) begin
    if(R_BUTTON) begin
        data_charRamRead_buf <= data_charRamRead_buf;
        mask_charMap_buf <= mask_charMap_buf;
    end else begin
        data_charRamRead_buf <= data_charRamRead;
        mask_charMap_buf <= mask_charMap;
    end
end

sub_SegDriver segs(
    .CLK_50MHZ(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .DATA_IN(fake_adcData[7:0]),
    .SEG_OUT(SEG_OUT), .SEG_SEL(SEG_SEL)
    );

wire[7:0] leds;
assign leds[7:0] = 8'b0;

/*- - - - - - - - - - - - - */
/* Fake ADC data            */
/*- - - - - - - - - - - - - */
always @ (posedge CLK_64MHZ or posedge MASTER_RST) begin
    if(MASTER_RST)
        fake_adcData <= 9'd0;
    else
        fake_adcData <= fake_adcData+1;
end



//==================================================================//
// SUBROUTINES                                                      //
//==================================================================//
//d_DCM_VGA clock_gen_VGA (
//    .CLKIN_IN(CLK_50MHZ_IN), 
//    .RST_IN(MASTER_RST), 
//    .CLKFX_OUT(CLK_VGA), 
//    .CLKIN_IBUFG_OUT(CLK_50MHZ_B), 
//    .LOCKED_OUT(CLK_VGA_LOCKED)
//    );

always @ (posedge CLK_50MHZ or posedge MASTER_RST)
    if(MASTER_RST) CLK_VGA <= 1'b0;
    else           CLK_VGA <= ~CLK_VGA;


wire CLK_64MHZ_LOCKED;
d_DCM clock_generator(
    .CLKIN_IN(CLK_50MHZ_IN),
    .RST_IN(MASTER_RST),
    .CLKIN_IBUFG_OUT(CLK_50MHZ),
    .CLK_64MHZ(CLK_64MHZ),
    .CLK180_64MHZ(CLK180_64MHZ),
    .LOCKED_OUT(CLK_64MHZ_LOCKED)
    );

wire[11:0] XCOORD, YCOORD;
wire[9:0] TRIGGER_LEVEL, HORZ_OFFSET, VERT_OFFSET;
wire[3:0] TIMESCALE;
wire[1:0] TRIGGERSTYLE;
Driver_mouse driver_MOUSE(
    .CLK_50MHZ(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .PS2C(PS2C), .PS2D(PS2D),
    .XCOORD(XCOORD), .YCOORD(YCOORD),
    .L_BUTTON(L_BUTTON), .M_BUTTON(M_BUTTON), .R_BUTTON(R_BUTTON)
    );
    
Driver_MouseInput Driver_MouseInput_inst(
    .CLK_50MHZ(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .XCOORD(XCOORD[9:0]), .YCOORD(YCOORD[9:0]),
    .L_BUTTON(L_BUTTON), .M_BUTTON(M_BUTTON), .R_BUTTON(R_BUTTON),
    .TRIGGER_LEVEL(TRIGGER_LEVEL), .HORZ_OFFSET(HORZ_OFFSET), .VERT_OFFSET(VERT_OFFSET),
    .TIMESCALE(TIMESCALE),
    .TRIGGERSTYLE(TRIGGERSTYLE)
    );



wire[8:0] ADC_RAM_DATA;
wire[10:0] ADC_RAM_ADDR;
wire ADC_RAM_CLK;
wire[10:0] TRIG_ADDR;
wire VGA_WRITE_DONE;

ADCDataBuffer ADC_Data_Buffer(
    .CLK_64MHZ(CLK_64MHZ),  .MASTER_CLK(MASTER_CLK), .MASTER_RST(MASTER_RST),
    .TIMESCALE(TIMESCALE), .TRIGGER_LEVEL(TRIGGER_LEVEL),
    .VERT_OFFSET(VERT_OFFSET), .HORZ_OFFSET(HORZ_OFFSET),
//    .ADC_DATA(ADC_DATA[7:0]),
    .ADC_DATA(fake_adcData),
    .CLK_ADC(CLK_ADC),
    .SNAP_DATA_EXT(ADC_RAM_DATA), .SNAP_ADDR_EXT(ADC_RAM_ADDR), .SNAP_CLK_EXT(ADC_RAM_CLK),
    .TRIGGERSTYLE(TRIGGERSTYLE)
    );


//------------------------------------------------------------------//
//   VGA                                                            //
//------------------------------------------------------------------//
wire[9:0] HCNT, VCNT;
wire[2:0] RGB_CHAR;


CharacterDisplay charTest(
    .MASTER_CLK(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .CLK_VGA(CLK_VGA), .HCNT(HCNT), .VCNT(VCNT),
    .RGB_OUT(RGB_CHAR),
    .TIMESCALE(TIMESCALE),
    .TRIGGERSTYLE(TRIGGERSTYLE),
    .XCOORD(XCOORD), .YCOORD(YCOORD)
    );


wire VGA_RAM_OE_w, VGA_RAM_WE_w, VGA_RAM_CS_w;
wire[17:0] VGA_RAM_ADDRESS_r;
wire VGA_RAM_OE_r, VGA_RAM_WE_r, VGA_RAM_CS_r;

assign VGA_RAM_ADDR = (VGA_RAM_ACCESS_OK) ? VGA_RAM_ADDRESS_w : VGA_RAM_ADDRESS_r;
assign VGA_RAM_DATA = (VGA_RAM_ACCESS_OK) ? VGA_RAM_DATA_w : 16'bZ;
assign VGA_RAM_OE = (VGA_RAM_ACCESS_OK) ? VGA_RAM_OE_w : VGA_RAM_OE_r;
assign VGA_RAM_WE = (VGA_RAM_ACCESS_OK) ? VGA_RAM_WE_w : VGA_RAM_WE_r;
assign VGA_RAM_CS = (VGA_RAM_ACCESS_OK) ? VGA_RAM_CS_w : VGA_RAM_CS_r;

VGADataBuffer ram_VGA_ramwrite(
    .CLK_50MHZ(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .VGA_RAM_DATA(VGA_RAM_DATA_w), .VGA_RAM_ADDR(VGA_RAM_ADDRESS_w),
    .VGA_RAM_OE(VGA_RAM_OE_w), .VGA_RAM_WE(VGA_RAM_WE_w), .VGA_RAM_CS(VGA_RAM_CS_w),
    .VGA_RAM_ACCESS_OK(VGA_RAM_ACCESS_OK),
    .ADC_RAM_DATA(ADC_RAM_DATA), .ADC_RAM_ADDR(ADC_RAM_ADDR), .ADC_RAM_CLK(ADC_RAM_CLK),
    .TIME_BASE(TIME_BASE)
    );

Driver_VGA driver_VGA(
    .CLK_50MHZ(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .CLK_VGA(CLK_VGA),
    .H_SYNC(H_SYNC), .V_SYNC(V_SYNC), .VGA_OUTPUT(VGA_OUTPUT),
    .XCOORD(XCOORD), .YCOORD(YCOORD),
    .VGA_RAM_DATA(VGA_RAM_DATA), .VGA_RAM_ADDR(VGA_RAM_ADDRESS_r),
    .VGA_RAM_OE(VGA_RAM_OE_r), .VGA_RAM_WE(VGA_RAM_WE_r), .VGA_RAM_CS(VGA_RAM_CS_r),
    .VGA_RAM_ACCESS_OK(VGA_RAM_ACCESS_OK),
    .TRIGGER_LEVEL(TRIGGER_LEVEL), .HORZ_OFFSET(HORZ_OFFSET), .VERT_OFFSET(VERT_OFFSET),
    .SHOW_LEVELS(SHOW_LEVELS_BUTTON),
    .HCNT(HCNT), .VCNT(VCNT),
    .RGB_CHAR(RGB_CHAR)
    );



    


//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//

endmodule

