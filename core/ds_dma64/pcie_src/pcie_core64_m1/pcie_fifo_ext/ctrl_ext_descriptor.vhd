-------------------------------------------------------------------------------
--
-- Title       : ctrl_ext_descriptor
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.5
--
-------------------------------------------------------------------------------
--
-- Description :  Память дескрипторов	   
--
--				  Регистры для записи
--					0 - регистр управления
--							0: 1 - разрешение записи дескриптора
--							1: 1 - сброс адреса
--							2: 
--					4 - Запись в регистр приводит к смене адреса	
--					8 - регистр записи данных в память дескриптора
--						последовательно записывается три байта адреса,
--						которые помещаются по текущему адресу памяти.
--						Первым записывается страший байт адреса.
--						
--							
--
--				  Регистры для чтения
--					0 - DESCRIPTOR_CMD
--							командное слово дескриптора
--
--				  Поле регистра состояния:
--					0: 1 - блок дескрипторов правильный
--					1: 0 - наличие следующего дескриптора
--
--
-------------------------------------------------------------------------------
--
--  Version 1.5   04.02.2012
--				  Исправлен подсчёт контрольной суммы при is_dsp48=0
--
-------------------------------------------------------------------------------
--
--  Version 1.4   14.12.2011
--				 Добавлены сигналы dsc_check_start, dsc_check_ready -
--				 для управления подсчётом контрольной суммы после 
--				 чтения дескриптора 
--
-------------------------------------------------------------------------------
--
--  Version  : 1.3  26.01.2011
--				 Добавлена запись 40-битного начального адреса дескриптора
--
-------------------------------------------------------------------------------
--
--  Version  : 1.2  05.04.2010
--				 Добавлен параметр is_dsp48 - разрешение использования
--				 блоков DSP48
--
-------------------------------------------------------------------------------
--
--  Version  :  1.1   26.01.2010 
--              Используется 40-битный адрес на шине PCI
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;   

package	 ctrl_ext_descriptor_pkg is

component ctrl_ext_descriptor is		 
	generic(
		is_dsp48		: in integer:=1		-- 1 - использовать DSP48, 0 - не использовать DSP48
	);
	port(
		---- Global ----
		reset				: in std_logic;	-- 0 - сброс
		clk					: in std_logic;	-- тактовая частота
		
		---- Запись адреса ----
		data_in				: in std_logic_vector( 31 downto 0 ); -- шина данных памяти
		pci_adr_we			: in std_logic;	-- 1 - запись адреса
		pci_adr_h_we		: in std_logic;	-- 1 - запись старших разрядов адреса
		
		---- ctrl_main ----
		dma_chn				: in  std_logic;	-- номер канала DMA
		dsc_correct			: out std_logic;		-- 1 - загружен правильный дескриптор
		dsc_cmd				: out std_logic_vector( 7 downto 0 );	-- командное слово дескриптора
		dsc_change_adr		: in  std_logic;	-- 1 - смена адреса дескриптора
		dsc_change_mode		: in  std_logic;	-- Режим изменения адреса:
												-- 0: - увеличение
		                                      	-- 1: - переход к нулевомй дескриптору
		dsc_load_en			: in  std_logic;	-- 1 - разрешение записи дескриптора
		dsc_check_start		: in  std_logic;	-- 1 - проверка дескриптора
		dsc_check_ready		: out std_logic;	-- 1 - проверка завершена

		---- ctrl_dma_ext_cmd ---
		ram0_wr				: in std_logic;	-- 1 - запись в память дескрипторов
		dma_wraddr			: in std_logic_vector( 11 downto 0 );	-- адрес памяти
		dma_wrdata			: in std_logic_vector( 63 downto 0 );	-- данные DMA
		dsc_adr_h			: out std_logic_vector( 7 downto 0 );    -- адрес, байт 4
		dsc_adr				: out std_logic_vector( 23 downto 0 );	-- адрес, байты 3..1
		dsc_size			: out std_logic_vector( 23 downto 0 );	-- размер, байты 3..1
		
		---- Контрольные точки ----
		test				: out std_logic_vector( 3 downto 0 )

	
	);
end component;

end package;

library ieee;
use ieee.std_logic_1164.all;   
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;


entity ctrl_ext_descriptor is		 
	generic(
		is_dsp48		: in integer:=1		-- 1 - использовать DSP48, 0 - не использовать DSP48
	);
	port(
		---- Global ----
		reset				: in std_logic;	-- 0 - сброс
		clk					: in std_logic;	-- тактовая частота
		
		---- Запись адреса ----
		data_in				: in std_logic_vector( 31 downto 0 ); -- шина данных памяти
		pci_adr_we			: in std_logic;	-- 1 - запись адреса
		pci_adr_h_we		: in std_logic;	-- 1 - запись старших разрядов адреса
		
		---- ctrl_main ----
		dma_chn				: in  std_logic;	-- номер канала DMA
		dsc_correct			: out std_logic;		-- 1 - загружен правильный дескриптор
		dsc_cmd				: out std_logic_vector( 7 downto 0 );	-- командное слово дескриптора
		dsc_change_adr		: in  std_logic;	-- 1 - смена адреса дескриптора
		dsc_change_mode		: in  std_logic;	-- Режим изменения адреса:
												-- 0: - увеличение
		                                      	-- 1: - переход к нулевомй дескриптору
		dsc_load_en			: in  std_logic;	-- 1 - разрешение записи дескриптора
		dsc_check_start		: in  std_logic;	-- 1 - проверка дескриптора
		dsc_check_ready		: out std_logic;	-- 1 - проверка завершена

		---- ctrl_dma_ext_cmd ---
		ram0_wr				: in std_logic;	-- 1 - запись в память дескрипторов
		dma_wraddr			: in std_logic_vector( 11 downto 0 );	-- адрес памяти
		dma_wrdata			: in std_logic_vector( 63 downto 0 );	-- данные DMA
		dsc_adr_h			: out std_logic_vector( 7 downto 0 );    -- адрес, байт 4
		dsc_adr				: out std_logic_vector( 23 downto 0 );	-- адрес, байты 3..1
		dsc_size			: out std_logic_vector( 23 downto 0 );	-- размер, байты 3..1
		
		---- Контрольные точки ----
		test				: out std_logic_vector( 3 downto 0 )

	
	);
end ctrl_ext_descriptor;


architecture ctrl_ext_descriptor of ctrl_ext_descriptor is

signal		ram_a_out	: std_logic_vector( 63 downto 0 );
signal		ram_a_out_x	: std_logic_vector( 63 downto 0 );
signal		ram_a_in	: std_logic_vector( 63 downto 0 );
signal		ram_a_adr	: std_logic_vector( 8 downto 0 );
signal		ram_a_wr	: std_logic;
signal		ram_b_wr	: std_logic;
signal		ram_b_adr	: std_logic_vector( 8 downto 0 );

--signal	reg0			: std_logic_vector( 7 downto 0 );
--signal	reg1			: std_logic_vector( 7 downto 0 );
--signal	reg2			: std_logic_vector( 7 downto 0 );

signal	reg_write		: std_logic;		   			 

signal	status			: std_logic_vector( 7 downto 0 );	  

--signal	reg84_wr		: std_logic;
--signal	reg88_wr		: std_logic;

signal	port_a		: std_logic_vector( 17 downto 0 );
signal	port_b		: std_logic_vector( 17 downto 0 );
signal	port_c		: std_logic_vector( 47 downto 0 );
signal	port_p		: std_logic_vector( 47 downto 0 );
signal  opmode		: std_logic_vector( 6 downto 0 );
signal	carry		: std_logic;

signal	reg_0		: std_logic_vector( 7 downto 0 );
signal	reg_1		: std_logic_vector( 7 downto 0 );
signal	reg_2		: std_logic_vector( 7 downto 0 );
--signal	reg_3		: std_logic_vector( 7 downto 0 );
--signal	reg_4		: std_logic_vector( 7 downto 0 );
--signal	reg_5		: std_logic_vector( 7 downto 0 );
--signal	reg_6		: std_logic_vector( 7 downto 0 );
--signal	reg_7		: std_logic_vector( 7 downto 0 );

signal	reg0_z					: std_logic;
signal	crc_reset				: std_logic;
signal	crc						: std_logic_vector( 15 downto 0 );
signal	crc_z					: std_logic;
signal	sig_error				: std_logic;
signal 	dma_descriptor_error	: std_logic;

signal	dsc_change_adr_i		: std_logic;		 
signal	crc_we					: std_logic;	 
signal	crc_we_0				: std_logic;					  

signal	dsc_check_ready_i		: std_logic;
--signal	crc_2					: std_logic_vector( 15 downto 0 );

begin	
	

--reg0 <= reg_di after 1 ns when rising_edge( clk ) and reg_write='1' and reg_adr( 2 downto 0 )="000"; -- адрес памяти 0 --
----reg1 <= reg_di after 1 ns when rising_edge( clk ) and reg_write='1' and reg_adr( 2 downto 0 )="001"; -- адрес памяти 1 --
----reg2 <= reg_di after 1 ns when rising_edge( clk ) and reg_write='1' and reg_adr( 2 downto 0 )="010"; -- регистр управления --
--
--reg_write <= reg_wr and  reg_adr(7) and not reg_adr(6); -- декодирование адресов 0x80-0x8F	
--
--reg88_wr <= reg_write and reg_adr(3) after 1 ns; -- запись в регистр 88
--
--pr_reg_write: process( clk ) begin
--	if( rising_edge( clk ) ) then
--		reg84_wr <= reg_write and reg_adr(2) after 1 ns; -- запись в регистр 84
--	end if;
--end process;
--
--
--reg_0 <= reg_di after 1 ns when rising_edge( clk ) and reg88_wr='1';
--reg_1 <= reg_0 after 1 ns when rising_edge( clk ) and reg88_wr='1';
--reg_2 <= reg_1 after 1 ns when rising_edge( clk ) and reg88_wr='1';
--reg_3 <= reg_2 after 1 ns when rising_edge( clk ) and reg88_wr='1';
--reg_4 <= reg_3 after 1 ns when rising_edge( clk ) and reg88_wr='1';
--reg_5 <= reg_4 after 1 ns when rising_edge( clk ) and reg88_wr='1';
--reg_6 <= reg_5 after 1 ns when rising_edge( clk ) and reg88_wr='1';
--reg_7 <= reg_6 after 1 ns when rising_edge( clk ) and reg88_wr='1';

--ram_a_in <= x"0000000000" & data_in( 31 downto 8 );
ram_a_in( 63 downto 32 ) <= (others=>'0');
ram_a_in( 31 downto 24 ) <= data_in( 7 downto 0 ) after 1 ns when rising_edge( clk ) and pci_adr_h_we='1';
ram_a_in( 23 downto 0 )  <= data_in( 31 downto 8 );

ram_a_wr <= pci_adr_we;

ram_b_adr( 7 downto 0 ) <= dma_wraddr( 10 downto 3 );
ram_b_adr( 8 ) <= dma_chn;

ram_b_wr <= ram0_wr and dsc_load_en;

ram_a_adr( 7 downto 0 ) <= port_c( 7 downto 0 );
ram_a_adr( 8 ) <= dma_chn;				

dsc_adr_h  <= ram_a_out( 31 downto 24 );
dsc_adr  <= ram_a_out( 23 downto 0 );
dsc_size <= ram_a_out( 63 downto 40 ); 

dsc_cmd <= ram_a_out( 39 downto 32 );

dsc_correct <= dma_descriptor_error;

	
ram0: RAMB16_S36_S36 
  generic map(
      SIM_COLLISION_CHECK => "NONE"
    )

  port map(
    DOA  	=> ram_a_out( 31 downto 0 ),  --: out std_logic_vector(3 downto 0);
    --DOB  	=> ram_b_out( 31 downto 0 ), --: out std_logic_vector(31 downto 0);
    --DOPB 	: out std_logic_vector(3 downto 0);

    ADDRA 	=> ram_a_adr( 8 downto 0 ), --: in std_logic_vector(11 downto 0);
    ADDRB 	=> ram_b_adr( 8 downto 0 ),  --: in std_logic_vector(8 downto 0);
    CLKA  	=> clk,
    CLKB  	=> clk,
    DIA   	=> ram_a_in( 31 downto 0 ), --: in std_logic_vector(3 downto 0);
    DIB   	=> dma_wrdata( 31 downto 0 ), --: in std_logic_vector(31 downto 0);
    DIPA  	=> (others=>'0'),
    DIPB  	=> (others=>'0'),
    ENA   	=> '1',
    ENB   	=> '1',
    SSRA  	=> '0',
    SSRB  	=> '0',
    WEA   	=> ram_a_wr,
    WEB   	=> ram_b_wr
    );

ram1: RAMB16_S36_S36 
  generic map(
      SIM_COLLISION_CHECK => "NONE"
    )

  port map(
    DOA  	=> ram_a_out( 63 downto 32 ),  --: out std_logic_vector(3 downto 0);
    --DOB  	=> ram_b_out( 31 downto 0 ), --: out std_logic_vector(31 downto 0);
    --DOPB 	: out std_logic_vector(3 downto 0);

    ADDRA 	=> ram_a_adr( 8 downto 0 ), --: in std_logic_vector(11 downto 0);
    ADDRB 	=> ram_b_adr( 8 downto 0 ),  --: in std_logic_vector(8 downto 0);
    CLKA  	=> clk,
    CLKB  	=> clk,
    DIA   	=> ram_a_in( 63 downto 32 ), --: in std_logic_vector(3 downto 0);
    DIB   	=> dma_wrdata( 63 downto 32 ), --: in std_logic_vector(31 downto 0);
    DIPA  	=> (others=>'0'),
    DIPB  	=> (others=>'0'),
    ENA   	=> '1',
    ENB   	=> '1',
    SSRA  	=> '0',
    SSRB  	=> '0',
    WEA   	=> ram_a_wr,
    WEB   	=> ram_b_wr
    );
	
ram_a_out_x <= ram_a_out after 1 ns;	

	
	
	
--p1 <= reg2(1);
--n1 <= not reg2(1);

-- reg0(2)=1 - изменение адреса: opmode=0x30 carry=1
-- reg0(2)=0 - запись адреса из дескриптора: opmode=0x03 carry=0
--opmode	<= '0' & p1 & p1 & "00" & n1 & n1;
--carry  <= p1;		 
--opmode <= "0110000";
opmode <= '0' & not dsc_check_start & not dsc_check_start & "00" & dsc_check_start & '0';
carry <= '1';

port_b <= x"0000" & "00";
port_a <= x"0000" & "00";


gen_dsp48: if( is_dsp48=1 ) generate

dsp: DSP48 
  generic map(

        AREG            => 1,
        B_INPUT         => "DIRECT",
        BREG            => 1,
        CARRYINREG      => 1,
        CARRYINSELREG   => 1,
        CREG            => 1,
        LEGACY_MODE     => "MULT18X18S",
        MREG            => 1,
        OPMODEREG       => 1,
        PREG            => 1,
        SUBTRACTREG     => 1
        )

  port map(
        --BCOUT                   : out std_logic_vector(17 downto 0);
        P                       => port_p,
        --PCOUT                   : out std_logic_vector(47 downto 0);

        A                       => port_a,
        B                       => port_b,
        BCIN                    => (others=>'0'),
        C                       => port_c,
        CARRYIN                 => carry,
        CARRYINSEL              => "00",
        CEA                     => '1',
        CEB                     => '1',
        CEC                     => '1',
        CECARRYIN               => '1',
        CECINSUB                => '1',
        CECTRL                  => '1',
        CEM                     => '1',
        CEP                     => '1',
        CLK                     => clk,
        OPMODE                  => opmode,
        PCIN                    => (others=>'0'),
        RSTA                    => '0',
        RSTB                    => '0',
        RSTC                    => '0',
        RSTCARRYIN              => '0',
        RSTCTRL                 => '0',
        RSTM                    => '0',
        RSTP                    => dsc_change_mode,
        SUBTRACT                => '0'
      );

	
end generate;

gen_ndsp48: if( is_dsp48=0 ) generate
	
pr_dsp: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( dsc_change_mode='1' ) then
			port_p( 11 downto 0 ) <= (others=>'0') after 1 ns;
		elsif( dsc_check_start='1' ) then
			port_p( 11 downto 0 ) <= port_p( 11 downto 0 ) + 1 after 1 ns;
		else
			port_p( 11 downto 0 ) <= port_c( 11 downto 0 ) + 1 after 1 ns;
		end if;
	end if;
end process;	
	
end generate;
	  
gen_ram: for ii in 0 to 11 generate	  

ram_adr:	ram16x1d 
		port map(
			we 	=> dsc_change_adr_i,
			d 	=> port_p(ii),
			wclk => clk,
			a0	=> dma_chn,
			a1	=> '0',
			a2	=> '0',
			a3	=> '0',
			spo	=> port_c(ii),
			dpra0 => '0',
			dpra1 => '0',
			dpra2 => '0',
			dpra3 => '1'
		);

end generate;		 

port_c( 47 downto 12 ) <= (others=>'0');

reg0_z <= dsc_load_en after 1 ns when rising_edge( clk );
crc_reset <= '1' when dsc_load_en='1' and reg0_z='0' else '0';

---- Проверка дескриптора ----
pr_crc: process( clk ) 

variable	v	: std_logic_vector( 15 downto 0 );

begin
	if( rising_edge( clk ) ) then
		if( crc_reset='1' ) then
			crc <= (others=>'1') after 1 ns;
		elsif( crc_we='1' ) then
			 v  :=  crc xor 
					ram_a_out_x( 15 downto 0 )  xor 
					ram_a_out_x( 31 downto 16 ) xor
					ram_a_out_x( 47 downto 32 ) xor
					ram_a_out_x( 63 downto 48 );
					
			crc( 15 downto 1 ) <= v( 14 downto 0 ) after 1 ns;
			crc( 0 ) <= not v( 15 ) after 1 ns;
		end if;
	end if;
end process;


------ Проверка дескриптора ----
--pr_crc2: process( clk ) 
--
--variable	v	: std_logic_vector( 15 downto 0 );
--
--begin
--	if( rising_edge( clk ) ) then
--		if( crc_reset='1' ) then
--			crc_2 <= (others=>'1') after 1 ns;
--		elsif( ram_b_wr='1' ) then
--			 v  :=  crc_2 xor 
--					dma_wrdata( 15 downto 0 )  xor 
--					dma_wrdata( 31 downto 16 ) xor
--					dma_wrdata( 47 downto 32 ) xor
--					dma_wrdata( 63 downto 48 );
--					
--			crc_2( 15 downto 1 ) <= v( 14 downto 0 ) after 1 ns;
--			crc_2( 0 ) <= not v( 15 ) after 1 ns;
--		end if;
--	end if;
--end process;

crc_z <= '1' when crc=x"0001" else '0';
dma_descriptor_error <= not ( (not crc_z) or sig_error ) after 1 ns  when rising_edge( clk );		

pr_sig: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( crc_we='1' ) then
			if( ram_a_out( 47 downto 32 )=x"4953" ) then
				sig_error <= '0' after 1 ns;
			else
				sig_error <= '1' after 1 ns;
			end if;
		end if;
	end if;
end process;


pr_dsc_check_ready: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( dsc_check_start='0' ) then
			dsc_check_ready_i <= '0' after 1 ns;
		elsif( port_p(6)='1' ) then
			dsc_check_ready_i <= '1' after 1 ns;
		end if;
	end if;
end process;

xready: srl16 port map( q=>dsc_check_ready, clk=>clk, d=>dsc_check_ready_i, a3=>'0', a2=>'1', a1=>'0', a0=>'0' );

dsc_change_adr_i <= dsc_change_adr or dsc_check_start;

crc_we_0 <= dsc_check_start and not port_p(6) after 1 ns when rising_edge( clk );
crc_we <= crc_we_0 after 1 ns when rising_edge( clk );

--pr_crc_we: process( clk ) begin
--	if( rising_edge( clk ) ) then
--		if( dsc_check_start='0' ) then
--			crc_we <= '0' after 1 ns;
--		elsif( crc_we_0='1' ) then
--			crc_we <= not crc_we after 1 ns;
--		end if;
--	end if;
--end process;

end ctrl_ext_descriptor;
