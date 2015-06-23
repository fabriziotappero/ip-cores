/*-----------------------------------------------------------------------------

								Video Stream Scaler
								
							Author: David Kronstein
							


Copyright 2011, David Kronstein, and individual contributors as indicated
by the @authors tag.

This is free software; you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation; either version 2.1 of
the License, or (at your option) any later version.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this software; if not, write to the Free
Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
02110-1301 USA, or see the FSF site: http://www.fsf.org.

								
-------------------------------------------------------------------------------

Scales streaming video up or down in resolution. Bilinear and nearest neighbor
modes are supported.

Run-time adjustment of input and output resolution, scaling factors, and scale
type. 

-------------------------------------------------------------------------------

Revisions

V1.0.0	Feb 21 2011		Initial Release		David Kronstein
Known bugs:
Very slight numerical errors (+0/-2 LSb) in output data due to coefficient arithmetic.
Impossible to notice without adjustment in video levels. Attempted to fix by setting
coeff11 to 1.0 - other coefficients, but this caused timing issues.

*/
`default_nettype none

module streamScaler #(
//---------------------------Parameters----------------------------------------
parameter	DATA_WIDTH =			8,		//Width of input/output data
parameter	CHANNELS =				1,		//Number of channels of DATA_WIDTH, for color images
parameter 	DISCARD_CNT_WIDTH =		8,		//Width of inputDiscardCnt
parameter	INPUT_X_RES_WIDTH =		11,		//Widths of input/output resolution control signals
parameter	INPUT_Y_RES_WIDTH =		11,
parameter	OUTPUT_X_RES_WIDTH =	11,
parameter	OUTPUT_Y_RES_WIDTH =	11,
parameter	FRACTION_BITS =			8,		//Number of bits for fractional component of coefficients.

parameter	SCALE_INT_BITS =		4,		//Width of integer component of scaling factor. The maximum input data width to
											//multipliers created will be SCALE_INT_BITS + SCALE_FRAC_BITS. Typically these
											//values will sum to 18 to match multipliers available in FPGAs.
parameter	SCALE_FRAC_BITS =		14,		//Width of fractional component of scaling factor
parameter	BUFFER_SIZE =			4,		//Depth of RFIFO
//---------------------Non-user-definable parameters----------------------------
parameter	COEFF_WIDTH =			FRACTION_BITS + 1,
parameter	SCALE_BITS =			SCALE_INT_BITS + SCALE_FRAC_BITS,
parameter	BUFFER_SIZE_WIDTH =		((BUFFER_SIZE+1) <= 2) ? 1 :	//wide enough to hold value BUFFER_SIZE + 1
									((BUFFER_SIZE+1) <= 4) ? 2 :
									((BUFFER_SIZE+1) <= 8) ? 3 :
									((BUFFER_SIZE+1) <= 16) ? 4 :
									((BUFFER_SIZE+1) <= 32) ? 5 :
									((BUFFER_SIZE+1) <= 64) ? 6 : 7
)(
//---------------------------Module IO-----------------------------------------
//Clock and reset
input wire							clk,
input wire							rst,

//User interface
//Input
input wire [DATA_WIDTH*CHANNELS-1:0]dIn,
input wire							dInValid,
output wire							nextDin,
input wire							start,

//Output
output reg [DATA_WIDTH*CHANNELS-1:0]
									dOut,
output reg							dOutValid,			//latency of 4 clock cycles after nextDout is asserted
input wire							nextDout,

//Control
input wire [DISCARD_CNT_WIDTH-1:0]	inputDiscardCnt,	//Number of input pixels to discard before processing data. Used for clipping
input wire [INPUT_X_RES_WIDTH-1:0]	inputXRes,			//Resolution of input data minus 1
input wire [INPUT_Y_RES_WIDTH-1:0]	inputYRes,
input wire [OUTPUT_X_RES_WIDTH-1:0]	outputXRes,			//Resolution of output data minus 1
input wire [OUTPUT_Y_RES_WIDTH-1:0]	outputYRes,
input wire [SCALE_BITS-1:0]			xScale,				//Scaling factors. Input resolution scaled up by 1/xScale. Format Q SCALE_INT_BITS.SCALE_FRAC_BITS
input wire [SCALE_BITS-1:0]			yScale,				//Scaling factors. Input resolution scaled up by 1/yScale. Format Q SCALE_INT_BITS.SCALE_FRAC_BITS

input wire [OUTPUT_X_RES_WIDTH-1+SCALE_FRAC_BITS:0]
									leftOffset,			//Integer/fraction of input pixel to offset output data horizontally right. Format Q OUTPUT_X_RES_WIDTH.SCALE_FRAC_BITS
input wire [SCALE_FRAC_BITS-1:0]	topFracOffset,		//Fraction of input pixel to offset data vertically down. Format Q0.SCALE_FRAC_BITS
input wire							nearestNeighbor		//Use nearest neighbor resize instead of bilinear
);
//-----------------------Internal signals and registers------------------------
reg								advanceRead1;
reg								advanceRead2;

wire [DATA_WIDTH*CHANNELS-1:0]	readData00;
wire [DATA_WIDTH*CHANNELS-1:0]	readData01;
wire [DATA_WIDTH*CHANNELS-1:0]	readData10;
wire [DATA_WIDTH*CHANNELS-1:0]	readData11;
reg [DATA_WIDTH*CHANNELS-1:0]	readData00Reg;
reg [DATA_WIDTH*CHANNELS-1:0]	readData01Reg;
reg [DATA_WIDTH*CHANNELS-1:0]	readData10Reg;
reg [DATA_WIDTH*CHANNELS-1:0]	readData11Reg;

wire [INPUT_X_RES_WIDTH-1:0]	readAddress;

reg 							readyForRead;		//Indicates two full lines have been put into the buffer
reg [OUTPUT_Y_RES_WIDTH-1:0]	outputLine;			//which output video line we're on
reg [OUTPUT_X_RES_WIDTH-1:0]	outputColumn;		//which output video column we're on
reg [INPUT_X_RES_WIDTH-1+SCALE_FRAC_BITS:0]
								xScaleAmount;		//Fractional and integer components of input pixel select (multiply result)
reg [INPUT_Y_RES_WIDTH-1+SCALE_FRAC_BITS:0]
								yScaleAmount;		//Fractional and integer components of input pixel select (multiply result)
reg [INPUT_Y_RES_WIDTH-1+SCALE_FRAC_BITS:0]
								yScaleAmountNext;	//Fractional and integer components of input pixel select (multiply result)
wire [BUFFER_SIZE_WIDTH-1:0] 	fillCount;			//Numbers used rams in the ram fifo
reg                 			lineSwitchOutputDisable; //On the end of an output line, disable the output for one cycle to let the RAM data become valid
reg								dOutValidInt;

reg [COEFF_WIDTH-1:0]			xBlend;
wire [COEFF_WIDTH-1:0]			yBlend = {1'b0, yScaleAmount[SCALE_FRAC_BITS-1:SCALE_FRAC_BITS-FRACTION_BITS]};

wire [INPUT_X_RES_WIDTH-1:0]	xPixLow = xScaleAmount[INPUT_X_RES_WIDTH-1+SCALE_FRAC_BITS:SCALE_FRAC_BITS];
wire [INPUT_Y_RES_WIDTH-1:0]	yPixLow = yScaleAmount[INPUT_Y_RES_WIDTH-1+SCALE_FRAC_BITS:SCALE_FRAC_BITS];
wire [INPUT_Y_RES_WIDTH-1:0]	yPixLowNext = yScaleAmountNext[INPUT_Y_RES_WIDTH-1+SCALE_FRAC_BITS:SCALE_FRAC_BITS];

wire 							allDataWritten;		//Indicates that all data from input has been read in
reg 							readState;

//States for read state machine
parameter RS_START = 0;
parameter RS_READ_LINE = 1;

//Read state machine
//Controls the RFIFO(ram FIFO) readout and generates output data valid signals
always @ (posedge clk or posedge rst or posedge start)
begin
	if(rst | start)
	begin
		outputLine <= 0;
		outputColumn <= 0;
		xScaleAmount <= 0;
		yScaleAmount <= 0;
		readState <= RS_START;
		dOutValidInt <= 0;
		lineSwitchOutputDisable <= 0;
		advanceRead1 <= 0;
		advanceRead2 <= 0;
		yScaleAmountNext <= 0;
	end
	else
	begin
		case (readState)
		  
			RS_START:
			begin
				xScaleAmount <= leftOffset;
				yScaleAmount <= {{INPUT_Y_RES_WIDTH{1'b0}}, topFracOffset};
				if(readyForRead)
				begin
					readState <= RS_READ_LINE;
					dOutValidInt <= 1;
				end
			end

			RS_READ_LINE:
			begin
			
				//outputLine goes through all output lines, and the logic determines which input lines to read into the RRB and which ones to discard.
				if(nextDout && dOutValidInt)
				begin
					if(outputColumn == outputXRes)
					begin //On the last input pixel of the line
						if(yPixLowNext == (yPixLow + 1))    //If the next input line is only one greater, advance the RRB by one only
						begin
							advanceRead1 <= 1;
							if(fillCount < 3)		//If the RRB doesn't have enough data, stop reading it out
								dOutValidInt <= 0;
						end
						else if(yPixLowNext > (yPixLow + 1))  //If the next input line is two or more greater, advance the read by two
						begin
							advanceRead2 <= 1;
							if(fillCount < 4)		//If the RRB doesn't have enough data, stop reading it out
								dOutValidInt <= 0;
						end
					
						outputColumn <= 0;
						xScaleAmount <= leftOffset;
						outputLine <= outputLine + 1;
						yScaleAmount <= yScaleAmountNext;
						lineSwitchOutputDisable <= 1;
					end
					else
					begin
						//Advance the output pixel selection values except when waiting for the ram data to become valid
						if(lineSwitchOutputDisable == 0)
						begin
							outputColumn <= outputColumn + 1;
							xScaleAmount <= (outputColumn + 1) * xScale + leftOffset;
						end
						advanceRead1 <= 0;
						advanceRead2 <= 0;
						lineSwitchOutputDisable <= 0;
					end
				end
				else //else from if(nextDout && dOutValidInt)
				begin
					advanceRead1 <= 0;
					advanceRead2 <= 0;
					lineSwitchOutputDisable <= 0;
				end
				
				//Once the RRB has enough data, let data be read from it. If all input data has been written, always allow read
				if(fillCount >= 2 && dOutValidInt == 0 || allDataWritten)
				begin
					if((!advanceRead1 && !advanceRead2))
					begin
						dOutValidInt <= 1;
						lineSwitchOutputDisable <= 0;
					end
				end
			end//state RS_READ_LINE:
		endcase
		
		//yScaleAmountNext is used to determine which input lines are valid.
		yScaleAmountNext <= (outputLine + 1) * yScale + {{OUTPUT_Y_RES_WIDTH{1'b0}}, topFracOffset};
	end
end

assign readAddress = xPixLow;

//Generate dOutValid signal, delayed to account for delays in data path
reg dOutValid_1;
reg dOutValid_2;
reg dOutValid_3;

always @(posedge clk or posedge rst)
begin
	if(rst)
	begin
		dOutValid_1 <= 0;
		dOutValid_2 <= 0;
		dOutValid_3 <= 0;
		dOutValid <= 0;
	end
	else
	begin
		dOutValid_1 <= nextDout && dOutValidInt && !lineSwitchOutputDisable;
		dOutValid_2 <= dOutValid_1;
		dOutValid_3 <= dOutValid_2;
		dOutValid <= dOutValid_3;
	end
end

//-----------------------Output data generation-----------------------------
//Scale amount values are used to generate coefficients for the four pixels coming out of the RRB to be multiplied with.

//Coefficients for each of the four pixels
//Format Q1.FRACTION_BITS
//			   yx
reg [COEFF_WIDTH-1:0] 	coeff00;		//Top left
reg [COEFF_WIDTH-1:0] 	coeff01;		//Top right
reg [COEFF_WIDTH-1:0]	coeff10;		//Bottom left
reg [COEFF_WIDTH-1:0]	coeff11;		//Bottom right

//Coefficient value of one, format Q1.COEFF_WIDTH-1
wire [COEFF_WIDTH-1:0]	coeffOne = {1'b1, {(COEFF_WIDTH-1){1'b0}}};	//One in MSb, zeros elsewhere
//Coefficient value of one half, format Q1.COEFF_WIDTH-1
wire [COEFF_WIDTH-1:0]	coeffHalf = {2'b01, {(COEFF_WIDTH-2){1'b0}}};

//Compute bilinear interpolation coefficinets. Done here because these pre-registerd values are used twice.
//Adding coeffHalf to get the nearest value.
wire [COEFF_WIDTH-1:0]	preCoeff00 = (((coeffOne - xBlend) * (coeffOne - yBlend) + (coeffHalf - 1)) >> FRACTION_BITS) & 	{{COEFF_WIDTH{1'b0}}, {COEFF_WIDTH{1'b1}}};
wire [COEFF_WIDTH-1:0]	preCoeff01 = ((xBlend * (coeffOne - yBlend) + (coeffHalf - 1)) >> FRACTION_BITS) & 				{{COEFF_WIDTH{1'b0}}, {COEFF_WIDTH{1'b1}}};
wire [COEFF_WIDTH-1:0]	preCoeff10 = (((coeffOne - xBlend) * yBlend + (coeffHalf - 1)) >> FRACTION_BITS) &				{{COEFF_WIDTH{1'b0}}, {COEFF_WIDTH{1'b1}}};

//Compute the coefficients
always @(posedge clk or posedge rst)
begin
	if(rst)
	begin
		coeff00 <= 0;
		coeff01 <= 0;
		coeff10 <= 0;
		coeff11 <= 0;
		xBlend <= 0;
	end
	else
	begin
		xBlend <= {1'b0, xScaleAmount[SCALE_FRAC_BITS-1:SCALE_FRAC_BITS-FRACTION_BITS]};	//Changed to registered to improve timing
		
		if(nearestNeighbor == 1'b0)
		begin
			//Normal bilinear interpolation
			coeff00 <= preCoeff00;
			coeff01 <= preCoeff01;
			coeff10 <= preCoeff10;
			coeff11 <= ((xBlend * yBlend + (coeffHalf - 1)) >> FRACTION_BITS) &								{{COEFF_WIDTH{1'b0}}, {COEFF_WIDTH{1'b1}}};
			//coeff11 <= coeffOne - preCoeff00 - preCoeff01 - preCoeff10;		//Guarantee that all coefficients sum to coeffOne. Saves a multiply too. Reverted to previous method due to timing issues.
		end
		else
		begin
			//Nearest neighbor interploation, set one coefficient to 1.0, the rest to zero based on the fractions
			coeff00 <= xBlend < coeffHalf && yBlend < coeffHalf ? coeffOne : {COEFF_WIDTH{1'b0}};
			coeff01 <= xBlend >= coeffHalf && yBlend < coeffHalf ? coeffOne : {COEFF_WIDTH{1'b0}};
			coeff10 <= xBlend < coeffHalf && yBlend >= coeffHalf ? coeffOne : {COEFF_WIDTH{1'b0}};
			coeff11 <= xBlend >= coeffHalf && yBlend >= coeffHalf ? coeffOne : {COEFF_WIDTH{1'b0}};
		end
	end
end


//Generate the blending multipliers
reg [(DATA_WIDTH+COEFF_WIDTH)*CHANNELS-1:0]	product00, product01, product10, product11;

generate
genvar channel;
	for(channel = 0; channel < CHANNELS; channel = channel + 1)
		begin : blend_mult_generate
			always @(posedge clk or posedge rst)
			begin
				if(rst)
				begin
					//productxx[channel] <= 0;
					product00[ (DATA_WIDTH+COEFF_WIDTH)*(channel+1)-1 : (DATA_WIDTH+COEFF_WIDTH)*channel] <= 0;
					product01[ (DATA_WIDTH+COEFF_WIDTH)*(channel+1)-1 : (DATA_WIDTH+COEFF_WIDTH)*channel] <= 0;
					product10[ (DATA_WIDTH+COEFF_WIDTH)*(channel+1)-1 : (DATA_WIDTH+COEFF_WIDTH)*channel] <= 0;
					product11[ (DATA_WIDTH+COEFF_WIDTH)*(channel+1)-1 : (DATA_WIDTH+COEFF_WIDTH)*channel] <= 0;
					
					//readDataxxReg[channel] <= 0;
					readData00Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] <= 0;
					readData01Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] <= 0;
					readData10Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] <= 0;
					readData11Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] <= 0;
					
					//dOut[channel] <= 0;
					dOut[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] <= 0;
				end
				else
				begin
					//readDataxxReg[channel] <= readDataxx[channel];
					readData00Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] <= readData00[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ];
					readData01Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] <= readData01[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ];
					readData10Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] <= readData10[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ];
					readData11Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] <= readData11[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ];
				
					//productxx[channel] <= readDataxxReg[channel] * coeffxx
					product00[ (DATA_WIDTH+COEFF_WIDTH)*(channel+1)-1 : (DATA_WIDTH+COEFF_WIDTH)*channel] <= readData00Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] * coeff00;
					product01[ (DATA_WIDTH+COEFF_WIDTH)*(channel+1)-1 : (DATA_WIDTH+COEFF_WIDTH)*channel] <= readData01Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] * coeff01;
					product10[ (DATA_WIDTH+COEFF_WIDTH)*(channel+1)-1 : (DATA_WIDTH+COEFF_WIDTH)*channel] <= readData10Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] * coeff10;
					product11[ (DATA_WIDTH+COEFF_WIDTH)*(channel+1)-1 : (DATA_WIDTH+COEFF_WIDTH)*channel] <= readData11Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] * coeff11;
					
					//dOut[channel] <= (((product00[channel]) + 
					//					(product01[channel]) +
					//					(product10[channel]) +
					//					(product11[channel])) >> FRACTION_BITS) & ({ {COEFF_WIDTH{1'b0}}, {DATA_WIDTH{1'b1}} });
					dOut[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] <=
							(((product00[ (DATA_WIDTH+COEFF_WIDTH)*(channel+1)-1 : (DATA_WIDTH+COEFF_WIDTH)*channel]) + 
							(product01[ (DATA_WIDTH+COEFF_WIDTH)*(channel+1)-1 : (DATA_WIDTH+COEFF_WIDTH)*channel]) +
							(product10[ (DATA_WIDTH+COEFF_WIDTH)*(channel+1)-1 : (DATA_WIDTH+COEFF_WIDTH)*channel]) +
							(product11[ (DATA_WIDTH+COEFF_WIDTH)*(channel+1)-1 : (DATA_WIDTH+COEFF_WIDTH)*channel])) >> FRACTION_BITS) & ({ {COEFF_WIDTH{1'b0}}, {DATA_WIDTH{1'b1}} });
				end
			end
		end
endgenerate

				
//---------------------------Data write logic----------------------------------
//Places input data into the correct ram in the RFIFO (ram FIFO)
//Controls writing to the RFIFO, and discards lines that arn't used

reg [INPUT_Y_RES_WIDTH-1:0]		writeNextValidLine;	//Which line greater than writeRowCount is the next one that must be read in
reg [INPUT_Y_RES_WIDTH-1:0]		writeNextPlusOne;	//One greater than writeNextValidLine, because we must always read in two adjacent lines
reg [INPUT_Y_RES_WIDTH-1:0]		writeRowCount;		//Which line we're reading from dIn
reg [OUTPUT_Y_RES_WIDTH-1:0]	writeOutputLine;	//The output line that corresponds to the input line. This is incremented until writeNextValidLine is greater than writeRowCount
reg								getNextPlusOne;		//Flag so that writeNextPlusOne is captured only once after writeRowCount >= writeNextValidLine. This is in case multiple cycles are requred until writeNextValidLine changes.

//Determine which lines to read out and which to discard.
//writeNextValidLine is the next valid line number that needs to be read out above current value writeRowCount
//writeNextPlusOne also needs to be read out (to do interpolation), this may or may not be equal to writeNextValidLine
always @(posedge clk or posedge rst or posedge start)
begin
	if(rst | start)
	begin
		writeOutputLine <= 0;
		writeNextValidLine <= 0;
		writeNextPlusOne <= 1;
		getNextPlusOne <= 1;
	end
	else
	begin
		if(writeRowCount >= writeNextValidLine) //When writeRowCount becomes higher than the next valid line to read out, comptue the next valid line.
		begin
			if(getNextPlusOne)			//Keep writeNextPlusOne
			begin
				writeNextPlusOne <= writeNextValidLine + 1;
			end
			getNextPlusOne <= 0;
			writeOutputLine <= writeOutputLine + 1;
			writeNextValidLine <= ((writeOutputLine*yScale + {{(OUTPUT_Y_RES_WIDTH + SCALE_INT_BITS){1'b0}}, topFracOffset}) >> SCALE_FRAC_BITS) & {{SCALE_BITS{1'b0}}, {OUTPUT_Y_RES_WIDTH{1'b1}}};
		end
		else
		begin
			getNextPlusOne <= 1;
		end
	end
end

reg			discardInput;
reg [DISCARD_CNT_WIDTH-1:0] discardCountReg;
wire		advanceWrite;

reg [1:0]	writeState;

reg [INPUT_X_RES_WIDTH-1:0] writeColCount;
reg			enableNextDin;
reg			forceRead;

//Write state machine
//Controls writing scaler input data into the RRB

parameter	WS_START = 0;
parameter	WS_DISCARD = 1;
parameter	WS_READ = 2;
parameter	WS_DONE = 3;

//Control write and address signals to write data into ram FIFO
always @ (posedge clk or posedge rst or posedge start)
begin
	if(rst | start)
	begin
		writeState <= WS_START;
		enableNextDin <= 0;
		discardInput <= 0;
		readyForRead <= 0;
		writeRowCount <= 0;
		writeColCount <= 0;
		discardCountReg <= 0;
		forceRead <= 0;
	end
	else
	begin
		case (writeState)
		
			WS_START:
			begin
				discardCountReg <= inputDiscardCnt;
				if(inputDiscardCnt > 0)
				begin
					discardInput <= 1;
					enableNextDin <= 1;
					writeState <= WS_DISCARD;
				end
				else
				begin
					discardInput <= 0;
					enableNextDin <= 1;
					writeState <= WS_READ;
				end
				discardInput <= (inputDiscardCnt > 0) ? 1'b1 : 1'b0;
			end
			
			WS_DISCARD:	//Discard pixels from input data
			begin
				if(dInValid)
				begin
					discardCountReg <= discardCountReg - 1;
					if((discardCountReg - 1) == 0)
					begin
						discardInput <= 0;
						writeState <= WS_READ;
					end
				end
			end
			
			WS_READ:
			begin
				if(dInValid & nextDin)
				begin
					if(writeColCount == inputXRes)
					begin	//Occurs on the last pixel in the line
						if((writeNextValidLine == writeRowCount + 1) ||
							(writeNextPlusOne == writeRowCount + 1))
						begin //Next line is valid, write into buffer
							discardInput <= 0;
						end
						else
						begin	//Next line is not valid, discard
							discardInput <= 1;
						end
						
						//Once writeRowCount is >= 2, data is ready to start being output.
						if(writeRowCount[1])
							readyForRead <= 1;
						
						if(writeRowCount == inputYRes)	//When all data has been read in, stop reading.
						begin
							writeState <= WS_DONE;
							enableNextDin <= 0;
							forceRead <= 1;
						end
						
						writeColCount <= 0;
						writeRowCount <= writeRowCount + 1;
					end
					else
					begin
						writeColCount <= writeColCount + 1;
					end
				end
			end
			
			WS_DONE:
			begin
				//do nothing, wait for reset
			end
			
		endcase
	end
end


//Advance write whenever we have just written a valid line (discardInput == 0)
//Generate this signal one earlier than discardInput above that uses the same conditions, to advance the buffer at the right time.
assign advanceWrite =	(writeColCount == inputXRes) & (discardInput == 0) & dInValid & nextDin;
assign allDataWritten = writeState == WS_DONE;
assign nextDin = (fillCount < BUFFER_SIZE) & enableNextDin;

ramFifo #(
	.DATA_WIDTH( DATA_WIDTH*CHANNELS ),
	.ADDRESS_WIDTH( INPUT_X_RES_WIDTH ),	//Controls width of RAMs
	.BUFFER_SIZE( BUFFER_SIZE )		//Number of RAMs
) ramRB (
	.clk( clk ),
	.rst( rst | start ),
	.advanceRead1( advanceRead1 ),
	.advanceRead2( advanceRead2 ),
	.advanceWrite( advanceWrite ),
	.forceRead( forceRead ),

	.writeData( dIn ),		
	.writeAddress( writeColCount ),
	.writeEnable( dInValid & nextDin & enableNextDin & ~discardInput ),
	.fillCount( fillCount ),
	
	.readData00( readData00 ),
	.readData01( readData01 ),
	.readData10( readData10 ),
	.readData11( readData11 ),
	.readAddress( readAddress )
);

endmodule	//scaler



//---------------------------Ram FIFO (RFIFO)-----------------------------
//FIFO buffer with rams as the elements, instead of data
//One ram is filled, while two others are simultaneously read out.
//Four neighboring pixels are read out at once, at the selected RAM and one line down, and at readAddress and readAddress + 1
module ramFifo #(
	parameter DATA_WIDTH = 8,
	parameter ADDRESS_WIDTH = 8,
	parameter BUFFER_SIZE = 2,
	parameter BUFFER_SIZE_WIDTH =	((BUFFER_SIZE+1) <= 2) ? 1 :	//wide enough to hold value BUFFER_SIZE + 1
									((BUFFER_SIZE+1) <= 4) ? 2 :
									((BUFFER_SIZE+1) <= 8) ? 3 :
									((BUFFER_SIZE+1) <= 16) ? 4 :
									((BUFFER_SIZE+1) <= 32) ? 5 :
									((BUFFER_SIZE+1) <= 64) ? 6 : 7
)(
	input wire 						clk,
	input wire 						rst,
	input wire						advanceRead1,	//Advance selected read RAM by one
	input wire						advanceRead2,	//Advance selected read RAM by two
	input wire						advanceWrite,	//Advance selected write RAM by one
	input wire						forceRead,		//Disables writing to allow all data to be read out (RAM being written to cannot be read from normally)		

	input wire [DATA_WIDTH-1:0]		writeData,
	input wire [ADDRESS_WIDTH-1:0]	writeAddress,
	input wire						writeEnable,
	output reg [BUFFER_SIZE_WIDTH-1:0]
									fillCount,

	//										yx
	output wire [DATA_WIDTH-1:0]	readData00,		//Read from deepest RAM (earliest data), at readAddress
	output wire [DATA_WIDTH-1:0]	readData01,		//Read from deepest RAM (earliest data), at readAddress + 1
	output wire [DATA_WIDTH-1:0]	readData10,		//Read from second deepest RAM (second earliest data), at readAddress
	output wire [DATA_WIDTH-1:0]	readData11,		//Read from second deepest RAM (second earliest data), at readAddress + 1
	input wire [ADDRESS_WIDTH-1:0]	readAddress
);

reg [BUFFER_SIZE-1:0]		writeSelect;
reg [BUFFER_SIZE-1:0]		readSelect;

//Read select ring register
always @(posedge clk or posedge rst)
begin
	if(rst)
		readSelect <= 1;
	else
	begin
		if(advanceRead1)
		begin
			readSelect <= {readSelect[BUFFER_SIZE-2 : 0], readSelect[BUFFER_SIZE-1]};
		end
		else if(advanceRead2)
		begin
			readSelect <= {readSelect[BUFFER_SIZE-3 : 0], readSelect[BUFFER_SIZE-1:BUFFER_SIZE-2]};
		end
	end
end

//Write select ring register
always @(posedge clk or posedge rst)
begin
	if(rst)
		writeSelect <= 1;
	else
	begin
		if(advanceWrite)
		begin
			writeSelect <= {writeSelect[BUFFER_SIZE-2 : 0], writeSelect[BUFFER_SIZE-1]};
		end
	end
end

wire [DATA_WIDTH-1:0] ramDataOutA [2**BUFFER_SIZE-1:0];
wire [DATA_WIDTH-1:0] ramDataOutB [2**BUFFER_SIZE-1:0];

//Generate to instantiate the RAMs
generate
genvar i;
	for(i = 0; i < BUFFER_SIZE; i = i + 1)
		begin : ram_generate

			ramDualPort #(
				.DATA_WIDTH( DATA_WIDTH ),
				.ADDRESS_WIDTH( ADDRESS_WIDTH )
			) ram_inst_i(
				.clk( clk ),
				
				//Port A is written to as well as read from. When writing, this port cannot be read from.
				//As long as the buffer is large enough, this will not cause any problem.
				.addrA( ((writeSelect[i] == 1'b1) && !forceRead && writeEnable) ? writeAddress : readAddress ),	//&& writeEnable is 
				//to allow the full buffer to be used. After the buffer is filled, write is advanced, so writeSelect
				//and readSelect are the same. The full buffer isn't written to, so this allows the read to work properly.
				.dataA( writeData ),													
				.weA( ((writeSelect[i] == 1'b1) && !forceRead) ? writeEnable : 1'b0 ),
				.qA( ramDataOutA[2**i] ),
				
				.addrB( readAddress + 1 ),
				.dataB( 0 ),
				.weB( 1'b0 ),
				.qB( ramDataOutB[2**i] )
			);
		end
endgenerate

//Select which ram to read from
wire [BUFFER_SIZE-1:0]	readSelect0 = readSelect;
wire [BUFFER_SIZE-1:0]	readSelect1 = (readSelect << 1) | readSelect[BUFFER_SIZE-1];

//Steer the output data to the right ports
assign readData00 = ramDataOutA[readSelect0];
assign readData10 = ramDataOutA[readSelect1];
assign readData01 = ramDataOutB[readSelect0];
assign readData11 = ramDataOutB[readSelect1];

//Keep track of fill level
always @(posedge clk or posedge rst)
begin
	if(rst)
	begin
		fillCount <= 0;
	end
	else
	begin
		if(advanceWrite)
		begin
			if(advanceRead1)
				fillCount <= fillCount;
			else if(advanceRead2)
				fillCount <= fillCount - 1;
			else
				fillCount <= fillCount + 1;
		end
		else
		begin
			if(advanceRead1)
				fillCount <= fillCount - 1;
			else if(advanceRead2)
				fillCount <= fillCount - 2;
			else
				fillCount <= fillCount;
		end
	end
end

endmodule //ramFifo


//Dual port RAM
module ramDualPort #(
	parameter DATA_WIDTH = 8,
	parameter ADDRESS_WIDTH = 8
)(
	input wire [(DATA_WIDTH-1):0] dataA, dataB,
	input wire [(ADDRESS_WIDTH-1):0] addrA, addrB,
	input wire weA, weB, clk,
	output reg [(DATA_WIDTH-1):0] qA, qB
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDRESS_WIDTH-1:0];

	//Port A
	always @ (posedge clk)
	begin
		if (weA) 
		begin
			ram[addrA] <= dataA;
			qA <= dataA;
		end
		else 
		begin
			qA <= ram[addrA];
		end 
	end 

	//Port B
	always @ (posedge clk)
	begin
		if (weB) 
		begin
			ram[addrB] <= dataB;
			qB <= dataB;
		end
		else 
		begin
			qB <= ram[addrB];
		end 
	end

endmodule //ramDualPort
