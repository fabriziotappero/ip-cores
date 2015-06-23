library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity gen_trama_top is
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
end gen_trama_top;

architecture Behavioral of gen_trama_top is

-- ********************* DECLARACION DE SEALES Y ESTADOS *****************************
   type state_type is (st1_espera, st2_dos_puntos, st3_lectura_ram, st4_ascii_H, st4_ascii_H_conver, st5_ascii_L, st5_ascii_L_conver, st6_fin_datos,st7_LRC_H, st7_LRC_H_conver, st8_LRC_L, st8_LRC_L_conver, st9_CR, st10_LF); 
	signal state, next_state : state_type; 
	signal Saddr 			:std_logic_vector (addr_bits-1 downto 0):=(others =>'0');  
	signal SE_ram 			:std_logic:='0';
	signal SWE_ram 		:std_logic:='0';
--	signal Sdata_in_uart	:std_logic_vector (7 downto 0):=(others =>'0');
	signal Ssend_data_uart	:std_logic:='0';
	signal Sst4_cont		:std_logic_vector(1 downto 0):="00";
	signal Sst5_cont		:std_logic_vector(1 downto 0):="00";
	signal Sst7_cont		:std_logic_vector(1 downto 0):="00";
	signal Sst8_cont		:std_logic_vector(1 downto 0):="00";

-- Seales CONVERSOR
	signal Sbin  		:std_logic_vector (7 downto 0):=(others =>'0');
   signal Sascii_H	:std_logic_vector (7 downto 0):=(others =>'0');
   signal Sascii_L 	:std_logic_vector (7 downto 0):=(others =>'0');
-- Seales LRC
	signal Slrc_bin	: std_logic_vector (7 downto 0):=(others =>'0');
	signal Strama		: std_logic:='0';	
	signal Q1, Q2, Q3, Q4, Q5	: std_logic:='0'; 	   -- seales auxiliares para obtener Snew_data e funcion de send_done (cadena Flip Flops)
	signal Snew_data_pre	: std_logic:='0';
	signal Snew_data	: std_logic:='0';


-- ***************** DECLARACION COMPONENTE GENERADOR LRC  ****************************
component gen_lrc
	port(
		clk		:in std_logic;	 				--clk
		reset	:in std_logic;					--reset
		new_data	:in std_logic;					--nuevo valor a leer
		trama	:in std_logic;					--suma vlida
		dato_trama:in std_logic_vector(7 downto 0);	--dato desde la ram
		lrc_bin	:out std_logic_vector(7 downto 0)	--valor del lrc calculado
	);
end component;
-- ***************** DECLARACION COMPONENTE CONVERSOR BIN A ASCII  ****************************
component bin_ascii
	port(
		clk		:in std_logic;
		reset	:in std_logic;
		bin		:in std_logic_vector(7 downto 0);
		ascii_h	:out std_logic_vector(7 downto 0);
		ascii_l	:out std_logic_vector(7 downto 0)
	);
end component;


begin
-- ***************** INSTANCIACION COMPONENTE GEN_LRC  ****************************
generador_lrc: gen_lrc
	port map(
		clk		=> clk,
		reset	=> reset,
		new_data	=> Snew_data,
		trama	=> Strama, 			--suma vlida (trama = '1')
		dato_trama => data_out_ram,		--dato desde la ram
		lrc_bin	=> Slrc_bin			--valor del lrc calculado
	);
-- ***************** INSTANCIACION COMPONENTE CONVERSOR  ****************************
conv_bin2ascii: bin_ascii
	port map(
		clk		=> clk,		
		reset	=> reset,
		bin		=> Sbin,	   	-- entrada del conversor
		ascii_h	=> Sascii_H,	
		ascii_l	=> Sascii_L
	);
--************ MAQUINA ESTADO: DESCRIPCION SINCRONIZAR CAMBIOS DE ESTADO **************	    
SYNC_PROC: process (clk,reset)
   begin
      if (reset='1') then
         state <= st1_espera;
      elsif (clk'event and clk = '1') then
         state <= next_state;
	    E_ram <= SE_ram;
	    WE_ram <= SWE_ram;
--    data_in_uart <= Sdata_in_uart;
--	    send_data_uart <= Ssend_data_uart;
      end if;
   end process;
	

--  data_in_uart <= Sdata_in_uart;
--************ MAQUINA ESTADO: DESCRIPCION EJECUCION EN LOS ESTADOS (SALIDAS) ***********
-- En los distintos estados se envian los caracteres de comienzo y fin de trama, lrc, y datos obtenidos de la RAM.
-- En el estos estados se usa send_done_uart solo para poder resetar las seales de "enviar dato" (send_data_uart) y las de RAM,
-- siempre que se cambia de estado es porque el dato anterior ya termino de enviarse.
OUTPUT_DECODE: process (state,send_done_uart) --send_done_uart = 1 == "envio realizado"
   begin
     if state = st2_dos_puntos then
		if send_done_uart = '0' then	   
			data_in_uart 	<= "00111010";	-- carga en la entrada de uart el dato a enviar: ':'	
		end if;
	end if;
	
	if state = st3_lectura_ram then	 --no se envian datos, se direcciona el elemento de la RAM
		if send_done_uart = '0' then	
			addr_ram 	<= Saddr;		-- direccion del elemento a enviar
			SE_ram 	<= '1';		-- hablita la RAM
			SWE_ram	<= '0';		-- habilita la Lectura
			Saddr <= Saddr + 1;           -- se incrementa el contador para luego acceder al proximo elemeto de RAM
		end if;
		Strama <= '1';
     end if;
	  
	if state = st4_ascii_H then
		if send_done_uart = '0' then
			data_in_uart 	<= Sascii_H;	-- parte alta del dato covertido
			Snew_data_pre <= '1';
		end if;
	end if;
	
	if state = st5_ascii_L then
		if send_done_uart = '0' then
			data_in_uart 	<= Sascii_L;	-- parte alta del dato covertido
			Snew_data_pre <= '0';
     	end if;
	end if;
	
	if state = st6_fin_datos then
		Strama <= '0';
		SE_ram 	<= '0';		-- deshabilita la RAM
		SWE_ram	<= '0';		-- (se mantiene siempre habilitada la lectura de la RAM)
	end if;
	
	if state = st7_LRC_H then
	    	data_in_uart 	<= Sascii_H;	-- parte alta del dato covertido	
	end if;
	
	if state = st8_LRC_L then
	    		data_in_uart 	<= Sascii_L;	-- parte alta del dato covertido
	end if;
	
   if state = st9_CR then
  		data_in_uart 	<= "01000010";--"00001101";	-- carga en la entrada de uart el dato a enviar: CR
   end if;
   if state = st10_LF then
    	data_in_uart 	<= "01000001";--"00001010";
		end_gen	<= '1';
	else
		end_gen <= '0';
   end if;
	
	
end process;

send_232:process(clk,state,send_done_uart)
begin
	if clk'event and clk = '1' then
		if (state=st2_dos_puntos or state = st4_ascii_H or state = st5_ascii_L or state = st7_LRC_H or	state = st8_LRC_L or state = st9_CR or state = st10_LF) then
			if send_done_uart = '0' then
	 			Ssend_data_uart	<= '1';        -- seal que da la orden a la uart para enviar el dato
	 		else
				Ssend_data_uart	<= '0';
	 		end if;
     	end if;
	end if;
end process;

send_data_uart <= Ssend_data_uart;

--************ MAQUINA ESTADO: DESCRIPCION ESTADO SIGUIENTE ***********************
NEXT_STATE_DECODE: process (Saddr, Sst4_cont,Sst5_cont, state, send_done_uart, picoB_ok)
begin
      next_state <= state;  					--default is to stay in current state
      case (state) is
			when st1_espera =>					--estado de espera, comienza la secuencia de estados cuado
				if picoB_ok = '1' then 			-- el pico blaze termina de cargar RAM
					next_state <= st2_dos_puntos;	-- se pasa a los estados que envan la trama
            end if;
         when st2_dos_puntos =>
	    		if send_done_uart = '1' then		--cuando se termina de enviar ":" se pasa al estado 3
					next_state <= st3_lectura_ram;
				end if;
         when st3_lectura_ram =>				-- se pasa a otro estado independientemente de send_done_uart ya que st3 no se envia ningn dato
				if Saddr < cant_datos_picoB then	-- se recorre la RAM hasta el ltimo elemento dispuesto por pico blaze 
					next_state <= st4_ascii_H_conver;	-- se va a enviar la parte alta del correspondiente elemento de RAM
				else 			
					next_state <= st6_fin_datos;-- cuando se termina de recorrer los elementos de la RAM se envia el LRC
				end if;
			when st4_ascii_H_conver =>
				if Sst4_cont > "10" then
					next_state <= st4_ascii_H;
				end if;
			when st4_ascii_H =>
				if send_done_uart = '1' then		-- cuando se termina de enviar la parte alta del correspondiente elemento, pasa a enviar la parte baja
					next_state <= st5_ascii_L_conver;	
				end if;
			when st5_ascii_L_conver =>
				if Sst5_cont > "10" then
					next_state <= st5_ascii_L;
				end if;
			when st5_ascii_L =>					
				if send_done_uart = '1' then		-- cuando se envi la parte baja volvemos al st3 a buscar otro elemento a enviar
					next_state <= st3_lectura_ram;	
				end if;
			when st6_fin_datos =>
				next_state <= st7_LRC_H_conver;
			when st7_LRC_H_conver =>
				next_state <= st7_LRC_H;
			when st7_LRC_H =>	
				if send_done_uart = '1' then	
					next_state <= st8_LRC_L_conver;
				end if;
			when st8_LRC_L_conver =>
				next_state <= st8_LRC_L;
			when st8_LRC_L =>	
				if send_done_uart = '1' then	
					next_state <= st9_CR;		-- cuando se termina de enviar el LRC se envia caracteres de fin de trama
				end if;
			when st9_CR =>
				if send_done_uart = '1' then
					next_state <= st10_LF;
				end if;
			when st10_LF =>
				if send_done_uart = '1' then		-- cuando se termina de enviar trama se vuelve a st1_espera
					next_state <= st1_espera;
				end if;
         when others =>
            next_state <= st1_espera;
			end case;      
end process;



process(clk)
begin
	if clk'event and clk = '1' then
		if state = st4_ascii_H_conver then
			Sst4_cont <= Sst4_cont + 1;
		else
			Sst4_cont <= "00";
		end if;
	end if;
end process;


process(clk)
begin
	if clk'event and clk = '1' then
		if state = st5_ascii_L_conver then
			Sst5_cont <= Sst5_cont + 1;
		else
			Sst5_cont <= "00";
		end if;
	end if;
end process;

process(clk)
begin
	if clk'event and clk = '1' then
		if state = st7_LRC_H_conver then
			Sst7_cont <= Sst7_cont + 1;
		else
			Sst7_cont <= "00";
		end if;
	end if;
end process;

process(clk)
begin
	if clk'event and clk = '1' then
		if state = st8_LRC_L_conver then
			Sst8_cont <= Sst8_cont + 1;
		else
			Sst8_cont <= "00";
		end if;
	end if;
end process;

 
-- ************** FLIP FLOPS PARA GENERAR Snew_data *******************
-- Snew_data es la seal que le idica al componente "generar LRC", que tome y sume un 
-- nuevo dato que tiene presente en la entrada.  Sigue a Send_done pero retrasado 
-- tres pulsos de clock, tiempo suficiente para que aparezca el dato a la entrada del
-- componente gen_LRC.

process(clk, reset)
begin
  if (reset = '1') then
    Q1 <= '0';
    Q2 <= '0';
    Q3 <= '0';
    Q4 <= '0';
    Q5 <= '0';
  elsif (clk'event and clk = '1') then
    Q1 <= Snew_data_pre;
    Q2 <= Q1;
    Q3 <= Q2;
    Q4 <= Q3;
    Q5 <= Q4;
  end if;
end process;

Snew_data <= Q1 and Q2 and Q3 and Q4 and (not Q5);

--******************************************************************

--************ MUX *************************
Sbin <= data_out_ram when Strama = '1' else 
		Slrc_bin; 
--******************************************

end Behavioral;