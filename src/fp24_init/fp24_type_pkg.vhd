-------------------------------------------------------------------------------
--
-- Title       : fp24_type_pkg
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-------------------------------------------------------------------------------
--
-- Description : types
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--		(c) Copyright 2015 													 
--		Kapitanov.                                          				 
--		All rights reserved.                                                 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
package fp24_type_pkg is
	type bit_array_1024x44 is array (1023 downto 0) of bit_vector(43 downto 0);
	type bit_array_1024x48 is array (1023 downto 0) of bit_vector(47 downto 0);
	type std_logic_array_64x256 is array (63 downto 0) of bit_vector(255 downto 0);
end package;