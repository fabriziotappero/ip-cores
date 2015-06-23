-------------------------------------------------------------------------------
--     Politecnico di Torino                                              
--     Dipartimento di Automatica e Informatica             
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------     
--
--     Title          : Shift Register
--
--     File name      : shiftreg.vhd 
--
--     Description    : Simple Shift Register    
--
--     Authors        : Erwing R. Sanchez <erwing.sanchez@polito.it>
--                                 
-------------------------------------------------------------------------------            
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;


entity shiftreg is
  
  generic (
    REGWD : integer := 16);

  port (
    clk   : in  std_logic;
    rst_n : in  std_logic;
    ce    : in  std_logic;
    sin   : in  std_logic;
    pout  : out std_logic_vector(REGWD - 1 downto 0));

end shiftreg;

architecture shreg1 of shiftreg is

  signal shreg : std_logic_vector(REGWD-1 downto 0);
  
begin  -- shreg1

  process (clk , rst_n)
  begin
    if rst_n = '0' then
      shreg <= (others => '0');
    elsif clk'event and clk = '1' then
      if ce = '1' then
        shreg <= shreg((REGWD - 2) downto 0) & sin;
      end if;
    end if;
    pout <= shreg;
  end process;

end shreg1;
