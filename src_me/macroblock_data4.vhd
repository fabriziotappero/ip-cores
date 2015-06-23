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

entity macroblock_data4 is
    port(
      clk : in std_logic;
      reset : in std_logic;
      clear : in std_logic;
      addr : in std_logic_vector (4 downto 0);
      data : out std_logic_vector (63 downto 0)
      );
end;


architecture rtl of macroblock_data4 is

signal data_int: std_logic_vector(63 downto 0);

subtype word is integer range 0 to 255;
type mem is array (0 to 255) of word;

signal memory : mem := ( 
16#4E#,16#4F#,16#4E#,16#4E#,16#5E#,16#4B#,16#57#,16#CB#,16#E6#,16#D7#,16#EB#,16#FF#,16#C2#,16#3C#,16#27#,16#6E#,
16#4F#,16#4E#,16#4F#,16#47#,16#4D#,16#4D#,16#3A#,16#6C#,16#84#,16#9D#,16#C9#,16#DA#,16#ED#,16#A2#,16#24#,16#62#,
16#4A#,16#4E#,16#4E#,16#37#,16#42#,16#42#,16#41#,16#61#,16#53#,16#5A#,16#63#,16#4C#,16#B6#,16#FF#,16#53#,16#57#,
16#4E#,16#53#,16#2F#,16#40#,16#7E#,16#34#,16#48#,16#8F#,16#68#,16#53#,16#44#,16#32#,16#4F#,16#BB#,16#C5#,16#9B#,
16#56#,16#3E#,16#2F#,16#7A#,16#99#,16#4D#,16#51#,16#7C#,16#6E#,16#6E#,16#74#,16#7C#,16#57#,16#53#,16#B4#,16#EA#,
16#42#,16#29#,16#69#,16#91#,16#6F#,16#6C#,16#6D#,16#6A#,16#6B#,16#6F#,16#6E#,16#6D#,16#71#,16#63#,16#5D#,16#A9#,
16#2C#,16#4E#,16#8E#,16#77#,16#62#,16#73#,16#6F#,16#66#,16#6A#,16#6B#,16#6A#,16#6A#,16#6F#,16#6E#,16#57#,16#48#,
16#47#,16#85#,16#7E#,16#63#,16#67#,16#6B#,16#6A#,16#69#,16#67#,16#69#,16#6B#,16#6B#,16#69#,16#6D#,16#70#,16#4E#,
16#7C#,16#88#,16#66#,16#68#,16#65#,16#68#,16#6A#,16#6A#,16#68#,16#6A#,16#6C#,16#69#,16#69#,16#69#,16#6E#,16#75#,
16#8A#,16#6A#,16#68#,16#6B#,16#68#,16#6B#,16#69#,16#69#,16#6D#,16#6C#,16#6B#,16#69#,16#6A#,16#6C#,16#69#,16#6D#,
16#70#,16#62#,16#6A#,16#69#,16#69#,16#6D#,16#6A#,16#67#,16#68#,16#6A#,16#6A#,16#6A#,16#6B#,16#6B#,16#6B#,16#6A#,
16#65#,16#64#,16#65#,16#67#,16#66#,16#6A#,16#6A#,16#67#,16#67#,16#6A#,16#68#,16#68#,16#68#,16#6A#,16#69#,16#6A#,
16#64#,16#67#,16#67#,16#68#,16#67#,16#67#,16#69#,16#69#,16#6C#,16#6C#,16#68#,16#69#,16#69#,16#6C#,16#6A#,16#69#,
16#6A#,16#6A#,16#68#,16#67#,16#67#,16#66#,16#68#,16#69#,16#6D#,16#6C#,16#6A#,16#6B#,16#6A#,16#6B#,16#6C#,16#6B#,
16#68#,16#65#,16#65#,16#66#,16#66#,16#67#,16#69#,16#6A#,16#68#,16#69#,16#6C#,16#6B#,16#6B#,16#68#,16#69#,16#6C#,
16#66#,16#65#,16#65#,16#67#,16#67#,16#66#,16#67#,16#68#,16#66#,16#69#,16#6A#,16#6B#,16#6C#,16#68#,16#67#,16#68#
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
