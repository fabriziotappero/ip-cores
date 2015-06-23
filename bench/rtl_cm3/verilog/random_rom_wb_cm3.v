///////////////////////////////////////////////
//	Random Instruction Code Generator
//	for Hyper Pipelined OR1200 Core
//	with CMF = 3
///////////////////////////////////////////////


// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module random_rom_wb_cm3 ( dat_o, adr_i, sel_i, cyc_i, stb_i, ack_o, clk_i, cmls, rst_i, core_off );

parameter adr_width = 26;


///////////////////////////////
//	IO signals

output [31:0]        	dat_o;	// wishbone signals
input [adr_width-1:2] 	adr_i;
input [3:0] 		sel_i;
input 		 	cyc_i;
input 		 	stb_i;
output 		 	ack_o;

input 		 	clk_i;	// clock
input [1:0]		 	cmls;		// core multiplier level selector
input 		 	rst_i;	// async reset
input	[2:0]			core_off;	// turn off second core


///////////////////////////////
//	internal signals

integer rand;
wire [adr_width-1:2] memBorder [2:0];
assign memBorder[0] = 24'h000500; //afe;
assign memBorder[1] = 24'h000800; //7fe;
assign memBorder[2] = 24'h000b00; //4fe;

///////////////////////////////
//	pipelined signals

reg [2:0] 	lastSet;		// indicates if flag is set
reg [2:0] 	ack;
reg [31:0] 	dat [2:0];

///////////////////////////////
//	assign outputs

assign	ack_o = ack[cmls];
assign	dat_o = dat[cmls];

///////////////////////////////
//	save adr for debugging

reg [adr_width-1:2] 	adr [2:0];
always @ (posedge clk_i) begin
	if (core_off[cmls] == 1)
		adr[cmls] <= 24'hXXXXXX; //000000;
	else
		adr[cmls] <= adr_i;
end

///////////////////////////////
//	random code generator

always @ (posedge clk_i or posedge rst_i)
if (rst_i) begin
	dat[0] <= 32'h0;
	dat[1] <= 32'h0;
	dat[2] <= 32'h0;
	lastSet <= 3'b000;
	ack <= 3'b000;
end else
if (!ack_o) 
begin
	if (cyc_i & stb_i) begin
		ack[cmls] <= 1'b1;
		//////////////////////////////////////////////////////////////
		//	branch forward by 0000010
		//////////////////////////////////////////////////////////////
		if (	(adr_i < memBorder[cmls] - 50) 	&
			(lastSet[cmls]) 			) begin
			rand = ($random() * $random()) % 2;
			if (rand < 0)
				rand = rand * -1;
			if (rand == 0) begin
		            dat[cmls][31:26] <= 6'h04;
				dat[cmls][25:0] <= 26'h0000020;		//	l.bf
				$display("l.bf @%x ", adr_i);
			end 
			else if (rand == 1) begin
		            dat[cmls][31:26] <= 6'h03;
				dat[cmls][25:0] <= 26'h0000020;		//	l.bnf
				$display("l.bnf @%x ", adr_i);
			end 
			lastSet[cmls] <= 1'b0;
		end 
		//////////////////////////////////////////////////////////////
		//	generate random instruction code
		//////////////////////////////////////////////////////////////
		else begin
			if (adr_i < memBorder[cmls] - 50) 
				rand = ($random() * $random()) % 51;
			else
				rand = ($random() * $random()) % 31;
			if (rand < 0)
				rand = rand * -1;
			if (rand == 0) begin
		            dat[cmls][31:26] <= 6'h38;
				dat[cmls][25:11] <= $random();
				dat[cmls][10:0] <= 11'h000;		//	l.add		=0x38h ..0.. 0
				$display("l.add @%x ", adr_i);
			end 
			else if (rand == 1) begin
		            dat[cmls][31:26] <= 6'h38;
				dat[cmls][25:11] <= $random();
				dat[cmls][10:0] <= 11'h001;		//	l.addc	=0x38h ..0.. 1
				$display("l.addc @%x ", adr_i);
			end 
			else if (rand == 2) begin
		            dat[cmls][31:26] <= 6'h27;		//	l.addi	=0x27h
				dat[cmls][25:0] <= $random();
				$display("l.addi @%x ", adr_i);
			end
			else if (rand == 3) begin
		            dat[cmls][31:26] <= 6'h28;		//	l.addic	=0x28h
				dat[cmls][25:0] <= $random();
				$display("l.addic @%x ", adr_i);
			end
			else if (rand == 4) begin
		            dat[cmls][31:26] <= 6'h38;
				dat[cmls][25:11] <= $random();
				dat[cmls][10:0] <= 11'h003;		//	l.and		=0x38h ..0.. 3
				$display("l.and @%x ", adr_i);
			end 
			else if (rand == 5) begin
		            dat[cmls][31:26] <= 6'h29;		//	l.andi	=0x29h
				dat[cmls][25:0] <= $random();
				$display("l.andi @%x ", adr_i);
			end
										//	l.bf
										//	l.buf
			else if (rand == 6) begin
		            dat[cmls][31:26] <= 6'h38;		//	l.cmov
				dat[cmls][25:21] <= $random();
				dat[cmls][20:16] <= $random();
				dat[cmls][15:11] <= $random();
				dat[cmls][10:0] <= 11'h00e;
				$display("l.cmov @%x ", adr_i);
			end
										//	l.div
										//	l.divu
										//	l.ext...
			else if (rand == 7) begin
		            dat[cmls][31:26] <= 6'h38;		//	l.ff1
				dat[cmls][25:21] <= $random();
				dat[cmls][20:16] <= $random();
				dat[cmls][15:11] <= $random();
				dat[cmls][10:0] <= 11'h00f;
				$display("l.ff1 @%x ", adr_i);
			end
			else if (rand == 8) begin
		            dat[cmls][31:26] <= 6'h38;		//	l.fl1
				dat[cmls][25:21] <= $random();
				dat[cmls][20:16] <= $random();
				dat[cmls][15:11] <= $random();
				dat[cmls][10:0] <= 11'h10f;
				$display("l.fl1 @%x ", adr_i);
			end
										//	l.trap
										//	l.j
										//	l.jal
										//	l.jalr
										//	l.jr
										//	l.lbs
										//	l.lbz
										//	l.lhs
										//	l.lhz
										//	l.lws
										//	l.lwz
			else if (rand == 9) begin
		            dat[cmls][31:26] <= 6'h31;		//	l.mac
				dat[cmls][25:21] <= 5'h00;
				dat[cmls][20:16] <= $random();
				dat[cmls][15:11] <= $random();
				dat[cmls][10:0] <= 11'h001;
				$display("l.mac @%x ", adr_i);
			end
			else if (rand == 10) begin
		            dat[cmls][31:26] <= 6'h13;		//	l.maci
				dat[cmls][25:21] <= $random();
				dat[cmls][20:16] <= 5'h00;
				dat[cmls][15:11] <= $random();
				dat[cmls][10:0] <= 11'h001;
				$display("l.maci @%x ", adr_i);
			end
			else if (rand == 11) begin
		            dat[cmls][31:26] <= 6'h06;		//	l.macrc
				dat[cmls][25:21] <= $random();
				dat[cmls][20:0] <= 21'h010000;
				$display("l.macrc @%x ", adr_i);
			end
										//	l.mfspr
			else if (rand == 12) begin
		            dat[cmls][31:26] <= 6'h06;		//	l.movhi	=0x6h
				dat[cmls][25:21] <= $random();
				dat[cmls][20:16] <= 5'h00;
				dat[cmls][15:0] <= $random();
				$display("l.movhi @%x ", adr_i);
			end
			else if (rand == 13) begin
		            dat[cmls][31:26] <= 6'h31;
				dat[cmls][25:21] <= 5'h00;
				dat[cmls][20:11] <= $random();
				dat[cmls][10:0] <= 11'h002;		//	l.msb		=0x38h ..3.. 6
				$display("l.msb @%x ", adr_i);
			end 
										//	l.mtspr
			else if (rand == 14) begin
		            dat[cmls][31:26] <= 6'h38;
				dat[cmls][25:11] <= $random();
				dat[cmls][10:0] <= 11'h306;		//	l.mul		=0x38h ..3.. 6
				$display("l.mul @%x ", adr_i);
			end 
			else if (rand == 15) begin
		            dat[cmls][31:26] <= 6'h2c;		//	l.muli	=0x2ch
				dat[cmls][25:0] <= $random();
				$display("l.muli @%x ", adr_i);
			end
			else if (rand == 16) begin
		            dat[cmls][31:26] <= 6'h38;
				dat[cmls][25:11] <= $random();
				dat[cmls][10:0] <= 11'h30b;		//	l.mulu	=0x38h ..3.. b
				$display("l.add @%x ", adr_i);
			end 
		//	else if (rand == 8) begin
		//		dat[cmls][31:26] <= 6'h15;		//	l.nop		=0x15h
		//		dat[cmls][25:0] <= 26'h000_0000;
		//	end
			else if (rand == 17) begin
		            dat[cmls][31:26] <= 6'h38;
				dat[cmls][25:11] <= $random();
				dat[cmls][10:0] <= 11'h004;		//	l.or		=0x38h ..0.. 4
				$display("l.or @%x ", adr_i);
			end 
			else if (rand == 18) begin
		            dat[cmls][31:26] <= 6'h38;
				dat[cmls][25:11] <= $random();
				dat[cmls][10:0] <= 11'h004;		//	l.or		=0x38h ..0.. 4
				$display("l.or @%x ", adr_i);
			end 
			else if (rand == 19) begin
		            dat[cmls][31:26] <= 6'h2a;		//	l.ori		=0x2ah
				dat[cmls][25:0] <= 26'h000_0000;
				$display("l.ori @%x ", adr_i);
			end
									//	l.rfe
			else if (rand == 20) begin
		            dat[cmls][31:26] <= 6'h38;
				dat[cmls][25:11] <= $random();
				dat[cmls][10:0] <= 11'h0c8;		//	l.ror	
				$display("l.ror @%x ", adr_i);
			end 
			else if (rand == 21) begin
		            dat[cmls][31:26] <= 6'h2e;
				dat[cmls][25:16] <= $random();
				dat[cmls][15:6] <= 10'h003;		//	l.rori	=0x2eh ..3.. 
				dat[cmls][5:0] <= $random();
				$display("l.rori @%x ", adr_i);
			end 
										//	l.sb
										//	l.sd
										//	l.sh
			else if (rand == 22) begin
		            dat[cmls][31:26] <= 6'h38;
				dat[cmls][25:11] <= $random();
				dat[cmls][10:0] <= 11'h008;		//	l.sll		=0x38h ..0.. 8
				$display("l.sll @%x ", adr_i);
			end 
			else if (rand == 23) begin
		            dat[cmls][31:26] <= 6'h2e;
				dat[cmls][25:8] <= $random();
				dat[cmls][7:6] <= 2'h0;			//	l.slli	=0x2eh ..0.. 
				dat[cmls][5:0] <= $random();
				$display("l.slli @%x ", adr_i);
			end 
			else if (rand == 24) begin
		            dat[cmls][31:26] <= 6'h38;
				dat[cmls][25:11] <= $random();
				dat[cmls][10:0] <= 11'h088;		//	l.sra		=0x38h ..2. 8
				$display("l.sra @%x ", adr_i);
			end
 			else if (rand == 25) begin
		            dat[cmls][31:26] <= 6'h2e;
				dat[cmls][25:8] <= $random();
				dat[cmls][7:6] <= 2'h2;			//	l.srai	=0x2eh ..2.. 
				dat[cmls][5:0] <= $random();
				$display("l.srai @%x ", adr_i);
			end 
			else if (rand == 26) begin
		            dat[cmls][31:26] <= 6'h38;
				dat[cmls][25:11] <= $random();
				dat[cmls][10:0] <= 11'h048;		//	l.srl		=0x38h ..1.. 8
				$display("l.srl @%x ", adr_i);
			end 
			else if (rand == 27) begin
		            dat[cmls][31:26] <= 6'h2e;
				dat[cmls][25:8] <= $random();
				dat[cmls][7:6] <= 2'h1;			//	l.srli	=0x2eh ..1.. 
				dat[cmls][5:0] <= $random();
				$display("l.srli @%x ", adr_i);
			end 
			else if (rand == 28) begin
		            dat[cmls][31:26] <= 6'h38;
				dat[cmls][25:11] <= $random();
				dat[cmls][10:0] <= 11'h002;		//	l.sub		=0x38h ..0.. 2
				$display("l.sub @%x ", adr_i);
			end 
										//	l.sw
										//	l.sys
			else if (rand == 29) begin
		            dat[cmls][31:26] <= 6'h38;
				dat[cmls][25:11] <= $random();
				dat[cmls][10:0] <= 11'h005;		//	l.xor		=0x38h ..0.. 5
				$display("l.xor @%x ", adr_i);
			end 
			else if (rand == 30) begin
		            dat[cmls][31:26] <= 6'h2b;		//	l.xori	=0x2bh
				dat[cmls][25:0] <= 26'h000_0000;
				$display("l.xori @%x ", adr_i);
			end
			/////////////////////////
			//	Set Flag Section
			/////////////////////////
										//	l.sfeq
			else if (rand == 31) begin
		            dat[cmls][31:21] <= 11'h720;
				dat[cmls][20:11] <= $random();
				dat[cmls][10:0] <= 11'h000;
				$display("l.sfeq @%x ", adr_i);
				lastSet[cmls] <= 1'b1;
			end 

										//	l.sfeqi
			else if (rand == 32) begin
		            dat[cmls][31:21] <= 11'h5e0;
				dat[cmls][20:0] <= $random();
				$display("l.sfeqi @%x ", adr_i);
				lastSet[cmls] <= 1'b1;
			end 
										//	l.sfges
			else if (rand == 33) begin
		            dat[cmls][31:21] <= 11'h72b;
				dat[cmls][20:11] <= $random();
				dat[cmls][10:0] <= 11'h000;
				$display("l.sfges @%x ", adr_i);
				lastSet[cmls] <= 1'b1;
			end 
										//	l.sfgesi
			else if (rand == 34) begin
		            dat[cmls][31:21] <= 11'h5eb;
				dat[cmls][20:0] <= $random();
				$display("l.sfgesi @%x ", adr_i);
				lastSet[cmls] <= 1'b1;
			end 
										//	l.sfgeu
			else if (rand == 35) begin
		            dat[cmls][31:21] <= 11'h723;
				dat[cmls][20:11] <= $random();
				dat[cmls][10:0] <= 11'h000;
				$display("l.sfgeu @%x ", adr_i);
				lastSet[cmls] <= 1'b1;
			end 
										//	l.sfgeui
			else if (rand == 36) begin
		            dat[cmls][31:21] <= 11'h5e3;
				dat[cmls][20:0] <= $random();
				$display("l.sfgeui @%x ", adr_i);
				lastSet[cmls] <= 1'b1;
			end 
										//	l.sfgts
			else if (rand == 37) begin
		            dat[cmls][31:21] <= 11'h72a;
				dat[cmls][20:11] <= $random();
				dat[cmls][10:0] <= 11'h000;
				$display("l.sfgts @%x ", adr_i);
				lastSet[cmls] <= 1'b1;
			end 
										//	l.sfgtsi
			else if (rand == 38) begin
		            dat[cmls][31:21] <= 11'h5ea;
				dat[cmls][20:0] <= $random();
				$display("l.sfgtsi @%x ", adr_i);
				lastSet[cmls] <= 1'b1;
			end 
										//	l.sfgtu
			else if (rand == 39) begin
		            dat[cmls][31:21] <= 11'h722;
				dat[cmls][20:11] <= $random();
				dat[cmls][10:0] <= 11'h000;
				$display("l.sfgtu @%x ", adr_i);
				lastSet[cmls] <= 1'b1;
			end 
										//	l.sfgtui
			else if (rand == 40) begin
		            dat[cmls][31:21] <= 11'h5e2;
				dat[cmls][20:0] <= $random();
				$display("l.sfgtui @%x ", adr_i);
				lastSet[cmls] <= 1'b1;
			end 
										//	l.sfles
			else if (rand == 41) begin
		            dat[cmls][31:21] <= 11'h72d;
				dat[cmls][20:11] <= $random();
				dat[cmls][10:0] <= 11'h000;
				$display("l.sfles @%x ", adr_i);
				lastSet[cmls] <= 1'b1;
			end 
										//	l.sflesi
			else if (rand == 42) begin
		            dat[cmls][31:21] <= 11'h5ed;
				dat[cmls][20:0] <= $random();
				$display("l.sflesi @%x ", adr_i);
				lastSet[cmls] <= 1'b1;
			end 
										//	l.sfleu
			else if (rand == 43) begin
		            dat[cmls][31:21] <= 11'h725;
				dat[cmls][20:11] <= $random();
				dat[cmls][10:0] <= 11'h000;
				$display("l.sfleu @%x ", adr_i);
				lastSet[cmls] <= 1'b1;
			end 
										//	l.sfleui
			else if (rand == 44) begin
		            dat[cmls][31:21] <= 11'h5e5;
				dat[cmls][20:0] <= $random();
				$display("l.sfleui @%x ", adr_i);
				lastSet[cmls] <= 1'b1;
			end 
										//	l.sflts
			else if (rand == 45) begin
		            dat[cmls][31:21] <= 11'h72c;
				dat[cmls][20:11] <= $random();
				dat[cmls][10:0] <= 11'h000;
				$display("l.sflts @%x ", adr_i);
				lastSet[cmls] <= 1'b1;
			end 
										//	l.sfltsi
			else if (rand == 46) begin
		            dat[cmls][31:21] <= 11'h5ec;
				dat[cmls][20:0] <= $random();
				$display("l.sfltsi @%x ", adr_i);
				lastSet[cmls] <= 1'b1;
			end 
										//	l.sfltu
			else if (rand == 47) begin
		            dat[cmls][31:21] <= 11'h724;
				dat[cmls][20:11] <= $random();
				dat[cmls][10:0] <= 11'h000;
				$display("l.sfltu @%x ", adr_i);
				lastSet[cmls] <= 1'b1;
			end 
										//	l.sfltui
			else if (rand == 48) begin
		            dat[cmls][31:21] <= 11'h5e4;
				dat[cmls][20:0] <= $random();
				$display("l.sfltui @%x ", adr_i);
				lastSet[cmls] <= 1'b1;
			end 
										//	l.sfne
			else if (rand == 49) begin
		            dat[cmls][31:21] <= 11'h721;
				dat[cmls][20:11] <= $random();
				dat[cmls][10:0] <= 11'h000;
				$display("l.sfltu @%x ", adr_i);
				lastSet[cmls] <= 1'b1;
			end 
										//	l.sfnei
			else if (rand == 50) begin
		            dat[cmls][31:21] <= 11'h5e1;
				dat[cmls][20:0] <= $random();
				$display("l.sfnei @%x ", adr_i);
				lastSet[cmls] <= 1'b1;
			end 
		end
		//////////////////////////////////////////////////////////////
		//	if memBorder reached, jmp register r0
		//	finish up pipeline stage
		//////////////////////////////////////////////////////////////
		if (adr_i == memBorder[cmls] - 4) begin
			dat[cmls] <= {6'h15, 5'h00, 5'h00, 16'h0000};	//32'h15000000;	// nop
			$display("@%x %x  c", adr_i, dat[cmls]);
		end
		if (adr_i == memBorder[cmls] - 3) begin
			dat[cmls] <= {6'h15, 5'h00, 5'h00, 16'h0000};	//32'h15000000;	// nop
			$display("@%x %x  c", adr_i, dat[cmls]);
		end
		if (adr_i == memBorder[cmls] - 2) begin
			dat[cmls] <= {6'h11, 26'h0000000};			//jmp register 0
			$display("@%x %x  d", adr_i, dat[cmls]);
		end
		if (adr_i == memBorder[cmls] - 1) begin
			dat[cmls] <= {6'h15, 5'h00, 5'h00, 16'h0000};	//32'h15000000;	// nop
			$display("@%x %x  e", adr_i, dat[cmls]);
		end
		if (adr_i == memBorder[cmls]) begin
			dat[cmls] <= {6'h15, 5'h00, 5'h00, 16'h0000};	//32'h15000000;	// nop
			$display("@%x %x  g", adr_i, dat[cmls]);
		end
		end
end
else
	ack[cmls] <= 1'b0;

         
endmodule
 
	      