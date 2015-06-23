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


	// Thread 0 : do LED PWM action
	// All other threads : loop forever

	///////////////
	// clr space //
	///////////////

	// thread 0
	i='h00;  ram[i] = { `lit_u,            `__, `s2 };  // s2=dat
	i=i+1;   ram[i] =                      16'h0100  ;  // addr
	i=i+1;   ram[i] = { `gto,              `P2, `__ };  // goto, pop s2 (addr)
	// and the rest
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

/*
	// simple binary count LED display
	i='h100; ram[i] = { `dat_is,          6'd0, `s0 };  // s0=0
	i=i+1;   ram[i] = { `dat_is,        `IO_LO, `s1 };  // s1=reg addr
	// loop start
	i=i+1;   ram[i] = { `add_is,          6'd1, `P0 };  // s0++
	i=i+1;   ram[i] = { `psu_i,         -6'd20, `s0 };  // s0=s0>>20
	i=i+1;   ram[i] = { `reg_w,            `s1, `P0 };  // (s1)=s0, pop s0
	i=i+1;   ram[i] = { `jmp_ie,    -4'd4, `s0, `s0 };  // loop forever
	// loop end
*/

/*
	// simple sequential LED display
	i='h100; ram[i] = { `dat_is,          6'd0, `s0 };  // s0=0
	i=i+1;   ram[i] = { `dat_is,        `IO_LO, `s1 };  // s1=reg addr
	// loop start
	i=i+1;   ram[i] = { `add_is,          6'd1, `P0 };  // s0++
	i=i+1;   ram[i] = { `shl_is,         6'd10, `s0 };  // s0=s0<<10
	i=i+1;   ram[i] = { `psu_i,         -6'd30, `P0 };  // s0=s0>>30, pop s0
	i=i+1;   ram[i] = { `pow,              `P0, `s0 };  // s0=1<<s0, pop s0
	i=i+1;   ram[i] = { `reg_w,            `s1, `P0 };  // (s1)=s0, pop s0
	i=i+1;   ram[i] = { `jmp_ie,    -4'd6, `s0, `s0 };  // loop forever
	// loop end
*/

/*
	// sequential LED display w/ PWM - moving "dark spot"
	i='h100; ram[i] = { `dat_is,          6'd0, `s0 };  // s0=0
	i=i+1;   ram[i] = { `dat_is,        `IO_LO, `s1 };  // s1=reg addr
	i=i+1;   ram[i] = { `dat_is,          6'd0, `s2 };  // s2=pwm
	// loop start
	i=i+1;   ram[i] = { `shl_is,         6'd13, `s0 };  // s0=s0<<13 - isolate decimal
	i=i+1;   ram[i] = { `add,              `P0, `P2 };  // s2+=s0, pop s0 - add to pwm counter
	i=i+1;   ram[i] = { `add_is,          6'd1, `P0 };  // s0++ - get next value
	i=i+1;   ram[i] = { `shl_is,         6'd13, `s0 };  // s0=s0<<13 - isolate decimal
	i=i+1;   ram[i] = { `add_xu,           `P0, `s2 };  // s2=s2+s0, pop s0 - see if it will cause pwm counter overflow
	i=i+1;   ram[i] = { `shl_is,         6'd19, `P2 };  // s2<<=19 - shift up to ones place
	i=i+1;   ram[i] = { `add,              `P2, `s0 };  // s0+=s2, pop s2 - add pwm bit
	i=i+1;   ram[i] = { `shl_is,         6'd11, `P0 };  // s0<<=11 - isolate integer
	i=i+1;   ram[i] = { `psu_i,         -6'd30, `P0 };  // s0>>=30
	i=i+1;   ram[i] = { `pow,              `s0, `P0 };  // s0=1<<s0, pop s0 - do one hot
	i=i+1;   ram[i] = { `not,              `s0, `P0 };  // s0~=s0 - invert
	i=i+1;   ram[i] = { `reg_w,            `s1, `P0 };  // (s1)=s0, pop s0
	i=i+1;   ram[i] = { `jmp_inz,       -6'd13, `s1 };  // loop forever
	// loop end
*/

	// "bouncing ball" 4 LED display w/ PWM
	//
	// s0 : sin
	// s1 : cos
	// s2 : alpha (attenuation factor = speed)
	// s3 : rectified sin, val, one-hot(val)
	// s4 : 
	// s5 : pwm counter
	// s6 : 
	// s7 : i/o register address
	
	i='h100; ram[i] = { `dat_is,          6'd0, `s0 };  // s0=0  (sin init)
	i=i+1;   ram[i] = { `lit_u,            `__, `s1 };  // s1=0x3000,0000 (cos init)
	i=i+1;   ram[i] =                      16'h3000  ;  // 
	i=i+1;   ram[i] = { `shl_is,         6'd16, `P1 };  //
	i=i+1;   ram[i] = { `lit_u,            `__, `s2 };  // s2=0x3000 (alpha init)
	i=i+1;   ram[i] =                      16'h3000  ;  // 
	i=i+1;   ram[i] = { `dat_is,          6'd0, `s5 };  // s5=0  (pwm init)
	i=i+1;   ram[i] = { `dat_is,        `IO_LO, `s7 };  // s7=reg addr
	// loop start
	// sin & cos
	i=i+1;   ram[i] = { `mul_xs,           `s2, `s0 };  // s0=s0*s2 (sin*alpha)
	i=i+1;   ram[i] = { `sub,              `P0, `P1 };  // s1-=s0 (cos-=sin*alpha)
	i=i+1;   ram[i] = { `mul_xs,           `s2, `s1 };  // s1=s1*s2 (cos*alpha)
	i=i+1;   ram[i] = { `add,              `P1, `P0 };  // s0-=s1 (sin+=cos*alpha)
	// |sin|
	i=i+1;   ram[i] = { `cpy,              `s0, `s3 };  // s3=s0
	i=i+1;   ram[i] = { `jmp_inlz,        6'd1, `s3 };  // (s3!<0) ? jmp +1
	i=i+1;   ram[i] = { `not,              `s3, `P3 };  // s3~=s3
	// decimal( |sin| ) + pwm to update, + pwm to get ofl
	i=i+1;   ram[i] = { `shl_is,          6'd4, `s3 };  // s3=s3<<4
	i=i+1;   ram[i] = { `add,              `s3, `P5 };  // s5+=s3 (update pwm count)
	i=i+1;   ram[i] = { `add_xu,           `P3, `s5 };  // s5=s5+s3, pop s3 (get pwm ofl)
	// one-hot( int( |sin| ) + pwm ofl )
	i=i+1;   ram[i] = { `shl_is,        -6'd28, `P3 };  // s3>>=28
	i=i+1;   ram[i] = { `add,              `P5, `P3 };  // s3+=s5, pop s5 (add pwm ofl)
	i=i+1;   ram[i] = { `pow,              `s3, `P3 };  // s3=1<<s3, pop s3 (one-hot)
	// output
	i=i+1;   ram[i] = { `reg_w,            `s7, `P3 };  // (s7)=s3, pop s3
	i=i+1;   ram[i] = { `jmp_inz,       -6'd15, `s7 };  // loop forever
	// loop end
		
	end
