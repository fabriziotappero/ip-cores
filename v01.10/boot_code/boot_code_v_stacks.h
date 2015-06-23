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
	-------------------------
	-- external parameters --
	-------------------------
	*/
	`include "op_encode.h"
	`include "reg_set_addr.h"

	/*
	------------------------------------------------------------
	-- defines that make programming code more human readable --
	------------------------------------------------------------
	*/
	`define s0				2'd0
	`define s1				2'd1
	`define s2				2'd2
	`define s3				2'd3
	`define _				1'b0
	`define P				1'b1
	//
	`define op_rd_i		op_rd_i[9:4]
	`define op_rd_ix		op_rd_ix[9:4]
	//
	`define op_jmp_iez	op_jmp_iez[9:5]
	`define op_jmp_ilz	op_jmp_ilz[9:5]
	`define op_jmp_ilez	op_jmp_ilez[9:5]
	`define op_jmp_igz	op_jmp_igz[9:5]
	`define op_jmp_igez	op_jmp_igez[9:5]
	`define op_jmp_iglz	op_jmp_iglz[9:5]
	`define op_jmp_i		op_jmp_i[9:5]
	//
	`define op_wr_i		op_wr_i[9:4]
	`define op_wr_ix		op_wr_ix[9:4]
	//
	`define op_jmp_ie		op_jmp_ie[9:5]
	`define op_jmp_il		op_jmp_il[9:5]
	`define op_jmp_ile	op_jmp_ile[9:5]
	`define op_jmp_iug	op_jmp_iug[9:5]
	`define op_jmp_iuge	op_jmp_iuge[9:5]
	`define op_jmp_igl	op_jmp_igl[9:5]
	//
	`define op_byt_i		op_byt_i[9:8]
	//
	`define op_shl_i		op_shl_i[9:6]
	`define op_shl_iu		op_shl_iu[9:6]
	`define op_add_i		op_add_i[9:6]
	
	/*
	----------------------------------------
	-- initialize: fill with default data --
	----------------------------------------
	*/
	integer i;

	initial begin

/*	// fill with nop (some compilers need this)
	for ( i = 0; i < CAPACITY; i = i+1 ) begin
		ram[i] = { op_nop, `_, `_, `s0, `s0 };
	end
*/

	/*
	---------------
	-- boot code --
	---------------
	*/


	// Thread 0 : test stack 1 for depth and error reporting
	// Thread 1 : test stack 1 clear instruction
	// All other threads : loop forever

	///////////////
	// clr space //
	///////////////

	// thread 0
	i='h0;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h100                                     ;  // addr
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s2, `s0 };  // goto, pop s2 (addr)
	//
	// thread 1
	i='h4;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h200                                     ;  // addr
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s2, `s0 };  // goto, pop s2 (addr)
	// and the rest (are here on Gilligan's Isle)
	i='h8;   ram[i] = { `op_jmp_i,       -5'h1, `_, `_, `s0, `s0 };  // loop forever
	i=i+4;   ram[i] = { `op_jmp_i,       -5'h1, `_, `_, `s0, `s0 };  // loop forever
	i=i+4;   ram[i] = { `op_jmp_i,       -5'h1, `_, `_, `s0, `s0 };  // loop forever
	i=i+4;   ram[i] = { `op_jmp_i,       -5'h1, `_, `_, `s0, `s0 };  // loop forever
	i=i+4;   ram[i] = { `op_jmp_i,       -5'h1, `_, `_, `s0, `s0 };  // loop forever
	i=i+4;   ram[i] = { `op_jmp_i,       -5'h1, `_, `_, `s0, `s0 };  // loop forever


	////////////////
	// intr space //
	////////////////

	///////////////////////
	// code & data space //
	///////////////////////


	// test correct stack depth and error reporting, result in s0
	// Correct functioning is s0 = 'd6 ('h6).
	//
	// s0 : final test result
	// s1 : test stack
	// s2 : sub addr
	// s3 : running test result, subroutine return address
	//
	// setup running test result:
	i='h100; ram[i] = { `op_byt_i,        8'd0, `_, `_, `s0, `s3 };  // 0=>s3
	// check for no stack errors
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h910                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `_, `s0, `s0 };  // (s0==0) ? skip
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `P, `P, `s0, `s3 };  // s3+1=>s3, pop both
	// fill s1
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h940                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	// check for push error
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h910                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_shl_iu,      -6'd8, `_, `P, `s0, `s0 };  // s0>>8=>s0, pop s0
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `_, `s0, `s0 };  // (s0==0) ? skip
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `P, `P, `s0, `s3 };  // s3+1=>s3, pop both
	// pop&push s/b OK
	i=i+1;   ram[i] = {  op_cpy,                `_, `P, `s2, `s1 };  // s2=>s1
	// check for no stack errors
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h910                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `_, `s0, `s0 };  // (s0==0) ? skip
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `P, `P, `s0, `s3 };  // s3+1=>s3, pop both
	// s/b one push over the line
	i=i+1;   ram[i] = {  op_cpy,                `_, `_, `s2, `s1 };  // s2=>s1
	// check for a push error
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h910                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_shl_iu,      -6'd8, `_, `P, `s0, `s0 };  // s0>>8=>s0, pop s0
	i=i+1;   ram[i] = { `op_jmp_iglz,     5'd1, `_, `_, `s0, `s0 };  // (s0<>0) ? skip
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `P, `P, `s0, `s3 };  // s3+1=>s3, pop both
	// empty s1
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h950                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	// check for no stack errors
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h910                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `_, `s0, `s0 };  // (s0==0) ? skip
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `P, `P, `s0, `s3 };  // s3+1=>s3, pop both
	// s/b one pop under the line
	i=i+1;   ram[i] = {  op_pop,                `_, `P, `s0, `s1 };  // pop s1
	// check for a pop error
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h910                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_shl_i,       6'd24, `_, `P, `s0, `s0 };  // s0<<24=>s0, pop s0
	i=i+1;   ram[i] = { `op_jmp_iglz,     5'd1, `_, `_, `s0, `s0 };  // (s0<>0) ? skip
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `P, `P, `s0, `s3 };  // s3+1=>s3, pop both
	// s3=>s0, loop forever
	i=i+1;   ram[i] = {  op_cpy,                `P, `P, `s3, `s0 };  // s3=>s0, pop both
	i=i+1;   ram[i] = { `op_jmp_i,       -5'h1, `_, `_, `s0, `s0 };  // loop forever


	// test stack clearing, result in s0
	// Correct functioning is s0 = 'd2 ('h2).
	//
	// s0 : final test result
	// s1 : test stack
	// s2 : sub addr
	// s3 : running test result, subroutine return address
	//
	// setup running test result:
	i='h200; ram[i] = { `op_byt_i,        8'd0, `_, `_, `s0, `s3 };  // 0=>s3
	// check for no stack errors
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h910                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `_, `s0, `s0 };  // (s0==0) ? skip
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `P, `P, `s0, `s3 };  // s3+1=>s3, pop both
	// fill s1
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h940                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	// save s3
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'ha00                                     ;  // addr
	i=i+1;   ram[i] = { `op_wr_i,         4'd0, `P, `_, `s2, `s3 };  // write s3=>(s2+offset), pop s2
	// clear all stacks
	i=i+1;   ram[i] = {  op_cls,                `_, `_, `s0, `s0 };  // clear stacks
	// restore s3
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'ha00                                     ;  // addr
	i=i+1;   ram[i] = { `op_rd_i,         4'd0, `P, `_, `s2, `s3 };  // read (s2+offset) => s3, pop s2
	// fill s1 again
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h940                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	// check for no stack errors
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h910                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `_, `s0, `s0 };  // (s0==0) ? skip
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `P, `P, `s0, `s3 };  // s3+1=>s3, pop both
	// s3=>s0, loop forever
	i=i+1;   ram[i] = {  op_cpy,                `P, `P, `s3, `s0 };  // s3=>s0, pop both
	i=i+1;   ram[i] = { `op_jmp_i,       -5'h1, `_, `_, `s0, `s0 };  // loop forever


	/////////////////
	// subroutines //
	/////////////////


	// sub : read & clear opcode errors for this thread => s0, return to (s3)
	i='h900; ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = REG_BASE_ADDR                               ;  // reg base addr
	i=i+1;   ram[i] = { `op_rd_i, THRD_ID_ADDR, `_, `_, `s2, `s0 };  // read (s2+offset)=>s0
	i=i+1;   ram[i] = {  op_shl_u,              `_, `P, `s0, `s0 };  // 1<<s0=>s0, pop s0
	i=i+1;   ram[i] = { `op_rd_i,   OP_ER_ADDR, `_, `_, `s2, `s3 };  // read (s2+offset)=>s3
	i=i+1;   ram[i] = {  op_and,                `P, `P, `s3, `s0 };  // s0&s3=>s0, pop both
	i=i+1;   ram[i] = { `op_wr_i,   OP_ER_ADDR, `P, `_, `s2, `s0 };  // write s0=>(s2+offset), pop s2
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s3, `s0 };  // return to (s3), pop s3


	// sub : read & clear stack errors for this thread => s0, return to (s3)
	i='h910; ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = REG_BASE_ADDR                               ;  // reg base addr
	i=i+1;   ram[i] = { `op_rd_i, THRD_ID_ADDR, `_, `_, `s2, `s0 };  // read (s2+offset)=>s0
	i=i+1;   ram[i] = {  op_shl_u,              `_, `P, `s0, `s0 };  // 1<<s0=>s0, pop s0
	i=i+1;   ram[i] = {  op_cpy,                `_, `_, `s0, `s3 };  // s0=>s3
	i=i+1;   ram[i] = { `op_shl_i,        6'd8, `_, `P, `s0, `s3 };  // s3<<8=>s3, pop s3
	i=i+1;   ram[i] = {  op_or,                 `P, `P, `s3, `s0 };  // s0|s3=>s0, pop both
	i=i+1;   ram[i] = { `op_rd_i,  STK_ER_ADDR, `_, `_, `s2, `s3 };  // read (s2+offset)=>s3
	i=i+1;   ram[i] = {  op_and,                `P, `P, `s3, `s0 };  // s0&s3=>s0, pop both
	i=i+1;   ram[i] = { `op_wr_i,  STK_ER_ADDR, `P, `_, `s2, `s0 };  // write s0=>(s2+offset), pop s2
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s3, `s0 };  // return to (s3), pop s3


	// sub : read 32 bit GPIO => s0, return to (s3)
	i='h920; ram[i] = {  op_lit_u,              `_, `_, `s0, `s1 };  // lit => s1
	i=i+1;   ram[i] = REG_BASE_ADDR                               ;  // reg base addr
	i=i+1;   ram[i] = { `op_rd_i,   IO_LO_ADDR, `_, `_, `s1, `s0 };  // read (s1+offset) => s0
	i=i+1;   ram[i] = { `op_rd_ix,  IO_HI_ADDR, `P, `P, `s1, `s0 };  // read (s1+offset) => s0, pop s1 & s0
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s3, `s0 };  // return, pop s3


	// sub : write s0 => 32 bit GPIO, return to (s3)
	i='h930; ram[i] = {  op_lit_u,              `_, `_, `s0, `s1 };  // lit => s1
	i=i+1;   ram[i] = REG_BASE_ADDR                               ;  // reg base addr
	i=i+1;   ram[i] = { `op_wr_i,   IO_LO_ADDR, `_, `_, `s1, `s0 };  // write s0 => (s1+offset)
	i=i+1;   ram[i] = { `op_wr_ix,  IO_HI_ADDR, `P, `_, `s1, `s0 };  // write s0 => (s1+offset), pop s1
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s3, `s0 };  // return, pop s3

	// sub : loop until empty s1 is full, return to (s3)
	// loop setup:
	i='h940; ram[i] = { `op_byt_i,       8'd32, `_, `_, `s0, `s2 };  // 32=>s2
	// loop
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s2 };  // s2--=>s2, pop s2
	i=i+1;   ram[i] = {  op_cpy,                `_, `_, `s2, `s1 };  // s2=>s1
	i=i+1;   ram[i] = { `op_jmp_igz,     -5'd3, `_, `_, `s0, `s2 };  // (s2>0) ? do again
	i=i+1;   ram[i] = {  op_gto,                `P, `P, `s3, `s2 };  // return, pop s3 & s2

	// sub : loop until full s1 is empty, return to (s3)
	// loop setup:
	i='h950; ram[i] = { `op_byt_i,       8'd32, `_, `_, `s0, `s2 };  // 32=>s2
	// loop
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s2 };  // s2+1=>s2, pop s2
	i=i+1;   ram[i] = {  op_pop,                `_, `P, `s0, `s1 };  // pop s1
	i=i+1;   ram[i] = { `op_jmp_igz,     -5'd3, `_, `_, `s0, `s2 };  // (s2>0) ? do again
	i=i+1;   ram[i] = {  op_gto,                `P, `P, `s3, `s2 };  // return, pop s3 & s2


	end
