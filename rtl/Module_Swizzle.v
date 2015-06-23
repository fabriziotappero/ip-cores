`timescale 1ns / 1ps
 `include "aDefinitions.v"
 //---------------------------------------------------------------------------
 module Swizzle3D
(
	input wire [`WIDTH-1:0] Source0_X,
	input wire [`WIDTH-1:0] Source0_Y,
	input wire [`WIDTH-1:0] Source0_Z,
	input wire [`WIDTH-1:0] iOperation,
	
	output reg [`WIDTH-1:0] SwizzleX,
	output reg [`WIDTH-1:0] SwizzleY,
	output reg [`WIDTH-1:0] SwizzleZ
 	
 );
 
 //wire [31:0] SwizzleX,SwizzleY,SwizzleZ;
 //-----------------------------------------------------
 always @ ( * )
 begin
	case (iOperation)
			`SWIZZLE_XXX: 	SwizzleX = Source0_X;
			`SWIZZLE_YYY: 	SwizzleX = Source0_Y;
			`SWIZZLE_ZZZ: 	SwizzleX = Source0_Z;
			`SWIZZLE_YXZ:	SwizzleX = Source0_Y;
			default: 		SwizzleX =  `DATA_ROW_WIDTH'd0;
	endcase
end
//-----------------------------------------------------
 always @ ( * )
 begin	
	case (iOperation)
			`SWIZZLE_XXX: 	SwizzleY = Source0_X;
			`SWIZZLE_YYY: 	SwizzleY = Source0_Y;
			`SWIZZLE_ZZZ: 	SwizzleY = Source0_Z;
			`SWIZZLE_YXZ:  SwizzleY = Source0_X;
			default: 		SwizzleY =  `DATA_ROW_WIDTH'd0;
	endcase
end	
//-----------------------------------------------------
 always @ ( * )
 begin
	case (iOperation)
			`SWIZZLE_XXX: 	SwizzleZ = Source0_X;
			`SWIZZLE_YYY: 	SwizzleZ = Source0_Y;
			`SWIZZLE_ZZZ: 	SwizzleZ = Source0_Z;
			`SWIZZLE_YXZ:  SwizzleZ = Source0_Z;
			default: 		SwizzleZ =  `DATA_ROW_WIDTH'd0;
	endcase
 end
 //-----------------------------------------------------
 endmodule
//---------------------------------------------------------------------------