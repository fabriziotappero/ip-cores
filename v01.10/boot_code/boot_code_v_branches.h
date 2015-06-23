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


	// Thread 0 : test all jmp_i instructions
	// Thread 1 : test all jmp instructions
	// Thread 2 : test all gto instructions
	// Other threads : do nothing, loop forever

	///////////////
	// clr space //
	///////////////

	i='h0;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s1 };  // lit => s1
	i=i+1;   ram[i] = 16'h040                                     ;  // addr
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s1, `s0 };  // goto, pop s1 (addr)
	//
	i='h4;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s1 };  // lit => s1
	i=i+1;   ram[i] = 16'h044                                     ;  // addr
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s1, `s0 };  // goto, pop s1 (addr)
	//
	i='h8;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s1 };  // lit => s1
	i=i+1;   ram[i] = 16'h048                                     ;  // addr
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s1, `s0 };  // goto, pop s1 (addr)
	//
	i='hc;   ram[i] = { `op_jmp_i,       -5'h1, `_, `_, `s0, `s0 };  // loop forever
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

	// thread 0 : do jmp_i tests
	i='h40;  ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h300                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	// loop forever
	i=i+1;   ram[i] = { `op_jmp_i,       -5'h1, `_, `_, `s0, `s0 };  // loop forever

	// thread 1 : do jmp tests
	i='h44;  ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h500                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	// loop forever
	i=i+1;   ram[i] = { `op_jmp_i,       -5'h1, `_, `_, `s0, `s0 };  // loop forever

	// thread 2 : do gto tests
	i='h48;  ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h700                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	// loop forever
	i=i+1;   ram[i] = { `op_jmp_i,       -5'h1, `_, `_, `s0, `s0 };  // loop forever


	/////////////////
	// subroutines //
	/////////////////



	// sub : test all jmp_i instructions, result in s0, return to (s3)
	// Correct functioning is s0 = 'd91 ('h5b).
	//
	// s0 : 0 (ez), final test result
	// s1 : +1 (gz)
	// s2 : -2 (lz)
	// s3 : running test result, subroutine return address
	//
	// setup test values and running test result:
	i='h300; ram[i] = { `op_byt_i,        8'd0, `_, `_, `s0, `s0 };  // 0=>s0
	i=i+1;   ram[i] = { `op_byt_i,        8'd1, `_, `_, `s0, `s1 };  // 1=>s1
	i=i+1;   ram[i] = { `op_byt_i,       -8'd2, `_, `_, `s0, `s2 };  // -2=>s2
	i=i+1;   ram[i] = { `op_byt_i,        8'd0, `_, `_, `s0, `s3 };  // 1=>s1
	//
	// distance testing
	//
	i=i+1;   ram[i] = { `op_jmp_i,       5'd15, `_, `_, `s0, `s1 };  // jump forward
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_i,       5'd10, `_, `_, `s0, `s1 };  // jump forward
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_i,        5'd6, `_, `_, `s0, `s1 };  // jump forward
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_i,        5'd2, `_, `_, `s0, `s1 };  // jump forward
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_i,        5'd8, `_, `_, `s0, `s1 };  // jump forward (and out)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_i,       -5'd4, `_, `_, `s0, `s1 };  // jump back
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_i,       -5'd8, `_, `_, `s0, `s1 };  // jump back
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_i,      -5'd12, `_, `_, `s0, `s1 };  // jump back
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_i,      -5'd16, `_, `_, `s0, `s1 };  // jump back
	//
	// unconditional testing
	//
	i=i+1;   ram[i] = { `op_jmp_i,        5'd1, `_, `_, `s0, `s1 };  // jump (YYY)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_i,        5'd1, `_, `_, `s0, `s2 };  // jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_i,        5'd1, `_, `_, `s0, `s0 };  // jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	i=i+1;   ram[i] = { `op_jmp_i,        5'd1, `_, `_, `s1, `s1 };  // jump (YYY)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_i,        5'd1, `_, `_, `s1, `s2 };  // jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_i,        5'd1, `_, `_, `s1, `s0 };  // jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	i=i+1;   ram[i] = { `op_jmp_i,        5'd1, `_, `_, `s2, `s1 };  // jump (YYY)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_i,        5'd1, `_, `_, `s2, `s2 };  // jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_i,        5'd1, `_, `_, `s2, `s0 };  // jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	// (A?0) testing
	// ez
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `_, `s0, `s1 };  // (s1==0) ? jump (NNY)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `_, `s0, `s2 };  // (s2==0) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `_, `s0, `s0 };  // (s0==0) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// lz
	i=i+1;   ram[i] = { `op_jmp_ilz,      5'd1, `_, `_, `s0, `s1 };  // (s1<0) ? jump (NYN)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_ilz,      5'd1, `_, `_, `s0, `s2 };  // (s2<0) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_ilz,      5'd1, `_, `_, `s0, `s0 };  // (s0<0) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	// lez
	i=i+1;   ram[i] = { `op_jmp_ilez,     5'd1, `_, `_, `s0, `s1 };  // (s1<=0) ? jump (NYY)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_ilez,     5'd1, `_, `_, `s0, `s2 };  // (s2<=0) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_ilez,     5'd1, `_, `_, `s0, `s0 };  // (s0<=0) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// gz
	i=i+1;   ram[i] = { `op_jmp_igz,      5'd1, `_, `_, `s0, `s1 };  // (s1>0) ? jump (YNN)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_igz,      5'd1, `_, `_, `s0, `s2 };  // (s2>0) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_igz,      5'd1, `_, `_, `s0, `s0 };  // (s0>0) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	// gez
	i=i+1;   ram[i] = { `op_jmp_igez,     5'd1, `_, `_, `s0, `s1 };  // (s1>=0) ? jump (YNY)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_igez,     5'd1, `_, `_, `s0, `s2 };  // (s2>=0) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_igez,     5'd1, `_, `_, `s0, `s0 };  // (s0>=0) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// glz
	i=i+1;   ram[i] = { `op_jmp_iglz,     5'd1, `_, `_, `s0, `s1 };  // (s1<>0) ? jump (YYN)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_iglz,     5'd1, `_, `_, `s0, `s2 };  // (s2<>0) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_iglz,     5'd1, `_, `_, `s0, `s0 };  // (s0<>0) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	//
	// (A?B) testing
	//
	// e
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `_, `_, `s0, `s1 };  // (s1==s0) ? jump (NNY)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `_, `_, `s0, `s2 };  // (s2==s0) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+2=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `_, `_, `s0, `s0 };  // (s0==s0) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `_, `_, `s1, `s1 };  // (s1==s1) ? jump (YNN)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `_, `_, `s1, `s2 };  // (s2==s1) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `_, `_, `s1, `s0 };  // (s0==s1) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	//
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `_, `_, `s2, `s1 };  // (s1==s2) ? jump (NYN)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `_, `_, `s2, `s2 };  // (s2==s2) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `_, `_, `s2, `s0 };  // (s0==s2) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	// l
	i=i+1;   ram[i] = { `op_jmp_il,       5'd1, `_, `_, `s0, `s1 };  // (s1<s0) ? jump (NYN)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_il,       5'd1, `_, `_, `s0, `s2 };  // (s2<s0) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_il,       5'd1, `_, `_, `s0, `s0 };  // (s0<s0) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	//
	i=i+1;   ram[i] = { `op_jmp_il,       5'd1, `_, `_, `s1, `s1 };  // (s1<s1) ? jump (NYY)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_il,       5'd1, `_, `_, `s1, `s2 };  // (s2<s1) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_il,       5'd1, `_, `_, `s1, `s0 };  // (s0<s1) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	i=i+1;   ram[i] = { `op_jmp_il,       5'd1, `_, `_, `s2, `s1 };  // (s1<s2) ? jump (NNN)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_il,       5'd1, `_, `_, `s2, `s2 };  // (s2<s2) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_il,       5'd1, `_, `_, `s2, `s0 };  // (s0<s2) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	// le
	i=i+1;   ram[i] = { `op_jmp_ile,      5'd1, `_, `_, `s0, `s1 };  // (s1<=s0) ? jump (NYY)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_ile,      5'd1, `_, `_, `s0, `s2 };  // (s2<=s0) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_ile,      5'd1, `_, `_, `s0, `s0 };  // (s0<=s0) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	i=i+1;   ram[i] = { `op_jmp_ile,      5'd1, `_, `_, `s1, `s1 };  // (s1<=s1) ? jump (YYY)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_ile,      5'd1, `_, `_, `s1, `s2 };  // (s2<=s1) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_ile,      5'd1, `_, `_, `s1, `s0 };  // (s0<=s1) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	i=i+1;   ram[i] = { `op_jmp_ile,      5'd1, `_, `_, `s2, `s1 };  // (s1<=s2) ? jump (NYN)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_ile,      5'd1, `_, `_, `s2, `s2 };  // (s2<=s2) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_ile,      5'd1, `_, `_, `s2, `s0 };  // (s0<=s2) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	// ug
	i=i+1;   ram[i] = { `op_jmp_iug,      5'd1, `_, `_, `s0, `s1 };  // (s1>s0) ? jump (YYN)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_iug,      5'd1, `_, `_, `s0, `s2 };  // (s2>s0) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_iug,      5'd1, `_, `_, `s0, `s0 };  // (s0>s0) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	//
	i=i+1;   ram[i] = { `op_jmp_iug,      5'd1, `_, `_, `s1, `s1 };  // (s1>s1) ? jump (NYN)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_iug,      5'd1, `_, `_, `s1, `s2 };  // (s2>s1) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_iug,      5'd1, `_, `_, `s1, `s0 };  // (s0>s1) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	//
	i=i+1;   ram[i] = { `op_jmp_iug,      5'd1, `_, `_, `s2, `s1 };  // (s1>s2) ? jump (NNN)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_iug,      5'd1, `_, `_, `s2, `s2 };  // (s2>s2) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_iug,      5'd1, `_, `_, `s2, `s0 };  // (s0>s2) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	// uge
	i=i+1;   ram[i] = { `op_jmp_iuge,     5'd1, `_, `_, `s0, `s1 };  // (s1>=s0) ? jump (YYY)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_iuge,     5'd1, `_, `_, `s0, `s2 };  // (s2>=s0) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_iuge,     5'd1, `_, `_, `s0, `s0 };  // (s0>=s0) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	i=i+1;   ram[i] = { `op_jmp_iuge,     5'd1, `_, `_, `s1, `s1 };  // (s1>=s1) ? jump (YYN)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_iuge,     5'd1, `_, `_, `s1, `s2 };  // (s2>=s1) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_iuge,     5'd1, `_, `_, `s1, `s0 };  // (s0>=s1) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	//
	i=i+1;   ram[i] = { `op_jmp_iuge,     5'd1, `_, `_, `s2, `s1 };  // (s1>=s2) ? jump (NYN)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_iuge,     5'd1, `_, `_, `s2, `s2 };  // (s2>=s2) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_iuge,     5'd1, `_, `_, `s2, `s0 };  // (s0>=s2) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	// gl
	i=i+1;   ram[i] = { `op_jmp_igl,      5'd1, `_, `_, `s0, `s1 };  // (s1<>s0) ? jump (YYN)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_igl,      5'd1, `_, `_, `s0, `s2 };  // (s2<>s0) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_igl,      5'd1, `_, `_, `s0, `s0 };  // (s0<>s0) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	//
	i=i+1;   ram[i] = { `op_jmp_igl,      5'd1, `_, `_, `s1, `s1 };  // (s1<>s1) ? jump (NYY)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_igl,      5'd1, `_, `_, `s1, `s2 };  // (s2<>s1) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_igl,      5'd1, `_, `_, `s1, `s0 };  // (s0<>s1) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	i=i+1;   ram[i] = { `op_jmp_igl,      5'd1, `_, `_, `s2, `s1 };  // (s1<>s2) ? jump (YNY)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_igl,      5'd1, `_, `_, `s2, `s2 };  // (s2<>s2) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = { `op_jmp_igl,      5'd1, `_, `_, `s2, `s0 };  // (s0<>s2) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// cleanup
	i=i+1;   ram[i] = {  op_pop,                `P, `P, `s2, `s1 };  // pop s1 & s2
	// check for opcode errors
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h900                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `_, `s0, `s0 };  // (s0==0) ? skip
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `P, `P, `s0, `s3 };  // s3+1=>s3, pop both
	// check for stack errors
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h910                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `_, `s0, `s0 };  // (s0==0) ? skip
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `P, `P, `s0, `s3 };  // s3+1=>s3, pop both
	// s3=>s0, return
	i=i+1;   ram[i] = {  op_cpy,                `P, `P, `s3, `s0 };  // s3=>s0, pop both
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s3, `s0 };  // return to (s3), pop s3
	// end sub

	
	// sub : test all jmp instructions, result in s0, return to (s3)
	// Correct functioning is s0 = 'd29 ('h1D).
	//
	// s0 : 0 (ez), final test result
	// s1 : +1 (gz)
	// s2 : -2 (lz)
	// s3 : running test result, subroutine return address
	//
	// setup test values and running test result:
	i='h500; ram[i] = { `op_byt_i,        8'd0, `_, `_, `s0, `s0 };  // 0=>s0
	i=i+1;   ram[i] = { `op_byt_i,        8'd1, `_, `_, `s0, `s1 };  // 1=>s1
	i=i+1;   ram[i] = { `op_byt_i,       -8'd2, `_, `_, `s0, `s2 };  // -2=>s2
	i=i+1;   ram[i] = { `op_byt_i,        8'd0, `_, `_, `s0, `s3 };  // 1=>s1
	//
	// distance testing
	//
	i=i+1;   ram[i] = { `op_byt_i,       8'd15, `_, `_, `s0, `s2 };  // 15=>s2
	i=i+1;   ram[i] = {  op_jmp,                `P, `_, `s2, `s0 };  // jump forward, pop s2
	//
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_byt_i,        8'd9, `_, `_, `s0, `s2 };  // 9=>s2
	i=i+1;   ram[i] = {  op_jmp,                `P, `_, `s2, `s0 };  // jump forward, pop s2
	//
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_byt_i,        8'd3, `_, `_, `s0, `s2 };  // 3=>s2
	i=i+1;   ram[i] = {  op_jmp,                `P, `_, `s2, `s0 };  // jump forward, pop s2
	//
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_byt_i,        8'd9, `_, `_, `s0, `s2 };  // 9=>s2
	i=i+1;   ram[i] = {  op_jmp,                `P, `_, `s2, `s0 };  // jump forward (and out), pop s2
	//
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_byt_i,       -8'd6, `_, `_, `s0, `s2 };  // -6=>s2
	i=i+1;   ram[i] = {  op_jmp,                `P, `_, `s2, `s0 };  // jump back, pop s2
	//
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_byt_i,      -8'd12, `_, `_, `s0, `s2 };  // -12=>s2
	i=i+1;   ram[i] = {  op_jmp,                `P, `_, `s2, `s0 };  // jump back, pop s2
	//
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = { `op_byt_i,      -8'd18, `_, `_, `s0, `s2 };  // -18=>s2
	i=i+1;   ram[i] = {  op_jmp,                `P, `_, `s2, `s0 };  // jump back, pop s2
	//
	// unconditional testing
	//
	i=i+1;   ram[i] = {  op_jmp,                `_, `_, `s1, `s1 };  // jump (YYY)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = {  op_jmp,                `_, `_, `s1, `s2 };  // jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = {  op_jmp,                `_, `_, `s1, `s0 };  // jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	// (A?0) testing
	// ez
	i=i+1;   ram[i] = {  op_jmp_ez,             `_, `_, `s1, `s1 };  // (s1==0) ? jump (NNY)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = {  op_jmp_ez,             `_, `_, `s1, `s2 };  // (s2==0) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = {  op_jmp_ez,             `_, `_, `s1, `s0 };  // (s0==0) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// lz
	i=i+1;   ram[i] = {  op_jmp_lz,             `_, `_, `s1, `s1 };  // (s1<0) ? jump (NYN)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = {  op_jmp_lz,             `_, `_, `s1, `s2 };  // (s2<0) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = {  op_jmp_lz,             `_, `_, `s1, `s0 };  // (s0<0) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	// lez
	i=i+1;   ram[i] = {  op_jmp_lez,            `_, `_, `s1, `s1 };  // (s1<=0) ? jump (NYY)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = {  op_jmp_lez,            `_, `_, `s1, `s2 };  // (s2<=0) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = {  op_jmp_lez,            `_, `_, `s1, `s0 };  // (s0<=0) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// gz
	i=i+1;   ram[i] = {  op_jmp_gz,             `_, `_, `s1, `s1 };  // (s1>0) ? jump (YNN)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = {  op_jmp_gz,             `_, `_, `s1, `s2 };  // (s2>0) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = {  op_jmp_gz,             `_, `_, `s1, `s0 };  // (s0>0) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	// gez
	i=i+1;   ram[i] = {  op_jmp_gez,            `_, `_, `s1, `s1 };  // (s1>=0) ? jump (YNY)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = {  op_jmp_gez,            `_, `_, `s1, `s2 };  // (s2>=0) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	i=i+1;   ram[i] = {  op_jmp_gez,            `_, `_, `s1, `s0 };  // (s0>=0) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// glz
	i=i+1;   ram[i] = {  op_jmp_glz,            `_, `_, `s1, `s1 };  // (s1<>0) ? jump (YYN)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = {  op_jmp_glz,            `_, `_, `s1, `s2 };  // (s2<>0) ? jump
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = {  op_jmp_glz,            `_, `_, `s1, `s0 };  // (s0<>0) ? jump
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	// cleanup
	i=i+1;   ram[i] = {  op_pop,                `P, `P, `s2, `s1 };  // pop s1 & s2
	// check for opcode errors
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h900                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `_, `s0, `s0 };  // (s0==0) ? skip
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `P, `P, `s0, `s3 };  // s3+1=>s3, pop both
	// check for stack errors
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h910                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `_, `s0, `s0 };  // (s0==0) ? skip
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `P, `P, `s0, `s3 };  // s3+1=>s3, pop both
	// s3=>s0, return
	i=i+1;   ram[i] = {  op_cpy,                `P, `P, `s3, `s0 };  // s3=>s0, pop both
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s3, `s0 };  // return to (s3), pop s3
	// end sub


	// sub : test all gto instructions, result in s0, return to (s3)
	// Correct functioning is s0 = 'd25 ('h19).
	//
	// s0 : 0 (ez), final test result
	// s1 : PC (gz)
	// s2 : -2 (lz)
	// s3 : running test result, subroutine return address
	//
	// setup test values and running test result:
	i='h700; ram[i] = { `op_byt_i,        8'd0, `_, `_, `s0, `s0 };  // 0=>s0
	i=i+1;   ram[i] = { `op_byt_i,       -8'd2, `_, `_, `s0, `s2 };  // -2=>s2
	i=i+1;   ram[i] = { `op_byt_i,        8'd0, `_, `_, `s0, `s3 };  // 1=>s1
	//
	// distance testing
	//
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd6, `_, `P, `s0, `s1 };  // s1+6=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s1, `s0 };  // go forward, pop s1
	//
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd6, `_, `P, `s0, `s1 };  // s1+6=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s1, `s0 };  // go forward, pop s1
	//
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,       -6'd6, `_, `P, `s0, `s1 };  // s1-6=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s1, `s0 };  // go back, pop s1
	//
	// unconditional testing
	//
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd3, `_, `P, `s0, `s1 };  // s1+3=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s1, `s1 };  // go, pop s1 (YYY)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd3, `_, `P, `s0, `s1 };  // s1+3=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s1, `s2 };  // go, pop s1 (YYY)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd3, `_, `P, `s0, `s1 };  // s1+3=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s1, `s0 };  // go, pop s1 (YYY)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	// (A?0) testing
	// ez
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd3, `_, `P, `s0, `s1 };  // s1+3=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto_ez,             `P, `_, `s1, `s1 };  // (s1==0) ? go, pop s1(NNY)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	//
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd3, `_, `P, `s0, `s1 };  // s1+3=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto_ez,             `P, `_, `s1, `s2 };  // (s2==0) ? go, pop s1
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	//
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd3, `_, `P, `s0, `s1 };  // s1+3=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto_ez,             `P, `_, `s1, `s0 };  // (s0==0) ? go, pop s1
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// lz
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd3, `_, `P, `s0, `s1 };  // s1+3=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto_lz,             `P, `_, `s1, `s1 };  // (s1<0) ? go, pop s1(NYN)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	//
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd3, `_, `P, `s0, `s1 };  // s1+3=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto_lz,             `P, `_, `s1, `s2 };  // (s2<0) ? go, pop s1
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd3, `_, `P, `s0, `s1 };  // s1+3=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto_lz,             `P, `_, `s1, `s0 };  // (s0<0) ? go, pop s1
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	// lez
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd3, `_, `P, `s0, `s1 };  // s1+3=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto_lez,            `P, `_, `s1, `s1 };  // (s1<=0) ? go, pop s1(NYY)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	//
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd3, `_, `P, `s0, `s1 };  // s1+3=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto_lez,            `P, `_, `s1, `s2 };  // (s2<=0) ? go, pop s1
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd3, `_, `P, `s0, `s1 };  // s1+3=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto_lez,            `P, `_, `s1, `s0 };  // (s0<=0) ? go, pop s1
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// gz
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd3, `_, `P, `s0, `s1 };  // s1+3=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto_gz,             `P, `_, `s1, `s1 };  // (s1>0) ? go, pop s1(YNN)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd3, `_, `P, `s0, `s1 };  // s1+3=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto_gz,             `P, `_, `s1, `s2 };  // (s2>0) ? go, pop s1
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	//
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd3, `_, `P, `s0, `s1 };  // s1+3=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto_gz,             `P, `_, `s1, `s0 };  // (s0>0) ? go, pop s1
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	// gez
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd3, `_, `P, `s0, `s1 };  // s1+3=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto_gez,            `P, `_, `s1, `s1 };  // (s1>=0) ? go, pop s1(YNY)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd3, `_, `P, `s0, `s1 };  // s1+3=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto_gez,            `P, `_, `s1, `s2 };  // (s2>=0) ? go, pop s1
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	//
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd3, `_, `P, `s0, `s1 };  // s1+3=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto_gez,            `P, `_, `s1, `s0 };  // (s0>=0) ? go, pop s1
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// glz
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd3, `_, `P, `s0, `s1 };  // s1+3=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto_glz,            `P, `_, `s1, `s1 };  // (s1<>0) ? go, pop s1(YYN)
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd3, `_, `P, `s0, `s1 };  // s1+3=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto_glz,            `P, `_, `s1, `s2 };  // (s2<>0) ? go, pop s1
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	i=i+1;   ram[i] = {  op_pc,                 `_, `_, `s0, `s1 };  // pc => s1
	i=i+1;   ram[i] = { `op_add_i,        6'd3, `_, `P, `s0, `s1 };  // s1+3=>s1, pop s1
	i=i+1;   ram[i] = {  op_gto_glz,            `P, `_, `s1, `s0 };  // (s0<>0) ? go, pop s1
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3 (N)
	// cleanup
	i=i+1;   ram[i] = {  op_pop,                `_, `P, `s0, `s2 };  // pop s2
	// check for opcode errors
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h900                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `_, `s0, `s0 };  // (s0==0) ? skip
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `P, `P, `s0, `s3 };  // s3+1=>s3, pop both
	// check for stack errors
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h910                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `_, `s0, `s0 };  // (s0==0) ? skip
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s3 };  // s3-1=>s3, pop s3 (Y)
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `P, `P, `s0, `s3 };  // s3+1=>s3, pop both
	// s3=>s0, return
	i=i+1;   ram[i] = {  op_cpy,                `P, `P, `s3, `s0 };  // s3=>s0, pop both
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s3, `s0 };  // return to (s3), pop s3
	// end sub


	// sub : read & clear opcode errors for this thread => s0, return to (s3)
	i='h900; ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = REG_BASE_ADDR                               ;  // reg base addr
	i=i+1;   ram[i] = { `op_rd_i, THRD_ID_ADDR, `_, `_, `s2, `s0 };  // read (s2+offset)=>s0
	i=i+1;   ram[i] = {  op_shl_u,              `_, `P, `s0, `s0 };  // 1<<s0=>s0, pop s0
	i=i+1;   ram[i] = { `op_rd_i,   OP_ER_ADDR, `_, `_, `s2, `s1 };  // read (s2+offset)=>s1
	i=i+1;   ram[i] = {  op_and,                `P, `P, `s1, `s0 };  // s0&s1=>s0, pop both
	i=i+1;   ram[i] = { `op_wr_i,   OP_ER_ADDR, `P, `_, `s2, `s0 };  // write s0=>(s2+offset), pop s2
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s3, `s0 };  // return to (s3), pop s3


	// sub : read & clear stack errors for this thread => s0, return to (s3)
	i='h910; ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = REG_BASE_ADDR                               ;  // reg base addr
	i=i+1;   ram[i] = { `op_rd_i, THRD_ID_ADDR, `_, `_, `s2, `s0 };  // read (s2+offset)=>s0
	i=i+1;   ram[i] = {  op_shl_u,              `_, `P, `s0, `s0 };  // 1<<s0=>s0, pop s0
	i=i+1;   ram[i] = {  op_cpy,                `_, `_, `s0, `s1 };  // s0=>s1
	i=i+1;   ram[i] = { `op_shl_i,        6'd8, `_, `P, `s0, `s1 };  // s1<<8=>s1, pop s1
	i=i+1;   ram[i] = {  op_or,                 `P, `P, `s1, `s0 };  // s0|s1=>s0, pop both
	i=i+1;   ram[i] = { `op_rd_i,  STK_ER_ADDR, `_, `_, `s2, `s1 };  // read (s2+offset)=>s1
	i=i+1;   ram[i] = {  op_and,                `P, `P, `s1, `s0 };  // s0&s1=>s0, pop both
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


	end
