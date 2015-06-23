-------------------------------------------------------------------------------
--
-- Title       : core64_pb_disp
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.2
--
-------------------------------------------------------------------------------
--
-- Description :  Диспетчер шины PB_BUS 
--
-------------------------------------------------------------------------------
--
--  Version 1.2  14.12.2011 Dmitry Smekhov
--				 Исправлено формирование сигналов reg_disp_back.data_we,
--				 reg_disp_back.complete
--				 
--
-------------------------------------------------------------------------------
--
--  Version 1.1  28.09.2011 Dmitry Smekhov
--				 Добавлен сигнал pb_slave.complete 
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.core64_type_pkg.all;

package core64_pb_disp_pkg is

component core64_pb_disp is
	port(
		--- General ---
		rstp				: in std_logic;		--! 1 - сброс 
		clk					: in std_logic;		--! тактовая частота ядра - 250 MHz 
		
		---- PB_DISP ----
		reg_disp			: in  type_reg_disp;		--! запрос на доступ к регистрам из BAR1 
		reg_disp_back		: out type_reg_disp_back;	--! ответ на запрос 
		
		---- EXT_FIFO ----
		ext_fifo_disp		: in  type_ext_fifo_disp;		--! запрос на доступ от узла EXT_FIFO 
		ext_fifo_disp_back	: out type_ext_fifo_disp_back;	--! ответ на запрос
		
		---- BAR1 ----	
		aclk				: in std_logic;				--! тактовая частота локальной шины - 266 МГц
		pb_master			: out type_pb_master;		--! запрос 
		pb_slave			: in  type_pb_slave			--! ответ  

	);

end component;

end package;


library ieee;
use ieee.std_logic_1164.all;	 
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

use work.core64_type_pkg.all;

entity core64_pb_disp is
	port(
		--- General ---
		rstp				: in std_logic;		--! 1 - сброс 
		clk					: in std_logic;		--! тактовая частота ядра - 250 MHz 
		
		---- PB_DISP ----
		reg_disp			: in  type_reg_disp;		--! запрос на доступ к регистрам из BAR1 
		reg_disp_back		: out type_reg_disp_back;	--! ответ на запрос 
		
		---- EXT_FIFO ----
		ext_fifo_disp		: in  type_ext_fifo_disp;		--! запрос на доступ от узла EXT_FIFO 
		ext_fifo_disp_back	: out type_ext_fifo_disp_back;	--! ответ на запрос
		
		---- BAR1 ----	
		aclk				: in std_logic;				--! тактовая частота локальной шины - 266 МГц
		pb_master			: out type_pb_master;		--! запрос 
		pb_slave			: in  type_pb_slave			--! ответ  

	);

end core64_pb_disp;


architecture core64_pb_disp of core64_pb_disp is

signal	reg_req_wr			: std_logic;
signal	reg_req_wr_z		: std_logic;
signal	reg_req_rd			: std_logic;
signal	reg_req_rd_z		: std_logic;

signal	pb_sel				: std_logic;   

signal	master_data			: std_logic_vector( 63 downto 0 );
signal	master_stb0			: std_logic;
signal	master_stb1			: std_logic;	
signal	master_cmd			: std_logic_vector( 2 downto 0 );

signal	reg_stb1			: std_logic;

signal	rstpz				: std_logic;

type stp_type is ( s0, sr1, sr2, sr3, sr5, sf1, sf2, sf3 );

signal	stp					: stp_type;

signal	pb_slave_stb1_z		: std_logic;
signal	ex_fifo_stb1_z		: std_logic;
signal	ext_fifo_eot		: std_logic;

signal	master_adr			: std_logic_vector( 31 downto 0 );
signal	dmar				: std_logic_vector( 1 downto 0 );

signal	fifo_allow_wr		: std_logic;		  
signal	fifo_data_en		: std_logic;

signal	reg_data_we_set		: std_logic;
signal	reg_data_we			: std_logic;
signal	reg_data_we_z1		: std_logic;
signal	reg_data_we_z2		: std_logic;
signal	reg_data_we_clr		: std_logic;
signal	reg_data_we_clr_z1	: std_logic;
signal	reg_data_we_clr_z2	: std_logic;

signal	reg_complete		: std_logic;

signal	timeout_cnt			: std_logic_vector( 12 downto 0 );
signal	slave_timeout		: std_logic;

attribute tig				: string;
attribute tig	of 	master_adr				: signal is "";
attribute tig	of 	dmar					: signal is "";
attribute tig	of 	rstp					: signal is "";

begin									
	
rstpz <= rstp after 1 ns when rising_edge( aclk );	

reg_req_wr <= reg_disp.request_reg_wr after 1 ns when rising_edge( aclk );
reg_req_wr_z <= reg_req_wr after 1 ns when rising_edge( aclk );

reg_req_rd <= reg_disp.request_reg_rd after 1 ns when rising_edge( aclk );
reg_req_rd_z <= reg_req_rd after 1 ns when rising_edge( aclk );


master_adr <= reg_disp.adr when pb_sel='0' else ext_fifo_disp.adr;
pb_master.adr <= master_adr;
	
master_data( 31 downto 0 ) <= reg_disp.data when pb_sel='0' else ext_fifo_disp.data( 31 downto 0 );
master_data( 63 downto 32 ) <= ext_fifo_disp.data( 63 downto 32 );	

master_stb1 <= reg_stb1 or ext_fifo_disp.data_we;

pb_master.data <= master_data after 1 ns when rising_edge( aclk );
pb_master.cmd <= master_cmd;

pb_master.stb0 <= master_stb0  after 1 ns when rising_edge( aclk );
pb_master.stb1 <= master_stb1  after 1 ns when rising_edge( aclk );

reg_disp_back.data <= pb_slave.data( 31 downto 0 ) after 1 ns  when rising_edge( aclk ) and pb_slave.stb1='1';

ext_fifo_disp_back.data	   <= pb_slave.data after 1 ns  when rising_edge( aclk );
ext_fifo_disp_back.data_we <= pb_slave.stb1 and fifo_data_en after 1 ns  when rising_edge( aclk );
dmar <= pb_slave.dmar;		 
ext_fifo_disp_back.dmar <= dmar;

ext_fifo_disp_back.irq <= pb_slave.irq;

pb_sel <= master_cmd(2) after 1 ns;

pr_state: process( aclk ) begin
	if( rising_edge( aclk ) ) then
		case( stp ) is
			when s0 =>
				master_cmd <= "000" after 1 ns;
				master_stb0 <= '0' after 1 ns;			 
				--reg_disp_back.complete <= '0' after 1 ns;
				reg_complete <= '0' after 1 ns;
				reg_data_we_set <= '0' after 1 ns;   
				fifo_allow_wr <= '0' after 1 ns;
				reg_stb1 <= '0' after 1 ns;			
				fifo_data_en <= '0' after 1 ns;
				ext_fifo_disp_back.complete <= '0' after 1 ns; 
				timeout_cnt <= (others=>'0') after 1 ns;
				
				if( reg_req_wr_z='1' or reg_req_rd_z='1' ) then
					stp <= sr1 after 1 ns;
				elsif( ext_fifo_disp.request_wr='1' or ext_fifo_disp.request_rd='1' ) then
					stp <= sf1 after 1 ns;
				end if;
				
			when sr1 => ---- Обращение к регистрам ----
				master_cmd(0) <= reg_req_wr_z after 1 ns;  	-- 1 - запись
				master_cmd(1) <= reg_req_rd_z after 1 ns;	-- 1 - чтение 
				master_cmd(2) <= '0';	-- только одно 32-х разрядное слово 
				master_stb0 <= '1' after 1 ns;  -- строб команды
				stp <= sr2 after 1 ns;
				
			when sr2 =>	---- Строб записи слова ----
				master_stb0 <= '0' after 1 ns;
				reg_stb1 <= reg_req_wr_z after 1 ns;
				stp <= sr3 after 1 ns;
				
				
			when sr3 =>	---- Ожидание подтверждения команды ---
				reg_stb1 <= '0' after 1 ns;
--				if( pb_slave.stb0='1' ) then
--				 	if( reg_req_rd_z='1' ) then
--						 stp <= sr4 after 1 ns;
--					else
--						stp <= sr5 after 1 ns;
--					end if;
--				end if;	   			
				timeout_cnt <= timeout_cnt + 1 after 1 ns;
				reg_data_we_set <= pb_slave.stb1 after 1 ns;
				if( pb_slave.complete='1' or slave_timeout='1') then
					stp <= sr5 after 1 ns;
				end if;
			
				
--			when sr4 => ---- Ожидание данных ----
--				if( pb_slave.stb1='1' ) then
--					reg_disp_back.data_we <= '1' after 1 ns;
--					stp <= sr5 after 1 ns;
--				end if;
				
			when sr5 => ---- Ожидание снятия запроса ----
				master_cmd <= "000";
				reg_data_we_set <= '0' after 1 ns;
				--reg_disp_back.complete <= '1' after 1 ns;	  
				reg_complete <= '1' after 1 ns;
				if( reg_req_wr_z='0' and reg_req_rd_z='0' ) then
					stp <= s0 after 1 ns;
				end if;
				
				

			when sf1 =>	
				master_cmd(0) <= ext_fifo_disp.request_wr after 1 ns;  	-- 1 - запись
				master_cmd(1) <= ext_fifo_disp.request_rd after 1 ns;	-- 1 - чтение 
				master_cmd(2) <= '1';	-- блок 512 слов 
				master_stb0 <= '1' after 1 ns;  -- строб команды
				stp <= sf2 after 1 ns;
				
			when sf2 =>					
				master_stb0 <= '0' after 1 ns;  -- строб команды
				fifo_allow_wr <= ext_fifo_disp.request_wr and pb_slave.ready after 1 ns;
				fifo_data_en <= '1' after 1 ns;
				timeout_cnt <= timeout_cnt + 1 after 1 ns;
				if( pb_slave.complete='1' or slave_timeout='1' ) then
					ext_fifo_disp_back.complete <= '1' after 1 ns;
					stp <= sf3 after 1 ns;
				end if;
				
			when sf3 =>
				ext_fifo_disp_back.complete <= '0' after 1 ns;
				fifo_allow_wr <= '0' after 1 ns;
				if( ext_fifo_disp.request_wr='0' and ext_fifo_disp.request_rd='0' ) then
					stp <= s0 after 1 ns;
				end if;
					
			
		end case;
		
		if( rstpz='1' ) then
			stp <= s0 after 1 ns;
		end if;
		
	end if;
end process;			   	

slave_timeout <= timeout_cnt(12) after 1 ns when rising_edge( clk );

ext_fifo_disp_back.allow_wr <= fifo_allow_wr;

pb_slave_stb1_z	 <= pb_slave.stb1 after 1 ns when rising_edge( aclk );
ex_fifo_stb1_z	 <= ext_fifo_disp.data_we after 1 ns when rising_edge( aclk );

--ext_fifo_eot <= (pb_slave_stb1_z and not pb_slave.stb1) or
--				 (ex_fifo_stb1_z and not ext_fifo_disp.data_we ) after 1 ns when rising_edge( aclk );
--				

--ext_fifo_eot <= pb_slave.complete after 1 ns when rising_edge( clk );

pr_reg_data_we: process( aclk ) begin
	if( rising_edge( aclk ) ) then
		if( reg_data_we_clr_z2='1' ) then	  
			reg_data_we <= '0' after 1 ns;
		elsif( reg_data_we_set='1' ) then
			reg_data_we <= '1' after 1 ns;
		end if;
	end if;
end process;

reg_data_we_z1 <= reg_data_we after 1 ns when rising_edge( clk );
reg_data_we_z2 <= reg_data_we_z1 after 1 ns when rising_edge( clk );
reg_disp_back.data_we <= reg_data_we_z2 and reg_disp.request_reg_rd after 1 ns when rising_edge( clk );

reg_data_we_clr <= reg_data_we_z2 after 1 ns when rising_edge( aclk );
reg_data_we_clr_z1 <= reg_data_we_clr after 1 ns when rising_edge( aclk );
reg_data_we_clr_z2 <= reg_data_we_clr_z1 after 1 ns when rising_edge( aclk );

xcomlete: srl16 port map( q=>reg_disp_back.complete, clk=>clk, d=>reg_complete, a3=>'0', a2=>'0', a1=>'1', a0=>'0' );
 

end core64_pb_disp;

