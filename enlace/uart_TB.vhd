
-- VHDL Test Bench Created from source file uart_rs232.vhd -- 21:28:36 07/21/2010
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

ENTITY uart_rs232_uart_TB_vhd_tb IS
END uart_rs232_uart_TB_vhd_tb;

ARCHITECTURE behavior OF uart_rs232_uart_TB_vhd_tb IS 

	COMPONENT uart_rs232
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		send_data : IN std_logic;
		data_in : IN std_logic_vector(7 downto 0);
		even_odd : IN std_logic;
		rxd : IN std_logic;          
		txd : OUT std_logic;
		transmitter_busy : OUT std_logic;
		send_done : OUT std_logic;
		data_out : OUT std_logic_vector(7 downto 0);
		parity_error : OUT std_logic;
		start_error : OUT std_logic;
		stop_error : OUT std_logic;
		discrepancy_error : OUT std_logic;
		receiver_busy : OUT std_logic;
		new_data : OUT std_logic
		);
	END COMPONENT;

	SIGNAL clk :  std_logic;
	SIGNAL reset :  std_logic;
	SIGNAL send_data :  std_logic;
	SIGNAL data_in :  std_logic_vector(7 downto 0);
	SIGNAL even_odd :  std_logic;
	SIGNAL rxd :  std_logic;
	SIGNAL txd :  std_logic:='1';
	SIGNAL transmitter_busy :  std_logic;
	SIGNAL send_done :  std_logic;
	SIGNAL data_out :  std_logic_vector(7 downto 0);
	SIGNAL parity_error :  std_logic;
	SIGNAL start_error :  std_logic;
	SIGNAL stop_error :  std_logic;
	SIGNAL discrepancy_error :  std_logic;
	SIGNAL receiver_busy :  std_logic;
	SIGNAL new_data :  std_logic;


	signal comiezo	:	std_logic_vector(7 downto 0):= "01010101";
	signal segundo :	std_logic_vector(7 downto 0):= "11100111";
     signal dospuntos :	std_logic_vector(7 downto 0):= "00111010";		--: ascii
     signal cero	 :	std_logic_vector(7 downto 0):= "00110000";		--0 ascii
	signal siete	 :	std_logic_vector(7 downto 0):="00110111";		--7 ascii
	signal uno	:	std_logic_vector(7 downto 0):="00110001";		--1 ascii
	signal ocho	:std_logic_vector(7 downto 0):= "00111000";		--8 ascii
	signal la_a	:std_logic_vector(7 downto 0):=  "01000001";		--A ascii
	signal cinco   :std_logic_vector(7 downto 0):=   "00110101";		--5 ascii
	signal la_f	:std_logic_vector(7 downto 0):= "01000110";		--F ascii
	signal cr		:std_logic_vector(7 downto 0):= "00001101";		--CR ascii
	signal lf		:std_logic_vector(7 downto 0):= "00001010";		--LF ascii



	   -- Clock period definitions
   constant clk_period : time := 20ns;


BEGIN

	uut: uart_rs232 PORT MAP(
		clk => clk,
		reset => reset,
		send_data => send_data,
		data_in => data_in,
		even_odd => even_odd,
		rxd => rxd,
		txd => txd,
		transmitter_busy => transmitter_busy,
		send_done => send_done,
		data_out => data_out,
		parity_error => parity_error,
		start_error => start_error,
		stop_error => stop_error,
		discrepancy_error => discrepancy_error,
		receiver_busy => receiver_busy,
		new_data => new_data
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
		send_data <='0';
		data_in <= "00000000";
		even_odd <= '1';
		wait for 100ns;
		reset <= '0';

--trama 1		
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

--trama 2		
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
      		rxd <= uno(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';


 --trama dato1 alto	 8 ascii
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

 --trama dato1 bajo 	 A ascii
		wait for 500us;
		rxd <= '0';
		wait for  104us;
		for i in 0 to 7 loop
      		rxd <= la_a(i);
			wait for 104us;
		end loop;	
		rxd <= '0';
		wait for 104us;
		rxd <= '1';

 --trama dato2 alto 	 5 ascii
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

 --trama dato2 bajo	 f ascii
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


	data_in <= "10101101";
	wait for 200us;
	send_data <= '1';
	wait for 120us;
	send_data <= '0';



      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
