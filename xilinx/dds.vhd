-------------------------------------------------------------------------------
--	MiniGA
--  Author: Thomas Pototschnig (thomas.pototschnig@gmx.de)
--
--  License: Creative Commons Attribution-NonCommercial-ShareAlike 2.0 License
--           http://creativecommons.org/licenses/by-nc-sa/2.0/de/
--
--  If you want to use MiniGA for commercial purposes please contact the author
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dds is
    Port ( clk : in std_logic;
           reset : in std_logic;
			  phase : in std_logic_vector (1 downto 0);
			  addi : out std_logic_vector (8 downto 0);
			  data : out std_logic_vector (15 downto 0));
end dds;

architecture Behavioral of dds is

component dds_sinus
    Port ( clk : in std_logic;
           reset : in std_logic;
			  adr : in std_logic_vector (6 downto 0);
			  output1 : out std_logic_vector (15 downto 0));
end component;

signal adr : std_logic_vector (6 downto 0);
signal output : std_logic_vector (15 downto 0);

begin
I_O:	dds_sinus	port map ( clk => clk, reset => reset, adr => adr, output1 => output);

	
	process (clk, reset)
		variable step48 : unsigned (63 downto 0) :=   X"1938ECE0531174F2";
		variable ctr_48 : unsigned (63 downto 0) :=   X"FFC0000000000000";
		variable ctr90_48 : unsigned (63 downto 0):=  X"3FC0000000000000";
		variable ctr135_48 : unsigned (63 downto 0):= X"5FC0000000000000";
		variable ctr225_48 : unsigned (63 downto 0):= X"9FC0000000000000";
		variable curctr : unsigned (8 downto 0);
		
		variable abschnittu : unsigned (1 downto 0);
		variable indexu : unsigned (6 downto 0);
		

	begin
		if reset='0' then
			ctr_48 := X"FFC0000000000000";
			ctr90_48 := X"3FC0000000000000";
			ctr135_48 := X"5FC0000000000000";
			ctr225_48 := X"9FC0000000000000";
			data <= (others => '0');
		elsif clk'event and clk='1' then
			ctr_48 := ctr_48 + step48;
			ctr90_48 := ctr90_48 + step48;
			ctr135_48 := ctr135_48 + step48;
			ctr225_48 := ctr225_48 + step48;

			case phase is
				when "00" => curctr := ctr_48 (63 downto 55);
				when "01" => curctr := ctr90_48 (63 downto 55);
				when "10" => curctr := ctr135_48 (63 downto 55);
				when "11" => curctr := ctr225_48 (63 downto 55);
				when others => curctr := (others=>'0');
			end case;
			
			addi <= std_logic_vector(curctr);--(others => '0');--conv_std_logic_vector(curctr,9);
			
			indexu := curctr (6 downto 0);	-- index für die tabelle

			case abschnittu(1) is
				when '1' => data <= conv_std_logic_vector(-signed(output),16);
				when '0' => data <= conv_std_logic_vector(signed(output),16);
				when others => data <= (others=>'0');
			end case;

			abschnittu := curctr (8 downto 7);

			case abschnittu(0) is
				when '0' => adr <= conv_std_logic_vector(indexu,7);
				when '1' => adr <= conv_std_logic_vector(127-indexu,7);			
				when others => adr <= (others=>'0');
			end case;
		end if;
	end process;	
end Behavioral;
