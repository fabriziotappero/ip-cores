--------------------------------------------------------------------------------------------------
--
-- Title       : block_pe_fifo_ext
-- Author      : Dmitry Smekhov
-- Company     : Instrumental System
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.3
--
---------------------------------------------------------------------------------------------------
--
-- Description : 
--		Блок управления FIFO для прошивки с ядром PCI-Express
--		
--		Модификация 2 - только режим автоинициализации	
--					  - для проекта DS_DMA64 
--
--		Регистры:
--				0x08 - DMA_MODE
--							бит 0:   CG_MODE   		1 - работа в режиме автоинициализации
--							бит 1:   DEMAND_MODE	1 - работа в режиме по запросам
--							бит 2:   DIRECT			1 - передача ADM->HOST, 0 - передача HOST->ADM
--				
--							бит 5:   DMA_INT_ENABLE  1 - разрешение формирования прерываний по флагу EOT
--
--				0x09 - DMA_CTRL
--							бит 0:   DMA_START		 - 1 - разрешение работы DMA
--							бит 1:   DMA_STOP		 - 1 - требование останова
--
--							бит 3:   PAUSE	 		 - 1 - приостановка обмена
--							бит 4:   RESET_FIFO		 - 1 - сброс внутреннего FIFO канала DMA
--				
--				0x0A - BLOCK_CNT - число блоков для обмена
--
--
--				0x10 - STATUS
--							биты 3..0:  DMA_STATUS
--							бит  4:	    DMA_EOT 		- 1 - завершение DMA
--							бит  5:  	DMA_SG_EOT		- 1 - завершение DMA в режиме SG	
--							бит  6:     DMA_INT_ERROR 	- 1 - пропуск обработки прерывания от DMA_EOT
--							бит  7:     INT_REQ			- 1 - запрос DMA
--							бит  8:     DSC_CORRECT  	- 1 - блок дескрипторов правильный
--
--							биты 15..12:  SIG			- сигнатура 0xA
--					   
--				0x11 - FLAG_CLR
--							бит  4:      DMA_EOT 	- 1 - сброс бита DMA_EOT в регистре STATUS
--
--				0x14 - PCI_ADRL
--				0x15 - PCI_ADRH
--				
--				0x17 - LOCAL_ADR
--					
--
--
---------------------------------------------------------------------------------------------------
--
--	Version 1.3		14.12.2011
--					Вычисление контрольной суммы производится после полного приёма 
--					блока дескрипторов
--
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;   

library	work;
use work.core64_type_pkg.all;

package block_pe_fifo_ext_pkg is
	
component block_pe_fifo_ext is				
	generic(
		is_dsp48			: in integer:=1			--! 1 - использовать DSP48, 0 - не использовать DSP48
	);
	port(
	
		---- Global ----
		rstp				: in std_logic;		--! 1 - сброс
		clk					: in std_logic;		--! Тактовая частота ядра - 250 МГц
		aclk				: in std_logic;		--! Тактовая частота локальной шины - 266 МГц
		
		---- TX_ENGINE ----
		tx_ext_fifo			: in type_tx_ext_fifo;			--! обмен TX->EXT_FIFO 
		tx_ext_fifo_back	: out type_tx_ext_fifo_back;	--! обмен TX->EXT_FIFO 
		
		---- RX_ENGINE ----
		rx_ext_fifo			: in type_rx_ext_fifo;			--! обмен RX->EXT_FIFO 
		
		---- REG ----
		reg_ext_fifo		: in  type_reg_ext_fifo;		--! запрос на доступ к блокам управления EXT_FIFO 
		reg_ext_fifo_back	: out type_reg_ext_fifo_back;	--! ответ на запрос 
			
		---- DISP  ----
		ext_fifo_disp		: out type_ext_fifo_disp;		--! запрос на доступ от узла EXT_FIFO 
		ext_fifo_disp_back	: in  type_ext_fifo_disp_back;	--! ответ на запрос
		
		irq					: out std_logic;				--! 1 - запрос прерывания
		
		test				: out std_logic_vector( 7 downto 0 )
		
		
							   
	);	
end component;

end package;



library ieee;
use ieee.std_logic_1164.all;   
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


library	work;
use work.ctrl_dma_ext_cmd_pkg.all;		  
use work.ctrl_ext_descriptor_pkg.all;  
use work.ctrl_ext_ram_pkg.all;		
use work.ctrl_main_pkg.all;

library unisim;
use unisim.vcomponents.all;

use work.core64_type_pkg.all;

entity block_pe_fifo_ext is	
	generic(
		is_dsp48			: in integer:=1			--! 1 - использовать DSP48, 0 - не использовать DSP48
	);
	port(
	
		---- Global ----
		rstp				: in std_logic;		--! 1 - сброс
		clk					: in std_logic;		--! Тактовая частота ядра - 250 МГц
		aclk				: in std_logic;		--! Тактовая частота локальной шины - 266 МГц
		
		---- TX_ENGINE ----
		tx_ext_fifo			: in type_tx_ext_fifo;			--! обмен TX->EXT_FIFO 
		tx_ext_fifo_back	: out type_tx_ext_fifo_back;	--! обмен TX->EXT_FIFO 
		
		---- RX_ENGINE ----
		rx_ext_fifo			: in type_rx_ext_fifo;			--! обмен RX->EXT_FIFO 
		
		---- REG ----
		reg_ext_fifo		: in  type_reg_ext_fifo;		--! запрос на доступ к блокам управления EXT_FIFO 
		reg_ext_fifo_back	: out type_reg_ext_fifo_back;	--! ответ на запрос 
			
		---- DISP  ----
		ext_fifo_disp		: out type_ext_fifo_disp;		--! запрос на доступ от узла EXT_FIFO 
		ext_fifo_disp_back	: in  type_ext_fifo_disp_back;	--! ответ на запрос

		irq					: out std_logic;				--! 1 - запрос прерывания
		
		test				: out std_logic_vector( 7 downto 0 )
		
	);		
end block_pe_fifo_ext;


architecture block_pe_fifo_ext of block_pe_fifo_ext is					   



signal	ram_adra	: std_logic_vector( 8 downto 0 );
signal	ram_adrb	: std_logic_vector( 8 downto 0 );
signal	ram_di_a	: std_logic_vector( 31 downto 0 );
signal	ram_do_a	: std_logic_vector( 31 downto 0 );
signal	ram_we_a	: std_logic;
signal	ram_do_b	: std_logic_vector( 31 downto 0 );
signal	reg_dma0_status	: std_logic_vector( 15 downto 0 );
signal	reg_dma1_status	: std_logic_vector( 15 downto 0 );

------------------------------------------------------------------------------------
--
-- declaration of KCPSM3
--
  component kcpsm3
    Port (      address : out std_logic_vector(9 downto 0);
            instruction : in std_logic_vector(17 downto 0);
                port_id : out std_logic_vector(7 downto 0);
           write_strobe : out std_logic;
               out_port : out std_logic_vector(7 downto 0);
            read_strobe : out std_logic;
                in_port : in std_logic_vector(7 downto 0);
              interrupt : in std_logic;
          interrupt_ack : out std_logic;
                  reset : in std_logic;
                    clk : in std_logic);
    end component;
--
-- declaration of program ROM
--
  component p_fifo
    Port (      address : in std_logic_vector(9 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                    clk : in std_logic);
    end component;
--
------------------------------------------------------------------------------------
--
-- Signals used to connect KCPSM3 to program ROM
--
signal     address : std_logic_vector(9 downto 0);
signal instruction : std_logic_vector(17 downto 0);
signal 	port_id		: std_logic_vector( 7 downto 0 );
signal	write_strobe	: std_logic;
signal	read_strobe		: std_logic;
signal	interrupt		: std_logic;
signal	interrupt_ack	: std_logic;
signal	kc_reset		: std_logic;
signal	in_port			: std_logic_vector( 7 downto 0 );
signal	out_port		: std_logic_vector( 7 downto 0 );

signal	reg4_do			: std_logic_vector( 7 downto 0 );
signal	reg8_do			: std_logic_vector( 7 downto 0 );
signal	ram0_wr			: std_logic;
signal	ram1_wr			: std_logic;
signal	ram_adr			: std_logic_vector( 10 downto 0 );

signal	reg_dma_chn		: std_logic_vector( 1 downto 0 );
signal	reg_status		: std_logic_vector( 7 downto 0 );
signal	reg_dma_status	: std_logic_vector( 3 downto 0 );
signal	reg_descriptor_status	: std_logic_vector( 1 downto 0 );		 
signal	dsc_adr_h		: std_logic_vector( 7 downto 0 );    -- адрес, байт 4
signal	dsc_adr			: std_logic_vector( 23 downto 0 );
signal	dsc_size		: std_logic_vector( 23 downto 0 ); 

signal	dma0_rs0		: std_logic_vector( 7 downto 0 );
signal	dma1_rs0		: std_logic_vector( 7 downto 0 );		   
signal	dma0_rs0x		: std_logic_vector( 7 downto 0 );
signal	dma1_rs0x		: std_logic_vector( 7 downto 0 );		   
signal	dma_rs0			: std_logic_vector( 7 downto 0 );
signal	reg_test		: std_logic_vector( 7 downto 0 );

signal	dx				: std_logic_vector( 7 downto 0 );	
signal	ram_transfer_rdy	: std_logic;

signal	dma0_transfer_rdy	: std_logic;
signal	dma1_transfer_rdy	: std_logic;
signal	dma0_eot_clr		: std_logic;
signal	dma1_eot_clr		: std_logic;
signal	dma0_ctrl			: std_logic_vector( 7 downto 0 );
signal	dma1_ctrl			: std_logic_vector( 7 downto 0 );
signal	ram_change			: std_logic;	-- 1 - изменение блока памяти
signal	reg_dma0_ctrl		: std_logic_vector( 7 downto 0 );
signal	reg_dma1_ctrl		: std_logic_vector( 7 downto 0 );
signal	reg_dma0_mode		: std_logic_vector( 7 downto 0 );
signal	reg_dma1_mode		: std_logic_vector( 7 downto 0 );
		
		---- ctrl_ext_descriptor ----
signal	dsc_correct			: std_logic;		-- 1 - загружен правильный дескриптор
signal	dsc_cmd				: std_logic_vector( 7 downto 0 );	-- командное слово дескриптора
signal	dsc_change_adr		: std_logic;	-- 1 - смена адреса дескриптора
signal	dsc_change_mode		: std_logic;	-- Режим изменения адреса:
												-- 0: - увеличение
		                                      	-- 1: - переход к нулевомй дескриптору
signal	dsc_load_en			: std_logic;	-- 1 - разрешение записи дескриптора
		
		---- ctrl_dma_ext_cmd ----						 
signal	dma_reg0			: std_logic_vector( 2 downto 0 );	-- регистр упрравления
signal	dma_change_adr		: std_logic	;	-- 1 - изменение адреса и размера
signal	dma_cmd_status		: std_logic_vector( 2 downto 0 );	-- состояние DMA
signal	dma_chn				: std_logic;

signal	pci_adr_we			: std_logic;			 
signal	pci_adr_h_we		: std_logic;	-- 1 - запись старших разрядов адреса
signal	loc_adr_we			: std_logic;

signal	ack_cnt				: std_logic_vector( 4 downto 0 );

signal	reset				: std_logic;

signal	dma_wraddr			: std_logic_vector( 11 downto 0 );
signal	dma_rdaddr			: std_logic_vector( 11 downto 0 );	 
signal 	dma_wrdata			: std_logic_vector( 63 downto 0 );

signal	req_rd				: std_logic;
signal	req_wr				: std_logic;
signal	dsc_check_start		: std_logic;	-- 1 - проверка дескриптора
signal	dsc_check_ready		: std_logic;	-- 1 - проверка завершена
--
------------------------------------------------------------------------------------


begin	

reset <= not rstp after 1 ns when rising_edge( clk );


--test( 7 downto 4 ) <= (others=>'-');  

test(4) <= req_rd after 1 ns when rising_edge( clk );
test(5) <= req_wr after 1 ns when rising_edge( clk );
test(6) <= dsc_load_en;	 
test(7) <= dsc_change_adr;

ram_adrb( 8 downto 7 ) <= (others=>'0');
ram_adrb( 6 downto 0 ) <= reg_ext_fifo.adr;
	
dma_wraddr( 11 downto 0 ) <= rx_ext_fifo.adr & "000";
dma_rdaddr( 11 downto 0 ) <= tx_ext_fifo.adr & "000";
dma_wrdata <= rx_ext_fifo.data;

ram0_wr <= rx_ext_fifo.data_we ;	 
ram1_wr <= rx_ext_fifo.data_we and dma_reg0(1);

ram: RAMB16_S36_S36 
  generic map(
    SIM_COLLISION_CHECK => "NONE",
  	INIT_00	 =>  x"000000000000000000000000" & x"00000002" & x"00000000" & x"00003400" & x"00000103" & x"00001018",
	INIT_04	 =>  x"000000000000000000000000" & x"00000002" & x"00000001" & x"00003400" & x"00000103" & x"00001018"
    )

  port map(
    DOA   => ram_do_a,
    DOB   => ram_do_b, --: out std_logic_vector(15 downto 0);
	
    ADDRA => ram_adra,
    ADDRB => ram_adrb,
    CLKA  => clk,
    CLKB  => clk,
    DIA   => ram_di_a,
    DIB   => reg_ext_fifo.data,
    ENA   => '1',
    ENB   => '1',
    DIPA  => (others=>'0'),
    DIPB  => (others=>'0'),		 
    SSRA  => '0',
    SSRB  => '0',
    WEA   => ram_we_a,
    WEB   => reg_ext_fifo.data_we
	
	
    --ADDRA : in std_logic_vector(10 downto 0);
    --ADDRB : in std_logic_vector(9 downto 0);
 
    );
	
	
reg_ext_fifo_back.data( 15 downto 0 )	<=	reg_dma0_status when  ram_adrb="0010000" else
											reg_dma1_status when  ram_adrb="0110000" else
											ram_do_b( 15 downto 0 );
 
reg_ext_fifo_back.data( 31 downto 16 ) <= ram_do_b( 31 downto 16 );


test(0) <= reg_dma0_status(4) after 1 ns when rising_edge( clk );
test(1) <= dma0_transfer_rdy after 1 ns when rising_edge( clk );	  
test(2) <= dma_cmd_status(0) after 1 ns when rising_edge( clk );
test(3) <= dma0_eot_clr after 1 ns when rising_edge( clk );



pr_dma_ctrl: process( clk ) begin
	if( rising_edge( clk ) ) then
		dma0_eot_clr <= '0' after 1 ns;
		dma1_eot_clr <= '0' after 1 ns;
		if( rstp='1' ) then
			reg_dma0_ctrl <= x"00" after 1 ns;
			reg_dma1_ctrl <= x"00" after 1 ns;
			reg_dma0_mode <= x"00" after 1 ns;
			reg_dma1_mode <= x"00" after 1 ns;
		elsif( reg_ext_fifo.data_we='1' ) then  
			case( reg_ext_fifo.adr ) is
				when "0001000" => reg_dma0_mode <= reg_ext_fifo.data( 7 downto 0 ) after 1 ns;
				when "0001001" => reg_dma0_ctrl <= reg_ext_fifo.data( 7 downto 0 ) after 1 ns;
				when "0010001" => dma0_eot_clr  <= reg_ext_fifo.data(4) after 1 ns;
				when "0101000" => reg_dma1_mode <= reg_ext_fifo.data( 7 downto 0 ) after 1 ns;
				when "0101001" => reg_dma1_ctrl <= reg_ext_fifo.data( 7 downto 0 ) after 1 ns;
				when "0110001" => dma1_eot_clr  <= reg_ext_fifo.data(4) after 1 ns;
				when others => null;
			end case;
		end if;
	end if;
end process;

dma0_ctrl(0) <= reg_dma0_ctrl(0); -- DMA_START	 
dma0_ctrl(1) <= reg_dma0_mode(1); -- DEMAND_MODE
dma0_ctrl(2) <= reg_dma0_mode(2); -- DIRECT
dma0_ctrl(3) <= reg_dma0_ctrl(3); -- PAUSE
dma0_ctrl(4) <= reg_dma0_ctrl(4); -- RESET_FIFO
dma0_ctrl(5) <= reg_dma0_mode(5); -- DMA_INT_ENABLE
dma0_ctrl(6) <= '0';
dma0_ctrl(7) <= '0';


dma1_ctrl(0) <= reg_dma1_ctrl(0); -- DMA_START	 
dma1_ctrl(1) <= reg_dma1_mode(1); -- DEMAND_MODE
dma1_ctrl(2) <= reg_dma1_mode(2); -- DIRECT
dma1_ctrl(3) <= reg_dma1_ctrl(3); -- PAUSE
dma1_ctrl(4) <= reg_dma1_ctrl(4); -- RESET_FIFO
dma1_ctrl(5) <= reg_dma1_mode(5); -- DMA_INT_ENABLE
dma1_ctrl(6) <= '0';
dma1_ctrl(7) <= '0';



main: ctrl_main 
	port map(
		---- Global ----
		reset				=> reset,	-- 0 - сброс
		clk					=> clk,		-- тактовая частота

		---- Регистры управления ----
		dma0_ctrl			=> dma0_ctrl,		-- Регистр DMA_CTRL, канал 0
		dma1_ctrl			=> dma1_ctrl,		-- Регистр DMA_CTRL, канал 0
		
		---- ctrl_ext_ram ----
		dma0_transfer_rdy	=> dma0_transfer_rdy,	-- 1 - канал 0 готов к обмену
		dma1_transfer_rdy	=> dma1_transfer_rdy,	-- 1 - канал 1 готов к обмену
		
		---- Управление DMA ----
		dma_chn				=> dma_chn,			-- номер канала DMA для текущего обмена
		ram_do				=> ram_di_a( 7 downto 0 ),		-- данные для записи в регистр STATUS
		ram_adr				=> ram_adra,		-- адрес для записи в регистр STATUS
		ram_we				=> ram_we_a,		-- 1 - запись в память
		dma0_eot_clr		=> dma0_eot_clr,	-- 1 - сброс флага DMA0_EOT
		dma1_eot_clr		=> dma1_eot_clr,	-- 1 - сброс флага DMA1_EOT
		
		reg_dma0_status		=> reg_dma0_status,	-- регистр STATUS канала 0
		reg_dma1_status		=> reg_dma1_status,	-- регистр STATUS канала 1
		
		---- ctrl_ext_ram	----
		ram_change			=> ram_change,		-- 1 - изменение блока памяти
		loc_adr_we			=> loc_adr_we,		-- 1 - запись локального адреса
		
		---- ctrl_ext_descriptor ----
		pci_adr_we			=> pci_adr_we,		-- 1 - запись адреса
		pci_adr_h_we		=> pci_adr_h_we,	-- 1 - запись старших разрядов адреса
		dsc_correct			=> dsc_correct,		-- 1 - загружен правильный дескриптор
		dsc_cmd				=> dsc_cmd,			-- командное слово дескриптора
		dsc_change_adr		=> dsc_change_adr,	-- 1 - смена адреса дескриптора
		dsc_change_mode		=> dsc_change_mode,	-- Режим изменения адреса:
												-- 0: - увеличение
		                                      	-- 1: - переход к нулевомй дескриптору
		dsc_load_en			=> dsc_load_en,		-- 1 - разрешение записи дескриптора
		dsc_check_start		=> dsc_check_start,	-- 1 - проверка дескриптора
		dsc_check_ready		=> dsc_check_ready,	-- 1 - проверка завершена
		
		---- ctrl_dma_ext_cmd ----						 
		dma_reg0			=> dma_reg0,		-- регистр упрравления
		dma_change_adr		=> dma_change_adr,	-- 1 - изменение адреса и размера
		dma_status			=> dma_cmd_status		-- состояние DMA
																	-- 0: 1 - завершение обмена
																	-- 1: 1 - ошибка при обмене
																	-- 2: 1 - размер блока равен 0
	);		

	
cmd: ctrl_dma_ext_cmd 
	generic map(
		is_dsp48		=> is_dsp48
	)
	port map(						  
		---- Global ----
		rstp			=> rstp,			-- 1 - сброс
		clk				=> clk,				-- тактовая частота
		
		---- CTRL_MAIN ----
		dma_reg0		=> dma_reg0,		-- регистр упрравления
		dma_change_adr	=> dma_change_adr,	-- 1 - изменение адреса и размера
		dma_cmd_status	=> dma_cmd_status,	-- состояние DMA
																-- 0: 1 - завершение обмена
																-- 1: 1 - ошибка при обмене
																-- 2: 1 - размер блока равен 0
		dma_chn			=> dma_chn,		-- номер канала DMA
		
		
		---- CTRL_EXT_DESCRIPTOR ----
		dsc_adr_h		=> dsc_adr_h,	    -- адрес, байт 4
		dsc_adr			=> dsc_adr,				-- адрес, байты 3..1
		dsc_size		=> dsc_size,			-- размер, байты 3..1
		
		
		---- TX_ENGINE ----
		tx_ext_fifo			=> tx_ext_fifo,		
		tx_req_wr			=> req_wr,	
		tx_req_rd			=> req_rd,	
		tx_rd_size			=> tx_ext_fifo_back.rd_size,	
		tx_pci_adr			=> tx_ext_fifo_back.pci_adr,	
		
		---- RX_ENGINE ----
		rx_ext_fifo			=> rx_ext_fifo
		
		---- Контрольные точки ----
		--test			: out std_logic_vector( 3 downto 0 )
	);
	
tx_ext_fifo_back.req_wr <= req_wr;	 
tx_ext_fifo_back.req_rd <= req_rd;

dsc: ctrl_ext_descriptor 
	generic map(
		is_dsp48		=> is_dsp48
	)
	port map(
		---- Global ----
		reset			=> reset,	-- 0 - сброс
		clk				=> clk,		-- тактовая частота
		
		---- Запись адреса ----
		data_in				=> ram_do_a,	 -- шина данных памяти
		pci_adr_we			=> pci_adr_we,		-- 1 - запись адреса
		pci_adr_h_we		=> pci_adr_h_we,	-- 1 - запись старших разрядов адреса
		
		---- ctrl_main ----
		dma_chn				=> dma_chn,			-- номер канала DMA
		dsc_correct			=> dsc_correct,		-- 1 - загружен правильный дескриптор
		dsc_cmd				=> dsc_cmd,			-- командное слово дескриптора
		dsc_change_adr		=> dsc_change_adr,	-- 1 - смена адреса дескриптора
		dsc_change_mode		=> dsc_change_mode,	-- Режим изменения адреса:
												-- 0: - увеличение
		                                      	-- 1: - переход к нулевомй дескриптору
		dsc_load_en			=> dsc_load_en,		-- 1 - разрешение записи дескриптора
		dsc_check_start		=> dsc_check_start,	-- 1 - проверка дескриптора
		dsc_check_ready		=> dsc_check_ready,	-- 1 - проверка завершена

		
		---- ctrl_dma_ext_cmd ---
		ram0_wr			=> ram0_wr,			-- 1 - запись в память дескрипторов
		dma_wraddr		=> dma_wraddr( 11 downto 0 ),	-- адрес памяти
		dma_wrdata		=> dma_wrdata,		-- данные DMA
		dsc_adr_h		=> dsc_adr_h,	    -- адрес, байт 4
		dsc_adr			=> dsc_adr,			-- адрес, байты 3..1
		dsc_size		=> dsc_size			-- размер, байты 3..1
		
--		---- Контрольные точки ----
--		test			: out std_logic_vector( 3 downto 0 )

	
	);	
	

	
ram_data: ctrl_ext_ram 
	generic map(
		is_dsp48		=> is_dsp48
	)
	port map(
	
		---- Global ----
		reset			=> reset,	-- 0 - сброс
		clk				=> clk,		-- Тактовая частота	250 МГц 
		aclk			=> aclk,	-- Тактовая частота 266 МГц
		
		
		---- ctrl_main ----
		ram_change		=> ram_change,		-- 1 - изменение блока памяти
		loc_adr_we		=> loc_adr_we,		-- 1 - запись локального адреса
		data_in			=> ram_do_a,		-- шина данных памяти
		dma_chn			=> dma_chn,			-- номер канала DMA
		
		
		---- Регистры управления ----
		dma0_ctrl		=> dma0_ctrl,		-- Регистр DMA_CTRL, канал 0
		dma1_ctrl		=> dma1_ctrl,		-- Регистр DMA_CTRL, канал 0
		
		
		dma0_transfer_rdy	=> dma0_transfer_rdy,	-- 1 - канал 0 готов к обмену
		dma1_transfer_rdy	=> dma1_transfer_rdy,	-- 1 - канал 1 готов к обмену
		
		
		---- PCI-Express ----
		dma_wr_en		=> dsc_size(0),		-- 1 - чтение, 0 - запись
		dma_wr			=> ram1_wr,			-- 1 - запись по шине wr_data
		dma_wrdata		=> dma_wrdata,		-- данные DMA
		dma_wraddr 		=> dma_wraddr,
		
		dma_rddata		=> tx_ext_fifo_back.data,	-- данные FIFO
		dma_rdaddr		=> dma_rdaddr,				-- адрес данных
		
		---- DISP  ----
		ext_fifo_disp		=> ext_fifo_disp,		-- запрос на доступ от узла EXT_FIFO 
		ext_fifo_disp_back	=> ext_fifo_disp_back	-- ответ на запрос
		
	);		
	


irq <= reg_dma0_status(7) or reg_dma1_status(7) or ext_fifo_disp_back.irq after 1 ns when rising_edge( clk );

end block_pe_fifo_ext;
