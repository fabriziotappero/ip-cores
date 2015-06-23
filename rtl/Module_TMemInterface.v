`timescale 1ns / 1ps
`include "aDefinitions.v"
//--------------------------------------------------------------------------
module Module_TMemInterface
(
input wire Clock,
input wire Reset,		
input wire iEnable,
input wire [`DATA_ROW_WIDTH-1:0]     iAddress,
output wire [`DATA_ROW_WIDTH-1:0]    oData,
output wire oDone,

input wire 						   ACK_I,
input wire                    GNT_I, 
input wire [`WB_WIDTH-1:0 ] 	DAT_I,

//WB Output Signals
output wire [`WB_WIDTH-1:0 ] ADR_O,
output wire 				     WE_O,
output wire 				     STB_O,
output wire  				     CYC_O


);

wire [3:0] wCurrentWord;
wire wDone;
assign oDone = wDone & iEnable;

FFD_POSEDGE_SYNCRONOUS_RESET # ( 1 ) FFD_DONE
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable( 1'b1 ),
	.D(wCurrentWord[3]),
	.Q(wDone)
);


//wire wShiftNow;
assign WE_O = 1'b0;	//we only read
assign CYC_O = iEnable;



wire[2:0] wLatchNow;
FFD_POSEDGE_SYNCRONOUS_RESET # ( 3 ) FFD_LATHCNOW
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable( 1'b1 ),
	.D(wCurrentWord[2:0]),
	.Q(wLatchNow)
);



SHIFTLEFT_POSEDGE #(4) SHL
( 
  .Clock(Clock),
  .Enable(iEnable & GNT_I),//wShiftNow),			
  .Reset(Reset | ~iEnable ), 
  .Initial(4'b1), 
  .O(wCurrentWord)
  
);

MUXFULLPARALELL_3SEL_WALKINGONE # ( `WB_WIDTH ) MUX1
 (
	.Sel( wCurrentWord[2:0] ),
	.I3(iAddress[31:0]),
	.I2(iAddress[63:32]),
	.I1(iAddress[95:64]),
	.O1( ADR_O )
 );
 


FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) FFDX
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable( wLatchNow[0] & GNT_I),
	.D(DAT_I),
	.Q(oData[95:64])
);


FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) FFDY
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable( wLatchNow[1] & GNT_I),
	.D(DAT_I),
	.Q(oData[63:32])
);


FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) FFDZ
(
	.Clock(Clock),
	.Reset( Reset ),
	.Enable( wLatchNow[2] & GNT_I),
	.D(DAT_I),
	.Q(oData[31:0])
);

endmodule
//--------------------------------------------------------------------------