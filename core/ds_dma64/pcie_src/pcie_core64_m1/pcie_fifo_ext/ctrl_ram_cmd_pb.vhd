-------------------------------------------------------------------------------
--
-- Title       : ctrl_ram_cmd_pb
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.3
--
-------------------------------------------------------------------------------
--
-- Description : ”зел управлени€ запросами к шине PLD_BUS
--
-------------------------------------------------------------------------------
--					 
--  Version 1.3   24.04.2012 Dmitry Smekhov
--
--  »справлено формирование block_rd_eot
--
-------------------------------------------------------------------------------
--					 
--  Version 1.3   09.04.2012 Dmitry Smekhov
--
--  »справлено формирование rdy во врем€ сброса
--
-------------------------------------------------------------------------------
--					 
--  Version 1.1   06.12.2011 Dmitry Smekhov
--
--  ƒобавлен local_adr_we - канал DMA должен начинать работу только после
--						    получени€ локального адреса
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;   

package ctrl_ram_cmd_pb_pkg is

component ctrl_ram_cmd_pb is
	port(
		---- Global ----
		reset				: in std_logic;		-- 0 - сброс
		clk					: in std_logic;		--! “актова€ частота €дра - 250 ћ√ц
		aclk				: in std_logic;		--! “актова€ частота локальной шины - 266 ћ√ц
		
		act					: in std_logic;		-- 1 - разрешение цикла обработки
		rdy					: out std_logic;	-- 1 - завершение цикла обработки
		
		loc_adr_we			: in std_logic;	-- 1 - запись локального адреса
		flag_data			: in  std_logic_vector( 1 downto 0 );	-- 1 - наличие данных в блоке
		
		flag_set			: out std_logic_vector( 1 downto 0 );	-- 1 - установка флага наличи€ данных
		flag_clr			: out std_logic_vector( 1 downto 0 );	-- 1 - сброс флага наличи€ данных
		next_block			: in  std_logic;	-- 1 - признак достижени€ блока 4 килобайта
		adr_hi_wr			: out std_logic;	-- 1 - увеличение старших разр€дов адреса дл€ блока
		
		reg_ctrl			: in std_logic_vector( 7 downto 0 ); -- регистр управлени€
		
		dmar				: in  std_logic;	-- 1 - запрос DMA					  
		
		pf_cb				: out std_logic;	-- номер текущего блока дл€ обмена с шиной
		pf_dma_wr_rdy		: out std_logic;	-- 1 - готовность передать 512 слов
		pf_dma_rd_rdy		: out std_logic;	-- 1 - готовность прин€ть 512 слов
		
		pf_ram_rd			: in  std_logic;	-- 1 - чтение данных из пам€ти
		pf_repack_we		: in  std_logic		-- 1 - запись в пам€ть
		
	
	);
end component;

end package;



library ieee;
use ieee.std_logic_1164.all;   
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ctrl_ram_cmd_pb is
	port(
		---- Global ----
		reset				: in std_logic;		-- 0 - сброс
		clk					: in std_logic;		--! “актова€ частота €дра - 250 ћ√ц
		aclk				: in std_logic;		--! “актова€ частота локальной шины - 266 ћ√ц
		
		act					: in std_logic;		-- 1 - разрешение цикла обработки
		rdy					: out std_logic;	-- 1 - завершение цикла обработки
		
		loc_adr_we			: in std_logic;	-- 1 - запись локального адреса
		flag_data			: in  std_logic_vector( 1 downto 0 );	-- 1 - наличие данных в блоке
		
		flag_set			: out std_logic_vector( 1 downto 0 );	-- 1 - установка флага наличи€ данных
		flag_clr			: out std_logic_vector( 1 downto 0 );	-- 1 - сброс флага наличи€ данных
		next_block			: in  std_logic;	-- 1 - признак достижени€ блока 4 килобайта
		adr_hi_wr			: out std_logic;	-- 1 - увеличение старших разр€дов адреса дл€ блока
		
		reg_ctrl			: in std_logic_vector( 7 downto 0 ); -- регистр управлени€
		
		dmar				: in  std_logic;	-- 1 - запрос DMA					  
		
		pf_cb				: out std_logic;	-- номер текущего блока дл€ обмена с шиной
		pf_dma_wr_rdy		: out std_logic;	-- 1 - готовность передать 128 слов
		pf_dma_rd_rdy		: out std_logic;	-- 1 - готовность прин€ть 128 слов
		
		pf_ram_rd			: in  std_logic;	-- 1 - чтение данных из пам€ти
		pf_repack_we		: in  std_logic		-- 1 - запись в пам€ть
		
	
	);
end ctrl_ram_cmd_pb;


architecture ctrl_ram_cmd_pb of ctrl_ram_cmd_pb is

type  stp_type is ( s0, s2,  sr2, sr5, sr6, sw2, sw3 ); -- s1, sr0, sr1,
signal	stp		: stp_type;

signal	rst_p	: std_logic;		 
signal	rst_p0	: std_logic;		 

signal	cb		: std_logic;

signal	block_rd_eot	: std_logic;
--signal	block_wr_eot	: std_logic;
signal	pf_repack_we_z	: std_logic;
signal	pf_ram_rd_z		: std_logic;

signal	start_rd		: std_logic;
signal	start_wr		: std_logic;   
signal	dmari			: std_logic;

signal	start_rd0		: std_logic;
signal	start_wr0		: std_logic;

signal	start_rd1		: std_logic;
signal	start_wr1		: std_logic;

signal	flag0_set		: std_logic_vector( 1 downto 0 );
signal	flag1_set		: std_logic_vector( 1 downto 0 );
signal	flag2_set		: std_logic_vector( 1 downto 0 );

signal	flag0_clr		: std_logic_vector( 1 downto 0 );
signal	flag1_clr		: std_logic_vector( 1 downto 0 );
signal	flag2_clr		: std_logic_vector( 1 downto 0 );
signal	local_adr_rdy	: std_logic;	-- 1 - локальный адрес записан 



attribute	tig			: string;
attribute	tig			of flag2_set	: signal is "";
attribute	tig			of flag2_clr	: signal is "";
attribute	tig			of start_rd0	: signal is "";
attribute	tig			of start_wr0	: signal is "";

begin
	
rst_p0 <= (not reset) or reg_ctrl(4) after 1 ns when rising_edge( aclk );	
rst_p <= rst_p0 after 1 ns when rising_edge( aclk );	

pf_cb <= cb;						

pf_repack_we_z <= pf_repack_we after 1 ns when rising_edge( aclk );
--block_rd_eot <= '1' when pf_repack_we='0' and pf_repack_we_z='1' else '0';
block_rd_eot <= next_block after 1 ns when rising_edge( aclk );

pf_ram_rd_z <= pf_ram_rd after 1 ns when rising_edge( aclk );
--block_wr_eot <= '1' when pf_ram_rd='0' and pf_ram_rd_z='1' else '0';
	
dmari <= dmar or not reg_ctrl(1);

pr_local_adr_rdy: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( reg_ctrl(0)='0' ) then
			local_adr_rdy <= '0' after 1 ns;
		elsif( loc_adr_we='1' ) then
			local_adr_rdy <= '1' after 1 ns;
		end if;
	end if;
end process;
			

start_rd0 <= reg_ctrl(0) and reg_ctrl(2) and dmari and not flag_data( conv_integer(cb) ) and local_adr_rdy after 1 ns when rising_edge( aclk );
start_wr0 <= reg_ctrl(0) and (not reg_ctrl(2)) and dmari and flag_data( conv_integer(cb) ) and local_adr_rdy after 1 ns when rising_edge( aclk ) ;


start_rd1 <= start_rd0 after 1 ns when rising_edge( aclk );
start_wr1 <= start_wr0 after 1 ns when rising_edge( aclk );

start_rd <= act and start_rd1;
start_wr <= act and start_wr1;

pr_state: process( aclk ) begin
	if( rising_edge( aclk ) ) then
		
		case( stp ) is
			
			when s0 =>
				flag0_set(0) <= '0' after 1 ns;
				flag0_set(1) <= '0' after 1 ns;
				flag0_clr(0) <= '0' after 1 ns;
				flag0_clr(1) <= '0' after 1 ns;	   
				adr_hi_wr <= '0' after 1 ns;
				
				pf_dma_wr_rdy <= '0' after 1 ns;		 
				pf_dma_rd_rdy <= '0' after 1 ns;
				
				rdy <= '0' after 1 ns;	   
				if( start_rd='1' ) then
					pf_dma_rd_rdy <= '1' after  1 ns;
					stp <= sr2 after  1ns;
				elsif( start_wr='1' ) then
				    pf_dma_wr_rdy <= '1' after 1 ns;		 
					stp <= sw2 after 1 ns;
				elsif( act='1' ) then
					stp <= s2 after 1 ns;
				end if;
			

			
			when s2 => ---  анал DMA выключен ----
				rdy <= '1' after 1 ns;
				--cb <= '0';
				if( act='0' ) then
					stp <= s0 after 1 ns;
				end if;
		


			when sr2 =>	  
--				if( pf_repack_we_z='1' ) then
--					pf_dma_rd_rdy <= '0' after 1 ns;
--				end if;
				if( block_rd_eot='1' ) then
					stp <= sr5 after 1 ns;
				end if;
				
				
			when sr5 =>
				pf_dma_rd_rdy <= '0' after 1 ns;
			--flag_set(conv_integer(cb)) <= '1' after 1 ns;
				flag0_set(0) <= not cb after 1 ns;
				flag0_set(1) <= cb after 1 ns;
			
--			
--				flag0_set(0) <= next_block and not cb after 1 ns;
--				flag0_set(1) <= next_block and cb after 1 ns;
--				if( next_block='1' ) then
--					cb <= not cb after 1 ns;
--				end if;						
				cb <= not cb after 1 ns;
				stp <= sr6 after 1 ns;		
				adr_hi_wr <= '1' after 1 ns;

			when sr6 =>						
				adr_hi_wr <= '0' after 1 ns;
				flag0_set(0) <= '0' after 1 ns;
				flag0_set(1) <= '0' after 1 ns;
				flag0_clr(0) <= '0' after 1 ns;
				flag0_clr(1) <= '0' after 1 ns;
				rdy <= '1' after 1 ns;
				if( act='0' ) then
					stp <= s0 after 1 ns;
				end if;						  				 
				
			when sw2 =>
--				if( pf_ram_rd='1' ) then
--					pf_dma_wr_rdy <= '0' after  1 ns;
--				end if;
				if( block_rd_eot='1' ) then
					stp <= sw3 after 1 ns;
				end if;
				
			when sw3 =>											 
				pf_dma_wr_rdy <= '0' after  1 ns;
				flag0_clr(0) <= not cb after 1 ns;
				flag0_clr(1) <= cb after 1 ns;
--				if( next_block='1' ) then
--					cb <= not cb after 1 ns;
--				end if;			
				cb <= not cb after 1 ns;
				stp <= sr6 after  1 ns;
				adr_hi_wr <= '1' after 1 ns;
				
			
			
		end case;								  
		
		
		if( rst_p='1' ) then
			stp <= s0 after 1 ns;		
			cb <= '0' after 1 ns;			
			rdy <= act after 1 ns;
		end if;
		
		
	end if;
end process;

gen_flag: for ii in 0 to 1 generate

pr_flag1_set: process( flag0_set(ii), clk ) begin
	
	if( flag0_set(ii)='1' ) then
		flag1_set(ii) <= '1' after 1 ns;
	elsif( rising_edge( clk ) ) then
		if( flag2_set(ii)='1' or rst_p='1' ) then
			flag1_set(ii) <= '0' after 1 ns;
		end if;
	end if;
	
end process;

pr_flag1_clr: process( flag0_clr(ii), clk ) begin
	
	if( flag0_clr(ii)='1' or rst_p='1' ) then
		flag1_clr(ii) <= '1' after 1 ns;
	elsif( rising_edge( clk ) ) then
		if( flag2_clr(ii)='1' ) then
			flag1_clr(ii) <= '0' after 1 ns;
		end if;
	end if;
	
end process;

end generate;

flag2_set <= flag1_set after 1 ns when rising_edge( clk );
flag2_clr <= flag1_clr after 1 ns when rising_edge( clk );

flag_set <= flag1_set;
flag_clr <= flag1_clr;


end ctrl_ram_cmd_pb;
