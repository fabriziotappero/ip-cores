library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gen_lrc is
	port(
		clk		:in std_logic;	 				--clk
		reset	:in std_logic;					--reset
		new_data	:in std_logic;					--nuevo valor a leer
		trama	:in std_logic;					--suma válida
		dato_trama:in std_logic_vector(7 downto 0);	--dato desde la ram
		lrc_bin	:out std_logic_vector(7 downto 0));--valor del lrc calculado
end gen_lrc;

architecture Behavioral of gen_lrc is
signal acumulador	:std_logic_vector(7 downto 0):=(others=>'0');
begin
SUMADOR:process (clk) 
begin
   if reset='1' then 
      acumulador <= (others => '0');
   elsif (clk'event and clk='1') then
   	if new_data='1' and trama = '1' then --tener presente que data_ok debe permanecer SOLO 1 clk
         acumulador <= acumulador + dato_trama;
	end if;
   end if;
end process SUMADOR;
lrc_bin <= (not acumulador + 1) when trama = '0' else	
			"00000000";
end Behavioral;
