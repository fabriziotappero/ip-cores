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
	`include "boot_code_defs.h"
	`include "op_encode.h"
	`include "reg_set_addr.h"
	
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
	// do s0=exp2(s0)
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



	// sub : s0=exp2(s0), return to (s7)
	//
	// input is c[31:27].m[26:0] unsigned fixed decimal
	// output is out[31:0] an unsigned 32 bit integer
	//
	// s0 : input, output
	// s1 : running multiply
	// s2 : running root
	// s3 : fudge factor
	// s4 :
	// s5 :
	// s6 : loop index
	// s7 : sub return addr
	//
	// setup
	i='h90;  ram[i] = { `flp,              `s0, `P0 };  // flp(s0) (to examine lsbs via msb)
	i=i+1;   ram[i] = { `psu_i,          6'd31, `s1 };  // s1=0x8000,0000 (starting value = 1)
	i=i+1;   ram[i] = { `cpy,              `s1, `s2 };  // s2=0x8000,000b (starting root = 2^2^-27)
	i=i+1;   ram[i] = { `add_is,          6'hb, `P2 };  // 
	i=i+1;   ram[i] = { `lit_u,            `__, `s3 };  // s3=0x173c,e500 (fudge factor bits)
	i=i+1;   ram[i] =                      16'he500  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P3 };  //
	i=i+1;   ram[i] =                      16'h173c  ;  //
	i=i+1;   ram[i] = { `dat_is,         6'd26, `s6 };  // s6=26 (loop index)
	// loop start
	// jump 0 start
	i=i+1;   ram[i] = { `jmp_inlz,        6'd2, `s0 };  // (s0[31]==0) ? jump +2 (skip running mult)
	i=i+1;   ram[i] = { `mul_xu,           `s2, `P1 };  // s1*=s2
	i=i+1;   ram[i] = { `shl_is,          6'd1, `P1 };  // s1<<=1 (so msb=1)
	// jump 0 end
	i=i+1;   ram[i] = { `mul_xu,           `s2, `P2 };  // s2*=s2 (square to get next root)
	i=i+1;   ram[i] = { `shl_is,          6'd1, `P2 };  // s2<<=1 (so msb=1 & lsb=0)
	// jump 1 start
	i=i+1;   ram[i] = { `jmp_inlz,        6'd1, `s3 };  // (s3[31]==0) ? jump +1 (no fudge bit)
	i=i+1;   ram[i] = { `add_is,          6'd1, `P2 };  // s2++ (set lsb of running root)
	// jump 1 end
	i=i+1;   ram[i] = { `shl_is,          6'd1, `P0 };  // s0<<=1 (get next input bit)
	i=i+1;   ram[i] = { `shl_is,          6'd1, `P3 };  // s2<<=1 (get next fudge bit)
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P6 };  // s6-- (loop index--)
	i=i+1;   ram[i] = { `jmp_inlz,      -6'd11, `s6 };  // (s6>=0) ? jump -11 (loop again)
	// loop end
	// final shift
	i=i+1;   ram[i] = { `flp,              `s0, `P0 };  // flp(s0) (flip remaining bits)
	i=i+1;   ram[i] = { `add_is,        -6'd31, `P0 };  // s0-=31
	i=i+1;   ram[i] = { `shl_u,            `P0, `P1 };  // s1<<=s0, pop s0
	// cleanup, return
	i=i+1;   ram[i] = { `cpy,              `P1, `s0 };  // s0=s1, pop s1 (move)
	i=i+1;   ram[i] = { `pop,           8'b01000110 };  // pop s2, s3, s6
	i=i+1;   ram[i] = { `gto,              `P7, `__ };  // return, pop s7
	// end sub

	end
