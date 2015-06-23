-------------------------------------------------------------------------------
--     Politecnico di Torino                                              
--     Dipartimento di Automatica e Informatica             
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------     
--
--     Title          : EPC Class1 Gen2 RFID Tag - 16-bit Pseudo-random Number Generator    
--
--     File name      : pseudoRNG.vhd 
--
--     Description    : Peudo-random number generator based on 31-bit LFSR.
--                      LFSR primitive polynomial: 1 + X^28 + X^31
--                      Better performance may be reached using a leap-forward
--                      LFSR implementation...!!!
--     
--     Authors        : Erwing R. Sanchez <erwing.sanchez@polito.it>
--                                 
-------------------------------------------------------------------------------            
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH.all;


entity prng is
  port (
    clk   : in  std_logic;
    rst_n : in  std_logic;
    init  : in  std_logic;
    cin   : in  std_logic_vector(30 downto 0);
    ce    : in  std_logic;
    cout  : out std_logic_vector(30 downto 0));
end prng;


architecture prng_arch of prng is

  signal lfsr31 : std_logic_vector(30 downto 0);
  
begin  -- prng16_arch

  LFSR : process (clk, rst_n)
  begin  -- process LFSR
    if rst_n = '0' then                 -- asynchronous reset (active low)
      lfsr31 <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if init = '1' then
        lfsr31 <= cin;
      elsif ce = '1' then               -- shift register;
        lfsr31(30 downto 1) <= lfsr31(29 downto 0);
        lfsr31(0)           <= lfsr31(30) xor lfsr31(27);
      end if;
    end if;
  end process LFSR;

  cout <= lfsr31;
  
end prng_arch;
