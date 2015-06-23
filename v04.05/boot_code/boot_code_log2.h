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
		ram[i] = { `nop, `s0, `s0 };
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

	// Log base 2
	// Thread 0 : Get input 32 bit GPIO, calculate log2, output 32 bit GPIO.
	// Other threads : do nothing, loop forever

	///////////////
	// clr space //
	///////////////

	i='h0;   ram[i] = { `lit_u,            `__, `s1 };  // s1=addr
	i=i+1;   ram[i] =                      16'h0040  ;  // 
	i=i+1;   ram[i] = { `gto,              `P1, `__ };  // goto, pop s1 (addr)
	//
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

	// read & write 32 bit GPIO data to & from s0
	i='h40;  ram[i] = { `lit_u,            `__, `s3 };  // s3=addr
	i=i+1;   ram[i] =                      16'h0080  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P3, `s3 };  // gsb, pop s3 (addr)
	// do s0=log2(s0)
	i=i+1;   ram[i] = { `lit_u,            `__, `s3 };  // s3=addr
	i=i+1;   ram[i] =                      16'h0090  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P3, `s7 };  // gsb, pop s3 (addr)
	// write s0 data to 32 bit GPIO
	i=i+1;   ram[i] = { `lit_u,            `__, `s3 };  // s3=addr
	i=i+1;   ram[i] =                      16'h0070  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P3, `s3 };  // gsb, pop s3 (addr)
	// loop forever
	i=i+1;   ram[i] = { `jmp_ie,    -4'd1, `s0, `s0 };  // loop forever


	// sub : read 32 bit GPIO => s0, return to (s3)
	i='h60;  ram[i] = { `dat_is,        `IO_LO, `s1 };  // s1=reg addr
	i=i+1;   ram[i] = { `reg_rs,           `P1, `s0 };  // s0=(s1), pop s1
	i=i+1;   ram[i] = { `dat_is,        `IO_HI, `s1 };  // s1=reg addr
	i=i+1;   ram[i] = { `reg_rh,           `P1, `P0 };  // s0=(s1), pop both
	i=i+1;   ram[i] = { `gto,              `P3, `__ };  // return, pop s3


	// sub : write s0 => 32 bit GPIO, return to (s3)
	i='h70;  ram[i] = { `dat_is,        `IO_LO, `s1 };  // s1=reg addr
	i=i+1;   ram[i] = { `reg_w,            `P1, `s0 };  // (s1)=s0, pop s1
	i=i+1;   ram[i] = { `dat_is,        `IO_HI, `s1 };  // s1=reg addr
	i=i+1;   ram[i] = { `reg_wh,           `P1, `s0 };  // (s1)=s0, pop s1
	i=i+1;   ram[i] = { `gto,              `P3, `__ };  // return, pop s3


	// sub : read & write 32 bit GPIO => s0, return to (s3)
	i='h80;  ram[i] = { `dat_is,        `IO_LO, `s1 };  // s1=reg addr
	i=i+1;   ram[i] = { `reg_rs,           `s1, `s0 };  // s0=(s1)
	i=i+1;   ram[i] = { `reg_w,            `P1, `s0 };  // (s1)=s0, pop s1
	i=i+1;   ram[i] = { `dat_is,        `IO_HI, `s1 };  // s1=reg addr
	i=i+1;   ram[i] = { `reg_rh,           `s1, `P0 };  // s0=(s1), pop s0
	i=i+1;   ram[i] = { `reg_wh,           `P1, `s0 };  // (s1)=s0, pop s1
	i=i+1;   ram[i] = { `gto,              `P3, `__ };  // return, pop s3



	// sub : s0=log2(s0), return to (s7)
	//
	// input is in[31:0] an unsigned 32 bit integer
	// output is c[31:27].m[26:0] unsigned fixed decimal
	//
	// s0 : input, normalize, square, output
	// s1 : lzc, result
	// s2 : 
	// s3 : 
	// s4 : 
	// s5 : 
	// s6 : loop index
	// s7 : sub return address
	//
	// (input=0)? is an error, return
	i='h90;  ram[i] = { `jmp_inz,         6'd1, `s0 };  // (s0!=0) ? skip return
	i=i+1;   ram[i] = { `gto,              `P7, `__ };  // return to (s7), pop s7
	// normalize
	i=i+1;   ram[i] = { `lzc,              `s0, `s1 };  // s1=lzc(s0)
	i=i+1;   ram[i] = { `shl_s,            `s1, `P0 };  // s0<<=s1 (normalize)
	// loop setup
	i=i+1;   ram[i] = { `dat_is,         6'd26, `s6 };  // s6=26 (loop index)
	// loop start
	i=i+1;   ram[i] = { `mul_xu,           `s0, `P0 };  // s0*=s0
	i=i+1;   ram[i] = { `shl_is,          6'd1, `P1 };  // s1<<=1
	// jump start
	i=i+1;   ram[i] = { `jmp_ilz,         6'd2, `s0 };  // (s0[31]==1) ? jump
	i=i+1;   ram[i] = { `shl_is,          6'd1, `P0 };  // s0<<=1
	i=i+1;   ram[i] = { `add_is,          6'd1, `P1 };  // s1++
	// jump end
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P6 };  // s6--
	i=i+1;   ram[i] = { `jmp_inlz,       -6'd7, `s6 };  // (s6>=0) ? do again
	// loop end
	// cleanup, return
	i=i+1;   ram[i] = { `not,              `P1, `P0 };  // s0=~s1, pop both
	i=i+1;   ram[i] = { `gto,              `P7, `P6 };  // return, pop s7 & s6
	// end sub

	end
