/////////////////////////////////////////////////////////////////////
////                                                             ////
////  SHA-160                                                    ////
////  Secure Hash Algorithm (SHA-160)   testbench                ////
////                                                             ////
////  Author: marsgod                                            ////
////          marsgod@opencores.org                              ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/sha_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2002-2004 marsgod                             ////
////                         marsgod@opencores.org               ////
////                                                             ////
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


`timescale 1ns/10ps

`define SHA1_TEST		"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
`define SHA1_TEST_PADDING	{1'b1,63'b0,448'b0,64'd448}	// 448 bit
`define SHA1_TEST_RESULT	160'h84983e44_1c3bd26e_baae4aa1_f95129e5_e54670f1

module test_sha;

reg clk,rst,cmd_w_i;
reg [31:0] text_i;

reg [2:0] cmd_i;

wire [31:0] text_o;
wire [3:0] cmd_o;

initial
begin
//	$sdf_annotate("syn/data/sha1.sdf",sha_core);

	clk = 1'b0;
	rst = 1'b0;
	cmd_w_i = 1'b0;
	cmd_i = 3'b0;
	
	#21;
	rst = 1'b1;
	#17;
	rst = 1'b0;
	
	test_SHA1;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	
	$finish;
end


always #5 clk = ~clk;

sha1 sha_core(
	.clk_i(clk),
	.rst_i(rst),
	.text_i(text_i),
	.text_o(text_o),
	.cmd_i(cmd_i),
	.cmd_w_i(cmd_w_i),
	.cmd_o(cmd_o)
	);

task test_SHA1;
integer i;
reg [1023:0] all_message;
reg [511:0] tmp_i;
reg [159:0] tmp_o;
reg [31:0] tmp;
begin
	all_message = {`SHA1_TEST,`SHA1_TEST_PADDING};
	tmp_i = all_message[1023:512];
	tmp_o = `SHA1_TEST_RESULT;
	
	#100;
	
	
	@(posedge clk);
	cmd_i = 3'b010;
	cmd_w_i = 1'b1;
	
	for (i=0;i<16;i=i+1)
	begin
		@(posedge clk);
		cmd_w_i = 1'b0;
		text_i = tmp_i[16*32-1:15*32];
		tmp_i = tmp_i << 32;
	end

	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);

	while (cmd_o[3])
		@(posedge clk);
	
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	
	#100;
	
	
	tmp_i = all_message[511:0];
	@(posedge clk);
	cmd_i = 3'b110;
	cmd_w_i = 1'b1;
	
	for (i=0;i<16;i=i+1)
	begin
		@(posedge clk);
		cmd_w_i = 1'b0;
		text_i = tmp_i[16*32-1:15*32];
		tmp_i = tmp_i << 32;
	end

	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);

	while (cmd_o[3])
		@(posedge clk);
	
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);

	cmd_i = 6'b001;
	cmd_w_i = 1'b1;
	
	@(posedge clk);
	cmd_w_i = 1'b0;
	for (i=0;i<5;i=i+1)
	begin
		@(posedge clk);
		#1;
		tmp = tmp_o[5*32-1:4*32];
		if (text_o !== tmp | (|text_o)===1'bx)
		begin
			$display("ERROR(SHA-160-%02d) Expected %x, Got %x", i,tmp, text_o);
		end
		else
		begin
			$display("OK(SHA-160-%02d),Expected %x, Got %x", i,tmp, text_o);
		end
		tmp_o = tmp_o << 32;
	end	
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	#100;
end
endtask


endmodule