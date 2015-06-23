-------------------------------------------------------------------------------
--	MiniGA
--  Author: Thomas Pototschnig (thomas.pototschnig@gmx.de)
--
--  License: Creative Commons Attribution-NonCommercial-ShareAlike 2.0 License
--           http://creativecommons.org/licenses/by-nc-sa/2.0/de/
--
--  If you want to use MiniGA for commercial purposes please contact the author
-------------------------------------------------------------------------------
-- Cycle-Shared-RAM
-- clk4x = 60MHz
-- Effektiv ergeben sich 30MB/sec pro Bus

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity csr is
	generic (
		ADR_WIDTH : integer := 19; -- A0 bis A18
		DATA_WIDTH : integer := 16 -- D0 bis D15
	);
	port (
		clk4x : in std_logic;
		reset : in std_logic;
		clk : in std_logic;
		sync : in std_logic;

-- ram
		ram_adr : out std_logic_vector ((ADR_WIDTH-1) downto 0);
		ram_data: inout std_logic_vector ((DATA_WIDTH-1) downto 0);
		ram_rd : out std_logic;
		ram_wr : out std_logic;
		ram_cs : out std_logic;	

		adr1 : in std_logic_vector ((ADR_WIDTH-1) downto 0);
		data1_in : in std_logic_vector ((DATA_WIDTH-1) downto 0);
		data1_out : out std_logic_vector ((DATA_WIDTH-1) downto 0);
		rd1 : in std_logic;
		wr1 : in std_logic;
		
		adr2 : in std_logic_vector ((ADR_WIDTH-1) downto 0);
		data2_in : in std_logic_vector ((DATA_WIDTH-1) downto 0);
		data2_out : out std_logic_vector ((DATA_WIDTH-1) downto 0);
		rd2 : in std_logic;
		wr2 : in std_logic
	);
end csr;

architecture behaviour of csr is

begin
-- immer 16bit zugriffe!

	process (clk4x, reset) 
	variable state : integer := -1;
	begin
		if reset='0' then
			ram_data <= (others => 'Z');
			ram_rd <= '1';
			ram_wr <= '1';
			ram_adr <= (others => '0');
	
			data1_out <= (others => '0');
			data2_out <= (others => '0');
			ram_cs <= '1';
			state := 4;
		elsif clk4x'event and clk4x='0' then
			case state is
				when 0 =>
					if rd2='0' and wr2='1' then
						data2_out <= ram_data;
					end if;					
					ram_rd <= '1';
					ram_wr <= '1';

					ram_adr <= adr1;
					ram_cs <= '0';
					
-- auf Datenbussen rausschreiben
					if wr1='0' and rd1='1' then
						ram_data <= data1_in;
					else
						ram_data <= (others => 'Z');
					end if;
					
					state := 1;
				when 1 =>
-- beim lesen nur vom selektierten SRAM lesen				
					ram_rd <= rd1;
					ram_wr <= wr1;				

					state := 2;
				when 2 => 
					if rd2='0' and wr2='1' then
						data1_out <= ram_data;
					end if;

					ram_rd <= '1';
					ram_wr <= '1';

					ram_adr <= adr2;
					ram_cs <= '0';
-- auf Datenbussen rausschreiben
					if wr2='0' and rd2='1' then
						ram_data <= data2_in;
					else
						ram_data <= (others => 'Z');
					end if;
					
					state := 3;
				when 3 =>
					ram_rd <= rd2;
					ram_wr <= wr2;				
					state := 0;
-- statemachine mit dem 15MHz clock synchronisieren					
				when 4 =>
					if sync='1' then
						state := 5;
					end if;
				when 5 =>
				    state := 6;
				when 6 =>
				    state := 0;
				when 7 => 
				    state := 0;
				when others => 
					state:=0;
			end case;
		end if;	
	end process;


end architecture;
