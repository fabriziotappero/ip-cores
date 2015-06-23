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

module sub_SegDriver(
    CLK_50MHZ, MASTER_RST,
    DATA_IN,
    SEG_OUT, SEG_SEL
    );
    
//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//
//----------------------//
// INPUTS               //
//----------------------//
input CLK_50MHZ;    // System wide clock
input MASTER_RST;   // System wide reset
input[15:0] DATA_IN;
//----------------------//
// OUTPUTS              //
//----------------------//
output[6:0] SEG_OUT;
output[3:0] SEG_SEL;

//----------------------//
// WIRES / NODES        //
//----------------------//
wire CLK_50MHZ, MASTER_RST;
wire[15:0] DATA_IN;
reg [6:0]  SEG_OUT;
reg [3:0]  SEG_SEL;

//----------------------//
// REGISTERS            //
//----------------------//
wire[6:0]  seg0, seg1, seg2, seg3;
reg[7:0] clk_390kHz;

//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//
always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1)
        clk_390kHz <= 8'b0;
    else
        clk_390kHz <= clk_390kHz + 1;
end

always @ (posedge clk_390kHz[7] or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1)
        SEG_SEL <= 4'b1110;
    else begin
        SEG_SEL[3:1] <= SEG_SEL[2:0];
        SEG_SEL[0] <= SEG_SEL[3];
    end
end

always @ (SEG_SEL or seg0 or seg1 or seg2 or seg3) begin
    if(SEG_SEL == 4'b1110)
        SEG_OUT = seg0;
    else if(SEG_SEL == 4'b1101)
        SEG_OUT = seg1;
    else if(SEG_SEL == 4'b1011)
        SEG_OUT = seg2;
    else if(SEG_SEL == 4'b0111)
        SEG_OUT = seg3;
    else
        SEG_OUT = 7'b1111111;
end

sub_HexSeg sub_seg3( .DATA_IN(DATA_IN[15:12]),
                     .SEG_OUT(seg3)
                    );
sub_HexSeg sub_seg2( .DATA_IN(DATA_IN[11:8]),
                     .SEG_OUT(seg2)
                   );
sub_HexSeg sub_seg1( .DATA_IN(DATA_IN[7:4]),
                     .SEG_OUT(seg1)
                   );
sub_HexSeg sub_seg0( .DATA_IN(DATA_IN[3:0]),
                     .SEG_OUT(seg0)
                   );

endmodule





