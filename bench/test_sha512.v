/////////////////////////////////////////////////////////////////////
////                                                             ////
////  SHA-512/384                                                ////
////  Secure Hash Algorithm (SHA-512/384)   testbench            ////
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

`define SHA384_TEST		"abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu"
`define SHA384_TEST_PADDING	{1'b1,127'b0,896'b0,128'd896}	// 896 bit
`define SHA384_TEST_RESULT	384'h09330c33_f71147e8_3d192fc7_82cd1b47_53111b17_3b3b05d2_2fa08086_e3b0f712_fcc7c71a_557e2db9_66c3e9fa_91746039

`define SHA512_TEST		"abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu"
`define SHA512_TEST_PADDING	{1'b1,127'b0,896'b0,128'd896}	// 896 bit
`define SHA512_TEST_RESULT	512'h8e959b75_dae313da_8cf4f728_14fc143f_8f7779c6_eb9f7fa1_7299aead_b6889018_501d289e_4900f7e4_331b99de_c4b5433a_c7d329ee_b6dd2654_5e96e55b_874be909


module test_sha;

reg clk,rst,cmd_w_i;
reg [31:0] text_i;

reg [3:0] cmd_i;

wire [31:0] text_o;
wire [4:0] cmd_o;

initial
begin
//	$sdf_annotate("syn/data/sha512.sdf",sha_core);

	clk = 1'b0;
	rst = 1'b0;
	cmd_w_i = 1'b0;
	cmd_i = 4'b0;
	
	#21;
	rst = 1'b1;
	#17;
	rst = 1'b0;
	
	test_SHA384;
	test_SHA512;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	
	$finish;
end


always #5 clk = ~clk;

sha512 sha_core(
	.clk_i(clk),
	.rst_i(rst),
	.text_i(text_i),
	.text_o(text_o),
	.cmd_i(cmd_i),
	.cmd_w_i(cmd_w_i),
	.cmd_o(cmd_o)
	);

task test_SHA384;
integer i;
reg [2047:0] all_message;
reg [1023:0] tmp_i;
reg [383:0] tmp_o;
reg [31:0] tmp;
begin
	all_message = {`SHA384_TEST,`SHA384_TEST_PADDING};
	tmp_i = all_message[2047:1024];
	tmp_o = `SHA384_TEST_RESULT;
	
	#100;
	
	
	@(posedge clk);
	cmd_i = 4'b0010;
	cmd_w_i = 1'b1;
	
	for (i=0;i<32;i=i+1)
	begin
		@(posedge clk);
		cmd_w_i = 1'b0;
		text_i = tmp_i[32*32-1:31*32];
		tmp_i = tmp_i << 32;
	end

	
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);

	while (cmd_o[4])
		@(posedge clk);
	
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	
	#100;
	
	
	tmp_i = all_message[1023:0];
	@(posedge clk);
	cmd_i = 4'b0110;
	cmd_w_i = 1'b1;
	
	for (i=0;i<32;i=i+1)
	begin
		@(posedge clk);
		cmd_w_i = 1'b0;
		text_i = tmp_i[32*32-1:31*32];
		tmp_i = tmp_i << 32;
	end

	
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);

	while (cmd_o[4])
		@(posedge clk);
	
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);

	cmd_i = 4'b0001;
	cmd_w_i = 1'b1;
	
	@(posedge clk);
	cmd_w_i = 1'b0;
	for (i=0;i<12;i=i+1)
	begin
		@(posedge clk);
		#1;
		tmp = tmp_o[12*32-1:11*32];
		if (text_o !== tmp | (|text_o)===1'bx)
		begin
			$display("ERROR(SHA-384-%02d) Expected %x, Got %x", i,tmp, text_o);
		end
		else
		begin
			$display("OK(SHA-384-%02d),Expected %x, Got %x", i,tmp, text_o);
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

task test_SHA512;
integer i;
reg [2047:0] all_message;
reg [1023:0] tmp_i;
reg [511:0] tmp_o;
reg [31:0] tmp;
begin
	all_message = {`SHA512_TEST,`SHA512_TEST_PADDING};
	tmp_i = all_message[2047:1024];
	tmp_o = `SHA512_TEST_RESULT;
	
	#100;
	
	
	@(posedge clk);
	cmd_i = 4'b1010;
	cmd_w_i = 1'b1;
	
	for (i=0;i<32;i=i+1)
	begin
		@(posedge clk);
		cmd_w_i = 1'b0;
		text_i = tmp_i[32*32-1:31*32];
		tmp_i = tmp_i << 32;
	end

	
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);

	while (cmd_o[4])
		@(posedge clk);
	
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	
	#100;
	
	
	tmp_i = all_message[1023:0];
	@(posedge clk);
	cmd_i = 4'b1110;
	cmd_w_i = 1'b1;
	
	for (i=0;i<32;i=i+1)
	begin
		@(posedge clk);
		cmd_w_i = 1'b0;
		text_i = tmp_i[32*32-1:31*32];
		tmp_i = tmp_i << 32;
	end

	
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);

	while (cmd_o[4])
		@(posedge clk);
	
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);

	cmd_i = 4'b1001;
	cmd_w_i = 1'b1;
	
	@(posedge clk);
	cmd_w_i = 1'b0;
	for (i=0;i<16;i=i+1)
	begin
		@(posedge clk);
		#1;
		tmp = tmp_o[16*32-1:15*32];
		if (text_o !== tmp | (|text_o)===1'bx)
		begin
			$display("ERROR(SHA-512-%02d) Expected %x, Got %x", i,tmp, text_o);
		end
		else
		begin
			$display("OK(SHA-512-%02d),Expected %x, Got %x", i,tmp, text_o);
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