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
----------------------------------------------------------------------------
-- Entity: 	
-- File:	macroblock_data.vhd
-- Author:	Jose Luis Nunez 
-- Description:	macroblock data 5x5 macroblocks 
------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.Numeric_STD.all;

entity macroblock_data3 is
    port(
      clk : in std_logic;
      reset : in std_logic;
      clear : in std_logic;
      addr : in std_logic_vector (4 downto 0);
      data : out std_logic_vector (63 downto 0)
      );
end;


architecture rtl of macroblock_data3 is

signal data_int: std_logic_vector(63 downto 0);

subtype word is integer range 0 to 255;
type mem is array (0 to 255) of word;

signal memory : mem := ( 
16#45#,16#4F#,16#4C#,16#48#,16#51#,16#51#,16#4B#,16#47#,16#4A#,16#4D#,16#4F#,16#52#,16#4F#,16#4F#,16#4E#,16#4A#,
16#48#,16#4A#,16#4C#,16#49#,16#4A#,16#4E#,16#49#,16#40#,16#48#,16#50#,16#4E#,16#4E#,16#4B#,16#4B#,16#4A#,16#4C#,
16#4B#,16#45#,16#43#,16#45#,16#48#,16#4D#,16#4B#,16#45#,16#49#,16#4C#,16#4B#,16#4C#,16#4E#,16#49#,16#44#,16#4A#,
16#47#,16#4A#,16#3F#,16#3F#,16#4B#,16#4D#,16#4B#,16#4C#,16#4C#,16#4A#,16#4A#,16#4A#,16#4D#,16#47#,16#41#,16#4B#,
16#43#,16#4D#,16#47#,16#42#,16#4A#,16#4B#,16#4A#,16#4C#,16#4C#,16#4C#,16#49#,16#49#,16#4B#,16#49#,16#48#,16#4D#,
16#43#,16#48#,16#4B#,16#49#,16#4A#,16#4A#,16#4A#,16#4B#,16#4A#,16#49#,16#48#,16#4A#,16#4D#,16#4D#,16#4C#,16#51#,
16#42#,16#47#,16#4C#,16#4B#,16#49#,16#4A#,16#49#,16#49#,16#49#,16#4A#,16#4A#,16#4A#,16#4B#,16#4B#,16#50#,16#4B#,
16#42#,16#45#,16#4A#,16#48#,16#48#,16#4B#,16#4A#,16#4A#,16#4B#,16#4B#,16#4C#,16#4B#,16#49#,16#4B#,16#4F#,16#38#,
16#42#,16#42#,16#4A#,16#4A#,16#49#,16#49#,16#49#,16#48#,16#49#,16#4B#,16#4D#,16#4B#,16#4A#,16#50#,16#3D#,16#34#,
16#43#,16#42#,16#49#,16#4A#,16#4A#,16#48#,16#49#,16#4A#,16#49#,16#4B#,16#4B#,16#49#,16#4F#,16#48#,16#30#,16#63#,
16#45#,16#42#,16#48#,16#49#,16#49#,16#4A#,16#4B#,16#4B#,16#4A#,16#4A#,16#49#,16#4D#,16#4C#,16#2F#,16#4E#,16#86#,
16#43#,16#41#,16#48#,16#49#,16#48#,16#4A#,16#4B#,16#49#,16#49#,16#49#,16#4D#,16#51#,16#32#,16#39#,16#79#,16#78#,
16#44#,16#41#,16#48#,16#4A#,16#48#,16#49#,16#4B#,16#4A#,16#49#,16#4A#,16#51#,16#3E#,16#2D#,16#6E#,16#88#,16#66#,
16#43#,16#42#,16#48#,16#49#,16#49#,16#49#,16#49#,16#4A#,16#49#,16#4C#,16#47#,16#32#,16#5B#,16#88#,16#6D#,16#63#,
16#43#,16#45#,16#4A#,16#4A#,16#4A#,16#4B#,16#4A#,16#4A#,16#4C#,16#4E#,16#30#,16#47#,16#86#,16#73#,16#60#,16#68#,
16#3A#,16#27#,16#30#,16#39#,16#36#,16#36#,16#39#,16#3E#,16#4A#,16#33#,16#2F#,16#78#,16#7B#,16#5E#,16#67#,16#67#
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
