---------------------------------------------------------------------------------------------------
--
-- Title       : host_pkg
-- Author      : Dmitry Smekhov
-- Company     : Instrumental System
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
---------------------------------------------------------------------------------------------------
--
-- Description : Определение общих типов данных
--
---------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;

package	host_pkg is
	

type bh_rom is array( 7 downto 0 ) of std_logic_vector( 15 downto 0 );


	
	
end package;

