------------------------------------
-- SINGLE PORT BLOCKRAM INFERENCE --
------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;
--use IEEE.NUMERIC_STD.ALL;

entity sp_ram is
		generic (data_width : integer := 32;
					addr_width : integer := 8);
		port (
			clka: IN std_logic;
			wea: IN std_logic_vector(0 downto 0); --direct drop-in replacement of coregen's spram
			addra: IN std_logic_vector(addr_width-1 downto 0);
			dina: IN std_logic_vector(data_width-1 downto 0);
			douta: OUT std_logic_vector(data_width-1 downto 0));
end sp_ram;

architecture sp_ram_arch of sp_ram is

	type mem_type is array (2**addr_width-1 downto 0) of std_logic_vector(data_width-1 downto 0);
	signal mem: mem_type; --Synplicity may need it to infer the RAM
	
	--attribute syn_ramstyle : string; --Synplicity may need it to infer the RAM
	--attribute syn_ramstyle of mem : signal is "block_ram"; --Synplicity may need it to infer the RAM
begin
	mem_write : process (clka)
	begin
		if (clka = '1' and clka'event) then
			--douta <= mem(to_integer(unsigned(addra))); --read first ram
         douta <= mem(conv_integer(addra)); --read first ram
			if (wea(0) = '1') then
				mem(conv_integer(addra)) <= dina;
			end if;
		end if;
	end process mem_write;
end sp_ram_arch;