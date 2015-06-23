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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

	--------------------------------------------
	-- Beschreibung :
	--
	-- das DDR2-RAM hat 512 MBit (64MByte) Speicherplatz
	-- organisiert in 16Bit Woertern
	--
	-- es werden immer Datenworte von 64Bit ausgelesen
	-- oder geschrieben (weil der Burst-Mode auf 4 steht)
	-- aus dem Grund ist der Daten-Vektor für Read/Write
	-- 64Bit breit
	--
	-- das RAM ist ein 4 Blöcke unterteilt (zu je 16Mbyte)
	-- Bank "00" bis Bank "11" : 2Bit
	--
	-- jeder Block ist in 8192 Reihen zu je 1024 Spalten organisiert
	-- ROW "0000000000000" bis "1111111111111" : 13Bit
	-- COL "0000000000" bis "1111111111" : 10Bit
	--
	-- die übergebene Adresse an die FIFO Komponente
	-- mit 25 Bit setzt sich dann so zusammen
	--
	-- input_adress =  ROW & COL & BANK
	--    (25Bit)     13Bit 10Bit  2Bit
	-- pro Adresse stehen 16bit Daten
	-- 
	-- in diesem Demo-Programm wird nur Bank=0
	-- COL=0 und ROW= 0 bis 15 benutzt
	---------------------------------------------
	--
	-- das CONTROL steuert die READ und WRITE funktion
	-- je nachdem welcher Button gedrückt wurde
	--
	--------------------------------------------
	-- Vorsicht !! zur Adressierung :
	-- Der Burst-Mode steht FIX auf "4"
	-- damit werden IMMER 4 (16bit) Zellen gelesen
	-- und beschrieben (also imer 64Bit)
	--
	-- wenn also das 64bit Wort "123456789ABCDEF0" in Adr 0
	-- geschrieben wird, sieht der Speicher danach so aus :
	-- Row 0 Col 0 = "1234"
	-- Row 0 Col 1 = "5678"
	-- Row 0 Col 2 = "9ABC"
	-- Row 0 Col 3 = "DEF0"
	--
	-- Der Col-Counter muss also immer um 4 Adressen
	-- incrementiert / decrementiert werden
	--
	-- in der Demo hier wird nur der ROW-Counter verändert
	-- 
	--------------------------------------------



entity DDR2_Control_VHDL is

	--------------------------------------------
	-- Port Deklerationen
	--------------------------------------------
	port (
		reset_in : in std_logic;
		clk_in : in std_logic;
		clk90_in : in std_logic;		
		init_done : in std_logic;
		command_register : out std_logic_vector(2 downto 0);
		input_adress : out std_logic_vector(24 downto 0);
		input_data : out std_logic_vector(31 downto 0);
		output_data : in std_logic_vector(31 downto 0);
		cmd_ack : in std_logic;
		data_valid : in std_logic;
		burst_done : out std_logic;
		auto_ref_req : in std_logic;
		debounce_in : in std_logic_vector(7 downto 0);
		risingedge_in : in std_logic_vector(3 downto 0);
		data_out : out std_logic_vector(7 downto 0)
	);

end DDR2_Control_VHDL;

architecture Verhalten of DDR2_Control_VHDL is

	--------------------------------------------
	-- Einbinden einer Componente
	-- zum schreiben eines 64Bit Wertes
	--------------------------------------------
	COMPONENT DDR2_Write_VHDL
	PORT (
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
	END COMPONENT DDR2_Write_VHDL;
	
	--------------------------------------------
	-- Einbinden einer Componente
	-- zum lesen eines 64Bit Wertes
	--------------------------------------------
	COMPONENT DDR2_Read_VHDL
	PORT (
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
	END COMPONENT DDR2_Read_VHDL;	

	--------------------------------------------
	-- Interne Signale
	--------------------------------------------

	constant INIT_PAUSE : integer := 133000; -- pause 1ms (Wichtig !!)
	signal v_counter :  natural range 0 to INIT_PAUSE := INIT_PAUSE;	
	
	--------------------------------------------
	-- 16 Konstante Werte erzeugen, die beim INIT
	-- (Auto-Write) ins RAM geschrieben werden
	-- ein Wert ist 64Bit = 8 Byte breit
	--------------------------------------------
	constant MAX_ADR : integer := 15; -- 0 bis 15 = 16 Werte
	type RAM_DATA_TYP is array (0 to MAX_ADR) of std_logic_vector(63 downto 0);
	constant RAM_DATA : RAM_DATA_TYP :=
	(
		x"0123456789ABCDEF", x"123456789ABCDEF0", x"23456789ABCDEF01", x"3456789ABCDEF012",
		x"456789ABCDEF0123", x"56789ABCDEF01234", others => (x"639CC6398C7318E7")
	);
	signal v_array_pos :  natural range 0 to MAX_ADR+1 := 0;	
	
	--------------------------------------------
	-- Definition der ROW,COL,BANK adressen
	--------------------------------------------
	signal v_ROW : std_logic_vector(12 downto 0):= (others => '0'); -- 13Bit
	signal v_COL : std_logic_vector(9 downto 0):= (others => '0');  -- 10Bit
	signal v_BANK : std_logic_vector(1 downto 0):= (others => '0'); -- 2Bit
	
	-- zwischenspeicher fuer daten
	signal v_write_data : std_logic_vector(63 downto 0):= (others => '0');	
	signal v_read_data : std_logic_vector(63 downto 0):= (others => '0');		
	
	--------------------------------------------
	-- Ein Konstanter Wert, der mit WRITE-Button
	-- ins RAM geschrieben wird
	--------------------------------------------	
	constant CONST_DATA : std_logic_vector(63 downto 0):= x"31CE629DC43B8877";
	
	--------------------------------------------
	-- State-Machine-Typen
	--------------------------------------------	
	type STATE_M_TYPE is (
		M1_START_UP,
		M2_WAIT_4_DONE,
		M3_AUTO_WRITE_START,
		M4_AUTO_WRITE_INIT,
		M5_AUTO_WRITING,
		M6_AUTO_READ_INIT,
		M7_AUTO_READING,
		M8_NOP,
		M9_WRITE_INIT,
		M10_WRITING,
		M11_READ_INIT,
		M12_READING
	);
	signal STATE_M : STATE_M_TYPE := M1_START_UP;	
		
	--------------------------------------------
	-- sonstige Signale
	--------------------------------------------		
	signal v_write_en : std_logic:='0'; -- '1'=chip-select
	signal v_read_en : std_logic:='0'; -- '1'=chip-select
	signal v_write_busy : std_logic; -- '1'=belegt, '0'=frei
	signal v_read_busy : std_logic; -- '1'=belegt, '0'=frei
	signal v_main_command_register : std_logic_vector(2 downto 0):= (others => '0');
	signal v_write_command_register : std_logic_vector(2 downto 0):= (others => '0');
	signal v_read_command_register : std_logic_vector(2 downto 0):= (others => '0');
	signal v_write_burst_done : std_logic;
	signal v_read_burst_done : std_logic;	
	
begin

	--------------------------------------------------
	-- Instantz einer Componente erzeugen und verbinden
	-- zum schreiben eines 64Bit Wertes
	--------------------------------------------------
	INST_DDR2_Write_VHDL : DDR2_Write_VHDL
	PORT MAP (
		reset_in => reset_in,
		clk_in => clk_in,
		clk90_in => clk90_in,
		w_command_register => v_write_command_register,
		w_cmd_ack => cmd_ack,
		w_burst_done => v_write_burst_done,
		write_en => v_write_en,
		write_busy => v_write_busy,
		input_data => input_data,
		write_data => v_write_data
	);
	
	--------------------------------------------------
	-- Instantz einer Componente erzeugen und verbinden
	-- zum lesen eines 64Bit Wertes
	--------------------------------------------------
	INST_DDR2_Read_VHDL : DDR2_Read_VHDL
	PORT MAP (
		reset_in => reset_in,
		clk_in => clk_in,
		clk90_in => clk90_in,
		r_command_register => v_read_command_register,
		r_cmd_ack => cmd_ack,
		r_burst_done => v_read_burst_done,	
		r_data_valid => data_valid,	
		read_en => v_read_en,
		read_busy => v_read_busy,
		output_data => output_data,
		read_data => v_read_data
	);		

	-----------------------------------------
	-- State-Machine :
	--   1. wartet nach Reset 1ms
	--   2. sendet das INIT-Kommando an das RAM
	--   3. Wartet auf das INIT_DONE vom RAM
	--   4. Schreiben von 16 Datenwerten ins RAM
	--   5. Auslesen von Adr0
	--   6. Warte auf Tastendrück
	--
	--     7a. North/South = ändern der Adresse (ROW)
	--     7b. East = auslesen eines Wertes
	--     7c. West = schreiben eines Wertes
	--   8. Sprung zu Punkt 6
	-----------------------------------------	
	P_State_Main : process(clk_in,reset_in)
	begin
		if reset_in = '1' then
			-- reset button ist gedrueckt
			STATE_M <= M1_START_UP;
			v_write_en <= '0';
			v_read_en <= '0';
			v_main_command_register <= "000"; -- NOP
			v_counter <= INIT_PAUSE;			
			v_ROW <= (others => '0');	
			v_COL <= (others => '0');
			v_BANK <= (others => '0');
			v_array_pos	<= 0;
		elsif falling_edge(clk_in) then
			case STATE_M is
			   -----------------------------------------------------
				-- INITIALISIERUNG vom RAM : WICHTIG !! :
				-- nach dem Reset wird 1ms gewartet und danach
				-- wird das INIT-Kommando an das RAM gesendet
				-- und auf das Init-Done-Signal vom RAM gewartet
				-----------------------------------------------------
				when M1_START_UP =>
					-- warte 1ms nach Reset bis RAM bereit
					-- WICHTIG !! das steht so im Datasheet
					if v_counter = 0 then					
						-- nach 1ms INIT-Kommando (für einen Clock) anlegen
						STATE_M <= M2_WAIT_4_DONE;
						v_main_command_register <= "010";	-- INIT-CMD	
					else 
						v_main_command_register <= "000"; -- NOP
						v_counter <= v_counter - 1;
					end if;	
				when M2_WAIT_4_DONE =>
					-- warte auf Init-Done-Signal vom RAM
					v_main_command_register <= "000"; -- NOP
					if (init_done = '1') then
						-- das RAM ist jetzt bereit
						STATE_M <= M3_AUTO_WRITE_START;	
					end if;
			   -----------------------------------------------------
				-- automatisches schreiben von ein paar Werten :
				-- es werden 16 feste Datenwerte in die Adressen 0-15
				-- ins RAM geschrieben
				-----------------------------------------------------					
				when M3_AUTO_WRITE_START =>
					-- automatisches schreiben von daten ins RAM
					if v_array_pos > MAX_ADR then
						-- wenn alle adressen geschrieben sind
						STATE_M <= M6_AUTO_READ_INIT;
						v_ROW <= (others => '0');
					else
						if v_write_busy = '0' and auto_ref_req = '0' then
							-- wenn RAM nicht beschäftigt ist, starte das schreiben
							STATE_M <= M4_AUTO_WRITE_INIT;
						end if;
					end if;
				when M4_AUTO_WRITE_INIT =>					
					-- warten bis zum schreiben bereit
					if v_write_busy = '0' and v_write_en='0' then
						-- daten zum schreiben freigeben
						v_write_en <= '1';
					elsif v_write_busy = '1' and v_write_en='1' then
						-- daten werden geschrieben
						v_write_en <= '0';
						STATE_M <= M5_AUTO_WRITING;
					end if;
				when M5_AUTO_WRITING =>								
					-- warte bis schreiben fertig
					if v_write_busy = '0' then
						-- naechste adresse beschreiben						
						v_array_pos <= v_array_pos +1;
						v_ROW <= v_ROW +1;
						STATE_M <= M3_AUTO_WRITE_START;
					end if;	
			   -----------------------------------------------------
				-- automatisches lesen von einem Wert :
				-- es wird der Inhalt von Adr 0 vom RAM ausgelesen
				-----------------------------------------------------					
				when M6_AUTO_READ_INIT =>
					-- automatisches lesen vom RAM  (ein wert)
					-- warten bis zum lesen bereit
					if v_read_busy = '0' and v_read_en='0' and auto_ref_req = '0' then 
						-- daten zum lesen freigeben
						v_read_en <= '1';						
					elsif v_read_busy = '1' and v_read_en='1' then
						-- daten werden gelesen
						v_read_en <= '0';						
						STATE_M <= M7_AUTO_READING;
					end if;
				when M7_AUTO_READING =>
					-- warte bis lesen fertig
					if v_read_busy = '0' then						
						STATE_M <= M8_NOP;
					end if;					
			   -----------------------------------------------------
				-- Dauerloop : warten auf User-Eingabe :
				-- hier wird gewartet, bis einer der 4 Buttons
				-- gedrückt wurde
				-----------------------------------------------------						
				when M8_NOP =>
					-- warte auf Taste fuer READ oder WRITE
					v_write_en <= '0';
					v_read_en <= '0';					
					if risingedge_in(3) = '1' and v_write_busy = '0' and auto_ref_req = '0' then
						-- button = west
						-- write starten (nur wenn nicht busy und kein refresh-zyklus)
						STATE_M <= M9_WRITE_INIT;
					elsif risingedge_in(0) = '1' and v_read_busy = '0' and auto_ref_req = '0' then
					   -- button = east
						-- read starten (nur wenn nicht busy und kein refresh-zyklus)
						STATE_M <= M11_READ_INIT;
					end if;					
					-- warte auf Taste fuer Adr-Up oder Adr-Down								
					if risingedge_in(1)='1' and v_ROW < 255 then
						-- button = north
						v_ROW <= v_ROW + 1;
					elsif risingedge_in(2)='1' and v_ROW > 0 then
						-- button = south
						v_ROW <= v_ROW - 1;
					end if;
			   -----------------------------------------------------
				-- WRITE : schreiben eines Wertes ins RAM :
				-- ein fester Datenwert wird in die aktuelle Adresse
				-- ins RAM geschrieben
				-----------------------------------------------------						
				when M9_WRITE_INIT =>					
					-- warten bis zum schreiben bereit
					if v_write_busy = '0' and v_write_en='0' then
						-- daten zum schreiben freigeben
						v_write_en <= '1';
					elsif v_write_busy = '1' and v_write_en='1' then
						-- daten werden geschrieben
						v_write_en <= '0';
						STATE_M <= M10_WRITING;
					end if;
				when M10_WRITING =>								
					-- warte bis schreiben fertig
					if v_write_busy = '0' then
						STATE_M <= M8_NOP;
					end if;
			   -----------------------------------------------------
				-- READ : lesen eines Wertes vom RAM :
				-- die aktuelle Adresse vom RAM wird ausgelesen
				-----------------------------------------------------						
				when M11_READ_INIT =>					
					-- warten bis zum lesen bereit
					if v_read_busy = '0' and v_read_en='0' then 
						-- daten zum lesen freigeben
						v_read_en <= '1';
					elsif v_read_busy = '1' and v_read_en='1' then
						-- daten werden gelesen
						v_read_en <= '0';						
						STATE_M <= M12_READING;
					end if;
				when M12_READING =>
					-- warte bis lesen fertig
					if v_read_busy = '0' then						
						STATE_M <= M8_NOP;
					end if;									
				when others =>
					NULL;
			end case;
		end if;
	end process P_State_Main;	
	
	-----------------------------------------
	-- Weiterleitung von Signalen
	-- in Abhängigkeit von Read oder Write :
	-----------------------------------------	
	P_SIGNAL : process(clk_in)
	begin
		if falling_edge(clk_in) then
			if STATE_M=M4_AUTO_WRITE_INIT or STATE_M=M5_AUTO_WRITING then
			   -----------------------------------------------------
				-- automatisches schreiben von ein paar Werten
				-----------------------------------------------------	
				v_write_data <= RAM_DATA(v_array_pos);							
				input_adress <= v_ROW & v_COL & v_BANK;
				command_register <= v_write_command_register;
				burst_done <= v_write_burst_done;					
			elsif STATE_M=M6_AUTO_READ_INIT or STATE_M=M7_AUTO_READING then
			   -----------------------------------------------------
				-- automatisches lesen von einem Wert
				-----------------------------------------------------
				v_write_data <= (others => '0'); 				
				input_adress <= v_ROW & v_COL & v_BANK;
				command_register <= v_read_command_register;
				burst_done <= v_read_burst_done;				
			elsif STATE_M=M9_WRITE_INIT or STATE_M=M10_WRITING then
			   -----------------------------------------------------
				-- WRITE : schreiben eines Wertes ins RAM
				-----------------------------------------------------	
				v_write_data <= CONST_DATA;				
				input_adress <= v_ROW & v_COL & v_BANK;
				command_register <= v_write_command_register;
				burst_done <= v_write_burst_done;				
			elsif STATE_M=M11_READ_INIT or STATE_M=M12_READING then
			   -----------------------------------------------------
				-- READ : lesen eines Wertes vom RAM
				-----------------------------------------------------
				v_write_data <= (others => '0'); 				
				input_adress <= v_ROW & v_COL & v_BANK;
				command_register <= v_read_command_register;
				burst_done <= v_read_burst_done;				
			else
			   -----------------------------------------------------
				-- Dauerloop oder INIT
				-----------------------------------------------------	
				v_write_data <= (others => '0');				
				input_adress <= (others => '0');				
				command_register <= v_main_command_register;
				burst_done <= '0';				
			end if;
		end if;
	end process P_SIGNAL;
	
	-----------------------------------------
	-- Ausgabe der gelesenen Daten
	-- je nach Schalterstellung
	-----------------------------------------	
	P_DataOut : process(clk_in,reset_in)
	begin
		if reset_in = '1' then
			-- reset button ist gedrueckt
			data_out <= (others => '0');
		elsif falling_edge(clk_in) then
			if debounce_in(7 downto 5)="000" then data_out <= v_read_data(7 downto 0);
			elsif debounce_in(7 downto 5)="001" then data_out <= v_read_data(15 downto 8);
			elsif debounce_in(7 downto 5)="010" then data_out <= v_read_data(23 downto 16);
			elsif debounce_in(7 downto 5)="011" then data_out <= v_read_data(31 downto 24);
			elsif debounce_in(7 downto 5)="100" then data_out <= v_read_data(39 downto 32);
			elsif debounce_in(7 downto 5)="101" then data_out <= v_read_data(47 downto 40);
			elsif debounce_in(7 downto 5)="110" then data_out <= v_read_data(55 downto 48);
			elsif debounce_in(7 downto 5)="111" then data_out <= v_read_data(63 downto 56);
			end if;
			-------------------------------------------			
		end if;
	end process P_DataOut;

end Verhalten;

