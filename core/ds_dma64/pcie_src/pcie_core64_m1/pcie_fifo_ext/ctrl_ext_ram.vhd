-------------------------------------------------------------------------------
--
-- Title       : ctrl_ext_ram
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.2
--
-------------------------------------------------------------------------------
--
-- Description : Узел двухпортовой памяти
--				 Со стороны шины PLD_BUS - FIFO
--				 Со стороны шины PCI_Express - память
--
-------------------------------------------------------------------------------
--
--  Version 1.2  06.12.2011
--				 Добавлен local_adr_we для ctrl_ram_cmd 
--
-------------------------------------------------------------------------------
--
--  Version 1.1  05.04.2010
--				 Добавлен параметр is_dsp48 - разрешение использования
--				 блоков DSP48
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;	

library	work;
use work.core64_type_pkg.all;

package	ctrl_ext_ram_pkg is

component ctrl_ext_ram is
	generic(
		is_dsp48		: in integer:=1		-- 1 - использовать DSP48, 0 - не использовать DSP48
	);
	port(
	
		---- Global ----
		reset				: in std_logic;	-- 0 - сброс
		clk					: in std_logic;		--! Тактовая частота ядра - 250 МГц
		aclk				: in std_logic;		--! Тактовая частота локальной шины - 266 МГц
		
		---- ctrl_main ----
		ram_change			: in std_logic;	-- 1 - изменение блока памяти
		loc_adr_we			: in std_logic;	-- 1 - запись локального адреса
		data_in				: in std_logic_vector( 31 downto 0 ); -- шина данных памяти
		dma_chn				: in std_logic;		-- номер канала DMA
		
		
		---- Регистры управления ----
		dma0_ctrl			: in std_logic_vector( 7 downto 0 );	-- Регистр DMA_CTRL, канал 0
		dma1_ctrl			: in std_logic_vector( 7 downto 0 );	-- Регистр DMA_CTRL, канал 0
		
		
		dma0_transfer_rdy	: out std_logic;	-- 1 - канал 0 готов к обмену
		dma1_transfer_rdy	: out std_logic;	-- 1 - канал 1 готов к обмену
		
		
		---- PCI-Express ----
		dma_wr_en			: in std_logic;		-- 1 - разрешение записи по DMA
		dma_wr				: in std_logic;		-- 1 - запись по шине wr_data
		dma_wrdata			: in std_logic_vector( 63 downto 0 );	-- данные DMA
		dma_wraddr 			: in std_logic_vector( 11 downto 0 );		
		
		dma_rddata			: out std_logic_vector( 63 downto 0 );	-- данные FIFO
		dma_rdaddr			: in  std_logic_vector( 11 downto 0 );	-- адрес данных
		
		---- DISP  ----
		ext_fifo_disp		: out type_ext_fifo_disp;		--! запрос на доступ от узла EXT_FIFO 
		ext_fifo_disp_back	: in  type_ext_fifo_disp_back	--! ответ на запрос
	
	);	
end component;

end package;


library ieee;
use ieee.std_logic_1164.all;			 
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library	work;
use work.core64_type_pkg.all;



use work.ctrl_ram_cmd_pkg.all;

entity ctrl_ext_ram is
	generic(
		is_dsp48			: in integer:=1		-- 1 - использовать DSP48, 0 - не использовать DSP48
	);
	port(
	
		---- Global ----
		reset				: in std_logic;	-- 0 - сброс
		clk					: in std_logic;		--! Тактовая частота ядра - 250 МГц
		aclk				: in std_logic;		--! Тактовая частота локальной шины - 266 МГц
		
		---- ctrl_main ----
		ram_change			: in std_logic;	-- 1 - изменение блока памяти
		loc_adr_we			: in std_logic;	-- 1 - запись локального адреса
		data_in				: in std_logic_vector( 31 downto 0 ); -- шина данных памяти
		dma_chn				: in std_logic;		-- номер канала DMA
		
		
		---- Регистры управления ----
		dma0_ctrl			: in std_logic_vector( 7 downto 0 );	-- Регистр DMA_CTRL, канал 0
		dma1_ctrl			: in std_logic_vector( 7 downto 0 );	-- Регистр DMA_CTRL, канал 0
		
		
		dma0_transfer_rdy	: out std_logic;	-- 1 - канал 0 готов к обмену
		dma1_transfer_rdy	: out std_logic;	-- 1 - канал 1 готов к обмену
		
		
		---- PCI-Express ----
		dma_wr_en			: in std_logic;		-- 1 - разрешение записи по DMA
		dma_wr				: in std_logic;		-- 1 - запись по шине wr_data
		dma_wrdata			: in std_logic_vector( 63 downto 0 );	-- данные DMA
		dma_wraddr 			: in std_logic_vector( 11 downto 0 );		
		
		dma_rddata			: out std_logic_vector( 63 downto 0 );	-- данные FIFO
		dma_rdaddr			: in  std_logic_vector( 11 downto 0 );	-- адрес данных
		
		---- DISP  ----
		ext_fifo_disp		: out type_ext_fifo_disp;		--! запрос на доступ от узла EXT_FIFO 
		ext_fifo_disp_back	: in  type_ext_fifo_disp_back	--! ответ на запрос

	);
end ctrl_ext_ram;


architecture ctrl_ext_ram of ctrl_ext_ram is

--signal	reg_write		: std_logic;
--signal	reg_write_C1	: std_logic;
--signal	reg_write_C2	: std_logic;
--signal	reg_write_C4	: std_logic;
--signal	reg_write_C8	: std_logic;
--signal	reg_write_D0	: std_logic;
--signal	reg_write_E0	: std_logic;

signal	reg_ch0_ctrl	: std_logic_vector( 7 downto 0 );
signal	reg_ch1_ctrl	: std_logic_vector( 7 downto 0 );

signal	pf_chn			: std_logic;

signal	ram_adra		: std_logic_vector( 10 downto 0 );
signal	ram_adrb		: std_logic_vector( 10 downto 0 );			

signal	ram_we_a		: std_logic;
signal	ram_we_b		: std_logic;

signal	pf_repack_di	: std_logic_vector( 63 downto 0 );

signal	pf_adr			: std_logic_vector( 31 downto 0 );
signal	pf_ram_rd		: std_logic;  
signal	pf_ram_rd_z		: std_logic;

begin		  
	

reg_ch0_ctrl <= dma0_ctrl;
reg_ch1_ctrl <= dma1_ctrl;

gen_ram_adr: for ii in 0 to 31 generate
	
ram1:	ram16x1d 
		port map(
			we 	=> loc_adr_we,
			d 	=> data_in(ii),
			wclk => clk,
			a0	=> dma_chn,
			a1	=> '0',
			a2	=> '0',
			a3	=> '0',
			dpra0 => pf_chn,
			dpra1 => '0',
			dpra2 => '0',
			dpra3 => '0',
			dpo	  => pf_adr( ii )
		);

		
end generate;

--pf_adr( 7 downto 0 ) <= x"00";

ram_adra( 8 downto 0 ) <= dma_wraddr( 11 downto 3 ) when dma_wr_en='0' else
						  dma_rdaddr( 11 downto 3 );
						  
ram_adra( 10 ) <= dma_chn;

ram_we_a <= dma_wr and not dma_wr_en;  
ram_we_b <= ext_fifo_disp_back.data_we;


ext_fifo_disp.data_we <= pf_ram_rd  after 1 ns when rising_edge( aclk );
ext_fifo_disp.adr <= pf_adr;

pf_ram_rd_z <= pf_ram_rd after 1 ns when rising_edge( aclk );

gen_ram_data: for ii in 0 to 7 generate
	
ram: RAMB16_S9_S9 
  generic map(
    SIM_COLLISION_CHECK => "NONE"
    )

  port map(
    DOA   => dma_rddata( 7+ii*8 downto ii*8 ),
    DOB   => ext_fifo_disp.data( 7+ii*8 downto ii*8 ),

    ADDRA => ram_adra,
    ADDRB => ram_adrb,
    CLKA  => clk,
    CLKB  => aclk,
    DIA   => dma_wrdata( 7+ii*8 downto ii*8 ),
    DIB   => ext_fifo_disp_back.data( 7+ii*8 downto ii*8 ),
    DIPA  => (others=>'0'),
    DIPB  => (others=>'0'),

    ENA   => '1',
    ENB   => '1',
    SSRA  => '0',
    SSRB  => '0',
    WEA   => ram_we_a,
    WEB   => ram_we_b
    );
	
end generate;			 		 


cmd: ctrl_ram_cmd 
	generic map(
		is_dsp48		=> is_dsp48
	)
	port map(
		---- Global ----
		reset			=> reset,				-- 0 - сброс
		clk				=> clk,					-- Тактовая частота 250 МГц
		aclk			=> aclk,				-- Тактовая частота 266 МГц 
		
		---- Picoblaze ----
		dma_chn			=> dma_chn,				-- номер канала DMA	  
		reg_ch0_ctrl	=> reg_ch0_ctrl,		-- регистр управления
		reg_ch1_ctrl	=> reg_ch1_ctrl,		-- регистр управления
		reg_write_E0	=> ram_change,		-- 1 - смена блока памяти
		dma0_transfer_rdy	=> dma0_transfer_rdy,	-- 1 - блок памяти готов к обмену
		dma1_transfer_rdy	=> dma1_transfer_rdy,	-- 1 - блок памяти готов к обмену
		loc_adr_we			=> loc_adr_we,			-- 1 - запись локального адреса
		
		---- PLB_BUS ----			  
		dmar0			=> ext_fifo_disp_back.dmar(0),		-- 1 - запрос DMA 0
		dmar1			=> ext_fifo_disp_back.dmar(1),		-- 1 - запрос DMA 1
		request_wr		=> ext_fifo_disp.request_wr,		-- 1 - запрос на запись в регистр 
		request_rd		=> ext_fifo_disp.request_rd,		-- 1 - запрос на чтение из регистра 
		allow_wr		=> ext_fifo_disp_back.allow_wr,		-- 1 - разрешение записи 
		pb_complete		=> ext_fifo_disp_back.complete,		--! 1 - завершение обмена по шине PLD_BUS
		
		
		pf_repack_we	=> ext_fifo_disp_back.data_we,		-- 1 - запись в память
		pf_ram_rd_out	=> pf_ram_rd,						-- 1 - чтение из памяти
		
		---- Память ----	   
		ram_adra_a9		=> ram_adra(9),	-- разряд 9 адреса памяти
		ram_adrb		=> ram_adrb
	
	);
	
pf_chn <= ram_adrb(10);

end ctrl_ext_ram;
