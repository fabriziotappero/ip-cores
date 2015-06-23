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


	/*
	------------
	-- TEST 0 --
	------------
	*/

	// Divide - restoring, both inputs positive.
	// Thread 0 : Get input 32 bit GPIO 2x, divide, output 32 bit GPIO 2x.
	// Other threads : do nothing, loop forever

	///////////////
	// clr space //
	///////////////

	i='h0;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s1 };  // lit => s1
	i=i+1;   ram[i] = 16'h040                                     ;  // addr
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s1, `s0 };  // goto, pop s1 (addr)
	//
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

	// read 32 bit GPIO data to s0
	i='h40;  ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h060                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)

	// write s0 data to 32 bit GPIO
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h068                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)

	// read 32 bit GPIO data to s0
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h060                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)

	// write s0 data to 32 bit GPIO
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h068                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)

	// do s0/s1 divide
	i=i+1;   ram[i] = {  op_cpy,                `P, `_, `s0, `s1 };  // s0=>s1, pop s0
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h070                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)

	// write s0 data to 32 bit GPIO
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h068                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)

	// write s1 data to 32 bit GPIO
	i=i+1;   ram[i] = {  op_cpy,                `P, `P, `s1, `s0 };  // s1=>s0, pop both
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s2 };  // lit => s2
	i=i+1;   ram[i] = 16'h068                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s2, `s3 };  // gsb, pop s2 (addr)

	// loop forever
	i=i+1;   ram[i] = { `op_jmp_i,       -5'h1, `_, `_, `s0, `s0 };  // loop forever




	// sub : read 32 bit GPIO => s0, return to (s3)
	i='h60;  ram[i] = {  op_lit_u,              `_, `_, `s0, `s1 };  // lit => s1
	i=i+1;   ram[i] = REG_BASE_ADDR                               ;  // reg base addr
	i=i+1;   ram[i] = { `op_rd_i,   IO_LO_ADDR, `_, `_, `s1, `s0 };  // read (s1+offset) => s0
	i=i+1;   ram[i] = { `op_rd_ix,  IO_HI_ADDR, `P, `P, `s1, `s0 };  // read (s1+offset) => s0, pop s1 & s0
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s3, `s0 };  // return, pop s3


	// sub : write s0 => 32 bit GPIO, return to (s3)
	i='h68;  ram[i] = {  op_lit_u,              `_, `_, `s0, `s1 };  // lit => s1
	i=i+1;   ram[i] = REG_BASE_ADDR                               ;  // reg base addr
	i=i+1;   ram[i] = { `op_wr_i,   IO_LO_ADDR, `_, `_, `s1, `s0 };  // write s0 => (s1+offset)
	i=i+1;   ram[i] = { `op_wr_ix,  IO_HI_ADDR, `P, `_, `s1, `s0 };  // write s0 => (s1+offset), pop s1
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s3, `s0 };  // return, pop s3


	// sub : divide s0/s1 => result in s0, remainder in s1, return to (s3)
	//
	// s0 : A input, A/B output
	// s1 : B input, A%B output
	// s2 : loop index
	// s3 : subroutine return address, A%B
	//
	// 0 input s1 is an error, return
	i='h70;  ram[i] = { `op_jmp_iglz,    5'd1,  `_, `_, `s0, `s1 };  // (s1!==0) ? skip return
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s3, `s0 };  // return to (s3), pop s3
	// loop setup
	i=i+1;   ram[i] = { `op_byt_i,       8'd32, `_, `_, `s0, `s2 };  // 32=>s2
	i=i+1;   ram[i] = { `op_byt_i,        8'd0, `_, `_, `s0, `s3 };  // 0=>s3
	// divide loop
	i=i+1;   ram[i] = { `op_add_i,       -6'd1, `_, `P, `s0, `s2 };  // s2--=>s2, pop s2
	i=i+1;   ram[i] = { `op_shl_i,        6'd1, `_, `P, `s0, `s3 };  // s3<<1=>s3, pop s3
	i=i+1;   ram[i] = { `op_jmp_igez,     5'd1, `_, `_, `s0, `s0 };  // (s0[31]==0) ? skip
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s3 };  // s3++=>s3, pop s3
	i=i+1;   ram[i] = { `op_shl_i,        6'd1, `_, `P, `s0, `s0 };  // s0<<1=>s0, pop s0
	i=i+1;   ram[i] = { `op_jmp_iug,      5'd2, `_, `_, `s3, `s1 };  // (s1u>s3) ? jump
	i=i+1;   ram[i] = {  op_sub,                `_, `P, `s1, `s3 };  // s3-s1=>s3, pop s3
	i=i+1;   ram[i] = { `op_add_i,        6'd1, `_, `P, `s0, `s0 };  // s0++=>s0, pop s0
	i=i+1;   ram[i] = { `op_jmp_igz,     -5'd9, `_, `_, `s0, `s2 };  // (s2>0) ? do again
	// s3=>s1; cleanup, return
	i=i+1;   ram[i] = {  op_cpy,                `P, `P, `s3, `s1 };  // s3=>s1, pop both
	i=i+1;   ram[i] = {  op_gto,                `P, `P, `s3, `s2 };  // return to (s3), pop s3 & s2
	// end sub

	
	end
