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


	// Thread 0 : test stack 1 for depth and error reporting
	// All other threads : loop forever

	///////////////
	// clr space //
	///////////////

	// thread 0
	i='h0;   ram[i] = { `lit_u,            `__, `s2 };  // s2='h0100
	i=i+1;   ram[i] =                      16'h0100  ;  // 
	i=i+1;   ram[i] = { `gto,              `P2, `__ };  // goto, pop s2 (addr)
	// and the rest
	i='h04;  ram[i] = { `jmp_ie,    -4'd1, `s0, `s0 };  // loop forever
	i='h08;  ram[i] = { `jmp_ie,    -4'd1, `s0, `s0 };  // loop forever
	i='h0c;  ram[i] = { `jmp_ie,    -4'd1, `s0, `s0 };  // loop forever
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


	// test s1 for correct stack depth and error reporting, result in s0
	// Correct functioning is s0 = 'd7 ('h7).
	//
	// s0 : final test result
	// s1 : test stack
	// s2 : sub addr
	// s3 : running test result, subroutine return address
	//
	// setup running test result:
	i='h100; ram[i] = { `dat_is,          6'd0, `s7 };  // s7=0
	// check for no stack errors
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7=addr
	i=i+1;   ram[i] =                      16'h0910  ;  // addr
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr), return to s7
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P4 };  // (s4==0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3-- (Y)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// fill s1
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7=addr
	i=i+1;   ram[i] =                      16'h0940  ;  // addr
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr), return to s7
	// check for push error
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7=addr
	i=i+1;   ram[i] =                      16'h0910  ;  // addr
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr), return to s7
	i=i+1;   ram[i] = { `psu_i,          -6'd8, `P4 };  // s4>>=8
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P4 };  // (s4==0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// pop&push s/b OK
	i=i+1;   ram[i] = { `add_is,          6'd0, `P1 };  // s1=s1
	// check for no stack errors
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7=addr
	i=i+1;   ram[i] =                      16'h0910  ;  // addr
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr), return to s7
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P4 };  // (s4==0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// s/b one push over the line
	i=i+1;   ram[i] = { `add_is,          6'd0, `s1 };  // s1=>s1
	// check for a push error
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7=addr
	i=i+1;   ram[i] =                      16'h0910  ;  // addr
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr), return to s7
	i=i+1;   ram[i] = { `psu_i,          -6'd8, `P4 };  // s4>>=8
	i=i+1;   ram[i] = { `jmp_inz,         6'd1, `P4 };  // (s4!=0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// empty s1
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7=addr
	i=i+1;   ram[i] =                      16'h0950  ;  // addr
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr), return to s7
	// check for no stack errors
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7=addr
	i=i+1;   ram[i] =                      16'h0910  ;  // addr
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr), return to s7
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P4 };  // (s4==0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// s/b one pop under the line
	i=i+1;   ram[i] = { `pop,           8'b00000010 };  // pop s1
	// check for a pop error	
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7=addr
	i=i+1;   ram[i] =                      16'h0910  ;  // addr
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr), return to s7
	i=i+1;   ram[i] = { `shl_is,         6'd24, `P4 };  // s4<<=24
	i=i+1;   ram[i] = { `jmp_inz,         6'd1, `P4 };  // (s4!=0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// check for no opcode errors
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7=addr
	i=i+1;   ram[i] =                      16'h0900  ;  // addr
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr), return to s7
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P4 };  // (s4==0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// copy result to s0
	i=i+1;   ram[i] = { `cpy,              `P3, `s0 };  // s0=s3, pop s3
	// loop forever
	i=i+1;   ram[i] = { `jmp_ie,    -4'd1, `s0, `s0 };  // loop forever



	/////////////////
	// subroutines //
	/////////////////


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


	// sub : read 32 bit GPIO => s0, return to (s7)
	i='h920; ram[i] = { `dat_is,        `IO_LO, `s3 };  // s3=reg addr
	i=i+1;   ram[i] = { `reg_rs,           `P3, `s0 };  // s0=(s3), pop s3
	i=i+1;   ram[i] = { `dat_is,        `IO_HI, `s3 };  // s3=reg addr
	i=i+1;   ram[i] = { `reg_rh,           `P3, `P0 };  // s0=(s3), pop both
	i=i+1;   ram[i] = { `gto,              `P7, `__ };  // return, pop s7


	// sub : write s0 => 32 bit GPIO, return to (s7)
	i='h930; ram[i] = { `dat_is,        `IO_LO, `s3 };  // s3=reg addr
	i=i+1;   ram[i] = { `reg_w,            `P3, `s0 };  // (s3)=s0, pop s3
	i=i+1;   ram[i] = { `dat_is,        `IO_HI, `s3 };  // s3=reg addr
	i=i+1;   ram[i] = { `reg_wh,           `P3, `s0 };  // (s3)=s0, pop s3
	i=i+1;   ram[i] = { `gto,              `P7, `__ };  // return, pop s7


	// sub : push 32x to s1, return to (s7)
	// loop setup:
	i='h940; ram[i] = { `dat_is,         6'd31, `s1 };  // s1=31  // first push (& loop index)
	// loop
	i=i+1;   ram[i] = { `add_is,         -6'd1, `s1 };  // s1=s1-1
	i=i+1;   ram[i] = { `jmp_inz,        -6'd2, `s1 };  // (s1!=0) ? do again
	i=i+1;   ram[i] = { `gto,              `P7, `__ };  // return, pop s7


	// sub : pop 32x from s1, return to (s7)
	// loop setup:
	i='h950; ram[i] = { `dat_is,         6'd31, `s2 };  // s2=31
	// loop
	i=i+1;   ram[i] = { `pop,           8'b00000010 };  // pop s1
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P2 };  // s2--
	i=i+1;   ram[i] = { `jmp_inlz,       -6'd3, `s2 };  // (s2>=0) ? do again
	i=i+1;   ram[i] = { `gto,              `P7, `P2 };  // return, pop s7 & s2


	end
