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


	// Thread 0 : enable interrupts
	// All threads : output thread ID @ interrupt

	///////////////
	// clr space //
	///////////////

	// thread 0 : enable interrupts & loop forever
	i='h0;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s3 };  // lit => s3
	i=i+1;   ram[i] = 16'h100                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s3, `s3 };  // gsb, pop s3 (addr)
	i=i+1;   ram[i] = { `op_jmp_i,       -6'h1, `_, `_, `s0, `s0 };  // loop forever
	// all others : loop forever
	i='h4;   ram[i] = { `op_jmp_i,       -6'h1, `_, `_, `s0, `s0 };  // loop forever
	i=i+4;   ram[i] = { `op_jmp_i,       -6'h1, `_, `_, `s0, `s0 };  // loop forever
	i=i+4;   ram[i] = { `op_jmp_i,       -6'h1, `_, `_, `s0, `s0 };  // loop forever
	i=i+4;   ram[i] = { `op_jmp_i,       -6'h1, `_, `_, `s0, `s0 };  // loop forever
	i=i+4;   ram[i] = { `op_jmp_i,       -6'h1, `_, `_, `s0, `s0 };  // loop forever
	i=i+4;   ram[i] = { `op_jmp_i,       -6'h1, `_, `_, `s0, `s0 };  // loop forever
	i=i+4;   ram[i] = { `op_jmp_i,       -6'h1, `_, `_, `s0, `s0 };  // loop forever

	////////////////
	// intr space //
	////////////////

	// all threads : read and output thread ID
	i='h20;  ram[i] = {  op_lit_u,              `_, `_, `s0, `s3 };  // lit => s3
	i=i+1;   ram[i] = 16'h110                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s3, `s3 };  // gsb, pop s3 (addr)
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s3, `s0 };  // return, pop s3
	//
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s3 };  // lit => s3
	i=i+1;   ram[i] = 16'h110                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s3, `s3 };  // gsb, pop s3 (addr)
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s3, `s0 };  // return, pop s3
	//
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s3 };  // lit => s3
	i=i+1;   ram[i] = 16'h110                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s3, `s3 };  // gsb, pop s3 (addr)
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s3, `s0 };  // return, pop s3
	//
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s3 };  // lit => s3
	i=i+1;   ram[i] = 16'h110                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s3, `s3 };  // gsb, pop s3 (addr)
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s3, `s0 };  // return, pop s3
	//
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s3 };  // lit => s3
	i=i+1;   ram[i] = 16'h110                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s3, `s3 };  // gsb, pop s3 (addr)
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s3, `s0 };  // return, pop s3
	//
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s3 };  // lit => s3
	i=i+1;   ram[i] = 16'h110                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s3, `s3 };  // gsb, pop s3 (addr)
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s3, `s0 };  // return, pop s3
	//
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s3 };  // lit => s3
	i=i+1;   ram[i] = 16'h110                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s3, `s3 };  // gsb, pop s3 (addr)
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s3, `s0 };  // return, pop s3
	//
	i=i+1;   ram[i] = {  op_lit_u,              `_, `_, `s0, `s3 };  // lit => s3
	i=i+1;   ram[i] = 16'h110                                     ;  // addr
	i=i+1;   ram[i] = {  op_gsb,                `P, `_, `s3, `s3 };  // gsb, pop s3 (addr)
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s3, `s0 };  // return, pop s3

	///////////////////////
	// code & data space //
	///////////////////////



	/////////////////
	// subroutines //
	/////////////////


	// sub : enable all ints, return to (s3)
	i='h100; ram[i] = {  op_lit_u,              `_, `_, `s0, `s1 };  // lit => s1
	i=i+1;   ram[i] = REG_BASE_ADDR                               ;  // reg base addr
	i=i+1;   ram[i] = { `op_byt_i,       -8'd1, `_, `_, `s0, `s0 };  // -1=>s0
	i=i+1;   ram[i] = { `op_wr_i, INTR_EN_ADDR, `P, `P, `s1, `s0 };  // write s0 => (s1+offset), pop both
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s3, `s0 };  // return, pop s3

	// sub : read thread ID, write to GPIO, pop, return to (s3)
	i='h110; ram[i] = {  op_lit_u,              `_, `_, `s0, `s1 };  // lit => s1
	i=i+1;   ram[i] = REG_BASE_ADDR                               ;  // reg base addr
	i=i+1;   ram[i] = { `op_rd_i, THRD_ID_ADDR, `_, `_, `s1, `s0 };  // read (s1+offset) => s0, pop s1
	i=i+1;   ram[i] = { `op_wr_i,   IO_LO_ADDR, `P, `P, `s1, `s0 };  // write s0 => (s1+offset), pop both
	i=i+1;   ram[i] = {  op_gto,                `P, `_, `s3, `s0 };  // return, pop s3


	end
