-------------------------------------------------------------------------------
--
-- Title       : ctrl_main
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.3
--
-------------------------------------------------------------------------------
--
-- Description : Узел формирования команд для управления работой контроллера DMA
--
-------------------------------------------------------------------------------
--
--  Version 1.3   14.12.2011
--				 Добавлены сигналы dsc_check_start, dsc_check_ready -
--				 для управления подсчётом контрольной суммы после 
--				 чтения дескриптора 
--
-------------------------------------------------------------------------------
--
--  Version 1.2   26.01.2011
--				 Добавлена запись 40-битного начального адреса дескриптора
--
-------------------------------------------------------------------------------
--
--  Version 1.1   02.06.2009
--				  Добавлено чередование приоритетов запуска каналов DMA
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;			  

package ctrl_main_pkg is

component ctrl_main is
	port(
		---- Global ----
		reset			: in std_logic;	-- 0 - сброс
		clk				: in std_logic;	-- тактовая частота

		---- Регистры управления ----
		dma0_ctrl		: in std_logic_vector( 7 downto 0 );	-- Регистр DMA_CTRL, канал 0
		dma1_ctrl		: in std_logic_vector( 7 downto 0 );	-- Регистр DMA_CTRL, канал 0
		
		---- ctrl_ext_ram ----
		dma0_transfer_rdy	: in std_logic;	-- 1 - канал 0 готов к обмену
		dma1_transfer_rdy	: in std_logic;	-- 1 - канал 1 готов к обмену
		
		---- Управление DMA ----
		dma_chn				: out std_logic;	-- номер канала DMA для текущего обмена
		ram_do				: out std_logic_vector( 7 downto 0 );	-- данные для записи в регистр STATUS
		ram_adr				: out std_logic_vector( 8 downto 0 );	-- адрес для записи в регистр STATUS
		ram_we				: out std_logic;	-- 1 - запись в память
		dma0_eot_clr		: in  std_logic;	-- 1 - сброс флага DMA0_EOT
		dma1_eot_clr		: in  std_logic;	-- 1 - сброс флага DMA1_EOT
		
		reg_dma0_status		: out std_logic_vector( 15 downto 0 );	-- регистр STATUS канала 0
		reg_dma1_status		: out std_logic_vector( 15 downto 0 );	-- регистр STATUS канала 1
		
		---- ctrl_ext_ram	----
		ram_change			: out std_logic;	-- 1 - изменение блока памяти
		loc_adr_we			: out std_logic;	-- 1 - запись локального адреса
		
		---- ctrl_ext_descriptor ----
		pci_adr_we			: out std_logic;	-- 1 - запись адреса
		pci_adr_h_we		: out std_logic;	-- 1 - запись старших разрядов адреса
		dsc_correct			: in  std_logic;	-- 1 - загружен правильный дескриптор
		dsc_cmd				: in  std_logic_vector( 7 downto 0 );	-- командное слово дескриптора
		dsc_change_adr		: out std_logic;	-- 1 - смена адреса дескриптора
		dsc_change_mode		: out std_logic;	-- Режим изменения адреса:
												-- 0: - увеличение
		                                      	-- 1: - переход к нулевомй дескриптору
		dsc_load_en			: out std_logic;	-- 1 - разрешение записи дескриптора
		dsc_check_start		: out std_logic;	-- 1 - проверка дескриптора
		dsc_check_ready		: in  std_logic;	-- 1 - проверка завершена
		
		---- ctrl_dma_ext_cmd ----						 
		dma_reg0			: out std_logic_vector( 2 downto 0 );	-- регистр упрравления
		dma_change_adr		: out std_logic	;	-- 1 - изменение адреса и размера
		dma_status			: in  std_logic_vector( 2 downto 0 )	-- состояние DMA
																	-- 0: 1 - завершение обмена
																	-- 1: 1 - ошибка при обмене
																	-- 2: 1 - размер блока равен 0
	);		
	
end component;

end package;



library ieee;
use ieee.std_logic_1164.all;			  
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;		

library unisim;														 
use unisim.vcomponents.all;


entity ctrl_main is
	port(
		---- Global ----
		reset			: in std_logic;	-- 0 - сброс
		clk				: in std_logic;	-- тактовая частота

		---- Регистры управления ----
		dma0_ctrl		: in std_logic_vector( 7 downto 0 );	-- Регистр DMA_CTRL, канал 0
		dma1_ctrl		: in std_logic_vector( 7 downto 0 );	-- Регистр DMA_CTRL, канал 0
		
		---- ctrl_ext_ram ----
		dma0_transfer_rdy	: in std_logic;	-- 1 - канал 0 готов к обмену
		dma1_transfer_rdy	: in std_logic;	-- 1 - канал 1 готов к обмену
		
		---- Управление DMA ----
		dma_chn				: out std_logic;	-- номер канала DMA для текущего обмена
		ram_do				: out std_logic_vector( 7 downto 0 );	-- данные для записи в регистр STATUS
		ram_adr				: out std_logic_vector( 8 downto 0 );	-- адрес для записи в регистр STATUS
		ram_we				: out std_logic;	-- 1 - запись в память
		dma0_eot_clr		: in  std_logic;	-- 1 - сброс флага DMA0_EOT
		dma1_eot_clr		: in  std_logic;	-- 1 - сброс флага DMA1_EOT
		
		reg_dma0_status		: out std_logic_vector( 15 downto 0 );	-- регистр STATUS канала 0
		reg_dma1_status		: out std_logic_vector( 15 downto 0 );	-- регистр STATUS канала 1
		
		---- ctrl_ext_ram	----
		ram_change			: out std_logic;	-- 1 - изменение блока памяти
		loc_adr_we			: out std_logic;	-- 1 - запись локального адреса
		
		---- ctrl_ext_descriptor ----
		pci_adr_we			: out std_logic;	-- 1 - запись адреса
		pci_adr_h_we		: out std_logic;	-- 1 - запись старших разрядов адреса
		dsc_correct			: in  std_logic;	-- 1 - загружен правильный дескриптор
		dsc_cmd				: in  std_logic_vector( 7 downto 0 );	-- командное слово дескриптора
		dsc_change_adr		: out std_logic;	-- 1 - смена адреса дескриптора
		dsc_change_mode		: out std_logic;	-- Режим изменения адреса:
												-- 0: - увеличение
		                                      	-- 1: - переход к нулевомй дескриптору
		dsc_load_en			: out std_logic;	-- 1 - разрешение записи дескриптора
		dsc_check_start		: out std_logic;	-- 1 - проверка дескриптора
		dsc_check_ready		: in  std_logic;	-- 1 - проверка завершена
		
		---- ctrl_dma_ext_cmd ----						 
		dma_reg0			: out std_logic_vector( 2 downto 0 );	-- регистр упрравления
		dma_change_adr		: out std_logic	;	-- 1 - изменение адреса и размера
		dma_status			: in  std_logic_vector( 2 downto 0 )	-- состояние DMA
																	-- 0: 1 - завершение обмена
																	-- 1: 1 - ошибка при обмене
																	-- 2: 1 - размер блока равен 0
	);
end ctrl_main;


architecture ctrl_main of ctrl_main is

signal		dma0_eot	: std_logic;	-- 1 - завершение передачи блока канала 0
signal		dma1_eot	: std_logic;	-- 1 - завершение передачи блока канала 1
signal		dma0_sg_eot	: std_logic;	-- 1 - завершение работы канала 0
signal		dma1_sg_eot	: std_logic;	-- 1 - завершение работы канала 1

signal	dma_eot_set		: std_logic;
signal	dma_sg_eot_set	: std_logic;

signal	ra				: std_logic_vector( 7 downto 0 );	-- адрес памяти автомата
signal	dma_chni		: std_logic:='0';	-- номер выбранного канала DMA

signal	ram_a_adr		: std_logic_vector( 8 downto 0 );
signal	ram_a_out		: std_logic_vector( 31 downto 0 );

signal	rstp			: std_logic;	   
signal	dma_chn_change_en	: std_logic;	 	

signal	dma0_ctrl_z			: std_logic;
signal	dma1_ctrl_z			: std_logic;

signal	dma0_flag_start		: std_logic;
signal	dma1_flag_start		: std_logic;
signal	dma_flag_start		: std_logic;
signal	dma_flag_start_clr	: std_logic;			
signal	dma_transfer_start	: std_logic;   
signal	dma_chn_change		: std_logic;		

signal	dma0_start			: std_logic;
signal	dma1_start			: std_logic;	   	  
signal	ram_adr_l			: std_logic_vector( 2 downto 0 );
signal	dma_start			: std_logic;

signal	dma0_wait_eot		: std_logic;
signal	dma1_wait_eot		: std_logic;

signal	dma0_wait_eot2		: std_logic;
signal	dma1_wait_eot2		: std_logic;

type st_type is ( s0, s01, s1, s2, s3, s3_01, s4, s4_01, st0, st1, st20, st2, sc0, sc1, sc2, sc3, sc4, sr0, sr1, sr2, sr3, sr4, sr5, sr5_01, sr6 );
signal	stp		: st_type;	 

---- Доступ к регистрам ----
---- 00 - STATUS
---- 10 - PCI_ADR_L
---- 11 - LOC_ADR
signal	ram_sel				: std_logic_vector( 2 downto 0 );


type stw_type is ( s0, s01, s02, s03, s1, s2, s3, s4, s5, s6, s7 );
signal	stw		: stw_type;


signal	init_compelte	: std_logic;  

signal	dma_rotate		: std_logic;  

signal	dma0_block		: std_logic;
signal	dma1_block		: std_logic;
signal	dma0_block_in	: std_logic;
signal	dma1_block_in	: std_logic;
signal	dma0_block_z	: std_logic;
signal	dma1_block_z	: std_logic;

begin					 
	
	
	
rstp <= not reset after 1 ns when rising_edge( clk );	

dma0_ctrl_z	<= dma0_ctrl(0) after 1 ns when rising_edge( clk );
dma1_ctrl_z	<= dma1_ctrl(0) after 1 ns when rising_edge( clk );

pr_dma_flag_start: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( dma0_ctrl(0)='0' or (dma_flag_start_clr='1' and dma_chni='0' ) ) then
			dma0_flag_start <= '0' after 1 ns;
		elsif( dma0_ctrl_z='0' ) then
			dma0_flag_start <= '1' after 1 ns;
		end if;

		if( dma1_ctrl(0)='0' or (dma_flag_start_clr='1' and dma_chni='1' ) ) then
			dma1_flag_start <= '0' after 1 ns;
		elsif( dma1_ctrl_z='0' ) then
			dma1_flag_start <= '1' after 1 ns;
		end if;
	end if;
end process;


---- Выбор канала для обмена ----
pr_chn: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( rstp='1' ) then
			dma_chni <= not dma_chni after 1 ns;
			dma_flag_start <= '0' after 1 ns;
			dma_transfer_start <= '0' after 1 ns;  
			dma_rotate <= '0' after  1 ns;
		else
			if( dma_chn_change='1' ) then
				
				if( dma_transfer_start='0' and dma_flag_start='0' ) then 
					if( dma0_flag_start='1' ) then
						dma_chni <= '0' after 1 ns;
						dma_flag_start <= '1' after 1 ns;
						dma_rotate <= '0' after 1 ns;
					elsif( dma1_flag_start='1' ) then
						dma_chni <= '1' after 1 ns;
						dma_flag_start <= '1' after 1 ns;
						dma_rotate <= '1' after 1 ns;
					elsif( dma0_transfer_rdy='1' and dma0_sg_eot='0' and dma0_wait_eot='0' and dma0_block_z='0' and dma_rotate='0' ) then
						dma_chni <= '0' after  1 ns;
						dma_transfer_start <= '1' after 1 ns;
						dma_rotate <= '1' after 1 ns;
					elsif( dma1_transfer_rdy='1' and dma1_sg_eot='0' and dma1_wait_eot='0' and dma1_block_z='0' and dma_rotate='1' ) then
						dma_chni <= '1' after  1 ns;
						dma_transfer_start <= '1' after 1 ns;
						dma_rotate <= '0' after 1 ns;
					else
						dma_rotate <= not dma_rotate after 1 ns;
					end if;
				end if;
			else
				dma_flag_start <= '0' after 1 ns;
				dma_transfer_start <= '0' after 1 ns;
			end if;
			
					

		end if;
	end if;
end process;

dma_chn <= dma_chni;

---- Инициализация ----
pr_init: process( clk ) begin
	if( rising_edge( clk ) ) then
		case( stw ) is
			when s0 =>		
				ram_sel <= "000" after 1 ns;	 
				pci_adr_we <= '0' after 1 ns;
				pci_adr_h_we <= '0' after 1 ns;
				loc_adr_we <= '0' after 1 ns;		 
				init_compelte <= '0' after 1 ns;
				if( stp=s1 ) then
					stw <= s01 after 1 ns;
				end if;		 

			when s01 =>
				ram_sel <= "101" after 1 ns;
				stw <= s02 after 1 ns;
			
			when s02 =>	  
				pci_adr_h_we <= '1' after 1 ns;
				stw <= s03 after 1 ns;
				
			when s03 =>
				pci_adr_h_we <= '0' after 1 ns;
				stw <= s1 after 1 ns;
				
				
			when s1 =>
				ram_sel <= "100" after 1 ns;
				stw <= s2 after 1 ns;
			
			when s2 =>	  
				pci_adr_we <= '1' after 1 ns;
				stw <= s3 after 1 ns;
				
			when s3 =>
				pci_adr_we <= '0' after 1 ns;
				stw <= s4 after 1 ns;
				
			when s4 =>
				ram_sel <= "111" after 1 ns;
				stw <= s5 after 1 ns;
				
			when s5 =>
				loc_adr_we <= '1' after 1 ns;
				stw <= s6 after 1 ns;
				
			when s6 =>
				loc_adr_we <= '0' after 1 ns;				
				stw <= s7 after 1 ns;
				
			when s7 =>
				ram_sel <= "000" after 1 ns;
				init_compelte <= '1' after 1 ns;
			
		end case;
		
		if( stp=s0 or stp=s01 ) then
			stw <= s0 after 1 ns;
		end if;
	end if;
end process;

---- Управление переходами ----			
pr_state: process( clk ) begin
	if( rising_edge( clk ) ) then
		
		case( stp ) is
			when s0 => 
				dma_chn_change <= '1' after 1 ns;
				if( dma_flag_start='1' ) then
					stp <= s01 after 1 ns;
				elsif( dma_transfer_start='1' ) then
					stp <= st0 after 1 ns;
				end if;
				dsc_load_en <= '0' after 1 ns;
				dma_reg0 <= "110" after 1 ns;		 
				dma_flag_start_clr <= '0' after 1 ns;	  
				dma_change_adr <= '0' after  1 ns;			 
				dsc_change_adr <= '0' after  1 ns;		
				dsc_change_mode <= '0' after 1 ns;
				ram_change <= '0' after 1 ns;
				dma_sg_eot_set <= '0' after  1 ns;
				dma_eot_set <= '0' after  1 ns;	  
				dsc_check_start <= '0' after 1 ns;
				
			when s01 => -- Повтор загрузки первого дескриптора --

				dsc_load_en <= '0' after 1 ns;
				dma_reg0 <= "110" after 1 ns;		 
				dma_flag_start_clr <= '0' after 1 ns;	  
				dma_change_adr <= '0' after  1 ns;			 
				dsc_change_adr <= '0' after  1 ns;		
				dsc_change_mode <= '0' after 1 ns;
				ram_change <= '0' after 1 ns;
				dma_sg_eot_set <= '0' after  1 ns;
				dma_eot_set <= '0' after  1 ns;	  
			
				if( init_compelte='0' ) then
					stp <= s1 after 1 ns;	
				end if;
			
			when s1 => -- Загрузка первого дескриптора --
				dma_chn_change <= '0' after 1 ns;
				dsc_load_en <= '1' after 1 ns;		 
				dma_reg0 <= "000" after 1 ns;		
				
				dsc_change_mode <= '1' after  1 ns;
				dsc_change_adr <= '1' after 1 ns;
				
				if( init_compelte='1' ) then
					stp <= s2 after 1 ns;	
				end if;
				
				
			when s2 =>
				dma_change_adr <= '1' after ns;
				dsc_change_adr <= '0' after 1 ns;
				stp <= s3 after 1 ns;
				
			when s3 =>
				dma_change_adr <= '0' after ns;
				dma_reg0 <= "001" after 1 ns;	
				dsc_load_en <= not dma_status(1) after 1 ns;		 
				if( dma_status(0)='1' ) then
					if( dma_start='0' ) then
						stp <= s0 after 1 ns;
					else
						stp <= s3_01 after 1 ns;
						
					end if;
				end if;	  
				
			when s3_01 => -- проверка дескриптора	
				dsc_change_mode <='0' after 1 ns;
				dsc_check_start <= '1' after 1 ns;
				if( dsc_check_ready='1' ) then
					stp <= s4 after 1 ns;
				end if;
				
			when s4 => 							  
				dsc_check_start <= '0' after 1 ns;
				dma_sg_eot_set <= not dsc_correct after 1 ns;
				dma_flag_start_clr <= '1' after 1 ns;
				dsc_change_mode <= '1' after 1 ns;	  
				dsc_change_adr <= '1' after 1 ns;
				stp <= s4_01 after 1 ns;	  
				
			when s4_01 =>
				dsc_change_mode <= '0' after 1 ns;	  
				stp <= sc0 after 1 ns;	  
			
				
			when st0 =>
				stp <= st1 after 1 ns;
				dma_chn_change <= '0' after 1 ns;
				dsc_change_mode <= dsc_cmd(2) after 1 ns;
				
			when st1 => -- Обмен --
				dma_reg0 <= "111" after 1 ns;
				if( dma_status(0)='1' ) then
					if( dma_start='0' ) then
						stp <= s0 after 1 ns;
					else		   
						if( dma_status(2)='0' ) then
							stp <= sc4 after 1 ns;
						else
							stp <= st20 after 1 ns;		 
						end if;
						dma_change_adr <= '1' after  1 ns;	
						ram_change <= '1' after 1 ns;
					end if;
				end if;			 
				
			when st20 =>
				dma_reg0 <= "010" after 1 ns;		 
				ram_change <= '0' after 1 ns;
				if( dma_status(0)='0' ) then
					stp <= st2 after 1 ns;
				end if;
				
			when st2 => -- Обработка дескриптора --
			    dma_change_adr <= '0' after  1 ns; 		 
				ram_change <= '0' after 1 ns;
				dsc_change_adr <= '1' after  1 ns;
				if( dsc_cmd(0)='1' or dsc_cmd(2)='1' ) then 	-- переход к следующему дескриптору --
					stp <= sc0 after  1 ns;  -- запись адреса в ctrl_ext_cmd
				elsif( dsc_cmd(1)='1' ) then
					stp <= sr0 after 1 ns;
				else
					-- завершение работы DMA канала --	   
					dma_sg_eot_set <= '1' after 1 ns;
					stp <= sc0 after 1 ns;
				end if;								 
				
				dma_eot_set <= dsc_cmd(4) after  1 ns;
				
				
			when sc0 => -- запись адреса в ctrl_ext_cmd --
				dsc_change_mode <= '0' after 1 ns;
				dsc_change_adr <= '0' after  1 ns;		
				dma_eot_set <= '0' after  1 ns;
				stp <= sc1 after 1 ns;
				
			when sc1 => 
				stp <= sc2 after 1 ns;
				
			when sc2 => 
				stp <= sc3 after 1 ns;

			when sc3 => 
				dma_change_adr <= '1' after 1 ns;
				stp <= sc4 after 1 ns;
			when sc4 => 
				dma_change_adr <= '0' after 1 ns;
				dma_reg0 <= "110" after 1 ns;		 
				ram_change <= '0' after 1 ns;
				if( dma_status(0)='0' ) then
					stp <= s0 after 1 ns;
				end if;
				

			when sr0 => -- запись адреса в ctrl_ext_cmd --
				dsc_change_adr <= '0' after  1 ns;		
				dma_eot_set <= '0' after  1 ns;
				stp <= sr1 after 1 ns;
				
			when sr1 => 
				stp <= sr2 after 1 ns;
				
			when sr2 => 
				stp <= sr3 after 1 ns;				
				dsc_change_mode <= '1' after  1 ns;
				dsc_change_adr <= '1' after 1 ns;
			

			when sr3 => 
				dma_change_adr <= '1' after 1 ns;
				stp <= sr4 after 1 ns;
			when sr4 => 						 
				dsc_load_en <= '0' after 1 ns;		 				
				dma_change_adr <= '0' after 1 ns;
				dma_reg0 <= "000" after 1 ns;		 
				ram_change <= '0' after 1 ns;
				if( dma_status(0)='0' ) then
					stp <= sr5 after 1 ns;
				end if;
				
			when sr5 =>
				dsc_load_en <= not dma_status(1) after 1 ns;		 				
				dma_reg0 <= "001" after 1 ns;
				if( dma_status(0)='1' ) then
						stp <= sr5_01 after 1 ns;
				end if;			  
				
			when sr5_01 => -- проверка дескриптора	
				dsc_change_mode <='0' after 1 ns;
				dsc_check_start <= '1' after 1 ns;
				if( dsc_check_ready='1' ) then
					stp <= s4 after 1 ns;
				end if;
				
				
			when sr6 =>		  
				--dsc_load_en <= '0' after 1 ns;		 				
				dma_sg_eot_set <= not dsc_correct after 1 ns;
				stp <= s4_01 after 1 ns;
				dsc_change_mode <= '1' after 1 ns;
				dsc_change_adr <= '1' after 1 ns;
				
		end case;		
					
		
		
		if( rstp='1' ) then
			stp <= s0 after 1 ns;
			dma_chn_change <= '0' after 1 ns;
		end if;
	end if;
end process;			 

dma0_block_in <= '1' when stp=st1 and dma_chni='0' else '0';
dma1_block_in <= '1' when stp=st1 and dma_chni='1' else '0';
	
xb0:	srl16 port map( clk=>clk, d=>dma0_block_in, q=> dma0_block, a0=>'1', a1=>'1', a2=>'0', a3=>'0' );	
xb1:	srl16 port map( clk=>clk, d=>dma1_block_in, q=> dma1_block, a0=>'1', a1=>'1', a2=>'0', a3=>'0' );	

dma0_block_z <= dma0_block after 1 ns when rising_edge( clk );
dma1_block_z <= dma1_block after 1 ns when rising_edge( clk );

--ram_adr_l(2) <= ram_sel(1);
--ram_adr_l(1 downto 0) <= (others=>ram_sel(0));
ram_adr_l( 2 downto 0 ) <= ram_sel;

ram_adr( 4 downto 0 ) <= "10" & ram_adr_l;
ram_adr(5) <= dma_chni;
ram_adr( 8 downto 6 ) <= "000";

--ram_do( 0 ) <= (dma0_start and not dma_chni) or (dma1_start and dma_chni);   -- 1 - канал DMA работает
--ram_do( 1 ) <= '0';
--ram_do( 2 ) <= '0';
--ram_do( 3 ) <= '0';
--
--ram_do( 4 ) <= ((dma0_eot or dma0_wait_eot2) and not dma_chni) or ((dma1_eot or dma1_wait_eot2)and dma_chni);		 -- 1 - завершение передачи блока данных
--ram_do( 5 ) <= (dma0_sg_eot and not dma_chni) or (dma1_sg_eot and dma_chni); -- 1 - завершение работы канала DMA
--ram_do( 6 ) <= (dma0_wait_eot and not dma_chni) or (dma1_wait_eot and dma_chni); -- 1 - ожидание сброса dma_eot
--ram_do( 7 ) <= dsc_correct;		

reg_dma0_status( 0 ) <= dma0_start after 1 ns when rising_edge( clk );  					-- 1 - канал DMA работает
reg_dma0_status( 1 ) <= '0';
reg_dma0_status( 2 ) <= '0';
reg_dma0_status( 3 ) <= '0';

reg_dma0_status( 4 ) <= dma0_eot or dma0_wait_eot2 after 1 ns when rising_edge( clk );		-- 1 - завершение передачи блока данных
reg_dma0_status( 5 ) <= dma0_sg_eot after 1 ns when rising_edge( clk );						-- 1 - завершение работы канала DMA
reg_dma0_status( 6 ) <= dma0_wait_eot after 1 ns when rising_edge( clk );					-- 1 - ожидание сброса dma_eot
reg_dma0_status( 7 ) <= (dma0_eot or dma0_wait_eot2) and dma0_ctrl(5) after 1 ns when rising_edge( clk ); -- 1 - запрос прерывания 
reg_dma0_status( 8 ) <= dsc_correct after 1 ns when rising_edge(clk) and dma_chni='0';		
reg_dma0_status( 15 downto 9 ) <= x"A" & "000";

reg_dma1_status( 0 ) <= dma1_start after 1 ns when rising_edge( clk );  					-- 1 - канал DMA работает
reg_dma1_status( 1 ) <= '0';
reg_dma1_status( 2 ) <= '0';
reg_dma1_status( 3 ) <= '0';

reg_dma1_status( 4 ) <= dma1_eot or dma1_wait_eot2 after 1 ns when rising_edge( clk );		-- 1 - завершение передачи блока данных
reg_dma1_status( 5 ) <= dma1_sg_eot after 1 ns when rising_edge( clk );						-- 1 - завершение работы канала DMA
reg_dma1_status( 6 ) <= dma1_wait_eot after 1 ns when rising_edge( clk );					-- 1 - ожидание сброса dma_eot
reg_dma1_status( 7 ) <= (dma1_eot or dma1_wait_eot2) and dma1_ctrl(5) after 1 ns when rising_edge( clk ); -- 1 - запрос прерывания 
reg_dma1_status( 8 ) <= dsc_correct after 1 ns when rising_edge(clk) and dma_chni='1';		
reg_dma1_status( 15 downto 9 ) <= x"A" & "000";


--ram_we <= not (ram_sel(1) or dma_chn_change);
ram_do <= (others=>'0');
ram_we <= '0';

pr_dma_eot: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( dma0_ctrl(0)='0' or  dma0_eot_clr='1' ) then
			dma0_eot <= '0' after 1 ns;
		elsif( dma_eot_set='1' and dma_chni='0' ) then
			dma0_eot <= '1' after 1 ns;
		end if;
		
		if( dma1_ctrl(0)='0' or  dma1_eot_clr='1' ) then
			dma1_eot <= '0' after 1 ns;
		elsif( dma_eot_set='1' and dma_chni='1' ) then
			dma1_eot <= '1' after 1 ns;
		end if;	  
		
		if( dma0_ctrl(0)='0' ) then
			dma0_sg_eot <= '0' after 1 ns;
		elsif( dma_sg_eot_set='1' and dma_chni='0' ) then
			dma0_sg_eot <= '1' after 1 ns;
		end if;

		if( dma1_ctrl(0)='0' ) then
			dma1_sg_eot <= '0' after 1 ns;
		elsif( dma_sg_eot_set='1' and dma_chni='1' ) then
			dma1_sg_eot <= '1' after 1 ns;
		end if;
		
	end if;
end process;	

pr_dma0_wait_eot: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( dma0_ctrl(0)='0' or (dma0_eot_clr='1' and  dma0_wait_eot2='1' ) ) then
			dma0_wait_eot <= '0' after 1 ns;
		elsif( dma_eot_set='1' and dma0_eot='1' and dma_chni='0' ) then
			dma0_wait_eot <= '1' after 1 ns;
		end if;

		if( dma1_ctrl(0)='0' or (dma1_eot_clr='1' and  dma1_wait_eot2='1' ) ) then
			dma1_wait_eot <= '0' after 1 ns;
		elsif( dma_eot_set='1' and dma1_eot='1' and dma_chni='1' ) then
			dma1_wait_eot <= '1' after 1 ns;
		end if;

		
		if( dma0_ctrl(0)='0' ) then
			dma0_wait_eot2 <= '0' after  1 ns;
		elsif( dma0_eot_clr='1' ) then
			dma0_wait_eot2 <= dma0_eot and dma0_wait_eot after 1 ns;
		end if;
		
		if( dma1_ctrl(0)='0' ) then
			dma1_wait_eot2 <= '0' after  1 ns;
		elsif( dma1_eot_clr='1' ) then
			dma1_wait_eot2 <= dma1_eot and dma1_wait_eot after 1 ns;
		end if;
			
			
			
	end if;
end process;

pr_dma_start: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( dma0_ctrl(0)='0' ) then
			dma0_start <= '0' after 1 ns;
		elsif( dma_flag_start_clr='1' and dma_chni='0' ) then
			dma0_start <= '1' after 1 ns;
		end if;
		if( dma1_ctrl(0)='0' ) then
			dma1_start <= '0' after 1 ns;
		elsif( dma_flag_start_clr='1' and dma_chni='1' ) then
			dma1_start <= '1' after 1 ns;
		end if;
	end if;
end process;

dma_start <= dma0_ctrl_z when dma_chni='0' else dma1_ctrl_z;

------ Сохранение текущего состояния канала DMA ----
--pr_ra:process( clk ) begin
--	if( rising_edge( clk ) ) then
--				
--		
--		if( rstp='1' ) then
--		  ra <= x"00" after  1 ns;
--		end if;
--		
--	end if;
--end process;
--
--
--
--gen_repack: for ii in 0 to 7 generate
--
--ram0:	ram16x1d 
--		port map(
--			we 	=> ra_we,
--			d 	=> ra(ii),
--			wclk => clk,
--			a0	=> dma_chni,
--			a1	=> '0',
--			a2	=> '0',
--			a3	=> '0',
--			spo => ram_a_adr(ii),
--			dpra0 => '0',
--			dpra1 => '0',
--			dpra2 => '0',
--			dpra3 => '0'
--		);
--
--end generate;
--
--
------ Обработка канала DMA ----
--
--ram1: RAMB16_S36_S36 
--  generic map(
--      SIM_COLLISION_CHECK => "NONE"
--    )
--
--  port map(
--    DOA  	=> ram_a_out( 31 downto 0 ),  --: out std_logic_vector(3 downto 0);
--    --DOB  	=> ram_b_out( 31 downto 0 ), --: out std_logic_vector(31 downto 0);
--    --DOPB 	: out std_logic_vector(3 downto 0);
--
--    ADDRA 	=> ram_a_adr( 8 downto 0 ), --: in std_logic_vector(11 downto 0);
--    ADDRB 	=> (others=>'0'),
--    CLKA  	=> clk,
--    CLKB  	=> '0',
--    DIA   	=> (others=>'0'), --: in std_logic_vector(3 downto 0);
--    DIB   	=> (others=>'0'),
--    DIPA  	=> (others=>'0'),
--    DIPB  	=> (others=>'0'),
--    ENA   	=> '1',
--    ENB   	=> '0',
--    SSRA  	=> '0',
--    SSRB  	=> '0',
--    WEA   	=> '1',
--    WEB   	=> '0'
--    );
--	
--	


end ctrl_main;
