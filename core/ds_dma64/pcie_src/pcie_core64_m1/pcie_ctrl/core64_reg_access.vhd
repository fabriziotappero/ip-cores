-------------------------------------------------------------------------------
--
-- Title       : core64_reg_access
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description :  Узел доступа к регистрам в пространствах BAR0, BAR1
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.core64_type_pkg.all;

package core64_reg_access_pkg is

component core64_reg_access is
	port(
		--- General ---
		rstp				: in std_logic;		--! 1 - сброс 
		clk					: in std_logic;		--! тактовая частота ядра - 250 MHz 
		
		--- RX_ENGINE ---- 
		reg_access			: in  type_reg_access;		--! запрос на доступ к регистрам 
		
		--- TX_ENGINE ----
		reg_access_back		: out type_reg_access_back;	--! ответ на запрос 
		
		---- PB_DISP ----
		reg_disp			: out type_reg_disp;		--! запрос на доступ к регистрам из BAR1 
		reg_disp_back		: in  type_reg_disp_back;	--! ответ на запрос 
		
		---- BLOCK EXT_FIFO ----
		reg_ext_fifo		: out type_reg_ext_fifo;		--! запрос на доступ к блокам управления EXT_FIFO 
		reg_ext_fifo_back	: in  type_reg_ext_fifo_back;	--! ответ на запрос 
		
		---- BAR0 - блоки управления ----
		bp_host_data		: out std_logic_vector( 31 downto 0 );	--! шина данных - выход 
		bp_data				: in  std_logic_vector( 31 downto 0 );  --! шина данных - вход
		bp_adr				: out  std_logic_vector( 19 downto 0 );	--! адрес регистра 
		bp_we				: out std_logic_vector( 3 downto 0 ); 	--! 1 - запись в регистры 
		bp_rd				: out std_logic_vector( 3 downto 0 );   --! 1 - чтение из регистров блока 
		bp_sel				: out std_logic_vector( 1 downto 0 );	--! номер блока для чтения 
		bp_reg_we			: out std_logic;			--! 1 - запись в регистр по адресам   0x100000 - 0x1FFFFF 
		bp_reg_rd			: out std_logic; 			--! 1 - чтение из регистра по адресам 0x100000 - 0x1FFFFF 
		bp_irq				: in  std_logic				--! 1 - запрос прерывания 
	);
		
end component;

end package;



library ieee;
use ieee.std_logic_1164.all;

use work.core64_type_pkg.all;

entity core64_reg_access is		
	port(
	
		--- General ---
		rstp				: in std_logic;		--! 1 - сброс 
		clk					: in std_logic;		--! тактовая частота ядра - 250 MHz 
		
		--- RX_ENGINE ---- 
		reg_access			: in  type_reg_access;		--! запрос на доступ к регистрам 
		
		--- TX_ENGINE ----
		reg_access_back		: out type_reg_access_back;	--! ответ на запрос 
		
		---- PB_DISP ----
		reg_disp			: out type_reg_disp;		--! запрос на доступ к регистрам из BAR1 
		reg_disp_back		: in  type_reg_disp_back;	--! ответ на запрос 
		
		---- BLOCK EXT_FIFO ----
		reg_ext_fifo		: out type_reg_ext_fifo;		--! запрос на доступ к блокам управления EXT_FIFO 
		reg_ext_fifo_back	: in  type_reg_ext_fifo_back;	--! ответ на запрос 
		
		---- BAR0 - блоки управления ----
		bp_host_data		: out std_logic_vector( 31 downto 0 );	--! шина данных - выход 
		bp_data				: in  std_logic_vector( 31 downto 0 );  --! шина данных - вход
		bp_adr				: out std_logic_vector( 19 downto 0 );	--! адрес регистра 
		bp_we				: out std_logic_vector( 3 downto 0 ); 	--! 1 - запись в регистры 
		bp_rd				: out std_logic_vector( 3 downto 0 );   --! 1 - чтение из регистров блока 
		bp_sel				: out std_logic_vector( 1 downto 0 );	--! номер блока для чтения 
		bp_reg_we			: out std_logic;			--! 1 - запись в регистр по адресам   0x100000 - 0x1FFFFF 
		bp_reg_rd			: out std_logic; 			--! 1 - чтение из регистра по адресам 0x100000 - 0x1FFFFF 
		bp_irq				: in  std_logic				--! 1 - запрос прерывания 
	);
		
end core64_reg_access;


architecture core64_reg_access of core64_reg_access is		

signal	bar0_complete		: std_logic;
signal	bar1_complete		: std_logic;
signal	adr					: std_logic_vector( 31 downto 0 );

signal	bar0_write			: std_logic;
signal	bar0_read			: std_logic;
signal	bar1_read			: std_logic;
signal	bar0i_data			: std_logic_vector( 31 downto 0 );
signal	bar0_data			: std_logic_vector( 31 downto 0 );

signal	bar1_data			: std_logic_vector( 31 downto 0 );

type	stp_type	is ( s0, s1, s2 );
signal	stp					: stp_type;
signal	st1p				: stp_type;

signal	disp_complete		: std_logic;


begin
	
bp_adr <= reg_access.adr( 22 downto 3 );	
bp_sel <= reg_access.adr( 9 downto 8 );	
reg_disp.adr <= reg_access.adr( 31 downto 0 );
reg_ext_fifo.adr <= reg_access.adr( 9 downto 3 );

bp_host_data 		<= reg_access.data;
reg_disp.data 		<= reg_access.data;
reg_ext_fifo.data 	<= reg_access.data;

reg_access_back.complete <= bar0_complete or bar1_complete after 1 ns when rising_edge( clk );

adr <= reg_access.adr;

bp_reg_we <= bar0_write and adr(20) after 1 ns when rising_edge( clk );

bp_we(0) <= bar0_write and not adr(20) and not adr(10) and not adr(9) and not adr(8) after 1 ns when rising_edge( clk );
bp_we(1) <= bar0_write and not adr(20) and not adr(10) and not adr(9) and     adr(8) after 1 ns when rising_edge( clk );
bp_we(2) <= bar0_write and not adr(20) and not adr(10) and     adr(9) and not adr(8) after 1 ns when rising_edge( clk );
bp_we(3) <= bar0_write and not adr(20) and not adr(10) and     adr(9) and     adr(8) after 1 ns when rising_edge( clk );

bp_reg_rd <= bar0_write and adr(20) after 1 ns when rising_edge( clk );

bp_rd(0) <= bar0_read and not adr(20) and not adr(10) and not adr(9) and not adr(8) after 1 ns when rising_edge( clk );
bp_rd(1) <= bar0_read and not adr(20) and not adr(10) and not adr(9) and     adr(8) after 1 ns when rising_edge( clk );
bp_rd(2) <= bar0_read and not adr(20) and not adr(10) and     adr(9) and not adr(8) after 1 ns when rising_edge( clk );
bp_rd(3) <= bar0_read and not adr(20) and not adr(10) and     adr(9) and     adr(8) after 1 ns when rising_edge( clk );


reg_ext_fifo.data_we <= bar0_write and not adr(20) and adr(10) after 1 ns when rising_edge( clk );


bar0i_data <= bp_data when adr(20)='1' or adr(10)='0' else
			  reg_ext_fifo_back.data;
	
bar0_data <= bar0i_data after 1 ns when rising_edge( clk ) and bar0_read='1';
bar1_data <= reg_disp_back.data after 1 ns when rising_edge( clk ) and reg_disp_back.data_we='1';

reg_access_back.data <= bar0_data when reg_access.req_rd(0)='1' else bar1_data;
reg_access_back.data_we <= bar0_read or bar1_read after 1 ns when rising_edge( clk );	   


pr0_state: process( clk ) begin
	if( rising_edge( clk ) ) then
		
		case( stp ) is
		
			when s0 =>
				bar0_complete <= '0' after 1 ns;
				bar0_write <= '0' after 1 ns;
				bar0_read  <= '0' after 1 ns;

				if( reg_access.req_wr(0)='1' or reg_access.req_rd(0)='1' ) then
					stp <= s1 after 1 ns;
				end if;
				
			when s1 =>
				bar0_write <= reg_access.req_wr(0) after 1 ns;
				bar0_read  <= reg_access.req_rd(0) after 1 ns;
				stp <= s2 after 1 ns;

			
			when s2 =>
				bar0_write <= '0' after 1 ns;
				bar0_read  <= '0' after 1 ns;
				bar0_complete <= '1' after 1 ns;
				if( reg_access.req_wr(0)='0' and reg_access.req_rd(0)='0' ) then
					stp <= s0 after 1 ns;
				end if;
			
		end case;
		
		if( rstp='1' ) then
			stp <= s0 after 1 ns;
		end if;
		
	end if;
end process;	

disp_complete <= reg_disp_back.complete after 1 ns when rising_edge( clk );
		
pr1_state: process( clk ) begin
	if( rising_edge( clk ) ) then
		
		case( st1p ) is
		
			when s0 =>
				bar1_complete <= '0' after 1 ns;
				bar1_read  <= '0' after 1 ns;
				reg_disp.request_reg_wr <= '0' after 1 ns;
				reg_disp.request_reg_rd <= '0' after 1 ns;

				if( reg_access.req_wr(1)='1' or reg_access.req_rd(1)='1' ) then
					st1p <= s1 after 1 ns;
				end if;
				
			when s1 =>
				reg_disp.request_reg_wr <= reg_access.req_wr(1) after 1 ns;
				reg_disp.request_reg_rd <= reg_access.req_rd(1) after 1 ns;
				bar1_read  <= '1' after 1 ns;
				
				if( disp_complete='1' ) then
					st1p <= s2 after 1 ns;
				end if;

			
			when s2 =>
				reg_disp.request_reg_wr <= '0' after 1 ns;
				reg_disp.request_reg_rd <= '0' after 1 ns;
				bar1_read  <= '0' after 1 ns;
				bar1_complete <= '1' after 1 ns;
				if( reg_access.req_wr(1)='0' and reg_access.req_rd(1)='0' ) then
					st1p <= s0 after 1 ns;
				end if;
			
		end case;
		
		if( rstp='1' ) then
			st1p <= s0 after 1 ns;
		end if;
		
	end if;
end process;


	
end core64_reg_access;
