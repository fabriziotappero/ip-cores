-------------------------------------------------------------------------------
--
-- Title       : ctrl_dma_ext_cmd
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description : Узел формирования команды для контроллера DMA PLDA
--				  
--		Узел формирует повторное обращение при ошибочном завершении обмена
--										   
--		Поле регистра состояния:
--			0: 1 - завершение обмена
--			1: 1 - ошибка при обмене 
--			2: 1 - размер равен 0
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library	work;
use work.core64_type_pkg.all;

package ctrl_dma_ext_cmd_pkg is
	
component ctrl_dma_ext_cmd is	   	  
	generic(
		is_dsp48		: in integer:=1		-- 1 - использовать DSP48, 0 - не использовать DSP48
	);
	port(						  
		---- Global ----
		rstp				: in std_logic;		--! 1 - сброс
		clk					: in std_logic;		--! тактовая частота 250 МГц
		
		---- CTRL_MAIN ----
		dma_reg0			: in std_logic_vector( 2 downto 0 );	--! регистр упрравления
																	--! 0:  1 - запуск обмена
																	--! 1:  1 - блок 4 kB, 0 - 512 байт
																	--! 2:  1 - увеличение адреса, 0 - запись адреса из дескриптора
		
		dma_change_adr		: in std_logic	;	--! 1 - изменение адреса и размера
		dma_cmd_status		: out std_logic_vector( 2 downto 0 );	--! состояние DMA
																--! 0: 1 - завершение обмена
																--! 1: 1 - ошибка при обмене
																--! 2: 1 - размер блока равен 0
		dma_chn				: in std_logic;							--! номер канала DMA
		
		---- CTRL_EXT_DESCRIPTOR ----			 
		dsc_adr_h			: in std_logic_vector( 7 downto 0 );    --! адрес, байт 4
		dsc_adr				: in std_logic_vector( 23 downto 0 );	--! адрес, байты 3..1
		dsc_size			: in std_logic_vector( 23 downto 0 );	--! размер, байты 3..1
		

		---- TX_ENGINE ----
		tx_ext_fifo			: in type_tx_ext_fifo;			--! обмен TX->EXT_FIFO 
		tx_req_wr			: out std_logic;				--! 1 - требование записи блока 4 кБ
		tx_req_rd			: out std_logic;				--! 1 - требование чтения
		tx_rd_size			: out std_logic;				--! 0 - 512 байт, 1 - 4 кБ
		tx_pci_adr			: out std_logic_vector( 39 downto 8 );	--! адрес на шине PCI 
		
		---- RX_ENGINE ----
		rx_ext_fifo			: in type_rx_ext_fifo;			--! обмен RX->EXT_FIFO 
		
		---- Контрольные точки ----
		test				: out std_logic_vector( 3 downto 0 )
	);
		
	
end component;

end package;



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;		

library	work;
use work.core64_type_pkg.all;
use work.ctrl_dma_adr_pkg.all;


entity ctrl_dma_ext_cmd is	   
	generic(
		is_dsp48		: in integer:=1		-- 1 - использовать DSP48, 0 - не использовать DSP48
	);
	port(
		---- Global ----
		rstp				: in std_logic;		--! 1 - сброс
		clk					: in std_logic;		--! тактовая частота 250 МГц
		
		---- CTRL_MAIN ----
		dma_reg0			: in std_logic_vector( 2 downto 0 );	--! регистр упрравления
																	--! 0:  1 - запуск обмена
																	--! 1:  1 - блок 4 kB, 0 - 512 байт
																	--! 2:  1 - увеличение адреса, 0 - запись адреса из дескриптора
		dma_change_adr		: in std_logic	;	--! 1 - изменение адреса и размера
		dma_cmd_status		: out std_logic_vector( 2 downto 0 );	--! состояние DMA
																--! 0: 1 - завершение обмена
																--! 1: 1 - ошибка при обмене
																--! 2: 1 - размер блока равен 0
		dma_chn				: in std_logic;							--! номер канала DMA
		
		---- CTRL_EXT_DESCRIPTOR ----			 
		dsc_adr_h			: in std_logic_vector( 7 downto 0 );    --! адрес, байт 4
		dsc_adr				: in std_logic_vector( 23 downto 0 );	--! адрес, байты 3..1
		dsc_size			: in std_logic_vector( 23 downto 0 );	--! размер, байты 3..1
		

		---- TX_ENGINE ----
		tx_ext_fifo			: in type_tx_ext_fifo;			--! обмен TX->EXT_FIFO 
		tx_req_wr			: out std_logic;				--! 1 - требование записи блока 4 кБ
		tx_req_rd			: out std_logic;				--! 1 - требование чтения
		tx_rd_size			: out std_logic;				--! 0 - 512 байт, 1 - 4 кБ
		tx_pci_adr			: out std_logic_vector( 39 downto 8 );	--! адрес на шине PCI 
		
		---- RX_ENGINE ----
		rx_ext_fifo			: in type_rx_ext_fifo;			--! обмен RX->EXT_FIFO 
		
		---- Контрольные точки ----
		test				: out std_logic_vector( 3 downto 0 )
	);
		
	
end ctrl_dma_ext_cmd;


architecture ctrl_dma_ext_cmd of ctrl_dma_ext_cmd is	

type stp_type is ( s0, s1, s2, s3 );

signal	stp		: stp_type;


signal	status	: std_logic_vector( 3 downto 0 );	  

signal	dma_rw	: std_logic;	  

signal	cnt_pause	: std_logic_vector( 5 downto 0 );

signal	dma_cmd_rdy		: std_logic;
signal	dma_cmd_error	: std_logic;
signal	dma_cmd_start	: std_logic;		 

signal	pci_adr			: std_logic_vector( 39 downto 0 );
signal	pci_size_z		: std_logic;

signal	size4k			: std_logic;


begin					
	
	
dma_cmd_start <= dma_reg0(0);

dma_adr: ctrl_dma_adr 
	generic map(
		is_dsp48		=> is_dsp48
	)
	port map(
		---- Global ----
		clk				=> clk,			-- тактовая частота
		
		---- Доступ к PICOBLAZE ----
		dma_chn			=> dma_chn,				-- номер канала DMA	  
		reg0			=> dma_reg0,			-- регистр DMA_CTRL
		reg41_wr		=> dma_change_adr,	 	-- 1 - запись в регистр 41
		
		---- CTRL_EXT_DESCRIPTOR ----
		dsc_adr			=> dsc_adr,				-- адрес, байты 3..1
		dsc_adr_h		=> dsc_adr_h,		    -- адрес, байт 4
		dsc_size		=> dsc_size,			-- размер, байты 3..1

		---- Адрес ----
		pci_adr			=> pci_adr,				-- текущий адрес 
		pci_size_z		=> pci_size_z,			-- 1 - размер равен 0
		pci_rw			=> dma_rw				-- 0 - чтение, 1 - запись	

	);


size4k <= dma_reg0(1);

tx_pci_adr <= pci_adr( 39 downto 8 );
tx_rd_size <= size4k;

dma_cmd_status(0) <= dma_cmd_rdy;
dma_cmd_status(1) <= dma_cmd_error;		 
dma_cmd_status(2) <= pci_size_z;

pr_state: process( clk ) begin
	if( rising_edge( clk ) ) then

		case( stp ) is
			when s0 =>
				if( dma_cmd_start='1' ) then
					stp <= s1 after 1 ns;
				end if;		
				
				tx_req_rd <= '0' after 1 ns;
				tx_req_wr <= '0' after 1 ns;
				dma_cmd_rdy <= '0' after 1 ns;
				dma_cmd_error <= '0' after 1 ns;
				
			when s1 =>
			
				tx_req_rd <= (not dma_rw) or (not size4k) after 1 ns;
				tx_req_wr <= dma_rw and size4k after 1 ns;
				
				if( tx_ext_fifo.complete_ok='1' ) then 
					stp <= s2 after 1 ns;			   
				elsif( tx_ext_fifo.complete_error='1' ) then
					stp <= s3 after 1 ns;			   
				end if;
				
				dma_cmd_error <= tx_ext_fifo.complete_error after 1 ns;
				
			when s2 =>
				
				tx_req_rd <= '0' after 1 ns;
				tx_req_wr <= '0' after 1 ns;
				
				dma_cmd_rdy <= '1' after 1 ns;
				if( dma_cmd_start='0' ) then
					stp <= s0 after 1 ns;
				end if;		 
				
			when s3 =>
				tx_req_rd <= '0' after 1 ns;
				tx_req_wr <= '0' after 1 ns;   
				if( tx_ext_fifo.complete_error='0' ) then
					stp <= s0 after 1 ns;
				end if;
				
			
		end case;
									
		
		if( rstp='1' ) then
			stp <= s0 after 1 ns;
		end if;
				
	end if;
end process;





end ctrl_dma_ext_cmd;
