---------------------------------------------------------------------------------------------------
--
-- Title       : trd_main_v8
-- Author      : Dmitry Smekhov
-- Company     : Instrumental System  
--
--  Version	   : 1.4
--
---------------------------------------------------------------------------------------------------
--
-- Description : Реализация тетрады MAIN
--									 
--				Модификация 8 - не используются счётчики CNT0, CNT1, CNT2
--						Выход cmd_data_out реализован на мультиплексоре
--						Узел начального тестирования сбрасывается через сигнал сброса FIFO
--						Поддерживается тестовый режим работы SYNX
--												 
---------------------------------------------------------------------------------------------------
--
--	 Регистр SYNX			  		  
--			0 - RDY0_OUT
--			1 - RDY1_OUT
--			4 - RDY0_OE
--			5 - RDY1_OE
--			12 - START_EN_OUT
--			13 - SYNC0_OUT	   
--			14 - ENCODE_OUT											 
--			15 - SYNX_TEST_MODE
--						   
--	 Регистр SYNX_IN  	- адрес 0x202
--			9  - SN_RDY0
--			10 - SN_RDY1
--			11 - SN_START
--			12 - SN_START_EN
--			13 - SN_SYNC0
--			14 - SN_ENCODE		- вход тактовой частоы
--			15 - SYNX_TEST_MODE - значение установленное в SYNX_TEST_MODE
--
---------------------------------------------------------------------------------------------------
--
--  Version	 1.4  10.06.2010
--			 Добавлены входы irq и drq для тетрад 8..15
--			 Входы начинают действовать при установке параметра ext_drq=1
--
--			 Добавлен регистр TEST_MODE - управление режимом формирования 
--			 тестовой последовательности
--
--
---------------------------------------------------------------------------------------------------
--
--  Version	 1.3  26.03.2009
--			 Добавлен выход запроса DMA	   
--
--			 11.05.2010 Добавлены триггеры на выходы reset_out, fifo_rst_out
--
---------------------------------------------------------------------------------------------------
--
--  Version	 1.2  06.12.2006
--			 Исправлено формирование запроса DMA - запрос разрешается при установке MODE0[3]=1
--			 Исправлен сброс тестового регистра - сброс может производиться через команду сброса FIFO
--
---------------------------------------------------------------------------------------------------
--
--  Version	 1.1  12.12.2005
--			   Убран буфер с 3-состоянием
--
---------------------------------------------------------------------------------------------------
--
--  Version	 1.0  25.08.2005
--			   Создан из trd_main_v1  версии 1.2
--
---------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.adm2_pkg.all;

package trd_main_v8_pkg is
	
constant  ID_MAIN		: std_logic_vector( 15 downto 0 ):=x"0001"; -- идентификатор тетрады
constant  ID_MODE_MAIN	: std_logic_vector( 15 downto 0 ):=x"0008"; -- модификатор тетрады
constant  VER_MAIN		: std_logic_vector( 15 downto 0 ):=x"0104";	-- версия тетрады
constant  RES_MAIN		: std_logic_vector( 15 downto 0 ):=x"0010";	-- ресурсы тетрады
constant  FIFO_MAIN		: std_logic_vector( 15 downto 0 ):=x"0100"; -- размер FIFO
constant  FTYPE_MAIN 	: std_logic_vector( 15 downto 0 ):=x"0040"; -- ширина FIFO

component trd_main_v8 is
	generic(
		sync0_mode	: in integer:=0;	-- режим управления sync0_out
										--  0 - через SYNX(13)
										--  1 - при SYNX(15)='0' - вход sn_sync0_in
										--	    при SYNX(15)='1' - через SYNX(13)
										
		ext_drq		: in integer:=0		-- 0 - используются только входы b1_drq - b7_drq
										-- 1 - используются все входы b_drq
	);
	port ( 
	
		-- GLOBAL
		reset		: in std_logic;
		clk			: in std_logic;
		
		-- T0		 
		adr_in		: in std_logic_vector( 6 downto 0 ); 	-- шина адреса
		data_in		: in std_logic_vector( 63 downto 0 );	-- шина данных для DATA
		cmd_data_in	: in std_logic_vector( 15 downto 0 ); 	-- шина данных для CMD_DATA
		
		cmd			: in bl_cmd; 							-- команда для терады
		
		data_out	: out std_logic_vector( 63 downto 0 );	-- выход DATA
		cmd_data_out: out std_logic_vector( 15 downto 0 );	-- выход регистров
		
		bx_drq		: out bl_drq;		-- управление DMA
		
		test_mode	: out std_logic; 						-- 1 - тестовый режим работы
		test_mode_init: in std_logic:='1';					-- начальное состояние test_mode
		fifo_rst_out: out std_logic; -- 0 - сброс FIFO
		
		-- Вход прерываний 
		b1_irq		: in std_logic:='0';
		b2_irq		: in std_logic:='0';
		b3_irq		: in std_logic:='0';
		b4_irq		: in std_logic:='0';
		b5_irq		: in std_logic:='0';
		b6_irq		: in std_logic:='0';
		b7_irq		: in std_logic:='0';
		b8_irq		: in std_logic:='0';
		b9_irq		: in std_logic:='0';
		b10_irq		: in std_logic:='0';
		b11_irq		: in std_logic:='0';
		b12_irq		: in std_logic:='0';
		b13_irq		: in std_logic:='0';
		b14_irq		: in std_logic:='0';
		b15_irq		: in std_logic:='0';

		
		-- Вход запросов DMA
		b1_drq		: in bl_drq:=( '0', '0', '0' );
		b2_drq		: in bl_drq:=( '0', '0', '0' );
		b3_drq		: in bl_drq:=( '0', '0', '0' );
		b4_drq		: in bl_drq:=( '0', '0', '0' );
		b5_drq		: in bl_drq:=( '0', '0', '0' );
		b6_drq		: in bl_drq:=( '0', '0', '0' );
		b7_drq		: in bl_drq:=( '0', '0', '0' );
		b8_drq		: in bl_drq:=( '0', '0', '0' );
		b9_drq		: in bl_drq:=( '0', '0', '0' );
		b10_drq		: in bl_drq:=( '0', '0', '0' );
		b11_drq		: in bl_drq:=( '0', '0', '0' );
		b12_drq		: in bl_drq:=( '0', '0', '0' );
		b13_drq		: in bl_drq:=( '0', '0', '0' );
		b14_drq		: in bl_drq:=( '0', '0', '0' );
		b15_drq		: in bl_drq:=( '0', '0', '0' );
		
		-- Выход DRQ и IRQ		
		int1		: out std_logic;
		int2		: out std_logic;
		int3		: out std_logic;
		
		drq0		: out bl_drq;
		drq1		: out bl_drq;
		drq2		: out bl_drq;
		drq3		: out bl_drq;
		
			
		reset_out	: out std_logic; -- программный сброс
		
		
		-- Управление мультплексором
		cp0			: out std_logic;
		cp1			: out std_logic;	
		
		-- Управление генераторами
		goe0		: out std_logic;
		goe1		: out std_logic;
		
		-- THDAC
		thclk		: out std_logic; 	-- тактовая частота загрузки ИПН
		thdin		: out std_logic;	-- данные ИПН
		thrs		: out std_logic;	-- сброс ИПН
		thld		: out std_logic;	-- загрузка данных в ИПН
		
		
		
		mode0		: out std_logic_vector( 15 downto 0 );	-- регистр MODE0
		mode1		: out std_logic_vector( 15 downto 0 );  -- регистр MODE1	   
		synx		: out std_logic_vector( 15 downto 0 );  -- регистр SYNX
		
		-- Выход регистров выбора канала DMA
		sel_drq0	: out std_logic_vector( 6 downto 0 );
		sel_drq1	: out std_logic_vector( 6 downto 0 );
		sel_drq2	: out std_logic_vector( 6 downto 0 );
		sel_drq3	: out std_logic_vector( 6 downto 0 );
		
		-- Тактовая частота
		b_clk		: in std_logic_vector( 15 downto 0 );	-- вход
		bx_clk		: out std_logic; 		-- выбранная тактовая частота тетрады
		
		-- Старт
		b_start		: in std_logic_vector( 15 downto 0 ); -- вход
		bx_start	: out std_logic; 		-- сигнал разрешения сбора
		bx_start_a	: out std_logic; 		-- асинхронный сигнал разрешения сбора
		bx_start_sync: out std_logic;  		-- импульс синхронизации
		
		-- SYNX
		sn_rdy0		: in std_logic;			-- готовность 0
		sn_rdy1		: in std_logic;			-- готовность 1
		sn_start_en	: in std_logic;			-- 0 - разрешение сбора
		sn_sync0	: in std_logic;			-- вход сигнала sync
		
		sn_rdy0_out	: out std_logic;		-- выход sn_rdy0
		sn_rdy1_out	: out std_logic;		-- выход sn_rdy1
		sn_start_en_out: out std_logic;		-- выход sn_start_en
		sn_sync0_out: out std_logic;		-- выход sn_sync0
		sn_sync0_in : in  std_logic:='0';	-- управление сигналом sn_syn0_out в ребочем режиме
		
		sn_rdy0_oe	: out std_logic;		-- 1 - разрешение выхода sn_rdy0
		sn_rdy1_oe	: out std_logic;		-- 1 - разрешение выхода sn_rdy1
		sn_master	: out std_logic	 		-- 1 - разрешение выхода start_en, start, encode
		
		
		
	);			  
end component;
	
end trd_main_v8_pkg;



library ieee;
use ieee.std_logic_1164.all;
							  
library work;
use work.adm2_pkg.all;
use	work.ctrl_start_v2_pkg.all;	
use work.cl_test0_v4_pkg.all;

entity trd_main_v8 is	   
	generic(
		sync0_mode	: in integer:=0;	-- режим управления sync0_out
										--  0 - через SYNX(13)
										--  1 - при SYNX(15)='0' - вход sn_sync0_in
										--	    при SYNX(15)='1' - через SYNX(13)
										
		ext_drq		: in integer:=0		-- 0 - используются только входы b1_drq - b7_drq
										-- 1 - используются все входы b_drq
										
	);
	port ( 
		-- GLOBAL
		reset		: in std_logic;
		clk			: in std_logic;
		
		-- T0		 
		adr_in		: in std_logic_vector( 6 downto 0 ); 	-- шина адреса
		data_in		: in std_logic_vector( 63 downto 0 );	-- шина данных для DATA
		cmd_data_in	: in std_logic_vector( 15 downto 0 ); 	-- шина данных для CMD_DATA
		
		cmd			: in bl_cmd; 							-- команда для терады
		
		data_out	: out std_logic_vector( 63 downto 0 );	-- выход DATA
		cmd_data_out: out std_logic_vector( 15 downto 0 );	-- выход регистров
		
		bx_drq		: out bl_drq;		-- управление DMA
		
		test_mode	: out std_logic; 						-- 1 - тестовый режим работы
		test_mode_init: in std_logic:='1';					-- начальное состояние test_mode
		fifo_rst_out: out std_logic; -- 0 - сброс FIFO
		
		-- Вход прерываний 
		b1_irq		: in std_logic:='0';
		b2_irq		: in std_logic:='0';
		b3_irq		: in std_logic:='0';
		b4_irq		: in std_logic:='0';
		b5_irq		: in std_logic:='0';
		b6_irq		: in std_logic:='0';
		b7_irq		: in std_logic:='0';
		b8_irq		: in std_logic:='0';
		b9_irq		: in std_logic:='0';
		b10_irq		: in std_logic:='0';
		b11_irq		: in std_logic:='0';
		b12_irq		: in std_logic:='0';
		b13_irq		: in std_logic:='0';
		b14_irq		: in std_logic:='0';
		b15_irq		: in std_logic:='0';

		-- Вход запросов DMA
		b1_drq		: in bl_drq:=( '0', '0', '0' );
		b2_drq		: in bl_drq:=( '0', '0', '0' );
		b3_drq		: in bl_drq:=( '0', '0', '0' );
		b4_drq		: in bl_drq:=( '0', '0', '0' );
		b5_drq		: in bl_drq:=( '0', '0', '0' );
		b6_drq		: in bl_drq:=( '0', '0', '0' );
		b7_drq		: in bl_drq:=( '0', '0', '0' );
		b8_drq		: in bl_drq:=( '0', '0', '0' );
		b9_drq		: in bl_drq:=( '0', '0', '0' );
		b10_drq		: in bl_drq:=( '0', '0', '0' );
		b11_drq		: in bl_drq:=( '0', '0', '0' );
		b12_drq		: in bl_drq:=( '0', '0', '0' );
		b13_drq		: in bl_drq:=( '0', '0', '0' );
		b14_drq		: in bl_drq:=( '0', '0', '0' );
		b15_drq		: in bl_drq:=( '0', '0', '0' );
		
		-- Выход DRQ и IRQ		
		int1		: out std_logic;
		int2		: out std_logic;
		int3		: out std_logic;
		
		drq0		: out bl_drq;
		drq1		: out bl_drq;
		drq2		: out bl_drq;
		drq3		: out bl_drq;
		
			
		reset_out	: out std_logic; -- программный сброс
		
		
		-- Управление мультплексором
		cp0			: out std_logic;
		cp1			: out std_logic;	
		
		-- Управление генераторами
		goe0		: out std_logic;
		goe1		: out std_logic;
		
		-- THDAC
		thclk		: out std_logic; 	-- тактовая частота загрузки ИПН
		thdin		: out std_logic;	-- данные ИПН
		thrs		: out std_logic;	-- сброс ИПН
		thld		: out std_logic;	-- загрузка данных в ИПН
		
		
		
		mode0		: out std_logic_vector( 15 downto 0 );	-- регистр MODE0
		mode1		: out std_logic_vector( 15 downto 0 );  -- регистр MODE1
		synx		: out std_logic_vector( 15 downto 0 );  -- регистр SYNX
		
		-- Выход регистров выбора канала DMA
		sel_drq0	: out std_logic_vector( 6 downto 0 );
		sel_drq1	: out std_logic_vector( 6 downto 0 );
		sel_drq2	: out std_logic_vector( 6 downto 0 );
		sel_drq3	: out std_logic_vector( 6 downto 0 );
		
		-- Тактовая частота
		b_clk		: in std_logic_vector( 15 downto 0 );	-- вход
		bx_clk		: out std_logic; 		-- выбранная тактовая частота тетрады
		
		-- Старт
		b_start		: in std_logic_vector( 15 downto 0 ); -- вход
		bx_start	: out std_logic; 		-- сигнал разрешения сбора
		bx_start_a	: out std_logic; 		-- асинхронный сигнал разрешения сбора
		bx_start_sync: out std_logic;  		-- импульс синхронизации
		
		-- SYNX
		sn_rdy0		: in std_logic;			-- готовность 0
		sn_rdy1		: in std_logic;			-- готовность 1
		sn_start_en	: in std_logic;			-- 0 - разрешение сбора
		sn_sync0	: in std_logic;			-- вход сигнала sync
		
		sn_rdy0_out	: out std_logic;		-- выход sn_rdy0
		sn_rdy1_out	: out std_logic;		-- выход sn_rdy1
		sn_start_en_out: out std_logic;		-- выход sn_start_en
		sn_sync0_out: out std_logic;		-- выход sn_sync0
		sn_sync0_in : in  std_logic:='0';	-- управление сигналом sn_syn0_out в ребочем режиме
		
		sn_rdy0_oe	: out std_logic;		-- 1 - разрешение выхода sn_rdy0
		sn_rdy1_oe	: out std_logic;		-- 1 - разрешение выхода sn_rdy1
		sn_master	: out std_logic	 		-- 1 - разрешение выхода start_en, start, encode
		
		
		
	);			  
	
	
end trd_main_v8;


architecture trd_main_v8 of trd_main_v8 is

component cl_test0_v1 is
	port( 
		reset: in std_logic;
		clk: in std_logic;
		
		adr_in: in std_logic_vector( 6 downto 0 );
		data_in: in std_logic_vector( 63 downto 0 );
		data_en: in std_logic;
		data_cs: in std_logic;
		
		data_out: out std_logic_vector( 63 downto 0 );
		test_mode_init: in std_logic;
		test_mode: out std_logic
	);
		
end component;				   

component ctrl_thdac is
	 port(
		 reset 		: in std_logic;		-- 0 - сброс
		 clk 		: in std_logic;		-- тактовая частота 100mhz	
		 start 		: in std_logic;		-- 1 - страт
		 data_dac 	: in std_logic_vector(11 downto 0);	-- данные для ипн
		 clkdac_out : out std_logic;	-- выходная тактовая частота
		 ld 		: out std_logic;	-- сигнал загрузки ипн
		 ready 		: out std_logic;	-- 1 - пересылка завершена
		 thrs  		: out std_logic;	-- 0 - сброс ипн
		 sdo_dac 	: out std_logic		-- последовательный порта ипн
	     );
end component;


signal c_mode0			: std_logic_vector( 15 downto 0 ); 	-- MODE0
signal c_mask, c_inv	: std_logic_vector( 15 downto 0 ); 	-- IRQ_MAK, IRQ_INV
signal c_thdac			: std_logic_vector( 11 downto 0 );	-- THDAC
signal thdac_start		: std_logic;						-- 1 - запуск выдачи в ИПН
signal c_mux			: std_logic_vector( 1 downto 0 ); 	-- MUX
signal do				: std_logic_vector( 63 downto 0 );	-- выход шины данных модуля тестирования
signal c_synx			: std_logic_vector( 15 downto 0 ); 	-- SYNX
signal c_fmode			: std_logic_vector( 5 downto 0 );	-- FMODE
signal c_fdiv			: std_logic_vector( 15 downto 0 );	-- FDIV	
signal fdiv_we			: std_logic;						-- 1 - запись в FDIV
signal c_stmode			: std_logic_vector( 15 downto 0 );	-- STMODE
signal irq_en			: std_logic_vector( 15 downto 0 ); 	-- IRQ_EN		   
signal c_test_mode		: std_logic;						-- TEST_MODE

--	выбор канала прерывания
signal c_sel0, c_sel1, c_sel2, c_sel3, c_sel4, c_sel5, c_sel6, c_sel7: std_logic_vector( 1 downto 0 );

-- выбор канала запроса DMA
signal c_sel_drq0, c_sel_drq1, c_sel_drq2, c_sel_drq3: std_logic_vector( 6 downto 0 );
signal b0_irq			: std_logic;		-- запрос прерывание
signal b0_drq			: bl_drq;			-- запрос DMA
signal rst				: std_logic;		-- 0 - сброс

-- распределение прерываний
signal i0_1, i1_1, i2_1, i3_1, i4_1, i5_1, i6_1, i7_1 : std_logic;
signal i0_2, i1_2, i2_2, i3_2, i4_2, i5_2, i6_2, i7_2 : std_logic;
signal i0_3, i1_3, i2_3, i3_3, i4_3, i5_3, i6_3, i7_3 : std_logic;
signal i8_1, i9_1, i10_1, i11_1, i12_1, i13_1, i14_1, i15_1 : std_logic;
signal i8_2, i9_2, i10_2, i11_2, i12_2, i13_2, i14_2, i15_2 : std_logic;
signal i8_3, i9_3, i10_3, i11_3, i12_3, i13_3, i14_3, i15_3 : std_logic;

signal status			: std_logic_vector( 15 downto 0 );	-- регистр состояния
signal th_rdy			: std_logic;	 					-- 1 - готовность ИПН
signal data_csp			: std_logic;  						-- 1 - чтение регистра DATA
signal drq0i, drq1i, drq2i, drq3i: bl_drq; 					-- внутренние сигналы DMA

signal	fifo_rst		: std_logic;	-- 0 - сброс узла тестирования
signal	synx_test_mode	: std_logic;	-- 1 - режим тестирования разъёма SYNX
signal	reg_synx_in		: std_logic_vector( 15 downto 0 );	-- регистр SYNX_IN
signal	bx_clki			: std_logic;

begin						   
	

data_csp <= not cmd.data_cs;
	
d_test0: cl_test0_v4
	port map ( 
		reset => reset,
		reset_reg => fifo_rst,
		clk => clk, 
		reg_test_mode	=> c_test_mode,	-- 1 - формирование псевдослучайной последовательности
		
		adr_in => adr_in,
		data_in => data_in,
		data_en => cmd.data_we,
		--data_en => '0',
		data_cs => data_csp,
		
		data_out => do,
		test_mode_init => test_mode_init,
		test_mode => test_mode	);
      
		
--xstatus: ctrl_buft16 port map( 
--	t => cmd.status_cs,
--	i =>  status,
--	o => cmd_data_out );
--
--xirq: ctrl_buft16 port map( 
--	t => cmd.cmd_data_cs,
--	i =>  irq_en,
--	o => cmd_data_out );
	
	
cmd_data_out <=  status when cmd.status_cs='0' else 
				 irq_en when cmd.adr(1)='0' else
				 reg_synx_in;
				 
	

data_out<=do;
	
	
irq_en(0)<='0';
irq_en( 15 downto 4 )<=(others=>'0');
	

pr_mode0: process( reset, clk ) 
 variable vthdac_start: std_logic;
 variable vfdiv_we: std_logic;
begin
	if( reset='0' ) then
		c_mode0<=(others=>'0');
	elsif( rising_edge( clk ) ) then
		vthdac_start:='0';		
		vfdiv_we:='0';
		if( cmd.cmd_data_we='1' ) then
			
			if( cmd.adr(9)='0' and cmd.adr(8)='0' ) then
			  case cmd.adr( 4 downto 0 ) is
				  when "00000" =>  -- MODE0
				    c_mode0<=cmd_data_in( 15 downto 0 );
				  when others=>null;
			  end case;
			end if;
		end if;		 
	end if;
end process;		 


pr_reg: process( rst, clk ) 
 variable vthdac_start: std_logic;
 variable vfdiv_we: std_logic;
begin
	if( rst='0' ) then
		vthdac_start:='0';		
		vfdiv_we:='0';	   
		irq_en( 3 downto 1 ) <= (others=>'0');
		c_mask<=(others=>'0');
		c_inv<=(others=>'0');
		c_fmode<=(others=>'0');
		c_fdiv<=(others=>'0');
		c_stmode<=(others=>'0');
		c_sel0<=(others=>'0');
		c_sel1<=(others=>'0');
		c_sel2<=(others=>'0');
		c_sel3<=(others=>'0');
		c_sel4<=(others=>'0');
		c_sel5<=(others=>'0');
		c_sel6<=(others=>'0');
		c_sel7<=(others=>'0');
		c_sel_drq0<=(others=>'0');
		c_sel_drq1<=(others=>'0');
		c_sel_drq2<=(others=>'0');
		c_sel_drq3<=(others=>'0');
		mode1<=(others=>'0');
		c_synx<=(others=>'0');
		c_mux<=(others=>'0');
		c_thdac<=(others=>'0');		   
		c_test_mode <= '0';
	elsif( rising_edge( clk ) ) then
		vthdac_start:='0';		
		vfdiv_we:='0';
		if( cmd.cmd_data_we='1' ) then
			if( cmd.adr(9)='1' and cmd.adr(8)='0' ) then
			    if( cmd.adr(0)='0' ) then -- IRQENST
				  irq_en( 3 downto 1 ) <= irq_en( 3 downto 1 ) or cmd_data_in( 3 downto 1 );
			    else
				  irq_en( 3 downto 1 ) <= irq_en( 3 downto 1 ) and not cmd_data_in( 3 downto 1 );
				end if;  
				--irq_en( 3 downto 1 ) <=  irq_en( 3 downto 1 ) or data_in( 3 downto 1 );
			end if;	
			
			if( cmd.adr(9)='0' and cmd.adr(8)='0' ) then
			  case cmd.adr( 4 downto 0 ) is
				  when "00001" =>  -- C_MASK
				    c_mask<=cmd_data_in( 15 downto 0 );
				  when "00010" =>  -- C_INV
				    c_inv<=cmd_data_in( 15 downto 0 );
--				  when "0001" => -- IRQ_ACK
--				    irq_ack<=data_in( 2 downto 0 );
				  when "00011" =>	-- FMODE
				    c_fmode<=cmd_data_in( 5 downto 0 );
				  when "00100" =>	-- FDIV
				    c_fdiv<=cmd_data_in( 15 downto 0 );
				  	vfdiv_we:='1';
				  when "00101" =>	-- STMODE
				    c_stmode<=cmd_data_in( 15 downto 0 );

				  when "01001" =>	-- MODE1
				    mode1 <= cmd_data_in( 15 downto 0 );

				  when "01100" =>	-- TEST_MODE
				    c_test_mode <= cmd_data_in(0);
					
				  when "01101" =>	-- SYNX
				    c_synx( 15 downto 0 ) <=cmd_data_in( 15 downto 0 );
				  when "01110" => 	-- THDAC
				  	c_thdac<=cmd_data_in( 11 downto 0 );
				  	vthdac_start:='1';
				  when "01111" => 	-- MUX
				   c_mux<=cmd_data_in( 1 downto 0 );
				  when "10000" => -- c_sel0
				   c_sel0( 1 downto 0 ) <=cmd_data_in( 1 downto 0 );
				   c_sel_drq0( 6 downto 0 ) <= cmd_data_in( 14 downto 8 );
				  when "10001" => -- c_sel1
				   c_sel1( 1 downto 0 ) <=cmd_data_in( 1 downto 0 );
				   c_sel_drq1( 6 downto 0 ) <= cmd_data_in( 14 downto 8 );
				  when "10010" => -- c_sel2
				   c_sel2( 1 downto 0 ) <=cmd_data_in( 1 downto 0 );
				   c_sel_drq2( 6 downto 0 ) <= cmd_data_in( 14 downto 8 );
				  when "10011" => -- c_sel3
				   c_sel3( 1 downto 0 ) <=cmd_data_in( 1 downto 0 );
				   c_sel_drq3( 6 downto 0 ) <= cmd_data_in( 14 downto 8 );
				  when "10100" => -- c_sel4
				   c_sel4( 1 downto 0 ) <=cmd_data_in( 1 downto 0 );
				  when "10101" => -- c_sel5
				   c_sel5( 1 downto 0 ) <=cmd_data_in( 1 downto 0 );
				  when "10110" => -- c_sel6
				   c_sel6( 1 downto 0 ) <=cmd_data_in( 1 downto 0 );
				  when "10111" => -- c_sel7
				   c_sel7( 1 downto 0 ) <=cmd_data_in( 1 downto 0 );
				  
				  
				  when others=>null;
			  end case;
			end if;
		end if;		 
		thdac_start <= vthdac_start;
		fdiv_we <= vfdiv_we;
	end if;
end process;		 

rst<='0' when reset='0' or c_mode0(0)='1' else '1';
reset_out<=rst after 1 ns when rising_edge( clk );						

fifo_rst <= '0' when rst='0' or c_mode0(1)='1' else '1';	
fifo_rst_out <= fifo_rst  after 1 ns when rising_edge( clk );
	
cp0<=c_mux(0);
cp1<=c_mux(1);

-- Формирование прерываний	
i0_1<='1' when c_sel0(1 downto 0)="01" and b0_irq='1' else '0';
i1_1<='1' when c_sel1(1 downto 0)="01" and b1_irq='1' else '0';
i2_1<='1' when c_sel2(1 downto 0)="01" and b2_irq='1' else '0';
i3_1<='1' when c_sel3(1 downto 0)="01" and b3_irq='1' else '0';
i4_1<='1' when c_sel4(1 downto 0)="01" and b4_irq='1' else '0';
i5_1<='1' when c_sel5(1 downto 0)="01" and b5_irq='1' else '0';
i6_1<='1' when c_sel6(1 downto 0)="01" and b6_irq='1' else '0';
i7_1<='1' when c_sel7(1 downto 0)="01" and b7_irq='1' else '0';
i8_1<='1' when c_sel0(1 downto 0)="01" and b8_irq='1' else '0';
i9_1<='1' when c_sel1(1 downto 0)="01" and b9_irq='1' else '0';
i10_1<='1' when c_sel2(1 downto 0)="01" and b10_irq='1' else '0';
i11_1<='1' when c_sel3(1 downto 0)="01" and b11_irq='1' else '0';
i12_1<='1' when c_sel4(1 downto 0)="01" and b12_irq='1' else '0';
i13_1<='1' when c_sel5(1 downto 0)="01" and b13_irq='1' else '0';
i14_1<='1' when c_sel6(1 downto 0)="01" and b14_irq='1' else '0';
i15_1<='1' when c_sel7(1 downto 0)="01" and b15_irq='1' else '0';

i0_2<='1' when c_sel0(1 downto 0)="10" and b0_irq='1' else '0';
i1_2<='1' when c_sel1(1 downto 0)="10" and b1_irq='1' else '0';
i2_2<='1' when c_sel2(1 downto 0)="10" and b2_irq='1' else '0';
i3_2<='1' when c_sel3(1 downto 0)="10" and b3_irq='1' else '0';
i4_2<='1' when c_sel4(1 downto 0)="10" and b4_irq='1' else '0';
i5_2<='1' when c_sel5(1 downto 0)="10" and b5_irq='1' else '0';
i6_2<='1' when c_sel6(1 downto 0)="10" and b6_irq='1' else '0';
i7_2<='1' when c_sel7(1 downto 0)="10" and b7_irq='1' else '0';
i8_2<='1' when c_sel0(1 downto 0)="10" and b8_irq='1' else '0';
i9_2<='1' when c_sel1(1 downto 0)="10" and b9_irq='1' else '0';
i10_2<='1' when c_sel2(1 downto 0)="10" and b10_irq='1' else '0';
i11_2<='1' when c_sel3(1 downto 0)="10" and b11_irq='1' else '0';
i12_2<='1' when c_sel4(1 downto 0)="10" and b12_irq='1' else '0';
i13_2<='1' when c_sel5(1 downto 0)="10" and b13_irq='1' else '0';
i14_2<='1' when c_sel6(1 downto 0)="10" and b14_irq='1' else '0';
i15_2<='1' when c_sel7(1 downto 0)="10" and b15_irq='1' else '0';
	
i0_3<='1' when c_sel0(1 downto 0)="11" and b0_irq='1' else '0';
i1_3<='1' when c_sel1(1 downto 0)="11" and b1_irq='1' else '0';
i2_3<='1' when c_sel2(1 downto 0)="11" and b2_irq='1' else '0';
i3_3<='1' when c_sel3(1 downto 0)="11" and b3_irq='1' else '0';
i4_3<='1' when c_sel4(1 downto 0)="11" and b4_irq='1' else '0';
i5_3<='1' when c_sel5(1 downto 0)="11" and b5_irq='1' else '0';
i6_3<='1' when c_sel6(1 downto 0)="11" and b6_irq='1' else '0';
i7_3<='1' when c_sel7(1 downto 0)="11" and b7_irq='1' else '0';
i8_3<='1' when c_sel0(1 downto 0)="11" and b8_irq='1' else '0';
i9_3<='1' when c_sel1(1 downto 0)="11" and b9_irq='1' else '0';
i10_3<='1' when c_sel2(1 downto 0)="11" and b10_irq='1' else '0';
i11_3<='1' when c_sel3(1 downto 0)="11" and b11_irq='1' else '0';
i12_3<='1' when c_sel4(1 downto 0)="11" and b12_irq='1' else '0';
i13_3<='1' when c_sel5(1 downto 0)="11" and b13_irq='1' else '0';
i14_3<='1' when c_sel6(1 downto 0)="11" and b14_irq='1' else '0';
i15_3<='1' when c_sel7(1 downto 0)="11" and b15_irq='1' else '0';
	
int1<=( i0_1 or i1_1 or i2_1 or i3_1 or	i4_1 or i5_1 or i6_1 or i7_1 or
		i8_1 or i9_1 or i10_1 or i11_1 or	i12_1 or i13_1 or i14_1 or i15_1 
		) and ( irq_en(1) );
		
int2<=( i0_2 or i1_2 or i2_2 or i3_2 or i4_2 or i5_2 or i6_2 or i7_2 or
		i8_2 or i9_2 or i10_2 or i11_2 or i12_2 or i13_2 or i14_2 or i15_2 
		) and ( irq_en(2) );
		
int3<=( i0_3 or i1_3 or i2_3 or i3_3 or i4_3 or i5_3 or i6_3 or i7_3 or
		i8_3 or i9_3 or i10_3 or i11_3 or i12_3 or i13_3 or i14_3 or i15_3 
		) and ( irq_en(3) );

	
gen_trd0: if( ext_drq=0 ) generate	 
	
pr_drq0: process( c_sel_drq0, b0_drq, b1_drq, b2_drq, b3_drq,
					b4_drq, b5_drq, b6_drq, b7_drq ) is
begin
	case c_sel_drq0( 2 downto 0 ) is
		when "000" => drq0i<=b0_drq;
		when "001" => drq0i<=b1_drq;
		when "010" => drq0i<=b2_drq;
		when "011" => drq0i<=b3_drq;
		when "100" => drq0i<=b4_drq;
		when "101" => drq0i<=b5_drq;
		when "110" => drq0i<=b6_drq;
		when "111" => drq0i<=b7_drq;		
		when others => null;
	end case;
end process;	

drq0.en<=drq0i.en and c_sel_drq0(4);
drq0.req<=drq0i.req;
drq0.ack<=drq0i.ack;

pr_drq1: process( c_sel_drq1, b0_drq, b1_drq, b2_drq, b3_drq,
					b4_drq, b5_drq, b6_drq, b7_drq ) is
begin
	case c_sel_drq1( 2 downto 0 ) is
		when "000" => drq1i<=b0_drq;
		when "001" => drq1i<=b1_drq;
		when "010" => drq1i<=b2_drq;
		when "011" => drq1i<=b3_drq;
		when "100" => drq1i<=b4_drq;
		when "101" => drq1i<=b5_drq;
		when "110" => drq1i<=b6_drq;
		when "111" => drq1i<=b7_drq;		   
		when others => null;
	end case;
end process;	

drq1.en<=drq1i.en and c_sel_drq1(4);
drq1.req<=drq1i.req;
drq1.ack<=drq1i.ack;

pr_drq2: process( c_sel_drq2, b0_drq, b1_drq, b2_drq, b3_drq,
					b4_drq, b5_drq, b6_drq, b7_drq ) is
begin
	case c_sel_drq2( 2 downto 0 ) is
		when "000" => drq2i<=b0_drq;
		when "001" => drq2i<=b1_drq;
		when "010" => drq2i<=b2_drq;
		when "011" => drq2i<=b3_drq;
		when "100" => drq2i<=b4_drq;
		when "101" => drq2i<=b5_drq;
		when "110" => drq2i<=b6_drq;
		when "111" => drq2i<=b7_drq;		
		when others => null;
	end case;
end process;			   

drq2.en<=drq2i.en and c_sel_drq2(4);
drq2.req<=drq2i.req;
drq2.ack<=drq2i.ack;





pr_drq3: process( c_sel_drq3, b0_drq, b1_drq, b2_drq, b3_drq,
					b4_drq, b5_drq, b6_drq, b7_drq ) is
begin
	case c_sel_drq3( 2 downto 0 ) is
		when "000" => drq3i<=b0_drq;
		when "001" => drq3i<=b1_drq;
		when "010" => drq3i<=b2_drq;
		when "011" => drq3i<=b3_drq;
		when "100" => drq3i<=b4_drq;
		when "101" => drq3i<=b5_drq;
		when "110" => drq3i<=b6_drq;
		when "111" => drq3i<=b7_drq;		
		when others => null;
	end case;
end process;			   

drq3.en<=drq3i.en and c_sel_drq3(4);
drq3.req<=drq3i.req;
drq3.ack<=drq3i.ack; 

end generate;



gen_trd8: if( ext_drq=1 ) generate	 
	
drq0i <= b0_drq when c_sel_drq0( 3 downto 0 )="0000" else
		 b1_drq when c_sel_drq0( 3 downto 0 )="0001" else
		 b2_drq when c_sel_drq0( 3 downto 0 )="0010" else
		 b3_drq when c_sel_drq0( 3 downto 0 )="0011" else
		 b4_drq when c_sel_drq0( 3 downto 0 )="0100" else
		 b5_drq when c_sel_drq0( 3 downto 0 )="0101" else
		 b6_drq when c_sel_drq0( 3 downto 0 )="0110" else
		 b7_drq when c_sel_drq0( 3 downto 0 )="0111" else
		 b8_drq when c_sel_drq0( 3 downto 0 )="1000" else
		 b9_drq when c_sel_drq0( 3 downto 0 )="1001" else
		 b10_drq when c_sel_drq0( 3 downto 0 )="1010" else
		 b11_drq when c_sel_drq0( 3 downto 0 )="1011" else
		 b12_drq when c_sel_drq0( 3 downto 0 )="1100" else
		 b13_drq when c_sel_drq0( 3 downto 0 )="1101" else
		 b14_drq when c_sel_drq0( 3 downto 0 )="1110" else
		 b15_drq when c_sel_drq0( 3 downto 0 )="1111";
	
	
drq0.en<=drq0i.en and c_sel_drq0(4);
drq0.req<=drq0i.req;
drq0.ack<=drq0i.ack;

drq1i <= b0_drq when c_sel_drq1( 3 downto 0 )="0000" else
		 b1_drq when c_sel_drq1( 3 downto 0 )="0001" else
		 b2_drq when c_sel_drq1( 3 downto 0 )="0010" else
		 b3_drq when c_sel_drq1( 3 downto 0 )="0011" else
		 b4_drq when c_sel_drq1( 3 downto 0 )="0100" else
		 b5_drq when c_sel_drq1( 3 downto 0 )="0101" else
		 b6_drq when c_sel_drq1( 3 downto 0 )="0110" else
		 b7_drq when c_sel_drq1( 3 downto 0 )="0111" else
		 b8_drq when c_sel_drq1( 3 downto 0 )="1000" else
		 b9_drq when c_sel_drq1( 3 downto 0 )="1001" else
		 b10_drq when c_sel_drq1( 3 downto 0 )="1010" else
		 b11_drq when c_sel_drq1( 3 downto 0 )="1011" else
		 b12_drq when c_sel_drq1( 3 downto 0 )="1100" else
		 b13_drq when c_sel_drq1( 3 downto 0 )="1101" else
		 b14_drq when c_sel_drq1( 3 downto 0 )="1110" else
		 b15_drq when c_sel_drq1( 3 downto 0 )="1111";

drq1.en<=drq1i.en and c_sel_drq1(4);
drq1.req<=drq1i.req;
drq1.ack<=drq1i.ack;

drq2i <= b0_drq when c_sel_drq2( 3 downto 0 )="0000" else
		 b1_drq when c_sel_drq2( 3 downto 0 )="0001" else
		 b2_drq when c_sel_drq2( 3 downto 0 )="0010" else
		 b3_drq when c_sel_drq2( 3 downto 0 )="0011" else
		 b4_drq when c_sel_drq2( 3 downto 0 )="0100" else
		 b5_drq when c_sel_drq2( 3 downto 0 )="0101" else
		 b6_drq when c_sel_drq2( 3 downto 0 )="0110" else
		 b7_drq when c_sel_drq2( 3 downto 0 )="0111" else
		 b8_drq when c_sel_drq2( 3 downto 0 )="1000" else
		 b9_drq when c_sel_drq2( 3 downto 0 )="1001" else
		 b10_drq when c_sel_drq2( 3 downto 0 )="1010" else
		 b11_drq when c_sel_drq2( 3 downto 0 )="1011" else
		 b12_drq when c_sel_drq2( 3 downto 0 )="1100" else
		 b13_drq when c_sel_drq2( 3 downto 0 )="1101" else
		 b14_drq when c_sel_drq2( 3 downto 0 )="1110" else
		 b15_drq when c_sel_drq2( 3 downto 0 )="1111";

drq2.en<=drq2i.en and c_sel_drq2(4);
drq2.req<=drq2i.req;
drq2.ack<=drq2i.ack;





drq3i <= b0_drq when c_sel_drq3( 3 downto 0 )="0000" else
		 b1_drq when c_sel_drq3( 3 downto 0 )="0001" else
		 b2_drq when c_sel_drq3( 3 downto 0 )="0010" else
		 b3_drq when c_sel_drq3( 3 downto 0 )="0011" else
		 b4_drq when c_sel_drq3( 3 downto 0 )="0100" else
		 b5_drq when c_sel_drq3( 3 downto 0 )="0101" else
		 b6_drq when c_sel_drq3( 3 downto 0 )="0110" else
		 b7_drq when c_sel_drq3( 3 downto 0 )="0111" else
		 b8_drq when c_sel_drq3( 3 downto 0 )="1000" else
		 b9_drq when c_sel_drq3( 3 downto 0 )="1001" else
		 b10_drq when c_sel_drq3( 3 downto 0 )="1010" else
		 b11_drq when c_sel_drq3( 3 downto 0 )="1011" else
		 b12_drq when c_sel_drq3( 3 downto 0 )="1100" else
		 b13_drq when c_sel_drq3( 3 downto 0 )="1101" else
		 b14_drq when c_sel_drq3( 3 downto 0 )="1110" else
		 b15_drq when c_sel_drq3( 3 downto 0 )="1111";

drq3.en<=drq3i.en and c_sel_drq3(4);
drq3.req<=drq3i.req;
drq3.ack<=drq3i.ack; 

end generate;


sel_drq0 <= c_sel_drq0;
sel_drq1 <= c_sel_drq1;
sel_drq2 <= c_sel_drq2;
sel_drq3 <= c_sel_drq3;

mode0 <= c_mode0;
	




b0_drq.en<=c_mode0(3);
b0_drq.req<= c_mode0(3);
b0_drq.ack<=data_csp;

bx_drq <= b0_drq;

start: ctrl_start_v2 port map ( 					

		reset	=> rst,
		mode0	=> c_mode0,
		stmode	=> c_stmode,
		fmode	=> c_fmode,
		fdiv	=> c_fdiv,
		fdiv_we	=> fdiv_we,
		
		b_clk	=> b_clk,
		b_start	=> b_start,
		
		bx_clk		=> bx_clki,
		bx_start	=> bx_start,
		bx_start_a	=> bx_start_a,
		bx_start_sync => bx_start_sync,
		goe0	=> goe0,
		goe1	=> goe1
		);

		
thdac: ctrl_thdac port map (
		 reset 	=> rst,
		 clk 	=> clk,
		 start 	=> thdac_start,
		 data_dac => c_thdac,
		 clkDAC_out => thclk,
		 ld 		=> thld,
		 ready 		=> th_rdy,
		 thrs  		=> thrs,
		 sdo_dac 	=> thdin   );
		 
-- STATUS		 
status(0) <= th_rdy;	-- CMD_RDY
status(1) <= '1';		-- RDY
status(2) <= '1';		-- EF
status(3) <= '1';		-- PAE
status(4) <= '0';		-- HF
status(5) <= '1';		-- PAF
status(6) <= '1';		-- FF
status(7) <= '0';		-- OVR
status(8) <= '0';		-- UND
status(9) <= sn_rdy0;	-- SN_RDY0
status(10) <= sn_rdy1;  -- SN_RDY1
status(11) <= b_start(4);	-- SN_START
status(12) <= sn_start_en;  -- SN_START_EN
status(13) <= sn_sync0;		-- SN_SYNC0
status(14) <= b_start(1);	-- COMP0
status(15) <= b_start(2);	-- COMP1


pr_b0_irq: process( status, c_mask, c_inv, c_mode0 ) 
 variable v: std_logic;
begin
	v:='0';
	if( c_mode0(2)='1' ) then
		for i in 0 to 15 loop
			if( ((status(i) xor c_inv(i)) and c_mask(i))='1' ) then
				v:='1';
			end if;
		end loop;
	end if;
	b0_irq<=v;
end process;


sn_rdy0_out 	<= c_synx(0);
sn_rdy1_out 	<= c_synx(1);
sn_rdy0_oe 		<= c_synx(4);
sn_rdy1_oe 		<= c_synx(5);
sn_start_en_out <= c_synx(12);
--sn_sync0_out 	<= c_synx(13);

synx_test_mode  <= c_synx(15);

gen_syn0_0: if( sync0_mode=0 ) generate
	
	sn_sync0_out 	<=  c_synx(13);

end generate;

gen_syn0_1: if( sync0_mode=1 ) generate

	sn_sync0_out 	<= sn_sync0_in when synx_test_mode='0' else c_synx(13);
	
end generate;


bx_clk <= bx_clki when 	synx_test_mode='0' else c_synx(14);
	
sn_master <= c_mode0(4);

reg_synx_in( 8 downto 0 ) <= (others=>'0');

reg_synx_in(9)  <= sn_rdy0;			-- SN_RDY0
reg_synx_in(10) <= sn_rdy1;  		-- SN_RDY1
reg_synx_in(11) <= b_start(4);		-- SN_START
reg_synx_in(12) <= sn_start_en;  	-- SN_START_EN
reg_synx_in(13) <= sn_sync0;		-- SN_SYNC0
reg_synx_in(14) <= b_clk(4);		-- SN_ENCODE
reg_synx_in(15) <= synx_test_mode;	-- SYNX_TEST_MODE

synx <= c_synx;
	
end trd_main_v8;
