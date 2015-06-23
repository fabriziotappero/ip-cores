-------------------------------------------------------------------------------
--
-- Title       : core64_pb_transaction
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.2
--
-------------------------------------------------------------------------------
--
-- Description : Узел управления локальной шиной 
--												
--		pb_master.cmd	- команда управления, сопровождается стробом stb0
--					0: 	- 1 запись данных
--					1:  - 1 чтение данных
--					2:  - 0 - одно слово, 1 - пакет 512 слов (4096 байт)
--
-------------------------------------------------------------------------------
--
--	Version 1.2  14.12.2011
--				 Добавлен lc_rd_cfg
--
---------------------------------------------------------------------------------
--
--  Version 1.1  28.09.2011 Dmitry Smekhov
--				 Добавлен сигнал pb_slave.complete 
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;		   

use work.core64_type_pkg.all;

package core64_pb_transaction_pkg is

component core64_pb_transaction is			  
	port(
		reset				: in std_logic;		--! 0 - сброс
		clk					: in std_logic;		--! тактовая частота локальной шины - 266 МГц 
		
		---- BAR1 ----	
		pb_master			: in  type_pb_master;		--! запрос 
		pb_slave			: out type_pb_slave;		--! ответ  
		
		---- локальная шина -----		
		lc_adr				: out std_logic_vector( 31 downto 0 );	--! шина адреса
		lc_host_data		: out std_logic_vector( 63 downto 0 );	--! шина данных - выход
		lc_data				: in  std_logic_vector( 63 downto 0 );	--! шина данных - вход
		lc_wr				: out std_logic;	--! 1 - запись
		lc_rd				: out std_logic;	--! 1 - чтение, данные должны быть на шестой такт после rd 
		lc_dma_req			: in  std_logic_vector( 1 downto 0 );	--! 1 - запрос DMA
		lc_irq				: in  std_logic;	--! 1 - запрос прерывания 
		lc_rd_cfg			: in std_logic_vector( 3 downto 0 ):="0101"	--! настройка задержки захвата данных по сигналу lc_rd				
				
	
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

entity core64_pb_transaction is			  
	port(
		reset				: in std_logic;		--! 0 - сброс
		clk					: in std_logic;		--! тактовая частота локальной шины - 266 МГц 
		
		---- BAR1 ----	
		pb_master			: in  type_pb_master;		--! запрос 
		pb_slave			: out type_pb_slave;		--! ответ  
		
		---- локальная шина -----		
		lc_adr				: out std_logic_vector( 31 downto 0 );	--! шина адреса
		lc_host_data		: out std_logic_vector( 63 downto 0 );	--! шина данных - выход
		lc_data				: in  std_logic_vector( 63 downto 0 );	--! шина данных - вход
		lc_wr				: out std_logic;	--! 1 - запись
		lc_rd				: out std_logic;	--! 1 - чтение, данные должны быть на шестой такт после rd 
		lc_dma_req			: in  std_logic_vector( 1 downto 0 );	--! 1 - запрос DMA
		lc_irq				: in  std_logic;	--! 1 - запрос прерывания 
		lc_rd_cfg			: in std_logic_vector( 3 downto 0 ):="0101"	--! настройка задержки захвата данных по сигналу lc_rd				
				
	
	);
	
end core64_pb_transaction;


architecture core64_pb_transaction of core64_pb_transaction is

signal	cnt_start			: std_logic;
signal	cnt					: std_logic_vector( 9 downto 0 );
signal	rstp				: std_logic;
signal	rd_start			: std_logic;
signal	rd_start_z			: std_logic;
signal	rd_start_z1			: std_logic;
signal	stb1_z				: std_logic;

begin
	
rstp <= not reset after 1 ns when rising_edge( clk );
--rstp <= '1', '0' after 30 us;

lc_adr <= pb_master.adr 	   after 1 ns when rising_edge( clk );
lc_host_data <= pb_master.data after 1 ns when rising_edge( clk );
lc_wr <= pb_master.stb1		   after 1 ns when rising_edge( clk );
lc_rd <= rd_start 			   after 1 ns when rising_edge( clk );

pr_cnt: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( cnt_start='0' ) then
			if( pb_master.cmd(2)='0' ) then
				cnt <= "0111111111" after 1 ns;
			else
				cnt <= "0000000000" after 1 ns;
			end if;
		else
				cnt <= cnt + 1 after 1 ns;
		end if;
	end if;
end process;

pr_cnt_start: process( clk ) begin
	if( rising_edge( clk ) ) then	
		if( rstp='1' or cnt(9)='1' ) then
			cnt_start <= '0' after 1 ns;
		elsif( pb_master.cmd(1)='1' and pb_master.stb0='1' ) then
			cnt_start <= '1' after 1 ns;
		end if;
	end if;
end process;	
		
rd_start <= cnt_start and not cnt(9);

--xrdz:	srl16 port map( q=>rd_start_z, clk=>clk, d=>rd_start, a3=>'0', a2=>'1', a1=>'0', a0=>'1' );
xrdz:	srl16 port map( q=>rd_start_z, clk=>clk, d=>rd_start, a3=>lc_rd_cfg(3), a2=>lc_rd_cfg(2), a1=>lc_rd_cfg(1), a0=>lc_rd_cfg(0) );

pb_slave.stb0 <= pb_master.stb0 after 1 ns when rising_edge( clk );
pb_slave.stb1 <= rd_start_z  after 1 ns when rising_edge( clk );
pb_slave.data <= lc_data   after 1 ns when rising_edge( clk );
pb_slave.dmar <= lc_dma_req;  
pb_slave.irq  <= lc_irq;

rd_start_z1 <= rd_start_z after 1 ns when rising_edge( clk );
stb1_z <= pb_master.stb1 after 1 ns when rising_edge( clk );

pb_slave.complete <= ((not rd_start_z) and rd_start_z1) or
					 ((not pb_master.stb1) and stb1_z ) after 1 ns 
						when rising_edge( clk ); 

pb_slave.ready <= '1';

end core64_pb_transaction;
