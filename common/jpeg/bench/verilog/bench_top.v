/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Discrete Cosine Transform Testbench (ITU-T.81 & ITU-T.83)  ////
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
//  $Id: bench_top.v,v 1.1 2002-10-23 09:07:01 rherveille Exp $
//
//  $Date: 2002-10-23 09:07:01 $
//  $Revision: 1.1 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//

`include "timescale.v"

module bench_top();

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
	// only (i.e. FDCT dout-bit[0])                                   //
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
	// Tests with real continuous and non-continous tone image data   //
	// have shown that when using the example quantization tables     //
	// from ITU-T.81 annex K, 10bits coefficients are sufficient to   //
	// comply to the ITU-T.83 specs. Compliance tests have been met   //
	// using as little as 9bit coefficients.                          //
	// For certain applications some of the lower-order bits could    //
	// actually be discarded. When looking at the luminance and       //
	// chrominance example quantization tables (ITU-T.81 annex K)     //
	// it can be seen that the smallest quantization value is ten     //
	// (qnt_val_min = 10). This means that the lower 2bits can be     //
	// discarded (set to zero '0') without having any effect on the   //
	// final result. In this example 11 bit or 12 bit coefficients    //
	// would be sufficient.                                           //
	//                                                                //
	////////////////////////////////////////////////////////////////////
	parameter coef_width = 13; //9;

	// amount of 8x8 data packets to use for tests (current max. = 4)
	parameter input_lists_start = 1;
	parameter input_lists_end = 4;


	//
	// internal wires
	//
	reg clk;
	reg rst;

	reg dstrb;
	reg [7:0] din;
	wire den;
	wire [10:0] dout;
	wire [ 3:0] size, rlen;
	wire [11:0] amp;

	reg [ 7:0] input_list  [(input_lists_end*64) -1:0];

	reg [7:0] qnt_list [63:0];
	wire [5:0] qnt_cnt;
	reg [7:0] qnt_val;


	integer x,y;
	integer n, list_cnt;

	//
	// JPEG Encoder unit
	//

	jpeg_encoder #(coef_width)
	jpeg_enc (
		.clk(clk),
		.ena(1'b1),
		.rst(rst),
		.dstrb(dstrb),
		.din(din),
		.qnt_val(qnt_val),
		.qnt_cnt(qnt_cnt),
		.size(size),
		.rlen(rlen),
		.amp(amp),
//		.dout(dout),
		.douten(den)
	);

	// generate Quantization memory
	always @(posedge clk)
	  qnt_val <= #1 qnt_list[qnt_cnt];

	// hookup checker-modules
	fdct_qnr_checker #(input_lists_start, input_lists_end)
	output_check (
		.clk(clk),
		.rst(rst),
		.dstrb(jpeg_enc.dqnr_doe),
		.din(jpeg_enc.qnr_dout)
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

		//
		// fill input-table
		//

		// input list 1
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

		// input list 2
		input_list[064] <= 8'd0;
		input_list[065] <= 8'd0;
		input_list[066] <= 8'd0;
		input_list[067] <= 8'd0;
		input_list[068] <= 8'd0;
		input_list[069] <= 8'd0;
		input_list[070] <= 8'd0;
		input_list[071] <= 8'd0;
		input_list[072] <= 8'd0;
		input_list[073] <= 8'd0;
		input_list[074] <= 8'd0;
		input_list[075] <= 8'd0;
		input_list[076] <= 8'd0;
		input_list[077] <= 8'd0;
		input_list[078] <= 8'd0;
		input_list[079] <= 8'd0;
		input_list[080] <= 8'd0;
		input_list[081] <= 8'd0;
		input_list[082] <= 8'd0;
		input_list[083] <= 8'd0;
		input_list[084] <= 8'd0;
		input_list[085] <= 8'd0;
		input_list[086] <= 8'd0;
		input_list[087] <= 8'd0;
		input_list[088] <= 8'd0;
		input_list[089] <= 8'd0;
		input_list[090] <= 8'd0;
		input_list[091] <= 8'd0;
		input_list[092] <= 8'd0;
		input_list[093] <= 8'd0;
		input_list[094] <= 8'd0;
		input_list[095] <= 8'd0;
		input_list[096] <= 8'd0;
		input_list[097] <= 8'd0;
		input_list[098] <= 8'd0;
		input_list[099] <= 8'd0;
		input_list[100] <= 8'd0;
		input_list[101] <= 8'd0;
		input_list[102] <= 8'd0;
		input_list[103] <= 8'd0;
		input_list[104] <= 8'd0;
		input_list[105] <= 8'd0;
		input_list[106] <= 8'd0;
		input_list[107] <= 8'd0;
		input_list[108] <= 8'd0;
		input_list[109] <= 8'd0;
		input_list[110] <= 8'd0;
		input_list[111] <= 8'd0;
		input_list[112] <= 8'd0;
		input_list[113] <= 8'd0;
		input_list[114] <= 8'd0;
		input_list[115] <= 8'd0;
		input_list[116] <= 8'd0;
		input_list[117] <= 8'd0;
		input_list[118] <= 8'd0;
		input_list[119] <= 8'd0;
		input_list[120] <= 8'd0;
		input_list[121] <= 8'd0;
		input_list[122] <= 8'd0;
		input_list[123] <= 8'd0;
		input_list[124] <= 8'd0;
		input_list[125] <= 8'd0;
		input_list[126] <= 8'd0;
		input_list[127] <= 8'd0;

		// input list 3
		input_list[128] <= 8'd70;
		input_list[129] <= 8'd72;
		input_list[130] <= 8'd70;
		input_list[131] <= 8'd70;
		input_list[132] <= 8'd72;
		input_list[133] <= 8'd68;
		input_list[134] <= 8'd68;
		input_list[135] <= 8'd64;
		input_list[136] <= 8'd103;
		input_list[137] <= 8'd101;
		input_list[138] <= 8'd103;
		input_list[139] <= 8'd100;
		input_list[140] <= 8'd99;
		input_list[141] <= 8'd97;
		input_list[142] <= 8'd94;
		input_list[143] <= 8'd94;
		input_list[144] <= 8'd132;
		input_list[145] <= 8'd132;
		input_list[146] <= 8'd132;
		input_list[147] <= 8'd130;
		input_list[148] <= 8'd129;
		input_list[149] <= 8'd129;
		input_list[150] <= 8'd125;
		input_list[151] <= 8'd121;
		input_list[152] <= 8'd157;
		input_list[153] <= 8'd157;
		input_list[154] <= 8'd155;
		input_list[155] <= 8'd154;
		input_list[156] <= 8'd153;
		input_list[157] <= 8'd150;
		input_list[158] <= 8'd148;
		input_list[159] <= 8'd145;
		input_list[160] <= 8'd168;
		input_list[161] <= 8'd163;
		input_list[162] <= 8'd164;
		input_list[163] <= 8'd162;
		input_list[164] <= 8'd163;
		input_list[165] <= 8'd161;
		input_list[166] <= 8'd161;
		input_list[167] <= 8'd156;
		input_list[168] <= 8'd172;
		input_list[169] <= 8'd170;
		input_list[170] <= 8'd165;
		input_list[171] <= 8'd166;
		input_list[172] <= 8'd163;
		input_list[173] <= 8'd163;
		input_list[174] <= 8'd162;
		input_list[175] <= 8'd158;
		input_list[176] <= 8'd174;
		input_list[177] <= 8'd170;
		input_list[178] <= 8'd167;
		input_list[179] <= 8'd167;
		input_list[180] <= 8'd164;
		input_list[181] <= 8'd163;
		input_list[182] <= 8'd164;
		input_list[183] <= 8'd159;
		input_list[184] <= 8'd174;
		input_list[185] <= 8'd173;
		input_list[186] <= 8'd170;
		input_list[187] <= 8'd167;
		input_list[188] <= 8'd167;
		input_list[189] <= 8'd166;
		input_list[190] <= 8'd166;
		input_list[191] <= 8'd160;

		// input list 4
		input_list[192] <= 8'd151;
		input_list[193] <= 8'd147;
		input_list[194] <= 8'd152;
		input_list[195] <= 8'd140;
		input_list[196] <= 8'd138;
		input_list[197] <= 8'd125;
		input_list[198] <= 8'd136;
		input_list[199] <= 8'd160;
		input_list[200] <= 8'd157;
		input_list[201] <= 8'd148;
		input_list[202] <= 8'd152;
		input_list[203] <= 8'd137;
		input_list[204] <= 8'd124;
		input_list[205] <= 8'd105;
		input_list[206] <= 8'd108;
		input_list[207] <= 8'd144;
		input_list[208] <= 8'd152;
		input_list[209] <= 8'd151;
		input_list[210] <= 8'd146;
		input_list[211] <= 8'd128;
		input_list[212] <= 8'd99;
		input_list[213] <= 8'd73;
		input_list[214] <= 8'd75;
		input_list[215] <= 8'd116;
		input_list[216] <= 8'd154;
		input_list[217] <= 8'd148;
		input_list[218] <= 8'd145;
		input_list[219] <= 8'd111;
		input_list[220] <= 8'd91;
		input_list[221] <= 8'd68;
		input_list[222] <= 8'd62;
		input_list[223] <= 8'd98;
		input_list[224] <= 8'd156;
		input_list[225] <= 8'd144;
		input_list[226] <= 8'd147;
		input_list[227] <= 8'd93;
		input_list[228] <= 8'd97;
		input_list[229] <= 8'd105;
		input_list[230] <= 8'd61;
		input_list[231] <= 8'd82;
		input_list[232] <= 8'd155;
		input_list[233] <= 8'd139;
		input_list[234] <= 8'd149;
		input_list[235] <= 8'd76;
		input_list[236] <= 8'd101;
		input_list[237] <= 8'd140;
		input_list[238] <= 8'd59;
		input_list[239] <= 8'd74;
		input_list[240] <= 8'd148;
		input_list[241] <= 8'd135;
		input_list[242] <= 8'd147;
		input_list[243] <= 8'd71;
		input_list[244] <= 8'd114;
		input_list[245] <= 8'd158;
		input_list[246] <= 8'd79;
		input_list[247] <= 8'd66;
		input_list[248] <= 8'd135;
		input_list[249] <= 8'd120;
		input_list[250] <= 8'd133;
		input_list[251] <= 8'd92;
		input_list[252] <= 8'd133;
		input_list[253] <= 8'd176;
		input_list[254] <= 8'd103;
		input_list[255] <= 8'd60;

		//
		// fill quantization table (IN ZIG-ZAG ORDER !!!)
		//

		// quantization table list 1
		qnt_list[00] <= 8'd16;
		qnt_list[01] <= 8'd11;
		qnt_list[02] <= 8'd12;
		qnt_list[03] <= 8'd14;
		qnt_list[04] <= 8'd12;
		qnt_list[05] <= 8'd10;
		qnt_list[06] <= 8'd16;
		qnt_list[07] <= 8'd14;
		qnt_list[08] <= 8'd13;
		qnt_list[09] <= 8'd14;
		qnt_list[10] <= 8'd18;
		qnt_list[11] <= 8'd17;
		qnt_list[12] <= 8'd16;
		qnt_list[13] <= 8'd19;
		qnt_list[14] <= 8'd24;
		qnt_list[15] <= 8'd40;
		qnt_list[16] <= 8'd26;
		qnt_list[17] <= 8'd24;
		qnt_list[18] <= 8'd22;
		qnt_list[19] <= 8'd22;
		qnt_list[20] <= 8'd24;
		qnt_list[21] <= 8'd49;
		qnt_list[22] <= 8'd35;
		qnt_list[23] <= 8'd37;
		qnt_list[24] <= 8'd29;
		qnt_list[25] <= 8'd40;
		qnt_list[26] <= 8'd58;
		qnt_list[27] <= 8'd51;
		qnt_list[28] <= 8'd61;
		qnt_list[29] <= 8'd60;
		qnt_list[30] <= 8'd57;
		qnt_list[31] <= 8'd51;
		qnt_list[32] <= 8'd56;
		qnt_list[33] <= 8'd55;
		qnt_list[34] <= 8'd64;
		qnt_list[35] <= 8'd72;
		qnt_list[36] <= 8'd92;
		qnt_list[37] <= 8'd78;
		qnt_list[38] <= 8'd64;
		qnt_list[39] <= 8'd68;
		qnt_list[40] <= 8'd87;
		qnt_list[41] <= 8'd69;
		qnt_list[42] <= 8'd55;
		qnt_list[43] <= 8'd56;
		qnt_list[44] <= 8'd80;
		qnt_list[45] <= 8'd109;
		qnt_list[46] <= 8'd81;
		qnt_list[47] <= 8'd87;
		qnt_list[48] <= 8'd95;
		qnt_list[49] <= 8'd98;
		qnt_list[50] <= 8'd103;
		qnt_list[51] <= 8'd104;
		qnt_list[52] <= 8'd103;
		qnt_list[53] <= 8'd62;
		qnt_list[54] <= 8'd77;
		qnt_list[55] <= 8'd113;
		qnt_list[56] <= 8'd121;
		qnt_list[57] <= 8'd112;
		qnt_list[58] <= 8'd100;
		qnt_list[59] <= 8'd120;
		qnt_list[60] <= 8'd92;
		qnt_list[61] <= 8'd101;
		qnt_list[62] <= 8'd103;
		qnt_list[63] <= 8'd99;


		//
		// initial body
		//

		clk = 0; // start with low-level clock
		rst = 0; // reset system
		dstrb = 1'b0;

		rst = #17 1'b1;

		list_cnt = (input_lists_start -1) * 64;

		// wait a while
		repeat(20) @(posedge clk);

		for(n=input_lists_start; n <= input_lists_end; n = n +1)
		begin
			// present dstrb
			dstrb = #1 1'b1;

			for(y=0; y<=7; y=y+1)
			for(x=0; x<=7; x=x+1)
			begin
				@(posedge clk)
				dstrb = #1 1'b0;

				din = #1 input_list[list_cnt] -8'd128;
				list_cnt = list_cnt +1;
			end
		end
	end

endmodule

//
// check outputs
//
module fdct_qnr_checker(clk, rst, dstrb, din);

	parameter output_lists_start = 2;
	parameter output_lists_end = 2;

	//
	// inputs
	//
	input clk;
	input rst;
	input dstrb;
	input [10:0] din;

	//
	// variables
	//
	reg [10:0] output_list [(output_lists_end*64) -1:0];

	integer x, y;
	integer n, err_cnt;
	integer list_cnt;

	reg go;

	//
	// module body
	//

	always @(posedge clk)
	  go <= #1 dstrb;

	initial
	begin
	  //
	  // fill output-table (IN ZIG-ZAG ORDER)
	  //

	  // output list 1
	  output_list[00] <= 11'h00f;
	  output_list[01] <= 11'h000;
	  output_list[02] <= 11'h7fe;
	  output_list[03] <= 11'h7ff;
	  output_list[04] <= 11'h7ff;
	  output_list[05] <= 11'h7ff;
	  output_list[06] <= 11'h000;
	  output_list[07] <= 11'h000;
	  output_list[08] <= 11'h7ff;
	  output_list[09] <= 11'h000;
	  output_list[10] <= 11'h000;
	  output_list[11] <= 11'h000;
	  output_list[12] <= 11'h000;
	  output_list[13] <= 11'h000;
	  output_list[14] <= 11'h000;
	  output_list[15] <= 11'h000;
	  output_list[16] <= 11'h000;
	  output_list[17] <= 11'h000;
	  output_list[18] <= 11'h000;
	  output_list[19] <= 11'h000;
	  output_list[20] <= 11'h000;
	  output_list[21] <= 11'h000;
	  output_list[22] <= 11'h000;
	  output_list[23] <= 11'h000;
	  output_list[24] <= 11'h000;
	  output_list[25] <= 11'h000;
	  output_list[26] <= 11'h000;
	  output_list[27] <= 11'h000;
	  output_list[28] <= 11'h000;
	  output_list[29] <= 11'h000;
	  output_list[30] <= 11'h000;
	  output_list[31] <= 11'h000;
	  output_list[32] <= 11'h000;
	  output_list[33] <= 11'h000;
	  output_list[34] <= 11'h000;
	  output_list[35] <= 11'h000;
	  output_list[36] <= 11'h000;
	  output_list[37] <= 11'h000;
	  output_list[38] <= 11'h000;
	  output_list[39] <= 11'h000;
	  output_list[40] <= 11'h000;
	  output_list[41] <= 11'h000;
	  output_list[42] <= 11'h000;
	  output_list[43] <= 11'h000;
	  output_list[44] <= 11'h000;
	  output_list[45] <= 11'h000;
	  output_list[46] <= 11'h000;
	  output_list[47] <= 11'h000;
	  output_list[48] <= 11'h000;
	  output_list[49] <= 11'h000;
	  output_list[50] <= 11'h000;
	  output_list[51] <= 11'h000;
	  output_list[52] <= 11'h000;
	  output_list[53] <= 11'h000;
	  output_list[54] <= 11'h000;
	  output_list[55] <= 11'h000;
	  output_list[56] <= 11'h000;
	  output_list[57] <= 11'h000;
	  output_list[58] <= 11'h000;
	  output_list[59] <= 11'h000;
	  output_list[60] <= 11'h000;
	  output_list[61] <= 11'h000;
	  output_list[62] <= 11'h000;
	  output_list[63] <= 11'h000;

	  // output list 2
	  output_list[064] <= 11'h7c0;
	  output_list[065] <= 11'h000;
	  output_list[066] <= 11'h000;
	  output_list[067] <= 11'h000;
	  output_list[068] <= 11'h000;
	  output_list[069] <= 11'h000;
	  output_list[070] <= 11'h000;
	  output_list[071] <= 11'h000;
	  output_list[072] <= 11'h000;
	  output_list[073] <= 11'h000;
	  output_list[074] <= 11'h000;
	  output_list[075] <= 11'h000;
	  output_list[076] <= 11'h000;
	  output_list[077] <= 11'h000;
	  output_list[078] <= 11'h000;
	  output_list[079] <= 11'h000;
	  output_list[080] <= 11'h000;
	  output_list[081] <= 11'h000;
	  output_list[082] <= 11'h000;
	  output_list[083] <= 11'h000;
	  output_list[084] <= 11'h000;
	  output_list[085] <= 11'h000;
	  output_list[086] <= 11'h000;
	  output_list[087] <= 11'h000;
	  output_list[088] <= 11'h000;
	  output_list[089] <= 11'h000;
	  output_list[090] <= 11'h000;
	  output_list[091] <= 11'h000;
	  output_list[092] <= 11'h000;
	  output_list[093] <= 11'h000;
	  output_list[094] <= 11'h000;
	  output_list[095] <= 11'h000;
	  output_list[096] <= 11'h000;
	  output_list[097] <= 11'h000;
	  output_list[098] <= 11'h000;
	  output_list[099] <= 11'h000;
	  output_list[100] <= 11'h000;
	  output_list[101] <= 11'h000;
	  output_list[102] <= 11'h000;
	  output_list[103] <= 11'h000;
	  output_list[104] <= 11'h000;
	  output_list[105] <= 11'h000;
	  output_list[106] <= 11'h000;
	  output_list[107] <= 11'h000;
	  output_list[108] <= 11'h000;
	  output_list[109] <= 11'h000;
	  output_list[110] <= 11'h000;
	  output_list[111] <= 11'h000;
	  output_list[112] <= 11'h000;
	  output_list[113] <= 11'h000;
	  output_list[114] <= 11'h000;
	  output_list[115] <= 11'h000;
	  output_list[116] <= 11'h000;
	  output_list[117] <= 11'h000;
	  output_list[118] <= 11'h000;
	  output_list[119] <= 11'h000;
	  output_list[120] <= 11'h000;
	  output_list[121] <= 11'h000;
	  output_list[122] <= 11'h000;
	  output_list[123] <= 11'h000;
	  output_list[124] <= 11'h000;
	  output_list[125] <= 11'h000;
	  output_list[126] <= 11'h000;
	  output_list[127] <= 11'h000;

	  // output list 3
	  output_list[128] <= 11'h005;
	  output_list[129] <= 11'h002;
	  output_list[130] <= 11'h7eb;
	  output_list[131] <= 11'h7f8;
	  output_list[132] <= 11'h000;
	  output_list[133] <= 11'h000;
	  output_list[134] <= 11'h000;
	  output_list[135] <= 11'h000;
	  output_list[136] <= 11'h000;
	  output_list[137] <= 11'h7fd;
	  output_list[138] <= 11'h000;
	  output_list[139] <= 11'h000;
	  output_list[140] <= 11'h000;
	  output_list[141] <= 11'h000;
	  output_list[142] <= 11'h000;
	  output_list[143] <= 11'h000;
	  output_list[144] <= 11'h000;
	  output_list[145] <= 11'h000;
	  output_list[146] <= 11'h000;
	  output_list[147] <= 11'h000;
	  output_list[148] <= 11'h000;
	  output_list[149] <= 11'h000;
	  output_list[150] <= 11'h000;
	  output_list[151] <= 11'h000;
	  output_list[152] <= 11'h000;
	  output_list[153] <= 11'h000;
	  output_list[154] <= 11'h000;
	  output_list[155] <= 11'h000;
	  output_list[156] <= 11'h000;
	  output_list[157] <= 11'h000;
	  output_list[158] <= 11'h000;
	  output_list[159] <= 11'h000;
	  output_list[160] <= 11'h000;
	  output_list[161] <= 11'h000;
	  output_list[162] <= 11'h000;
	  output_list[163] <= 11'h000;
	  output_list[164] <= 11'h000;
	  output_list[165] <= 11'h000;
	  output_list[166] <= 11'h000;
	  output_list[167] <= 11'h000;
	  output_list[168] <= 11'h000;
	  output_list[169] <= 11'h000;
	  output_list[170] <= 11'h000;
	  output_list[171] <= 11'h000;
	  output_list[172] <= 11'h000;
	  output_list[173] <= 11'h000;
	  output_list[174] <= 11'h000;
	  output_list[175] <= 11'h000;
	  output_list[176] <= 11'h000;
	  output_list[177] <= 11'h000;
	  output_list[178] <= 11'h000;
	  output_list[179] <= 11'h000;
	  output_list[180] <= 11'h000;
	  output_list[181] <= 11'h000;
	  output_list[182] <= 11'h000;
	  output_list[183] <= 11'h000;
	  output_list[184] <= 11'h000;
	  output_list[185] <= 11'h000;
	  output_list[186] <= 11'h000;
	  output_list[187] <= 11'h000;
	  output_list[188] <= 11'h000;
	  output_list[189] <= 11'h000;
	  output_list[190] <= 11'h000;
	  output_list[191] <= 11'h000;

	  // output list 4
	  output_list[192] <= 11'h7fc;
	  output_list[193] <= 11'h00e;
	  output_list[194] <= 11'h005;
	  output_list[195] <= 11'h005;
	  output_list[196] <= 11'h7ff;
	  output_list[197] <= 11'h002;
	  output_list[198] <= 11'h001;
	  output_list[199] <= 11'h003;
	  output_list[200] <= 11'h7fb;
	  output_list[201] <= 11'h001;
	  output_list[202] <= 11'h000;
	  output_list[203] <= 11'h000;
	  output_list[204] <= 11'h7fe;
	  output_list[205] <= 11'h7fb;
	  output_list[206] <= 11'h7ff;
	  output_list[207] <= 11'h7ff;
	  output_list[208] <= 11'h002;
	  output_list[209] <= 11'h002;
	  output_list[210] <= 11'h000;
	  output_list[211] <= 11'h7ff;
	  output_list[212] <= 11'h000;
	  output_list[213] <= 11'h000;
	  output_list[214] <= 11'h000;
	  output_list[215] <= 11'h000;
	  output_list[216] <= 11'h000;
	  output_list[217] <= 11'h000;
	  output_list[218] <= 11'h000;
	  output_list[219] <= 11'h001;
	  output_list[220] <= 11'h000;
	  output_list[221] <= 11'h7ff;
	  output_list[222] <= 11'h000;
	  output_list[223] <= 11'h000;
	  output_list[224] <= 11'h000;
	  output_list[225] <= 11'h000;
	  output_list[226] <= 11'h000;
	  output_list[227] <= 11'h000;
	  output_list[228] <= 11'h000;
	  output_list[229] <= 11'h000;
	  output_list[230] <= 11'h000;
	  output_list[231] <= 11'h000;
	  output_list[232] <= 11'h000;
	  output_list[233] <= 11'h000;
	  output_list[234] <= 11'h000;
	  output_list[235] <= 11'h000;
	  output_list[236] <= 11'h000;
	  output_list[237] <= 11'h000;
	  output_list[238] <= 11'h000;
	  output_list[239] <= 11'h000;
	  output_list[240] <= 11'h000;
	  output_list[241] <= 11'h000;
	  output_list[242] <= 11'h000;
	  output_list[243] <= 11'h000;
	  output_list[244] <= 11'h000;
	  output_list[245] <= 11'h000;
	  output_list[246] <= 11'h000;
	  output_list[247] <= 11'h000;
	  output_list[248] <= 11'h000;
	  output_list[249] <= 11'h000;
	  output_list[250] <= 11'h000;
	  output_list[251] <= 11'h000;
	  output_list[252] <= 11'h000;
	  output_list[253] <= 11'h000;
	  output_list[254] <= 11'h000;
	  output_list[255] <= 11'h000;

	  //
	  // checker body
	  //

	  list_cnt = (output_lists_start -1) * 64;

	  // wait for 'rst' signal to negate
	  while (rst !== 1'b1) #1;

	  $display("*");
	  $display("* Verifying FDCT & Quantization/rounding unit");
	  $display("*");

	  err_cnt = 0;
	  for(n=output_lists_start; n <= output_lists_end; n = n +1)
	  begin
	      $display("\n* verifying input-list %d", n);

	      // wait for 'den' signal
	      while (!go) @(posedge clk);

	      for(y=0; y<=7; y=y+1)
	         for(x=0; x<=7; x=x+1)
	            begin
	                if (din !== output_list[list_cnt])
	                   begin
	                       $display("Data compare error, received %h, expected %h. %d",
	                                 din, output_list[list_cnt], y*8 +x);

	                       err_cnt = err_cnt +1;
	                   end

	                list_cnt = list_cnt +1;

	                @(posedge clk);
	            end
	  end

	  repeat(150) @(posedge clk);

	  $display("\nTotal errors: %d", err_cnt);
	  $stop;
	end
endmodule


