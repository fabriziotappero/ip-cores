---------------------------------------------------------------------
-- File :			DDR2_Read_VHDL.vhd
-- Projekt :		Prj_12_DDR2
-- Zweck :			DDR2-Read-Funktion
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
	-- Die State-Machine liest
	-- einen 64Bit Wert aus dem RAM
	-- von 4 aufeinander folgenden 16bit-Zellen
	--
	-- die Adresse wird
	-- von der übergeordneten CONTROL-Unit
	-- gehandelt
	-- 
	-- solange die Read-Funktion läuft,
	-- ist READ_BUSY=1
	--------------------------------------------

entity DDR2_Read_VHDL is

	--------------------------------------------
	-- Port Deklerationen
	--------------------------------------------
	port (
		reset_in : in std_logic;
		clk_in : in std_logic;
		clk90_in : in std_logic;
		r_command_register : out std_logic_vector(2 downto 0);
		r_cmd_ack : in std_logic;
		r_burst_done : out std_logic;
		r_data_valid : in std_logic;
		read_en : in std_logic;
		read_busy : out std_logic;
		output_data : in std_logic_vector(31 downto 0);
		read_data : out std_logic_vector(63 downto 0)
	);
	
end DDR2_Read_VHDL;

architecture Verhalten of DDR2_Read_VHDL is

	--------------------------------------------
	-- Interne Signale
	--------------------------------------------
	
	signal v_data_lsb : std_logic_vector(31 downto 0):=(others => '0');
	signal v_data_msb : std_logic_vector(31 downto 0):=(others => '0');	
		
	constant CLK_ANZ : integer := 1;   -- warte 2 Clockzyklen (1 bis 0 = 2)
	signal v_counter :  natural range 0 to CLK_ANZ := CLK_ANZ;
	
	type STATE_RA_TYPE is (
		RA_1_NOP,
		RA_2_WAIT_4_ACK1,
		RA_3_WAIT_CLK,
		RA_4_SET_BURST,
		RA_5_SET_NOP,
		RA_6_WAIT_4_ACK0
	);
	signal STATE_RA : STATE_RA_TYPE := RA_1_NOP;

	type STATE_RB_TYPE is (
		RB_1_NOP,
		RB_2_WAIT_4_VALID1,
		RB_3_DATA_MSB,
		RB_4_WAIT_4_ACK0
	);
	signal STATE_RB : STATE_RB_TYPE := RB_1_NOP;	

begin

	-----------------------------------------
	-- State-Machine RA : (Clock-0 Lo-Flanke)
	--   1. wartet auf das READ_EN=1 von der DDR2_Control
	--   2. sendet das READ-Kommando an das RAM
	--   3. wartet auf das ACK=1 vom RAM
	--   4. wartet 2 Clockzyklen
	--      (solange dauert das lesen von 64Bit)
	--   5. legt das BURST_DONE-Signal für 2 Clockzyklen an
	--   6. wartet auf das ACK=0 vom RAM
	--   7. Sprung zu Punkt 1
	-----------------------------------------	
	P_Read_RA : process(clk_in,reset_in)
	begin		
		if reset_in = '1' then
			r_burst_done <= '0';	
			r_command_register <= "000";
			STATE_RA <= RA_1_NOP;
		elsif falling_edge(clk_in) then	
			-- Default Stellungen
			r_burst_done <= '0';	
			r_command_register <= "000";
			-- State-Machine
			case STATE_RA is
				when RA_1_NOP =>					
					-- warten auf read enable signal					
					v_counter <= CLK_ANZ;	
					if read_en = '1' then
						-- read enable wurde erkannt
						STATE_RA <= RA_2_WAIT_4_ACK1;
					end if;			
				when RA_2_WAIT_4_ACK1 =>
					-- READ-CMD anlegen
					-- warten auf ACK=1 signal	
					r_command_register <= "110";
					if r_cmd_ack = '1' then
						-- ack-signal wurde erkannt
						STATE_RA <= RA_3_WAIT_CLK;
					end if;
				when RA_3_WAIT_CLK =>				
					-- warte ein paar Clockzyklen
					r_command_register <= "110";
					if v_counter = 0 then						
						STATE_RA <= RA_4_SET_BURST;
					else						
						v_counter <= v_counter - 1;
					end if;
				when RA_4_SET_BURST =>
					r_command_register <= "110";
					r_burst_done <= '1';
					STATE_RA <= RA_5_SET_NOP;
				when RA_5_SET_NOP =>
					-- NOP-CMD anlegen	
					-- bei Burst_Done=Hi
					r_burst_done <= '1';
					STATE_RA <= RA_6_WAIT_4_ACK0;
				when RA_6_WAIT_4_ACK0 =>
					-- burst_done auf Lo
					-- warten auf ACK=0 signal									
					if r_cmd_ack = '0' then
						-- ack-signal wurde erkannt
						STATE_RA <= RA_1_NOP;
					end if;					
				when others =>
					NULL;
			end case;
		end if;
	end process P_Read_RA;

	-----------------------------------------
	-- State-Machine RB : (Clock-90 Hi-Flanke)
	--   1. wartet bis State-Machine-RA das
	--      READ-Kommando gesendet hat
	--   2. warte auf das DATA_VALID=1 vom RAM
	--   3. liest die LSB-Daten (32Bit) vom RAM
	--   4. wartet einen Clockzyklus
	--   5. liest die MSB-Daten (32Bit) vom RAM
	--   6. wartet auf das ACK=0 vom RAM
	--   7. Sprung zu Punkt 1
	-----------------------------------------	
	P_Read_RB : process(clk90_in,reset_in)
	begin
		if reset_in = '1' then
			-- reset button ist gedrueckt
			v_data_lsb <=  (others => '0');
			v_data_msb <=  (others => '0');
			STATE_RB <= RB_1_NOP;		
		elsif rising_edge(clk90_in) then
			case STATE_RB is
				when RB_1_NOP =>					
					-- warten bis Read enable								
					if STATE_RA = RA_2_WAIT_4_ACK1 then
						-- ack-signal wurde erkannt
						STATE_RB <= RB_2_WAIT_4_VALID1;
					end if;
				when RB_2_WAIT_4_VALID1 =>
					-- warte bis Daten Valid sind					
					if r_data_valid = '1' then
						-- LSB Daten sind ok
						v_data_lsb <= output_data;
						STATE_RB <= RB_3_DATA_MSB;
					else
						v_data_lsb <= v_data_lsb;
					end if;					
				when RB_3_DATA_MSB =>
					-- MSB Daten lesen
					if r_data_valid = '1' then
						-- MSB Daten sind ok	
						v_data_msb <= output_data;					  	
					else
						v_data_msb <= v_data_msb;
					end if;		
					STATE_RB <= RB_4_WAIT_4_ACK0;
				when RB_4_WAIT_4_ACK0 =>	
					-- warten auf ACK=0 vom RAM
					if r_cmd_ack = '0' then
						-- ack-signal wurde erkannt
						STATE_RB <= RB_1_NOP;
					end if;
				when others =>
					NULL;
			end case;			
		end if;
	end process P_Read_RB;
	
	
	-----------------------------------------
	-- Read-Busy erzeugen :
	-- solange der Read-Prozess im Gange
	-- ist READ_BUSY = 1	
	-----------------------------------------		
	read_busy <= '0' when STATE_RA=RA_1_NOP else '1';

	-----------------------------------------
	-- Read-Data uebergeben :
	-- 64Bit zusammengesetzt aus MSB & LSB
	-----------------------------------------		
	read_data <= v_data_msb & v_data_lsb;	

end Verhalten;

