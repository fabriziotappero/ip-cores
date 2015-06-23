---------------------------------------------------------------------
-- File :			DDR2_Write_VHDL.vhd
-- Projekt :		Prj_12_DDR2
-- Zweck :			DDR2-Write-Funktion
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

	--------------------------------------------
	-- Beschreibung :
	--
	-- Die State-Machine schreibt
	-- einen 64Bit Wert ins RAM
	-- in 4 aufeinander folgenden 16bit-Zellen
	--
	-- die Adresse wird
	-- von der übergeordneten CONTROL-Unit
	-- gehandelt
	-- 
	-- solange die Write-Funktion läuft,
	-- ist WRITE_BUSY=1
	--------------------------------------------

entity DDR2_Write_VHDL is

	--------------------------------------------
	-- Port Deklerationen
	--------------------------------------------
	port (
		reset_in : in std_logic;
		clk_in : in std_logic;
		clk90_in : in std_logic;
		w_command_register : out std_logic_vector(2 downto 0);
		w_cmd_ack : in std_logic;
		w_burst_done : out std_logic;
		write_en : in std_logic;
		write_busy : out std_logic;
		input_data : out std_logic_vector(31 downto 0);
		write_data : in std_logic_vector(63 downto 0)
	);
	
end DDR2_Write_VHDL;

architecture Verhalten of DDR2_Write_VHDL is

	--------------------------------------------
	-- Interne Signale
	--------------------------------------------
	
	constant CLK_ANZ : integer := 2; -- warte 3 Clockzyklen (2 bis 0 = 3)	
	signal v_counter :  natural range 0 to CLK_ANZ := CLK_ANZ;
	
	type STATE_WA_TYPE is (
		WA_1_NOP,
		WA_2_WRITE_CMD,
		WA_3_WAIT_4_ACK1,
		WA_4_WAIT_3_CLK,
		WA_5_BURST_HI,
		WA_6_BURST_OK,
		WA_7_WAIT_4_ACK0
	);
	signal STATE_WA : STATE_WA_TYPE := WA_1_NOP;

	type STATE_WB_TYPE is (
		WB_1_NOP,
		WB_2_DATA_LSB,
		WB_3_T1,
		WB_4_T2,
		WB_5_DATA_MSB
	);
	signal STATE_WB : STATE_WB_TYPE := WB_1_NOP;		

begin

	-----------------------------------------
	-- State-Machine WA : (Clock-0 Lo-Flanke)
   --   1. wartet auf das WRITE_EN=1 von der DDR2_Control
	--   2. sendet das WRITE-Kommando an das RAM
	--   3. wartet auf das ACK=1 vom RAM
	--   4. wartet 3 Clockzyklen
	--      (solange dauert das schreiben von 64Bit)
	--   5. legt das BURST_DONE-Signal für 2 Clockzyklen an
	--   6. wartet auf das ACK=0 vom RAM
	--   7. Sprung zu Punkt 1
	-----------------------------------------	
	P_Write_WA : process(clk_in,reset_in)
	begin
		if reset_in = '1' then
			-- reset button ist gedrueckt
			STATE_WA <= WA_1_NOP;
			w_command_register <= "000"; -- NOP
			w_burst_done <= '0';
		elsif falling_edge(clk_in) then
			case STATE_WA is
				when WA_1_NOP =>		
					-- warte auf write enable signal
					w_command_register <= "000"; -- NOP
					v_counter <= CLK_ANZ;
					w_burst_done <= '0';
					if write_en = '1' then
						STATE_WA <= WA_2_WRITE_CMD;						
					end if;								
				when WA_2_WRITE_CMD =>
					-- CMD anlegen
					w_command_register <= "100"; -- WRITE-CMD
					STATE_WA <= WA_3_WAIT_4_ACK1;										
				when WA_3_WAIT_4_ACK1 =>
					-- warten auf ACK=1 vom RAM
					if w_cmd_ack = '1' then
						STATE_WA <= WA_4_WAIT_3_CLK;
					end if;					
				when WA_4_WAIT_3_CLK =>
					-- warte 3 Clockzyklen
					if v_counter = 0 then
						-- burst_done auf HI
						w_burst_done <= '1';
						STATE_WA <= WA_5_BURST_HI;						
					else
						w_burst_done <= '0';
						v_counter <= v_counter - 1;
					end if;	
				when WA_5_BURST_HI =>
					-- NOP anlegen
					w_command_register <= "000"; -- NOP
					STATE_WA <= WA_6_BURST_OK;
				when WA_6_BURST_OK =>
					-- burst_done auf Lo
					w_burst_done <= '0';
					STATE_WA <= WA_7_WAIT_4_ACK0;
				when WA_7_WAIT_4_ACK0 =>
					-- warten auf ACK=0 vom RAM
					if w_cmd_ack = '0' then
						STATE_WA <= WA_1_NOP;
					end if;					
				when others =>
					NULL;
			end case;
		end if;
	end process P_Write_WA;

	-----------------------------------------
	-- State-Machine WB : (Clock-90 Hi-Flanke)
	--   1. wartet bis State-Machine-WA das
	--      WRITE-Kommando gesendet hat
	--   2. legt die LSB-Daten (32Bit) für das RAM an
	--   3. wartet auf das ACK=1 vom RAM
	--   4. wartet nochmal 2 Clockzyklen (WICHTIG !!)
	--   5. legt die MSB-Daten (32Bit) für das RAM an
	--   6. wartet bis State-Machine-WA das
	--      BURST_DONE-Signal angelegt hat
	--   7. Sprung zu Punkt 1
	-----------------------------------------	
	P_Write_WB : process(clk90_in,reset_in)
	begin
		if reset_in = '1' then
			-- reset button ist gedrueckt
			STATE_WB <= WB_1_NOP;
			input_data <= (others => '0');
		elsif rising_edge(clk90_in) then
			case STATE_WB is
				when WB_1_NOP =>
					-- warte bis write start
					input_data <= (others => '0');
					if STATE_WA = WA_2_WRITE_CMD then
						STATE_WB <= WB_2_DATA_LSB;						
					end if;
				when WB_2_DATA_LSB =>
					-- Daten (LSB) anlegen
					-- und warten auf ACK
					input_data <= write_data(31 downto 0);
					if w_cmd_ack = '1' then
						STATE_WB <= WB_3_T1;
					end if;
				when WB_3_T1 =>
					input_data <= write_data(31 downto 0);					
					STATE_WB <= WB_4_T2;					
				when WB_4_T2 =>
					input_data <= write_data(31 downto 0);					
					STATE_WB <= WB_5_DATA_MSB;					
				when WB_5_DATA_MSB =>
					-- Daten (MSB) anlegen
					-- und warten bis Write fertig
					input_data <= write_data(63 downto 32);
					if STATE_WA = WA_5_BURST_HI then
						STATE_WB <= WB_1_NOP;
					end if;
				when others =>
					NULL;
			end case;
		end if;
	end process P_Write_WB;
	
	-----------------------------------------
	-- Write-Busy erzeugen :
	-- solange der Write-Prozess im Gange
	-- ist WRITE_BUSY = 1
	-----------------------------------------		
	write_busy <= '0' when STATE_WA=WA_1_NOP else '1';	

end Verhalten;

