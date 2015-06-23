-------------------------------------------------------------------------------
--
-- Title       : sp_msb_decoder_m1
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     : 
--
-------------------------------------------------------------------------------
--
-- Description : version 1.0
-- 				 RLOC, BEL attributes included, latency = 3 clocks
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

package sp_msb_decoder_m1_pkg is
component sp_msb_decoder_m1 is
	port(
		din 	: in std_logic_vector(15 downto 0);
		din_en  : in std_logic;
		clk 	: in std_logic;
		reset 	: in std_logic;
		dout 	: out std_logic_vector(3 downto 0)
	);
end component;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity sp_msb_decoder_m1 is
	port(
		din 	: in std_logic_vector(15 downto 0);
		din_en  : in std_logic;
		clk 	: in std_logic;
		reset 	: in std_logic;
		dout 	: out std_logic_vector(3 downto 0)
	);
end sp_msb_decoder_m1;

architecture sp_msb_decoder_m1 of sp_msb_decoder_m1 is
type std_logic_array_4x2 is array (3 downto 0) of std_logic_vector(1 downto 0);
signal four0 	: std_logic_array_4x2;
signal four4 	: std_logic_vector(3 downto 0);
signal four4h 	: std_logic_vector(1 downto 0);  
signal four0z 	: std_logic_array_4x2;
signal four4z 	: std_logic_vector(3 downto 0);
signal four4hz 	: std_logic_vector(1 downto 0);
signal four0zz 	: std_logic_array_4x2;
signal lo2d     : std_logic_vector(1 downto 0);
signal lo2		: std_logic_vector(1 downto 0);
signal hi2d     : std_logic_vector(1 downto 0);	 

type str_array is array (3 downto 0) of string(1 downto 1);	
constant str : str_array:=(0=>"A", 1=>"B", 2=>"C",3=>"D");

attribute BEL	: string;
attribute RLOC	: string;

attribute BEL of dlut_hi		: label is "A6LUT";
attribute BEL of dlut_lo		: label is "B6LUT";
--attribute BEL of fdre_f4hz_hi	: label is "FFA";
--attribute BEL of fdre_f4hz_lo	: label is "FFB";

--attribute RLOC of dlut_hi		: label is "X1Y1";	
--attribute RLOC of dlut_lo		: label is "X1Y1"; 

begin

four_gen: for ii in 0 to 3 generate
	
attribute BEL of d4lut_hi	: label is str(ii) & "6LUT";
attribute BEL of fdre_hi	: label is "FF" & str(ii);

attribute BEL of d4lut_lo	: label is str(ii) & "6LUT";
attribute BEL of fdre_lo	: label is "FF" & str(ii);

attribute BEL of a4lut		: label is str(ii) & "6LUT";
attribute BEL of fdre_f4	: label is "FF" & str(ii);

attribute RLOC of d4lut_hi	: label is "X0Y0"; 
attribute RLOC of d4lut_lo	: label is "X1Y0";
attribute RLOC of a4lut		: label is "X0Y1";

attribute RLOC of fdre_hi	: label is "X0Y0"; 
attribute RLOC of fdre_lo	: label is "X1Y0";
attribute RLOC of fdre_f4	: label is "X0Y1";

attribute BEL of fdre_0zz0	: label is str(ii) & "5FF";
attribute BEL of fdre_0zz1	: label is str(ii) & "5FF";

attribute RLOC of fdre_0zz0	: label is "X1Y0"; 
attribute RLOC of fdre_0zz1	: label is "X0Y0"; 

begin

fdre_0zz0: FDRE 
generic map(INIT => '0')
port map
(
	Q 	=> four0zz(ii)(0),
	C   => clk, 
	CE  => din_en,
	R 	=> reset,
	D   => four0z(ii)(0) 
); 	
	
fdre_0zz1: FDRE 
generic map(INIT => '0')
port map
(
	Q 	=> four0zz(ii)(1),
	C   => clk, 
	CE  => din_en,
	R 	=> reset,
	D   => four0z(ii)(1) 
); 		
----------------------------------------	
d4lut_hi: LUT4 
generic map(INIT => X"FFF0")
port map(
	I0 => din(ii*4+0), 
	I1 => din(ii*4+1), 
	I2 => din(ii*4+2), 
	I3 => din(ii*4+3), 
	O  => four0(ii)(1) 
	);
	
fdre_hi: FDRE 
generic map(INIT => '0')
port map
(
	Q 	=> four0z(ii)(1),
	C   => clk, 
	CE  => din_en,
	R 	=> reset,
	D   => four0(ii)(1) 
);
----------------------------------------
d4lut_lo: LUT4 
generic map(INIT => X"FF0C")
port map(
	I0 => din(ii*4+0), 
	I1 => din(ii*4+1), 
	I2 => din(ii*4+2), 
	I3 => din(ii*4+3), 
	O  => four0(ii)(0) 
);	

fdre_lo: FDRE 
generic map(INIT => '0')
port map
(
	Q 	=> four0z(ii)(0),
	C   => clk, 
	CE  => din_en,
	R 	=> reset,
	D   => four0(ii)(0) 
); 	
----------------------------------------
a4lut: LUT4 
generic map(INIT => X"FFFE")
port map(
	I0 => din(ii*4+0), 
	I1 => din(ii*4+1), 
	I2 => din(ii*4+2), 
	I3 => din(ii*4+3), 
	O  => four4(ii) 
);		

fdre_f4: FDRE 
generic map(INIT => '0')
port map
(
	Q 	=> four4z(ii),
	C   => clk, 
	CE  => din_en,
	R 	=> reset,
	D   => four4(ii) 
); 	
end generate;
----------------------------------------
hi2d_gen: for ii in 0 to 1 generate
	
attribute BEL of fdre_f4hz	: label is "FF" & str(ii);
attribute RLOC of fdre_f4hz	: label is "X1Y1";
attribute BEL of dlut_lo0	: label is str(ii+2) & "6LUT";
attribute RLOC of dlut_lo0	: label is "X1Y1";

attribute BEL of hi2d_fd	: label is "FF" & str(ii+2);
attribute RLOC of hi2d_fd	: label is "X2Y1";
attribute BEL of lo2d_fd	: label is "FF" & str(ii);
attribute RLOC of lo2d_fd	: label is "X2Y1";

begin
	
fdre_f4hz: FDR 
generic map(INIT => '0')
port map
(
	Q 	=> four4hz(ii),
	C   => clk, 
	R 	=> reset,
	D   => four4h(ii) 
); 

hi2d_fd: FDRE 
generic map(INIT => '0')
port map
(
	Q 	=> hi2d(ii),
	C   => clk,
	CE  => din_en,	
	R 	=> reset,
	D   => four4hz(ii) 
); 	   

dlut_lo0: LUT6 
generic map(INIT => X"FF00CCCCF0F0AAAA")
port map(
	I0 => four0zz(0)(ii), 
	I1 => four0zz(1)(ii), 
	I2 => four0zz(2)(ii), 
	I3 => four0zz(3)(ii), 
	I4 => four4hz(1),
	I5 => four4hz(0),
	O  => lo2(ii)
);	

lo2d_fd: FDRE 
generic map(INIT => '0')
port map
(
	Q 	=> lo2d(ii),
	C   => clk,
	CE  => din_en,	
	R 	=> reset,
	D   => lo2(ii) 
); 
end generate;


dlut_hi: LUT4 
generic map(INIT => X"FFF0")
port map(
	I0 => four4z(0), 
	I1 => four4z(1), 
	I2 => four4z(2), 
	I3 => four4z(3), 
	O  => four4h(1)
);	

dlut_lo: LUT4 
generic map(INIT => X"FF0C")
port map(
	I0 => four4z(0), 
	I1 => four4z(1), 
	I2 => four4z(2), 
	I3 => four4z(3), 
	O  => four4h(0)
);	

dout <= hi2d & lo2d;	
	
end sp_msb_decoder_m1;
