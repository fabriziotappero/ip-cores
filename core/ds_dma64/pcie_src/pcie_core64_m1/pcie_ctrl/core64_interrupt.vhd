-------------------------------------------------------------------------------
--
-- Title       : core64_interrupt
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description : ”зел формировани€ прерываний 
--
-------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;  

package core64_interrupt_pkg is

component core64_interrupt is
	port(
	
		rstp					: in std_logic;		--! 1 - сброс
		clk						: in std_logic;		--! “актова€ частота €дра 250 ћ√ц
		
		irq						: in std_logic;		--! 1 - запрос прерывани€
		
		cfg_command10			: in  std_logic;	--! 1 - прерывани€ запрещены 
		cfg_interrupt			: out std_logic;	--! 0 - изменение состо€ни€ прерывани€
		cfg_interrupt_assert	: out std_logic;	--! 0 - формирование прерывани€, 1 - сни€тие прерывани€ 
		cfg_interrupt_rdy		: in  std_logic		--! 0 - подтверждение изменени€ прерывани€ 
	
	);
end component;

end package;

library ieee;
use ieee.std_logic_1164.all;  
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity core64_interrupt is
	port(
	
		rstp					: in std_logic;		--! 1 - сброс
		clk						: in std_logic;		--! “актова€ частота €дра 250 ћ√ц
		
		irq						: in std_logic;		--! 1 - запрос прерывани€
		
		cfg_command10			: in  std_logic;	--! 1 - прерывани€ запрещены 
		cfg_interrupt			: out std_logic;	--! 0 - изменение состо€ни€ прерывани€
		cfg_interrupt_assert	: out std_logic;	--! 0 - формирование прерывани€, 1 - сни€тие прерывани€ 
		cfg_interrupt_rdy		: in  std_logic		--! 0 - подтверждение изменени€ прерывани€ 
	
	);
end core64_interrupt;


architecture core64_interrupt of core64_interrupt is

type stp_type	is ( s0, s1, s2, s3 );

signal	stp			: stp_type;
signal	cnt			: std_logic_vector( 4 downto 0 );
signal	irq_en		: std_logic;

begin
	
pr_irq_en: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( rstp='1' or cfg_command10='1' ) then
			irq_en <= '0' after 1 ns;
		else
			irq_en	<= irq after 1 ns;
		end if;
	end if;
end process;

pr_state: process( clk ) begin
	if( rising_edge( clk ) ) then
		
		case( stp ) is
			when s0 =>
				cfg_interrupt_assert <= '0' after 1 ns;
				cfg_interrupt <= '1' after 1 ns;
				if( irq_en='1' and cnt(4)='1' ) then
					stp <= s1 after 1 ns;
				end if;
				
			when s1 =>
				
				if( cfg_interrupt_rdy='0' ) then
					cfg_interrupt <= '1' after 1 ns;	
					stp <= s2 after 1 ns;
				else
					cfg_interrupt <= '0' after 1 ns;
				end if;				
				
			when s2 =>
				cfg_interrupt <= '1' after 1 ns;		
				cfg_interrupt_assert <= '1' after 1 ns;
				if( irq_en='0' and cnt(4)='1' ) then
					stp <= s3 after 1 ns;
				end if;
				
			when s3 =>
				if( cfg_interrupt_rdy='0' ) then
					cfg_interrupt <= '1' after 1 ns;	
					stp <= s0 after 1 ns;
				else
					cfg_interrupt <= '0' after 1 ns;
				end if;				
			
		end case;		
			
		
		
		if( rstp='1' ) then
			stp <= s0 after 1 ns;
		end if;
		
	end if;
end process;
	
pr_cnt: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( rstp='1' or stp=s1 or stp=s3 ) then
			cnt <= "00000" after 1 ns;
		elsif( cnt(4)='0' ) then
			cnt <= cnt + 1 after 1 ns;
		end if;
	end if;
end process;
	

end core64_interrupt;
