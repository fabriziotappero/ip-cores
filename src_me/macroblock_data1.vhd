
----------------------------------------------------------------------------
--  This file is a part of the me testbench VHDL model
--  Copyright (C) 2006  Jose Luis Nunez
--  
-----------------------------------------------------------------------------
-- Entity: 	
-- File:	macroblock_data.vhd
-- Author:	Jose Luis Nunez 
-- Description:	macroblock data 5x5 macroblocks 
------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.Numeric_STD.all;

entity macroblock_data1 is
    port(
      clk : in std_logic;
      reset : in std_logic;
      clear : in std_logic;
      addr : in std_logic_vector (4 downto 0);
      data : out std_logic_vector (63 downto 0)
      );
end;


architecture rtl of macroblock_data1 is

signal data_int: std_logic_vector(63 downto 0);

subtype word is integer range 0 to 255;
type mem is array (0 to 255) of word;

signal memory : mem := ( 
16#3E#,16#48#,16#44#,16#48#,16#46#,16#41#,16#40#,16#40#,16#45#,16#4A#,16#4A#,16#46#,16#45#,16#3F#,16#47#,16#4D#,
16#46#,16#45#,16#42#,16#3C#,16#42#,16#43#,16#43#,16#44#,16#41#,16#43#,16#41#,16#42#,16#45#,16#46#,16#4D#,16#47#,
16#47#,16#3E#,16#45#,16#42#,16#42#,16#45#,16#40#,16#3C#,16#3C#,16#41#,16#41#,16#45#,16#42#,16#44#,16#47#,16#41#,
16#46#,16#44#,16#43#,16#46#,16#42#,16#40#,16#3D#,16#39#,16#3D#,16#3C#,16#3B#,16#40#,16#41#,16#44#,16#42#,16#44#,
16#43#,16#41#,16#3D#,16#3E#,16#3D#,16#3E#,16#41#,16#42#,16#44#,16#3F#,16#3D#,16#3D#,16#41#,16#44#,16#42#,16#42#,
16#40#,16#3E#,16#40#,16#39#,16#39#,16#44#,16#4B#,16#4D#,16#4C#,16#4E#,16#4D#,16#44#,16#3F#,16#3D#,16#40#,16#41#,
16#41#,16#45#,16#3F#,16#37#,16#3E#,16#4A#,16#3D#,16#2C#,16#2D#,16#35#,16#43#,16#4B#,16#44#,16#3B#,16#40#,16#45#,
16#40#,16#3E#,16#39#,16#3E#,16#4A#,16#45#,16#2E#,16#25#,16#2C#,16#2E#,16#39#,16#4B#,16#4C#,16#40#,16#3C#,16#40#,
16#43#,16#3D#,16#38#,16#41#,16#4C#,16#2B#,16#55#,16#AD#,16#A9#,16#81#,16#4A#,16#39#,16#4B#,16#48#,16#3B#,16#3B#,
16#48#,16#48#,16#3F#,16#44#,16#40#,16#4A#,16#BD#,16#FF#,16#ED#,16#E0#,16#9A#,16#43#,16#41#,16#4B#,16#3C#,16#3F#,
16#40#,16#40#,16#3B#,16#49#,16#36#,16#5E#,16#F7#,16#ED#,16#BB#,16#EB#,16#C8#,16#4D#,16#3B#,16#4E#,16#3A#,16#32#,
16#38#,16#39#,16#39#,16#44#,16#3F#,16#37#,16#A5#,16#EF#,16#D9#,16#D3#,16#93#,16#3F#,16#42#,16#4E#,16#3C#,16#1A#,
16#3C#,16#41#,16#45#,16#41#,16#47#,16#33#,16#28#,16#81#,16#AC#,16#7D#,16#4F#,16#46#,16#4E#,16#40#,16#45#,16#64#,
16#47#,16#48#,16#49#,16#3F#,16#3E#,16#40#,16#1F#,16#22#,16#37#,16#30#,16#39#,16#49#,16#4C#,16#36#,16#49#,16#C0#,
16#4D#,16#3C#,16#28#,16#34#,16#3A#,16#40#,16#44#,16#2B#,16#20#,16#32#,16#44#,16#44#,16#3F#,16#3D#,16#40#,16#64#,
16#8#,16#2C#,16#7E#,16#61#,16#39#,16#43#,16#3C#,16#3D#,16#44#,16#3F#,16#39#,16#40#,16#3D#,16#42#,16#42#,16#13#
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
