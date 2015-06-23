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

entity macroblock_data5 is
    port(
      clk : in std_logic;
      reset : in std_logic;
      clear : in std_logic;
      addr : in std_logic_vector (4 downto 0);
      data : out std_logic_vector (63 downto 0)
      );
end;


architecture rtl of macroblock_data5 is

signal data_int: std_logic_vector(63 downto 0);

subtype word is integer range 0 to 255;
type mem is array (0 to 255) of word;

signal memory : mem := ( 
16#D5#,16#D8#,16#D4#,16#EF#,16#EB#,16#94#,16#38#,16#30#,16#4E#,16#45#,16#87#,16#DE#,16#CB#,16#C8#,16#CC#,16#CD#,
16#DC#,16#D2#,16#C6#,16#CE#,16#D0#,16#D9#,16#D9#,16#82#,16#3A#,16#36#,16#75#,16#D9#,16#D2#,16#C4#,16#C9#,16#CB#,
16#E1#,16#CE#,16#C2#,16#BF#,16#C0#,16#DE#,16#F9#,16#E4#,16#8B#,16#1D#,16#5A#,16#D9#,16#D2#,16#C0#,16#C6#,16#CA#,
16#C9#,16#CC#,16#C4#,16#C6#,16#C5#,16#C1#,16#BE#,16#EA#,16#F7#,16#54#,16#40#,16#D5#,16#D6#,16#C0#,16#D0#,16#DA#,
16#D6#,16#C2#,16#C7#,16#CA#,16#CA#,16#CA#,16#C9#,16#C1#,16#F2#,16#B8#,16#50#,16#BD#,16#DD#,16#C6#,16#D2#,16#C2#,
16#E5#,16#D2#,16#C0#,16#C6#,16#C8#,16#C8#,16#C7#,16#C2#,16#D3#,16#D5#,16#94#,16#B3#,16#D6#,16#C4#,16#9A#,16#65#,
16#96#,16#E3#,16#CF#,16#BC#,16#BF#,16#C4#,16#C3#,16#C2#,16#C1#,16#D3#,16#D4#,16#BF#,16#C9#,16#C3#,16#5F#,16#1C#,
16#48#,16#AA#,16#DD#,16#C4#,16#C0#,16#C4#,16#C5#,16#C8#,16#C3#,16#C4#,16#D5#,16#C9#,16#C5#,16#C9#,16#60#,16#1F#,
16#54#,16#4C#,16#A6#,16#EB#,16#D9#,16#C6#,16#C9#,16#C9#,16#C6#,16#C4#,16#C7#,16#C6#,16#CB#,16#C8#,16#55#,16#24#,
16#6F#,16#4A#,16#54#,16#83#,16#B9#,16#E1#,16#DA#,16#D4#,16#C9#,16#C6#,16#C9#,16#C8#,16#C6#,16#D1#,16#92#,16#18#,
16#6A#,16#73#,16#5A#,16#32#,16#68#,16#A3#,16#AE#,16#C7#,16#E4#,16#E2#,16#C8#,16#C6#,16#BF#,16#D2#,16#E1#,16#78#,
16#6B#,16#6B#,16#6F#,16#6C#,16#56#,16#50#,16#68#,16#89#,16#AA#,16#BE#,16#D4#,16#E0#,16#D0#,16#BC#,16#CA#,16#D6#,
16#6B#,16#6A#,16#70#,16#73#,16#65#,16#57#,16#58#,16#58#,16#44#,16#62#,16#AB#,16#C0#,16#D4#,16#D8#,16#C6#,16#E4#,
16#69#,16#69#,16#6B#,16#6A#,16#71#,16#6F#,16#68#,16#60#,16#4E#,16#54#,16#57#,16#4F#,16#9D#,16#E3#,16#CB#,16#C4#,
16#6C#,16#6A#,16#69#,16#68#,16#68#,16#6B#,16#6A#,16#6C#,16#75#,16#6D#,16#4F#,16#45#,16#4B#,16#76#,16#CB#,16#A5#,
16#6A#,16#6D#,16#6A#,16#68#,16#68#,16#6A#,16#6A#,16#68#,16#69#,16#6B#,16#6F#,16#75#,16#4A#,16#3C#,16#6E#,16#3A#
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
