/////////////////////////////////////////////////////////////////////
////                                                             ////
////  JPEG Encoder Core - Verilog                                ////
////                                                             ////
////  Author: David Lundgren                                     ////
////          davidklun@gmail.com                                ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2009 David Lundgren                           ////
////                  davidklun@gmail.com                        ////
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


/* This module combines the Y, Cb, and Cr blocks, and the RGB to Y, Cb, and Cr
converter. */

`timescale 1ns / 100ps

module pre_fifo(clk, rst, enable, data_in, cr_JPEG_bitstream, cr_data_ready, 
cr_orc, cb_JPEG_bitstream, cb_data_ready, cb_orc, y_JPEG_bitstream, 
y_data_ready, y_orc, y_eob_output,
y_eob_empty, cb_eob_empty, cr_eob_empty);
input		clk, rst, enable;
input	[23:0]	data_in;
output  [31:0]  cr_JPEG_bitstream;
output		cr_data_ready;
output  [4:0] cr_orc;
output  [31:0]  cb_JPEG_bitstream;
output		cb_data_ready;
output  [4:0] cb_orc;
output  [31:0]  y_JPEG_bitstream;
output		y_data_ready;
output  [4:0] y_orc;
output		y_eob_output; 
output		y_eob_empty, cb_eob_empty, cr_eob_empty;


wire	rgb_enable;
wire	[23:0]	dct_data_in;


	RGB2YCBCR u4(.clk(clk), .rst(rst), .enable(enable), 
	.data_in(data_in), .data_out(dct_data_in), .enable_out(rgb_enable));
	
	crd_q_h u11(.clk(clk), .rst(rst), .enable(rgb_enable), .data_in(dct_data_in[23:16]),
	.JPEG_bitstream(cr_JPEG_bitstream), 
 	 .data_ready(cr_data_ready), .cr_orc(cr_orc),
 	 .end_of_block_empty(cr_eob_empty)); 
	
	cbd_q_h u12(.clk(clk), .rst(rst), .enable(rgb_enable), .data_in(dct_data_in[15:8]),
	.JPEG_bitstream(cb_JPEG_bitstream), 
 	 .data_ready(cb_data_ready), .cb_orc(cb_orc),
 	 .end_of_block_empty(cb_eob_empty)); 
 
  	yd_q_h u13(.clk(clk), .rst(rst), .enable(rgb_enable), .data_in(dct_data_in[7:0]),
	.JPEG_bitstream(y_JPEG_bitstream), 
 	 .data_ready(y_data_ready), .y_orc(y_orc),
 	 .end_of_block_output(y_eob_output), .end_of_block_empty(y_eob_empty)); 
  
	endmodule
