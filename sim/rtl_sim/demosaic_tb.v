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

Testbench for bilinearDemosaic V1.0.0

*/

`default_nettype none

module scalerTestbench;
parameter BUFFER_SIZE = 4;

wire [2:0] done;

//Input throttling (data source slower than data sink)
	demosaicTest #(
	.X_RES ( 640-1 ),
	.Y_RES ( 512-1 ),
	
	.DATA_WIDTH ( 8 ),
	.X_RES_WIDTH ( 11 ),
	.Y_RES_WIDTH ( 11 ),
	.BUFFER_SIZE ( BUFFER_SIZE ),				//Number of RAMs in RFIFO
	.DIN_VALID_PERIOD ( 1000 ),
	.DIN_VALID_ON( 800 ),
	.DOUT_VALID_PERIOD( 1000 ),
	.DOUT_VALID_ON( 1000 )
	) dt_640x512_it (
	.inputFilename( "src/input640x512RGBBlur.raw" ),
	.outputFilename( "dst/outputIT.raw" ),

	//Control
	.done ( done[0] )
	);


//No throttling (full speed)
	demosaicTest #(
	.X_RES ( 640-1 ),
	.Y_RES ( 512-1 ),
	
	.DATA_WIDTH ( 8 ),
	.X_RES_WIDTH ( 11 ),
	.Y_RES_WIDTH ( 11 ),
	.BUFFER_SIZE ( BUFFER_SIZE ),				//Number of RAMs in RFIFO
	.DIN_VALID_PERIOD ( 1000 ),
	.DIN_VALID_ON( 1000 ),
	.DOUT_VALID_PERIOD( 1000 ),
	.DOUT_VALID_ON( 1000 )
	) dt_640x512_fs (
	.inputFilename( "src/input640x512RGBBlur.raw" ),
	.outputFilename( "dst/outputFS.raw" ),

	//Control
	.done ( done[1] )
	);
	
//output throttling (data sink slower than data source, as in typical readout for a live display with blanking periods)
	demosaicTest #(
	.X_RES ( 640-1 ),
	.Y_RES ( 512-1 ),
	
	.DATA_WIDTH ( 8 ),
	.X_RES_WIDTH ( 11 ),
	.Y_RES_WIDTH ( 11 ),
	.BUFFER_SIZE ( BUFFER_SIZE ),				//Number of RAMs in RFIFO
	.DIN_VALID_PERIOD ( 1000 ),
	.DIN_VALID_ON( 1000 ),
	.DOUT_VALID_PERIOD( 1000 ),
	.DOUT_VALID_ON( 800 )
	) dt_640x512_ot (
	.inputFilename( "src/input640x512RGBBlur.raw" ),
	.outputFilename( "dst/outputOT.raw" ),

	//Control
	.done ( done[2] )
	);
	
	initial
	begin
	  #10
	  while(done != 3'b111)
	   #10
	   ;
		$stop;
	end
endmodule


module demosaicTest #(
parameter X_RES = 640-1,
parameter Y_RES = 512-1,

parameter DATA_WIDTH = 8,
parameter X_RES_WIDTH = 11,
parameter Y_RES_WIDTH = 11,

parameter BUFFER_SIZE = 5,				//Number of RAMs in RFIFO

parameter DIN_VALID_PERIOD = 1000,
parameter DIN_VALID_ON = 1000,
parameter DOUT_VALID_PERIOD = 1000,
parameter DOUT_VALID_ON = 1000

)(
input wire [50*8:0] inputFilename, outputFilename,

//Control

output reg done
);

reg						clk;
reg						rst;

reg [DATA_WIDTH-1:0]	dIn;
reg						dInValid;
wire					nextDin;
reg						start;

wire [DATA_WIDTH-1:0]	rOut;
wire [DATA_WIDTH-1:0]	gOut;
wire [DATA_WIDTH-1:0]	bOut;
wire					dOutValid;
reg						nextDout;

reg [X_RES_WIDTH-1:0]	xCount;
reg [Y_RES_WIDTH-1:0]	yCount;

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
reg [24-1:0] readMem [0:0];
integer readCount;

wire [1:0] quadSelect = {yCount[0], xCount[0]};
initial // Input file read, generates dIn data
begin
  #10 //Delay to allow filename to get here
	rfile = $fopen(inputFilename, "rb");
	
	dIn = 0;
	dInValid = 0;
	start = 0;
	xCount = 0;
	yCount = 0;
	readCount = 0;
	
	#41
	start = 1;

	#10
	start = 0;

	#20
	r = $fread(readMem, rfile);
	dIn =	quadSelect == 2'b00 ? readMem[0][23:16] :		//RG	[23:16] is first data (R)
			quadSelect == 2'b01 ? readMem[0][15:8] :	//GB
			quadSelect == 2'b10 ? readMem[0][15:8] :
								  readMem[0][7:0];
	xCount = xCount + 1;
	
	dInValid = 1;
	
	while(! $feof(rfile))
	begin
		#10 
		if(nextDin) 
		begin
			if(dInValid)
			begin
				r = $fread(readMem, rfile);
			
			
				dIn =	quadSelect == 2'b00 ? readMem[0][23:16] :		//RG	[23:16] is first data (R)
						quadSelect == 2'b01 ? readMem[0][15:8] :	//GB
						quadSelect == 2'b10 ? readMem[0][15:8] :
											  readMem[0][7:0];
				
				if(xCount == X_RES)
				begin
					xCount = 0;
					yCount = yCount + 1;
				end
				else
					xCount = xCount + 1;
			end
			
			readCount = readCount + 1;	//pulse dInValid to simulate a slow data source
			if(readCount == DIN_VALID_PERIOD)
			begin
				readCount = 0;
				dInValid = 1;
			end
			else if(readCount == DIN_VALID_ON)
			begin
				dInValid = 0;
			end
			
			
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
		#(10*(DOUT_VALID_PERIOD - DOUT_VALID_ON))
		nextDout = 1;
		#(10*(DOUT_VALID_ON))
		nextDout = 0;
		
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
	while(dOutCount < ((X_RES+1) * (Y_RES+1)))
	begin
		#10
		if(dOutValid == 1)
		begin
			$fwrite(wfile, "%c", rOut[7:0]);
			$fwrite(wfile, "%c", gOut[7:0]);
			$fwrite(wfile, "%c", bOut[7:0]);
			dOutCount = dOutCount + 1;
		end
	end
	$fclose(wfile);
	done = 1;
end

bilinearDemosaic #(
.DATA_WIDTH( DATA_WIDTH ),
.X_RES_WIDTH( X_RES_WIDTH ),
.Y_RES_WIDTH( Y_RES_WIDTH ),
.BUFFER_SIZE( BUFFER_SIZE )				//Number of RAMs in RFIFO
) demosaic_inst (
.clk( clk ),
.rst( rst ),

.dIn( dIn ),
.dInValid( dInValid ),
.nextDin( nextDin ),
.start( start ),

.rOut( rOut ),
.gOut( gOut ),
.bOut( bOut ),
.dOutValid( dOutValid ),
.nextDout( nextDout ),

.bayerPattern( 0 ),
.xRes( X_RES ),				//Input data number of pixels per line
.yRes( Y_RES )

);
endmodule
