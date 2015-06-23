/*	MODULE: openfire_debug
	DESCRIPTION: Contains opcode dissasembler and 

AUTHOR: 
Antonio J. Anton
Anro Ingenieros (www.anro-ingenieros.com)
aj@anro-ingenieros.com

REVISION HISTORY:
Revision 1.0, 26/03/2007
Initial release

COPYRIGHT:
Copyright (c) 2007 Antonio J. Anton

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.*/

//synthesis translate_off

// ------------------ opcode disassembler -----------------
// based on the kcpsm3 (picoblaze) dissasembler

`ifdef OPCODE_DISSASEMBLER
reg [31:0]  pc_actual;
reg [31:0]  instruction;			// executing instruction
reg [31:0]  instruction_decode;	
reg [31:0]  instruction_fetch;	// fetched instruction
reg [15:0]	prev_imm;

reg [1:64]	op;
reg [1:32]	arg1;
reg [1:32]	arg2;
reg [1:80]	arg3;

reg			[1:0] rD, rA, rB_IMM;

initial prev_imm = 0;			// initialize IMM opcode

always @(posedge clk)
begin
  if(rst)
  begin
  	 instruction_fetch   = `NoOp;
	 instruction_decode  = `NoOp;
	 instruction		   = `NoOp;
  end
  else if(imem_done)
  begin
    instruction 			= instruction_decode;
	 instruction_decode  = instruction_fetch;
	 instruction_fetch   = CPU.FETCH.idata;
 end
end

always @(posedge clk)
begin
   if(CPU.EXECUTE.instr_complete & !CPU.EXECUTE.stall)
	begin
	  op[1:56]   = "        ";					// initialize dissasembled line
	  arg1[1:32] = "    ";
	  arg2[1:32] = "    ";
	  arg3[1:80] = "          ";
	  rD = 1;										// by default enable all parameters, specific
	  rA = 1;										// opcodes will disable they
	  rB_IMM = 1;
     pc_actual = {{(30 - `A_SPACE) {1'b0}},CPU.EXECUTE.pc_exe};	// executed PC

     casez(`opcode)														// decode opcode
	  	`ADD			: begin
						    	op[1:24] = "add";
						    	if(`IMM_bit) op[25:32] = "i";
						    	if(`K_bit)   op[33:40] = "k";
						    	if(`C_bit)	 op[41:48] = "c";
				        end
      `LOGIC_AND  : begin
								op[1:24] = "and";
								if(`IMM_bit) op[25:32] = "i";
						  end
		`LOGIC_ANDN : begin
								op[1:32] = "andn";
								if(`IMM_bit) op[33:40] = "i";
						  end
      `BRANCH_CON : begin
							rD = 0;
						   case(`branch_compare)
							`CMP_equal 			: op[1:24] = "beq";
							`CMP_not_equal		: op[1:24] = "bne";
							`CMP_lessthan		: op[1:24] = "blt";
							`CMP_lt_equal		: op[1:24] = "ble";
							`CMP_greaterthan	: op[1:24] = "bgt";
							`CMP_gt_equal		: op[1:24] = "bge";
							default: $display("error: invalid conditional branch");
						   endcase
						  if(`IMM_bit) 	op[25:32] = "i";
						  if(`D_bit_cond)	op[33:40] = "d";
						  end
		`BRANCH_UNCON: begin
							 rA = 0;
							 if(`A_bit & `L_bit & ~`D_bit_uncond) 	// bral = break
							 begin
								op[1:32] = "brk";								// rA is 5'b01100 for brk
								if(`IMM_bit) op[33:40] = "i";
						    end
					       else
							 begin			// other unconditional branches
							   op[1:16] = "br";
								if(`A_bit)   op[17:24] = "a";
								if(`IMM_bit) op[25:32] = "i";
								if(`L_bit)   op[33:40] = "l"; else rD = 0;	// rD used if link
								if(`D_bit_uncond)	 op[41:48] = "d";
							 end 
							end
		`BARREL_SHIFT: $display("error: barrel shift not implemented");
		`FSL			 : begin
								if(~`FSL_nblock) 	op[1:8] = "n";
								if(`FSL_control) 	op[9:16] = "c";
								if(`fsl_get_put)  op[17:40] = "put";
								else              op[17:40] = "get";
								rA = 0;
								rB_IMM = 3;
						   end
		`FP_OP		 : $display("error: floating point not implemented");
		`DIVIDE		 : $display("error: divide not implemented");
		`IMMEDIATE	 : begin
								rD = 0;
								rA = 0;
								op[1:24]="imm";
								prev_imm = instruction[15:0];		// store previous immediate
						   end
		`LOAD			 : begin
								op[1:8] = "l";
								case(`word_size)
									2'b00: op[9:24] = "bu";
									2'b01: op[9:24] = "hu";
									2'b10: op[9:16] = "w";
									default:	$display("error: invalid load");
						      endcase
								if(`IMM_bit) op[25:32] = "i";
							end
		`SPECIAL_REG : begin
							  if(`is_mfs)	// mfs rD,rS (rmsr, rpc, etc..)
							  begin
							  	 op[1:24] = "mfs";
								 rA = 0;
								 rB_IMM = 2;
							  end
							  else if(`is_mts)	// mts rS,rD (rS only msr)
							  begin
							  	 op[1:24] = "mts";
								 rD = 2;
								 rB_IMM = 0;
							  end
						   end
		`MULTIPLY	 : begin
								op[1:24] = "mul";
								if(`IMM_bit) op[25:32] = "i";
							end
		`LOGIC_OR	 :	begin
								op[1:16] = "or";
								if(`IMM_bit) op[17:24] = "i";
						  	end
		`PATTERN_CMP : $display("error: pattern compare not implemented");
		`SUBTRACT	 : begin
								if(`CMP_bit)
								begin
								 op[1:24] = "cmp";		// compare
								 if(`U_bit) op[25:32] = "u";
							   end
								else op[1:32] = "rsub";
								if(`IMM_bit) op[33:40] = "i";
								if(`K_bit)	 op[41:48] = "k";
								if(`C_bit)	 op[49:56] = "c";
							end
		`RETURN		 : begin								// default is return from subroutine
								rD = 0;
								op[1:32] = "rtsd";		// rD = 6'b10100,  type B (imm value)
								if(`BRK_bit) op[17:24] = "b";
								else if(`INT_bit) op[17:24] = "i";
								else if(`EXC_bit) op[17:24] = "e";
							end
		`STORE		 : begin
								op[1:8] = "s";
								case(`word_size)
									2'b00: op[9:16] = "b";
									2'b01: op[9:16] = "h";
									2'b10: op[9:16] = "w";
									default:	$display("error: invalid store");
						      endcase
								if(`IMM_bit) op[17:24] = "i";
							end
		`LOGIC_BIT	 : begin							// is only type A: opcode rD,rA,rB
								rB_IMM = 0;
								if(`is_SEXT16)		 op[1:48] = "sext16";
								else if(`is_SEXT8) op[1:40] = "sext8";
								else if(`is_SRA)	 op[1:24] = "sra";
								else if(`is_SRC)	 op[1:24] = "src";
								else if(`is_SRL)	 op[1:24] = "srl";
								else $display("error: invalid logical bit function");
						   end
		`LOGIC_XOR	 :	begin
								op[1:24] = "xor";
								if(`IMM_bit) op[25:32] = "i";
						  	end
		default		 :	$display("error: invalid opcode");
     endcase

	  if(`opcode == `IMMEDIATE)		// IMM opcode only has arg3
	  begin
	  	arg3[1:16] = "0x";
		arg3[17:48] = hex4(prev_imm);				// high 16 bits are prev_imm
	  end
	  else
	  begin
	     if(`IMM_bit)
		  begin
		  	if(prev_imm == 0) prev_imm = {16 {instruction[15]}};	// sign extend immediate
			arg3[1:16] = "0x";
			arg3[17:48] = hex4(prev_imm);				// high 16 bits are prev_imm
			arg3[49:80] = hex4(instruction[15:0]);	// low 16 bits are in opcode
		  end
		  else arg3[1:24] = registro(`regB_sel);
		  if(rD == 1)	arg1[1:24] = registro(`regD_sel);
		  else if(rD == 2) arg1[1:32] = registro_especial(`regS_sel_msr);
		  arg2[1:24] = registro(`regA_sel);
     end
	  if(rD == 0) arg1[1:32] = "    "; 	// disable unused parameters
	  if(rA == 0) arg2[1:32] = "    "; 
	  if(rB_IMM == 0) arg3[1:80] = "          ";
	  else if(rB_IMM == 2) arg3[1:32] = registro_especial(`regS_sel_msr);
	  else if(rB_IMM == 3) 
	  begin
	  	arg3[1:24] = "FSL";
		arg3[25:32] = "0" + instruction[2:0];
	  end
	  if(rD && rA) arg1[25:32] = ",";	// parameter separators
	  if(rA && rB_IMM) arg2[25:32] = ",";
	  if(rD && rB_IMM) arg2[25:32] = ",";
	  $display("%d PC[%x] OPCODE[%x] - %s", $time, pc_actual, instruction, {op, arg1, arg2, arg3} );
	  if(`opcode != `IMMEDIATE && prev_imm != 0) prev_imm = 0;		// after the opcode that uses the IMM, prev_imm=0
   end
end

function [1:8] hexcharacter ;	// generates 4 bit hex string
 input 	[3:0] nibble ;
 begin
 case (nibble)
 4'b0000 : hexcharacter = "0" ;
 4'b0001 : hexcharacter = "1" ;
 4'b0010 : hexcharacter = "2" ;
 4'b0011 : hexcharacter = "3" ;
 4'b0100 : hexcharacter = "4" ;
 4'b0101 : hexcharacter = "5" ;
 4'b0110 : hexcharacter = "6" ;
 4'b0111 : hexcharacter = "7" ;
 4'b1000 : hexcharacter = "8" ;
 4'b1001 : hexcharacter = "9" ;
 4'b1010 : hexcharacter = "A" ;
 4'b1011 : hexcharacter = "B" ;
 4'b1100 : hexcharacter = "C" ;
 4'b1101 : hexcharacter = "D" ;
 4'b1110 : hexcharacter = "E" ;
 4'b1111 : hexcharacter = "F" ;
 endcase
 end
endfunction

function [15:0] hex2;		// generates 8 bit hex string
 input [7:0] num;
 begin
   hex2[15:8] = hexcharacter(num[7:4]);
	hex2[7:0]  = hexcharacter(num[3:0]);
 end
endfunction

function [31:0] hex4;			// generates 16 bit hex string
 input [15:0] num;
 begin
   hex4[31:16] = hex2(num[15:8]);
	hex4[15:0]  = hex2(num[7:0]);
 end
endfunction

function [1:32] registro_especial;
  input [4:0] regn;
  begin
  case (regn)
  `rS_PC  : registro_especial = "rpc ";
  `rS_MSR : registro_especial = "rmsr";
  default : 
  begin
  	$display("dissasembler: error: special register %x not implemented", regn);
	registro_especial = "???";
  end
  endcase
  end
endfunction

function [1:24] registro;		// converts 5 bits to the register representation rXX
 input [4:0] regn;
 begin
 case (regn)
 0 : registro = "r0 ";
 1 : registro = "r1 ";
 2 : registro = "r2 ";
 3 : registro = "r3 ";
 4 : registro = "r4 ";
 5 : registro = "r5 ";
 6 : registro = "r6 ";
 7 : registro = "r7 ";
 8 : registro = "r8 ";
 9 : registro = "r9 ";
 10: registro = "r10";
 11: registro = "r11";
 12: registro = "r12";
 13: registro = "r13";
 14: registro = "r14";
 15: registro = "r15";
 16: registro = "r16";
 17: registro = "r17";
 18: registro = "r18";
 19: registro = "r19";
 20: registro = "r20";
 21: registro = "r21";
 22: registro = "r22";
 23: registro = "r23";
 24: registro = "r24";
 25: registro = "r25";
 26: registro = "r26";
 27: registro = "r27";
 28: registro = "r28";
 29: registro = "r29";
 30: registro = "r30";
 31: registro = "r31";
 endcase
 end
endfunction
`endif

// -------------- memory/register dumps -------------------
// from Stephen Douglas Craven testbench

`ifdef DEBUG_SIMPLE_MEMORY_DUMP
// BREAKPOINT stops simulation and displays register contents.
// Set to unreachable address to disable.
`define BREAKPOINT 32'hc0

// Define clock counter for debugging
integer i;

reg [31:0] counter;
assign clock = clk;
assign reset = rst;

initial begin
	counter =  32'b0;
	for (i = 0; i >= 0; i = i + 1)
		@(posedge clock) if (~reset) counter <= counter + 1;
end

// Debug Statements
always@(posedge clock)
begin
if( CPU.EXECUTE.instr_complete & !CPU.EXECUTE.stall )
begin
	if(CPU.branch_taken)	// Branch instructions
		begin
				$display("*** PC=%x: BRANCH=%x", {{(30 - `A_SPACE) {1'b0}},CPU.EXECUTE.pc_exe},
				{{(30 - `A_SPACE) {1'b0}},CPU.pc_branch});
		end	
	if (CPU.REGFILE.write_en)	// Register File writes
		begin
			if(CPU.dmem_re)
				$display("*** PC=%x: r%d=%x (leido de DMEM=0x%x)", {{(30 - `A_SPACE) {1'b0}},CPU.EXECUTE.pc_exe}, 
					CPU.REGFILE.regD_addr, {CPU.REGFILE.input_data}, CPU.dmem_addr );
			else
				$display("*** PC=%x: r%d=%x", {{(30 - `A_SPACE) {1'b0}},CPU.EXECUTE.pc_exe}, CPU.REGFILE.regD_addr, 
					{CPU.REGFILE.input_data});
		end

	if (dmem_we)	// Memory writes
		begin
				$display("*** PC=%x: addr=%x write=%x", {{(30 - `A_SPACE) {1'b0}},CPU.EXECUTE.pc_exe}, 
					CPU.dmem_addr, dmem_data2mem);
		end
  if (dmem_re & !CPU.REGFILE.write_en)	// Memory read
  		begin
				$display("*** PC=%x: addr=%x read=%x", {{(30 - `A_SPACE) {1'b0}},CPU.EXECUTE.pc_exe}, 
					CPU.dmem_addr, dmem_data2cpu);
	   end
end

end

// Stop at Breakpoint
//always@(posedge clock)
//begin
//	if(CPU.DECODE.pc_exe == `BREAKPOINT)
//		begin
		// Uncomment to display register file contents at breakpoint
		/*	$display(" PC is %x", CPU.EXECUTE.pc_exe);
			$display(" Clock Counter is %d", counter);
			for(j = 0; j < 8; j = j + 1) 
				$display("    %d: %x      %d %x     %d: %x       %d %x", j, CPU.REGFILE.RF_BANK0.MEM[j], j + 8, 
					CPU.REGFILE.RF_BANK0.MEM[j + 8],j+16, CPU.REGFILE.RF_BANK0.MEM[j+16],j+24, 
					CPU.REGFILE.RF_BANK0.MEM[j+24]);
		*/
//			$finish;
//		end
//end 
`endif

//synthesis translate_on
