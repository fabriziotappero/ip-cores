library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


entity AdrDec is
  generic (
    constant ADRS_SIZE    :     integer := 32;
    constant ADRS_BITS	  :     integer := 4;
    constant ADRS_RANGE   :     integer := 8 );  
  port (
    AdrIn                 : in  std_logic_vector(ADRS_SIZE-1 downto ADRS_SIZE-ADRS_BITS);
    AdrValid 		  : out std_logic);
end AdrDec;

architecture Behavioral of AdrDec is

signal Address : std_logic_vector (ADRS_BITS - 1 downto 0);

begin
	Address <= conv_std_logic_vector(ADRS_RANGE, ADRS_BITS);

	process (AdrIn)
	begin
		if (AdrIn (ADRS_SIZE - 1 downto ADRS_SIZE - ADRS_BITS) >= Address) then
			AdrValid <= '1';
		else
			AdrValid <= '0';
		end if;
	end process;

end Behavioral;
