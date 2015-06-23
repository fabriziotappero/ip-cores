---------------------------------------------------------------------------------------------------
--
-- Title       : cl_fifo_control_v2
-- Author      : Dmitry Smekhov
-- Company     : Instrumental System
-- E-mail	   : dsmv@insys.ru
--	
-- Version	   : 2.0
--
---------------------------------------------------------------------------------------------------
--
-- Description : Управление FIFO
--				 Модификация 2
--				 Используется для управления FIFO с выходом на регистр
--
---------------------------------------------------------------------------------------------------
--					
--  Version 2.0  24.02.2004
--				 Изменён алгоритм работы. Исправлены ошибки чтения данных.
--
--  Version 1.2  13.01.2004
--				 Исправлено чтение второго слова из FIFO при empty=0
--
--  Version 1.1  24.12.2003
--				Исправлен алгоритм работы
--
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity cl_fifo_control_v2 is   
	port(  
		reset		: in std_logic;		-- 0 - сброс
		clk			: in std_logic;		-- тактовая частота
		ef			: out std_logic;	-- 0 - FIFO пустое
		rd			: out std_logic;	-- 1 - чтение из FIFO
		we			: out std_logic;	-- 1 - запись во входной буфер
		empty		: in std_logic;		-- 1 - FIFO пустое
		read		: in std_logic 		-- 0 - запрос на чтение
		);
end cl_fifo_control_v2;


architecture cl_fifo_control_v2 of cl_fifo_control_v2 is

type	st_type is ( s0, s1, s2, s4, s5, s6, s7 );
signal	st, stn	: st_type;			 		
signal	empty1	: std_logic;

begin						
	
pr_state: process( reset, clk ) begin
	if( reset='0' ) then
		st<=s0;
	elsif( rising_edge( clk ) ) then
		st<=stn after 1 ns;		
	end if;
end process;

pr_empty1: process( clk ) begin
	if( rising_edge( clk ) ) then
		empty1<=empty after 1 ns;			 
	end if;
end process;	

pr_st: process( clk, st, empty, read ) 

variable vr	: std_logic;	-- rd;
variable vw	: std_logic;	-- we;
variable vef: std_logic;	-- ef;

begin					
	
	vr:='0';
	vw:='0';
	vef:='0';
	
	case  st is
		when s0 =>  if( empty='0' ) then
						stn <= s1; 
					else 
					    stn <=s0;
					end if;
		when s1 =>  vr:='1'; stn <=s2;
		when s2 => 	vw:='1'; stn <=s4;
		when s4 =>  if( empty1='0' ) then stn<=s7; vr:='1';
					else stn<=s5;
					end if;
		when s5	=>  vef:='1';
					if( read='0' ) then
						stn<=s0;
					elsif( empty1='0' ) then
						vr:='1';
						stn<=s7;
					else
						stn<=s5;
					end if;		
					
		when s6 =>  -- vef:='1';
						vr:='1';
						stn<=s7;
--					if( read='0' )then 
--						stn<=s0;
--					else
--						vr:='1';
--						stn<=s7;
--					end if;
					
		when s7 =>	vef:='1';
					if( read='0' ) then
						if( empty='0' ) then
							vr:='1';
							vw:='1';
							stn<=s7;
						else
							vw:='1';
							stn<=s5;
						end if;
					else
						stn<=s7;
					end if;
		end case;
		
		rd <= vr;
		we <= vw;
		ef <= vef;
					
end process;	

end cl_fifo_control_v2;
