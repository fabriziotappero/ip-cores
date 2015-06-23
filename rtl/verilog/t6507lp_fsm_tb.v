////////////////////////////////////////////////////////////////////////////
////									////
//// T6507LP IP Core	 						////
////									////
//// This file is part of the T6507LP project				////
//// http://www.opencores.org/cores/t6507lp/				////
////									////
//// Description							////
//// 6507 FSM testbench							////
////									////
//// Author(s):								////
//// - Gabriel Oshiro Zardo, gabrieloshiro@gmail.com			////
//// - Samuel Nascimento Pagliarini (creep), snpagliarini@gmail.com	////
////									////
////////////////////////////////////////////////////////////////////////////
////									////
//// Copyright (C) 2001 Authors and OPENCORES.ORG			////
////									////
//// This source file may be used and distributed without		////
//// restriction provided that this copyright statement is not		////
//// removed from the file and that any derivative work contains	////
//// the original copyright notice and the associated disclaimer.	////
////									////
//// This source file is free software; you can redistribute it		////
//// and/or modify it under the terms of the GNU Lesser General		////
//// Public License as published by the Free Software Foundation;	////
//// either version 2.1 of the License, or (at your option) any		////
//// later version.							////
////									////
//// This source is distributed in the hope that it will be		////
//// useful, but WITHOUT ANY WARRANTY; without even the implied		////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR		////
//// PURPOSE. See the GNU Lesser General Public License for more	////
//// details.								////
////									////
//// You should have received a copy of the GNU Lesser General		////
//// Public License along with this source; if not, download it		////
//// from http://www.opencores.org/lgpl.shtml				////
////									////
////////////////////////////////////////////////////////////////////////////

`include "timescale.v"

module t6507lp_fsm_tb();
	// mem_rw signals
	localparam MEM_READ = 1'b0;
	localparam MEM_WRITE = 1'b1;

	reg clk; // regs are inputs
	reg reset_n;
	reg [7:0] alu_result;
	reg [7:0] alu_status;
	reg [7:0] data_in;
	reg [7:0] alu_x;
	reg [7:0] alu_y;
	wire [12:0] address; // wires are outputs
	wire mem_rw; 
	wire [7:0] data_out;
	wire [7:0] alu_opcode;
	wire [7:0] alu_a;
	wire alu_enable;

	integer my_i;

	`include "t6507lp_package.v"

	t6507lp_fsm #(8,13) t6507lp_fsm(
		.clk(clk),
		.reset_n(reset_n),
		.alu_result(alu_result),
		.alu_status(alu_status),
		.data_in(data_in),
		.alu_x(alu_x),
		.alu_y(alu_y),
		.address(address),
		.mem_rw(mem_rw),
		.data_out(data_out),
		.alu_opcode(alu_opcode),
		.alu_a(alu_a),
		.alu_enable(alu_enable)
	);

	always #10 clk = ~clk;

	reg[7:0] fake_mem[2**13-1:0];

	initial begin
		clk = 1'b0;
		reset_n = 1'b0;
		alu_result = 8'h01;
		alu_status = 8'h00;
		alu_x = 8'h07;
		alu_y = 8'h03;
		
		for (my_i=0; my_i < 2**13; my_i= my_i+1) begin
			$write("\n%d",my_i);
			fake_mem[my_i]=8'h00;
		end

		fake_mem[0] = STA_IDY; // testing IDY mode WRITE TYPE, page crossed;
		fake_mem[1] = 8'h00;  
		fake_mem[2] = STA_IDY; // testing IDY mode WRITE TYPE, page not crossed;
		fake_mem[3] = 8'h04; 
		fake_mem[4] = 8'hFF; 


		/*fake_mem[0] = ASL_ACC; // testing ACC mode
		fake_mem[1] = ADC_IMM; // testing IMM mode
		fake_mem[2] = 8'h27;
		fake_mem[3] = JMP_ABS; // testing ABS mode, JMP type
		fake_mem[4] = 8'h09;*/
		fake_mem[5] = 8'h00;
		fake_mem[6] = ASL_ACC; // wont be executed
		fake_mem[7] = ASL_ACC; // wont be executed
		fake_mem[8] = ASL_ACC; // wont be executed
		fake_mem[9] = ASL_ACC; // wont be executed
		fake_mem[10] = LDA_ABS; // testing ABS mode, READ type. A = MEM[0002]. (a=27)
		fake_mem[11] = 8'h02;
		fake_mem[12] = 8'h00;
		fake_mem[13] = ASL_ABS; // testing ABS mode, READ_MODIFY_WRITE type. should overwrite the first ASL_ACC
		fake_mem[14] = 8'h00;
		fake_mem[15] = 8'h00;
		fake_mem[16] = STA_ABS; // testing ABS mode, WRITE type. should write alu_result on MEM[1]
		fake_mem[17] = 8'h01;
		fake_mem[18] = 8'h00;
		fake_mem[19] = LDA_ZPG; // testing ZPG mode, READ type
		fake_mem[20] = 8'h00;
		fake_mem[21] = ASL_ZPG; // testing ZPG mode, READ_MODIFY_WRITE type
		fake_mem[22] = 8'h00;
		fake_mem[23] = STA_ZPG; // testing ZPG mode, WRITE type
		fake_mem[24] = 8'h00;
		fake_mem[25] = LDA_ZPX; // testing ZPX mode, READ type. A = MEM[x+1]
		fake_mem[26] = 8'h01;
		fake_mem[27] = ASL_ZPX; // testing ZPX mode, READ_MODIFY_WRITE type. MEM[x+1] = MEM[x+1] << 1;
		fake_mem[28] = 8'h01;
		fake_mem[29] = STA_ZPX; // testing ZPX mode, WRITE type. MEM[x+2] = A;
		fake_mem[30] = 8'h02;
		fake_mem[31] = LDA_ABX; // testing ABX mode, READ TYPE. No page crossed.
		fake_mem[32] = 8'h0a;
		fake_mem[33] = 8'h00;
		fake_mem[34] = LDA_ABX; // testing ABX mode, READ TYPE. Page crossed.
		fake_mem[35] = 8'hff;
		fake_mem[36] = 8'h00;
		fake_mem[37] = ASL_ABX; // testing ABX mode, READ_MODIFY_WRITE TYPE. No page crossed.
		fake_mem[38] = 8'h01;
		fake_mem[39] = 8'd35;
		fake_mem[40] = ASL_ABX; // testing ABX mode, READ_MODIFY_WRITE TYPE. Page crossed.
		fake_mem[41] = 8'hff;
		fake_mem[42] = 8'h00;
		fake_mem[40] = STA_ABX; // testing ABX mode, WRITE TYPE. No page crossed.
		fake_mem[41] = 8'h04;
		fake_mem[42] = 8'h00;
		fake_mem[43] = STA_ABX; // testing ABX mode, WRITE TYPE. Page crossed.
		fake_mem[44] = 8'hff;
		fake_mem[45] = 8'h00;
		fake_mem[46] = BNE_REL; // testing REL mode, taking a branch, no page crossed.
		fake_mem[47] = 8'h0a;
		fake_mem[58] = BNE_REL; // testing REL mode, taking a branch, page crossed.
		fake_mem[59] = 8'hff;
		fake_mem[60] = 8'hff;
		fake_mem[254] = 8'hff;
		fake_mem[256] = 8'h55; // PCL fetched from here when executing RTS_IMP
		fake_mem[257] = 8'h01;    // PCH fetched from here when executing RTS_IMP
		fake_mem[264] = 8'd340;
		fake_mem[315] = BEQ_REL; // testing REL mode, not taking a branch, page would have crossed.
		fake_mem[316] = 8'hff;
		fake_mem[317] = BEQ_REL; // testing REL mode, not taking a branch, page would not have crossed.
		fake_mem[318] = 8'h00;
		fake_mem[319] = LDA_IDX; // testing IDX mode READ TYPE, no page crossed;
		fake_mem[320] = 8'h0a;	
		fake_mem[321] = LDA_IDX; // testing IDX mode READ TYPE, page crossed; this will actually do A = MEM[6] because there is no carry
		fake_mem[322] = 8'hff;
		//fake_mem[319] = SLO_IDX; // testing IDX mode READ_MODIFY_WRITE TYPE
		//fake_mem[320] = 8'h0a;   // all of read modify write instructions are not documented therefore will not be simulated
		fake_mem[323] = STA_IDX; // testing IDX mode WRITE TYPE, page crossed being ignored
		fake_mem[324] = 8'hff;		
		fake_mem[325] = STA_IDX; // testing IDX mode WRITE TYPE, page not crossed;
		fake_mem[326] = 8'h00;		
		fake_mem[327] = LDA_IDY; // testing IDY mode READ TYPE, page not crossed;
		fake_mem[328] = 8'h00;	
		fake_mem[329] = LDA_IDY; // testing IDY mode READ TYPE, page not crossed but pointer overflowed.
		fake_mem[330] = 8'hff;	
		/* testing IDY mode READ TYPE, page crossed.
		   address may assume a invalid value when page is crossed but it is fixed on the next cycle when the true read occurs.
		   this is probably not an issue */
		fake_mem[331] = LDA_IDY;
		fake_mem[332] = 8'hfe;
		fake_mem[333] = STA_IDY; // testing IDY mode WRITE TYPE, page crossed;
		fake_mem[334] = 8'h00;  
		fake_mem[335] = STA_IDY; // testing IDY mode WRITE TYPE, page not crossed;
		fake_mem[336] = 8'h0e;  
		fake_mem[337] = INX_IMP;  
		//fake_mem[338] = JMP_IND; // testing absolute indirect addressing. page crossed when updating pointer.
		//fake_mem[339] = 8'hff; 
		//fake_mem[340] = 8'h00; 
		//fake_mem[337] = JMP_IND; // testing absolute indirect addressing. no page crossed when updating pointer.
		//fake_mem[338] = 8'h3b;   // these are commented cause they will actually jump
		//fake_mem[339] = 8'h00;
		//fake_mem[338] = BRK_IMP;
		//fake_mem[339] = RTI_IMP;
		//fake_mem[340] = RTS_IMP;
		// 341 is skipped due to RTS internal functionality
		//fake_mem[342] = PHA_IMP;	
		//fake_mem[343] = PHP_IMP;	
		//fake_mem[344] = PLA_IMP;	
		//fake_mem[345] = PLP_IMP;
		fake_mem[338] = JSR_ABS;
		fake_mem[339] = 8'h01;
		fake_mem[340] = 8'h01;
			


		fake_mem[8190] = 8'h53; // this is the reset vector
		fake_mem[8191] = 8'h01;	
		@(negedge clk) // will wait for next negative edge of the clock (t=20)
		reset_n=1'b1;
	

		#4000;
		$finish; // to shut down the simulation
	end //initial

	always @(clk) begin
		if (mem_rw == MEM_READ) begin // MEM_READ
			data_in <= fake_mem[address];
			$write("\nreading from mem position %h: %h", address, fake_mem[address]);
		end
		else begin // MEM_WRITE
			fake_mem[address] <= data_out;
			$write("\nreading from mem position %h: %h", address, fake_mem[address]);
		end
	end

endmodule
