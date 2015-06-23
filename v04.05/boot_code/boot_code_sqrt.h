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

	// Square root
	// Thread 0 : Get input 32 bit GPIO, calculate square root, output 32 bit GPIO.
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
	// do s0=sqrt(s0)
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


	// sub : s0=sqrt(s0), return to (s7)
	//
	// input is unsigned 32 integer
	// output is unsigned 16.16 integer
	//
	// algorithm: binary search
	// iterate 32 times
	//
	// s0 : input (x), output (Q)
	// s1 : running q
	// s2 : temp: q^2 + q
	// s3 : 
	// s4 : 
	// s5 : 
	// s6 : one-hot (& loop test)
	// s7 : sub return address
	//
	// loop setup
	i='h90;  ram[i] = { `dat_is,          6'd0, `s1 };  // s1=0 (init Q)
	i=i+1;   ram[i] = { `psu_i,         6'd31, `s6 };  // s6 MSB=1 (init OH)
	// loop start
	i=i+1;   ram[i] = { `add,              `s6, `P1 };  // s1+=s6
	i=i+1;   ram[i] = { `mul_xu,           `s1, `s1 };  // s1=s1*s1 (square, integer portion)
	// jump start
	i=i+1;   ram[i] = { `jmp_ilu,    4'd1, `s0, `P1 };  // (s1<s0) ? jump 1  pop s1 (skip restore)
	i=i+1;   ram[i] = { `sub,              `s6, `P1 };  // s1-=s6 (restore)
	// jump end
	i=i+1;   ram[i] = { `psu_i,          -6'd1, `P6 };  // s6>>=1 (new OH)
	i=i+1;   ram[i] = { `jmp_inz,        -6'd6, `s6 };  // (s6!=0) ? do again
	// loop end
	i=i+1;   ram[i] = { `mul_xu,           `s1, `s1 };  // s1=s1*s1 (square, integer portion)
	i=i+1;   ram[i] = { `sub,              `P1, `P0 };  // s0-=s1, pop s1 : x -= q^2
	i=i+1;   ram[i] = { `add,              `s1, `P0 };  // s0+=s1 : Q = q + x - q^2
	i=i+1;   ram[i] = { `mul,              `s1, `s1 };  // s1=s1*s1 (square, decimal portion) : (q>>n)^2
	i=i+1;   ram[i] = { `cpy,              `P1, `s2 };  // s2=s1, move
	i=i+1;   ram[i] = { `add_xu,           `P1, `P2 };  // s2+=s1 (carry out, integer portion), pop s1 : int[q>>n + (q>>n)^2]
	i=i+1;   ram[i] = { `sub,              `P2, `P0 };  // s0+=s2, pop s2 : Q = q + (x - q^2) - int[q>>n + (q>>n)^2]
	i=i+1;   ram[i] = { `gto,              `P7, `P6 };  // return, pop s7 & s6
	// end sub

	end
