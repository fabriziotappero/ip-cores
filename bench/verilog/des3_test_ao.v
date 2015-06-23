/////////////////////////////////////////////////////////////////////
////                                                             ////
////  DES TEST BENCH                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Rudolf Usselmann                         ////
////                    rudi@asics.ws                            ////
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

module test;

reg		clk;
reg	[319:0]	x[512:0];

reg	[319:0]	tmp;

reg	[5:0]	cnt;
integer		select;
integer		decrypt;
wire	[63:0]	desOut;
wire	[63:0]	des_in;
wire	[63:0]	exp_out;
wire	[55:0]	key1;
wire	[55:0]	key2;
wire	[55:0]	key3;
integer		ZZZ;

initial
   begin
	$display("\n\n");
	$display("*********************************************************");
	$display("* Area Optimized DES core simulation started ...        *");
	$display("*********************************************************");
	$display("\n");

`ifdef WAVES
  	$shm_open("waves");
	$shm_probe("AS",test,"AS");
	$display("INFO: Signal dump enabled ...\n\n");
`endif

	clk=0;

	ZZZ=0;
	
	//           key1                key2             key3          Test data        Out data
	x[0]=320'h0101010101010101_0101010101010101_0101010101010101_95F8A5E5DD31D900_8000000000000000;
	x[1]=320'h0101010101010101_0101010101010101_0101010101010101_9D64555A9A10B852_0000001000000000;
	x[2]=320'h3849674C2602319E_3849674C2602319E_3849674C2602319E_51454B582DDF440A_7178876E01F19B2A;
	x[3]=320'h04B915BA43FEB5B6_04B915BA43FEB5B6_04B915BA43FEB5B6_42FD443059577FA2_AF37FB421F8C4095;
	x[4]=320'h0123456789ABCDEF_0123456789ABCDEF_0123456789ABCDEF_736F6D6564617461_3D124FE2198BA318;
	x[5]=320'h0123456789ABCDEF_5555555555555555_0123456789ABCDEF_736F6D6564617461_FBABA1FF9D05E9B1;
	x[6]=320'h0123456789ABCDEF_5555555555555555_FEDCBA9876543210_736F6D6564617461_18d748e563620572;
	x[7]=320'h0352020767208217_8602876659082198_64056ABDFEA93457_7371756967676C65_c07d2a0fa566fa30;
	x[8]=320'h0101010101010101_8001010101010101_0101010101010102_0000000000000000_e6e6dd5b7e722974;
	x[9]=320'h1046103489988020_9107D01589190101_19079210981A0101_0000000000000000_e1ef62c332fe825b;

	
	decrypt = 0;
	@(posedge clk);
	
	$display("");
	$display("**************************************");
	$display("* Starting DES Test ...              *");
	$display("**************************************");
	$display("");
	
	for(decrypt=0;decrypt<2;decrypt=decrypt+1)
	begin
	if(decrypt)	$display("Running Encrypt test ...\n");
	else		$display("Running Decrypt test ...\n");

	for(select=0;select<16;select=select+1)
	   begin
	   	tmp=x[select];
		for(cnt=0;cnt<47;cnt=cnt+1)	@(posedge clk);

		#10;
		if((exp_out !== desOut) | (^exp_out===1'bx) | (^desOut===1'bx)) 

			$display("ERROR: (%0d) Expected %x Got %x", select, exp_out, desOut);
		 else
		 	$display("PASS : (%0d) Expected %x Got %x", select, exp_out, desOut);

		//#2 $display("%h %h %h %h %h", key3, key2, key1, des_in, exp_out);
		@(posedge clk);
	   end
	end

	$display("");
	$display("**************************************");
	$display("* DES Test done ...                  *");
	$display("**************************************");
	$display("");

	$finish;
   end // end of innitial

always #100 clk=~clk;

assign #1 key1 =	{tmp[319:313],tmp[311:305],tmp[303:297],tmp[295:289],
			tmp[287:281],tmp[279:273],tmp[271:265],tmp[263:257]};

assign #1 key2 =	{tmp[255:249],tmp[247:241],tmp[239:233],tmp[231:225],
			tmp[223:217],tmp[215:209],tmp[207:201],tmp[199:193]};

assign #1 key3 =	{tmp[191:185],tmp[183:177],tmp[175:169],tmp[167:161],
			tmp[159:153],tmp[151:145],tmp[143:137],tmp[135:129]};


assign #1 des_in = decrypt[0] ? tmp[63:0]   : tmp[127:64];
assign   exp_out = decrypt[0] ? tmp[127:64] : tmp[63:0];

des3 u0( .clk(		clk		),
	.desOut(	desOut		),
	.desIn(		des_in		),
	.key1(		key1		),
	.key2(		key2		),
	.key3(		key3		),
	.roundSel(	cnt		),
	.decrypt(	decrypt[0]		)
	);

endmodule
