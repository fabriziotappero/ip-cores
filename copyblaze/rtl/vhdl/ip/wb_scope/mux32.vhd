-----------------------------------------------------------------------------
-- 32-to-1 MUXer ------------------------------------------------------------
--
-- (c) 2006 by Joerg Bornschein  (jb@capsec.org)
-- All files under GPLv2   
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;


-----------------------------------------------------------------------------
-- 32-to-1 MUXer ------------------------------------------------------------
entity mux32 is
	port (
		input     : in  std_logic_vector(31 downto 0);
		output    : out std_logic;
		sel       : in  std_logic_vector(4 downto 0) );
end entity;


-----------------------------------------------------------------------------
-- Implementation -----------------------------------------------------------
architecture rtl of mux32 is
signal usel : unsigned(4 downto 0);
begin

  output <= input( to_integer(unsigned(sel)) );

end architecture rtl;
