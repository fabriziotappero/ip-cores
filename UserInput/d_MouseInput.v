//==================================================================//
// File:    d_MouseInput.v                                          //
// Version: 0.0.0.2                                                 //
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
// Ver 0.0.0.1     May   , 2005   Under Development                 //
// Ver 0.0.0.2     Jun 08, 2005    Modulized 'UserLines'            //
//                                                                  //
//==================================================================//

module Driver_MouseInput(
    CLK_50MHZ, MASTER_RST,
    XCOORD, YCOORD, L_BUTTON, R_BUTTON, M_BUTTON,
    TRIGGER_LEVEL, VERT_OFFSET, HORZ_OFFSET,
    TIMESCALE, TRIGGERSTYLE
    );


//==================================================================//
// PARAMETER DEFINITIONS                                            //
//==================================================================//
parameter P_clickLimit_left     = 10'd556;
parameter P_clickLimit_right    = 10'd558;
parameter P_clickLimit_leftV    = 10'd559;
parameter P_clickLimit_rightV   = 10'd561;
parameter P_clickLimit_top      = 10'd102;
parameter P_clickLimit_bot      = 10'd100;


//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//
//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input CLK_50MHZ;            // System wide clock
input MASTER_RST;           // System wide reset
input[9:0] XCOORD;          // X coordinate of the cursor
input[9:0] YCOORD;          // Y coordinate of the cursor
input L_BUTTON;             // Left Mouse Button Press
input R_BUTTON;             // Right Mouse Button Press
input M_BUTTON;             // Middle Mouse Button Press
output[9:0] TRIGGER_LEVEL;  // Current Trigger Level
output[9:0] VERT_OFFSET;    // VERTICAL OFFSET
output[9:0] HORZ_OFFSET;    // HORIZONTAL OFFSET
output[3:0] TIMESCALE;      // Current Tiemscale value
output[1:0] TRIGGERSTYLE;   // Style (rise/fall) of trigger

//----------------------//
// WIRES / NODES        //
//----------------------//
wire CLK_50MHZ, MASTER_RST;
wire[9:0] XCOORD;
wire[9:0] YCOORD;
wire L_BUTTON, R_BUTTON, M_BUTTON;
wire[9:0] TRIGGER_LEVEL, VERT_OFFSET, HORZ_OFFSET;
wire[3:0] TIMESCALE;
wire[1:0] TRIGGERSTYLE;

//----------------------//
// REGISTERS            //
//----------------------//


//----------------------//
// TESTING              //
//----------------------//




//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//

//------------------------------------------------------------------//
// INTERMEDIATES                                                    //
//------------------------------------------------------------------//

// -- LEFT BUTTON --
wire Lrise, Lfall;
reg  Lbuf;
always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) Lbuf <= 1'b0;
    else                   Lbuf <= L_BUTTON;
end

assign Lrise = (!Lbuf &  L_BUTTON);
assign Lfall = ( Lbuf & !L_BUTTON);

// -- RIGHT BUTTON --
wire Rrise, Rfall;
reg  Rbuf;
always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) Rbuf <= 1'b0;
    else                   Rbuf <= R_BUTTON;
end

assign Rrise = (!Rbuf &  R_BUTTON);
assign Rfall = ( Rbuf & !R_BUTTON);


// -- MIDDLE BUTTON --
wire Mrise, Mfall;
reg  Mbuf;
always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) Mbuf <= 1'b0;
    else                   Mbuf <= M_BUTTON;
end

assign Mrise = (!Mbuf &  M_BUTTON);
assign Mfall = ( Mbuf & !M_BUTTON);


//------------------------------------------------------------------//
// USER MODIFIABLE LINES                                            //
//------------------------------------------------------------------//
sub_UserLines set_trigger(
    .MASTER_CLK(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .LINE_VALUE_OUT(TRIGGER_LEVEL),
    .BUTTON_RISE(Lrise),
	.BUTTON_FALL(Lfall),
    .XCOORD(XCOORD),
	.YCOORD(YCOORD),
    .RESET_VALUE(10'd99),
    .LEFT(P_clickLimit_left),
	.RGHT(P_clickLimit_right),
    .BOT(TRIGGER_LEVEL),
//    .BOT(TRIGGER_LEVEL-1'b1),
	.TOP(TRIGGER_LEVEL+1'b1),
    .SETXnY(1'b0)
    );
    
sub_UserLines set_Voffset(
    .MASTER_CLK(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .LINE_VALUE_OUT(VERT_OFFSET),
    .BUTTON_RISE(Lrise),
	.BUTTON_FALL(Lfall),
    .XCOORD(XCOORD),
	.YCOORD(YCOORD),
    .RESET_VALUE(10'd0),
    .LEFT(P_clickLimit_leftV),
	.RGHT(P_clickLimit_rightV),
    .BOT(VERT_OFFSET),
//	  .BOT(VERT_OFFSET-1'b1),
	.TOP(VERT_OFFSET+1'b1),
    .SETXnY(1'b0)
    );
    
sub_UserLines set_Hoffset(
    .MASTER_CLK(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .LINE_VALUE_OUT(HORZ_OFFSET),
    .BUTTON_RISE(Lrise),
	.BUTTON_FALL(Lfall),
    .XCOORD(XCOORD),
	.YCOORD(YCOORD),
    .RESET_VALUE(10'd319),
//    .LEFT(HORZ_OFFSET-1'b1),
    .LEFT(HORZ_OFFSET),
	.RGHT(HORZ_OFFSET+1'b1),
	.BOT(P_clickLimit_bot),
	.TOP(P_clickLimit_top),
    .SETXnY(1'b1)
    );
    
sub_UserTimeScaleBox TSBox(
    .MASTER_CLK(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .VALUE_OUT(TIMESCALE),
    .BUTTON_RISE(Lrise),
	.BUTTON_FALL(Lfall),
    .XCOORD(XCOORD),
	.YCOORD(YCOORD)
    );
    
sub_UserTriggerStyleBox TrigStyleBox(
    .MASTER_CLK(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .VALUE_OUT(TRIGGERSTYLE),
    .BUTTON_RISE(Lrise),
	.BUTTON_FALL(Lfall),
    .XCOORD(XCOORD),
	.YCOORD(YCOORD)
    );




endmodule

