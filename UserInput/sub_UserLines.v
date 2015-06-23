//==================================================================//
// File:    sub_UserLines.v                                         //
// Version: 0.0.0.1                                                 //
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
// Ver 0.0.0.1     Jun 08, 2005   Under Development                 //
//                                                                  //
//==================================================================//

module sub_UserLines(
    MASTER_CLK, MASTER_RST,
    LINE_VALUE_OUT,
    BUTTON_RISE, BUTTON_FALL,
    XCOORD, YCOORD, RESET_VALUE,
    LEFT, RGHT, BOT, TOP,
    SETXnY
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
input MASTER_CLK;       // global master clock
input MASTER_RST;       // global master reset
input XCOORD, YCOORD;   // X and Y coordinates of the current mouse
                        // position. See the documentation for details
input LEFT, RGHT;       // Left and Right limits for 'InRange'
input TOP, BOT;         // Top and Bottom limits for 'InRange'
input SETXnY;           // Upon trigger, either set the 'Value' to the
                        // X or Y coord.
input BUTTON_RISE;      // Trigger has risen
input BUTTON_FALL;      // Trigger has fallen

output[9:0] LINE_VALUE_OUT;    // a 10 bit register to store the X or Y value

input[9:0] RESET_VALUE; // Reset value

//----------------------//
//        NODES         //
//----------------------//
wire      MASTER_CLK, MASTER_RST;
wire[9:0] XCOORD, YCOORD, RESET_VALUE;
wire[9:0] LEFT, RGHT, TOP, BOT;
wire      SETXnY;
wire      BUTTON_RISE, BUTTON_FALL;

reg[9:0] LINE_VALUE_OUT;




//==================================================================//
//                         T E S T I N G                            //
//==================================================================//
// NOTHING TO TEST

//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//
wire in_range;
reg drag;

assign in_range = (((YCOORD >= BOT) && (YCOORD <= TOP)) && ((XCOORD >= LEFT && XCOORD <= RGHT)));

// the 'DRAG' state machine
always @ (posedge MASTER_CLK or posedge MASTER_RST) begin
    if(MASTER_RST)
        drag <= 1'b0;
    else if(BUTTON_RISE && in_range)
        drag <= 1'b1;
    else if(BUTTON_FALL)
        drag <= 1'b0;
    else
        drag <= drag;
end

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   Until this is figured out, it is bad to have the lines at 'zero'
   (due to the comparison for 'in range')
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
always @ (posedge MASTER_CLK or posedge MASTER_RST) begin
    if(MASTER_RST)
        LINE_VALUE_OUT <= RESET_VALUE;
    else if(drag && SETXnY)
        LINE_VALUE_OUT <= XCOORD;
    else if(drag && !SETXnY && (YCOORD<=10'd400))
        LINE_VALUE_OUT <= YCOORD;
    else
        LINE_VALUE_OUT <= LINE_VALUE_OUT;
end



endmodule

