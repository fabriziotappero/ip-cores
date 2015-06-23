//==================================================================//
// File:    sub_UserBoxes.v                                         //
// Version: 0.0.0.1                                                 //
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
// Copyright (C) Stephen Pickett                                    //
//   Jul 15, 2005                                                   //
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
//                                                                  //
//==================================================================//

module sub_UserTimeScaleBox(
    MASTER_CLK, MASTER_RST,
    VALUE_OUT,
    BUTTON_RISE, BUTTON_FALL,
    XCOORD, YCOORD
);
    
//==================================================================//
// DEFINITIONS                                                      //
//==================================================================//
parameter P_UPleft   = 10'h99;
parameter P_UPright  = 10'h9D;
parameter P_UPbot    = 10'h1E8;
parameter P_UPtop    = 10'h1EE;
parameter P_DNleft   = 10'h9F;
parameter P_DNright  = 10'hA3;
parameter P_DNbot    = 10'h1E8;
parameter P_DNtop    = 10'h1EE;



//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//
//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input MASTER_CLK;       // global master clock
input MASTER_RST;       // global master reset
input[9:0] XCOORD, YCOORD;   // X and Y coordinates of the current mouse
                        // position. See the documentation for details
input BUTTON_RISE;      // Trigger has risen
input BUTTON_FALL;      // Trigger has fallen

output[3:0] VALUE_OUT;  //

//----------------------//
//        NODES         //
//----------------------//
wire      MASTER_CLK, MASTER_RST;
wire[9:0] XCOORD, YCOORD;
wire      BUTTON_RISE, BUTTON_FALL;

reg[3:0]  VALUE_OUT;




//==================================================================//
//                         T E S T I N G                            //
//==================================================================//
// NOTHING TO TEST

//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//
wire in_range_up, in_range_dn;

assign in_range_up = (((YCOORD >= P_UPbot) && (YCOORD <= P_UPtop)) && ((XCOORD >= P_UPleft && XCOORD <= P_UPright)));
assign in_range_dn = (((YCOORD >= P_DNbot) && (YCOORD <= P_DNtop)) && ((XCOORD >= P_DNleft && XCOORD <= P_DNright)));

always @ (posedge MASTER_CLK or posedge MASTER_RST) begin
    if(MASTER_RST)
        VALUE_OUT <= 4'b0;
    else if(BUTTON_RISE && in_range_up)
        VALUE_OUT <= VALUE_OUT + 1;
    else if(BUTTON_RISE && in_range_dn)
        VALUE_OUT <= VALUE_OUT - 1;
    else
        VALUE_OUT <= VALUE_OUT;
end


endmodule

//==================================================================//
//==================================================================//
//==================================================================//
//==================================================================//
//==================================================================//
//==================================================================//


module sub_UserTriggerStyleBox(
    MASTER_CLK, MASTER_RST,
    VALUE_OUT,
    BUTTON_RISE, BUTTON_FALL,
    XCOORD, YCOORD
);
    
//==================================================================//
// DEFINITIONS                                                      //
//==================================================================//
parameter P_RISEleft   = 10'h39;
parameter P_RISEright  = 10'h3D;
parameter P_RISEbot    = 10'h1DF;
parameter P_RISEtop    = 10'h1E5;
parameter P_FALLleft   = 10'h3F;
parameter P_FALLright  = 10'h43;
parameter P_FALLbot    = 10'h1DF;
parameter P_FALLtop    = 10'h1E5;



//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//
//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input MASTER_CLK;           // global master clock
input MASTER_RST;           // global master reset
input[9:0] XCOORD, YCOORD;  // X and Y coordinates of the current mouse
                            // position. See the documentation for details
input BUTTON_RISE;          // Trigger has risen
input BUTTON_FALL;          // Trigger has fallen

output[1:0] VALUE_OUT;      //

//----------------------//
//        NODES         //
//----------------------//
wire      MASTER_CLK, MASTER_RST;
wire[9:0] XCOORD, YCOORD;
wire      BUTTON_RISE, BUTTON_FALL;

reg[1:0]  VALUE_OUT;




//==================================================================//
//                         T E S T I N G                            //
//==================================================================//
// NOTHING TO TEST

//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//
wire in_range_rise, in_range_fall;

assign in_range_rise = (((YCOORD >= P_RISEbot) && (YCOORD <= P_RISEtop)) && ((XCOORD >= P_RISEleft && XCOORD <= P_RISEright)));
assign in_range_fall = (((YCOORD >= P_FALLbot) && (YCOORD <= P_FALLtop)) && ((XCOORD >= P_FALLleft && XCOORD <= P_FALLright)));

always @ (posedge MASTER_CLK or posedge MASTER_RST) begin
    if(MASTER_RST)
        VALUE_OUT <= 2'b00;
    else if(BUTTON_RISE && in_range_rise)
        VALUE_OUT <= 2'b00;
    else if(BUTTON_RISE && in_range_fall)
        VALUE_OUT <= 2'b01;
    else
        VALUE_OUT <= VALUE_OUT;
end


endmodule


