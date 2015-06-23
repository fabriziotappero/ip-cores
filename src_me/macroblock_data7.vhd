----------------------------------------------------------------------------
--  This file is a part of the LM VHDL IP LIBRARY
--  Copyright (C) 2009 Jose Nunez-Yanez
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  See the file COPYING for the full details of the license.
--
--  The license allows free and unlimited use of the library and tools for research and education purposes. 
--  The full LM core supports many more advanced motion estimation features and it is available under a 
--  low-cost commercial license. See the readme file to learn more or contact us at 
--  eejlny@byacom.co.uk or www.byacom.co.uk
-----------------------------------------------------------------------------
-- Entity: 	
-- File:	macroblock_data.vhd
-- Author:	Jose Luis Nunez 
-- Description:	macroblock data 5x5 macroblocks 
------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.Numeric_STD.all;

entity macroblock_data7 is
    port(
      clk : in std_logic;
      reset : in std_logic;
      clear : in std_logic;
      addr : in std_logic_vector (4 downto 0);
      data : out std_logic_vector (63 downto 0)
      );
end;


architecture rtl of macroblock_data7 is

signal data_int: std_logic_vector(63 downto 0);

subtype word is integer range 0 to 255;
type mem is array (0 to 255) of word;

signal memory : mem := ( 
16#F3#,16#C9#,16#AD#,16#A8#,16#AF#,16#AE#,16#A5#,16#BC#,16#AC#,16#33#,16#84#,16#DE#,16#9C#,16#59#,16#34#,16#16#,
16#C3#,16#E1#,16#AB#,16#A8#,16#AC#,16#AB#,16#AC#,16#B3#,16#61#,16#11#,16#80#,16#CC#,16#AF#,16#B1#,16#B9#,16#5F#,
16#5B#,16#D5#,16#BC#,16#A2#,16#AE#,16#A8#,16#B3#,16#A7#,16#36#,16#1A#,16#88#,16#B9#,16#AF#,16#C2#,16#DA#,16#BA#,
16#01#,16#84#,16#D1#,16#A7#,16#A5#,16#A7#,16#B3#,16#A5#,16#3F#,16#26#,16#8F#,16#C3#,16#BE#,16#B6#,16#A5#,16#B3#,
16#2B#,16#30#,16#BA#,16#BB#,16#9C#,16#A6#,16#B0#,16#A3#,16#3C#,16#38#,16#B3#,16#AA#,16#7B#,16#7C#,16#5F#,16#52#,
16#9F#,16#1C#,16#6A#,16#DB#,16#B7#,16#9A#,16#BF#,16#A9#,16#2B#,16#3B#,16#9C#,16#65#,16#2B#,16#34#,16#32#,16#39#,
16#B9#,16#32#,16#18#,16#AA#,16#D0#,16#AE#,16#B9#,16#8A#,16#1D#,16#24#,16#4A#,16#41#,16#42#,16#46#,16#4D#,16#53#,
16#4D#,16#4C#,16#1E#,16#29#,16#97#,16#BF#,16#7F#,16#3C#,16#2A#,16#46#,16#45#,16#4D#,16#60#,16#5E#,16#60#,16#60#,
16#28#,16#4B#,16#41#,16#10#,16#2F#,16#6D#,16#57#,16#28#,16#4D#,16#68#,16#5E#,16#5A#,16#58#,16#54#,16#56#,16#54#,
16#4D#,16#48#,16#44#,16#40#,16#19#,16#21#,16#37#,16#46#,16#73#,16#5D#,16#4F#,16#57#,16#55#,16#54#,16#54#,16#55#,
16#4A#,16#48#,16#41#,16#3D#,16#3F#,16#39#,16#2C#,16#3B#,16#56#,16#68#,16#60#,16#4E#,16#50#,16#54#,16#52#,16#55#,
16#48#,16#48#,16#41#,16#3D#,16#3C#,16#3D#,16#3E#,16#31#,16#2D#,16#56#,16#66#,16#62#,16#5B#,16#51#,16#52#,16#54#,
16#47#,16#46#,16#40#,16#3D#,16#3E#,16#3E#,16#3F#,16#39#,16#2E#,16#2A#,16#45#,16#62#,16#5F#,16#5B#,16#5C#,16#5B#,
16#48#,16#46#,16#40#,16#3D#,16#3D#,16#3D#,16#3C#,16#3D#,16#3C#,16#2D#,16#2C#,16#32#,16#43#,16#5C#,16#5D#,16#5A#,
16#48#,16#46#,16#40#,16#3E#,16#3D#,16#3C#,16#3D#,16#3B#,16#3C#,16#3F#,16#35#,16#28#,16#2E#,16#3B#,16#39#,16#39#,
16#48#,16#46#,16#40#,16#3E#,16#3C#,16#3A#,16#3C#,16#3C#,16#3A#,16#3A#,16#3D#,16#3F#,16#36#,16#2B#,16#28#,16#28#
);

--attribute syn_romstyle : string;
--attribute syn_romstyle of memory : signal is "logic";


begin

  p : process(addr)
	variable vaddr1 : integer range 0 to 255;
	variable vaddr2 : integer range 0 to 255;
	variable vaddr3 : integer range 0 to 255;
	variable vaddr4 : integer range 0 to 255;
	variable vaddr5 : integer range 0 to 255;
	variable vaddr6 : integer range 0 to 255;
	variable vaddr7 : integer range 0 to 255;
	variable vaddr8 : integer range 0 to 255;
	begin
			vaddr1 := To_integer(unsigned(addr&"000"));
			vaddr2 := To_integer(unsigned(addr&"001"));
			vaddr3 := To_integer(unsigned(addr&"010"));
			vaddr4 := To_integer(unsigned(addr&"011"));
			vaddr5 := To_integer(unsigned(addr&"100"));
			vaddr6 := To_integer(unsigned(addr&"101"));
			vaddr7 := To_integer(unsigned(addr&"110"));
			vaddr8 := To_integer(unsigned(addr&"111"));
			data_int <= (std_logic_vector(to_unsigned(memory(vaddr1),8)) &  std_logic_vector(to_unsigned(memory(vaddr2),8)) &  std_logic_vector(to_unsigned(memory(vaddr3),8)) & std_logic_vector(to_unsigned(memory(vaddr4),8)) & std_logic_vector(to_unsigned(memory(vaddr5),8)) & std_logic_vector(to_unsigned(memory(vaddr6),8)) & std_logic_vector(to_unsigned(memory(vaddr7),8)) & std_logic_vector(to_unsigned(memory(vaddr8),8)));
		--	data_int(23 downto 16) <= std_logic_vector(to_unsigned(memory(vaddr2),8));
		--	data_int(15 downto 8) <= std_logic_vector(to_unsigned(memory(vaddr3),8));
		--	data_int(7 downto 0) <= std_logic_vector(to_unsigned(memory(vaddr4),8));
  end process;
  
  
  ff: process(clear,clk)
  begin
  	if (clear = '1') then
			data <= (others => '0');    			
	elsif rising_edge(clk) then 
			if (reset = '1') then
			     data <= (others => '0');  
			else 
			     data <= data_int;
 			end if;
 	end if;
  end process;
  




end rtl;
