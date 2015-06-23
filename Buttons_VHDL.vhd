---------------------------------------------------------------------
-- File :			Buttons_VHDL.vhd
-- Projekt :		Prj_12_DDR2
-- Zweck :			Buttons und Schalter entprellen
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
	-- hier werden die Buttons und Schalter
	-- mit dem Clock syncronisiert
	--
	-- weil die Taster prellen
	-- werden sie mit einer Verzögerung eingelesen
	-- sonst kommt es zu anzeigefehlern
	--
	-- damit die Read/Write Funktionen
	-- bei gedruecktem Button nicht
	-- staendig aufgerufen werden,
	-- wird aus allen 4 Buttons
	-- ein OnClick-Eregnis gemacht
	--------------------------------------------
	
entity Buttons_VHDL is

	--------------------------------------------
	-- Port Deklerationen
	--------------------------------------------
	port (
		clk_in : in std_logic;
		button_in : in std_logic_vector(3 downto 0);
		switch_in : in std_logic_vector(3 downto 0);
		debounce_out : out std_logic_vector(7 downto 0);
		risingedge_out : out std_logic_vector(3 downto 0)
	);
		
end Buttons_VHDL;

architecture Verhalten of Buttons_VHDL is

	--------------------------------------------
	-- Interne Signale
	--------------------------------------------
	signal v_debounce : std_logic_vector(7 downto 0) := (others => '0');
	signal v_btn_old : std_logic_vector(3 downto 0):= (others => '0');	
	signal v_btn_tic : std_logic_vector(3 downto 0):= (others => '0');	
	
	-- verzoegerung für die tasten, weil sie prellen	
	constant BUTTON_SLEEP : integer := 6650000; -- Zeit = 50ms bei 133MHz Quarz 
	signal v_counter :  natural range 0 to BUTTON_SLEEP := BUTTON_SLEEP; 	

begin

	-----------------------------------------
	-- Einclocken von Asyncronen Signalen
	-----------------------------------------
	P_ASYNC : process(clk_in)
	begin
		if falling_edge(clk_in) then
			if v_counter = 0 then
				-- wenn Verzögerungszeit um, die zustände der 
			   -- buttons und schalter übergeben
				v_counter <= BUTTON_SLEEP;
				v_debounce(3 downto 0) <= button_in(3 downto 0);
				v_debounce(7 downto 4) <= switch_in(3 downto 0);
			else
				v_counter <= v_counter -1;			
			end if;								
		end if;
	end process P_ASYNC;
	
	-- übergabe der Signale------------------
	debounce_out <= v_debounce;
	
	-----------------------------------------
	-- Aus den Tastern jeweils ein
	-- einzelnes 1Clock langes Signal machen,
	-- bis der Taser wieder verlassen ist
	-- damit die Funktionen (+/-, read,write)
	-- nur einmal ausgeführt werden
	-----------------------------------------
	P_Buttons : process(clk_in)
	begin
		if falling_edge(clk_in) then
			-- TIC merker zurücksetzen
			v_btn_tic(3 downto 0) <= "0000";
		
			-- button east-------------------------------			
			if v_debounce(0)='1' and v_btn_old(0)='0' then
				v_btn_old(0) <= '1';
				v_btn_tic(0) <= '1';
			elsif v_debounce(0)='0' and v_btn_old(0)='1' then
				v_btn_old(0) <= '0';
			end if;
			
			-- button north-----------------------------			
			if v_debounce(1)='1' and v_btn_old(1)='0' then
				v_btn_old(1) <= '1';
				v_btn_tic(1) <= '1';
			elsif v_debounce(1)='0' and v_btn_old(1)='1' then
				v_btn_old(1) <= '0';
			end if;
			
			-- button south-----------------------------			
			if v_debounce(2)='1' and v_btn_old(2)='0' then
				v_btn_old(2) <= '1';
				v_btn_tic(2) <= '1';
			elsif v_debounce(2)='0' and v_btn_old(2)='1' then
				v_btn_old(2) <= '0';
			end if;	
			
			-- button west------------------------------			
			if v_debounce(3)='1' and v_btn_old(3)='0' then
				v_btn_old(3) <= '1';
				v_btn_tic(3) <= '1';
			elsif v_debounce(3)='0' and v_btn_old(3)='1' then
				v_btn_old(3) <= '0';
			end if;			
		end if;
	end process P_Buttons;	
	
	-- übergabe der Signale------------------
	risingedge_out <= v_btn_tic;

end Verhalten;

