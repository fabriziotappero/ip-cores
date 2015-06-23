---------------------------------------------------------------------
-- File :			DDR2_Control_VHDL.vhd
-- Projekt :		Prj_12_DDR2
-- Zweck :			DDR2-Verwaltung (Init,Read,Write)
-- Datum :        19.08.2011
-- Version :      2.0
-- Plattform :    XILINX Spartan-3A
-- FPGA :         XC3S700A-FGG484
-- Sprache :      VHDL
-- ISE :				ISE-Design-Suite V:13.1
-- Autor :        UB
-- Mail :         Becker_U(at)gmx.de
---------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Clock_VHDL is
	--------------------------------------------
	-- Port Deklerationen
	--------------------------------------------
	port (
		clk_in_133MHz : in std_logic;
		clk_out_1Hz : out std_logic
	);
	
end Clock_VHDL;

architecture Verhalten of Clock_VHDL is

	--------------------------------------------
	-- Interne Signale
	--------------------------------------------
	constant STATUS_LED_VORTEILER : integer := 66500000; -- 1Hz bei 133MHz Quarzclock
	signal v_cnt1 : natural range 0 to STATUS_LED_VORTEILER  := 0;
	signal clk1Hz		: std_logic := '0';


begin

	-------------------------------------------------------
	-- erzeugen eines 1Hz Signales aus dem Eingangstakt
	-------------------------------------------------------
	Timer2 : process (clk_in_133MHz) begin
		if rising_edge(clk_in_133MHz) then
			v_cnt1 <= v_cnt1 + 1;
			if(v_cnt1 >= STATUS_LED_VORTEILER) then
				-- wenn zeit abgelaufen, signal toggeln
				v_cnt1 <= 0;
				clk1Hz <= not clk1Hz;
			end if;
		end if;
	end process Timer2;
	
	-------------------------------------------------------
	-- Uebergabe aller Signale
	-------------------------------------------------------		
	clk_out_1Hz<=clk1Hz;
	


end Verhalten;

