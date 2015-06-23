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


	// Thread 0 : test ALU logical functions
	// Thread 1 : test ALU arithmetic functions
	// Thread 2 : test ALU shift functions
	// All other threads : loop forever

	///////////////
	// clr space //
	///////////////

	// thread 0
	i='h00;  ram[i] = { `lit_u,            `__, `s2 };  // s2=dat
	i=i+1;   ram[i] =                      16'h0100  ;  // addr
	i=i+1;   ram[i] = { `gto,              `P2, `__ };  // goto, pop s2 (addr)
	// thread 1
	i='h04;  ram[i] = { `lit_u,            `__, `s2 };  // s2=dat
	i=i+1;   ram[i] =                      16'h0200  ;  // addr
	i=i+1;   ram[i] = { `gto,              `P2, `__ };  // goto, pop s2 (addr)
	// thread 2
	i='h08;  ram[i] = { `lit_u,            `__, `s2 };  // s2=dat
	i=i+1;   ram[i] =                      16'h0300  ;  // addr
	i=i+1;   ram[i] = { `gto,              `P2, `__ };  // goto, pop s2 (addr)
	// and the rest (are here on Gilligan's Isle)
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


	// test ALU logical functions, result in s0
	// Correct functioning is s0 = 'd14 ('he).
	//
	// s0 : final test result
	// s1 : test value
	// s2 : test value
	// s3 : running test result, subroutine return address
	//
	// setup running test result:
	i='h100; ram[i] = { `dat_is,          6'd0, `s3 };  // s3=0
	// load s1 & s2 values
	i=i+1;   ram[i] = { `dat_is,          6'd1, `s1 };  // s1=1
	i=i+1;   ram[i] = { `dat_is,         -6'd1, `s2 };  // s2=-1
	// BRA ( &(1)= 0; &(-1)=-1 )
	i=i+1;   ram[i] = { `bra,              `s1, `s0 };  // s0=&s1
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P0 };  // (s0==0) ? skip, pop s0
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	//
	i=i+1;   ram[i] = { `bra,              `s2, `s0 };  // s0=&s2
	i=i+1;   ram[i] = { `jmp_inz,         6'd1, `P0 };  // (s0!=0) ? skip, pop s0
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// BRO  ( |(1)=-1; |(-1)=-1 )
	i=i+1;   ram[i] = { `bro,              `s1, `s0 };  // s0=|s1
	i=i+1;   ram[i] = { `jmp_inz,         6'd1, `P0 };  // (s0!=0) ? skip, pop s0
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	//
	i=i+1;   ram[i] = { `bro,              `s2, `s0 };  // s0=|s2
	i=i+1;   ram[i] = { `jmp_inz,         6'd1, `P0 };  // (s0!=0) ? skip, pop s0
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// BRX ( ^(1)=-1; ^(-1)=0 )
	i=i+1;   ram[i] = { `brx,              `s1, `s0 };  // s0=^s1
	i=i+1;   ram[i] = { `jmp_inz,         6'd1, `P0 };  // (s0!=0) ? skip, pop s0
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	//
	i=i+1;   ram[i] = { `brx,              `s2, `s0 };  // s0=^s2
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P0 };  // (s0==0) ? skip, pop s0
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// clean up
	i=i+1;   ram[i] = { `pop,           8'b00000110 };  // pop s2 & s1
	// load s1 & s2 values
	i=i+1;   ram[i] = { `lit_u,            `__, `s1 };  // s1='h36c9,a53c
	i=i+1;   ram[i] =                      16'ha53c  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P1 };  // 
	i=i+1;   ram[i] =                      16'h36c9  ;  // 
	//
	i=i+1;   ram[i] = { `lit_u,            `__, `s2 };  // s2='h5ca3,c396
	i=i+1;   ram[i] =                      16'hc396  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P2 };  // 
	i=i+1;   ram[i] =                      16'h5ca3  ;  // 
	// AND (s/b 'h1481,8114)
	i=i+1;   ram[i] = { `and,              `s2, `s1 };  // s1=s1&s2
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='h1481,8114
	i=i+1;   ram[i] =                      16'h8114  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'h1481  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// OR  (s/b 'h7eeb,e7be)
	i=i+1;   ram[i] = { `orr,              `s2, `s1 };  // s1=s1|s2
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='h7eeb,e7be
	i=i+1;   ram[i] =                      16'he7be  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'h7eeb  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// XOR (s/b 'h6a6a,66aa)
	i=i+1;   ram[i] = { `xor,              `s2, `s1 };  // s1=s1^s2
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='h6a6a,66aa
	i=i+1;   ram[i] =                      16'h66aa  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'h6a6a  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// NOT (s/b 'hc936,5ac3)
	i=i+1;   ram[i] = { `not,              `s1, `s1 };  // s1=~s1
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='hc936,5ac3
	i=i+1;   ram[i] =                      16'h5ac3  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'hc936  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// FLP (s/b 'h3ca5,936c)
	i=i+1;   ram[i] = { `flp,              `s1, `s1 };  // s1=flip(s1)
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='h3ca5,936c
	i=i+1;   ram[i] =                      16'h936c  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'h3ca5  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// LZC (s/b 'h0000,0002)
	i=i+1;   ram[i] = { `lzc,              `s1, `s1 };  // s1=lzc(s1)
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='h0000,0002
	i=i+1;   ram[i] =                      16'h0002  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'h0000  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// check for no opcode errors
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7='h0900
	i=i+1;   ram[i] =                      16'h0900  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr)
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P4 };  // (s4==0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// check for no stack errors
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7='h0910
	i=i+1;   ram[i] =                      16'h0910  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr)
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P4 };  // (s4==0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// copy result to s0
	i=i+1;   ram[i] = { `cpy,              `P3, `s0 };  // s0=s3, pop s3
	// loop forever
	i=i+1;   ram[i] = { `jmp_ie,    -4'd1, `s0, `s0 };  // loop forever


	// test ALU arithmetic functions, result in s0
	// Correct functioning is s0 = 'd13 ('hd).
	//
	// s0 : final test result
	// s1 : test value
	// s2 : test value
	// s3 : running test result, subroutine return address
	//
	// setup running test result:
	i='h200; ram[i] = { `dat_is,          6'd0, `s3 };  // s3=0
	// load s1 & s2 values
	i=i+1;   ram[i] = { `lit_u,            `__, `s1 };  // s1='ha53c,36c9
	i=i+1;   ram[i] =                      16'h36c9  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P1 };  // 
	i=i+1;   ram[i] =                      16'ha53c  ;  // 
	//
	i=i+1;   ram[i] = { `lit_u,            `__, `s2 };  // s2='h5ca3,c396
	i=i+1;   ram[i] =                      16'hc396  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P2 };  // 
	i=i+1;   ram[i] =                      16'h5ca3  ;  // 
	// ADD_I -32 (s/b 'ha53c,36a9)
	i=i+1;   ram[i] = { `add_is,        -6'd32, `s1 };  // s1=s1-32
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='ha53c,36a9
	i=i+1;   ram[i] =                      16'h36a9  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'ha53c  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// ADD_I +31 (s/b 'ha53c,36e8)
	i=i+1;   ram[i] = { `add_is,         6'd31, `s1 };  // s1=s1+31
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='ha53c,36e8
	i=i+1;   ram[i] =                      16'h36e8  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'ha53c  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// ADD (s/b 'h01df,fa5f)
	i=i+1;   ram[i] = { `add,              `s2, `s1 };  // s1=s1+s2
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='h01df,fa5f
	i=i+1;   ram[i] =                      16'hfa5f  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'h01df  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// ADD_XS (s/b 0)
	i=i+1;   ram[i] = { `add_xs,           `s2, `s1 };  // s1=s1+s2
	i=i+1;   ram[i] = { `dat_is,          6'd0, `s0 };  // s0=0
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// ADD_XU (s/b 1)
	i=i+1;   ram[i] = { `add_xu,           `s2, `s1 };  // s1=s1+s2
	i=i+1;   ram[i] = { `dat_is,          6'd1, `s0 };  // s0=1
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// SUB (s/b 'h4898,7333)
	i=i+1;   ram[i] = { `sub,              `s2, `s1 };  // s1=s1-s2
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='h4898,7333
	i=i+1;   ram[i] =                      16'h7333  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'h4898  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// SUB_XS (s/b -1)
	i=i+1;   ram[i] = { `sub_xs,           `s2, `s1 };  // s1=s1-s2
	i=i+1;   ram[i] = { `dat_is,         -6'd1, `s0 };  // s0=-1
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// SUB_XU (s/b 0)
	i=i+1;   ram[i] = { `sub_xu,           `s2, `s1 };  // s1=s1-s2
	i=i+1;   ram[i] = { `dat_is,          6'd0, `s0 };  // s0=0
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// MUL (s/b 'hccfe,34c6)
	i=i+1;   ram[i] = { `mul,              `s2, `s1 };  // s1=s1*s2
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='hccfe,34c6
	i=i+1;   ram[i] =                      16'h34c6  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'hccfe  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// MUL_XS (s/b 'hdf27,93ae)
	i=i+1;   ram[i] = { `mul_xs,           `s2, `s1 };  // s1=s1*s2
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='hdf27,93ae
	i=i+1;   ram[i] =                      16'h93ae  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'hdf27  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// MUL_XU (s/b 'h3bcb,5744)
	i=i+1;   ram[i] = { `mul_xu,           `s2, `s1 };  // s1=s1*s2
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='h3bcb,5744
	i=i+1;   ram[i] =                      16'h5744  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'h3bcb  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// check for no opcode errors
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7='h0900
	i=i+1;   ram[i] =                      16'h0900  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr)
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P4 };  // (s4==0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// check for no stack errors
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7='h0910
	i=i+1;   ram[i] =                      16'h0910  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr)
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P4 };  // (s4==0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// copy result to s0
	i=i+1;   ram[i] = { `cpy,              `P3, `s0 };  // s0=s3, pop s3
	// loop forever
	i=i+1;   ram[i] = { `jmp_ie,    -4'd1, `s0, `s0 };  // loop forever


	// test ALU shift functions, result in s0
	// Correct functioning is s0 = 'd12 ('hc).
	//
	// s0 : final test result
	// s1 : test value
	// s2 : test value
	// s3 : running test result, subroutine return address
	//
	// setup running test result:
	i='h300; ram[i] = { `dat_is,          6'd0, `s3 };  // s3=0
	// load s1 test value
	i=i+1;   ram[i] = { `lit_u,            `__, `s1 };  // s1='ha53c,36c9
	i=i+1;   ram[i] =                      16'h36c9  ;  // hi data
	i=i+1;   ram[i] = { `lit_h,            `__, `P1 };  // lit => s1, pop combine
	i=i+1;   ram[i] =                      16'ha53c  ;  // lo data
	// SHL_IS -28 (s/b 'hffff,fffa)
	i=i+1;   ram[i] = { `shl_is,        -6'd28, `s1 };  // s1>>=28
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='hffff,fffa
	i=i+1;   ram[i] =                      16'hfffa  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'hffff  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// SHL_IS +28 (s/b 'h9000,0000)
	i=i+1;   ram[i] = { `shl_is,         6'd28, `s1 };  // s1<<=28
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='h9000,0000
	i=i+1;   ram[i] =                      16'h0000  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'h9000  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// PSU_I -28 (s/b 'h0000,000a)
	i=i+1;   ram[i] = { `psu_i,         -6'd28, `s1 };  // s1>>=28
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='h0000,000a
	i=i+1;   ram[i] =                      16'h000a  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'h0000  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// PSU_I +28 (s/b 'h1000,0000)
	i=i+1;   ram[i] = { `psu_i,          6'd28, `s1 };  // s1=1<<28
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='h1000,0000
	i=i+1;   ram[i] =                      16'h0000  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'h1000  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// SHL_S -4 (s/b 'hfa53,c36c)
	i=i+1;   ram[i] = { `dat_is,         -6'd4, `s2 };  // s2=-4
	i=i+1;   ram[i] = { `shl_s,            `P2, `s1 };  // s1<<=s2, pop s2
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='hfa53,c36c
	i=i+1;   ram[i] =                      16'hc36c  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'hfa53  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// SHL_S +4 (s/b 'h53c3,6c90)
	i=i+1;   ram[i] = { `dat_is,          6'd4, `s2 };  // s2=4
	i=i+1;   ram[i] = { `shl_s,            `P2, `s1 };  // s1<<=s2, pop s2
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='h53c3,6c90
	i=i+1;   ram[i] =                      16'h6c90  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'h53c3  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// SHL_U -4 (s/b 'h0a53,c36c)
	i=i+1;   ram[i] = { `dat_is,         -6'd4, `s2 };  // s2=-4
	i=i+1;   ram[i] = { `shl_u,            `P2, `s1 };  // s1<<=s2, pop s2
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='h0a53,c36c
	i=i+1;   ram[i] =                      16'hc36c  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'h0a53  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// SHL_U +4 (s/b 'h53c3,6c90)
	i=i+1;   ram[i] = { `dat_is,          6'd4, `s2 };  // s2=4
	i=i+1;   ram[i] = { `shl_u,            `P2, `s1 };  // s1<<=s2, pop s2
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='h53c3,6c90
	i=i+1;   ram[i] =                      16'h6c90  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'h53c3  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// POW -4 (s/b 'h1000,0000)
	i=i+1;   ram[i] = { `dat_is,         -6'd4, `s2 };  // s2=-4
	i=i+1;   ram[i] = { `pow,              `P2, `s1 };  // s1=1<<s2, pop s2
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='h0000,0000
	i=i+1;   ram[i] =                      16'h0000  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'h1000  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// POW +4 (s/b 'h0000,0010)
	i=i+1;   ram[i] = { `dat_is,          6'd4, `s2 };  // s2=4
	i=i+1;   ram[i] = { `pow,              `P2, `s1 };  // s1=1<<s2, pop s2
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='h0000,0010
	i=i+1;   ram[i] =                      16'h0010  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P0 };  // 
	i=i+1;   ram[i] =                      16'h0000  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// check for no opcode errors
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7='h0900
	i=i+1;   ram[i] =                      16'h0900  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr)
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P4 };  // (s4==0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// check for no stack errors
	i=i+1;   ram[i] = { `lit_u,            `__, `s7 };  // s7='h0910
	i=i+1;   ram[i] =                      16'h0910  ;  // 
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s7 (addr)
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P4 };  // (s4==0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// copy result to s0
	i=i+1;   ram[i] = { `cpy,              `P3, `s0 };  // s0=s3, pop s3
	// loop forever
	i=i+1;   ram[i] = { `jmp_ie,    -4'd1, `s0, `s0 };  // loop forever




	/////////////////
	// subroutines //
	/////////////////


	// sub : read & clear opcode errors for this thread => s4, return to (s7)
	// avoid the use of s1!
	i='h900; ram[i] = { `dat_is,      `THRD_ID, `s6 };  // s6=reg addr
	i=i+1;   ram[i] = { `reg_rs,           `P6, `s5 };  // s5=(s6), pop s6
	i=i+1;   ram[i] = { `pow,              `P5, `s4 };  // s4=1<<s5, pop s5
	i=i+1;   ram[i] = { `dat_is,        `OP_ER, `s6 };  // s6=reg addr
	i=i+1;   ram[i] = { `reg_rs,           `s6, `s5 };  // s5=(s6)
	i=i+1;   ram[i] = { `and,              `P5, `P4 };  // s4&=s5, pop s5
	i=i+1;   ram[i] = { `reg_w,            `P6, `s4 };  // (s6)=s4, pop s6
	i=i+1;   ram[i] = { `gto,              `P7, `__ };  // return to (s7), pop s7


	// sub : read & clear stack errors for this thread => s4, return to (s7)
	// avoid the use of s1!
	i='h910; ram[i] = { `dat_is,      `THRD_ID, `s6 };  // s6=reg addr
	i=i+1;   ram[i] = { `reg_rs,           `P6, `s5 };  // s5=(s6), pop s6
	i=i+1;   ram[i] = { `pow,              `P5, `s4 };  // s4=1<<s5, pop s5
	i=i+1;   ram[i] = { `cpy,              `s4, `s5 };  // s5=s4
	i=i+1;   ram[i] = { `shl_is,          6'd8, `P5 };  // s5<<=8
	i=i+1;   ram[i] = { `orr,              `P5, `P4 };  // s4|=s5, pop s5
	i=i+1;   ram[i] = { `dat_is,       `STK_ER, `s6 };  // s6=reg addr
	i=i+1;   ram[i] = { `reg_rs,           `s6, `s5 };  // s5=(s6)
	i=i+1;   ram[i] = { `and,              `P5, `P4 };  // s4&=s5, pop s5
	i=i+1;   ram[i] = { `reg_w,            `P6, `s4 };  // (s6)=s4, pop s6
	i=i+1;   ram[i] = { `gto,              `P7, `__ };  // return to (s7), pop s7


	end
