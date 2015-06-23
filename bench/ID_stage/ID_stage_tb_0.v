/***************************************************
 * Module: ID_stage_tb_0_v
 * Project: mips_16
 * Author: fzy
 * Description: 
 *     
 *
 * Revise history:
 *     
 ***************************************************/
`timescale 1ns/1ps
`include "mips_16_defs.v"

module ID_stage_tb_0_v;
	reg					clk;
	reg					rst;
	reg					instruction_decode_en;
	
	// to EX_stage
	wire	[56:0]		pipeline_reg_out;	//	[56:22],35bits:	ex_alu_cmd[2:0], ex_alu_src1[15:0], ex_alu_src2[15:0]
												//	[21:5],17bits:	mem_write_en, mem_write_data[15:0]
												//	[4:0],5bits:	write_back_en, write_back_dest[2:0], write_back_result_mux, 
	
	// to IF_stage
	reg		[15:0]		instruction;
	wire	[5:0]		branch_offset_imm;
	wire				branch_taken;
	
	// to register file
	wire	[2:0]		reg_read_addr_1;	// register file read port 1 address
	wire	[2:0]		reg_read_addr_2;	// register file read port 2 address
	reg		[15:0]		reg_read_data_1;	// register file read port 1 data
	reg		[15:0]		reg_read_data_2;	// register file read port 2 data
	
	// to hazard detection unit
	wire	[2:0]		decoding_op_src1;		//source_1 register number
	wire	[2:0]		decoding_op_src2;		//source_2 register number
	
	
	
	
	parameter CLK_PERIOD = 10;
	integer test;
	
	ID_stage uut(
		.clk(clk),
		.rst(rst),
		.instruction_decode_en(instruction_decode_en),
		.pipeline_reg_out(pipeline_reg_out),
		.instruction(instruction),
		.branch_offset_imm(branch_offset_imm),
		.branch_taken(branch_taken),
		.reg_read_addr_1(reg_read_addr_1),	//
		.reg_read_addr_2(reg_read_addr_2),	//
		.reg_read_data_1(reg_read_data_1),	//
		.reg_read_data_2(reg_read_data_2),	//
		.decoding_op_src1(decoding_op_src1),		
		.decoding_op_src2(decoding_op_src2)
	);
	
	always #(CLK_PERIOD /2) 
		clk =~clk;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		instruction_decode_en = 0;
		instruction = 0;
		reg_read_data_1 = 0;
		reg_read_data_2 = 0;
		test = 0;
		
		// Wait 100 ns for global reset to finish
		#100;
        display_debug_message;
		#(CLK_PERIOD/2)
		test1;
		
		$stop;
		
		$finish;
		
	end
	
	
	task display_debug_message;
		begin
			$display("\n***************************");
			$display("ID_stage test");
			$display("***************************\n");
		end
	endtask
	
	task sys_reset;
		begin
			rst = 0;
			#(CLK_PERIOD*1) rst = 1;
			#(CLK_PERIOD*1) rst = 0;
		end
	endtask
	
	task test1;
		begin
			
			sys_reset;
			#1
			instruction_decode_en = 1;
			#(CLK_PERIOD) test = 1;
			
			#(CLK_PERIOD*100) test = 0;
			sys_reset;
			
		end
	endtask
	
	// register file behavior
	always@(*) begin
		reg_read_data_1 = 0;
		reg_read_data_2 = 0;
		
		if(reg_read_addr_1 == 1)
			reg_read_data_1 = 31;
		if(reg_read_addr_1 == 5)
			reg_read_data_1 = 7;
		if(reg_read_addr_1 == 7)
			reg_read_data_1 = 0;// ==0, BZ will taken
			// reg_read_data_1 = 3;  // !=0, BZ will not taken
			
		if(reg_read_addr_2 == 2)
			reg_read_data_2 = 28;
		if(reg_read_addr_2 == 4)
			reg_read_data_2 = 16'h9a3c;
		if(reg_read_addr_2 == 6)
			reg_read_data_2 = 16'hc32e;
	end
	
	always @ (test) begin
	    case(test)
			1: begin
			    $display("running test1\n");
				$display("check datapath control logic S1~S6 correct or not\n");
				//while(test == 1) begin
					// NOP
					#(CLK_PERIOD) instruction = { `OP_NOP, 12'b0};
					$display("OP_NOP\n");
					
					// ADD
					#(CLK_PERIOD) instruction = { `OP_ADD, 3'd0, 3'd1, 3'd2, 3'd0};
					$display("OP_ADD\n");
					#(CLK_PERIOD)
					if(
						uut.write_back_en			!= 1		||	// S3
						uut.write_back_result_mux	!= 0		||	// S1
						uut.ex_alu_cmd				!= `ALU_ADD	||	// S2
						uut.alu_src2_mux			!= 0		||	// S4
						uut.decoding_op_is_branch	!= 0		||	// S5
						uut.decoding_op_is_store	!= 0		||	// S6
						decoding_op_src1			!= 1		||
						decoding_op_src2			!= 2		||
						branch_taken				!= 0		||
						branch_offset_imm			!= 6'b010000||
						reg_read_addr_1				!= 1		||
						reg_read_addr_2				!= 2		
					)
						$display("error1\n");
					#(CLK_PERIOD)
					if(
						pipeline_reg_out[56:54]		!= `ALU_ADD	||	// S2 ex_alu_cmd
						pipeline_reg_out[53:38]		!= 31		||	//    alu src1
						pipeline_reg_out[37:22]		!= 28		||	//    alu src2
						pipeline_reg_out[21]		!= 0		||	//    mem_write_en
						pipeline_reg_out[20:5]		!= 28		||	// 	  mem_write_data
						pipeline_reg_out[4]			!= 1		||	// S3 write_back_en
						pipeline_reg_out[3:1]		!= 0		||	//    write_back_dest
						pipeline_reg_out[0]			!= 0			// S1 write_back_result_mux
						
					)
						$display("error2\n");
						
					// ST
					#(CLK_PERIOD) instruction = { `OP_ST, 3'd4, 3'd5, 6'd31};
					$display("OP_ST\n");
					#(CLK_PERIOD)
					if(
						uut.write_back_en			!= 0		||	// S3
						uut.write_back_result_mux	!= 1'bx		||	// S1
						uut.ex_alu_cmd				!= `ALU_ADD	||	// S2
						uut.alu_src2_mux			!= 1		||	// S4
						uut.decoding_op_is_branch	!= 0		||	// S5
						uut.decoding_op_is_store	!= 1		||	// S6
						decoding_op_src1			!= 5		||
						decoding_op_src2			!= 4		||
						branch_taken				!= 0		||
						branch_offset_imm			!= 6'd31	||
						reg_read_addr_1				!= 5		||
						reg_read_addr_2				!= 4		
					)
						$display("error1\n");
					#(CLK_PERIOD)
					if(
						pipeline_reg_out[53:38]		!= 7		||	//    ex_alu_src1
						pipeline_reg_out[37:22]		!= 31		||	//    ex_alu_src2
						pipeline_reg_out[21]		!= 1		||	//    mem_write_en
						pipeline_reg_out[20:5]		!= 16'h9a3c	||	// 	  mem_write_data
						pipeline_reg_out[3:1]		!= 4			//    write_back_dest
					)
						$display("error2\n");
					
					// BZ
					#(CLK_PERIOD) instruction = { `OP_BZ, 3'd0, 3'd7, -6'd10};
					$display("OP_BZ\n");
					#(CLK_PERIOD)
					if(
						uut.write_back_en			!= 0		||	// S3
						uut.write_back_result_mux	!= 1'bx		||	// S1
						uut.ex_alu_cmd				!= `ALU_NC	||	// S2
						uut.alu_src2_mux			!= 1		||	// S4
						uut.decoding_op_is_branch	!= 1		||	// S5
						uut.decoding_op_is_store	!= 0		||	// S6
						decoding_op_src1			!= 7		||
						decoding_op_src2			!= 0		||
						branch_taken				!= 1		||
						// branch_taken				!= 0		||
						branch_offset_imm			!= -6'd10	||
						reg_read_addr_1				!= 7		||
						reg_read_addr_2				!= 3'b110		
					)
						$display("error1\n");
					#(CLK_PERIOD)
					if(
						pipeline_reg_out[53:38]		!= 0		||	//    ex_alu_src1
						// pipeline_reg_out[53:38]		!= 3		||	//    ex_alu_src1
						pipeline_reg_out[37:22]		!= -6'd10	||	//    ex_alu_src2
						pipeline_reg_out[21]		!= 0		||	//    mem_write_en
						pipeline_reg_out[20:5]		!= 16'hc32e	||	// 	  mem_write_data
						pipeline_reg_out[3:1]		!= 0			//    write_back_dest
					)
						$display("error2\n");
					
				//end
			end
			
			
			
		endcase
	end
	

	
endmodule 