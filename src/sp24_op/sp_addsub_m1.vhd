-------------------------------------------------------------------------------
--
-- Title       : sp_addsub_m1
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     : 
--
-- Description : adder/subtractor with BEL and RLOC options	(SLICEL contains 1 6LUT: Virtex-5,6,7)
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

package sp_addsub_m1_pkg is
	component sp_addsub_m1 is
		generic(	
			N 		: integer:=15);
		port(
			data_a 	: in std_logic_vector(N downto 0);
			data_b 	: in std_logic_vector(N downto 0);
			data_c 	: out std_logic_vector(N downto 0);
			add_sub	: in std_logic;  -- '0' - add, '1' - sub
			cin     : in std_logic:='0';
			cout    : out std_logic;
			clk    	: in std_logic;
			ce 		: in std_logic:='1';	
			aclr  	: in std_logic:='1'
		);
	end component;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.sp_full_addsub_m1_pkg.all;
use work.sp_int2str_pkg.all;

entity sp_addsub_m1 is
	generic(	
		N 		: integer:=15);
	port(
		data_a 	: in std_logic_vector(N downto 0);
		data_b 	: in std_logic_vector(N downto 0);
		data_c 	: out std_logic_vector(N downto 0);
		add_sub	: in std_logic;  -- '0' - add, '1' - sub
		cin     : in std_logic:='0';
		cout    : out std_logic;
		clk    	: in std_logic;
		ce 		: in std_logic:='1';	
		aclr  	: in std_logic:='1'
	);
end sp_addsub_m1;

architecture sp_addsub_m1 of sp_addsub_m1 is 

signal cix		: std_logic_vector(N+1 downto 0):=(others=>'0');
signal cox 		: std_logic_vector(N downto 0):=(others=>'0'); 
attribute RLOC	: string;

begin 

gen_slice: for ii in 0 to N generate  

constant xx : natural:=0; 
constant yy	: natural:=conv_integer(conv_std_logic_vector(ii, 16)(7 downto 2));
constant rloc_str : string :="X" & nat2str(xx,2) & "Y" & nat2str(yy,2) ;
attribute RLOC of full_slice : label is rloc_str; 

begin	

full_slice: sp_full_addsub_m1
generic map( pos => conv_integer(conv_std_logic_vector(ii, 16)(1 downto 0)))
port map(
	a		=> data_a(ii), 
	b 		=> data_b(ii), 
	c		=> data_c(ii), 
	cin		=> cix(ii), 
	cout	=> cox(ii), 
	add_sub => add_sub, 
	ce		=> ce,
	rst		=> aclr, 
	clk		=> clk 
	);
	cix(ii+1)<=cox(ii);
end generate;
cix(0)<=cin;
cout<=cox(N);

end sp_addsub_m1;
