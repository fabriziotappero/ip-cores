
-- VHDL Test Bench Created from source file top_enlace.vhd -- 18:01:39 07/21/2010
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

ENTITY top_enlace_enlace_TB_vhd_tb IS
END top_enlace_enlace_TB_vhd_tb;

ARCHITECTURE behavior OF top_enlace_enlace_TB_vhd_tb IS 

	COMPONENT top_enlace
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		send_ram : IN std_logic;
		rxd : IN std_logic;
		error_uart : OUT std_logic;
		error_lrc : OUT std_logic;
		leds : OUT std_logic_vector(7 downto 0);
		txd : OUT std_logic;
		picoB_ok			:in std_logic;
		addr_picoB		: in std_logic_vector (3 downto 0);
		Eram_picoB		: in std_logic;
		WEram_picoB		: in std_logic;
		data_in_ram_picoB	: in std_logic_vector (7 downto 0);
		data_out_ram_picoB	: in std_logic_vector (7 downto 0);
		cant_datos_picoB	: in std_logic_vector (7 downto 0)
		);
	END COMPONENT;

	SIGNAL clk :  std_logic;
	SIGNAL reset :  std_logic;
	SIGNAL send_ram :  std_logic;
	SIGNAL rxd :  std_logic:='1';
	SIGNAL picoB_ok : std_logic;
	SIGNAL addr_picoB		: std_logic_vector (3  downto 0);
	SIGNAL Eram_picoB		: std_logic;
	SIGNAL WEram_picoB		: std_logic;
	SIGNAL data_in_ram_picoB	: std_logic_vector (7 downto 0);
	SIGNAL data_out_ram_picoB: std_logic_vector (7 downto 0);
	SIGNAL cant_datos_picoB	: std_logic_vector (7 downto 0);
	SIGNAL error_uart :  std_logic;
	SIGNAL error_lrc  :  std_logic;
	SIGNAL leds :  std_logic_vector(7 downto 0);
	SIGNAL txd :  std_logic;
	signal comiezo	:	std_logic_vector(7 downto 0):= "01010101";
	signal segundo :	std_logic_vector(7 downto 0):= "11100111";
     signal dospuntos :	std_logic_vector(7 downto 0):= "00111010";		--: ascii
     signal cero	 :	std_logic_vector(7 downto 0):= "00110000";		--0 ascii
	signal uno	:	std_logic_vector(7 downto 0):= "00110001";		--1 ascii
	signal dos	:	std_logic_vector(7 downto 0):= "00110010";		--2 ascii
	signal tres	:	std_logic_vector(7 downto 0):= "00110011";		--3 ascii
	signal cuatro	:	std_logic_vector(7 downto 0):= "00110100";		--4 ascii	
	signal cinco   :	std_logic_vector(7 downto 0):= "00110101";		--5 ascii
	signal seis    :	std_logic_vector(7 downto 0):= "00110110";		--6 ascii
	signal siete	:	std_logic_vector(7 downto 0):= "00110111";		--7 ascii
	signal ocho	:	std_logic_vector(7 downto 0):= "00111000";		--8 ascii
	signal nueve	:	std_logic_vector(7 downto 0):= "00111001";		--9 ascii
	signal la_a	:	std_logic_vector(7 downto 0):= "01000001";		--A ascii
	signal la_b	:	std_logic_vector(7 downto 0):= "01000010";		--B ascii
	signal la_e	:	std_logic_vector(7 downto 0):= "01000101";		--E ascii
	signal la_f	:	std_logic_vector(7 downto 0):= "01000110";		--F ascii
	signal cr		:	std_logic_vector(7 downto 0):= "00001101";		--CR ascii
	signal lf		:	std_logic_vector(7 downto 0):= "00001010";		--LF ascii


	   -- Clock period definitions
   constant clk_period : time := 20ns;


BEGIN

	uut: top_enlace 
		PORT MAP(
		clk => clk,
		reset => reset,
		send_ram => send_ram,
		rxd => rxd,
		error_uart => error_uart,
		leds => leds,
		txd => txd,
		picoB_ok => picoB_ok,
		addr_picoB => addr_picoB,
		Eram_picoB => Eram_picoB,
		WEram_picoB	=> WEram_picoB,
		cant_datos_picoB => cant_datos_picoB,
		data_in_ram_picoB	=> data_in_ram_picoB,
		data_out_ram_picoB	=> data_out_ram_picoB
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
		send_ram <='0';
		addr_picoB <= "0011";
		Eram_picoB <= '0';
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
--     trama MODBUS 1
--*************************************************
 --trama dos puntos		
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= dospuntos(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dire alto 	 1 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= uno(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dire bajo 	 1 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= uno(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';


 --trama función alto 	 0 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= cero(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama función bajo 	 1 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= tres(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';


 --trama dato1 alto	 0 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= cero(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato1 bajo 	 0 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= cero(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato2 alto 	 6 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <=  seis(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato2 bajo	 b ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <=  la_b(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato3 alto	 0 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= cero(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato3 bajo 	 0 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= cero(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato4 alto	 0 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= cero(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato4 bajo 	 3 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= tres(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';


 --trama lrc alto	 7 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <=siete(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama lrc bajo 	 e ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= la_e(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama cr
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <=  cr(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama lf
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <=  lf(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';


--*************************************************
--     trama MODBUS 2
--*************************************************
 --trama dos puntos		
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= dospuntos(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dire alto 	 0 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= cero(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dire bajo 	 7 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= siete(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';


 --trama función alto 	 0 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= cero(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama función bajo 	 1 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= dos(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';


 --trama dato1 alto	 5 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= cinco(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato1 bajo 	 8 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= ocho(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato2 alto 	 F ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <=  la_f(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato2 bajo	 a ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <=  la_a(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama cr
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <=  cr(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama lf
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <=  lf(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';


--*************************************************
--     trama MODBUS 3
--*************************************************
 --trama dos puntos		
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= dospuntos(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';
-- direccion ***************************************
 --trama dire alto 	 1 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= uno(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';
--trama dire bajo 	 1 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= uno(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';
-- funcion  ***************************************

 --trama función alto 	 0 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= cero(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama función bajo 	 6 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= seis(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';


 --trama dato1 alto	 7 ascii  ********************************
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= siete(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato1 bajo 	 2 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= dos(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato2 alto 	 4 ascii	 ********************************
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <=  cuatro(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato2 bajo	 5 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <=  cinco(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato3 alto	 2 ascii	********************************
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= dos(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato3 bajo 	 6 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= seis(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato4 alto	 5 ascii	********************************
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= cinco(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato4 bajo 	 5ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= cinco(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato5 alto	 7 ascii	********************************
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= siete(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato5 bajo   8 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= ocho(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato6 alto	 8 ascii	********************************
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= ocho(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato6 bajo   5 ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= cinco(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';


 --trama lrc alto	B ascii ********************************
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= la_b(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama lrc bajo 	 A ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <=  la_a(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama cr
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <=  cr(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama lf
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <=  lf(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

--**********************************************************

--enviar datos de la ram al TX
	 wait for 5ms;	  -- antes 500us, os parece poco tiempo éste valor
	 Eram_picoB <= '1';
	wait for 100us;
	addr_picoB <= "0011";
	wait for 100us;
	send_ram <= '1';
	wait for 120us;
	send_ram <= '0';
	wait for 2ms;
      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
