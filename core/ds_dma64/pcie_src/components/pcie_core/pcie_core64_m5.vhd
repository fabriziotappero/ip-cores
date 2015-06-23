-------------------------------------------------------------------------------
--
-- Title       : pcie_core64_m5
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.1
--
-------------------------------------------------------------------------------
--
-- Description :  Контроллер шины PCI Express 
--				  Модификация 4 - Virtex 6 PCI Express 2.0 x4 
--
--				  Включает pcie_core64_m4, block_pe_main, core64_pb_transaction
--				  Реализует шину LC_BUS 
--
-------------------------------------------------------------------------------
--
--  Version 1.1  	17.02.2014
--					Добавлена поддержка Artix 7 - pcie_core64_m10
--
-------------------------------------------------------------------------------
--
--  Version 1.0  	15.08.2011
--					Создан из pcie_core64_m2 v1.0
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

package	pcie_core64_m5_pkg is

--! контроллер PCI-Express 
component pcie_core64_m5 is
	generic ( 
		CORE_NAME		: in string:="pcie_core64_m4";
		Device_ID		: in std_logic_vector( 15 downto 0 ):=x"0000"; -- идентификатор модуля
		Revision		: in std_logic_vector( 15 downto 0 ):=x"0000"; -- версия модуля
		PLD_VER			: in std_logic_vector( 15 downto 0 ):=x"0000"; -- версия ПЛИС
		
		refclk			: integer:=100;		--! Значение опорной тактовой частоты [МГц]
		is_simulation	: integer:=0	--! 0 - синтез, 1 - моделирование 
	);		  
	
	port (
	
		---- PCI-Express ----
		txp				: out std_logic_vector( 3 downto 0 );
		txn				: out std_logic_vector( 3 downto 0 );
		
		rxp				: in  std_logic_vector( 3 downto 0 );
		rxn				: in  std_logic_vector( 3 downto 0 );
		
		mgt250			: in  std_logic; -- тактовая частота 250 MHz или 100 MHz от PCI_Express
		
		perst			: in  std_logic;	-- 0 - сброс						   
		
		px				: out std_logic_vector( 7 downto 0 );	--! контрольные точки 
		
		pcie_lstatus	: out std_logic_vector( 15 downto 0 ); -- регистр LSTATUS
		pcie_link_up	: out std_logic;	-- 0 - завершена инициализация PCI-Express
		
		
		---- Локальная шина ----			  
		clk250_out		: out std_logic;		--! тактовая частота 250 MHz		  
		reset_out		: out std_logic;		--! 0 - сброс
		dcm_rstp		: out std_logic;		--! 1 - сброс DCM 266 МГц
		clk				: in std_logic;			--! тактовая частота локальной шины - 266 МГц
		clk_lock		: in std_logic;			--! 1 - захват частоты
		
		---- BAR1 ----
		lc_adr			: out std_logic_vector( 31 downto 0 );	--! шина адреса
		lc_host_data	: out std_logic_vector( 63 downto 0 );	--! шина данных - выход
		lc_data			: in  std_logic_vector( 63 downto 0 );	--! шина данных - вход
		lc_wr			: out std_logic;	--! 1 - запись
		lc_rd			: out std_logic;	--! 1 - чтение, данные должны быть на шестой такт после rd 
		lc_dma_req		: in  std_logic_vector( 1 downto 0 );	--! 1 - запрос DMA
		lc_irq			: in  std_logic;	--! 1 - запрос прерывания 
		lc_rd_cfg		: in std_logic_vector( 3 downto 0 ):="0101"	--! настройка задержки захвата данных по сигналу lc_rd				
		
				
		
	);
end component;

end package;



library ieee;
use ieee.std_logic_1164.all;

use work.core64_type_pkg.all;
--use work.pcie_core64_m4_pkg.all;
use work.core64_pb_transaction_pkg.all;
use work.block_pe_main_pkg.all;

--! контроллер PCI-Express 
entity pcie_core64_m5 is
	generic (				 
		CORE_NAME		: in string:="pcie_core64_m4";
		Device_ID		: in std_logic_vector( 15 downto 0 ):=x"0000"; -- идентификатор модуля
		Revision		: in std_logic_vector( 15 downto 0 ):=x"0000"; -- версия модуля
		PLD_VER			: in std_logic_vector( 15 downto 0 ):=x"0000"; -- версия ПЛИС
	
		refclk			: integer:=100;		--! Значение опорной тактовой частоты [МГц]
		is_simulation	: integer:=0	--! 0 - синтез, 1 - моделирование 
	);		  
	
	port (
	
		---- PCI-Express ----
		txp				: out std_logic_vector( 3 downto 0 );
		txn				: out std_logic_vector( 3 downto 0 );
		
		rxp				: in  std_logic_vector( 3 downto 0 );
		rxn				: in  std_logic_vector( 3 downto 0 );
		
		mgt250			: in  std_logic; -- тактовая частота 250 MHz или 100 MHz от PCI_Express
		
		perst			: in  std_logic;	-- 0 - сброс						   
		
		px				: out std_logic_vector( 7 downto 0 );	--! контрольные точки 
		
		pcie_lstatus	: out std_logic_vector( 15 downto 0 ); -- регистр LSTATUS
		pcie_link_up	: out std_logic;	-- 0 - завершена инициализация PCI-Express
		
		
		---- Локальная шина ----			  
		clk250_out		: out std_logic;	--! тактовая частота 250 MHz		  
		reset_out		: out std_logic;	--! 0 - сброс
		dcm_rstp		: out std_logic;		--! 1 - сброс DCM 266 МГц
		clk				: in std_logic;			--! тактовая частота локальной шины - 266 МГц
		clk_lock		: in std_logic;			--! 1 - захват частота

		---- BAR1 ----
		lc_adr			: out std_logic_vector( 31 downto 0 );	--! шина адреса
		lc_host_data	: out std_logic_vector( 63 downto 0 );	--! шина данных - выход
		lc_data			: in  std_logic_vector( 63 downto 0 );	--! шина данных - вход
		lc_wr			: out std_logic;	--! 1 - запись
		lc_rd			: out std_logic;	--! 1 - чтение, данные должны быть на четвёртый такт после rd
		lc_dma_req		: in  std_logic_vector( 1 downto 0 );	--! 1 - запрос DMA
		lc_irq			: in  std_logic;	--! 1 - запрос прерывания 
		lc_rd_cfg		: in std_logic_vector( 3 downto 0 ):="0101"	--! настройка задержки захвата данных по сигналу lc_rd				
		
				
		
	);
end pcie_core64_m5;


architecture pcie_core64_m5 of pcie_core64_m5 is

--! контроллер PCI-Express 
component pcie_core64_m4 is
	generic (  
		DEVICE_ID			: in bit_vector := X"5507";   	--! значение регистра DeviceID 
		refclk				: in integer:=100;				--! Значение опорной тактовой частоты [МГц]
		is_simulation		: in integer:=0;				--! 0 - синтез, 1 - моделирование 
		interrupt_number	: in std_logic_vector( 1 downto 0 ):="00"	-- номер INTx: 0 - INTA, 1 - INTB, 2 - INTC, 3 - INTD 
		
	);		  
	
	port (
	
		---- PCI-Express ----
		txp				: out std_logic_vector( 3 downto 0 );
		txn				: out std_logic_vector( 3 downto 0 );
		
		rxp				: in  std_logic_vector( 3 downto 0 );
		rxn				: in  std_logic_vector( 3 downto 0 );
		
		mgt250			: in  std_logic; --! тактовая частота 250 MHz или 100 МГц от PCI_Express
		
		perst			: in  std_logic;	--! 0 - сброс						   
		
		px				: out std_logic_vector( 7 downto 0 );	--! контрольные точки 
		
		pcie_lstatus	: out std_logic_vector( 15 downto 0 ); -- регистр LSTATUS
		pcie_link_up	: out std_logic;	-- 0 - завершена инициализация PCI-Express
		
		
		---- Локальная шина ----			  
		clk_out			: out std_logic;	--! тактовая частота 250 MHz		  
		reset_out		: out std_logic;	--! 0 - сброс
		dcm_rstp		: out std_logic;	--! 1 - сброс DCM 266 МГц

		---- BAR0 - блоки управления ----
		bp_host_data	: out std_logic_vector( 31 downto 0 );	--! шина данных - выход 
		bp_data			: in  std_logic_vector( 31 downto 0 );  --! шина данных - вход
		bp_adr			: out std_logic_vector( 19 downto 0 );	--! адрес регистра 
		bp_we			: out std_logic_vector( 3 downto 0 ); 	--! 1 - запись в регистры 
		bp_rd			: out std_logic_vector( 3 downto 0 );   --! 1 - чтение из регистров блока 
		bp_sel			: out std_logic_vector( 1 downto 0 );	--! номер блока для чтения 
		bp_reg_we		: out std_logic;			--! 1 - запись в регистр по адресам   0x100000 - 0x1FFFFF 
		bp_reg_rd		: out std_logic; 			--! 1 - чтение из регистра по адресам 0x100000 - 0x1FFFFF 
		bp_irq			: in  std_logic;			--! 1 - запрос прерывания 

		---- BAR1 ----	
		aclk			: in std_logic;				--! тактовая частота локальной шины - 266 МГц
		aclk_lock		: in std_logic;				--! 1 - захват частоты
		pb_master		: out type_pb_master;		--! запрос 
		pb_slave		: in  type_pb_slave			--! ответ  
		
				
		
	);
end component;

component pcie_core64_m10 is
	generic (  
		DEVICE_ID			: in std_logic_vector := x"5507";   	--! значение регистра DeviceID 
		refclk				: in integer:=100;				--! Значение опорной тактовой частоты [МГц]
		is_simulation		: in integer:=0;				--! 0 - синтез, 1 - моделирование 
		interrupt_number	: in std_logic_vector( 1 downto 0 ):="00"	-- номер INTx: 0 - INTA, 1 - INTB, 2 - INTC, 3 - INTD 
		
	);		  
	
	port (
	
		---- PCI-Express ----
		txp				: out std_logic_vector( 3 downto 0 );
		txn				: out std_logic_vector( 3 downto 0 );
		
		rxp				: in  std_logic_vector( 3 downto 0 );
		rxn				: in  std_logic_vector( 3 downto 0 );
		
		mgt250			: in  std_logic; --! тактовая частота 250 MHz или 100 МГц от PCI_Express
		
		perst			: in  std_logic;	--! 0 - сброс						   
		
		px				: out std_logic_vector( 7 downto 0 );	--! контрольные точки 
		
		pcie_lstatus	: out std_logic_vector( 15 downto 0 ); -- регистр LSTATUS
		pcie_link_up	: out std_logic;	-- 0 - завершена инициализация PCI-Express
		
		
		---- Локальная шина ----			  
		clk_out			: out std_logic;	--! тактовая частота 250 MHz		  
		reset_out		: out std_logic;	--! 0 - сброс
		dcm_rstp		: out std_logic;	--! 1 - сброс DCM 266 МГц

		---- BAR0 - блоки управления ----
		bp_host_data	: out std_logic_vector( 31 downto 0 );	--! шина данных - выход 
		bp_data			: in  std_logic_vector( 31 downto 0 );  --! шина данных - вход
		bp_adr			: out std_logic_vector( 19 downto 0 );	--! адрес регистра 
		bp_we			: out std_logic_vector( 3 downto 0 ); 	--! 1 - запись в регистры 
		bp_rd			: out std_logic_vector( 3 downto 0 );   --! 1 - чтение из регистров блока 
		bp_sel			: out std_logic_vector( 1 downto 0 );	--! номер блока для чтения 
		bp_reg_we		: out std_logic;			--! 1 - запись в регистр по адресам   0x100000 - 0x1FFFFF 
		bp_reg_rd		: out std_logic; 			--! 1 - чтение из регистра по адресам 0x100000 - 0x1FFFFF 
		bp_irq			: in  std_logic;			--! 1 - запрос прерывания 

		---- BAR1 ----	
		aclk			: in std_logic;				--! тактовая частота локальной шины - 266 МГц
		aclk_lock		: in std_logic;				--! 1 - захват частоты
		pb_master		: out type_pb_master;		--! запрос 
		pb_slave		: in  type_pb_slave			--! ответ  
		
				
		
	);
end component;

---- BAR0 - блоки управления ----
signal	bp_host_data	: std_logic_vector( 31 downto 0 );	--! шина данных - выход 
signal	bp_data			: std_logic_vector( 31 downto 0 );  --! шина данных - вход
signal	bp_adr			: std_logic_vector( 19 downto 0 );	--! адрес регистра внутри блока 
signal	bp_we			: std_logic_vector( 3 downto 0 ); 	--! 1 - запись в регистры 
signal	bp_rd			: std_logic_vector( 3 downto 0 );   --! 1 - чтение из регистров блока 
signal	bp_sel			: std_logic_vector( 1 downto 0 );	--! номер блока для чтения 
signal	bp_reg_we		: std_logic;			--! 1 - запись в регистр по адресам   0x100000 - 0x1FFFFF 
signal	bp_reg_rd		: std_logic; 			--! 1 - чтение из регистра по адресам 0x100000 - 0x1FFFFF 
signal	bp_irq			: std_logic;						--! 1 - запрос прерывания 

signal	clk250			: std_logic;
signal	reset			: std_logic;

signal	pb_master		: type_pb_master;		--! запрос 
signal	pb_slave		: type_pb_slave;		--! ответ  

signal	pb_reset		: std_logic;
signal	brd_mode		: std_logic_vector( 15 downto 0 );

signal	bp0_data		: std_logic_vector( 31 downto 0 );

begin
	
gen_m4: if( CORE_NAME="pcie_core64_m4" ) generate
	
core: pcie_core64_m4 
	generic map(
		refclk			=> refclk,				--! Значение опорной тактовой частоты [МГц]
		is_simulation	=> is_simulation		--! 0 - синтез, 1 - моделирование 
	)		  
	port map(
	
		---- PCI-Express ----
		txp				  => txp,				
		txn				  => txn,				
						                  
		rxp				  => rxp,				
		rxn				  => rxn,				
						                  
		mgt250			  => mgt250,			
						                  
		perst			  => perst,			
						                  
		px				  => px,				
						                  
		pcie_lstatus	  => pcie_lstatus,	
		pcie_link_up	  => pcie_link_up,	
		
		
		---- Локальная шина ----			  
		clk_out			 => clk250,
		reset_out		 => reset,
		dcm_rstp		 => dcm_rstp, 

		---- BAR1 ----
		aclk			=> clk,
		aclk_lock		=> clk_lock,
		pb_master		=> pb_master,		
		pb_slave		=> pb_slave,		

						                 
		---- BAR0 - блоки управления ----
		bp_host_data	=> bp_host_data,	
		bp_data			=> bp_data,			
		bp_adr			=> bp_adr,			
		bp_we			=> bp_we,			
		bp_rd			=> bp_rd,
		bp_sel			=> bp_sel,			
		bp_reg_we		=> bp_reg_we,		
		bp_reg_rd		=> bp_reg_rd,		
		bp_irq			=> bp_irq
						                
		
	);		 
	
end generate;	

	
gen_m10: if( CORE_NAME="pcie_core64_m10" ) generate
	
core: pcie_core64_m10 
	generic map(
		DEVICE_ID			=> Device_ID,	   		--! значение регистра DeviceID 
		refclk				=> refclk,				--! Значение опорной тактовой частоты [МГц]
		is_simulation		=> is_simulation		--! 0 - синтез, 1 - моделирование 
	)		  
	port map(
	
		---- PCI-Express ----
		txp				  => txp,				
		txn				  => txn,				
						                  
		rxp				  => rxp,				
		rxn				  => rxn,				
						                  
		mgt250			  => mgt250,			
						                  
		perst			  => perst,			
						                  
		px				  => px,				
						                  
		pcie_lstatus	  => pcie_lstatus,	
		pcie_link_up	  => pcie_link_up,	
		
		
		---- Локальная шина ----			  
		clk_out			 => clk250,
		reset_out		 => reset,
		dcm_rstp		 => dcm_rstp, 

		---- BAR1 ----
		aclk			=> clk,
		aclk_lock		=> clk_lock,
		pb_master		=> pb_master,		
		pb_slave		=> pb_slave,		

						                 
		---- BAR0 - блоки управления ----
		bp_host_data	=> bp_host_data,	
		bp_data			=> bp_data,			
		bp_adr			=> bp_adr,			
		bp_we			=> bp_we,			
		bp_rd			=> bp_rd,
		bp_sel			=> bp_sel,			
		bp_reg_we		=> bp_reg_we,		
		bp_reg_rd		=> bp_reg_rd,		
		bp_irq			=> bp_irq
						                
		
	);		 
	
end generate;

reset_out <= reset;
clk250_out   <= clk250;

bp_data <= bp0_data when bp_sel="00" else (others=>'0');

tz: core64_pb_transaction 
	port map(
		reset				=> reset,		--! 0 - сброс
		clk					=> clk,			--! тактовая частота локальной шины - 266 МГц 
		
		---- BAR1 ----	
		pb_master			=> pb_master,			--! запрос 
		pb_slave			=> pb_slave,			--! ответ  
		
		---- локальная шина -----		
		lc_adr				=> lc_adr,				
		lc_host_data		=> lc_host_data,	
		lc_data				=> lc_data,			
		lc_wr				=> lc_wr,			
		lc_rd				=> lc_rd,			
		lc_dma_req			=> lc_dma_req,		
		lc_irq				=> lc_irq,		
		lc_rd_cfg			=> lc_rd_cfg	
	);
				
	
main: block_pe_main 
	generic map(
		Device_ID		=> Device_ID,	 		-- идентификатор модуля
		Revision		=> Revision,		 	-- версия модуля
		PLD_VER			=> PLD_VER,				-- версия ПЛИС
		BLOCK_CNT		=> x"0008"  			-- число блоков управления 
		
	)	
	port map(
	
		---- Global ----
		reset_hr1		=> reset,		-- 0 - сброс
		clk				=> clk250,		-- Тактовая частота DSP
		pb_reset		=> pb_reset,	-- 0 - сброс ведомой ПЛИС
		
		---- HOST ----
		bl_adr			=> bp_adr( 4 downto 0 ),		-- адрес
		bl_data_in		=> bp_host_data,				-- данные
		bl_data_out		=> bp0_data,					-- данные
		bl_data_we		=> bp_we(0),					-- 1 - запись данных   
		
		---- Управление ----
		brd_mode		=> brd_mode						-- регистр BRD_MODE

	);		
		
end pcie_core64_m5;
