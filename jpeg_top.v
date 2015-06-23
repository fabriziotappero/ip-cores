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

/* This is the top level module of the JPEG Encoder Core.
This module takes the output from the fifo_out module and sends it 
to the ff_checker module to check for FF's in the bitstream.  When it finds an
FF, it puts a 00 after it, and then continues with the rest of the bitstream.
At the end of the file, if there is not a full 32 bit set of JPEG data, then the
signal "eof_data_partial_ready" will go high, to indicate there
are less than 32 valid JPEG bits in the bitstream.  The number of valid bits in the
last JPEG_bitstream value is written to the signal "end_of_file_bitstream_count".
*/

`timescale 1ns / 100ps

module jpeg_top(clk, rst, end_of_file_signal, enable, data_in, JPEG_bitstream, 
data_ready, end_of_file_bitstream_count, eof_data_partial_ready);
input		clk;
input		rst;
input		end_of_file_signal;
input		enable;
input	[23:0]	data_in;
output  [31:0]  JPEG_bitstream;
output		data_ready;
output	[4:0] end_of_file_bitstream_count;
output		eof_data_partial_ready;

wire [31:0] JPEG_FF;
wire data_ready_FF;
wire [4:0] orc_reg_in;
 

 fifo_out u19 (.clk(clk), .rst(rst), .enable(enable), .data_in(data_in), 
 .JPEG_bitstream(JPEG_FF), .data_ready(data_ready_FF), .orc_reg(orc_reg_in));
 
 ff_checker u20 (.clk(clk), .rst(rst), 
 .end_of_file_signal(end_of_file_signal), .JPEG_in(JPEG_FF), 
 .data_ready_in(data_ready_FF), .orc_reg_in(orc_reg_in),
 .JPEG_bitstream_1(JPEG_bitstream), 
 .data_ready_1(data_ready), .orc_reg(end_of_file_bitstream_count),
 .eof_data_partial_ready(eof_data_partial_ready));

 endmodule