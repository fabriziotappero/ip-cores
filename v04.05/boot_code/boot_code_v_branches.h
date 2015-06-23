/*
--------------------------------------------------------------------------------

Module : boot_code.h

--------------------------------------------------------------------------------

Function:
- Boot code for a processor core.

Instantiates:
- Nothing.

Notes:
- For testing (@ core.v):
  CLR_BASE		= 'h0;
  CLR_SPAN		= 2;  // gives 4 instructions
  INTR_BASE		= 'h20;  // 'd32
  INTR_SPAN		= 2;  // gives 4 instructions


--------------------------------------------------------------------------------
*/

	/*
	--------------------
	-- external stuff --
	--------------------
	*/
	`include "op_encode.h"
	`include "reg_set_addr.h"
	`include "boot_code_defs.h"
	
	/*
	----------------------------------------
	-- initialize: fill with default data --
	----------------------------------------
	*/
	integer i;

	initial begin

/*	// fill with nop (some compilers need this)
	for ( i = 0; i < CAPACITY; i = i+1 ) begin
		ram[i] = { `nop, `__, `__ };
	end
*/

	/*
	---------------
	-- boot code --
	---------------
	*/


	// Thread 0 : test all jmp_i (A?B) instructions
	// Thread 1 : test all jmp_i (A?0) instructions
	// Thread 2 : test all jmp instructions
	// Thread 3 : test all gto instructions
	// Other threads : do nothing, loop forever

	///////////////
	// clr space //
	///////////////

	i='h0;   ram[i] = { `lit_u,            `__, `s1 };  // s1=addr
	i=i+1;   ram[i] =                      16'h0200  ;  // 
	i=i+1;   ram[i] = { `gto,              `P1, `__ };  // goto, pop s1 (addr)
	//
	i='h4;   ram[i] = { `lit_u,            `__, `s1 };  // s1=addr
	i=i+1;   ram[i] =                      16'h0400  ;  // 
	i=i+1;   ram[i] = { `gto,              `P1, `__ };  // goto, pop s1 (addr)
	//
	i='h8;   ram[i] = { `lit_u,            `__, `s1 };  // s1=addr
	i=i+1;   ram[i] =                      16'h0500  ;  // 
	i=i+1;   ram[i] = { `gto,              `P1, `__ };  // goto, pop s1 (addr)
	//
	i='hc;   ram[i] = { `lit_u,            `__, `s1 };  // s1=addr
	i=i+1;   ram[i] =                      16'h0600  ;  // 
	i=i+1;   ram[i] = { `gto,              `P1, `__ };  // goto, pop s1 (addr)
	//
	i='h10;  ram[i] = { `jmp_ie,    -4'd1, `s0, `s0 };  // loop forever
	i='h14;  ram[i] = { `jmp_ie,    -4'd1, `s0, `s0 };  // loop forever
	i='h18;  ram[i] = { `jmp_ie,    -4'd1, `s0, `s0 };  // loop forever
	i='h1c;  ram[i] = { `jmp_ie,    -4'd1, `s0, `s0 };  // loop forever


	////////////////
	// intr space //
	////////////////


	///////////////////////
	// code & data space //
	///////////////////////


	/////////////////
	// subroutines //
	/////////////////


	// test all jmp_i (A?B) instructions, result in s0.
	// Correct functioning is s0 = 'd58 ('h3A).
	//
	// s0 :  0 & final test result
	// s1 : +1
	// s2 : -2
	// s3 : running test result
	//
	// setup test values and running test result:
	i='h200; ram[i] = { `dat_is,          6'd0, `s0 };  // s0=0
	i=i+1;   ram[i] = { `dat_is,          6'd1, `s1 };  // s1=1
	i=i+1;   ram[i] = { `dat_is,         -6'd2, `s2 };  // s2=-2
	i=i+1;   ram[i] = { `dat_is,          6'd0, `s3 };  // s3=0
	//
	// distance testing
	//
	i=i+1;   ram[i] = { `jmp_ie,     4'd7, `s0, `s0 };  // jump forward
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // (+0,-9) s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // (+1,-8) s3++ (backward jump lands here)
	i=i+1;   ram[i] = { `jmp_ie,     4'd6, `s0, `s0 };  // (+2,-7) jump forward (and out)
	// 3 don't cares here
	i=i+4;   ram[i] = { `add_is,         -6'd1, `P3 };  // (+6,-3) s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // (+7,-2) s3++ (forward jump lands here)
	i=i+1;   ram[i] = { `jmp_ie,    -4'd8, `s0, `s0 };  // (+8,-1) jump back
	//
	// (A?B) testing
	//
	// ie
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `s0, `s0 };  // (s0==s0) ? jump (YNN)
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `s0, `s1 };  // (s1==s0) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `s0, `s2 };  // (s2==s0) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	//
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `s1, `s0 };  // (s0==s1) ? jump (NYN)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `s1, `s1 };  // (s1==s1) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `s1, `s2 };  // (s2==s1) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	//
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `s2, `s0 };  // (s0==s2) ? jump (NNY)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `s2, `s1 };  // (s1==s2) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `s2, `s2 };  // (s2==s2) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// ine
	i=i+1;   ram[i] = { `jmp_ine,    4'd1, `s0, `s0 };  // (s0!=s0) ? jump (NYY)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_ine,    4'd1, `s0, `s1 };  // (s1!=s0) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_ine,    4'd1, `s0, `s2 };  // (s2!=s0) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	//
	i=i+1;   ram[i] = { `jmp_ine,    4'd1, `s1, `s0 };  // (s0!=s1) ? jump (YNY)
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_ine,    4'd1, `s1, `s1 };  // (s1!=s1) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_ine,    4'd1, `s1, `s2 };  // (s2!=s1) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	//
	i=i+1;   ram[i] = { `jmp_ine,    4'd1, `s2, `s0 };  // (s0!=s2) ? jump (YYN)
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_ine,    4'd1, `s2, `s1 };  // (s1!=s2) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_ine,    4'd1, `s2, `s2 };  // (s2!=s2) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	// ilu
	i=i+1;   ram[i] = { `jmp_ilu,    4'd1, `s0, `s0 };  // (s0<s0) ? jump (NNN)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_ilu,    4'd1, `s0, `s1 };  // (s1<s0) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_ilu,    4'd1, `s0, `s2 };  // (s2<s0) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	//
	i=i+1;   ram[i] = { `jmp_ilu,    4'd1, `s1, `s0 };  // (s0<s1) ? jump (YNN)
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_ilu,    4'd1, `s1, `s1 };  // (s1<s1) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_ilu,    4'd1, `s1, `s2 };  // (s2<s1) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	//
	i=i+1;   ram[i] = { `jmp_ilu,    4'd1, `s2, `s0 };  // (s0<s2) ? jump (YYN)
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_ilu,    4'd1, `s2, `s1 };  // (s1<s2) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_ilu,    4'd1, `s2, `s2 };  // (s2<s2) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	// inlu
	i=i+1;   ram[i] = { `jmp_inlu,   4'd1, `s0, `s0 };  // (s0>=s0) ? jump (YYY)
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_inlu,   4'd1, `s0, `s1 };  // (s1>=s0) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_inlu,   4'd1, `s0, `s2 };  // (s2>=s0) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	//
	i=i+1;   ram[i] = { `jmp_inlu,   4'd1, `s1, `s0 };  // (s0>=s1) ? jump (NYY)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_inlu,   4'd1, `s1, `s1 };  // (s1>=s1) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_inlu,   4'd1, `s1, `s2 };  // (s2>=s1) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	//
	i=i+1;   ram[i] = { `jmp_inlu,   4'd1, `s2, `s0 };  // (s0>=s2) ? jump (NNY)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_inlu,   4'd1, `s2, `s1 };  // (s1>=s2) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_inlu,   4'd1, `s2, `s2 };  // (s2>=s2) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// ils
	i=i+1;   ram[i] = { `jmp_ils,    4'd1, `s0, `s0 };  // (s0<s0) ? jump (NNY)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_ils,    4'd1, `s0, `s1 };  // (s1<s0) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_ils,    4'd1, `s0, `s2 };  // (s2<s0) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	//
	i=i+1;   ram[i] = { `jmp_ils,    4'd1, `s1, `s0 };  // (s0<s1) ? jump (YNY)
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_ils,    4'd1, `s1, `s1 };  // (s1<s1) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_ils,    4'd1, `s1, `s2 };  // (s2<s1) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	//
	i=i+1;   ram[i] = { `jmp_ils,    4'd1, `s2, `s0 };  // (s0<s2) ? jump (NNN)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_ils,    4'd1, `s2, `s1 };  // (s1<s2) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_ils,    4'd1, `s2, `s2 };  // (s2<s2) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	// inls
	i=i+1;   ram[i] = { `jmp_inls,   4'd1, `s0, `s0 };  // (s0>=s0) ? jump (YYN)
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_inls,   4'd1, `s0, `s1 };  // (s1>=s0) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_inls,   4'd1, `s0, `s2 };  // (s2>=s0) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	//
	i=i+1;   ram[i] = { `jmp_inls,   4'd1, `s1, `s0 };  // (s0>=s1) ? jump (NYN)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_inls,   4'd1, `s1, `s1 };  // (s1>=s1) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_inls,   4'd1, `s1, `s2 };  // (s2>=s1) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	//
	i=i+1;   ram[i] = { `jmp_inls,   4'd1, `s2, `s0 };  // (s0>=s2) ? jump (YYY)
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_inls,   4'd1, `s2, `s1 };  // (s1>=s2) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_inls,   4'd1, `s2, `s2 };  // (s2>=s2) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// cleanup
	i=i+1;   ram[i] = { `pop,           8'b00000111 };  // pop s0, s1, s2
	// check for no opcode errors
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7='h0900
	i=i+1;   ram[i] =                      16'h0900  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr)
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P4 };  // (s4==0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// check for no stack errors
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7='h0910
	i=i+1;   ram[i] =                      16'h0910  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr)
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P4 };  // (s4==0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// copy result to s0
	i=i+1;   ram[i] = { `cpy,              `P3, `s0 };  // s0=s3, pop s3
	// loop forever
	i=i+1;   ram[i] = { `jmp_ie,    -4'd1, `s0, `s0 };  // loop forever



	// test all jmp_i (A?0) instructions, result in s0.
	// Correct functioning is s0 = 'd16 ('h10).
	//
	// s0 :  0 & final test result
	// s1 : +1
	// s2 : -2
	// s3 : running test result
	//
	// setup test values and running test result:
	i='h400; ram[i] = { `dat_is,          6'd0, `s0 };  // s0=0
	i=i+1;   ram[i] = { `dat_is,          6'd1, `s1 };  // s1=1
	i=i+1;   ram[i] = { `dat_is,         -6'd2, `s2 };  // s2=-2
	i=i+1;   ram[i] = { `dat_is,          6'd0, `s3 };  // s3=0
	//
	// distance testing
	//
	i=i+1;   ram[i] = { `jmp_iz,         6'd31, `s0 };  // jump forward
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // (+0,-33) s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // (+1,-32) s3++ (backward jump lands here)
	i=i+1;   ram[i] = { `jmp_iz,         6'd30, `s0 };  // (+2,-31) jump forward (and out)
	// 27 don't cares here
	i=i+28;  ram[i] = { `add_is,         -6'd1, `P3 };  // (+30,-3) s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // (+31,-2) s3++ (forward jump lands here)
	i=i+1;   ram[i] = { `jmp_iz,        -6'd32, `s0 };  // jump back
	//
	// (A?0) testing
	//
	// z
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `s0 };  // (s0==0) ? jump (YNN)
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `s1 };  // (s1==0) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `s2 };  // (s2==0) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	// nz
	i=i+1;   ram[i] = { `jmp_inz,         6'd1, `s0 };  // (s0!=0) ? jump (NYY)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_inz,         6'd1, `s1 };  // (s1!=0) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_inz,         6'd1, `s2 };  // (s2!=0) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// lz
	i=i+1;   ram[i] = { `jmp_ilz,         6'd1, `s0 };  // (s0<0) ? jump (NNY)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_ilz,         6'd1, `s1 };  // (s1<0) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_ilz,         6'd1, `s2 };  // (s2<0) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// nlz
	i=i+1;   ram[i] = { `jmp_inlz,        6'd1, `s0 };  // (s0>=0) ? jump (YYN)
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_inlz,        6'd1, `s1 };  // (s1>=0) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_inlz,        6'd1, `s2 };  // (s2>=0) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	// cleanup
	i=i+1;   ram[i] = { `pop,           8'b00000111 };  // pop s0, s1, s2
	// check for no opcode errors
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7='h0900
	i=i+1;   ram[i] =                      16'h0900  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr)
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P4 };  // (s4==0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// check for no stack errors
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7='h0910
	i=i+1;   ram[i] =                      16'h0910  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr)
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P4 };  // (s4==0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// copy result to s0
	i=i+1;   ram[i] = { `cpy,              `P3, `s0 };  // s0=s3, pop s3
	// loop forever
	i=i+1;   ram[i] = { `jmp_ie,    -4'd1, `s0, `s0 };  // loop forever


	// test all jmp instructions, result in s0.
	// Correct functioning is s0 = 'd19 ('h13).
	//
	// s0 :  0 & final test result
	// s1 : +1
	// s2 : -2
	// s3 : running test result
	//
	// setup test values and running test result:
	i='h500; ram[i] = { `dat_is,          6'd0, `s0 };  // s0=0
	i=i+1;   ram[i] = { `dat_is,          6'd1, `s1 };  // s1=1
	i=i+1;   ram[i] = { `dat_is,         -6'd2, `s2 };  // s2=-2
	i=i+1;   ram[i] = { `dat_is,          6'd0, `s3 };  // s3=0
	//
	// distance testing
	//
	i=i+1;   ram[i] = { `dat_is,         6'd30, `s0 };  // s0=30
	i=i+1;   ram[i] = { `dat_is,        -6'd32, `s0 };  // s0=-32
	i=i+1;   ram[i] = { `dat_is,         6'd31, `s0 };  // s0=31
	i=i+1;   ram[i] = { `jmp,              `P0, `__ };  // jump forward 31, pop s0
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // (+0,-33) s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // (+1,-32) s3++ (backward jump lands here)
	i=i+1;   ram[i] = { `jmp,              `P0, `s0 };  // (+2,-31) jump forward 30 (and out)
	// 27 don't cares here
	i=i+28;  ram[i] = { `add_is,         -6'd1, `P3 };  // (+30,-3) s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // (+31,-2) s3++ (forward jump lands here)
	i=i+1;   ram[i] = { `jmp,              `P0, `__ };  // jump back -32, pop s1
	//
	// unconditional testing
	//
	i=i+1;   ram[i] = { `jmp,              `s1, `s0 };  // jump (s0?0)
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp,              `s1, `s1 };  // jump (s1?0)
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp,              `s1, `s2 };  // jump (s2?0)
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	//
	// (A?0) testing
	// z
	i=i+1;   ram[i] = { `jmp_z,            `s1, `s0 };  // (s0==0) ? jump (YNN)
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_z,            `s1, `s1 };  // (s1==0) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_z,            `s1, `s2 };  // (s2==0) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	// nz
	i=i+1;   ram[i] = { `jmp_nz,           `s1, `s0 };  // (s0!=0) ? jump (NYY)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_nz,           `s1, `s1 };  // (s1!=0) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_nz,           `s1, `s2 };  // (s2!=0) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// lz
	i=i+1;   ram[i] = { `jmp_lz,           `s1, `s0 };  // (s0<0) ? jump (NNY)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_lz,           `s1, `s1 };  // (s1<0) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	i=i+1;   ram[i] = { `jmp_lz,           `s1, `s2 };  // (s2<0) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// nlz
	i=i+1;   ram[i] = { `jmp_nlz,          `s1, `s0 };  // (s0>=0) ? jump (YYN)
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_nlz,          `s1, `s1 };  // (s1>=0) ? jump
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `jmp_nlz,          `s1, `s2 };  // (s2>=0) ? jump
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++ (N)
	// cleanup
	i=i+1;   ram[i] = { `pop,           8'b00000111 };  // pop s0, s1, s2
	// check for no opcode errors
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7='h0900
	i=i+1;   ram[i] =                      16'h0900  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr)
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P4 };  // (s4==0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// check for no stack errors
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7='h0910
	i=i+1;   ram[i] =                      16'h0910  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr)
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P4 };  // (s4==0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// copy result to s0
	i=i+1;   ram[i] = { `cpy,              `P3, `s0 };  // s0=s3, pop s3
	// loop forever
	i=i+1;   ram[i] = { `jmp_ie,    -4'd1, `s0, `s0 };  // loop forever


	// test all gto instructions, result in s0.
	// Correct functioning is s0 = 'd7 ('h7).
	//
	// s0 :  0 & final test result
	// s1 : PC
	// s2 : -2
	// s3 : running test result
	//
	// setup test values and running test result:
	i='h600; ram[i] = { `dat_is,          6'd0, `s0 };  // s0=0
	i=i+1;   ram[i] = { `dat_is,         -6'd2, `s2 };  // s2=-2
	i=i+1;   ram[i] = { `dat_is,          6'd0, `s3 };  // s3=0
	//
	// distance testing
	//
	i=i+1;   ram[i] = { `pgc,              `__, `s1 };  // s1=pc
	i=i+1;   ram[i] = { `add_is,          6'd6, `P1 };  // s1+=6
	i=i+1;   ram[i] = { `gto,              `P1, `__ };  // go forward, pop s1
	//
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `pgc,              `__, `s1 };  // s1=pc
	i=i+1;   ram[i] = { `add_is,          6'd6, `P1 };  // s1+=6
	i=i+1;   ram[i] = { `gto,              `P1, `__ };  // go forward, pop s1
	//
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	i=i+1;   ram[i] = { `pgc,              `__, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `add_is,         -6'd6, `P1 };  // s1-=6
	i=i+1;   ram[i] = { `gto,              `P1, `__ };  // go back, pop s1
	//
	// unconditional testing
	//
	i=i+1;   ram[i] = { `pgc,              `__, `s1 };  // s1=pc
	i=i+1;   ram[i] = { `add_is,          6'd3, `P1 };  // s1+=3
	i=i+1;   ram[i] = { `gto,              `P1, `s0 };  // go, pop s1 (YYY)
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	//
	i=i+1;   ram[i] = { `pgc,              `__, `s1 };  // s1=pc
	i=i+1;   ram[i] = { `add_is,          6'd3, `P1 };  // s1+=3
	i=i+1;   ram[i] = { `gto,              `P1, `s1 };  // go, pop s1
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	//
	i=i+1;   ram[i] = { `pgc,              `__, `s1 };  // s1=pc
	i=i+1;   ram[i] = { `add_is,          6'd3, `P1 };  // s1+=3
	i=i+1;   ram[i] = { `gto,              `P1, `s2 };  // go, pop s1
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// cleanup
	i=i+1;   ram[i] = { `pop,           8'b00000101 };  // pop s0, s2
	// check for no opcode errors
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7='h0900
	i=i+1;   ram[i] =                      16'h0900  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr)
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P4 };  // (s4==0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// check for no stack errors
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7='h0910
	i=i+1;   ram[i] =                      16'h0910  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr)
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P4 };  // (s4==0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// copy result to s0
	i=i+1;   ram[i] = { `cpy,              `P3, `s0 };  // s0=s3, pop s3
	// loop forever
	i=i+1;   ram[i] = { `jmp_ie,    -4'd1, `s0, `s0 };  // loop forever



	// sub : read & clear opcode errors for this thread => s4, return to (s7)
	// avoid the use of s1!
	i='h900; ram[i] = { `dat_is,      `THRD_ID, `s6 };  // s6=reg addr
	i=i+1;   ram[i] = { `reg_rs,           `P6, `s5 };  // s5=(s6), pop s6
	i=i+1;   ram[i] = { `pow,              `P5, `s4 };  // s4=1<<s5, pop s5
	i=i+1;   ram[i] = { `dat_is,        `OP_ER, `s6 };  // s6=reg addr
	i=i+1;   ram[i] = { `reg_rs,           `s6, `s5 };  // s5=(s6)
	i=i+1;   ram[i] = { `and,              `P5, `P4 };  // s4&=s5, pop s5
	i=i+1;   ram[i] = { `reg_w,            `P6, `s4 };  // (s6)=s4, pop s6
	i=i+1;   ram[i] = { `gto,              `P7, `__ };  // return to (s7), pop s7


	// sub : read & clear stack errors for this thread => s4, return to (s7)
	// avoid the use of s1!
	i='h910; ram[i] = { `dat_is,      `THRD_ID, `s6 };  // s6=reg addr
	i=i+1;   ram[i] = { `reg_rs,           `P6, `s5 };  // s5=(s6), pop s6
	i=i+1;   ram[i] = { `pow,              `P5, `s4 };  // s4=1<<s5, pop s5
	i=i+1;   ram[i] = { `cpy,              `s4, `s5 };  // s5=s4
	i=i+1;   ram[i] = { `shl_is,          6'd8, `P5 };  // s5<<=8
	i=i+1;   ram[i] = { `orr,              `P5, `P4 };  // s4|=s5, pop s5
	i=i+1;   ram[i] = { `dat_is,       `STK_ER, `s6 };  // s6=reg addr
	i=i+1;   ram[i] = { `reg_rs,           `s6, `s5 };  // s5=(s6)
	i=i+1;   ram[i] = { `and,              `P5, `P4 };  // s4&=s5, pop s5
	i=i+1;   ram[i] = { `reg_w,            `P6, `s4 };  // (s6)=s4, pop s6
	i=i+1;   ram[i] = { `gto,              `P7, `__ };  // return to (s7), pop s7


	end
