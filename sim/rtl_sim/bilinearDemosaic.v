/*-----------------------------------------------------------------------------

								Bilinear Demosaic
								
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

Provides demosaicing of a streamign video source.


Bayer pattern codes for input bayerPattern:
0=R G
  G B
  
1=B G
  G R
  
2=G R
  B G
  
3=G B
  R G

-------------------------------------------------------------------------------

Revisions

V1.0.0	Nov 16 2012		Initial Release		David Kronstein



*/
`default_nettype none

module bilinearDemosaic #(
//---------------------------Parameters----------------------------------------
parameter	DATA_WIDTH =			8,		//Width of input/output data
parameter	X_RES_WIDTH =			11,		//Widths of input/output resolution control signals
parameter	Y_RES_WIDTH =			11,
parameter	BUFFER_SIZE =			4,		//Depth of RFIFO
//---------------------Non-user-definable parameters----------------------------
parameter	BUFFER_SIZE_WIDTH =		((BUFFER_SIZE+1) <= 2) ? 1 :	//wide enough to hold value BUFFER_SIZE + 1
									((BUFFER_SIZE+1) <= 4) ? 2 :
									((BUFFER_SIZE+1) <= 8) ? 3 :
									((BUFFER_SIZE+1) <= 16) ? 4 :
									((BUFFER_SIZE+1) <= 32) ? 5 :
									((BUFFER_SIZE+1) <= 64) ? 6 : 7
)(
//---------------------------Module IO-----------------------------------------
//Clock and reset
input wire						clk,
input wire						rst,

//User interface
//Video Input
input wire [DATA_WIDTH-1:0]		dIn,
input wire						dInValid,
output wire						nextDin,
input wire						start,

//Video Output
output reg [DATA_WIDTH-1:0]
								rOut,
output reg [DATA_WIDTH-1:0]
								gOut,
output reg [DATA_WIDTH-1:0]
								bOut,
output reg						dOutValid,			//latency of 1 clock cycle after nextDout is asserted
input wire						nextDout,

//Control
input wire [1:0]				bayerPattern,		//Controls which of four bayer pixel patterns is used
input wire [X_RES_WIDTH-1:0]	xRes,				//Resolution of input data minus 1
input wire [Y_RES_WIDTH-1:0]	yRes

);
//-----------------------Internal signals and registers------------------------
reg								advanceRead;

wire [DATA_WIDTH-1:0]			readData0;
wire [DATA_WIDTH-1:0]			readData1;
wire [DATA_WIDTH-1:0]			readData2;

wire [X_RES_WIDTH-1:0]			readAddress;

reg 							readyForRead;		//Indicates two full lines have been put into the buffer
reg [Y_RES_WIDTH-1:0]			outputLine;			//which output video line we're on
reg [X_RES_WIDTH-1:0]			outputColumn;		//which output video column we're on
wire [BUFFER_SIZE_WIDTH-1:0] 	fillCount;			//Numbers used rams in the ram fifo
reg								dOutValidInt;
reg								fillPipeline;
reg								fillPipeline_1;
reg [2:0]						fillPipelineCount;

wire 							allDataWritten;		//Indicates that all data from input has been read in
reg 							readState;

//States for read state machine
parameter RS_START =		1'b0;
parameter RS_READ_LINE =	1'b1;

//Read state machine
//Controls the RFIFO(ram FIFO) readout and generates output data valid signals
always @ (posedge clk or posedge rst or posedge start)
begin
	if(rst | start)
	begin
		outputLine <= 0;
		outputColumn <= 0;
		readState <= RS_START;
		dOutValidInt <= 0;
		advanceRead <= 0;
		fillPipeline <= 0;
		fillPipeline_1 <= 0;
		fillPipelineCount <= 0;
	end
	else
	begin
		case (readState)
		  
			RS_START:
			begin
				if(readyForRead)
				begin
					readState <= RS_READ_LINE;
					dOutValidInt <= 1;
					fillPipeline <= 1;
					fillPipelineCount <= 4;
				end
			end

			RS_READ_LINE:
			begin
				if(nextDout && dOutValidInt || fillPipeline)
				begin
					if(outputColumn == xRes)
					begin //On the last input pixel of the line

						advanceRead <= 1;
						if(fillCount < (3 + 1))		//If the RFIFO doesn't have enough data, stop reading it out (+1 to account for fill level after advancing the RRB)
							dOutValidInt <= 0;

						outputColumn <= 0;
						outputLine <= outputLine + 1;
					end
					else
					begin
						//Advance the output pixel selection values
						outputColumn <= outputColumn + 1;
						advanceRead <= 0;
					end
				end
				else //else from if(nextDout && dOutValidInt || fillPipeline)
				begin
					advanceRead <= 0;
				end
				
				//Once the RFIFO has enough data, let data be read from it.
				if(fillCount >= 3 && dOutValidInt == 0 || allDataWritten)
				begin
					if(!advanceRead)
					begin
						dOutValidInt <= 1;
					end
				end
				
				//Counter for pipeline fill time
				if(fillPipelineCount > 0)
				begin
					fillPipelineCount <= fillPipelineCount - 1;
				end
				else
				begin
					fillPipeline <= 0;
				end
				
				fillPipeline_1 <= fillPipeline;
				
			end//state RS_READ_LINE:
		endcase
		
	end
end

assign readAddress = outputColumn;

//Generate dOutValid signal, delayed to account for delays in data path
always @(posedge clk or posedge rst)
begin
	if(rst)
	begin
		dOutValid <= 0;
	end
	else
	begin
		dOutValid <= nextDout && dOutValidInt;
	end
end


wire					advanceWrite;
reg [1:0]				writeState;
reg [X_RES_WIDTH-1:0]	writeColCount;
reg [Y_RES_WIDTH-1:0]	writeRowCount;
reg						enableNextDin;
reg						forceRead;

//Write state machine
//Controls writing scaler input data into the RFIFO
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
		readyForRead <= 0;
		writeRowCount <= 0;
		writeColCount <= 0;
		forceRead <= 0;
	end
	else
	begin
		case (writeState)
		
			WS_START:
			begin
				enableNextDin <= 1;
				writeState <= WS_READ;
			end
			
			WS_READ:
			begin
				if(dInValid & nextDin)
				begin
					if(writeColCount == xRes)
					begin	//Occurs on the last pixel in the line
						
						//Once writeRowCount is >= 3, data is ready to start being output.
						if(writeRowCount[1:0] == 2'h2)
							readyForRead <= 1;
						
						if(writeRowCount == yRes)	//When all data has been read in, stop reading from input.
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

//Masks to disable blending of invalid data (when at edges of image and no data is available for some pixels)
wire leftMask, rightMask, topMask, bottomMask;

wire leftMask_1 =	~(outputColumn == 0);
wire rightMask_1 =	~(outputColumn == xRes);
wire topMask_1 =	~(outputLine == 0);
wire bottomMask_1 =	~(outputLine == yRes);

//delay mask signals as required
registerDelay #(
	.DATA_WIDTH( 4 ),
	.STAGES( 3 )
) rd_edgeMask (
	.clk( clk ),
	.rst( rst | start ),
	.enable( dOutValid || fillPipeline ),
	.d( {leftMask_1, rightMask_1, topMask_1, bottomMask_1} ),
	.q( {leftMask, rightMask, topMask, bottomMask} )
	);


reg [DATA_WIDTH-1:0]	pixel [2:0][2:0];    //[y, x] pixel da
wire [DATA_WIDTH-1:0]	pixelMasked [2:0][2:0];    //[y, x]
/*
Pixel data format

pixel[0][0]	pixel[0][1]	pixel[0][2]	
pixel[1][0]	pixel[1][1]	pixel[1][2]	
pixel[2][0]	pixel[2][1]	pixel[2][2]	

*/

always @ (posedge clk or posedge rst or posedge start)
begin
   if(rst | start)
   begin
       pixel[0][0] <= 0;
       pixel[0][1] <= 0;
       pixel[0][2] <= 0;
       pixel[1][0] <= 0;
       pixel[1][1] <= 0;
       pixel[1][2] <= 0;
       pixel[2][0] <= 0;
       pixel[2][1] <= 0;
       pixel[2][2] <= 0;
   end
   else
   begin
	   if( dOutValid || fillPipeline_1 )
	   begin
		   pixel[0][2] <= readData0;	//Upper line
		   pixel[0][1] <= pixel[0][2];
		   pixel[0][0] <= pixel[0][1];

		   pixel[1][2] <= readData1;	//Middle line
		   pixel[1][1] <= pixel[1][2];
		   pixel[1][0] <= pixel[1][1];
		   
		   pixel[2][2] <= readData2;	//Lower line
		   pixel[2][1] <= pixel[2][2];
		   pixel[2][0] <= pixel[2][1];
		end	   
	end
end

//Apply masking so invalid data at the edge of the image is not used
assign pixelMasked[0][0] = pixel[0][0] & {DATA_WIDTH{leftMask}} & {DATA_WIDTH{topMask}};
assign pixelMasked[0][1] = pixel[0][1] & {DATA_WIDTH{topMask}};
assign pixelMasked[0][2] = pixel[0][2] & {DATA_WIDTH{rightMask}} & {DATA_WIDTH{topMask}};
assign pixelMasked[1][0] = pixel[1][0] & {DATA_WIDTH{leftMask}};
assign pixelMasked[1][1] = pixel[1][1];
assign pixelMasked[1][2] = pixel[1][2] & {DATA_WIDTH{rightMask}};
assign pixelMasked[2][0] = pixel[2][0] & {DATA_WIDTH{leftMask}} & {DATA_WIDTH{bottomMask}};
assign pixelMasked[2][1] = pixel[2][1] & {DATA_WIDTH{bottomMask}};
assign pixelMasked[2][2] = pixel[2][2] & {DATA_WIDTH{rightMask}} & {DATA_WIDTH{bottomMask}};

wire [2:0]	sidesMasked = ~leftMask + ~rightMask + ~topMask + ~bottomMask;	//Number of sides masked, either 0, 1 or 2. Used for selecting how to divide during averaging
reg [2:0]	sidesMaskedReg;

/*
Perform demosaic blending
All possible blend modes are computed simultaneously, and
the proper ones are selected based on which color filter is being worked on

Blend modes:
blend1 = +	(average of four pixels N S E and W)
blend2 = X	(average of four pixels NE SE SW and NW)
blend3 = --	(average of pixels E and W)
blend4 = |	(average of pixels N and S)
blend5 = straight through
*/

wire [DATA_WIDTH+1:0]	blend1Sum_1 = pixelMasked[1][0] + pixelMasked[1][2] + pixelMasked[0][1] + pixelMasked[2][1];
reg [DATA_WIDTH+1:0]	blend1SumOver3, blend1Sum;
reg [DATA_WIDTH+1:0]	blend1, blend2, blend3, blend4, blend5, blend2_1, blend3_1, blend4_1, blend5_1;

always @ (posedge clk or posedge rst or posedge start)
begin
	if(rst | start)
	begin
		blend1SumOver3 <= 0;
		blend1Sum <= 0;
		blend1 <= 0;
		blend2 <= 0;
		blend3 <= 0;
		blend4 <= 0;
		sidesMaskedReg <= 0;
	end
	else
	begin
		if( dOutValid || fillPipeline_1 )
		begin
			blend1SumOver3 <= (blend1Sum_1 >> 2) + (blend1Sum_1 >> 4) + (blend1Sum_1 >> 6) + (blend1Sum_1 >> 10);	//Constant multiply by 1/3 (approximate, but close enough)
			blend1Sum <= blend1Sum_1;
			blend1 <= ((sidesMaskedReg == 0) ? blend1Sum >> 2 : (sidesMaskedReg == 1) ? blend1SumOver3 : blend1Sum >> 1);	// divide by 4, 3, 2
			
			blend2_1 <= (pixelMasked[0][0] + pixelMasked[2][2] + pixelMasked[0][2] + pixelMasked[2][0]) >> ((sidesMasked == 0) ? 2 : (sidesMasked == 1) ? 1 : 0);	// divide by 4, 2, 1
			blend3_1 <= (pixelMasked[1][0] + pixelMasked[1][2]) >> ((!leftMask || !rightMask) ? 0 : 1);	//divide by 2, 1
			blend4_1 <= (pixelMasked[0][1] + pixelMasked[2][1]) >> ((!topMask || !bottomMask) ? 0 : 1);	//divide by 2, 1
			blend5_1 <= pixelMasked[1][1];	//Straight through
			
			blend2 <= blend2_1;
			blend3 <= blend3_1;
			blend4 <= blend4_1;
			blend5 <= blend5_1;
			
			sidesMaskedReg <= sidesMasked;
		end
		
	end
end


/*
Bayer pattern codes:
0=R G
  G B
  
1=B G
  G R
  
2=G R
  B G
  
3=G B
  R G
  
  Pixel codes
  0 = R, 1 = G with B above, 2 = G with R above, 3 = B
*/
reg [1:0] pixel0; 
reg [1:0] pixel1; 
reg [1:0] pixel2; 
reg [1:0] pixel3; 
  
always @(*)
begin
	case(bayerPattern)
	0:
	begin
		pixel0 = 0; 
		pixel1 = 1; 
		pixel2 = 2; 
		pixel3 = 3; 
	end

	1:
	begin
		pixel0 = 3; 
		pixel1 = 2; 
		pixel2 = 1; 
		pixel3 = 0; 
	end

	2:
	begin
		pixel0 = 1; 
		pixel1 = 0; 
		pixel2 = 3; 
		pixel3 = 2; 
	end

	3:
	begin
		pixel0 = 2; 
		pixel1 = 3; 
		pixel2 = 0; 
		pixel3 = 1; 
	end
	endcase
end

wire [1:0]	quadPosition = {outputLine[0], outputColumn[0]};
wire [1:0]	blendModeSelect_1 =	quadPosition == 0 ? pixel0 :
								quadPosition == 1 ? pixel1 :
								quadPosition == 2 ? pixel2 :
													pixel3;
wire [1:0]	blendModeSelect;

//Delay blend mode
registerDelay #(
	.DATA_WIDTH( 2 ),
	.STAGES( 5 )
) rd_blendMode (
	.clk( clk ),
	.rst( rst | start ),
	.enable( dOutValid || fillPipeline_1 ),
	.d( blendModeSelect_1 ),
	.q( blendModeSelect )
	);
	
//Select proper blend mode for each R G and B output
always @ (posedge clk or posedge rst or posedge start)
begin
	if(rst | start)
	begin
		rOut <= 0;
		gOut <= 0;
		bOut <= 0;
	end
	else
	begin
		if( dOutValid || fillPipeline_1 )
		begin
			case(blendModeSelect)
			0:	//Red filter
			begin
				rOut <= blend5;	// Straight through
				gOut <= blend1;	// +
				bOut <= blend2;	// X
			end
			
			1:	//Green filter with blue above/below
			begin
				rOut <= blend3;	// --
				gOut <= blend5;	// Straight through
				bOut <= blend4;	// |
			end
			
			2:	//Green filter with red above/below
			begin
				rOut <= blend4;	// |
				gOut <= blend5;	// Straight through
				bOut <= blend3;	// --
			end
			
			3:	//Blue filter
			begin
				rOut <= blend2;	// X
				gOut <= blend1;	// +
				bOut <= blend5;	// Straight through
			end
			endcase
		end
	end
end


//Advance write whenever we have just written a valid line (discardInput == 0)
//Generate this signal one earlier than discardInput above that uses the same conditions, to advance the buffer at the right time.
assign advanceWrite =	(writeColCount == xRes) & dInValid & nextDin;
assign allDataWritten = writeState == WS_DONE;
assign nextDin = (fillCount < BUFFER_SIZE) & enableNextDin;

ramFifo #(
	.DATA_WIDTH( DATA_WIDTH ),
	.ADDRESS_WIDTH( X_RES_WIDTH ),	//Controls width of RAMs
	.BUFFER_SIZE( BUFFER_SIZE )		//Number of RAMs
) ramRB (
	.clk( clk ),
	.rst( rst | start ),
	.advanceRead( advanceRead ),
	.advanceWrite( advanceWrite ),

	.writeData( dIn ),		
	.writeAddress( writeColCount ),
	.writeEnable( dInValid & nextDin & enableNextDin ),
	.fillCount( fillCount ),
	
	.readData0( readData0 ),
	.readData1( readData1 ),
	.readData2( readData2 ),
	.readAddress( readAddress )
);

endmodule	//bilinearDemosaic



//---------------------------Ram FIFO (RFIFO)-----------------------------
//FIFO buffer with rams as the elements, instead of data
//One ram is filled, while three others are simultaneously read out.
module ramFifo #(
	parameter DATA_WIDTH = 8,
	parameter ADDRESS_WIDTH = 8,
	parameter BUFFER_SIZE = 3,
	parameter BUFFER_SIZE_WIDTH =	((BUFFER_SIZE+1) <= 2) ? 1 :	//wide enough to hold value BUFFER_SIZE + 1
									((BUFFER_SIZE+1) <= 4) ? 2 :
									((BUFFER_SIZE+1) <= 8) ? 3 :
									((BUFFER_SIZE+1) <= 16) ? 4 :
									((BUFFER_SIZE+1) <= 32) ? 5 :
									((BUFFER_SIZE+1) <= 64) ? 6 : 7
)(
	input wire 						clk,
	input wire 						rst,
	input wire						advanceRead,	//Advance selected read RAM by one
	input wire						advanceWrite,	//Advance selected write RAM by one	

	input wire [DATA_WIDTH-1:0]		writeData,
	input wire [ADDRESS_WIDTH-1:0]	writeAddress,
	input wire						writeEnable,
	output reg [BUFFER_SIZE_WIDTH-1:0]
									fillCount,

	output wire [DATA_WIDTH-1:0]	readData0,		//Read from deepest RAM (earliest data), at readAddress
	output wire [DATA_WIDTH-1:0]	readData1,		//Read from second deepest RAM (second earliest data), at readAddress
	output wire [DATA_WIDTH-1:0]	readData2,		//Read from third deepest RAM (third earliest data), at readAddress
	input wire [ADDRESS_WIDTH-1:0]	readAddress
);

reg [BUFFER_SIZE-1:0]				writeSelect;
reg [BUFFER_SIZE-1:0]				readSelect;

//Read select ring register
always @(posedge clk or posedge rst)
begin
	if(rst)
		readSelect <= {1'b1, {(BUFFER_SIZE-1){1'b0}}}; //Mod for demosaic, normally 1
	else
	begin
		if(advanceRead)
		begin
			readSelect <= {readSelect[BUFFER_SIZE-2 : 0], readSelect[BUFFER_SIZE-1]};
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

wire [DATA_WIDTH-1:0] ramDataOut [2**BUFFER_SIZE-1:0];

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
				
				//Port A is written to, port B is read from
				.addrA( writeAddress ),
				.dataA( writeData ),													
				.weA( (writeSelect[i] == 1'b1) ? writeEnable : 1'b0 ),
				.qA(  ),
				
				.addrB( readAddress ),
				.dataB( 0 ),
				.weB( 1'b0 ),
				.qB( ramDataOut[2**i] )
			);
		end
endgenerate

//Select which ram to read from
wire [BUFFER_SIZE-1:0]	readSelect0 = readSelect;
wire [BUFFER_SIZE-1:0]	readSelect1 = (readSelect << 1) | readSelect[BUFFER_SIZE-1];
wire [BUFFER_SIZE-1:0]	readSelect2 = (readSelect << 2) | readSelect[BUFFER_SIZE-1:BUFFER_SIZE-2];

//Steer the output data to the right ports
assign readData0 = ramDataOut[readSelect0];
assign readData1 = ramDataOut[readSelect1];
assign readData2 = ramDataOut[readSelect2];


//Keep track of fill level
always @(posedge clk or posedge rst)
begin
	if(rst)
	begin
		fillCount <= 1;		//Mod for demosaic, normally 0. The first line has to come out of readData1, the invalid data from readData0 will be masked
	end
	else
	begin
		if(advanceWrite)
		begin
			if(advanceRead)
				fillCount <= fillCount;
			else
				fillCount <= fillCount + 1;
		end
		else
		begin
			if(advanceRead)
				fillCount <= fillCount - 1;
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

`default_nettype wire
