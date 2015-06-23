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


	// Thread 0 : test I/O functions
	// All other threads : loop forever

	///////////////
	// clr space //
	///////////////

	// thread 0
	i='h0;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h100                                     ;  // addr
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s2, `s0 };  // goto, pop s2 (addr)
	// and the rest (are here on Gilligan's Isle)
	i='h4;   ram[i] = { `op_jmp_i,       -5'h1, `_, `_, `s0, `s0 };  // loop forever
	i=i+4;   ram[i] = { `op_jmp_i,       -5'h1, `_, `_, `s0, `s0 };  // loop forever
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


	// test I/O functions, result in s0
	// Correct functioning is s0 = 'd9 ('h9).
	//
	// s0 : final test result
	// s1 : test value
	// s2 : test value
	// s3 : running test result, subroutine return address
	//
	// setup running test result:
	i='h100; ram[i] = { `op_byt_i,        8'd0, `_, `_, `s0, `s3 };  // 0=>s3
	// PC
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // PC => s1
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'h102                                     ;  // value
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// setup test value:
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s1, `s1 };  // lit => s1
	i=i+1;   ram[i] = 16'ha53c                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s1, `s1 };  // lit => s1, pop combine
	i=i+1;   ram[i] = 16'h36c9                                    ;  // hi data
	// WR_IX & RD_IX
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'ha00                                     ;  // addr
	i=i+1;   ram[i] = { `op_wr_i,         4'd0, `_, `_, `s2, `s1 };  // write s1=>(s2+offset)
	i=i+1;   ram[i] = { `op_wr_ix,        4'd1, `_, `_, `s2, `s1 };  // write s1=>(s2+offset)
	i=i+1;   ram[i] = { `op_rd_i,         4'd0, `_, `_, `s2, `s0 };  // read (s2+offset)=>s0
	i=i+1;   ram[i] = { `op_rd_ix,        4'd1, `P, `P, `s2, `s0 };  // read (s2+offset)=>s0, pop both
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `_, `P, `s1, `s0 };  // (s0==s1) ? skip, pop s0
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// RD_I (signed)
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'ha00                                     ;  // addr
	i=i+1;   ram[i] = { `op_wr_i,         4'd0, `_, `_, `s2, `s1 };  // write s1=>(s2+offset)
	i=i+1;   ram[i] = { `op_rd_i,         4'd0, `P, `_, `s2, `s0 };  // read (s2+offset)=>s0, pop s2
	i=i+1;   ram[i] = { `op_shl_i,       6'd16, `_, `_, `s1, `s1 };  // s1<<16=>s1
	i=i+1;   ram[i] = { `op_shl_i,      -6'd16, `_, `P, `s1, `s1 };  // s1>>16=>s1, pop s1
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// RD_I (unsigned)
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'ha00                                     ;  // addr
	i=i+1;   ram[i] = { `op_wr_ix,        4'd0, `_, `_, `s2, `s1 };  // write s1=>(s2+offset)
	i=i+1;   ram[i] = { `op_rd_i,         4'd0, `P, `_, `s2, `s0 };  // read (s2+offset)=>s0, pop s2
	i=i+1;   ram[i] = { `op_shl_iu,     -6'd16, `_, `_, `s1, `s1 };  // s1>>16=>s1
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// LIT (signed)
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'ha53c                                    ;  // lo data
	i=i+1;   ram[i] = { `op_shl_i,       6'd16, `_, `_, `s1, `s1 };  // s1<<16=>s1
	i=i+1;   ram[i] = { `op_shl_i,      -6'd16, `_, `P, `s1, `s1 };  // s1>>16=>s1, pop s1
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// LIT (unsigned)
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'ha53c                                    ;  // lo data
	i=i+1;   ram[i] = { `op_shl_i,       6'd16, `_, `_, `s1, `s1 };  // s1<<16=>s1
	i=i+1;   ram[i] = { `op_shl_iu,     -6'd16, `_, `P, `s1, `s1 };  // s1>>16=>s1, pop s1
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// CPY
	i=i+1;   ram[i] = {  op_cpy,                `_, `_, `s1, `s0 };  // s1=>s0
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `_, `P, `s1, `s0 };  // (s0==s1) ? skip, pop s0
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// check for no opcode errors
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h900                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `P, `s0, `s0 };  // (s0==0) ? skip, pop s0
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// check for no stack errors
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h910                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `P, `s0, `s0 };  // (s0==0) ? skip, pop s0
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// s3=>s0, loop forever
	i=i+1;   ram[i] = {  op_cpy,                `P, `_, `s3, `s0 };  // s3=>s0, pop s3
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



	end
