----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:19:21 06/04/2010 
-- Design Name: 
-- Module Name:    det_top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
-- TRAMA:
-- The allowable characters transmitted for all other fields are hexadecimal 09, AF (ASCII coded). The devices monitor the bus
-- continuously for the colon character(:). When this character is received, each device decodes the next character until it detects the
-- End-Of-Frame(CR Y LF) --> (en ese orden).

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity det_top is
    generic (
   		DIRE_LOCAL_ALTO : std_logic_vector(7 downto 0) := "00110001";  -- 1 ASCII
   		DIRE_LOCAL_BAJO : std_logic_vector(7 downto 0) := "00110001";  -- 1 ASCII
		bits 		 : integer := 8;   -- ancho de datos de la memoria
          addr_bits 	 : integer := 8 -- 2^addr_bits = numero bits de direccionamiento
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
			data_ram	:out	std_logic_vector(bits-1 downto 0)); --dato a guardar en ram
end det_top;

architecture Behavioral of det_top is

--*******************************************************************
-- DECLARACION COMPONENTE ASCII a BIN
--*******************************************************************
component ascii_bin
	port(
			clk			:in std_logic;
			reset		:in std_logic;
			new_data		:in std_logic;
			Nnew_data		:out std_logic;
			ascii		:in std_logic_vector(7 downto 0);
			bin			:out std_logic_vector(7 downto 0));
end component;

--*******************************************************************
-- DECLARACION COMPONENTE PONDERA
--*******************************************************************
component pondera_top 
	port(
		clk: 	in std_logic;
		reset:	in std_logic;
		bin_HL:	in std_logic_vector(7 downto 0);
		new_data:	in std_logic;
		trama_ok: in std_logic;
		bin:		out std_logic_vector(7 downto 0);
		bin_ok:	out std_logic
	);
end component;

--*******************************************************************
-- DECLARACION COMPONENTE CALCULO LRC
--*******************************************************************
component lrc
	port(
			clk		:in std_logic;
			reset	:in std_logic;
			trama	:in std_logic;
			dato_ok	:in std_logic;
			dato		:in std_logic_vector(7 downto 0);
			lrc_ok	:out std_logic);
end component;
 
--*******************************************************************
-- SEALES MAQUINA DE ESTADO	
--*******************************************************************

   type state_type is (st1_det, st2_dire_alto, st3_dire_bajo, st4_comp, st5_func_alto, st6_func_bajo, st7_CR, st8_dato_y_LRC_rec, st9_LF); 
   signal state, next_state : state_type; 

	signal Scomp		: std_logic:='0';
	signal Serror		: std_logic:='0';
	signal SCR		: std_logic_vector(7 downto 0):=(others => '0');
	signal SLF		: std_logic_vector(7 downto 0):=(others => '0');
	signal Sdire_bajo	: std_logic_vector(7 downto 0):=(others => '0');
	signal Sdire_alto	: std_logic_vector(7 downto 0):=(others => '0');
	signal Sfunc_bajo	: std_logic_vector(7 downto 0):=(others => '0');
	signal Sfunc_alto	: std_logic_vector(7 downto 0):=(others => '0');

--*******************************************************************
-- SEALES BLOQUE RAM	
--*******************************************************************
	signal SEram		: std_logic;	-- habilitador de la ram
	signal SEram_write	: std_logic;   -- habilitador de escritura
	signal Sram_addr	:std_logic_vector(addr_bits-1 downto 0):=(others=>'0') ;
	signal Sdata_in_ram	:std_logic_vector(bits-1 downto 0):=(others=>'0') ;
--*************************************************************************
--                  seales para el detector de lrc bajo y alto
--*************************************************************************
	signal SQ1		: std_logic_vector(7 downto 0):=(others => '0');
	signal SQ2		: std_logic_vector(7 downto 0):=(others => '0');
	
	signal SsQ1		: std_logic:='0';
	signal SsQ2		: std_logic:='0';
	signal SsQ3		: std_logic:='0';
	signal Sstate_bin	: std_logic:='0';
--*************************************************************************
--                  seales componente ascii a binario
--*************************************************************************
	signal Sascii		: std_logic_vector(7 downto 0):=(others => '0');
	signal Sbin		: std_logic_vector(7 downto 0):=(others => '0');
	signal SNnew_data	:std_logic:='0';

--*************************************************************************
--                  seales componente pondera
--*************************************************************************
	signal Sbin_pond 	: std_logic_vector(7 downto 0):=(others => '0');
	signal Sbin_ok_pond : std_logic:='0';
	signal Strama_ok : std_logic:='0';

--*************************************************************************
--                  seales componente calculador lrc
--*************************************************************************

	signal Sdata_ram	:std_logic_vector(bits-1 downto 0):=(others=>'0');
	signal Slrc_ok		:std_logic :='0';

begin

--*******************************************************************
-- INSTANCIACION COMPONENTE ASCII BINARIO
--*******************************************************************
ascii2bin: ascii_bin 
	port map(
			clk	=> clk,
			reset => reset,
			new_data => new_data,
			Nnew_data => SNnew_data,
			ascii => Sascii,
			bin	=> Sbin
	);

--*******************************************************************
-- INSTANCIACION COMPONENTE PONDERA
--*******************************************************************
ponderacion: pondera_top
	port map(
		clk		=> clk,
		reset	=> reset,
		bin_HL	=> Sbin,
		new_data	=> SNnew_data,
		bin		=> Sdata_ram,
		trama_ok	=> Strama_ok,
		bin_ok	=> Sbin_ok_pond
	);
--*******************************************************************


--*******************************************************************
-- INSTANCIACION COMPONENTE CALCULAR LRC
--*******************************************************************
cal_lrc: lrc
	port map(
		clk		=> clk,
		reset	=> reset,
		trama	=> Strama_ok,
		dato_ok	=> Sbin_ok_pond,
		dato		=> Sdata_ram,
		lrc_ok	=> Slrc_ok
	);
--*******************************************************************


--*******************************************************************
--  SINCRONIZMO  DE LAS SALIDAS
--*******************************************************************
   SYNC_PROC: process (clk)
   begin
      if (clk'event and clk = '1') then
         if (reset = '1') then
            state <= st1_det;
		  error <= '0';
         else
            state <= next_state;
		  error <= Serror;
         -- assign other outputs to internal signals
         end if;        
      end if;
   end process;
 
--*******************************************************************
--  CODIFICACION ACCION EN LOS ESTADOS
--*******************************************************************

   --MEALY State-Machine - Outputs based on state and inputs
   OUTPUT_DECODE: process (state, new_data)
   begin
      --insert statements to decode internal output signals
      --below is simple example
	if (state = st2_dire_alto and new_data = '1') then
         Sdire_alto <= data;
		Sascii <= data; -- a convertir y LRC
	end if;
	
	if (state = st3_dire_bajo and new_data = '1') then
         Sdire_bajo <= data;
	    Sascii <= data; -- a convertir y LRC
    	end if;
		
	if (state = st4_comp and Sdire_alto = DIRE_LOCAL_ALTO and Sdire_bajo = DIRE_LOCAL_BAJO) then  -- direccin del esclavo
		Scomp <= '1';
	else
		Scomp <= '0';
	end if;

	if (state = st5_func_alto and new_data = '1') then
         Sfunc_alto <= data;
	    Sascii <= data; --	a convertir y LRC luego:    Sdata_in_ram <= data;

     end if;
	
	if (state = st6_func_bajo and new_data = '1') then
         Sfunc_bajo <= data;
	    Sascii <= data; --	a convertir y LRC luego:	    Sdata_in_ram <= data;
     end if;

	if (state = st7_CR and data = "01000110")  then --"." ascii   --CR en ASCII
		SCR <= data;
	end if;

	if (state = st8_dato_y_LRC_rec and new_data = '1') then
		Sascii <= data; --	a convertir y LRC luego:		Sdata_in_ram <= data;		
     end if;

	if (state = st9_LF and data = "01000001")  then   	--A ascii--LF en ASCII
		SLF <= data;
		Serror <= Slrc_ok;
		end_det <= '1';
	else
		end_det <= '0';
	end if;

   end process;

--*******************************************************************
--  CONDICION DE LOS ESTADOS A SEGUIR
--*******************************************************************
 
   NEXT_STATE_DECODE: process (state, new_data)
   begin
      --declare default state for next_state to avoid latches
      next_state <= state;  --default is to stay in current state
      --insert statements to decode next_state
      --below is a simple example
      case (state) is
         when st1_det =>
            if new_data = '1' and data = "00111010" then -- : ASCII
               next_state <= st2_dire_alto;
            end if;
         when st2_dire_alto =>
            if new_data = '1' then
               next_state <= st3_dire_bajo;
            end if;
         when st3_dire_bajo =>
			if new_data = '1' then
				next_state <= st4_comp;
			end if;
		when st4_comp =>
			if Sdire_alto = DIRE_LOCAL_ALTO and Sdire_bajo = DIRE_LOCAL_BAJO then
				next_state <= st5_func_alto;
			else
				next_state <= st1_det;
			end if;
	  	when st5_func_alto =>
           	if new_data = '1' then
               	next_state <= st6_func_bajo;
            	end if;
        	when st6_func_bajo =>
			if new_data = '1' then
				next_state <= st7_CR;
			end if;
		when st7_CR =>
			if  data = "00101110" then -- "." ascii --"00001010" then -- LF ASCII	   
				next_state <= st9_LF;
			else
				next_state <= st8_dato_y_LRC_rec;
			end if;
		when st8_dato_y_LRC_rec =>
			if new_data = '1' then
				next_state <= st7_CR;
			end if;
		when st9_LF =>
			if  data = "01000001" then		--A asci            --"00001101" then -- CR ASCII
				next_state <= st1_det;
			end if;						
         when others =>
            	next_state <= st1_det;
      end case;      
   end process;

--**************Escritura en bloque ram*****************************
SEram <= '1' when state = st8_dato_y_LRC_rec or state = st5_func_alto or state = st6_func_bajo else
		'0';
ADDR	<= Sram_addr;
data_ram <= Sdata_ram;



--**************Escritura en bloque ram*****************************
guardar_en_ram: process(clk,reset)
begin
	if reset = '1' or state = st1_det then
		Sram_addr <= (others=>'0');
	elsif clk'event and clk = '1' then
		if Sbin_ok_pond = '1' then
			Sram_addr <= Sram_addr +1;
		end if;
	end if;
end process guardar_en_ram;
WE <= Sbin_ok_pond;
--*************************************************************************


Strama_ok <= '1' when state /= st1_det and state /= st9_LF and data /= "00111010"  else
	   	'0';
E <= Strama_ok;

process(clk, reset)
begin
  if (reset = '1') then
    SsQ1 <= '0';
    SsQ2 <= '0';
    SsQ3 <= '0';
  elsif (clk'event and clk = '1') then
    SsQ1 <= Sstate_bin;
    SsQ2 <= SsQ1;
    SsQ3 <= SsQ2;
  end if;
end process;
Sstate_bin <= '1' when state = st9_LF else
			'0';    
end Behavioral;

