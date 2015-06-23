---------------------------------------------------------------------------------------------------
--
-- Title       : ctrl_adsp_v2_decode_data_we
-- Author      : Dmitry Smekhov, Ilya Ivanov
-- Company     : Instrumental System
--
-- Version     : 1.1
---------------------------------------------------------------------------------------------------
--
-- Description :  Модуль декодирования сигналов записи в тетраду для Virtex2
--
---------------------------------------------------------------------------------------------------
--
--	Version 1.1 17.06.2005
--				Удалены атрибуты RLOC и компоненты FMAP
--
---------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;  
use ieee.std_logic_arith.all;

-- synopsys translate_off
library ieee;
use ieee.vital_timing.all;	
-- synopsys translate_on

library unisim;
use unisim.VCOMPONENTS.all;


entity ctrl_adsp_v2_decode_data_we is	
	generic(
		trd			: in integer;			-- номер тетрады
		reg			: in integer			-- номер регистра
											-- 0 - STATUS
											-- 1 - DATA
											-- 2 - CMD_ADR
											-- 3 - CMD_DATA
	);					 
	port (
		reset		: in std_logic;			-- 0 - сброс
		clk			: in std_logic;			-- тактовая частота
		adr			: in std_logic_vector( 4 downto 0 );	-- шина адреса
		wr			: in std_logic;							-- 0 - запись данных
		data_we		: out std_logic							-- 1 - запись данных
	);
end ctrl_adsp_v2_decode_data_we;


architecture ctrl_adsp_v2_decode_data_we of ctrl_adsp_v2_decode_data_we is

signal cs0	: std_logic;	-- 1 - совпадение номера тетрады
signal cs1	: std_logic;	-- 0 - чтение данных

component fmap is
	port(
		i1, i2, i3, i4	: in std_logic;
		o				: in std_logic
	);
end component;
	
--attribute rloc	: string;
--attribute rloc	of fmap	: component is "X0Y0";
--attribute rloc	of xd	: label is "X0Y0";

begin
	

cs0 <='1' when adr( 4 downto 2 )=conv_std_logic_vector( trd, 3 ) else '0';
cs1 <='1' when 	adr( 1 downto 0 )=conv_std_logic_vector( reg, 2 ) 
				and wr='0' and  cs0='1'
			    else '0'  after 1 ns;
				   
				   
--xcs0: fmap port map( o=>cs0, i1=>adr(2), i2=>adr(3), i3=>adr(4), i4=>'0' );	
--xcs1: fmap port map( o=>cs1, i1=>cs0, i2=>wr, i3=>adr(0), i4=>adr(1) );
xd:	  fd   port map( q=>data_we, c=>clk, d=>cs1 );


end ctrl_adsp_v2_decode_data_we;

