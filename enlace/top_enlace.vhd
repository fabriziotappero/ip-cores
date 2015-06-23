library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_enlace is
	generic ( bits : integer := 8;   -- ancho de datos de la memoria
             addr_bits : integer := 8 -- 2^addr_bits = numero bits de direccionamiento
	);
	Port (
--nexys2
		Led			: out std_logic_vector (7 downto 0);
		an				: out std_logic_vector (3 downto 0);	
		
-- analizar lógico
		canalA		:out std_logic_vector (7 downto 0);
		canalB		:out std_logic_vector (7 downto 0);
		
--++++++++++++++++
		clk 			: in std_logic; -- clock global
		reset		: in std_logic; -- reset global
--		send_ram		: in std_logic; -- orden para sacar dato de ram por RS232
		rxd			: in std_logic; -- linea de recepcion del RS232
		error_uart	: out std_logic;
		error_lrc		: out std_logic;
		txd			: out std_logic; -- linea de transmision del RS232
-- puertos comunicacin con pico Blaze
		picoB_ok			:in std_logic;
		addr_picoB		: in std_logic_vector (addr_bits-1 downto 0);
		Eram_picoB		: in std_logic;
		WEram_picoB		: in std_logic;
		data_in_ram_picoB	: in std_logic_vector (7 downto 0);
		data_out_ram_picoB	: out std_logic_vector (7 downto 0);
		cant_datos_picoB	: in std_logic_vector (7 downto 0);
		det_trama_ok_PB	: out std_logic;	--avisa cuando una trama est lista para usar
		gen_trama_ok_PB	: out std_logic	--avisa cuando una trama fue enviada por la uart
	);

end top_enlace;

architecture Behavioral of top_enlace is

--*******************************************************************
-- DECLARACION COMPONENTE UART_RS232
--*******************************************************************
component uart_rs232 
    Port ( clk 			: in std_logic; -- global clock
           reset 			: in std_logic; -- global reset
           send_data 		: in std_logic; -- this signal orders to send the data present at the data_in inputs through the TXD line
           data_in 			: in std_logic_vector(7 downto 0); -- data to be sent
			  even_odd			: in std_logic; -- it selects the desired parity (0: odd/impar; 1: even/par)
			  rxd 			: in std_logic; -- The RS232 RXD line
           txd 			: out std_logic; -- The RS232 TXD line
           transmitter_busy 	: out std_logic; -- it indicates that the transmitter is busy sending one character
           send_done 		: out std_logic; -- it indicates that the character has been sent
           data_out 		: out std_logic_vector(7 downto 0); -- The data received, in parallel
           parity_error 		: out std_logic; -- it indicates a parity error in the received data
           start_error 		: out std_logic; -- it indicates an error in the start bit (false start) of the received data. The receiver will wait for a new complete start bit
           stop_error 		: out std_logic; -- it indicates an error in the stop bit of the received data (though the data could have been received correctly and it is presented at the outputs).
		     discrepancy_error	: out std_logic;  -- it indicates an error because the three samples of the same bit of the data being currently received have different values.
           receiver_busy 	: out std_logic; -- it indicates that the receiver is busy receiving one character
           new_data 		: out std_logic -- it indicates that the receiving process has ended and a new character is available
	);
end component;

--*******************************************************************
-- DECLARACION COMPONENTE Detector (mquina de estado)
--*******************************************************************
component det_top
    generic (
   		DIRE_LOCAL_ALTO : std_logic_vector(7 downto 0) := "00110001"; -- 1 ASCII
   		DIRE_LOCAL_BAJO : std_logic_vector(7 downto 0) := "00110001";  -- 1 ASCII
		   bits 		 : integer := 8;   -- ancho de datos de la memoria
         addr_bits 	 : integer := 8    -- 2^addr_bits = numero bits de direccionamiento
	);
    Port ( 
			clk 		:in  std_logic;
			reset	:in	std_logic;
			data		:in	std_logic_vector(7 downto 0);
			new_data	:in  std_logic;
			error	:out std_logic;
			end_det	:out std_logic;
--para escritura de ram:
			E		:out	std_logic;	-- habilitador de la ram
			WE		:out	std_logic;	-- habilitador de escritura
			ADDR		:out	std_logic_vector(addr_bits-1 downto 0);
			data_ram	:out	std_logic_vector(bits-1 downto 0) --dato a guardar en ram
	);
end component;

--*******************************************************************
-- DECLARACION COMPONENTE BLOQUE RAM 
--*******************************************************************
component ram2_top
    generic (
		bits 		 : integer := 8;   -- ancho de datos de la memoria
          addr_bits 	 : integer := 8 -- 2^addr_bits = numero bits de direccionamiento
	);
	port(
		clk		:in	std_logic;
		reset	:in	std_logic;
		E		:in	std_logic;	-- habilitador de la ram
		WE		:in	std_logic;	-- habilitador de escritura
		ADDR		:in	std_logic_vector(addr_bits-1 downto 0);
		data_in	:in	std_logic_vector(bits-1 downto 0);
		data_out	:out	std_logic_vector(bits-1 downto 0)
	);
end component;

--*******************************************************************
-- DECLARACION COMPONENTE generador trama (maquina de estado) 
--*******************************************************************
component gen_trama_top
	generic(
		addr_bits 	 : integer := 8 -- 2^addr_bits = numero bits de direccionamiento
	);
	port(
		clk			:in std_logic;
		reset		:in std_logic;
		end_gen		:out std_logic;
-- PicoBlaze
		cant_datos_picoB	:in std_logic_vector(7 downto 0);  -- cantidad de datos cargados en ram 
		picoB_ok		:in std_logic;	-- arrancar transmision (tomando datos desde ram)
-- ram
    	data_out_ram	:in  std_logic_vector(7 downto 0);  --dato leido desde ram
    	addr_ram		:out std_logic_vector(addr_bits-1 downto 0);  --dato leido desde ram
		E_ram		:out std_logic;  	-- habilitador de ram
		WE_ram		:out std_logic;  	-- habilitador de escritura ram: 0-lectura 1-escritura
-- uart
		send_done_uart	:in  std_logic;		-- aviso de dato enviado (por uart), seal habilitadora para obtener nuevo dato de ram
		data_in_uart	:out std_logic_vector(7 downto 0);  --dato leido desde ram
		send_data_uart	:out std_logic
	);
end component;

--*******************************************************************
-- DECLARACION COMPONENTE generador trama (maquina de estado) 
--*******************************************************************
component contro_ram
	generic(
		addr_bits : integer := 8); -- 2^addr_bits = numero bits de direccionamiento
  	port(
--entradas y salidas de la RAM
		clk			:in std_logic;
		reset		:in std_logic;
		Eram 		:out std_logic;
		Eram_write 	:out std_logic;
		ram_addr 		:out std_logic_vector(addr_bits-1 downto 0);
		data_in_ram 	:out std_logic_vector(7 downto 0);
		data_out_ram	:in std_logic_vector(7 downto 0);
--entradas y salidas del pico blaze
	 	Eram_picoB	:in std_logic;
		WEram_picoB	:in std_logic;
		addr_picoB	:in std_logic_vector(addr_bits-1 downto 0);
		data_in_ram_picoB:in std_logic_vector(7 downto 0);
		data_out_ram_picoB:out std_logic_vector(7 downto 0);
--entradas y salidas del componente detector
		Eram_det		:in std_logic;
		Eram_write_det	:in std_logic;
		ram_addr_det	:in std_logic_vector(addr_bits-1 downto 0);	
		data_in_ram_det:in std_logic_vector(7 downto 0);
--entradas y salidas del componente generador trama
      E_ram_gen		:in std_logic;
		WE_ram_gen	:in std_logic;
		addr_ram_gen	:in std_logic_vector(addr_bits-1 downto 0);	
		data_out_ram_gen:out std_logic_vector(7 downto 0)
		);
end component;		
signal Q1,Q2,Q3 : std_logic:='0';
signal picoB_ok_pulso : std_logic:='0';
signal Stxd		: std_logic:='1';
--*******************************************************************
-- SEALES DE COMPONENTE UART_RS232
--*******************************************************************
signal Sdata_out	: std_logic_vector(7 downto 0):= (others=>'0');
signal Snew_data	: std_logic:='0';
signal Ssend_done	: std_logic:='1';
signal Ssend_data_uart : std_logic:='0';
signal Sdata_in_uart: std_logic_vector(7 downto 0):= (others=>'0');
signal Stransmitter_busy : std_logic := '0';
signal Sparity_error	: std_logic := '0';
signal Sstart_error		: std_logic := '0';
signal Sstop_error		: std_logic := '0';
signal Sdiscrepancy_error: std_logic := '0';
signal Sreceiver_busy	: std_logic := '0';
	
--*******************************************************************
-- SEALES DE COMPONENTE DET_TOP	
--*******************************************************************

signal Serror_det : std_logic := '0';
signal SEram_det  : std_logic := '0';
signal Sram_addr_det: std_logic_vector (addr_bits-1 downto 0):=(others=>'0') ;
signal SEram_write_det: std_logic := '0';-- habilitador de escritura
signal Sdata_in_ram_det: std_logic_vector (7 downto 0):=(others=>'0') ;
signal Send_det		: std_logic:='0';

--*******************************************************************
-- SEALES DE COMPONENTE BLOQUE RAM	
--*******************************************************************

	signal SEram		: std_logic;	-- habilitador de la ram
	signal SEram_write	: std_logic;   -- habilitador de escritura
	signal Sram_addr	:std_logic_vector(addr_bits-1 downto 0):=(others=>'0') ;
	signal Sdata_in_ram	:std_logic_vector(bits-1 downto 0):=(others=>'0') ;
	signal Sdata_out_ram:std_logic_vector(bits-1 downto 0):=(others=>'0') ;

--*******************************************************************
-- SEALES DE COMPONENTE generador trama (maquina de estado)	
--*******************************************************************
	signal Send_gen		: std_logic:='0';
	signal Sdata_out_ram_gen:std_logic_vector(bits-1 downto 0):=(others=>'0');  --dato leido desde ram
   signal Saddr_ram_gen:std_logic_vector(addr_bits-1 downto 0):=(others=>'0') ;  --dato leido desde ram
	signal SE_ram_gen : std_logic:='0';  	-- habilitador de ram
	signal SWE_ram_gen : std_logic:='0';
	
	
-- *********************Señales para CE **************
	signal cont_div :std_logic_vector(20 downto 0):=(others=> '0');
	signal CE_clock :std_logic:='0';
	
	signal contador_canalA : std_logic_vector(7 downto 0) := (others=>'0');
	signal RAM_trucha			:std_logic_vector(7 downto 0) := (others=>'0');
begin

--*******************************************************************
-- INSTANCIACION COMPONENTE UART_RS232
--*******************************************************************
IC_uart : uart_rs232 
    Port map ( 
    		 clk 			=> clk, -- global clock
           reset 			=> reset, -- global reset
           send_data 		=> Ssend_data_uart,--send_ram, -- this signal orders to send the data present at the data_in inputs through the TXD line
           data_in 			=> Sdata_in_uart,--Sdata_out_ram,	-- data to be sent
			  even_odd			=> '0',--Seven_odd,	 -- it selects the desired parity (0: odd/impar; 1: even/par)
		     rxd 			=> rxd, -- The RS232 RXD line
           txd 			=> Stxd, -- The RS232 TXD line
           transmitter_busy 	=> Stransmitter_busy, -- it indicates that the transmitter is busy sending one character
           send_done 		=> Ssend_done,	-- it indicates that the character has been sent
           data_out 		=> Sdata_out, -- The data received, in parallel
           parity_error 		=> Sparity_error, -- it indicates a parity error in the received data
           start_error 		=> Sstart_error, -- it indicates an error in the start bit (false start) of the received data. The receiver will wait for a new complete start bit
           stop_error 		=> Sstop_error, -- it indicates an error in the stop bit of the received data (though the data could have been received correctly and it is presented at the outputs).
			  discrepancy_error	=> Sdiscrepancy_error,  -- it indicates an error because the three samples of the same bit of the data being currently received have different values.
           receiver_busy 	=> Sreceiver_busy, -- it indicates that the receiver is busy receiving one character
           new_data 		=> Snew_data -- it indicates that the receiving process has ended and a new character is available
	);


--*******************************************************************
-- INSTANCIACION COMPONENTE Detector (mquina de estado)
--*******************************************************************
IC_det: det_top
    generic map (
   		DIRE_LOCAL_ALTO 	=> "00110001", -- 0 ASCII
   		DIRE_LOCAL_BAJO  	=> "00110001",  -- 7 ASCII
			bits 			=> 8,   -- ancho de datos de la memoria
         addr_bits 		=> 8 -- 2^addr_bits = numero bits de direccionamiento
	)
    Port map ( 
			clk			=> clk,
			reset		=> reset,	
			data			=> Sdata_out, --datos recibidos por la UART en 8bit
			new_data		=> Snew_data, --bandera que detecta cuando se recibe un dato en la UART
			error		=> Serror_det,
			end_det		=> Send_det,
--para escritura de ram:
			E			=> SEram_det,		-- habilitador de la ram
			WE			=> SEram_write_det,-- habilitador de escritura
			ADDR			=> Sram_addr_det, -- direccion de ram donde quiero escribir
			data_ram		=> Sdata_in_ram_det -- dato a guardar en ram
     );

--*******************************************************************
-- INSTANCIACION COMPONENTE BLOQUE RAM (mquina de estado)
--*******************************************************************
bloque_ram: ram2_top
	generic map( 	
		bits 			=> 8,   	-- ancho de datos de la memoria
      addr_bits 	=> 8 	-- 2^addr_bits = numero bits de direccionamiento
 	)
	port map (
		clk => clk,
		reset => reset,
		E => SEram,		-- habilitador de la ram
		WE => SEram_write,		-- habilitador de escritura
		ADDR => Sram_addr,
		data_in => Sdata_in_ram,
		data_out => Sdata_out_ram
	);

--*******************************************************************
-- INSTANCIACION COMPONENTE generador trama (maquina de estado)
--*******************************************************************
gen_top: gen_trama_top
	generic map(
		addr_bits 		=> 8 -- 2^addr_bits = numero bits de direccionamiento
	)
	port map(
		clk			=> clk,
		reset		=> reset,
		end_gen		=> Send_gen,
-- PicoBlaze
		cant_datos_picoB => cant_datos_picoB,-- cantidad de datos cargados en ram 
		picoB_ok         => picoB_ok_pulso,	-- arrancar transmision (tomando datos desde ram)
-- ram
    	data_out_ram	=> Sdata_out_ram_gen,  --dato leido desde ram
    	addr_ram		=> Saddr_ram_gen,  --dato leido desde ram
		E_ram		=> SE_ram_gen,  	-- habilitador de ram
		WE_ram		=> SWE_ram_gen,  	-- habilitador de escritura ram: 0-lectura 1-escritura
-- uart
		send_done_uart	=> Ssend_done, 		-- aviso de dato enviado (por uart), seal habilitadora para obtener nuevo dato de ram
		data_in_uart	=> Sdata_in_uart,  --dato leido desde ram
		send_data_uart	=> Ssend_data_uart
	);


--*******************************************************************
--  ESCRITURA / LECTURA EN RAM
--*******************************************************************

		
control_RAM: contro_ram
	generic map(
		addr_bits => 8) -- 2^addr_bits = numero bits de direccionamiento
  	port map(
--entradas y salidas de la RAM
		clk			=> clk,
		reset		=> reset,
		Eram 		=> SEram,		-- habilitador de la ram	
		Eram_write 	=> SEram_write,		-- habilitador de escritura
		ram_addr 		=> Sram_addr,
		data_in_ram 	=> Sdata_in_ram,
		data_out_ram	=> Sdata_out_ram,
--entradas y salidas del pico blaze
	 	Eram_picoB	=> Eram_picoB,
		WEram_picoB	=> WEram_picoB,
		addr_picoB	=> addr_picoB,
		data_in_ram_picoB=> data_in_ram_picoB,
		data_out_ram_picoB=> data_out_ram_picoB,
--entradas y salidas del componente detector
		Eram_det		=> SEram_det,		-- habilitador de la ram
		Eram_write_det	=> SEram_write_det,-- habilitador de escritura
		ram_addr_det	=> Sram_addr_det, -- direccion de ram donde quiero escribir
		data_in_ram_det=> Sdata_in_ram_det, -- dato a guardar en ram
--entradas y salidas del componente generador trama
      E_ram_gen		=> SE_ram_gen,  	-- habilitador de ram:in std_logic;
		WE_ram_gen	=> SWE_ram_gen,  	-- habilitador de escritura ram: 0-lectura 1-escritura
		addr_ram_gen	=> Saddr_ram_gen,  --dato leido desde ram
		data_out_ram_gen=> Sdata_out_ram_gen  --dato leido desde ram
		);		

--*******************************************************************
--  SEALES DE ERROR
--*******************************************************************
error_uart <= Stransmitter_busy or Sparity_error	or Sstart_error or Sstop_error or Sdiscrepancy_error or Sreceiver_busy;
error_lrc <= Serror_det;

--*******************************************************************
--  SEALES QUE AVISAN EL ESTADO DE LA INFORMACION ENVIADO/RECIBIDO
--*******************************************************************
det_trama_ok_PB <= Send_det;
gen_trama_ok_PB <= Send_gen;
--nexys2
an <= "1111";
--Led(6 downto 0) <= Sram_addr(6 downto 0);
--Led(7) <= SEram;
Led(3 downto 0) <= (others=>'0');--contador_canalA(4 downto 0);
Led(4) <= Serror_det;
Led(5) <=SEram; 
Led(6) <=SE_ram_gen;
Led(7) <=SEram_det;
canalA <= contador_canalA;--Sdata_in_uart;

canalB(0) <= SEram;		-- habilitador de la ram
canalB(1) <= SEram_write;
canalB(2) <= Stxd;
txd <= Stxd;
canalB(7 downto 3) <= Sram_addr(4 downto 0);

--**Insert the following after the 'begin' keyword**
process(clk)
begin
   if (clk'event and clk = '1') then	
      if (reset = '1') then
         Q1 <= '0';
         Q2 <= '0';
         Q3 <= '0'; 
      else--if CE_clock = '1' then
         Q1 <= picoB_ok;
         Q2 <= Q1;
         Q3 <= Q2;
      end if;
   end if;
end process;

picoB_ok_pulso <= Q1 and Q2 and (not Q3);

process(clk)
begin
	if CE_clock = '1' then
		cont_div <= (others=>'0');
	elsif clk'event and clk = '1' then
		cont_div <= cont_div + 1;
	end if;
end process;

process(clk)
begin
	if clk'event and clk = '1' then
		if cont_div > "111111111111111111100" then
			CE_clock <= '1';
		else
			CE_clock <= '0';
		end if;
	end if;
end process;

process (clk) 
begin
   if clk='1' and clk'event then
      if CE_clock='1' then
         contador_canalA <= contador_canalA + 1;
      end if;
   end if;
end process;

RAM_trucha <= "00110101";
end Behavioral;
