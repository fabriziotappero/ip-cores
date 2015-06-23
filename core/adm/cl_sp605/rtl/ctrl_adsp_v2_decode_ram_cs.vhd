---------------------------------------------------------------------------------------------------
--
-- Title       : ctrl_adsp_v2_decode_ram_cs
-- Author      : Dmitry Smekhov, Ilya Ivanov
-- Company     : Instrumental System
--
-- Version     : 1.1
---------------------------------------------------------------------------------------------------
--
-- Description :  Модуль декодирования сигнала чтения ОЗУ или ПЗУ  для Virtex2
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


entity ctrl_adsp_v2_decode_ram_cs is
	generic (
		reg			: in integer			-- номер регистра
											-- 0 - RAM
											-- 1 - ROM
	);
	port (
		reset		: in std_logic;			-- 0 - сброс
		clk			: in std_logic;			-- тактовая частота
		cmd_adr		: in std_logic_vector( 9 downto 8 );	-- косвенный адрес
		adr			: in std_logic_vector( 4 downto 0 );	-- шина адреса
		rd			: in std_logic;							-- 0 - чтение данных
		data_cs		: out std_logic							-- 0 - чтение данных
	);
end ctrl_adsp_v2_decode_ram_cs;


architecture ctrl_adsp_v2_decode_ram_cs of ctrl_adsp_v2_decode_ram_cs is

signal cs1	: std_logic;	-- 0 - чтение данных

--attribute rloc	: string;
--attribute rloc	of xcs1	: label is "X0Y0";
--attribute rloc	of xd	: label is "X0Y0";

begin
	
	
	
cs1 <='0' when 	adr( 1 downto 0 )="11" and 
				cmd_adr( 9 downto 8 )=conv_std_logic_vector( reg, 2 )
				else '1'  after 1 ns;

--xcs1: fmap port map( o=>cs1, i1=>cmd_adr(8), i2=>cmd_adr(9), i3=>adr(0), i4=>adr(1) );
xd:	  fd   port map( q=>data_cs, c=>clk, d=>cs1 );


end ctrl_adsp_v2_decode_ram_cs;
