/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Discrete Cosine Transform Testbench                        ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2002 Richard Herveille                        ////
////                    richard@asics.ws                         ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: bench_top.v,v 1.2 2002-10-23 09:06:58 rherveille Exp $
//
//  $Date: 2002-10-23 09:06:58 $
//  $Revision: 1.2 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//

`include "timescale.v"

module bench_top();

	//
	// internal wires
	//
	reg clk;
	reg rst;

	reg dstrb;
	reg [7:0] din;
	wire den;
	wire [11:0] dout;

	reg [ 7:0] input_list  [63:0];
	reg [11:0] output_list [63:0];

	integer x,y;

	integer err_cnt;

	//
	// DCT unit
	//

	////////////////////////////////////////////////////////////////////
	//                                                                //
	// ITU-T.81, ITU-T.83 & Coefficient resolution notes              //
	//                                                                //
	////////////////////////////////////////////////////////////////////
	//                                                                //
	// Worst case error (all input values -128) is                    //
	// zero (i.e. no errors) when using 15bit coefficients            //
	//                                                                //
	// Using less bits for the coefficients produces a biterror       //
	// approx. equal to (15 - used_coefficient-bits).                 //
	// e.g. 14bit coefficients, errors in dout-bit[0] only            //
	//      13bit coefficients, errors in dout-bits[1:0]              //
	//      12bit coefficients, errors in dout-bits[2:0] etc.         //
	// Tests with real non-continous tone image data have shown that  //
	// even when using 13bit coefficients errors remain in the lsb    //
	// only (i.e. dout-bit[0]                                         //
	//                                                                //
	// The amount of coefficient-bits needed is dependent on the      //
	// desired quality.                                               //
	// The JPEG-standard compliance specs.(ITU-T.83) prescribe        //
	// that the output of the combined DCT AND Quantization unit      //
	// shall not exceed 1 for the desired quality.                    //
	//                                                                //
	// This means for high quantization levels, lesser bits           //
	// for the DCT unit can be used.                                  //
	//                                                                //
	// Looking at the recommended "quantization tables for generic    //
	// compliance testing of DCT-based processes" (ITU-T.83 annex B)  //
	// it can be noticed that relatively large quantization values    //
	// are being used. Errors in the lower-order bits should          //
	// therefore not be visible.                                      //
	// For certain applications some of the lower-order bits could    //
	// actually be discarded. When looking at the luminance and       //
	// chrominance example quantization tables (ITU-T.81 annex K)     //
	// it can be seen that the smallest quantization value is ten     //
	// (qnt_val_min = 10). This means that the lowest 2bits can be    //
	// discarded (set to zero '0') without having any effect on the   //
	// final result. In this example 11 bit or 12 bit coefficients    //
	// would be sufficient.                                           //
	//                                                                //
	////////////////////////////////////////////////////////////////////

	fdct #(13)
	dut (
		.clk(clk),
		.ena(1'b1),
		.rst(rst),
		.dstrb(dstrb),
		.din(din),
		.dout(dout),
		.douten(den)
	);


	//
	// testbench body
	//

	// generate clock
	always #2.5 clk <= ~clk;

	// initial statements
	initial
	begin

		// waves statement
		`ifdef WAVES
		    $shm_open("waves");
		    $shm_probe("AS",bench_top,"AS");
		    $display("INFO: Signal dump enabled ...\n\n");
		`endif

		// fill input-table

		input_list[00] <= 8'd139;
		input_list[01] <= 8'd144;
		input_list[02] <= 8'd149;
		input_list[03] <= 8'd153;
		input_list[04] <= 8'd155;
		input_list[05] <= 8'd155;
		input_list[06] <= 8'd155;
		input_list[07] <= 8'd155;
		input_list[08] <= 8'd144;
		input_list[09] <= 8'd151;
		input_list[10] <= 8'd153;
		input_list[11] <= 8'd156;
		input_list[12] <= 8'd159;
		input_list[13] <= 8'd156;
		input_list[14] <= 8'd156;
		input_list[15] <= 8'd156;
		input_list[16] <= 8'd150;
		input_list[17] <= 8'd155;
		input_list[18] <= 8'd160;
		input_list[19] <= 8'd163;
		input_list[20] <= 8'd158;
		input_list[21] <= 8'd156;
		input_list[22] <= 8'd156;
		input_list[23] <= 8'd156;
		input_list[24] <= 8'd159;
		input_list[25] <= 8'd161;
		input_list[26] <= 8'd162;
		input_list[27] <= 8'd160;
		input_list[28] <= 8'd160;
		input_list[29] <= 8'd159;
		input_list[30] <= 8'd159;
		input_list[31] <= 8'd159;
		input_list[32] <= 8'd159;
		input_list[33] <= 8'd160;
		input_list[34] <= 8'd161;
		input_list[35] <= 8'd162;
		input_list[36] <= 8'd162;
		input_list[37] <= 8'd155;
		input_list[38] <= 8'd155;
		input_list[39] <= 8'd155;
		input_list[40] <= 8'd161;
		input_list[41] <= 8'd161;
		input_list[42] <= 8'd161;
		input_list[43] <= 8'd161;
		input_list[44] <= 8'd160;
		input_list[45] <= 8'd157;
		input_list[46] <= 8'd157;
		input_list[47] <= 8'd157;
		input_list[48] <= 8'd162;
		input_list[49] <= 8'd162;
		input_list[50] <= 8'd161;
		input_list[51] <= 8'd163;
		input_list[52] <= 8'd162;
		input_list[53] <= 8'd157;
		input_list[54] <= 8'd157;
		input_list[55] <= 8'd157;
		input_list[56] <= 8'd162;
		input_list[57] <= 8'd162;
		input_list[58] <= 8'd161;
		input_list[59] <= 8'd161;
		input_list[60] <= 8'd163;
		input_list[61] <= 8'd158;
		input_list[62] <= 8'd158;
		input_list[63] <= 8'd158;
/*
		input_list[00] <= 8'd0;
		input_list[01] <= 8'd0;
		input_list[02] <= 8'd0;
		input_list[03] <= 8'd0;
		input_list[04] <= 8'd0;
		input_list[05] <= 8'd0;
		input_list[06] <= 8'd0;
		input_list[07] <= 8'd0;
		input_list[08] <= 8'd0;
		input_list[09] <= 8'd0;
		input_list[10] <= 8'd0;
		input_list[11] <= 8'd0;
		input_list[12] <= 8'd0;
		input_list[13] <= 8'd0;
		input_list[14] <= 8'd0;
		input_list[15] <= 8'd0;
		input_list[16] <= 8'd0;
		input_list[17] <= 8'd0;
		input_list[18] <= 8'd0;
		input_list[19] <= 8'd0;
		input_list[20] <= 8'd0;
		input_list[21] <= 8'd0;
		input_list[22] <= 8'd0;
		input_list[23] <= 8'd0;
		input_list[24] <= 8'd0;
		input_list[25] <= 8'd0;
		input_list[26] <= 8'd0;
		input_list[27] <= 8'd0;
		input_list[28] <= 8'd0;
		input_list[29] <= 8'd0;
		input_list[30] <= 8'd0;
		input_list[31] <= 8'd0;
		input_list[32] <= 8'd0;
		input_list[33] <= 8'd0;
		input_list[34] <= 8'd0;
		input_list[35] <= 8'd0;
		input_list[36] <= 8'd0;
		input_list[37] <= 8'd0;
		input_list[38] <= 8'd0;
		input_list[39] <= 8'd0;
		input_list[40] <= 8'd0;
		input_list[41] <= 8'd0;
		input_list[42] <= 8'd0;
		input_list[43] <= 8'd0;
		input_list[44] <= 8'd0;
		input_list[45] <= 8'd0;
		input_list[46] <= 8'd0;
		input_list[47] <= 8'd0;
		input_list[48] <= 8'd0;
		input_list[49] <= 8'd0;
		input_list[50] <= 8'd0;
		input_list[51] <= 8'd0;
		input_list[52] <= 8'd0;
		input_list[53] <= 8'd0;
		input_list[54] <= 8'd0;
		input_list[55] <= 8'd0;
		input_list[56] <= 8'd0;
		input_list[57] <= 8'd0;
		input_list[58] <= 8'd0;
		input_list[59] <= 8'd0;
		input_list[60] <= 8'd0;
		input_list[61] <= 8'd0;
		input_list[62] <= 8'd0;
		input_list[63] <= 8'd0;
*/
		// fill output-table
		output_list[00] <= 12'h1d7;
		output_list[01] <= 12'hffe;
		output_list[02] <= 12'hfd3;
		output_list[03] <= 12'hfea;
		output_list[04] <= 12'hfdd; //16bit resolution returns 13'h1fdc
		output_list[05] <= 12'hfe8;
		output_list[06] <= 12'hff6;
		output_list[07] <= 12'hff4;
		output_list[08] <= 12'hfed;
		output_list[09] <= 12'hff2;
		output_list[10] <= 12'hfff;
		output_list[11] <= 12'hffc;
		output_list[12] <= 12'hffd;
		output_list[13] <= 12'hffa;
		output_list[14] <= 12'h004;
		output_list[15] <= 12'hffd;
		output_list[16] <= 12'hffa;
		output_list[17] <= 12'h003;
		output_list[18] <= 12'h000;
		output_list[19] <= 12'hffe;
		output_list[20] <= 12'h004;
		output_list[21] <= 12'hffd;
		output_list[22] <= 12'h000;
		output_list[23] <= 12'h003;
		output_list[24] <= 12'h003;
		output_list[25] <= 12'h000;
		output_list[26] <= 12'h000;
		output_list[27] <= 12'hffb;
		output_list[28] <= 12'h003;
		output_list[29] <= 12'h001;
		output_list[30] <= 12'hffe;
		output_list[31] <= 12'h002;
		output_list[32] <= 12'h003;
		output_list[33] <= 12'h003;
		output_list[34] <= 12'hfff;
		output_list[35] <= 12'hffb;
		output_list[36] <= 12'h003;
		output_list[37] <= 12'hfff;
		output_list[38] <= 12'hfff;
		output_list[39] <= 12'h000;
		output_list[40] <= 12'h000;
		output_list[41] <= 12'hfff;
		output_list[42] <= 12'hffe;
		output_list[43] <= 12'h000;
		output_list[44] <= 12'h000;
		output_list[45] <= 12'hfff;
		output_list[46] <= 12'hffe;
		output_list[47] <= 12'hffd;
		output_list[48] <= 12'hff8;
		output_list[49] <= 12'hffc;
		output_list[50] <= 12'hfff;
		output_list[51] <= 12'h003;
		output_list[52] <= 12'h001;
		output_list[53] <= 12'h001;
		output_list[54] <= 12'h003;
		output_list[55] <= 12'h002;
		output_list[56] <= 12'h003;
		output_list[57] <= 12'h004;
		output_list[58] <= 12'h002;
		output_list[59] <= 12'h002;
		output_list[60] <= 12'hffe;
		output_list[61] <= 12'hffe;
		output_list[62] <= 12'hfff;
		output_list[63] <= 12'hfff;

		clk = 0; // start with low-level clock
		rst = 0; // reset system
		dstrb = 1'b0;

		rst = #17 1'b1;

		// wait a while
		repeat(20) @(posedge clk);

		// present dstrb
		dstrb = #1 1'b1;
		@(posedge clk)
		dstrb = #1 1'b0;

		for(y=0; y<=7; y=y+1)
		for(x=0; x<=7; x=x+1)
		begin
		  din = #1 input_list[y*8 +x] -8'd128;
		  @(posedge clk);
		end

		// wait for 'den' signal
		while (!den) @(posedge clk);

		// den is presented 1clk cycle before data
		@(posedge clk);

		err_cnt = 0;
		for(y=0; y<=7; y=y+1)
		for(x=0; x<=7; x=x+1)
		begin
			if (dout !== output_list[y*8 +x])
			begin
			  $display("Data compare error, received %h, expected %h. %d",
			           dout, output_list[y*8 +x], y*8 +x);

			  err_cnt = err_cnt +1;
			end

			@(posedge clk);
		end

		$display("\nTotal errors: %d", err_cnt);
		$stop;
	end

endmodule
