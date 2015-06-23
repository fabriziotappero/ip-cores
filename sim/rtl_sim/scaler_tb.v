/*-----------------------------------------------------------------------------

								Video Stream Scaler testbench
								
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

Testbench for streamScaler V1.0.0

*/

`default_nettype none

//Input files. Raw data format, no header. 8 bits per pixel, 3 color channels.
`define INPUT640x512			"src/input640x512RGB.raw"
`define INPUT1280x1024			"src/input1280x1024RGB.raw"
`define INPUT1280x1024_21EXTRA	"src/input640x512_21extraRGB.raw"	//21 extra pixels at the start to be discarded

module scalerTestbench;
parameter BUFFER_SIZE = 4;

wire [7-1:0] done;

//640x512 to 1280x1024
	scalerTest #(
	.INPUT_X_RES ( 640-1 ),
	.INPUT_Y_RES ( 512-1 ),
	.OUTPUT_X_RES ( 1280-1 ),   //Output resolution - 1
	.OUTPUT_Y_RES ( 1024-1 ),   //Output resolution - 1
	//.X_SCALE ( X_SCALE ),
	//.Y_SCALE ( Y_SCALE ),

	.DATA_WIDTH ( 8 ),
	.DISCARD_CNT_WIDTH ( 8 ),
	.INPUT_X_RES_WIDTH ( 11 ),
	.INPUT_Y_RES_WIDTH ( 11 ),
	.OUTPUT_X_RES_WIDTH ( 11 ),
	.OUTPUT_Y_RES_WIDTH ( 11 ),
	.BUFFER_SIZE ( BUFFER_SIZE )				//Number of RAMs in RAM ring buffer
	) st_640x512to1280x1024 (
	.inputFilename( `INPUT640x512 ),
	.outputFilename( "out/output640x512to1280x1024.raw" ),

	//Control
	.inputDiscardCnt( 0 ),		//Number of input pixels to discard before processing data. Used for clipping
	.leftOffset( 0 ),
	.topFracOffset( 0 ),
	.nearestNeighbor( 0 ),
	.done ( done[0] )
	);


//640x512 to 640x512
	scalerTest #(
	.INPUT_X_RES ( 640-1 ),
	.INPUT_Y_RES ( 512-1 ),
	.OUTPUT_X_RES ( 640-1 ),   //Output resolution - 1
	.OUTPUT_Y_RES ( 512-1 ),   //Output resolution - 1
	.X_SCALE ( 32'h4000 ),
	.Y_SCALE ( 32'h4000 ),

	.DATA_WIDTH ( 8 ),
	.DISCARD_CNT_WIDTH ( 8 ),
	.INPUT_X_RES_WIDTH ( 11 ),
	.INPUT_Y_RES_WIDTH ( 11 ),
	.OUTPUT_X_RES_WIDTH ( 11 ),
	.OUTPUT_Y_RES_WIDTH ( 11 ),
	.BUFFER_SIZE ( BUFFER_SIZE )				//Number of RAMs in RAM ring buffer
	) st_640x512to640x512 (
	.inputFilename( `INPUT640x512 ),
	.outputFilename( "out/output640x512to640x512.raw" ),

	//Control
	.inputDiscardCnt( 0 ),		//Number of input pixels to discard before processing data. Used for clipping
	.leftOffset( 0 ),
	.topFracOffset( 0 ),
	.nearestNeighbor( 0 ),
	.done ( done[1] )
	);
	

//1280x1024 to 960x768
	scalerTest #(
	.INPUT_X_RES ( 1280-1 ),
	.INPUT_Y_RES ( 1024-1 ),
	.OUTPUT_X_RES ( 960-1 ),   //Output resolution - 1
	.OUTPUT_Y_RES ( 768-1 ),   //Output resolution - 1
	//.X_SCALE ( X_SCALE ),
	//.Y_SCALE ( Y_SCALE ),

	.DATA_WIDTH ( 8 ),
	.DISCARD_CNT_WIDTH ( 8 ),
	.INPUT_X_RES_WIDTH ( 11 ),
	.INPUT_Y_RES_WIDTH ( 11 ),
	.OUTPUT_X_RES_WIDTH ( 11 ),
	.OUTPUT_Y_RES_WIDTH ( 11 ),
	.BUFFER_SIZE ( BUFFER_SIZE )				//Number of RAMs in RAM ring buffer
	) st_1280x1024to960x768 (
	.inputFilename( `INPUT1280x1024 ),
	.outputFilename( "out/output1280x1024to960x768.raw" ),

	//Control
	.inputDiscardCnt( 0 ),		//Number of input pixels to discard before processing data. Used for clipping
	.leftOffset( 0 ),
	.topFracOffset( 0 ),
	.nearestNeighbor( 0 ),
  	.done ( done[2] )
	);


//1280x1024 to 640x512
	scalerTest #(
	.INPUT_X_RES ( 1280-1 ),
	.INPUT_Y_RES ( 1024-1 ),
	.OUTPUT_X_RES ( 640-1 ),   //Output resolution - 1
	.OUTPUT_Y_RES ( 512-1 ),   //Output resolution - 1
	.X_SCALE ( 32'h4000*2 ),
	.Y_SCALE ( 32'h4000*2 ),

	.DATA_WIDTH ( 8 ),
	.DISCARD_CNT_WIDTH ( 8 ),
	.INPUT_X_RES_WIDTH ( 11 ),
	.INPUT_Y_RES_WIDTH ( 11 ),
	.OUTPUT_X_RES_WIDTH ( 11 ),
	.OUTPUT_Y_RES_WIDTH ( 11 ),
	.BUFFER_SIZE ( BUFFER_SIZE )				//Number of RAMs in RAM ring buffer
	) st_1280x1024to640x512 (
	.inputFilename( `INPUT1280x1024 ),
	.outputFilename( "out/output1280x1024to640x512.raw" ),

	//Control
	.inputDiscardCnt( 0 ),		//Number of input pixels to discard before processing data. Used for clipping
	.leftOffset( 25'h1FFF ),
	.topFracOffset( 25'h1FFF ),
	.nearestNeighbor( 0 ),
	.done ( done[3] )
	);

//1280x1024 to 480x384

	scalerTest #(
	.INPUT_X_RES ( 1280-1 ),
	.INPUT_Y_RES ( 1024-1 ),
	.OUTPUT_X_RES ( 480-1 ),   //Output resolution - 1
	.OUTPUT_Y_RES ( 384-1 ),   //Output resolution - 1
	//.X_SCALE ( 32'h4000*2 ),
	//.Y_SCALE ( 32'h4000*2 ),

	.DATA_WIDTH ( 8 ),
	.DISCARD_CNT_WIDTH ( 8 ),
	.INPUT_X_RES_WIDTH ( 11 ),
	.INPUT_Y_RES_WIDTH ( 11 ),
	.OUTPUT_X_RES_WIDTH ( 11 ),
	.OUTPUT_Y_RES_WIDTH ( 11 ),
	.BUFFER_SIZE ( BUFFER_SIZE )				//Number of RAMs in RAM ring buffer
	) st_1280x1024to480x384 (
	.inputFilename( `INPUT1280x1024 ),
	.outputFilename( "out/output1280x1024to480x384.raw" ),

	//Control
	.inputDiscardCnt( 0 ),		//Number of input pixels to discard before processing data. Used for clipping
	.leftOffset( 0 ),
	.topFracOffset( 0 ),
	.nearestNeighbor( 0 ),
	.done ( done[4] )
		);
	
//640x512 to 1280x1024, discarding 21

	scalerTest #(
	.INPUT_X_RES ( 640-1 ),
	.INPUT_Y_RES ( 512-1 ),
	.OUTPUT_X_RES ( 1280-1 ),   //Output resolution - 1
	.OUTPUT_Y_RES ( 1024-1 ),   //Output resolution - 1
	//.X_SCALE ( 32'h4000*2 ),
	//.Y_SCALE ( 32'h4000*2 ),

	.DATA_WIDTH ( 8 ),
	.DISCARD_CNT_WIDTH ( 8 ),
	.INPUT_X_RES_WIDTH ( 11 ),
	.INPUT_Y_RES_WIDTH ( 11 ),
	.OUTPUT_X_RES_WIDTH ( 11 ),
	.OUTPUT_Y_RES_WIDTH ( 11 ),
	.BUFFER_SIZE ( BUFFER_SIZE )				//Number of RAMs in RAM ring buffer
	) st_640x512to1280x1024_21extra (
	.inputFilename( `INPUT1280x1024_21EXTRA ),
	.outputFilename( "out/output640x512to1280x1024_21extra.raw" ),

	//Control
	.inputDiscardCnt( 21 ),		//Number of input pixels to discard before processing data. Used for clipping
	.leftOffset( 0 ),
	.topFracOffset( 0 ),
	.nearestNeighbor( 0 ),
	.done ( done[5] )
		);
	
//640x512 to 1280x1024, discarding 21

	scalerTest #(
	.INPUT_X_RES ( 640-1 ),
	.INPUT_Y_RES ( 40-1 ),
	.OUTPUT_X_RES ( 640-1 ),   //Output resolution - 1
	.OUTPUT_Y_RES ( 512-1 ),   //Output resolution - 1
	.X_SCALE ( 32'h4000 * (50-1) / (640-1)-1 ),
	.Y_SCALE ( 32'h4000 * (40-1) / (512-1)-1 ),

	.DATA_WIDTH ( 8 ),
	.DISCARD_CNT_WIDTH ( 14 ),
	.INPUT_X_RES_WIDTH ( 11 ),
	.INPUT_Y_RES_WIDTH ( 11 ),
	.OUTPUT_X_RES_WIDTH ( 11 ),
	.OUTPUT_Y_RES_WIDTH ( 11 ),
	.BUFFER_SIZE ( BUFFER_SIZE )				//Number of RAMs in RAM ring buffer
	) st_50x40to640x512clipped (
	.inputFilename( `INPUT640x512 ),
	.outputFilename( "out/output50x40to640x512clipped.raw" ),

	//Control
	.inputDiscardCnt( 640*3 ),		//Number of input pixels to discard before processing data. Used for clipping
	.leftOffset( {11'd249, 14'b0} ),
	.topFracOffset( 0 ),
	.nearestNeighbor( 0 ),
	.done ( done[6] )
		);
	
	initial
	begin
	  #10
	  while(done != 7'b1111111)
	   #10
	   ;
		$stop;
	end
  



endmodule

module scalerTest #(
parameter INPUT_X_RES = 120-1,
parameter INPUT_Y_RES = 90-1,
parameter OUTPUT_X_RES = 1280-1,   //Output resolution - 1
parameter OUTPUT_Y_RES = 960-1,   //Output resolution - 1
parameter X_SCALE = 32'h4000 * (INPUT_X_RES) / (OUTPUT_X_RES)-1,
parameter Y_SCALE = 32'h4000 * (INPUT_Y_RES) / (OUTPUT_Y_RES)-1,

parameter DATA_WIDTH = 8,
parameter CHANNELS = 3,
parameter DISCARD_CNT_WIDTH = 8,
parameter INPUT_X_RES_WIDTH = 11,
parameter INPUT_Y_RES_WIDTH = 11,
parameter OUTPUT_X_RES_WIDTH = 11,
parameter OUTPUT_Y_RES_WIDTH = 11,
parameter BUFFER_SIZE = 6				//Number of RAMs in RAM ring buffer
)(
input wire [50*8:0] inputFilename, outputFilename,

//Control
input wire [DISCARD_CNT_WIDTH-1:0]	inputDiscardCnt,		//Number of input pixels to discard before processing data. Used for clipping
input wire [INPUT_X_RES_WIDTH+14-1:0] leftOffset,
input wire [14-1:0]	topFracOffset,
input wire nearestNeighbor,

output reg done

);


reg clk;
reg rst;


reg [DATA_WIDTH*CHANNELS-1:0] dIn;
reg		dInValid;
wire	nextDin;
reg		start;

wire [DATA_WIDTH*CHANNELS-1:0] dOut;
wire	dOutValid;
reg		nextDout;

integer r, rfile, wfile;

initial // Clock generator
  begin
    #10 //Delay to allow filename to get here
    clk = 0;
    #5 forever #5 clk = !clk;
  end

initial	// Reset
  begin
	done = 0;
    #10 //Delay to allow filename to get here
    rst = 0;
    #5 rst = 1;
    #4 rst = 0;
   // #50000 $stop;
  end

reg eof;
reg [DATA_WIDTH*CHANNELS-1:0] readMem [0:0];
initial // Input file read, generates dIn data
begin
  #10 //Delay to allow filename to get here
	rfile = $fopen(inputFilename, "rb");
	
	dIn = 0;
	dInValid = 0;
	start = 0;

	#41
	start = 1;

	#10
	start = 0;

	#20
	r = $fread(readMem, rfile);
	dIn = readMem[0];
	
	while(! $feof(rfile))
	begin
		dInValid = 1;
		
		#10 
		if(nextDin) 
		begin
			r = $fread(readMem, rfile);
			dIn = readMem[0];
		end
	end

  $fclose(rfile);
end

//Generate nextDout request signal
initial
begin
  #10 //Delay to match filename arrival delay
	nextDout = 0;
	#140001
	forever
	begin
		//This can be used to slow down the read to simulate live read-out. This basically inserts H blank periods.
		#(10*(OUTPUT_X_RES+1)*4)
		nextDout = 0;
		#(10*(OUTPUT_X_RES+1))
		nextDout = 1;
		
	end
end

//Read dOut and write to file
integer dOutCount;
initial
begin
  #10 //Delay to allow filename to get here
	wfile = $fopen(outputFilename, "wb");
	nextDout = 0;
	dOutCount = 0;
	#1
	while(dOutCount < (OUTPUT_X_RES+1) * (OUTPUT_Y_RES+1))
	begin
		#10
		if(dOutValid == 1)
		begin
			$fwrite(wfile, "%c", dOut[23:16]);
			$fwrite(wfile, "%c", dOut[15:8]);
			$fwrite(wfile, "%c", dOut[7:0]);
			dOutCount = dOutCount + 1;
		end
	end
	$fclose(wfile);
	done = 1;
end

streamScaler #(
.DATA_WIDTH( DATA_WIDTH ),
.CHANNELS( CHANNELS ),
.DISCARD_CNT_WIDTH( DISCARD_CNT_WIDTH ),
.INPUT_X_RES_WIDTH( INPUT_X_RES_WIDTH ),
.INPUT_Y_RES_WIDTH( INPUT_Y_RES_WIDTH ),
.OUTPUT_X_RES_WIDTH( OUTPUT_X_RES_WIDTH ),
.OUTPUT_Y_RES_WIDTH( OUTPUT_Y_RES_WIDTH ),
.BUFFER_SIZE( BUFFER_SIZE )				//Number of RAMs in RAM ring buffer
) scaler_inst (
.clk( clk ),
.rst( rst ),

.dIn( dIn ),
.dInValid( dInValid ),
.nextDin( nextDin ),
.start( start ),

.dOut( dOut ),
.dOutValid( dOutValid ),
.nextDout( nextDout ),

//Control
.inputDiscardCnt( inputDiscardCnt ),		//Number of input pixels to discard before processing data. Used for clipping
.inputXRes( INPUT_X_RES ),				//Input data number of pixels per line
.inputYRes( INPUT_Y_RES ),

.outputXRes( OUTPUT_X_RES ),				//Resolution of output data
.outputYRes( OUTPUT_Y_RES ),
.xScale( X_SCALE ),					//Scaling factors. Input resolution scaled by 1/xScale. Format Q4.14
.yScale( Y_SCALE ),					//Scaling factors. Input resolution scaled by 1/yScale. Format Q4.14

.leftOffset( leftOffset ),
.topFracOffset( topFracOffset ),
.nearestNeighbor( nearestNeighbor )
);

endmodule
