//---------------------------------------------------------------------------------------
//	Project:	ADPCM Encoder 
// 
//	Filename:	ima_adpcm_enc.v			(February 18, 2010)
// 
//	Author(s):	Moti Litochevski 
// 
//	Description:
//		This module implements the IMA ADPCM audio encoding algorithm. The input samples 
// 		interface is 16 bits wide. ADPCM encoded data output is 4 bits wide and is sent 
//		for every new input sample. 
//
//---------------------------------------------------------------------------------------
//
//	To Do: 
//	- 
// 
//---------------------------------------------------------------------------------------
// 
//	Copyright (C) 2010 Moti Litochevski 
// 
//	This source file may be used and distributed without restriction provided that this 
//	copyright statement is not removed from the file and that any derivative work 
//	contains the original copyright notice and the associated disclaimer.
//
//	THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, 
//	INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTIBILITY AND 
//	FITNESS FOR A PARTICULAR PURPOSE. 
// 
//---------------------------------------------------------------------------------------

module ima_adpcm_enc
(
	clock, reset, 
	inSamp, inValid,
	inReady,
	outPCM, outValid, 
	outPredictSamp, outStepIndex 
);
//---------------------------------------------------------------------------------------
// global inputs 
input			reset;
input			clock;

// input interface 
input	[15:0]	inSamp;			// input sample 
input			inValid;		// input valid flag 
output			inReady;		// input ready indication  

// output interface 
output	[3:0]	outPCM;			// ADPCM encoded value 
output			outValid;		// output valid flag 
output	[15:0]	outPredictSamp;	// predictor sample value output 
output	[6:0]	outStepIndex;	// step index value output 

//---------------------------------------------------------------------------------------
// registers output 
reg [3:0] outPCM;
reg outValid, inReady;

// internals 
reg [2:0] pcmSq;
reg [19:0] sampDiff, prePredSamp;
reg [18:0] predictorSamp, dequantSamp;
reg [3:0] prePCM;
reg [14:0] stepSize;	// unsigned 
reg [6:0] stepIndex;	// unsigned 
reg [4:0] stepDelta;
wire [7:0] preStepIndex;

// constant declarations 
// main state machine 
`define PCM_IDLE	3'd0
`define PCM_SIGN	3'd1
`define PCM_BIT2	3'd2
`define PCM_BIT1	3'd3
`define PCM_BIT0	3'd4
`define PCM_DONE	3'd5

//---------------------------------------------------------------------------------------
// module implementation 
// encoder main control process 
always @ (posedge clock or posedge reset)
begin 
	if (reset)
	begin 
		pcmSq <= 3'b0;
		sampDiff <= 20'b0;
		predictorSamp <= 19'b0;
		dequantSamp <= 19'b0;
		prePCM <= 4'b0;
		inReady <= 1'b0;
	end 
	else 
	begin 
		case (pcmSq)
			// waiting for a new input sample 
			`PCM_IDLE:
				// on a new input sample calculate the difference between the input 
				// sample and predictor output 
				if (inValid) 
				begin 
					// compute the difference between the current predictor output and the input 
					// sample with extended width to prevent any wrapping.
					sampDiff <= {inSamp[15], inSamp, 3'b0} - {predictorSamp[18], predictorSamp};
					
					// sign that input is not ready 
					inReady <= 1'b0;
					
					// switch to next state 
					pcmSq <= `PCM_SIGN;
				end 
				else 
					// sign that input is ready 
					inReady <= 1'b1;
			
			// check the difference sign and set PCM sign bit accordingly 
			`PCM_SIGN:
				begin 
					// check the difference sign 
					if (sampDiff[19])
					begin 
						// set PCM sign bit and negate the calculated sample difference 
						prePCM[3] <= 1'b1;
						sampDiff <= (~sampDiff) + 20'd1;
					end 
					else 
						// clear the PCM sign bit 
						prePCM[3] <= 1'b0;
						
					// prepare the de-quantizer sample 
					dequantSamp <= {4'b0, stepSize};
						
					// switch to next state 
					pcmSq <= `PCM_BIT2;
				end 

			// determine quantizer bit 2 value 
			`PCM_BIT2:
				begin 
					// check if the difference is larger than step size 
					if (sampDiff[19:3] >= {2'b0, stepSize})
					begin 
						// bit 2 of PCM nibble is set 
						prePCM[2] <= 1'b1;
						// update the difference value and the de-quantizer value 
						sampDiff[19:3] <= sampDiff[19:3] - {2'b0, stepSize};
						dequantSamp <= dequantSamp + {1'b0, stepSize, 3'b0};
					end 
					else 
						// bit 2 of PCM nibble is zero 
						prePCM[2] <= 1'b0;
					
					// switch to next state 
					pcmSq <= `PCM_BIT1;
				end 
			
			// determine quantizer bit 1 value 
			`PCM_BIT1:
				begin 
					// check if the difference is larger than step size 
					if (sampDiff[19:2] >= {3'b0, stepSize})
					begin 
						// bit 1 of PCM nibble is set 
						prePCM[1] <= 1'b1;
						// update the difference value and the de-quantizer value 
						sampDiff[19:2] <= sampDiff[19:2] - {3'b0, stepSize};
						dequantSamp <= dequantSamp + {2'b0, stepSize, 2'b0};
					end 
					else 
						// bit 1 of PCM nibble is zero 
						prePCM[1] <= 1'b0;
					
					// switch to next state 
					pcmSq <= `PCM_BIT0;
				end 
			
			// determine quantizer bit 0 value 
			`PCM_BIT0:
				begin 
					// check if the difference is larger than step size 
					if (sampDiff[19:1] >= {4'b0, stepSize})
					begin 
						// bit 0 of PCM nibble is set 
						prePCM[0] <= 1'b1;
						// update the de-quantizer value 
						dequantSamp <= dequantSamp + {3'b0, stepSize, 1'b0};
					end 
					else 
						// bit 0 of PCM nibble is zero 
						prePCM[0] <= 1'b0;
					
					// switch to next state 
					pcmSq <= `PCM_DONE;
				end 

			// check saturation condition on new predictor sample and update it 
			`PCM_DONE:
				begin 
					// check the new predictor output saturation conditions 
					if (prePredSamp[19] && !prePredSamp[18])
						// negative saturation 
						predictorSamp <= {1'b1, 18'b0};
					else if (!prePredSamp[19] && prePredSamp[18])
						// positive saturation 
						predictorSamp <= {1'b0, {18{1'b1}}};
					else 
						// no saturation 
						predictorSamp <= prePredSamp[18:0];
				
					// sign that input is ready 
					inReady <= 1'b1;
					
					// return to idle state 
					pcmSq <= `PCM_IDLE;
				end 
			
			// unused states 
			default:	pcmSq <= `PCM_IDLE;
		endcase 
	end 
end 
// internal state output assignment 
assign outPredictSamp = predictorSamp[18:3] + predictorSamp[2];
assign outStepIndex = stepIndex;

// calculate the update predictor sample before it is updated by the state machine 
always @ (prePCM or predictorSamp or dequantSamp)
begin 
	if (prePCM[3])
		prePredSamp <= {predictorSamp[18], predictorSamp} - {1'b0, dequantSamp};
	else 
		prePredSamp <= {predictorSamp[18], predictorSamp} + {1'b0, dequantSamp};
end  

// output interface 
always @ (posedge clock or posedge reset)
begin 
	if (reset)
	begin 
		outPCM <= 4'b0;
		outValid <= 1'b0;
	end 
	else if (pcmSq == `PCM_DONE)
	begin 
		outPCM <= prePCM;
		outValid <= 1'b1;
	end 
	else 
		outValid <= 1'b0;
end 

// quantizer index adaptation lookup table 
always @ (prePCM)
begin 
	case (prePCM[2:0]) 
		3'd0:	stepDelta <= 5'd31;		// = -1 
		3'd1:	stepDelta <= 5'd31;		// = -1 
		3'd2:	stepDelta <= 5'd31;		// = -1 
		3'd3:	stepDelta <= 5'd31;		// = -1 
		3'd4:	stepDelta <= 5'd2;
		3'd5:	stepDelta <= 5'd4;
		3'd6:	stepDelta <= 5'd6;
		3'd7:	stepDelta <= 5'd8;
	endcase 
end 
// calculate the new index value before saturation 
assign preStepIndex = {1'b0, stepIndex} + {{3{stepDelta[4]}}, stepDelta};

// update the step index with saturation checking 
always @ (posedge clock or posedge reset)
begin 
	if (reset)
		stepIndex <= 7'b0;
	else if (pcmSq == `PCM_DONE) 
	begin 
		// check is the updated step value should be saturated 
		if (preStepIndex[7])
			stepIndex <= 7'd0;
		else if (preStepIndex[6:0] > 7'd88)
			stepIndex <= 7'd88;
		else 
			stepIndex <= preStepIndex[6:0];
	end 
end 

// quantizer step size lookup table 
always @ (posedge clock)
begin 
	case (stepIndex) 
		7'd0:		stepSize <= 15'd7;
		7'd1:		stepSize <= 15'd8;
		7'd2:		stepSize <= 15'd9;
		7'd3:		stepSize <= 15'd10;
		7'd4:		stepSize <= 15'd11;
		7'd5:		stepSize <= 15'd12;
		7'd6:		stepSize <= 15'd13;
		7'd7:		stepSize <= 15'd14;
		7'd8:		stepSize <= 15'd16;
		7'd9:		stepSize <= 15'd17;
		7'd10:		stepSize <= 15'd19;
		7'd11:		stepSize <= 15'd21;
		7'd12:		stepSize <= 15'd23;
		7'd13:		stepSize <= 15'd25;
		7'd14:		stepSize <= 15'd28;
		7'd15:		stepSize <= 15'd31;
		7'd16:		stepSize <= 15'd34;
		7'd17:		stepSize <= 15'd37;
		7'd18:		stepSize <= 15'd41;
		7'd19:		stepSize <= 15'd45;
		7'd20:		stepSize <= 15'd50;
		7'd21:		stepSize <= 15'd55;
		7'd22:		stepSize <= 15'd60;
		7'd23:		stepSize <= 15'd66;
		7'd24:		stepSize <= 15'd73;
		7'd25:		stepSize <= 15'd80;
		7'd26:		stepSize <= 15'd88;
		7'd27:		stepSize <= 15'd97;
		7'd28:		stepSize <= 15'd107;
		7'd29:		stepSize <= 15'd118;
		7'd30:		stepSize <= 15'd130;
		7'd31:		stepSize <= 15'd143;
		7'd32:		stepSize <= 15'd157;
		7'd33:		stepSize <= 15'd173;
		7'd34:		stepSize <= 15'd190;
		7'd35:		stepSize <= 15'd209;
		7'd36:		stepSize <= 15'd230;
		7'd37:		stepSize <= 15'd253;
		7'd38:		stepSize <= 15'd279;
		7'd39:		stepSize <= 15'd307;
		7'd40:		stepSize <= 15'd337;
		7'd41:		stepSize <= 15'd371;
		7'd42:		stepSize <= 15'd408;
		7'd43:		stepSize <= 15'd449;
		7'd44:		stepSize <= 15'd494;
		7'd45:		stepSize <= 15'd544;
		7'd46:		stepSize <= 15'd598;
		7'd47:		stepSize <= 15'd658;
		7'd48:		stepSize <= 15'd724;
		7'd49:		stepSize <= 15'd796;
		7'd50:		stepSize <= 15'd876;
		7'd51:		stepSize <= 15'd963;
		7'd52:		stepSize <= 15'd1060;
		7'd53:		stepSize <= 15'd1166;
		7'd54:		stepSize <= 15'd1282;
		7'd55:		stepSize <= 15'd1411;
		7'd56:		stepSize <= 15'd1552;
		7'd57:		stepSize <= 15'd1707;
		7'd58:		stepSize <= 15'd1878;
		7'd59:		stepSize <= 15'd2066;
		7'd60:		stepSize <= 15'd2272;
		7'd61:		stepSize <= 15'd2499;
		7'd62:		stepSize <= 15'd2749;
		7'd63:		stepSize <= 15'd3024;
		7'd64:		stepSize <= 15'd3327;
		7'd65:		stepSize <= 15'd3660;
		7'd66:		stepSize <= 15'd4026;
		7'd67:		stepSize <= 15'd4428;
		7'd68:		stepSize <= 15'd4871;
		7'd69:		stepSize <= 15'd5358;
		7'd70:		stepSize <= 15'd5894;
		7'd71:		stepSize <= 15'd6484;
		7'd72:		stepSize <= 15'd7132;
		7'd73:		stepSize <= 15'd7845;
		7'd74:		stepSize <= 15'd8630;
		7'd75:		stepSize <= 15'd9493;
		7'd76:		stepSize <= 15'd10442;
		7'd77:		stepSize <= 15'd11487;
		7'd78:		stepSize <= 15'd12635;
		7'd79:		stepSize <= 15'd13899;
		7'd80:		stepSize <= 15'd15289;
		7'd81:		stepSize <= 15'd16818;
		7'd82:		stepSize <= 15'd18500;
		7'd83:		stepSize <= 15'd20350;
		7'd84:		stepSize <= 15'd22385;
		7'd85:		stepSize <= 15'd24623;
		7'd86:		stepSize <= 15'd27086;
		7'd87:		stepSize <= 15'd29794;
		7'd88:		stepSize <= 15'd32767;
		default:	stepSize <= 15'd32767;
	endcase 
end 

endmodule
//---------------------------------------------------------------------------------------
//						Th.. Th.. Th.. That's all folks !!!
//---------------------------------------------------------------------------------------
