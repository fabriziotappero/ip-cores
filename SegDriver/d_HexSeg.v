//==================================================================
// File:    d_MouseDriver.v
// Version: 0.01
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Copyright Stephen Pickett, Clarke Ellis
//   April 28, 2005
//------------------------------------------------------------------
// Revisions:
// Ver 0.01     Apr 28, 2005    Initial Release
//
//==================================================================

module sub_HexSeg(
    DATA_IN,
    SEG_OUT
    );
    
//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//
//----------------------//
// INPUTS               //
//----------------------//
input[3:0] DATA_IN;
//----------------------//
// OUTPUTS              //
//----------------------//
output[6:0] SEG_OUT;

//----------------------//
// WIRES / NODES        //
//----------------------//
wire[3:0] DATA_IN;
reg[6:0] SEG_OUT;

//----------------------//
// REGISTERS            //
//----------------------//

//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//
//     ____
//  5 | 0  | 1
//    |____|
//  4 | 6  | 2
//    |____|
//      3

always @ (DATA_IN) begin
SEG_OUT[6] = !((DATA_IN == 4'h2) |
               (DATA_IN == 4'h3) |
               (DATA_IN == 4'h4) |
               (DATA_IN == 4'h5) |
               (DATA_IN == 4'h6) |
               (DATA_IN == 4'h8) |
               (DATA_IN == 4'h9) |
               (DATA_IN == 4'hA) |
               (DATA_IN == 4'hB) |
               (DATA_IN == 4'hD) |
               (DATA_IN == 4'hE) |
               (DATA_IN == 4'hF));

SEG_OUT[5] = !((DATA_IN == 4'h0) ||
             (DATA_IN == 4'h4) ||
             (DATA_IN == 4'h5) ||
             (DATA_IN == 4'h6) ||
             (DATA_IN == 4'h8) ||
             (DATA_IN == 4'h9) ||
             (DATA_IN == 4'hA) ||
             (DATA_IN == 4'hB) ||
             (DATA_IN == 4'hC) ||
             (DATA_IN == 4'hE) ||
             (DATA_IN == 4'hF));

SEG_OUT[4] = !((DATA_IN == 4'h0) ||
             (DATA_IN == 4'h2) ||
             (DATA_IN == 4'h6) ||
             (DATA_IN == 4'h8) ||
             (DATA_IN == 4'hA) ||
             (DATA_IN == 4'hB) ||
             (DATA_IN == 4'hC) ||
             (DATA_IN == 4'hD) ||
             (DATA_IN == 4'hE) ||
             (DATA_IN == 4'hF));

SEG_OUT[3] = !((DATA_IN == 4'h0) ||
             (DATA_IN == 4'h2) ||
             (DATA_IN == 4'h3) ||
             (DATA_IN == 4'h5) ||
             (DATA_IN == 4'h6) ||
             (DATA_IN == 4'h8) ||
             (DATA_IN == 4'h9) ||
             (DATA_IN == 4'hB) ||
             (DATA_IN == 4'hC) ||
             (DATA_IN == 4'hD) ||
             (DATA_IN == 4'hE));

SEG_OUT[2] = !((DATA_IN == 4'h0) ||
             (DATA_IN == 4'h1) ||
             (DATA_IN == 4'h3) ||
             (DATA_IN == 4'h4) ||
             (DATA_IN == 4'h5) ||
             (DATA_IN == 4'h6) ||
             (DATA_IN == 4'h7) ||
             (DATA_IN == 4'h8) ||
             (DATA_IN == 4'h9) ||
             (DATA_IN == 4'hA) ||
             (DATA_IN == 4'hB) ||
             (DATA_IN == 4'hD));

SEG_OUT[1] = !((DATA_IN == 4'h0) ||
             (DATA_IN == 4'h1) ||
             (DATA_IN == 4'h2) ||
             (DATA_IN == 4'h3) ||
             (DATA_IN == 4'h4) ||
             (DATA_IN == 4'h7) ||
             (DATA_IN == 4'h8) ||
             (DATA_IN == 4'h9) ||
             (DATA_IN == 4'hA) ||
             (DATA_IN == 4'hD));

SEG_OUT[0] = !((DATA_IN == 4'h0) ||
             (DATA_IN == 4'h2) ||
             (DATA_IN == 4'h3) ||
             (DATA_IN == 4'h5) ||
             (DATA_IN == 4'h6) ||
             (DATA_IN == 4'h7) ||
             (DATA_IN == 4'h8) ||
             (DATA_IN == 4'h9) ||
             (DATA_IN == 4'hA) ||
             (DATA_IN == 4'hC) ||
             (DATA_IN == 4'hE) ||
             (DATA_IN == 4'hF));


end

endmodule







