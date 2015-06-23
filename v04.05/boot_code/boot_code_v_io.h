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


	// Thread 0 : test I/O functions
	// All other threads : loop forever

	///////////////
	// clr space //
	///////////////

	// thread 0
	i='h0;   ram[i] = { `lit_u,            `__, `s2 };  // s2='h0100
	i=i+1;   ram[i] =                      16'h0100  ;  // 
	i=i+1;   ram[i] = { `gto,              `P2, `__ };  // goto, pop s2 (addr)
	// thread 1
	i='h4;   ram[i] = { `lit_u,            `__, `s2 };  // s2='h0200
	i=i+1;   ram[i] =                      16'h0200  ;  // 
	i=i+1;   ram[i] = { `gto,              `P2, `__ };  // goto, pop s2 (addr)
	// and the rest
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


	// test I/O functions, result in s0
	// Correct functioning is s0 = 'd8 ('h8).
	//
	// s0 : final test result
	// s1 : test value
	// s2 : test value
	// s3 : running test result, subroutine return address
	//
	// setup running test result:
	i='h100; ram[i] = { `dat_is,          6'd0, `s3 };  // s3=0
	// PGC
	i=i+1;   ram[i] = { `pgc,              `__, `s1 };  // s1=PC
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='h0102
	i=i+1;   ram[i] =                      16'h0102  ;  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// setup test value:
	i=i+1;   ram[i] = { `lit_u,            `__, `s1 };  // s1='h36c9,a53c
	i=i+1;   ram[i] =                      16'ha53c  ;  // 
	i=i+1;   ram[i] = { `lit_h,            `__, `P1 };  // 
	i=i+1;   ram[i] =                      16'h36c9  ;  // 
	// MEM_IWH & MEM_IRH
	i=i+1;   ram[i] = { `lit_u,            `__, `s2 };  // s2='h0a00
	i=i+1;   ram[i] =                      16'h0a00  ;  // 
	i=i+1;   ram[i] = { `mem_iw,     4'd0, `s2, `s1 };  // (s2+offset)=s1
	i=i+1;   ram[i] = { `mem_iwh,    4'd1, `s2, `s1 };  // 
	i=i+1;   ram[i] = { `mem_irs,    4'd0, `s2, `s0 };  // s0=(s2+offset)
	i=i+1;   ram[i] = { `mem_irh,    4'd1, `P2, `P0 };  // 
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `s1, `P0 };  // (s0==s1) ? skip, pop s0
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// MEM_IRS (signed)
	i=i+1;   ram[i] = { `lit_u,            `__, `s2 };  // s2='h0a00
	i=i+1;   ram[i] =                      16'h0a10  ;  // 
	i=i+1;   ram[i] = { `mem_iw,     4'd0, `s2, `s1 };  // (s2+offset)=s1
	i=i+1;   ram[i] = { `mem_irs,    4'd0, `P2, `s0 };  // s0=(s2+offset), pop s2
	i=i+1;   ram[i] = { `shl_is,         6'd16, `s1 };  // s1<<=16
	i=i+1;   ram[i] = { `shl_is,        -6'd16, `P1 };  // s1>>=16
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// MEM_IRS (unsigned)
	i=i+1;   ram[i] = { `lit_u,            `__, `s2 };  // s2='h0a00
	i=i+1;   ram[i] =                      16'h0a20  ;  // 
	i=i+1;   ram[i] = { `mem_iwh,    4'd0, `s2, `s1 };  // (s2+offset)=s1
	i=i+1;   ram[i] = { `mem_irs,    4'd0, `P2, `s0 };  // s0=(s2+offset), pop s2
	i=i+1;   ram[i] = { `psu_i,        -6'd16, `s1 };  // s1>>=16
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// REG_RS, REG_RH, REG_W & REG_WH (check manually for I/O loopback)
	i=i+1;   ram[i] = { `dat_is,        `IO_LO, `s2 };  // s2=reg addr
	i=i+1;   ram[i] = { `reg_rs,           `s2, `s1 };  // s1=(s2)
	i=i+1;   ram[i] = { `reg_w,            `P2, `P1 };  // (s2)=s1, pop both
	i=i+1;   ram[i] = { `dat_is,        `IO_HI, `s2 };  // s2=reg addr
	i=i+1;   ram[i] = { `reg_rh,           `s2, `s1 };  // s1=(s2)
	i=i+1;   ram[i] = { `reg_wh,           `P2, `P1 };  // (s2)=s1, pop s2
	// LIT_S
	i=i+1;   ram[i] = { `lit_s,            `__, `s0 };  // s0='ha53c
	i=i+1;   ram[i] =                      16'ha53c  ;  // 
	i=i+1;   ram[i] = { `shl_is,         6'd16, `s1 };  // s1<<=16
	i=i+1;   ram[i] = { `shl_is,        -6'd16, `P1 };  // s1>>=16, pop s1
	i=i+1;   ram[i] = { `jmp_ie,     4'd1, `P1, `P0 };  // (s0==s1) ? skip, pop both
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// LIT_U
	i=i+1;   ram[i] = { `lit_u,            `__, `s0 };  // s0='ha53c
	i=i+1;   ram[i] =                      16'ha53c  ;  // 
	i=i+1;   ram[i] = { `shl_is,         6'd16, `s1 };  // s1<<=16
	i=i+1;   ram[i] = { `psu_i,         -6'd16, `P1 };  // s1>>=16, pop s1
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
	i=i+1;   ram[i] = { `gsb,              `P7, `s7 };  // gsb, pop s2 (addr)
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P4 };  // (s4==0) ? skip, pop s4
	i=i+1;   ram[i] = { `add_is,         -6'd1, `P3 };  // s3--
	i=i+1;   ram[i] = { `add_is,          6'd1, `P3 };  // s3++
	// copy result to s0
	i=i+1;   ram[i] = { `cpy,              `P3, `s0 };  // s0=s3, pop s3
	// loop forever
	i=i+1;   ram[i] = { `jmp_ie,    -4'd1, `s0, `s0 };  // loop forever
	// end sub


	// test UART
	//
	// s0 : TX value
	// s1 : 
	// s2 : reg addr
	// s3 : 
	// s4 : TX ready
	//
	//
	i='h200; ram[i] = { `lit_u,            `__, `s0 };  // s0='h00a5
	i=i+1;   ram[i] =                      16'h00a5  ;  // 
	i=i+1;   ram[i] = { `dat_is,      `UART_TX, `s2 };  // s2=reg addr
	i=i+1;   ram[i] = { `reg_rs,           `s2, `s4 };  // s4=(s2)
	i=i+1;   ram[i] = { `jmp_iz,          6'd1, `P4 };  // (s4==0) ? skip, pop s4
	i=i+1;   ram[i] = { `reg_w,            `s2, `s0 };  // (s2)=s0
	// loop forever
	i=i+1;   ram[i] = { `jmp_ie,    -4'd1, `s0, `s0 };  // loop forever
	// end sub


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
