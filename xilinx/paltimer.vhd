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

entity paltimer is
    Port ( clk : in std_logic;
			clk15m : in std_logic;
           reset : in std_logic;
			  en_sync : out std_logic;
			  en_schwarz : out std_logic;
			  en_bild : out std_logic;
			  en_vertbr : out std_logic;
			  en_verteq : out std_logic;
			  en_burst : out std_logic;
			  phase : out std_logic;
			  sync : out std_logic;
			  framereset : out std_logic;
			  readmem : out std_logic;
			  austastung : out std_logic);
			  
end paltimer;

architecture Behavioral of paltimer is

attribute clock_signal : string;

begin
	process (clk15m, reset)
	variable pixctr : integer := 0;
	variable hlctr : integer :=0;
	variable i_en_sync : std_logic := '0';
	variable i_en_sync_last : std_logic := '0';
	
	variable i_en_schwarz : std_logic := '0';
	variable i_en_bild : std_logic := '0';
	variable i_en_burst : std_logic := '0';
	variable i_en_vertbr : std_logic := '0';
	variable i_en_vertbr_last : std_logic := '0';
	variable i_en_verteq : std_logic := '0';
	variable i_austastung : std_logic := '0';
	variable i_framereset : std_logic := '0';
	variable i_sync : std_logic := '0';
	variable i_readmem : std_logic := '0';
	variable i_phase : std_logic := '0';
	variable i_sync_c : integer := 0;
	begin
		if reset='0' then
			pixctr := 0;
			hlctr :=0;
			i_en_sync := '0';
			i_en_schwarz := '0';
			i_en_bild := '0';
			i_en_burst := '0';
			i_en_vertbr := '0';
			i_en_verteq := '0';
			i_austastung := '0';
			i_framereset := '0';
			i_sync := '0';
			i_readmem := '0';
			i_phase := '0';
			
			en_sync <= '0';
			en_schwarz <= '0';
			en_bild <= '0';
			en_vertbr <= '0';
			en_verteq <= '0';
			en_burst <= '0';
			phase <= '0';
			sync <= '0';
			framereset <= '1';
			readmem <= '0';
			austastung <= '0';			
		elsif clk15m'event and clk15m='1' then
			pixctr:=pixctr+1;
			if pixctr = 960 then
				pixctr:=0;
			end if;
		
			if pixctr >=  0  AND pixctr <=  70  then
				i_en_sync := '1';
			else
				i_en_sync := '0';
			end if;
-- flanke nochmal checken ...
			if i_en_sync ='0' and i_en_sync_last='1' then
				i_phase := NOT i_phase;
			end if;

			i_en_sync_last := i_en_sync;

			if (pixctr >=  0  AND pixctr <=  157 ) then
				i_en_schwarz := '1';
			elsif (pixctr >=  938  AND pixctr <=  959 ) then
				i_en_schwarz := '1';
			else
				i_en_schwarz := '0';
			end if;

			if pixctr >=  158  AND pixctr <=  937  then
				i_en_bild := '1';
			else
				i_en_bild := '0';
			end if;

			if pixctr >=  81  AND pixctr <=  118  then
				i_en_burst := '1';
			else
				i_en_burst := '0';
			end if;


			if pixctr >=  0  AND pixctr <=  408  then
				i_en_vertbr := '1';
			elsif pixctr >=  480  AND pixctr <=  888  then
				i_en_vertbr := '1';
			else
				i_en_vertbr := '0';
			end if;

			if pixctr >=  0  AND pixctr <=  34  then
				i_en_verteq := '1';
			elsif pixctr >=  480  AND pixctr <=  514  then
				i_en_verteq := '1';
			else
				i_en_verteq := '0';
			end if;
			
			if i_en_vertbr='1' and i_en_vertbr_last='0' then
				hlctr:=hlctr+1;

				if hlctr = 1250 then
					hlctr:=0;
					i_framereset := '1';
				else
					i_framereset := '0';			
				end if;
				
				if hlctr >= 0 and hlctr <=  4  then
					i_sync_c := 1;
				elsif hlctr >=  5  and hlctr <=  9  then
					i_sync_c := 2;
				elsif hlctr >=  10  and hlctr <=  619  then
					i_sync_c := 3;
				elsif hlctr >=  620  and hlctr <=  624  then
					i_sync_c := 2;
				elsif hlctr >=  625  and hlctr <=  629  then
					i_sync_c := 1;
				elsif hlctr >=  630  and hlctr <=  634  then
					i_sync_c := 2;
				elsif hlctr >=  635  and hlctr <=  1244  then
					i_sync_c := 3;
				elsif hlctr >=  1245  and hlctr <=  1249  then
					i_sync_c := 2;
				else
					i_sync_c := 0;
				end if;

				if hlctr >=  1245  and hlctr <=  1249  then
					i_austastung := '1';
				elsif hlctr >=  0  and hlctr <=  44  then
					i_austastung := '1';
				elsif hlctr >=  620  and hlctr <=  668  then
					i_austastung := '1';
				else
					i_austastung := '0';
				end if;

				if hlctr >=  42  and hlctr <=  617  then
					i_readmem := '1';
				elsif hlctr >=  668  and hlctr <=  1241  then
					i_readmem := '1';
				else
					i_readmem := '0';
				end if;
			end if;

			i_en_vertbr_last := i_en_vertbr;
		
			case i_sync_c is
				when 0 => i_sync := '0';
				when 1 => i_sync := i_en_vertbr;
				when 2 => i_sync := i_en_verteq;
				when 3 => i_sync := i_en_sync;
				when others => i_sync := '0';
			end case; 
					
			phase <= i_phase;
			en_sync <= i_en_sync;
			en_schwarz <= i_en_schwarz;
			en_bild <= i_en_bild;
			en_vertbr <= i_en_vertbr;
			en_verteq <= i_en_verteq;
			en_burst <= i_en_burst;
			readmem <= i_readmem;
			sync <= NOT i_sync;
			austastung <= NOT i_austastung;
			framereset <= i_framereset;
		end if;
	end process;

end Behavioral;
