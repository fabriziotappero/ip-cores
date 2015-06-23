`timescale 1ns / 1ps
`include "aDefinitions.v"
/**********************************************************************************
Theia, Ray Cast Programable graphic Processing Unit.
Copyright (C) 2010  Diego Valverde (diego.valverde.g@gmail.com)

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

***********************************************************************************/



//--------------------------------------------------------------
module VectorALU
(
	input wire						Clock,
	input wire						Reset,
	input  wire[`INSTRUCTION_OP_LENGTH-1:0]		iOperation,
	input  wire[`WIDTH-1:0]								iChannel_Ax,
	input  wire[`WIDTH-1:0]								iChannel_Bx,
	input  wire[`WIDTH-1:0]								iChannel_Ay,
	input  wire[`WIDTH-1:0]								iChannel_By,
	input  wire[`WIDTH-1:0]								iChannel_Az,
	input  wire[`WIDTH-1:0]								iChannel_Bz,
	output wire [`WIDTH-1:0]							oResultA,
	output wire [`WIDTH-1:0]							oResultB,
	output wire [`WIDTH-1:0]							oResultC,
	input	 wire												iInputReady,
	output reg												oBranchTaken,
	output reg												oBranchNotTaken,
	output reg                                   oReturnFromSub,
	input wire [`ROM_ADDRESS_WIDTH-1:0]          iCurrentIP,
	
	//Connections to the O Memory
	output wire [`DATA_ROW_WIDTH-1:0]    oOMEMWriteAddress,
	output wire [`DATA_ROW_WIDTH-1:0]    oOMEMWriteData,
	output wire                          oOMEM_WriteEnable,
	//Connections to the R Memory
	output wire [`DATA_ROW_WIDTH-1:0]    oTMEMReadAddress,
	input wire [`DATA_ROW_WIDTH-1:0]     iTMEMReadData,
	input wire                           iTMEMDataAvailable,
	output wire                          oTMEMDataRequest,
	
	output reg 												OutputReady
	
);





wire wMultiplcationUnscaled;
assign wMultiplcationUnscaled = (iOperation == `IMUL) ? 1'b1 : 1'b0;

//--------------------------------------------------------------

reg [7:0]	 InputReadyA,InputReadyB,InputReadyC;

//------------------------------------------------------
/*
	This is the block that takes care of all tha arithmetic
	comparisons. Supported operations are <,>,<=,>=,==,!=
	
*/
//------------------------------------------------------
reg [`WIDTH-1:0] wMultiplicationA_Ax;
reg  [`WIDTH-1:0] wMultiplicationA_Bx;
wire [`LONG_WIDTH-1:0] wMultiplicationA_Result;
wire  wMultiplicationA_InputReady;
wire wMultiplicationA_OutputReady;
wire wMultiplicationOutputReady, wMultiplicationOutputReadyA,
wMultiplicationOutputReadyB,wMultiplicationOutputReadyC,wMultiplicationOutputReadyD;

wire wAddSubAOutputReady,wAddSubBOutputReady,wAddSubCOutputReady;
wire [`INSTRUCTION_OP_LENGTH-1:0] wOperation;
wire [`WIDTH-1:0] wSwizzleOutputX,wSwizzleOutputY,wSwizzleOutputZ;

//--------------------------------------------------------------------
reg [`WIDTH-1:0] ResultA,ResultB,ResultC;

//Output Flip Flops,
//This flip flop will control the outputs so that the
//values of the outputs change ONLY when when there is 
//a positive edge of OutputReady

FFD32_POSEDGE ResultAFFD
(
	.Clock( OutputReady ),
	.D( ResultA ),
	.Q( oResultA )
);

FFD32_POSEDGE ResultBFFD
(
	.Clock( OutputReady ),
	.D( ResultB ),
	.Q( oResultB )
);

FFD32_POSEDGE ResultCFFD
(
	.Clock( OutputReady ),
	.D( ResultC ),
	.Q( oResultC )
);
//--------------------------------------------------------------------



Swizzle3D Swizzle1
(
	.Source0_X( iChannel_Bx ),
	.Source0_Y( iChannel_By ),
	.Source0_Z( iChannel_Bz ),
	.iOperation( iChannel_Ax ),
		
	.SwizzleX( wSwizzleOutputX ),
	.SwizzleY( wSwizzleOutputY ),
	.SwizzleZ( wSwizzleOutputZ )
);
//---------------------------------------------------------------------
wire [`LONG_WIDTH-1:0] wModulus2N_ResultA,wModulus2N_ResultB,wModulus2N_ResultC;

//---------------------------------------------------------------------(

wire IOW_Operation,wOMEM_We;
assign IOW_Operation = (iOperation == `OMWRITE);

always @ ( * )
begin
	if (iOperation == `RET)
		oReturnFromSub <= OutputReady;
	else
		oReturnFromSub <= 1'b0;
  
end

FFD_POSEDGE_SYNCRONOUS_RESET # ( 1 ) FFD1_AWE
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( 1'b1 ),
	.D( IOW_Operation ),
	.Q( wOMEM_We )
);

assign oOMEM_WriteEnable = wOMEM_We & IOW_Operation;

FFD_POSEDGE_SYNCRONOUS_RESET # ( `DATA_ROW_WIDTH ) FFD1_A
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( iInputReady ),
	.D( {iChannel_Ax,iChannel_Ay,iChannel_Az} ),
	.Q( oOMEMWriteAddress)
);
FFD_POSEDGE_SYNCRONOUS_RESET # ( `DATA_ROW_WIDTH ) FFD2_B
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( iInputReady ),
	.D( {iChannel_Bx,iChannel_By,iChannel_Bz} ),
	.Q( oOMEMWriteData )
);



wire wTMReadOutputReady;
assign wTMReadOutputReady = iTMEMDataAvailable;
/*
FFD_POSEDGE_SYNCRONOUS_RESET # ( 1 ) FFD1_ARE
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( 1'b1 ),
	.D( iTMEMDataAvailable ),
	.Q( wTMReadOutputReady )
);
*/
//assign oTMEMReadAddress = {iChannel_Ax,iChannel_Ay,iChannel_Az};

//We wait 1 clock cycle before be send the data read request, because
//we need to lathc the values at the output

wire wOpTRead;
assign wOpTRead = ( iOperation == `TMREAD ) ? 1'b1 : 1'b0;
wire wTMEMRequest;
FFD_POSEDGE_SYNCRONOUS_RESET # ( 1 ) FFD1_ARE123
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( 1'b1 ),
	.D( wOpTRead ),
	.Q( wTMEMRequest )
);
assign oTMEMDataRequest = wTMEMRequest & wOpTRead;
FFD_POSEDGE_SYNCRONOUS_RESET # ( `DATA_ROW_WIDTH ) FFD2_B445
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( iInputReady & wOpTRead ),
	.D( {iChannel_Ax,iChannel_Ay,iChannel_Az} ),
	.Q( oTMEMReadAddress )
);

/*
	This MUX will select the apropiated X,Y or Z depending on
	wheter it is XYZ iOperation. This gets defined by the bits 3 and 4 
	of iOperation, and only applies for oBranchTaken and Store operations.
*/

wire 					wArithmeticComparison_Result;
wire 					ArithmeticComparison_InputReady;
wire 					ArithmeticComparison_OutputReady;
reg[`WIDTH-1:0] 	ArithmeticComparison_A,ArithmeticComparison_B;


always @ ( * )
begin
	case ( {iOperation[4],iOperation[3]} )
		2'b01: 		ArithmeticComparison_A = iChannel_Ax;
		2'b10: 		ArithmeticComparison_A = iChannel_Ay;
		2'b11:		ArithmeticComparison_A = iChannel_Az;
		default: ArithmeticComparison_A = 0;	//Should never happen
	endcase
end
//---------------------------------------------------------------------
always @ ( * )
begin
	case ( {iOperation[4],iOperation[3]} )
		2'b01: 		ArithmeticComparison_B = iChannel_Bx;
		2'b10: 		ArithmeticComparison_B = iChannel_By;
		2'b11:		ArithmeticComparison_B = iChannel_Bz;
		default: ArithmeticComparison_B = 0;	//Should never happen
	endcase
end

//---------------------------------------------------------------------
/*
	The onbly instance of Aritmetic comparison in the ALU,
	ArithmeticComparison operations matches the 3 LSB of 
	Global ALU iOperation for oBranchTaken Instruction family
*/

assign ArithmeticComparison_InputReady = iInputReady;

wire wArithmeticComparisonResult;

ArithmeticComparison ArithmeticComparison_1
(
	.Clock( Clock ),
	.X( ArithmeticComparison_A ),
	.Y( ArithmeticComparison_B ),
	.iOperation( iOperation[2:0] ),
	.iInputReady( ArithmeticComparison_InputReady ),
	.OutputReady( ArithmeticComparison_OutputReady ),
	.Result( wArithmeticComparisonResult )
);


assign  wArithmeticComparison_Result = wArithmeticComparisonResult && OutputReady; 
//--------------------------------------------------------------------
 RADIX_R_MUL_32_FULL_PARALLEL MultiplicationChannel_A
(

	.Clock( Clock ),
	.Reset( Reset ),
	.A( wMultiplicationA_Ax ),
	.B( wMultiplicationA_Bx ),
	.R( wMultiplicationA_Result ),
	.iUnscaled( wMultiplcationUnscaled ),
	.iInputReady( wMultiplicationA_InputReady ),
	.OutputReady( wMultiplicationA_OutputReady )
);

//--------------------------------------------------------------------
always @ ( * )
begin
	case (iOperation)
	`CROSS: 		wMultiplicationA_Ax = iChannel_Ay;	// Ay * Bz
	`MAG:			wMultiplicationA_Ax = iChannel_Ax;
	`MULP:		wMultiplicationA_Ax = iChannel_Ax;	//Az = Ax * Ay
	default: 	wMultiplicationA_Ax = iChannel_Ax;	// Ax * Bx
	endcase
end
//--------------------------------------------------------------------

//assign wMultiplicationA_Ax = iChannel_Ax;

assign wMultiplicationA_InputReady 
	= (iOperation == `CROSS || 
		iOperation == `DOT	||
		iOperation == `MUL 	|| 
		iOperation == `IMUL 	|| 
		iOperation == `MAG	||
		iOperation == `MULP  
		) ? iInputReady : 0;
	
//--------------------------------------------------------------------
always @ ( * )
begin
	case (iOperation)
	`MUL,`IMUL:			wMultiplicationA_Bx = iChannel_Bx;	//Ax*Bx
	`MAG:			wMultiplicationA_Bx = iChannel_Ax;	//Ax^2
	`DOT:			wMultiplicationA_Bx = iChannel_Bx;	//Ax*Bx
	`CROSS:		wMultiplicationA_Bx = iChannel_Bz;	// Ay * Bz
	`MULP:		wMultiplicationA_Bx = iChannel_Ay;  //Az = Ax * Ay
	default:		wMultiplicationA_Bx = 32'b0;
	endcase
end
//--------------------------------------------------------------------

//------------------------------------------------------

reg [`WIDTH-1:0] wMultiplicationB_Ay;
reg [`WIDTH-1:0]  wMultiplicationB_By;
wire [`LONG_WIDTH-1:0] wMultiplicationB_Result;
wire wMultiplicationB_InputReady;
wire wMultiplicationB_OutputReady;


RADIX_R_MUL_32_FULL_PARALLEL MultiplicationChannel_B
(

	.Clock( Clock ),
	.Reset( Reset ),
	.A( wMultiplicationB_Ay ),
	.B( wMultiplicationB_By ),
	.R( wMultiplicationB_Result ),
	.iUnscaled( wMultiplcationUnscaled ),
	.iInputReady( wMultiplicationB_InputReady ),
	.OutputReady( wMultiplicationB_OutputReady )
);


//----------------------------------------------------

always @ ( * )
begin
	case (iOperation)
		`CROSS: 	wMultiplicationB_Ay = iChannel_Az;	// Az * By
		`MAG: 	wMultiplicationB_Ay = iChannel_Ay;
		default: wMultiplicationB_Ay = iChannel_Ay;	// Ay * By
	endcase
end
//----------------------------------------------------
assign wMultiplicationB_InputReady 
	= (iOperation == `CROSS 			|| 
		iOperation == `DOT	||	
		iOperation == `MUL 		|| 
		iOperation == `IMUL 		|| 
		iOperation == `MAG ) ? iInputReady : 0;
	
//----------------------------------------------------
always @ ( * )
begin
	case (iOperation)
	`MUL,`IMUL:			wMultiplicationB_By = iChannel_By;	//Ay*By
	`MAG:			wMultiplicationB_By = iChannel_Ay;	//Ay^2
	`DOT:			wMultiplicationB_By = iChannel_By;	//Ay*By
	`CROSS:		wMultiplicationB_By = iChannel_By;	// Az * By
	default:		wMultiplicationB_By = 32'b0;
	endcase
end
//----------------------------------------------------
	
//------------------------------------------------------
reg [`WIDTH-1:0] wMultiplicationC_Az;
reg  [`WIDTH-1:0] wMultiplicationC_Bz;
wire [`LONG_WIDTH-1:0] wMultiplicationC_Result;
wire wMultiplicationC_InputReady;
wire wMultiplicationC_OutputReady;


RADIX_R_MUL_32_FULL_PARALLEL MultiplicationChannel_C
(

	.Clock( Clock ),
	.Reset( Reset ),
	.A( wMultiplicationC_Az ),
	.B( wMultiplicationC_Bz ),
	.R( wMultiplicationC_Result ),
	.iUnscaled( wMultiplcationUnscaled ),
	.iInputReady( wMultiplicationC_InputReady ),
	.OutputReady( wMultiplicationC_OutputReady )
);


//----------------------------------------------------
always @ ( * )
begin
	case (iOperation)
		`CROSS: 	wMultiplicationC_Az = iChannel_Az; 	//Az*Bx
		`MAG: 	wMultiplicationC_Az = iChannel_Az;
		default: 				wMultiplicationC_Az = iChannel_Az;	//Az*Bz
	endcase	
end
//----------------------------------------------------

assign wMultiplicationC_InputReady 
	= (
		iOperation == `CROSS 			|| 
		iOperation == `DOT	||	
		iOperation == `MUL 		||
		iOperation == `IMUL 		||
		iOperation == `MAG 
		) ? iInputReady : 0;
	
//----------------------------------------------------
always @ ( * )
begin
	case (iOperation)
	`MUL,`IMUL:			wMultiplicationC_Bz = iChannel_Bz;	//Az*Bz
	`MAG:			wMultiplicationC_Bz = iChannel_Az;	//Ay^2
	`DOT:			wMultiplicationC_Bz = iChannel_Bz;	//Az*Bz
	`CROSS:		wMultiplicationC_Bz = iChannel_Bx;	//Az*Bx
	default:		wMultiplicationC_Bz = 32'b0;
	endcase
end
//----------------------------------------------------	

reg [`WIDTH-1:0] wMultiplicationD_Aw;
reg  [`WIDTH-1:0] wMultiplicationD_Bw;
wire [`LONG_WIDTH-1:0] wMultiplicationD_Result;
wire wMultiplicationD_InputReady;
wire wMultiplicationD_OutputReady;


RADIX_R_MUL_32_FULL_PARALLEL MultiplicationChannel_D
(

	.Clock( Clock ),
	.Reset( Reset ),
	.A( wMultiplicationD_Aw ),
	.B( wMultiplicationD_Bw ),
	.R( wMultiplicationD_Result ),
	.iUnscaled( wMultiplcationUnscaled ),
	.iInputReady( wMultiplicationD_InputReady ),
	.OutputReady( wMultiplicationD_OutputReady )
);

assign wMultiplicationD_InputReady 
	= (iOperation == `CROSS ) ? iInputReady : 0;


//----------------------------------------------------	
always @ ( * )
begin
	case (iOperation)
	`CROSS:			wMultiplicationD_Aw = iChannel_Ax;	//Ax*Bz
	default:							wMultiplicationD_Aw = 32'b0;
	endcase
end
//----------------------------------------------------	
always @ ( * )
begin
	case (iOperation)
	`CROSS:			wMultiplicationD_Bw = iChannel_Bz;	//Ax*Bz
	default:							wMultiplicationD_Bw = 32'b0;
	endcase
end
//----------------------------------------------------	
reg [`WIDTH-1:0] wMultiplicationE_Ak;
reg  [`WIDTH-1:0] wMultiplicationE_Bk;
wire [`LONG_WIDTH-1:0] wMultiplicationE_Result;
wire wMultiplicationE_InputReady;
wire wMultiplicationE_OutputReady;


RADIX_R_MUL_32_FULL_PARALLEL MultiplicationChannel_E
(

	.Clock( Clock ),
	.Reset( Reset ),
	.A( wMultiplicationE_Ak ),
	.B( wMultiplicationE_Bk ),
	.R( wMultiplicationE_Result ),
	.iUnscaled( wMultiplcationUnscaled ),
	.iInputReady( wMultiplicationE_InputReady ),
	.OutputReady( wMultiplicationE_OutputReady )
);

assign wMultiplicationE_InputReady 
	= (iOperation == `CROSS ) ? iInputReady : 0;
	
	
//----------------------------------------------------	
always @ ( * )
begin
	case (iOperation)
	`CROSS:			wMultiplicationE_Ak = iChannel_Ax;	//Ax*By
	default:			wMultiplicationE_Ak = 32'b0;
	endcase
end
//----------------------------------------------------	
always @ ( * )
begin
	case (iOperation)
	`CROSS:			wMultiplicationE_Bk = iChannel_By;	//Ax*By
	default:			wMultiplicationE_Bk = 32'b0;
	endcase
end	
	
//----------------------------------------------------		
reg [`WIDTH-1:0] wMultiplicationF_Al;
reg  [`WIDTH-1:0] wMultiplicationF_Bl;
wire [`LONG_WIDTH-1:0] wMultiplicationF_Result;
wire wMultiplicationF_InputReady;
wire wMultiplicationF_OutputReady;


RADIX_R_MUL_32_FULL_PARALLEL MultiplicationChannel_F
(

	.Clock( Clock ),
	.Reset( Reset ),
	.A( wMultiplicationF_Al ),
	.B( wMultiplicationF_Bl ),
	.R( wMultiplicationF_Result ),
	.iUnscaled( wMultiplcationUnscaled ),
	.iInputReady( wMultiplicationF_InputReady ),
	.OutputReady( wMultiplicationF_OutputReady )
);
assign wMultiplicationF_InputReady 
	= (iOperation == `CROSS ) ? iInputReady : 0;
	
	
//----------------------------------------------------	
always @ ( * )
begin
	case (iOperation)
	`CROSS:			wMultiplicationF_Al = iChannel_Ay;	//Ay*Bx
	default:			wMultiplicationF_Al = 32'b0;
	endcase
end
//----------------------------------------------------	
always @ ( * )
begin
	case (iOperation)
	`CROSS:			wMultiplicationF_Bl = iChannel_Bx;	//Ay*Bx
	default:			wMultiplicationF_Bl = 32'b0;
	endcase
end		
//------------------------------------------------------
wire [`WIDTH-1:0] wDivisionA_Result;
wire wDivisionA_OutputReady;
wire wDivisionA_InputReady;

assign wDivisionA_InputReady = 
	( iOperation == `DIV) ? iInputReady : 0;

SignedIntegerDivision DivisionChannel_A
(
.Clock( Clock ),
.Reset( Reset ),
.iDividend( iChannel_Ax ),
.iDivisor( 	iChannel_Bx ),
.xQuotient( wDivisionA_Result ),
.iInputReady( wDivisionA_InputReady ),
.OutputReady( wDivisionA_OutputReady )

);
//------------------------------------------------------
wire [`WIDTH-1:0] wDivisionB_Result;
wire wDivisionB_OutputReady;
wire wDivisionB_InputReady;

assign wDivisionB_InputReady = 
	( iOperation == `DIV) ? iInputReady : 0;

SignedIntegerDivision DivisionChannel_B
(
.Clock( Clock ),
.Reset( Reset ),
.iDividend( iChannel_Ay ),
.iDivisor( iChannel_By ),
.xQuotient( wDivisionB_Result ),
.iInputReady( wDivisionB_InputReady ),
.OutputReady( wDivisionB_OutputReady )

);
//------------------------------------------------------
wire [`WIDTH-1:0] wDivisionC_Result;
wire wDivisionC_OutputReady;
wire wDivisionC_InputReady;


assign wDivisionC_InputReady = 
	( iOperation == `DIV) ? iInputReady : 0;

SignedIntegerDivision DivisionChannel_C
(
.Clock( Clock ),
.Reset( Reset ),
.iDividend( iChannel_Az ),
.iDivisor( iChannel_Bz ),
.xQuotient( wDivisionC_Result ),
.iInputReady( wDivisionC_InputReady ),
.OutputReady( wDivisionC_OutputReady )

);
//--------------------------------------------------------------
/*
	First addtion block instance goes here.
	Note that all inputs/outputs to the block
	are wires. It has two MUXES one for each entry.
*/
reg [`LONG_WIDTH-1:0] wAddSubA_Ax,wAddSubA_Bx;
wire [`LONG_WIDTH-1:0] wAddSubA_Result;
wire wAddSubA_Operation; //Either addition or substraction
reg wAddSubA_InputReady;
wire wAddSubA_OutputReady;

assign wAddSubA_Operation 
	= ( 
		iOperation == `SUB 	 
		|| iOperation == `CROSS 
		|| iOperation == `DEC	
		|| iOperation == `MOD	
	) ? 1 : 0;

FixedAddSub AddSubChannel_A
(
.Clock( Clock ),
.Reset( Reset ),
.A( wAddSubA_Ax ),
.B( wAddSubA_Bx ),
.R( wAddSubA_Result ),
.iOperation( wAddSubA_Operation ),
.iInputReady( wAddSubA_InputReady ),		
.OutputReady( wAddSubA_OutputReady )		
);
//Diego


//----------------------------

//InpuReady Mux A
always @ ( * )
begin
	case (iOperation)
	`ADD:		wAddSubA_InputReady = iInputReady;
	`SUB:		wAddSubA_InputReady = iInputReady;
	`INC,`INCX,`INCY,`INCZ:		wAddSubA_InputReady = iInputReady;
	`DEC:		wAddSubA_InputReady = iInputReady;
	`MOD:		wAddSubA_InputReady = iInputReady;
	
	`MAG:		wAddSubA_InputReady = wMultiplicationOutputReadyA &&
												wMultiplicationOutputReadyB;
										//wMultiplicationA_OutputReady 
										//&& wMultiplicationB_OutputReady;
										
	`DOT:		wAddSubA_InputReady = 
											wMultiplicationOutputReadyA &&
											wMultiplicationOutputReadyB;
										//wMultiplicationA_OutputReady 
										//&& wMultiplicationB_OutputReady;
										
	`CROSS:	wAddSubA_InputReady =
										wMultiplicationOutputReadyA &&
										wMultiplicationOutputReadyB;
										// wMultiplicationA_OutputReady
										//&& wMultiplicationB_OutputReady;
										
	default:	wAddSubA_InputReady = 1'b0;									
	endcase
end
//----------------------------

//wAddSubA_Bx 2:1 input Mux
always @ ( * )
begin
	case (iOperation)
	
	`ADD:		wAddSubA_Ax = ( iChannel_Ax[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Ax } : { 32'b0, iChannel_Ax };
	`SUB: 	wAddSubA_Ax = ( iChannel_Ax[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Ax } : { 32'b0, iChannel_Ax };
	`INC,`INCX,`INCY,`INCZ:		wAddSubA_Ax = ( iChannel_Ax[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Ax } : { 32'b0, iChannel_Ax };
	`DEC:		wAddSubA_Ax = ( iChannel_Ax[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Ax } : { 32'b0, iChannel_Ax };
	`MOD:		wAddSubA_Ax = ( iChannel_Bx[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Bx } : { 32'b0, iChannel_Bx };
	
	`MAG:		wAddSubA_Ax = wMultiplicationA_Result;
	`DOT:		wAddSubA_Ax = wMultiplicationA_Result;
	`CROSS:	wAddSubA_Ax = wMultiplicationA_Result;
	default:	wAddSubA_Ax = 64'b0;
	endcase
end
//----------------------------
//wAddSubA_Bx 2:1 input Mux
always @ ( * )
begin
	case (iOperation)
	`ADD: wAddSubA_Bx = ( iChannel_Bx[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Bx } : { 32'b0, iChannel_Bx };
	`SUB: wAddSubA_Bx = ( iChannel_Bx[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Bx } : { 32'b0, iChannel_Bx };
	`INC,`INCX: wAddSubA_Bx = (`LONG_WIDTH'd1 << `SCALE);
	`INCY,`INCZ: wAddSubA_Bx = `LONG_WIDTH'd0;
	`DEC: wAddSubA_Bx = (`LONG_WIDTH'd1 << `SCALE);
	`MOD: wAddSubA_Bx = (`LONG_WIDTH'd1 << `SCALE);
	
	`MAG:		wAddSubA_Bx = wMultiplicationB_Result;
	`DOT:		wAddSubA_Bx = wMultiplicationB_Result;
	`CROSS:	wAddSubA_Bx = wMultiplicationB_Result;
	default:	wAddSubA_Bx = 64'b0;
	endcase
end
//--------------------------------------------------------------
/*
	Second addtion block instance goes here.
	Note that all inputs/outputs to the block
	are wires. It has two MUXES one for each entry.
*/

wire [`LONG_WIDTH-1:0] wAddSubB_Result;


wire wAddSubB_Operation; //Either addition or substraction
reg  wAddSubB_InputReady;
wire wAddSubB_OutputReady;

reg [`LONG_WIDTH-1:0] wAddSubB_Ay,wAddSubB_By;

assign wAddSubB_Operation = 
	( iOperation == `SUB 	 
	  || iOperation == `CROSS 	
	  || iOperation == `DEC		
	  || iOperation == `MOD 
	  ) ? 1 : 0;

FixedAddSub AddSubChannel_B
(
.Clock( Clock ),
.Reset( Reset ),
.A( wAddSubB_Ay ),
.B( wAddSubB_By ),
.R( wAddSubB_Result ),
.iOperation( wAddSubB_Operation ),
.iInputReady( wAddSubB_InputReady ),		
.OutputReady( wAddSubB_OutputReady )		
);
//----------------------------
wire wMultiplicationOutputReadyC_Dealy1;
FFD_POSEDGE_ASYNC_RESET # (1) FFwMultiplicationOutputReadyC_Dealy1
(
	.Clock( Clock ),
	.Clear( Reset ),
	.D( wMultiplicationOutputReadyC ),
	.Q( wMultiplicationOutputReadyC_Dealy1 )
);	





//InpuReady Mux B
always @ ( * )
begin
	case (iOperation)
	`ADD:		wAddSubB_InputReady = iInputReady;
	`SUB:		wAddSubB_InputReady = iInputReady;
	`INC,`INCX,`INCY,`INCZ:		wAddSubB_InputReady = iInputReady;
	`DEC:		wAddSubB_InputReady = iInputReady;
	`MOD:		wAddSubB_InputReady = iInputReady;
	
	`MAG:		wAddSubB_InputReady = wAddSubAOutputReady 
											&& wMultiplicationOutputReadyC_Dealy1;
										//&& wMultiplicationC_OutputReady;
										
	`DOT:		wAddSubB_InputReady = wAddSubAOutputReady 
										&& wMultiplicationOutputReadyC_Dealy1;
										//&& wMultiplicationC_OutputReady;
										
	`CROSS:	wAddSubB_InputReady = wMultiplicationOutputReadyC &&
											 wMultiplicationOutputReadyD;
										//	wMultiplicationC_OutputReady
										//&& wMultiplicationD_OutputReady;
										
	default:	wAddSubB_InputReady = 1'b0;									
	
	endcase
end
//----------------------------
// wAddSubB_Ay 2:1 input Mux
// If the iOperation is ADD or SUB, it will simply take the inputs from
// ALU Channels. If it is a VECTOR_MAGNITUDE, it take the input from the
// previus ADDER_A, same for dot product.
always @ ( * )
begin
	case (iOperation)
	`ADD: 	wAddSubB_Ay = (iChannel_Ay[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Ay} : {32'b0,iChannel_Ay};		//Ay
	`SUB: 	wAddSubB_Ay = (iChannel_Ay[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Ay} : {32'b0,iChannel_Ay};		//Ay
	`INC,`INCX,`INCY,`INCZ:		wAddSubB_Ay = (iChannel_Ay[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Ay} : {32'b0,iChannel_Ay};		//Ay
	`DEC:		wAddSubB_Ay = (iChannel_Ay[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Ay} : {32'b0,iChannel_Ay};		//Ay
	`MOD:		wAddSubB_Ay = (iChannel_By[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_By} : {32'b0,iChannel_By};		//Ay
	`MAG:		wAddSubB_Ay = wAddSubA_Result;	//A^2+B^2
	`DOT:		wAddSubB_Ay = wAddSubA_Result;   //Ax*Bx + Ay*By
	`CROSS:	wAddSubB_Ay	= wMultiplicationC_Result;	
	default:	wAddSubB_Ay = 64'b0;
	endcase
end
//----------------------------
//wAddSubB_By 2:1 input Mux
always @ ( * )
begin
	case (iOperation)
	`ADD: 	wAddSubB_By = (iChannel_By[31] == 1'b1) ? {32'hFFFFFFFF,iChannel_By } : {32'b0,iChannel_By};				//By
	`SUB: 	wAddSubB_By = (iChannel_By[31] == 1'b1) ? {32'hFFFFFFFF,iChannel_By } : {32'b0,iChannel_By}; //{32'b0,iChannel_By};				//By
	`INC,`INCY:		wAddSubB_By = (`LONG_WIDTH'd1 << `SCALE);
	`INCX,`INCZ:   wAddSubB_By = `LONG_WIDTH'd0;
	`DEC:		wAddSubB_By = (`LONG_WIDTH'd1 << `SCALE);
	`MOD:		wAddSubB_By = (`LONG_WIDTH'd1 << `SCALE);
	`MAG:		wAddSubB_By = wMultiplicationC_Result;	//C^2
	`DOT:		wAddSubB_By = wMultiplicationC_Result;	//Az * Bz
	`CROSS:	wAddSubB_By	= wMultiplicationD_Result;	
	default:	wAddSubB_By = 32'b0;
	endcase
end
//--------------------------------------------------------------
wire [`LONG_WIDTH-1:0] wAddSubC_Result;
reg [`LONG_WIDTH-1:0] wAddSubC_Az,wAddSubC_Bz;

wire wAddSubC_Operation; //Either addition or substraction
reg wAddSubC_InputReady;
wire wAddSubC_OutputReady;

reg [`LONG_WIDTH-1:0] AddSubC_Az,AddSubB_Bz;

//-----------------------------------------
always @ ( * )
begin	
	case (iOperation)
		`CROSS: 	wAddSubC_Az = wMultiplicationE_Result;
		`MOD: wAddSubC_Az = (iChannel_Bz[31] == 1'b1) ? {32'hFFFFFFFF,iChannel_Bz} : {32'b0,iChannel_Bz};
		default: 				wAddSubC_Az = (iChannel_Az[31] == 1'b1) ? {32'hFFFFFFFF,iChannel_Az} : {32'b0,iChannel_Az};
	endcase
end	
//-----------------------------------------
always @ ( * )
begin	
	case (iOperation)
		`CROSS: 	wAddSubC_Bz = wMultiplicationF_Result;
		`INC,`INCZ:		wAddSubC_Bz = (`LONG_WIDTH'd1 << `SCALE);
		`INCX,`INCY:   wAddSubC_Bz = `LONG_WIDTH'd0;
		`DEC:		wAddSubC_Bz = (`LONG_WIDTH'd1 << `SCALE);
		`MOD:		wAddSubC_Bz = (`LONG_WIDTH'd1 << `SCALE);
		default: 				wAddSubC_Bz = (iChannel_Bz[31] == 1'b1) ? {32'hFFFFFFFF,iChannel_Bz} : {32'b0,iChannel_Bz};
	endcase
end	
//-----------------------------------------

assign wAddSubC_Operation 
	= ( 
		iOperation == `SUB 		
		|| iOperation == `CROSS 	
		|| iOperation == `DEC 		
		|| iOperation == `MOD	
		) ? 1 : 0;

FixedAddSub AddSubChannel_C
(
.Clock( Clock ),
.Reset( Reset ),
.A( wAddSubC_Az ),
.B( wAddSubC_Bz ),
.R( wAddSubC_Result ),
.iOperation( wAddSubC_Operation ),
.iInputReady( wAddSubC_InputReady ),		
.OutputReady( wAddSubC_OutputReady )		
);


always @ ( * )
begin	
	case (iOperation)
	`CROSS:	wAddSubC_InputReady = wMultiplicationE_OutputReady && 
		wMultiplicationF_OutputReady;
		
	default: wAddSubC_InputReady = iInputReady;	
	endcase
end

//------------------------------------------------------
wire [`WIDTH-1:0] wSquareRoot_Result;
wire wSquareRoot_OutputReady;


FixedPointSquareRoot SQROOT1
(
	.Clock( Clock ),
	.Reset( Reset ),
	.Operand( wAddSubB_Result ),			
	.iInputReady( wAddSubBOutputReady && iOperation == `MAG),					
	.OutputReady( wSquareRoot_OutputReady ),	
	.Result( wSquareRoot_Result )
);
//------------------------------------------------------

assign wModulus2N_ResultA =  (iChannel_Ax  & wAddSubA_Result );
assign wModulus2N_ResultB =  (iChannel_Ay  & wAddSubB_Result );
assign wModulus2N_ResultC =  (iChannel_Az  & wAddSubC_Result );






//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&//
//****Mux for ResultA***
// Notice that the Dot Product or the Magnitud Result will
// output in ResultA.

always @ ( *  )
begin
	case ( iOperation )
	`RETURN:				ResultA = iChannel_Ax;
	`ADD:			  		ResultA = (wAddSubA_Result[63] == 1'b1) ? { 1'b1,wAddSubA_Result[30:0]} : {1'b0,wAddSubA_Result[30:0]};// & 32'h7FFFFFFF;
	`SUB:	  				ResultA = (wAddSubA_Result[63] == 1'b1) ? { 1'b1,wAddSubA_Result[30:0]} : {1'b0,wAddSubA_Result[30:0]};//wAddSubA_Result[31:0];
	`CROSS:				ResultA = (wAddSubA_Result[63] == 1'b1) ? { 1'b1,wAddSubA_Result[30:0]} : {1'b0,wAddSubA_Result[30:0]};//wAddSubA_Result[31:0];
	`DIV:		  	  		ResultA = wDivisionA_Result;
	`MUL:   				ResultA = wMultiplicationA_Result[31:0];
	`IMUL:            ResultA = wMultiplicationA_Result[31:0];
	`DOT:					ResultA = (wAddSubB_Result[63] == 1'b1) ? { 1'b1,wAddSubB_Result[30:0]} : {1'b0,wAddSubB_Result[30:0]};//wAddSubB_Result[31:0];
	`MAG:					ResultA = wSquareRoot_Result;
	`ZERO:				ResultA = 32'b0;
	`COPY:				ResultA = iChannel_Ax;
	`TMREAD:          ResultA = iTMEMReadData[95:64];
	`LEA:             ResultA = {16'b0,iCurrentIP};
	
	`SWIZZLE3D: ResultA  = wSwizzleOutputX;
	
	//Set Operations
	`UNSCALE:			ResultA  = iChannel_Ax >> `SCALE;
	`SETX,`RET:   	ResultA  = iChannel_Ax;
   `SETY:				ResultA  = iChannel_Bx; 	
	`SETZ:				ResultA  = iChannel_Bx;  
	`INC,`INCX,`INCY,`INCZ:					ResultA = (wAddSubA_Result[63] == 1'b1) ? { 1'b1,wAddSubA_Result[30:0]} : {1'b0,wAddSubA_Result[30:0]};
	`DEC:					ResultA = (wAddSubA_Result[63] == 1'b1) ? { 1'b1,wAddSubA_Result[30:0]} : {1'b0,wAddSubA_Result[30:0]};
	`MOD:					ResultA =  wModulus2N_ResultA;
	`FRAC:				ResultA = iChannel_Ax & (`WIDTH'hFFFFFFFF >> (`WIDTH - `SCALE));
	`MULP:			   ResultA = iChannel_Ax;
	`NEG:				 	ResultA = ~iChannel_Ax + 1'b1;
	`XCHANGEX:			ResultA  = iChannel_Bx;

	default:				
	begin
	`ifdef DEBUG
//	$display("%dns ALU: Error Unknown Operation: %d",$time,iOperation);
//	$stop();
	`endif
	ResultA =  32'b0;
	end
	endcase	
end
//------------------------------------------------------
//****Mux for RB***
always @ ( * )
begin
	case ( iOperation )
	`RETURN:				ResultB = iChannel_Ax;
	`ADD:			  		ResultB = (wAddSubB_Result[63] == 1'b1) ? {1'b1,wAddSubB_Result[30:0]} : {1'b0,wAddSubB_Result[30:0]}; // & 32'h7FFFFFFF;
	`SUB:		  			ResultB = (wAddSubB_Result[63] == 1'b1) ? {1'b1,wAddSubB_Result[30:0]} : {1'b0,wAddSubB_Result[30:0]}; //wAddSubB_Result[31:0];
	`CROSS:				ResultB = (wAddSubB_Result[63] == 1'b1) ? {1'b1,wAddSubB_Result[30:0]} : {1'b0,wAddSubB_Result[30:0]};//wAddSubB_Result[31:0];
	`DIV:		  	  		ResultB = wDivisionB_Result;
	`MUL:   				ResultB = wMultiplicationB_Result[31:0];
	`IMUL:            ResultB = wMultiplicationB_Result[31:0];
	`DOT:					ResultB = (wAddSubB_Result[63] == 1'b1) ? {1'b1,wAddSubB_Result[30:0]} : {1'b0,wAddSubB_Result[30:0]};//wAddSubB_Result[31:0];
	`MAG:					ResultB = wSquareRoot_Result;
	`ZERO:				ResultB = 32'b0;
	`COPY:				ResultB = iChannel_Ay;
	`TMREAD:          ResultB = iTMEMReadData[63:32];
	`LEA:             ResultB = {16'b0,iCurrentIP};
	
	//Set Operations
	`UNSCALE:			ResultB  = iChannel_Ay >> `SCALE;
	`SETX,`RET:		ResultB  = iChannel_By; 	// {Source1[95:64],Source0[63:32],Source0[31:0]}; 
	`SETY:				ResultB  = iChannel_Ax; 	// {Source0[95:64],Source1[95:64],Source0[31:0]}; 
	`SETZ:				ResultB  = iChannel_By;  // {Source0[95:64],Source0[63:32],Source1[95:64]}; 
	
	`SWIZZLE3D: 		ResultB  = wSwizzleOutputY;
	
	`INC,`INCX,`INCY,`INCZ:			  		ResultB = (wAddSubB_Result[63] == 1'b1) ? {1'b1,wAddSubB_Result[30:0]} : {1'b0,wAddSubB_Result[30:0]}; // & 32'h7FFFFFFF;
	`DEC:			  		ResultB = (wAddSubB_Result[63] == 1'b1) ? {1'b1,wAddSubB_Result[30:0]} : {1'b0,wAddSubB_Result[30:0]}; // & 32'h7FFFFFFF;
	`MOD:					ResultB =  wModulus2N_ResultB;
	`FRAC:				ResultB = iChannel_Ay & (`WIDTH'hFFFFFFFF >> (`WIDTH - `SCALE));
	`MULP:				ResultB = iChannel_Ay;
	`NEG:					ResultB = ~iChannel_Ay + 1'b1;
	`XCHANGEX:			ResultB = iChannel_Ay;
	
	default:				
	begin
	`ifdef DEBUG
	//$display("%dns ALU: Error Unknown Operation: %d",$time,iOperation);
	//$stop();
	`endif
	ResultB =  32'b0;
	end
	endcase	
end
//------------------------------------------------------
//****Mux for RC***
always @ ( * )
begin
	case ( iOperation )
	`RETURN:				ResultC = iChannel_Ax;
	`ADD:			  		ResultC = (wAddSubC_Result[63] == 1'b1) ? {1'b1,wAddSubC_Result[30:0]} : {1'b0,wAddSubC_Result[30:0]}; //wAddSubC_Result[31:0];// & 32'h7FFFFFFF;
	`SUB:		  			ResultC = (wAddSubC_Result[63] == 1'b1) ? {1'b1,wAddSubC_Result[30:0]} : {1'b0,wAddSubC_Result[30:0]}; //wAddSubC_Result[31:0];
	`CROSS:				ResultC = (wAddSubC_Result[63] == 1'b1) ? {1'b1,wAddSubC_Result[30:0]} : {1'b0,wAddSubC_Result[30:0]};//wAddSubC_Result[31:0];
	`DIV:		  	  		ResultC = wDivisionC_Result;
	`MUL:   				ResultC = wMultiplicationC_Result[31:0];
	`IMUL:            ResultC = wMultiplicationC_Result[31:0];
	`DOT:					ResultC = (wAddSubB_Result[63] == 1'b1) ? {1'b1,wAddSubB_Result[30:0]} : {1'b0,wAddSubB_Result[30:0]};//wAddSubB_Result[31:0];
	`MAG:					ResultC = wSquareRoot_Result;
	`ZERO:				ResultC = 32'b0;
	`COPY:				ResultC = iChannel_Az;
	`TMREAD:          ResultC = iTMEMReadData[31:0];
	`LEA:             ResultC = {16'b0,iCurrentIP};
	
	`SWIZZLE3D: ResultC  = wSwizzleOutputZ;
	
	//Set Operations
	`UNSCALE:			ResultC  = iChannel_Az >> `SCALE;
	`SETX,`RET:		ResultC  = iChannel_Bz; 	// {Source1[95:64],Source0[63:32],Source0[31:0]}; 
	`SETY:				ResultC  = iChannel_Bz; 	// {Source0[95:64],Source1[95:64],Source0[31:0]}; 
	`SETZ:				ResultC  = iChannel_Ax;  // {Source0[95:64],Source0[63:32],Source1[95:64]}; 
	
	`INC,`INCX,`INCY,`INCZ:			  		ResultC = (wAddSubC_Result[63] == 1'b1) ? {1'b1,wAddSubC_Result[30:0]} : {1'b0,wAddSubC_Result[30:0]}; //wAddSubC_Result[31:0];// & 32'h7FFFFFFF;
	`DEC:			  		ResultC = (wAddSubC_Result[63] == 1'b1) ? {1'b1,wAddSubC_Result[30:0]} : {1'b0,wAddSubC_Result[30:0]}; //wAddSubC_Result[31:0];// & 32'h7FFFFFFF;
	`MOD:					ResultC =  wModulus2N_ResultC;
	`FRAC:				ResultC = iChannel_Az & (`WIDTH'hFFFFFFFF >> (`WIDTH - `SCALE));
	`MULP:				ResultC = wMultiplicationA_Result[31:0];
	`NEG:					ResultC = ~iChannel_Az + 1'b1;
	`XCHANGEX:			ResultC = iChannel_Az;
	default:
	begin
	`ifdef DEBUG
	//$display("%dns ALU: Error Unknown Operation: %d",$time,iOperation);
	//$stop();
	`endif
	ResultC =  32'b0;
	end
	endcase	
end
//------------------------------------------------------------------------


always @ ( * )
begin
	case (iOperation)
	`JMP,`CALL,`RET: oBranchTaken = OutputReady;
	`JGX:	oBranchTaken = wArithmeticComparison_Result;
	`JGY:	oBranchTaken = wArithmeticComparison_Result;
	`JGZ:	oBranchTaken = wArithmeticComparison_Result;
	
	`JLX:	oBranchTaken = wArithmeticComparison_Result;
	`JLY:	oBranchTaken = wArithmeticComparison_Result;
	`JLZ:	oBranchTaken = wArithmeticComparison_Result;
	
	`JEQX:	oBranchTaken = wArithmeticComparison_Result;
	`JEQY:	oBranchTaken = wArithmeticComparison_Result;
	`JEQZ:	oBranchTaken = wArithmeticComparison_Result;
	
	`JNEX:	oBranchTaken = wArithmeticComparison_Result;
	`JNEY:	oBranchTaken = wArithmeticComparison_Result;
	`JNEZ:	oBranchTaken = wArithmeticComparison_Result;
	
	`JGEX:	oBranchTaken = wArithmeticComparison_Result;
	`JGEY:	oBranchTaken = wArithmeticComparison_Result;
	`JGEZ:	oBranchTaken = wArithmeticComparison_Result;
	
	`JLEX:	oBranchTaken = wArithmeticComparison_Result;
	`JLEY:	oBranchTaken = wArithmeticComparison_Result;
	`JLEZ:	oBranchTaken = wArithmeticComparison_Result;
	
	default: oBranchTaken = 0;
	endcase
	
end

always @ ( * )
begin
	case (iOperation)
	
		`JMP,`CALL,`RET,`JGX,`JGY,`JGZ,`JLX,`JLY,`JLZ,`JEQX,`JEQY,`JEQZ,
		`JNEX,`JNEY,`JNEZ,`JGEX,`JGEY,`JGEZ: oBranchNotTaken = !oBranchTaken && OutputReady;
		`JLEX: oBranchNotTaken = !oBranchTaken && OutputReady;
		`JLEY: oBranchNotTaken = !oBranchTaken && OutputReady;
		`JLEZ: oBranchNotTaken = !oBranchTaken && OutputReady;
	default:
		oBranchNotTaken = 0;
	endcase
end
//------------------------------------------------------------------------
//Output ready logic Stuff for Division...
//Some FFT will hopefully do the trick

wire wDivisionOutputReadyA,wDivisionOutputReadyB,wDivisionOutputReadyC;
wire wDivisionOutputReady;


assign wAddSubAOutputReady = wAddSubA_OutputReady;
assign wAddSubBOutputReady = wAddSubB_OutputReady;
assign wAddSubCOutputReady = wAddSubC_OutputReady;


FFT1 FFT_DivisionA
  (
   .D(1'b1),
   .Clock( wDivisionA_OutputReady ), 
   .Reset( iInputReady ), 
   .Q( wDivisionOutputReadyA )
 );

FFT1 FFT_DivisionB
  (
   .D(1'b1),
   .Clock( wDivisionB_OutputReady ), 
   .Reset( iInputReady ), 
   .Q( wDivisionOutputReadyB )
 );
 
 FFT1 FFT_DivisionC
  (
   .D(1'b1),
   .Clock( wDivisionC_OutputReady ), 
   .Reset( iInputReady ), 
   .Q( wDivisionOutputReadyC )
 );
 
 assign wDivisionOutputReady = 
 ( wDivisionOutputReadyA && wDivisionOutputReadyB && wDivisionOutputReadyC );
 
assign wMultiplicationOutputReadyA = wMultiplicationA_OutputReady;
assign wMultiplicationOutputReadyB = wMultiplicationB_OutputReady;
assign wMultiplicationOutputReadyC = wMultiplicationC_OutputReady;
assign wMultiplicationOutputReadyD = wMultiplicationD_OutputReady;
 
 assign wMultiplicationOutputReady = 
 ( wMultiplicationOutputReadyA && wMultiplicationOutputReadyB && wMultiplicationOutputReadyC );
 
 wire wSquareRootOutputReady;
 FFT1 FFT_Sqrt
  (
   .D(1'b1),
   .Clock( wSquareRoot_OutputReady ), 
   .Reset( iInputReady ), 
   .Q( wSquareRootOutputReady )
 );
 
 
//------------------------------------------------------------------------
wire wOutputDelay1Cycle,wOutputDelay2Cycle,wOutputDelay3Cycle;


FFD_POSEDGE_ASYNC_RESET # (1) FFOutputReadyDelay2
(
	.Clock( Clock ),
	.Clear( Reset ),
	.D( iInputReady ),
	.Q( wOutputDelay1Cycle )
);

FFD_POSEDGE_ASYNC_RESET # (1) FFOutputReadyDelay22
(
	.Clock( Clock  ),
	.Clear( Reset ),
	.D( wOutputDelay1Cycle ),
	.Q( wOutputDelay2Cycle )
);


FFD_POSEDGE_ASYNC_RESET # (1) FFOutputReadyDelay222
(
	.Clock( Clock &&  wOperation == `OMWRITE),
	.Clear( Reset ),
	.D( wOutputDelay2Cycle ),
	.Q( wOutputDelay3Cycle )
);




FFD_POSEDGE_SYNCRONOUS_RESET # ( `INSTRUCTION_OP_LENGTH ) SourceZ2
(
	.Clock( Clock ),
	.Reset( Reset ),
	.Enable( iInputReady ),
	.D( iOperation ),
	.Q(wOperation)
);


//Mux for output ready signal
always @ ( * )
begin
	case ( wOperation )
	`UNSCALE:			OutputReady  = wOutputDelay1Cycle;
	`RETURN: OutputReady = wOutputDelay1Cycle;
	
	`NOP: OutputReady = wOutputDelay1Cycle;
	`FRAC: OutputReady = wOutputDelay1Cycle;
	`NEG: OutputReady = wOutputDelay1Cycle;
	`OMWRITE: OutputReady = wOutputDelay3Cycle;
	`TMREAD:  OutputReady = wTMReadOutputReady;  //One cycle after TMEM data availale asserted
	
	`ifdef DEBUG
	//Debug Print behaves as a NOP in terms of ALU...
	`DEBUG_PRINT: OutputReady = wOutputDelay1Cycle;
	`endif
	
	`ADD,`INC,`INCX,`INCY,`INCZ:		OutputReady = 	wAddSubAOutputReady &&
									wAddSubBOutputReady &&
									wAddSubCOutputReady;
														  
	`SUB,`DEC:	  	OutputReady = 	wAddSubAOutputReady &&
									wAddSubBOutputReady &&
									wAddSubCOutputReady;
															
	`DIV:		OutputReady = 	wDivisionOutputReady; 
	
															
	`MUL,`IMUL:   	OutputReady = 	wMultiplicationOutputReady;
	`MULP:  OutputReady =  wMultiplicationOutputReadyA;
															
	`DOT:		OutputReady = wAddSubBOutputReady;
	
	`CROSS:	OutputReady = 	wAddSubAOutputReady && 
									wAddSubBOutputReady && 
									wAddSubCOutputReady;
	
	`MAG:		OutputReady = wSquareRootOutputReady;
	
	`ZERO:	OutputReady = wOutputDelay1Cycle;
	
	`COPY:	OutputReady = wOutputDelay1Cycle;
	
	`SWIZZLE3D: OutputReady = wOutputDelay1Cycle;
	
	`SETX,`SETY,`SETZ,`JMP,`LEA,`CALL,`RET: 	OutputReady = wOutputDelay1Cycle;
	 

	
	`JGX,`JGY,`JGZ:				OutputReady = ArithmeticComparison_OutputReady;
	`JLX,`JLY,`JLZ:				OutputReady = ArithmeticComparison_OutputReady;
	`JEQX,`JEQY,`JEQZ:			OutputReady = ArithmeticComparison_OutputReady;
	`JNEX,`JNEY,`JNEZ:			OutputReady = ArithmeticComparison_OutputReady;
	`JGEX,`JGEY,`JGEZ:			OutputReady = ArithmeticComparison_OutputReady;
	`JLEX,`JLEY,`JLEZ:			OutputReady = ArithmeticComparison_OutputReady;
	
	`MOD: OutputReady = wAddSubAOutputReady &&				//TODO: wait 1 more cycle
									wAddSubBOutputReady &&
									wAddSubCOutputReady;
									
	`XCHANGEX: OutputReady = wOutputDelay1Cycle;
	
	
	default:	
	begin
		OutputReady =  32'b0;
		//`ifdef DEBUG
		//$display("*** ALU ERROR: iOperation = %d ***",iOperation);
		//`endif
	end
	
	endcase	
end

endmodule
//------------------------------------------------------------------------
