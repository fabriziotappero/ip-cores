-------------------------------------------------------------------------------
--
-- Title       : fp24_m2_pkg
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-- Description : FP package, width = 27
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--		(c) Copyright 2015 													 
--		Kapitanov.                                          				 
--		All rights reserved.                                                 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package	fp24_m2_pkg is	
	
	type complex_fp24 is record
		re : std_logic_vector(23 downto 0);
		im : std_logic_vector(23 downto 0);
	end record;
	
	type complex_m is record
		exp_m 	: integer; 
		sig_m 	: std_logic;
		man_m 	: std_logic_vector(16 downto 0);
		int 	: real;
	end record;
	
	component fp24_add_m2 is
		port(
			aa 		: in std_logic_vector(23 downto 0);
			bb 		: in std_logic_vector(23 downto 0);
			cc 		: out std_logic_vector(23 downto 0);
			enable 	: in std_logic;	
			valid	: out std_logic;
			reset  	: in std_logic;
			clk 	: in std_logic	
		);
	end component;

	component fp24_sub_m2 is
		port(
			aa 		: in std_logic_vector(23 downto 0);
			bb 		: in std_logic_vector(23 downto 0);
			cc 		: out std_logic_vector(23 downto 0);
			enable 	: in std_logic;
			valid	: out std_logic;
			reset  	: in std_logic;
			clk 	: in std_logic	
		);
	end component;
	
	component fp24_mult_m2 is
		port(
			aa 		: in std_logic_vector(23 downto 0);
			bb 		: in std_logic_vector(23 downto 0);
			cc 		: out std_logic_vector(23 downto 0);
			enable 	: in std_logic;
			valid	: out std_logic;
			reset  	: in std_logic;
			clk 	: in std_logic	
		);
	end component;

	component fp24_addsub_m2 is
		port(
			aa 		: in std_logic_vector(23 downto 0);
			bb 		: in std_logic_vector(23 downto 0);
			cc_add	: out std_logic_vector(23 downto 0);
			cc_sub	: out std_logic_vector(23 downto 0);
			enable 	: in std_logic;
			valid	: out std_logic;
			reset  	: in std_logic;
			clk 	: in std_logic	
		);
	end component;

	component fp24_cmult_m2 is
		port(
		aa 		: in complex_fp24;
		bb 		: in complex_fp24;
		cc 		: out complex_fp24;
		enable 	: in std_logic;
		reset  	: in std_logic;
		clk 	: in std_logic;
		dout_v	: out std_logic
		);	
	end component; 
	
	function flt_decode( code_num: std_logic_vector(23 downto 0) ) return complex_m;
	function relerr_cacl(undertest : real; precise : real ) return real;
	
end fp24_m2_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

package	body fp24_m2_pkg	is 
	
	function flt_decode(code_num: std_logic_vector(23 downto 0)) return complex_m is 
		variable int_num 	: real;
		variable flt_num	: complex_m;
		variable sigexp		: real:=1.0;
	begin
		sigexp			:=	1.0;
		flt_num.exp_m	:=	conv_integer(code_num(23 downto 17));
		flt_num.sig_m	:=	code_num(16);
		flt_num.man_m	:=	'1' & code_num(15 downto 0);	
		
		if flt_num.exp_m = 0 then 
			flt_num.int := 0.0;
		else
			flt_num.exp_m := flt_num.exp_m-32;
			flt_num.int := real(conv_integer(flt_num.man_m))*(2.0**real(flt_num.exp_m));
			if flt_num.sig_m = '1' then 
				flt_num.int := -flt_num.int; 
			end if;
		end if;	
		return flt_num;		
	end flt_decode;	

	function relerr_cacl(undertest : real; precise : real) return real is
		variable rel_error : real:=0.0;
	begin
		if (precise=0.0) then 
			rel_error	:=	0.0;
		else 
			rel_error	:=	abs(real(undertest)-real(precise))/real(precise);
		end if;
		return rel_error;
	end relerr_cacl;	
	
end fp24_m2_pkg;
