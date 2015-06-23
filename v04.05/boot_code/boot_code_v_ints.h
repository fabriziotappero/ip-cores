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


	// Thread 0 : enable interrupts
	// All threads : output thread ID @ interrupt

	///////////////
	// clr space //
	///////////////

	// thread 0 : enable interrupts & loop forever
	i='h0;   ram[i] = { `lit_u,            `__, `s3 };  // s3='h0100
	i=i+1;   ram[i] =                      16'h0100  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P3, `s3 };  // gsb, pop s3
	i=i+1;   ram[i] = { `jmp_ie,    -4'd1, `s0, `s0 };  // loop forever
	// all others : loop forever
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

	// all threads : read and output thread ID
	i='h20;  ram[i] = { `lit_u,            `__, `s3 };  // s3='h0110
	i=i+1;   ram[i] =                      16'h0110  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P3, `s3 };  // gsb, pop s3 (addr)
	i=i+1;   ram[i] = { `gto,              `P0, `__ };  // return, pop s0
	//
	i='h24;  ram[i] = { `lit_u,            `__, `s3 };  // s3='h0110
	i=i+1;   ram[i] =                      16'h0110  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P3, `s3 };  // gsb, pop s3 (addr)
	i=i+1;   ram[i] = { `gto,              `P0, `__ };  // return, pop s0
	//
	i='h28;  ram[i] = { `lit_u,            `__, `s3 };  // s3='h0110
	i=i+1;   ram[i] =                      16'h0110  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P3, `s3 };  // gsb, pop s3 (addr)
	i=i+1;   ram[i] = { `gto,              `P0, `__ };  // return, pop s0
	//
	i='h2c;  ram[i] = { `lit_u,            `__, `s3 };  // s3='h0110
	i=i+1;   ram[i] =                      16'h0110  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P3, `s3 };  // gsb, pop s3 (addr)
	i=i+1;   ram[i] = { `gto,              `P0, `__ };  // return, pop s0
	//
	i='h30;  ram[i] = { `lit_u,            `__, `s3 };  // s3='h0110
	i=i+1;   ram[i] =                      16'h0110  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P3, `s3 };  // gsb, pop s3 (addr)
	i=i+1;   ram[i] = { `gto,              `P0, `__ };  // return, pop s0
	//
	i='h34;  ram[i] = { `lit_u,            `__, `s3 };  // s3='h0110
	i=i+1;   ram[i] =                      16'h0110  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P3, `s3 };  // gsb, pop s3 (addr)
	i=i+1;   ram[i] = { `gto,              `P0, `__ };  // return, pop s0
	//
	i='h38;  ram[i] = { `lit_u,            `__, `s3 };  // s3='h0110
	i=i+1;   ram[i] =                      16'h0110  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P3, `s3 };  // gsb, pop s3 (addr)
	i=i+1;   ram[i] = { `gto,              `P0, `__ };  // return, pop s0
	//
	i='h3c;  ram[i] = { `lit_u,            `__, `s3 };  // s3='h0110
	i=i+1;   ram[i] =                      16'h0110  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P3, `s3 };  // gsb, pop s3 (addr)
	i=i+1;   ram[i] = { `gto,              `P0, `__ };  // return, pop s0



	///////////////////////
	// code & data space //
	///////////////////////



	/////////////////
	// subroutines //
	/////////////////


	// sub : enable all ints, return to (s3)
	i='h100; ram[i] = { `dat_is,      `INTR_EN, `s1 };  // s1=reg addr
	i=i+1;   ram[i] = { `dat_is,         -6'd1, `s0 };  // s0=-1
	i=i+1;   ram[i] = { `reg_w,            `P1, `P0 };  // (s1)=s0, pop both
	i=i+1;   ram[i] = { `gto,              `P3, `__ };  // return, pop s3

	// sub : read thread ID & write to GPIO, return to (s3)
	i='h110; ram[i] = { `dat_is,      `THRD_ID, `s1 };  // s1=reg addr
	i=i+1;   ram[i] = { `reg_rs,           `P1, `s0 };  // s0=(s1), pop s1
	i=i+1;   ram[i] = { `dat_is,        `IO_LO, `s1 };  // s1=reg addr
	i=i+1;   ram[i] = { `reg_w,            `P1, `P0 };  // (s1)=s0, pop both
	i=i+1;   ram[i] = { `gto,              `P3, `__ };  // return, pop s3


	end
