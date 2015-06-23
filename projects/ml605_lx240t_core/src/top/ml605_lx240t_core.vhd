-------------------------------------------------------------------------------
--
-- Title       : ml605_lx240t_core
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description : 	Проверка ядра PCI Express на модуле AMBPEX5 
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;	   

package ml605_lx240t_core_pkg is

component ml605_lx240t_core is 
	generic (
		is_simulation	: integer:=0	-- 0 - синтез, 1 - моделирование ADM
	);
	port(
		---- PCI-Express ----
	  	pci_exp_txp         : out std_logic_vector(3 downto 0);
	  	pci_exp_txn         : out std_logic_vector(3 downto 0);
	  	pci_exp_rxp         : in std_logic_vector(3 downto 0);
	  	pci_exp_rxn         : in std_logic_vector(3 downto 0);
	
	  	sys_clk_p           : in std_logic;
	  	sys_clk_n           : in std_logic;
	  	sys_reset_n         : in std_logic;						   
		
		---- Светодиоды ----
		gpio_led0			: out std_logic;
		gpio_led1			: out std_logic; 
		gpio_led2			: out std_logic; 
		gpio_led3			: out std_logic;
		gpio_led4			: out std_logic 
		
	);
end component;

end package;

library ieee;
use ieee.std_logic_1164.all;	  
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


library unisim;
use unisim.vcomponents.all;


use work.adm2_pkg.all;
use work.cl_ml605_pkg.all;				
use work.trd_main_v8_pkg.all;
use work.trd_pio_std_v4_pkg.all;
use work.trd_admdio64_out_v4_pkg.all;
use work.trd_admdio64_in_v6_pkg.all;
use work.trd_test_ctrl_m1_pkg.all;


entity ml605_lx240t_core is 
	generic (
		is_simulation	: integer:=0	-- 0 - синтез, 1 - моделирование ADM
	);
	port(
		---- PCI-Express ----
	  	pci_exp_txp         : out std_logic_vector(3 downto 0);
	  	pci_exp_txn         : out std_logic_vector(3 downto 0);
	  	pci_exp_rxp         : in std_logic_vector(3 downto 0);
	  	pci_exp_rxn         : in std_logic_vector(3 downto 0);
	
	  	sys_clk_p           : in std_logic;
	  	sys_clk_n           : in std_logic;
	  	sys_reset_n         : in std_logic;					   
		
		---- Светодиоды ----
		gpio_led0			: out std_logic;
		gpio_led1			: out std_logic; 
		gpio_led2			: out std_logic; 
		gpio_led3			: out std_logic; 
		gpio_led4			: out std_logic 

	);
end ml605_lx240t_core;


architecture ml605_lx240t_core of ml605_lx240t_core is
 


---- Тактовая частота внутренней шины ----
signal	clk				: std_logic;
	
---- 0 - Сброс для тетрады MAIN ----
signal	reset_main		: std_logic;
	
---- 0 - Сброс для всех тетрад кроме MAIN ----
signal	reset			: std_logic;
	
---- Шина адреса для подключения к узлу начального тестирования тетрады MAIN ----
signal trd_host_adr		: std_logic_vector( 31 downto 0 ):=(others=>'0');		 

---- Шина данных, через которую производиться запись в регистры тетрады ----
signal trd_host_data	: std_logic_array_16x64;	

---- Шина данных, через которую производиться запись в регистры тетрады ----		
signal trd_host_cmd_data	: std_logic_array_16x16;

		---- Комада управления для каждой тетрады ----
signal trd_host_cmd	    : std_logic_array_16xbl_cmd;

---- Выходы региста DATA от каждой тетрады ----
signal trd_data			: std_logic_array_16x64:=(others=>(others=>'0'));

---- Выходы регистров STATUS, CMD_ADR, CMD_DATA от каждой тетрады ----
signal trd_cmd_data		: std_logic_array_16x16:=(others=>(others=>'1'));

---- Запросы DMA от каждой тетрады
signal trd_drq			: std_logic_array_16xbl_drq:=(others=>(others=>'0'));

---- Запросы прерываения от каждой тетрады ----
signal trd_irq			: std_logic_array_16xbl_irq:=(others=>'0');

---- Сброс FIFO от каждой тетрады ----
signal trd_reset_fifo	: std_logic_array_16xbl_reset_fifo:=(others=>'0');

---- Запросы DMA от тетрады MAIN (после маршрутизации) ----
signal trd_main_drq		: std_logic_array_16xbl_drq:=(others=>(others=>'0'));

---- Запросы прерываения от тетрады MAIN (после маршрутизации) ----
signal trd_main_irq		: std_logic_array_16xbl_irq:=(others=>'0');

---- Регистры управления DMA ----
signal trd_main_sel_drq	: std_logic_array_16x6:=(others=>(others=>'0'));

signal	test_mode		: std_logic;

---- Комада управления для каждой тетрады ----
signal trd_trd_cmd	    : std_logic_array_16xbl_cmd;

---- Флаги FIFO ----
signal trd_flag_rd	    : std_logic_array_16xbl_fifo_flag;


signal	di_mode1		: std_logic_vector( 15 downto 0 );
signal	di_data			: std_logic_vector( 63 downto 0 );
signal	di_data_we		: std_logic;
signal	di_flag_wr		: bl_fifo_flag;
signal	di_start		: std_logic;	  
signal	di_fifo_rst		: std_logic;
signal	di_clk			: std_logic;

signal	do_mode1		: std_logic_vector( 15 downto 0 );
signal	do_data			: std_logic_vector( 63 downto 0 );
signal	do_data_cs		: std_logic;
signal	do_flag_rd		: bl_fifo_flag;		 
signal	do_start		: std_logic;
signal	do_fifo_rst		: std_logic;
signal	do_clk			: std_logic;

signal	clk200			: std_logic;
signal	freq0			: std_logic;
signal	freq1			: std_logic;
signal	freq2			: std_logic;

signal	led_h1			: std_logic;
signal	led_h2			: std_logic;
signal	led_h3			: std_logic;
signal	led_h4			: std_logic;

signal	led_h1_p		: std_logic;
signal	led_h2_p		: std_logic;
signal	led_h3_p		: std_logic;
signal	led_h4_p		: std_logic;


signal	tp1				: std_logic;
signal	tp2				: std_logic;
signal	tp3				: std_logic;	

signal	px				: std_logic_vector( 3 downto 1 );

signal	clk30k			: std_logic;

----------------- Константы ----------------------------------------
constant rom_main:  bl_trd_rom:=
(  
	0=>ID_MAIN, 			-- Идентификатор тетрады
	1=>ID_MODE_MAIN,		-- Модификатор тетрады
	2=>VER_MAIN,  			-- Версия тетрады
	3=>RES_MAIN,  			-- Ресурсы тетрады
	4=>FIFO_MAIN, 			-- Размер FIFO, иммитируется FIFO 256x64
	5=>FTYPE_MAIN, 			-- Тип FIFO
	6=>x"0100",  			-- Подключение тетрады
	7=>x"0001", 			-- Номер экземпляра
    8=>x"4953", 			-- Сигнатура ПЛИС ADM
	9=>x"0200", 			-- Версия ADM
	10=>x"0100", 			-- Версия прошивки ПЛИС
	11=>x"0000",			-- Модификация прошивки ПЛИС
	12=>"0000000011000011", -- Используемые тетрады
	13=>x"0000",			-- Ресурсы ПЛИС
	14=>x"0000",			-- Не используется
	15=>x"0000",			-- Не используется
	16=>x"5507",			-- Идентификатор базового модуля
	17=>x"0200",			-- Версия базового модуля
	18=>x"0000",			-- Идентификатор субмодуля
	19=>x"0000",			-- Версия субмодуля
	20=>x"0107",			-- Номер сборки прошивки
	31 downto 21 => x"0000"	);	


constant rom_dio_in:  bl_trd_rom:=
(  
	0=>ID_DIO_IN,			-- Идентификатор тетрады 
	1=>ID_MODE_DIO_IN,		-- Модификатор тетрады
	2=>VER_DIO_IN,			-- Версия тетрады
	3=>RES_DIO_IN,			-- Ресурсы тетрады
	4=>FIFO_DIO_IN,			-- Размер FIFO
	5=>FTYPE_DIO_IN, 		-- Тип FIFO
	6=>x"010D",				-- Подключение тетрады
	7=>x"0001", 			-- Номер экземпляра
	31 downto 8 => x"0000");-- резерв
	
constant rom_dio_out:  bl_trd_rom:=
(  
	0=>ID_DIO_OUT,			-- Идентификатор тетрады 
	1=>ID_MODE_DIO_OUT,		-- Модификатор тетрады
	2=>VER_DIO_OUT,			-- Версия тетрады				 			 
	3=>RES_DIO_OUT,			-- Ресурсы тетрады
	4=>FIFO_DIO_OUT,		-- Размер FIFO
	5=>FTYPE_DIO_OUT, 		-- Тип FIFO
	6=>x"0C01",				-- Подключение тетрады
	7=>x"0001", 			-- Номер экземпляра
	31 downto 8 => x"0000");-- резерв		
		
		 
constant rom_test_ctrl:  bl_trd_rom:=
(  
	0=>ID_TEST,				-- Идентификатор тетрады 
	1=>ID_MODE_TEST,		-- Модификатор тетрады
	2=>VER_TEST,			-- Версия тетрады
	3=>RES_TEST,			-- Ресурсы тетрады
	4=>FIFO_TEST,			-- Размер FIFO
	5=>FTYPE_TEST, 			-- Тип FIFO
	6=>x"0000",				-- Подключение тетрады
	7=>x"0001", 			-- Номер экземпляра
	31 downto 8 => x"0000");-- резерв		


constant trd_rom	: std_logic_array_16xbl_trd_rom	:=
(
	0 => rom_main,
	1 => rom_test_ctrl,
	2 => rom_empty,
	3 => rom_empty,
	4 => rom_empty,
	5 => rom_empty,
	6 => rom_dio_in,
	7 => rom_dio_out,
	others=> rom_empty 	);

begin
	
xled0:	obuf_s_16 port map( gpio_led0, '1' );	
xled1:	obuf_s_16 port map( gpio_led1, led_h1_p );
xled2:	obuf_s_16 port map( gpio_led2, led_h2_p );
xled3:	obuf_s_16 port map( gpio_led3, led_h3_p );
xled4:	obuf_s_16 port map( gpio_led4, led_h4_p );

led_h1_p  <= not led_h1;
led_h2_p  <= not led_h2;
led_h3_p  <= not led_h3;
led_h4_p  <= not led_h4;


tp1 <= not tp1 when rising_edge( clk );
tp2 <= px(2);
tp3 <= clk30k;

--btp1: obuf_f_16 port map( btp(1), tp1 );
--btp2: obuf_f_16 port map( btp(2), tp2 );
--btp3: obuf_f_16 port map( btp(3), tp3 );
--



amb: cl_ml605
	generic map(		

		CLKOUT6_DIVIDE 	=> 4,		-- 4 - частота системной шины 250 МГц
	
		---- Константы тетрад ----
		trd_rom			=> trd_rom,
		---- Разрешение чтения из регистра DATA ----
		trd_in			=> "0000000001000001",
		---- Разрешение чтения из регистра STATUS ----
		trd_st			=> "0000000011000011",

		is_simulation	=> is_simulation	-- 0 - синтез, 1 - моделирование ADM
	)
	port map(
	---- PCI-Express ----
		txp				=> pci_exp_txp,
		txn				=> pci_exp_txn,

		rxp				=> pci_exp_rxp,
		rxn				=> pci_exp_rxn,
		
		mgt100_p		=> sys_clk_p, 	-- тактовая частота 100 MHz от PCI_Express
		mgt100_n		=> sys_clk_n,
		
		
		bperst			=> sys_reset_n,	-- 0 - сброс						   
		
		p				=> px,		 

		led_h1			=> led_h1,	-- 0 - светится светодиод H1
		led_h2			=> led_h2,	-- 0 - светится светодиод H2 
		led_h3			=> led_h3,	-- 0 - светится светодиод H3 
		led_h4			=> led_h4,	-- 0 - светится светодиод H4
		
		---- Внутренняя шина ----
		clk_out			=> clk,  		-- тактовая частота
		reset_out		=> reset_main,	-- 0 - сброс
		test_mode		=> test_mode,	-- 1 - тестовый режим
		clk30k			=> clk30k,		-- тактовая частота 30 кГц
		clk200_out		=> clk200,		-- тактовая частота 200 МГц

		---- Шина адреса для подключения к узлу начального тестирования тетрады MAIN ----		
		trd_host_adr	=> trd_host_adr( 15 downto 0 ),
		
		---- Шина данных, через которую производиться запись в регистры тетрады ----		
		trd_host_data	=> trd_host_data,

		---- Шина данных, через которую производиться запись в регистры тетрады ----		
		trd_host_cmd_data=>trd_host_cmd_data,
				
		---- Комада управления для каждой тетрады ----		
		trd_host_cmd	=> trd_host_cmd,
		
		---- Выходы региста DATA от каждой тетрады ----
		trd_data		=> trd_data,
		
		---- Выходы регистров STATUS, CMD_ADR, CMD_DATA от каждой тетрады ----
		trd_cmd_data	=> trd_cmd_data,
		
		---- Запросы DMA от каждой тетрады ----
		trd_drq			=> trd_drq,
		
		---- Запросы DMA от тетрады MAIN (после маршрутизации) ----
		trd_main_drq	=> trd_main_drq,

		---- Регистры управления DMA ----
		trd_main_sel_drq=> trd_main_sel_drq,

		---- Сброс FIFO от каждой тетрады ----
		trd_reset_fifo	=> trd_reset_fifo,
		
		---- Запросы прерываения от тетрады MAIN (после маршрутизации) ----
		trd_main_irq	=> trd_main_irq
		
	);
	


main: trd_main_v8 
	port map 
	( 
	
		-- GLOBAL
		reset			=> reset_main,
		clk				=> clk,
		
		-- T0		 
		adr_in			=> trd_host_adr( 6 downto 0 ),
		data_in			=> trd_host_data(0),
		cmd_data_in 	=> trd_host_cmd_data(0),
		
		cmd				=> trd_host_cmd(0),
		
		data_out		=> trd_data(0),
		cmd_data_out	=> trd_cmd_data(0),
		
		bx_drq			=> trd_drq(0),			-- управление DMA
		
		test_mode		=> test_mode,
		test_mode_init	=> '1',
		
		b1_irq 			=> trd_irq(1),  
		b2_irq 			=> trd_irq(2),  
		b3_irq 			=> trd_irq(3),  
		b4_irq 			=> trd_irq(4),  
		b5_irq 			=> trd_irq(5),  
		b6_irq 			=> trd_irq(6),  
		b7_irq 			=> trd_irq(7),  

			   	
		b1_drq 			=> trd_drq(1),
		b2_drq 			=> trd_drq(2),
		b3_drq 			=> trd_drq(3),
		b4_drq 			=> trd_drq(4),
		b5_drq 			=> trd_drq(5),
		b6_drq 			=> trd_drq(6),
		b7_drq 			=> trd_drq(7),

		
		int1 			=> trd_main_irq(1),
		
		drq0 			=> trd_main_drq(0),
		drq1 			=> trd_main_drq(1),
		drq2 			=> trd_main_drq(2),
		drq3 			=> trd_main_drq(3),
		
		reset_out 		=> reset,
	   	
		fifo_rst_out	=> trd_reset_fifo(0),
		
		-- Синхронизация
		b_clk 			=> (others=>'0'),
		
		b_start 		=> (others=>'0'),
		
		-- SYNX
		sn_rdy0 		=> '0',
		sn_rdy1 		=> '0',
		sn_start_en 	=> '0',
		sn_sync0 		=> '0'
		
		);
		
		
		


dio_in: trd_admdio64_in_v6  
	port map(		
		-- GLOBAL
		reset				=> reset,		-- 0 - сброс
		clk					=> clk,			-- тактовая частота
		
		-- Управление тетрадой
		cmd_data_in 		=> trd_host_cmd_data(6),
		cmd					=> trd_host_cmd(6),
		
		data_out2			=> trd_data(6),
		cmd_data_out2		=> trd_cmd_data(6),
		
		
		bx_irq				=> trd_irq(6),  		-- 1 - прерывание от тетрады
		bx_drq				=> trd_drq(6),			-- управление DMA
		
		mode1				=> di_mode1,			-- регистр MODE1

		fifo_rst			=> di_fifo_rst, 				-- 0 - сброс FIFO (выход)
		
		start				=> di_start,			--  1 - разрешение работы (MODE0[5])
		
		-- Запись FIFO					
		data_in             => di_data,			-- данные для записи в FIFO
		data_wr             => di_data_we,		-- 1 - строб записи
		flag_wr				=> di_flag_wr,		-- флаги FIFO, синхронно с clk_wr
		clk_wr 				=> di_clk	 	-- тактовая частота записи в FIFO
	);		
	
trd_reset_fifo(6) <= di_fifo_rst;



dio_out: trd_admdio64_out_v4 
	port map(		
	
		-- GLOBAL
		reset				=> reset,		-- 0 - сброс
		clk					=> clk,			-- тактовая частота
		
		-- Управление тетрадой
		data_in				=> trd_host_data(7),
		cmd_data_in 		=> trd_host_cmd_data(7),
		
		cmd					=> trd_host_cmd(7),
		
		cmd_data_out2		=> trd_cmd_data(7),
		
		
		bx_irq				=> trd_irq(7),  		-- 1 - прерывание от тетрады
		bx_drq				=> trd_drq(7),			-- управление DMA
		
		mode1				=> do_mode1,	-- регистр MODE1
		
		fifo_rst			=> do_fifo_rst,		 	-- 0 - сброс FIFO
		start				=> do_start,			--  1 - разрешение работы (MODE0[5])
		
		-- Чтение из FIFO
		data_out			=> do_data,			-- шина данных FIFO
		data_cs         	=> do_data_cs,		-- 0 - чтение данных
		flag_rd         	=> do_flag_rd,		-- флаги FIFO
		clk_rd          	=> do_clk	   						-- тактовая частота чтения данных
		
	   );		   
		
trd_reset_fifo(7) <= do_fifo_rst;	  

freq0 <= clk;
freq1 <= '0';	
freq2 <= '0';
						

test_ctrl: trd_test_ctrl_m1 
	generic map(
		SystemFreq 	=> 2000  	-- значение системной тактовой частоты
	)
	port map(		
		-- GLOBAL
		reset			=> reset,		-- 0 - сброс
		clk				=> clk,			-- тактовая частота
		
		-- Управление тетрадой
		cmd_data_in 	=> trd_host_cmd_data(1),
		
		cmd				=> trd_host_cmd(1),
		
		cmd_data_out2	=> trd_cmd_data(1),
		
		
		bx_irq			=> trd_irq(1),  		-- 1 - прерывание от тетрады
		bx_drq			=> trd_drq(1),			-- управление DMA
		
		---- DIO_IN ----
		di_clk			=> di_clk,			-- тактовая частота записи в FIFO
		di_data			=> di_data,			-- данные	 out
		di_data_we		=> di_data_we,		-- 1 - запись данных
		di_flag_wr		=> di_flag_wr,		-- флаги FIFO
		di_fifo_rst		=> di_fifo_rst,		-- 0 - сброс FIFO
		di_mode1		=> di_mode1,		-- регистр MODE1
		di_start		=> di_start,		-- 1 - разрешение работы (MODE0[5])
		
		---- DIO_OUT ----
		do_clk			=> do_clk,		 	-- тактовая частота чтения из FIFO
		do_data			=> do_data,			-- данные  in
		do_data_cs		=> do_data_cs,		-- 0 - чтение данных
		do_flag_rd		=> do_flag_rd,		-- флаги FIFO
		do_fifo_rst		=> do_fifo_rst,		-- 0 - сброс FIFO
		do_mode1		=> do_mode1,		-- регистр MODE1
		do_start		=> do_start,		-- 1 - разрешение работы (MODE0[5])
		
		clk_sys			=> clk200,		-- опорная тактовая частота
		clk_check0		=> freq0,		-- измеряемая частота, вход 0
		clk_check1		=> freq1,		-- измеряемая частота, вход 0
		clk_check2		=> freq2		-- измеряемая частота, вход 0
		
	    );
		

end ml605_lx240t_core;
