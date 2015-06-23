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
	`define op_wr_i		op_wr_i[9:4]
	`define op_wr_ix		op_wr_ix[9:4]
	//
	`define op_jmp_ie		op_jmp_ie[9:5]
	`define op_jmp_iez	op_jmp_iez[9:5]
	`define op_jmp_il		op_jmp_il[9:5]
	`define op_jmp_ilz	op_jmp_ilz[9:5]
	`define op_jmp_ile	op_jmp_ile[9:5]
	`define op_jmp_ilez	op_jmp_ilez[9:5]
	`define op_jmp_iug	op_jmp_iug[9:5]
	`define op_jmp_igz	op_jmp_igz[9:5]
	`define op_jmp_iuge	op_jmp_iuge[9:5]
	`define op_jmp_igez	op_jmp_igez[9:5]
	`define op_jmp_igl	op_jmp_igl[9:5]
	`define op_jmp_iglz	op_jmp_iglz[9:5]
	//
	`define op_jmp_i		op_jmp_i[9:6]
	//
	`define op_byt_i		op_byt_i[9:8]
	//
	`define op_shl_i		op_shl_i[9:6]
	`define op_shl_iu		op_shl_iu[9:6]
	//
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


	// Thread 0 : test ALU logical functions
	// Thread 1 : test ALU arithmetic functions
	// Thread 2 : test ALU shift functions
	// All other threads : loop forever

	///////////////
	// clr space //
	///////////////

	// thread 0
	i='h0;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h100                                     ;  // addr
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s2, `s0 };  // goto, pop s2 (addr)
	// thread 1
	i='h4;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h200                                     ;  // addr
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s2, `s0 };  // goto, pop s2 (addr)
	// thread 2
	i='h8;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h300                                     ;  // addr
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s2, `s0 };  // goto, pop s2 (addr)
	// and the rest (are here on Gilligan's Isle)
	i='hc;   ram[i] = { `op_jmp_i,       -6'h1, `_, `_, `s0, `s0 };  // loop forever
	i=i+4;   ram[i] = { `op_jmp_i,       -6'h1, `_, `_, `s0, `s0 };  // loop forever
	i=i+4;   ram[i] = { `op_jmp_i,       -6'h1, `_, `_, `s0, `s0 };  // loop forever
	i=i+4;   ram[i] = { `op_jmp_i,       -6'h1, `_, `_, `s0, `s0 };  // loop forever
	i=i+4;   ram[i] = { `op_jmp_i,       -6'h1, `_, `_, `s0, `s0 };  // loop forever


	////////////////
	// intr space //
	////////////////

	///////////////////////
	// code & data space //
	///////////////////////


	// test ALU logical functions, result in s0
	// Correct functioning is s0 = 'd12 ('hc).
	//
	// s0 : final test result
	// s1 : test value
	// s2 : test value
	// s3 : running test result, subroutine return address
	//
	// setup running test result:
	i='h100; ram[i] = { `op_byt_i,        8'd0, `_, `_, `s0, `s3 };  // 0=>s3
	// load s1 & s2 values
	i=i+1;   ram[i] = { `op_byt_i,       -8'h1, `_, `_, `s1, `s1 };  // -1 => s1
	i=i+1;   ram[i] = { `op_byt_i,        8'h1, `_, `_, `s2, `s2 };  //  1 => s2
	// AND_B ( &(-1)=-1; &(1)= 0 )
	i=i+1;   ram[i] = {  op_and_b,              `_, `_, `s1, `s0 };  // &s1=>s0
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `_, `P, `s1, `s0 };  // (s0==-1) ? skip, pop s0
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	i=i+1;   ram[i] = {  op_and_b,              `_, `_, `s2, `s0 };  // &s2=>s0
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `P, `s0, `s0 };  // (s0==0) ? skip, pop s0
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// OR_B  ( |(-1)=-1; |(1)=-1 )
	i=i+1;   ram[i] = {  op_or_b,               `_, `_, `s1, `s0 };  // |s1=>s0
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `_, `P, `s1, `s0 };  // (s0==-1) ? skip, pop s0
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	i=i+1;   ram[i] = {  op_or_b,               `_, `_, `s2, `s0 };  // |s2=>s0
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `_, `P, `s1, `s0 };  // (s0==-1) ? skip, pop s0
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// XOR_B ( ^(-1)= 0; ^(1)=-1 )
	i=i+1;   ram[i] = {  op_xor_b,              `_, `_, `s1, `s0 };  // ^s1=>s0
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `P, `s0, `s0 };  // (s0==0) ? skip, pop s0
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	//
	i=i+1;   ram[i] = {  op_xor_b,              `_, `_, `s2, `s0 };  // ^s2=>s0
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `_, `P, `s1, `s0 };  // (s0==-1) ? skip, pop s0
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// clean up
	i=i+1;   ram[i] = {  op_pop,                `P, `P, `s2, `s1 };  // pop s2 & s1
	// load s1 & s2 values
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s1, `s1 };  // lit => s1
	i=i+1;   ram[i] = 16'ha53c                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s1, `s1 };  // lit => s1, pop combine
	i=i+1;   ram[i] = 16'h36c9                                    ;  // hi data
	//
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s2, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'hc396                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s2, `s2 };  // lit => s2, pop combine
	i=i+1;   ram[i] = 16'h5ca3                                    ;  // hi data
	// AND (s/b 'h1481,8114)
	i=i+1;   ram[i] = {  op_and,                `_, `_, `s2, `s1 };  // s1&s2=>s1
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'h8114                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s0, `s0 };  // lit => s0, pop combine
	i=i+1;   ram[i] = 16'h1481                                    ;  // hi data
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// OR  (s/b 'h7eeb,e7be)
	i=i+1;   ram[i] = {  op_or,                 `_, `_, `s2, `s1 };  // s1|s2=>s1
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'he7be                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s0, `s0 };  // lit => s0, pop combine
	i=i+1;   ram[i] = 16'h7eeb                                    ;  // hi data
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// XOR (s/b 'h6a6a,66aa)
	i=i+1;   ram[i] = {  op_xor,                `_, `_, `s2, `s1 };  // s1^s2=>s1
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'h66aa                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s0, `s0 };  // lit => s0, pop combine
	i=i+1;   ram[i] = 16'h6a6a                                    ;  // hi data
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// NOT (s/b 'hc936,5ac3)
	i=i+1;   ram[i] = {  op_not,                `_, `_, `s1, `s1 };  // ~s1=>s1
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'h5ac3                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s0, `s0 };  // lit => s0, pop combine
	i=i+1;   ram[i] = 16'hc936                                    ;  // hi data
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// check for no opcode errors
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h900                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `P, `s0, `s0 };  // (s0==0) ? skip, pop s0
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// check for no stack errors
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h910                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `P, `s0, `s0 };  // (s0==0) ? skip, pop s0
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// s3=>s0, loop forever
	i=i+1;   ram[i] = {  op_cpy,                `P, `_, `s3, `s0 };  // s3=>s0, pop s3
	i=i+1;   ram[i] = { `op_jmp_i,       -6'h1, `_, `_, `s0, `s0 };  // loop forever



	// test ALU arithmetic functions, result in s0
	// Correct functioning is s0 = 'd13 ('hd).
	//
	// s0 : final test result
	// s1 : test value
	// s2 : test value
	// s3 : running test result, subroutine return address
	//
	// setup running test result:
	i='h200; ram[i] = { `op_byt_i,        8'd0, `_, `_, `s0, `s3 };  // 0=>s3
	// load s1 & s2 values
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s1, `s1 };  // lit => s1
	i=i+1;   ram[i] = 16'h36c9                                    ;  // hi data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s1, `s1 };  // lit => s1, pop combine
	i=i+1;   ram[i] = 16'ha53c                                    ;  // lo data
	//
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s2, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'hc396                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s2, `s2 };  // lit => s2, pop combine
	i=i+1;   ram[i] = 16'h5ca3                                    ;  // hi data
	// ADD_I -32 (s/b 'ha53c,36a9)
	i=i+1;   ram[i] = { `op_add_i,      -6'd32, `_, `_, `s1, `s1 };  // s1-32=>s1
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'h36a9                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s0, `s0 };  // lit => s0, pop combine
	i=i+1;   ram[i] = 16'ha53c                                    ;  // hi data
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// ADD_I +31 (s/b 'ha53c,36e8)
	i=i+1;   ram[i] = { `op_add_i,       6'd31, `_, `_, `s1, `s1 };  // s1+31=>s1
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'h36e8                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s0, `s0 };  // lit => s0, pop combine
	i=i+1;   ram[i] = 16'ha53c                                    ;  // hi data
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// ADD (s/b 'h01df,fa5f)
	i=i+1;   ram[i] = {  op_add,                `_, `_, `s2, `s1 };  // s1+s2=>s1
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'hfa5f                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s0, `s0 };  // lit => s0, pop combine
	i=i+1;   ram[i] = 16'h01df                                    ;  // hi data
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// ADD_X (s/b 0)
	i=i+1;   ram[i] = {  op_add_x,              `_, `_, `s2, `s1 };  // s1+s2=>s1
	i=i+1;   ram[i] = { `op_byt_i,        8'h0, `_, `_, `s0, `s0 };  // 0 => s0
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// ADD_UX (s/b 1)
	i=i+1;   ram[i] = {  op_add_ux,             `_, `_, `s2, `s1 };  // s1+s2=>s1
	i=i+1;   ram[i] = { `op_byt_i,        8'h1, `_, `_, `s0, `s0 };  // 1 => s0
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// SUB (s/b 'h4898,7333)
	i=i+1;   ram[i] = {  op_sub,                `_, `_, `s2, `s1 };  // s1-s2=>s1
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'h7333                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s0, `s0 };  // lit => s0, pop combine
	i=i+1;   ram[i] = 16'h4898                                    ;  // hi data
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// SUB_X (s/b -1)
	i=i+1;   ram[i] = {  op_sub_x,              `_, `_, `s2, `s1 };  // s1-s2=>s1
	i=i+1;   ram[i] = { `op_byt_i,       -8'h1, `_, `_, `s0, `s0 };  // -1 => s0
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// SUB_UX (s/b 0)
	i=i+1;   ram[i] = {  op_sub_ux,             `_, `_, `s2, `s1 };  // s1-s2=>s1
	i=i+1;   ram[i] = { `op_byt_i,        8'h0, `_, `_, `s0, `s0 };  // 0 => s0
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// MUL (s/b 'hccfe,34c6)
	i=i+1;   ram[i] = {  op_mul,                `_, `_, `s2, `s1 };  // s1*s2=>s1
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'h34c6                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s0, `s0 };  // lit => s0, pop combine
	i=i+1;   ram[i] = 16'hccfe                                    ;  // hi data
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// MUL_X (s/b 'hdf27,93ae)
	i=i+1;   ram[i] = {  op_mul_x,              `_, `_, `s2, `s1 };  // s1*s2=>s1
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'h93ae                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s0, `s0 };  // lit => s0, pop combine
	i=i+1;   ram[i] = 16'hdf27                                    ;  // hi data
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// MUL_UX (s/b 'h3bcb,5744)
	i=i+1;   ram[i] = {  op_mul_ux,             `_, `_, `s2, `s1 };  // s1*s2=>s1
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'h5744                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s0, `s0 };  // lit => s0, pop combine
	i=i+1;   ram[i] = 16'h3bcb                                    ;  // hi data
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// check for no opcode errors
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h900                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `P, `s0, `s0 };  // (s0==0) ? skip, pop s0
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// check for no stack errors
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h910                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `P, `s0, `s0 };  // (s0==0) ? skip, pop s0
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// s3=>s0, loop forever
	i=i+1;   ram[i] = {  op_cpy,                `P, `_, `s3, `s0 };  // s3=>s0, pop s3
	i=i+1;   ram[i] = { `op_jmp_i,       -6'h1, `_, `_, `s0, `s0 };  // loop forever


	// test ALU shift functions, result in s0
	// Correct functioning is s0 = 'd10 ('ha).
	//
	// s0 : final test result
	// s1 : test value
	// s2 : test value
	// s3 : running test result, subroutine return address
	//
	// setup running test result:
	i='h300; ram[i] = { `op_byt_i,        8'd0, `_, `_, `s0, `s3 };  // 0=>s3
	// load s1 value 0xa53c36c9
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s1, `s1 };  // lit => s1
	i=i+1;   ram[i] = 16'h36c9                                    ;  // hi data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s1, `s1 };  // lit => s1, pop combine
	i=i+1;   ram[i] = 16'ha53c                                    ;  // lo data
	// SHL_I -28 (s/b 'hffff,fffa)
	i=i+1;   ram[i] = { `op_shl_i,      -6'd28, `_, `_, `s1, `s1 };  // s1<<-28=>s1
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'hfffa                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s0, `s0 };  // lit => s0, pop combine
	i=i+1;   ram[i] = 16'hffff                                    ;  // hi data
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// SHL_I +28 (s/b 'h9000,0000)
	i=i+1;   ram[i] = { `op_shl_i,       6'd28, `_, `_, `s1, `s1 };  // s1<<28=>s1
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'h0000                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s0, `s0 };  // lit => s0, pop combine
	i=i+1;   ram[i] = 16'h9000                                    ;  // hi data
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// SHL_IU -28 (s/b 'h0000,000a)
	i=i+1;   ram[i] = { `op_shl_iu,     -6'd28, `_, `_, `s1, `s1 };  // s1<<-28=>s1
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'h000a                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s0, `s0 };  // lit => s0, pop combine
	i=i+1;   ram[i] = 16'h0000                                    ;  // hi data
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// SHL_IU +28 (s/b 'h1000,0000)
	i=i+1;   ram[i] = { `op_shl_iu,      6'd28, `_, `_, `s1, `s1 };  // 1<<28=>s1
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'h0000                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s0, `s0 };  // lit => s0, pop combine
	i=i+1;   ram[i] = 16'h1000                                    ;  // hi data
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// SHL -4 (s/b 'hfa53,c36c)
	i=i+1;   ram[i] = { `op_byt_i,       -8'd4, `_, `_, `s2, `s2 };  // -4=>s2
	i=i+1;   ram[i] = {  op_shl,                `P, `_, `s2, `s1 };  // s1<<s2=>s1, pop s2
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'hc36c                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s0, `s0 };  // lit => s0, pop combine
	i=i+1;   ram[i] = 16'hfa53                                    ;  // hi data
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// SHL +4 (s/b 'h53c3,6c90)
	i=i+1;   ram[i] = { `op_byt_i,        8'd4, `_, `_, `s2, `s2 };  // 4=>s2
	i=i+1;   ram[i] = {  op_shl,                `P, `_, `s2, `s1 };  // s1<<s2=>s1, pop s2
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'h6c90                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s0, `s0 };  // lit => s0, pop combine
	i=i+1;   ram[i] = 16'h53c3                                    ;  // hi data
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// SHL_U -4 (s/b 'h0a53,c36c)
	i=i+1;   ram[i] = { `op_byt_i,       -8'd4, `_, `_, `s2, `s2 };  // -4=>s2
	i=i+1;   ram[i] = {  op_shl_u,              `P, `_, `s2, `s1 };  // s1<<s2=>s1, pop s2
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'hc36c                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s0, `s0 };  // lit => s0, pop combine
	i=i+1;   ram[i] = 16'h0a53                                    ;  // hi data
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// SHL +4 (s/b 'h0000,0010)
	i=i+1;   ram[i] = { `op_byt_i,        8'd4, `_, `_, `s2, `s2 };  // 4=>s2
	i=i+1;   ram[i] = {  op_shl_u,              `P, `_, `s2, `s1 };  // 1<<s2=>s1, pop s2
	i=i+1;   ram[i] = {  op_lit,                `_, `_, `s0, `s0 };  // lit => s0
	i=i+1;   ram[i] = 16'h0010                                    ;  // lo data
	i=i+1;   ram[i] = {  op_lit_x,              `_, `P, `s0, `s0 };  // lit => s0, pop combine
	i=i+1;   ram[i] = 16'h0000                                    ;  // hi data
	i=i+1;   ram[i] = { `op_jmp_ie,       5'd1, `P, `P, `s1, `s0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// check for no opcode errors
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h900                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `P, `s0, `s0 };  // (s0==0) ? skip, pop s0
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// check for no stack errors
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h910                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `op_jmp_iez,      5'd1, `_, `P, `s0, `s0 };  // (s0==0) ? skip, pop s0
	i=i+1;   ram[i] = { `op_add_i,       -6'd2, `_, `P, `s0, `s3 };  // s3-2=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3+1=>s3, pop s3
	// s3=>s0, loop forever
	i=i+1;   ram[i] = {  op_cpy,                `P, `_, `s3, `s0 };  // s3=>s0, pop s3
	i=i+1;   ram[i] = { `op_jmp_i,       -6'h1, `_, `_, `s0, `s0 };  // loop forever




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
