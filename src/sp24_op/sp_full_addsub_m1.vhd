-------------------------------------------------------------------------------
--
-- Title       : sp_full_addsub
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     : 
--
-- Description : 1-bit full adder with BEL and RLOC options;
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

package	sp_full_addsub_m1_pkg is
component sp_full_addsub_m1 is 
	generic(
		pos 	: integer :=0);	
	port(
		clk		: in std_logic;		
		ce		: in std_logic;	
		rst    	: in std_logic;
		
		a		: in std_logic;
		b 		: in std_logic;
		cin		: in std_logic;
		c		: out std_logic;
		cout	: out std_logic; 	
		add_sub : in std_logic
	);
end component;
end package;

library ieee;
use ieee.std_logic_1164.all; 
library unisim;
use unisim.vcomponents.all;

entity sp_full_addsub_m1 is	
	generic(
		pos 	: integer :=0);	
	port(
		clk		: in std_logic;		
		ce		: in std_logic;	
		rst     : in std_logic;
		
		a		: in std_logic;
		b 		: in std_logic;
		cin		: in std_logic;
		c		: out std_logic;
		cout	: out std_logic; 	
		add_sub : in std_logic
	);

end sp_full_addsub_m1;


architecture sp_full_addsub_m1 of sp_full_addsub_m1 is

signal lut_out		: std_logic;
signal xor_c		: std_logic;

attribute BEL		: string;
attribute RLOC		: string;
attribute U_SET 	: string;

type str_array is array (3 downto 0) of string(1 downto 1);	
constant str : str_array:=(0=>"A", 1=>"B", 2=>"C",3=>"D"); 

attribute BEL of lut_uut	: label is str(pos) & "6LUT";
attribute BEL of fdre_uut	: label is "FF" & str(pos);
attribute RLOC of lut_uut	: label is "X0Y0"; 
attribute RLOC of fdre_uut	: label is "X0Y0";	
--attribute U_SET of lut_uut	: label is "uset";
--attribute U_SET of fdre_uut	: label is "uset";

begin		  
	
--lut_uut : LUT4
--generic map (INIT => X"6969")
--port map 
--(
--	O 	=> lut_out,
--	I0 	=> a, 
--	I1 	=> b, 
--	I2 	=> add_sub, 
--	I3 	=> '0'
--); 

lut_uut : LUT6
generic map(INIT => X"6969696969696969")
port map(
	O	=> lut_out,
	I0	=> a,
	I1	=> b,
	I2	=> add_sub,
	I3	=> '0',
	I4	=> '0',
	I5	=> '0'
);
	
xor_uut: XORCY 
port map(
	O 	=> xor_c, 
	CI 	=> cin, 
	LI 	=> lut_out 
);

mux_uut: MUXCY 
port map(
	O 	=> cout,
	CI 	=> cin,
	DI 	=> a,
	S  	=> lut_out
);	 

fdre_uut: FDRE 
generic map(INIT => '0')
port map(
	Q 	=> c,
	C   => clk, 
	CE  => ce,
	R 	=> rst,
	D   => xor_c 
); 
--ares_n <= not rst;	
end sp_full_addsub_m1;