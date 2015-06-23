-------------------------------------------------------------------------------
--     Politecnico di Torino                                              
--     Dipartimento di Automatica e Informatica             
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------     
--
--     Title          : Simple Counter with clear    
--
--     File name      : counterclear.vhd 
--
--     Description    : Counter with clear.    
--
--     Authors        : Erwing R. Sanchez <erwing.sanchez@polito.it>
-------------------------------------------------------------------------------            
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity COUNTERCLR is
  generic (
    width : integer := 8);

  port (
    clk    : in  std_logic;
    rst_n  : in  std_logic;
    en     : in  std_logic;
    clear  : in  std_logic;
    outcnt : out std_logic_vector(width-1 downto 0));
end COUNTERCLR;

architecture COUNTERCLR1 of COUNTERCLR is

  signal cnt : std_logic_vector(width-1 downto 0);
  
begin  -- COUNTERCLR1

  process (clk, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      cnt <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if en = '1' then
        cnt <= conv_std_logic_vector(CONV_INTEGER(cnt) + 1, width);
      elsif clear = '1' then
        cnt <= (others => '0');
      end if;
      
    end if;
  end process;

  outcnt <= cnt;
  
end COUNTERCLR1;
