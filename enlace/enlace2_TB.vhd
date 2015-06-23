-- VHDL Test Bench Created from source file top_enlace.vhd -- 17:30:35 09/15/2010
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY top_enlace_enlace2_TB_vhd_tb IS
END top_enlace_enlace2_TB_vhd_tb;

ARCHITECTURE behavior OF top_enlace_enlace2_TB_vhd_tb IS 

	COMPONENT top_enlace
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		Led	: out std_logic_vector(7 downto 0); --nexys2
		an 	: out std_logic_vector(3 downto 0); --nexys2
		canalA: out std_logic_vector(7 downto 0); --nexys2
		canalB: out std_logic_vector(7 downto 0); --nexys2
		rxd : IN std_logic;
		picoB_ok : IN std_logic;
		addr_picoB : IN std_logic_vector(7 downto 0);
		Eram_picoB : IN std_logic;
		WEram_picoB : IN std_logic;
		data_in_ram_picoB : IN std_logic_vector(7 downto 0);
		cant_datos_picoB : IN std_logic_vector(7 downto 0);          
		error_uart : OUT std_logic;
		error_lrc : OUT std_logic;
		txd : OUT std_logic;
		data_out_ram_picoB : OUT std_logic_vector(7 downto 0);
		det_trama_ok_PB	: out std_logic;	--avisa cuando una trama est lista para usar
		gen_trama_ok_PB	: out std_logic	--avisa cuando una trama fue enviada por la uart
	);
	END COMPONENT;

	SIGNAL clk :  std_logic;
	signal Led  :  std_logic_vector(7 downto 0);
	signal an	:  std_logic_vector(3 downto 0);
	signal canalA: std_logic_vector(7 downto 0);
	signal canalB: std_logic_vector(7 downto 0);
	SIGNAL reset :  std_logic;
--	SIGNAL send_ram :  std_logic;
	SIGNAL rxd :  std_logic;
	SIGNAL error_uart :  std_logic;
	SIGNAL error_lrc :  std_logic;
--	SIGNAL leds :  std_logic_vector(7 downto 0);
	SIGNAL txd :  std_logic;
	SIGNAL picoB_ok :  std_logic;
	SIGNAL addr_picoB :  std_logic_vector(7 downto 0);
	SIGNAL Eram_picoB :  std_logic;
	SIGNAL WEram_picoB :  std_logic;
	SIGNAL data_in_ram_picoB :  std_logic_vector(7 downto 0);
	SIGNAL data_out_ram_picoB :  std_logic_vector(7 downto 0);
	SIGNAL cant_datos_picoB :  std_logic_vector(7 downto 0);
	SIGNAL det_trama_ok_PB	:  std_logic;	--avisa cuando una trama est lista para usar
	SIGNAL gen_trama_ok_PB	:  std_logic;	--avisa cuando una trama fue enviada por la uart

	signal comiezo		:	std_logic_vector(7 downto 0):= "01010101";
	signal segundo 	:	std_logic_vector(7 downto 0):= "11100111";
	signal punto		:  std_logic_vector(7 downto 0):= "00101110";
   signal dospuntos 	:	std_logic_vector(7 downto 0):= "00111010";		--: ascii
   signal cero	 		:	std_logic_vector(7 downto 0):= "00110000";		--0 ascii
	signal uno			:	std_logic_vector(7 downto 0):= "00110001";		--1 ascii
	signal dos			:	std_logic_vector(7 downto 0):= "00110010";		--2 ascii
	signal tres			:	std_logic_vector(7 downto 0):= "00110011";		--3 ascii
	signal cuatro		:	std_logic_vector(7 downto 0):= "00110100";		--4 ascii	
	signal cinco   	:	std_logic_vector(7 downto 0):= "00110101";		--5 ascii
	signal seis    	:	std_logic_vector(7 downto 0):= "00110110";		--6 ascii
	signal siete		:	std_logic_vector(7 downto 0):= "00110111";		--7 ascii
	signal ocho			:	std_logic_vector(7 downto 0):= "00111000";		--8 ascii
	signal nueve		:	std_logic_vector(7 downto 0):= "00111001";		--9 ascii
	signal la_a			:	std_logic_vector(7 downto 0):= "01000001";		--A ascii
	signal la_b			:	std_logic_vector(7 downto 0):= "01000010";		--B ascii
	signal la_c			:	std_logic_vector(7 downto 0):= "01000011";		--C ascii
	signal la_d			:	std_logic_vector(7 downto 0):= "01000100";		--D ascii
	signal la_e			:	std_logic_vector(7 downto 0):= "01000101";		--E ascii
	signal la_f			:	std_logic_vector(7 downto 0):= "01000110";		--F ascii
	signal cr			:	std_logic_vector(7 downto 0):= "00001101";		--CR ascii
	signal lf			:	std_logic_vector(7 downto 0):= "00001010";		--LF ascii
	
	signal buffer_rx  : std_logic_vector(7 downto 0):= "00000000";
	type arreglo_datos is array (60 downto 0) of std_logic_vector (7 downto 0);   
	signal datos : arreglo_datos;	   

	   -- Clock period definitions
   constant clk_period : time := 20ns;



BEGIN

	uut: top_enlace PORT MAP(
		clk => clk,
		reset => reset,
		Led => Led,
		an	=> an,
		canalA => canalA,
		canalB => canalB,
		rxd => rxd,
		error_uart => error_uart,
		error_lrc => error_lrc,
		txd => txd,
		picoB_ok => picoB_ok,
		addr_picoB => addr_picoB,
		Eram_picoB => Eram_picoB,
		WEram_picoB => WEram_picoB,
		data_in_ram_picoB => data_in_ram_picoB,
		data_out_ram_picoB => data_out_ram_picoB,
		cant_datos_picoB => cant_datos_picoB,
		det_trama_ok_PB  => det_trama_ok_PB,
		gen_trama_ok_PB  => gen_trama_ok_PB	
	);
    -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
-- *** Test Bench - User Defined Section ***
 tb : PROCESS
   BEGIN
   
		wait for 100ns;
		reset <= '1';
		addr_picoB <= "00000011";
		Eram_picoB <= '0';
		picoB_ok <= '0';
		wait for 100ns;
		reset <= '0';

--caracter erroneo 1		
		wait for 300us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= comiezo(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

--caracter erroneo 2		
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= segundo(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';
--*************************************************
--    RECEPCION
--*************************************************
    for j in 0 to 10 loop
 --trama dos puntos		
 		buffer_rx <= datos(j);
 		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= buffer_rx(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';
   end loop;
--*************************************************
--    RESPUESTA PICOBLAZE
--*************************************************
	wait for 4ms;
	cant_datos_picoB <= "00100000";--"00010000";
	picoB_ok <= '1';
	wait for 500ms;
	picoB_ok <= '0';
wait; -- will wait forever	
END PROCESS;
-- *** End Test Bench - User Defined Section ***

datos(0) <= dospuntos;
datos(1) <= uno;
datos(2) <= uno;

datos(3) <= cero;
datos(4) <= uno;

datos(5) <= cinco;--seis;
datos(6) <= cinco;--siete;

datos(7) <= siete;
datos(8) <= la_d;

datos(9) <= punto;
datos(10) <= la_a;


--datos(0) <= dospuntos;
--datos(1) <= uno;
--datos(2) <= uno;
--
--datos(3) <= cero;
--datos(4) <= siete;
--
--datos(5) <= cuatro;
--datos(6) <= seis;
--
--datos(7) <= la_a;
--datos(8) <= la_b;
--
--datos(9) <= la_e;
--datos(10) <= siete;
--
--datos(11) <= uno;
--datos(12) <= seis;
--
--datos(13) <= uno;
--datos(14) <= ocho;
--
--datos(15) <= siete;
--datos(16) <= la_e;
--
--datos(17) <= cinco;
--datos(18) <= la_f;
--
--datos(19) <= ocho;
--datos(20) <= siete;
--
--datos(21) <= cero;
--datos(22) <= cero;
--
--datos(23) <= uno;
--datos(24) <= cero;
--
--datos(25) <= seis;
--datos(26) <= la_d;
--
--datos(27) <= lf;
--datos(20) <= la_a;--cr;	

END;


