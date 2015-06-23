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
`define EXEU_AFTER_RESET							0
`define EXEU_INITIAL_STATE 						1
`define EXEU_WAIT_FOR_DECODE						2
`define EXEU_FETCH_DECODED_INST					3
`define EXEU_WAIT_FOR_ALU_EXECUTION				4
`define EXEU_WRITE_BACK_TO_RAM					5
`define EXEU_HANDLE_JUMP							7



module ExecutionFSM
(
input wire								Clock,
input wire								Reset,

input	wire										iDecodeDone,
input wire[`INSTRUCTION_OP_LENGTH-1:0]	iOperation,
input wire[`DATA_ROW_WIDTH-1:0]				iSource0,iSource1,
input wire[`DATA_ADDRESS_WIDTH-1:0]		iDestination,
inout wire[`DATA_ROW_WIDTH-1:0]				RAMBus,
//output 	reg									ReadyForNextInstruction,
output wire 									oJumpFlag 			,
output  wire [`ROM_ADDRESS_WIDTH-1:0]	oJumpIp 				,
output  wire									oRAMWriteEnable 	,
output  wire [`DATA_ADDRESS_WIDTH-1:0]	oRAMWriteAddress 	,
output  wire 									oExeLatchedValues,
output  reg										oBusy ,

//ALU ports and control signals
output  wire [`INSTRUCTION_OP_LENGTH-1:0]				oALUOperation,		
output  wire [`WIDTH-1:0]									oALUChannelX1,
output  wire [`WIDTH-1:0]									oALUChannelY1,
output  wire [`WIDTH-1:0]									oALUChannelZ1,
output  wire [`WIDTH-1:0]									oALUChannelX2,
output  wire [`WIDTH-1:0]									oALUChannelY2,
output  wire [`WIDTH-1:0]									oALUChannelZ2,
output  wire													oTriggerALU,

input  wire   [`WIDTH-1:0]									iALUResultX,
input  wire	  [`WIDTH-1:0]									iALUResultY,
input wire	  [`WIDTH-1:0]									iALUResultZ,
input wire		 												iALUOutputReady,
input	wire														iBranchTaken,
input wire														iBranchNotTaken,


`ifdef DEBUG 
	input wire[`ROM_ADDRESS_WIDTH-1:0]  iDebug_CurrentIP,
	input wire [`MAX_CORES-1:0]         iDebug_CoreID,
`endif
//Data forward Signals
output wire [`DATA_ADDRESS_WIDTH-1:0] oLastDestination


);

wire wLatchNow;
reg rInputLatchesEnabled;

//If ALU says jump, just pass along
assign oJumpFlag = iBranchTaken; 
//JumpIP is the instruction destination (= oRAMWriteAddress)
assign oJumpIp = oRAMWriteAddress;

assign wLatchNow = iDecodeDone & rInputLatchesEnabled;
assign oExeLatchedValues = wLatchNow;
assign oTriggerALU = wLatchNow;

wire wOperationIsJump;
assign wOperationIsJump = iBranchTaken || iBranchNotTaken;

//Don't allow me to write back back if the operation is a NOP
`ifdef DEBUG
	assign oRAMWriteEnable = iALUOutputReady && !wOperationIsJump && 
		(oALUOperation != `NOP) && oALUOperation != `DEBUG_PRINT;
`else
	assign oRAMWriteEnable = iALUOutputReady && !wOperationIsJump && oALUOperation != `NOP;
`endif	


assign RAMBus = ( oRAMWriteEnable ) ? {iALUResultX,iALUResultY,iALUResultZ} : `DATA_ROW_WIDTH'bz;

assign oALUChannelX1 = iSource1[95:64];
assign oALUChannelY1 = iSource1[63:32];
assign oALUChannelZ1 = iSource1[31:0];

assign oALUChannelX2 = iSource0[95:64];
assign oALUChannelY2 = iSource0[63:32];
assign oALUChannelZ2 = iSource0[31:0];
 
/*
FF32_POSEDGE_SYNCRONOUS_RESET SourceX1
(
	.Clock( wLatchNow ),
	.Clear( Reset ),
	.D( iSource1[95:64] ),
	.Q( oALUChannelX1 )
);

FF32_POSEDGE_SYNCRONOUS_RESET SourceY1
(
	.Clock( wLatchNow ),
	.Clear( Reset ),
	.D( iSource1[63:32] ),
	.Q( oALUChannelY1 )
);

FF32_POSEDGE_SYNCRONOUS_RESET SourceZ1
(
	.Clock( wLatchNow ),
	.Clear( Reset ),
	.D( iSource1[31:0] ),
	.Q( oALUChannelZ1 )
);
*/
/*
FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) SourceX1
(
	.Clock( Clock ),//wLatchNow ),
	.Reset( Reset),
	.Enable( wLatchNow ),//1'b1 ),
	.D( iSource1[95:64] ),
	.Q(oALUChannelX1)
);
FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) SourceY1
(
	.Clock( Clock ),//wLatchNow ),
	.Reset( Reset),
	.Enable( wLatchNow ),//1'b1 ),
	.D( iSource1[63:32] ),
	.Q(oALUChannelY1)
);
FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) SourceZ1
(
	.Clock( Clock ),//wLatchNow ),
	.Reset( Reset),
	.Enable( wLatchNow ),//1'b1 ),
	.D( iSource1[31:0] ),
	.Q(oALUChannelZ1)
);
*/
/*
FF32_POSEDGE_SYNCRONOUS_RESET SourceX2
(
	.Clock( wLatchNow ),
	.Clear( Reset ),
	.D( iSource0[95:64] ),
	.Q( oALUChannelX2 )
);

FF32_POSEDGE_SYNCRONOUS_RESET SourceY2
(
	.Clock( wLatchNow ),
	.Clear( Reset ),
	.D( iSource0[63:32] ),
	.Q( oALUChannelY2 )
);

FF32_POSEDGE_SYNCRONOUS_RESET SourceZ2
(
	.Clock( wLatchNow ),
	.Clear( Reset ),
	.D( iSource0[31:0] ),
	.Q( oALUChannelZ2 )
);
*/
/*
FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) SourceX2
(
	.Clock( Clock ),//wLatchNow ),
	.Reset( Reset),
	.Enable( wLatchNow ),//1'b1 ),
	.D( iSource0[95:64] ),
	.Q(oALUChannelX2)
);
FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) SourceY2
(
	.Clock( Clock ),//wLatchNow ),
	.Reset( Reset),
	.Enable( wLatchNow ),//1'b1 ),
	.D( iSource0[63:32] ),
	.Q(oALUChannelY2)
);
FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) SourceZ2
(
	.Clock( Clock ),//wLatchNow ),
	.Reset( Reset),
	.Enable( wLatchNow ),//1'b1 ),
	.D( iSource0[31:0] ),
	.Q(oALUChannelZ2)
);
*/
//Finally one more latch to store 
//the iOperation and the destination


assign oALUOperation = iOperation;
//assign oRAMWriteAddress = iDestination;
/*
FF_OPCODE_POSEDGE_SYNCRONOUS_RESET FFOperation
(
	.Clock( wLatchNow ),
	.Clear( Reset ),
	.D( iOperation  ),
	.Q( oALUOperation )
	
);


FF16_POSEDGE_SYNCRONOUS_RESET PSRegDestination
(
	.Clock( wLatchNow  ),
	.Clear( Reset ),
	.D( iDestination  ),
	.Q( oRAMWriteAddress )
	
);
*/
/*
FFD_POSEDGE_SYNCRONOUS_RESET # ( `INSTRUCTION_OP_LENGTH ) FFOperation
(
	.Clock( Clock ),//wLatchNow ),
	.Reset( Reset),
	.Enable( wLatchNow ),//1'b1 ),
	.D( iOperation ),
	.Q(oALUOperation)
);
*/
FFD_POSEDGE_SYNCRONOUS_RESET # ( `DATA_ADDRESS_WIDTH ) PSRegDestination
(
	.Clock( Clock ),//wLatchNow ),
	.Reset( Reset),
	.Enable( wLatchNow ),//1'b1 ),
	.D( iDestination ),
	.Q(oRAMWriteAddress)
);

//Data forwarding
assign oLastDestination = oRAMWriteAddress;

reg [7:0] CurrentState; 
reg [7:0] NextState; 


//------------------------------------------------
  always @(posedge Clock or posedge Reset) 
  begin 
  
		
			
    if (Reset)  
		CurrentState <= `EXEU_AFTER_RESET; 
    else        
		CurrentState <= NextState; 
		
  end
//------------------------------------------------


always @( * ) 
   begin 
        case (CurrentState) 
		  //------------------------------------------
		  `EXEU_AFTER_RESET:
		  begin
				//ReadyForNextInstruction <= 1;
				oBusy							<= 0;
				rInputLatchesEnabled		<=	1;
				
	
				NextState 	<= `EXEU_WAIT_FOR_DECODE;
		  end
		  //------------------------------------------
		  /**
			At the same time iDecodeDone goes to 1, our Flops
			will store the value, so next clock cycle we can
			tell IDU to go ahead and decode the next instruction
			in the pipeline.
		  */
		  `EXEU_WAIT_FOR_DECODE:
		  begin
			

				//ReadyForNextInstruction <= 1;
				oBusy							<= 0;
				rInputLatchesEnabled		<=	1;
			
			
			if ( iDecodeDone )	//This same thing triggers the ALU
				NextState	<= `EXEU_WAIT_FOR_ALU_EXECUTION;
			else
				NextState	<= `EXEU_WAIT_FOR_DECODE;
		  end
		  //------------------------------------------
		  /*
		  If the instruction is aritmetic then pass the parameters
		  the ALU, else if it store iOperation then...
		  */
		  `EXEU_WAIT_FOR_ALU_EXECUTION:
		  begin

				//ReadyForNextInstruction <= 0;						//*
				oBusy							<= 1;
				rInputLatchesEnabled		<=	0;		//NO INTERRUPTIONS WHILE WE WAIT!!
				

				
				if ( iALUOutputReady )	/////This same thing enables writing th results to RAM
					NextState <= `EXEU_WAIT_FOR_DECODE;	
				else	
					NextState <= `EXEU_WAIT_FOR_ALU_EXECUTION;	
		  end
		  //------------------------------------------
		  `EXEU_WRITE_BACK_TO_RAM:
		  begin
	
				//ReadyForNextInstruction <= 0;						
				oBusy							<= 1;
				rInputLatchesEnabled		<=	1;
						
			if ( iDecodeDone )
				NextState <= `EXEU_WAIT_FOR_ALU_EXECUTION;
			else
				NextState <= `EXEU_WAIT_FOR_DECODE;
		
		  end
		
		  //------------------------------------------
		  default:
		  begin
		  
				//ReadyForNextInstruction <= 1;
				oBusy							<= 0;
				rInputLatchesEnabled		<=	1;

				NextState <= `EXEU_AFTER_RESET;
		  end
		  //------------------------------------------
	endcase
end

//-----------------------------------------------------------------------
`ifdef DUMP_CODE
integer ucode_file;
integer reg_log;
initial
begin

	$display("Opening ucode dump file....\n");
	ucode_file = $fopen("Code.log","w");
	$fwrite(ucode_file,"\n\n************ Theia UCODE DUMP *******\n\n\n\n");
	$display("Opening Register lof file...\n");
	reg_log = $fopen("Registers.log","w");
	
end

`endif //Ucode dump

//-----------------------------------------------------------------------
`ifdef DEBUG
wire [`WIDTH-1:0] wALUChannelX1,wALUChannelY1,wALUChannelZ1;
wire [`WIDTH-1:0] wALUChannelX2,wALUChannelY2,wALUChannelZ2;

FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) SourceX1
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( wLatchNow ),
	.D( iSource1[95:64] ),
	.Q(wALUChannelX1)
);
FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) SourceY1
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( wLatchNow ),
	.D( iSource1[63:32] ),
	.Q(wALUChannelY1)
);
FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) SourceZ1
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( wLatchNow ),
	.D( iSource1[31:0] ),
	.Q(wALUChannelZ1)
);


FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) SourceX2
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( wLatchNow ),
	.D( iSource0[95:64] ),
	.Q(wALUChannelX2)
);
FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) SourceY2
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( wLatchNow ),
	.D( iSource0[63:32] ),
	.Q(wALUChannelY2)
);
FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) SourceZ2
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( wLatchNow ),
	.D( iSource0[31:0] ),
	.Q(wALUChannelZ2)
);


	always @ (posedge iDecodeDone && iDebug_CoreID == `DEBUG_CORE)
	begin
		`LOGME"[CORE %d] IP:%d", iDebug_CoreID,iDebug_CurrentIP);
	end

	always @ (negedge  Clock && iDebug_CoreID == `DEBUG_CORE)
	begin
	if ( iALUOutputReady )
	begin
	
		
		if (iBranchTaken)
			`LOGME"<BT>");
			
		if (iBranchNotTaken	)
			`LOGME"<BNT>");
			
		if (oRAMWriteEnable)
			`LOGME"<WE>");
	
		`LOGME "(%dns ",$time); 
					case ( oALUOperation )
					`RETURN: `LOGME"RETURN"); 
					`ADD: 	`LOGME"ADD");				
					`SUB:		`LOGME"SUB");	
					`DIV:		`LOGME"DIV");		
					`MUL: 	`LOGME"MUL");			
					`MAG:		`LOGME"MAG");	
					`JGX:		`LOGME"JGX");
					`JLX:		`LOGME"JLX");					
					`JGEX:	`LOGME"JGEX");				
					`JGEY:	`LOGME"JGEY");			
					`JGEZ:	`LOGME"JGEZ");			
					`JLEX:	`LOGME"JLEX");			
					`JLEY:	`LOGME"JLEY");			
					`JLEZ:	`LOGME"JLEZ");			
					`JMP:		`LOGME"JMP");						
					`ZERO:	`LOGME"ZERO");			
					`JNEX:	`LOGME"JNEX");			
					`JNEY:	`LOGME"JNEY");			
					`JNEZ:	`LOGME"JNEZ");			
					`JEQX:	`LOGME"JEQX");			
					`JEQY:	`LOGME"JEQY");			
					`JEQZ:	`LOGME"JEQZ");			
					`CROSS:	`LOGME"CROSS");			
					`DOT:		`LOGME"DOT");			
					`SETX:	`LOGME"SETX");			
					`SETY:	`LOGME"SETY");			
					`SETZ:	`LOGME"SETZ");
					`NOP: 	`LOGME"NOP");
					`COPY:	`LOGME"COPY");
					`INC:		`LOGME"INC");
					`DEC:		`LOGME"DEC");
					`MOD:		`LOGME"MOD");
					`FRAC:	`LOGME"FRAC");
					`NEG:    `LOGME"NEG");
					`SWIZZLE3D: `LOGME"SWIZZLE3D");
					`MULP:		`LOGME"MULP");
					`XCHANGEX: 	`LOGME"XCHANGEX");
					`IMUL:      `LOGME"IMUL");
					`UNSCALE:      `LOGME"UNSCALE");
					`INCX: `LOGME"INCX");
					`INCY: `LOGME"INCY");
					`INCZ: `LOGME"INCZ");
					`OMWRITE: `LOGME"OMWRITE");
					`TMREAD: `LOGME"TMREAD");
					`LEA:     `LOGME"LEA");
					`CALL:    `LOGME"CALL");
					`RET:     `LOGME"RET");
					`DEBUG_PRINT:
					begin
						`LOGME"DEBUG_PRINT");
					
					end
					default:
					begin
						`LOGME"**********ERROR UNKNOWN OP*********");
						$display("%dns EXE: Error Unknown Instruction : %d", $time,oALUOperation);
					//	$stop();
					end	
					endcase
					
					`LOGME"\t %h [ %h %h %h ][ %h %h %h ] = ",
					oRAMWriteAddress,
					wALUChannelX1,wALUChannelY1,wALUChannelZ1,
					wALUChannelX2,wALUChannelY2,wALUChannelZ2
					
					);
					
					if (oALUOperation == `RETURN)
						`LOGME"\n\n\n");
					
		end			
	end //always
	
	always @ ( negedge Clock && iDebug_CoreID == `DEBUG_CORE )
	begin
	if ( iALUOutputReady )
		`LOGME" [ %h %h %h ])\n",iALUResultX,iALUResultY,iALUResultZ);
	end //always
`endif

endmodule
