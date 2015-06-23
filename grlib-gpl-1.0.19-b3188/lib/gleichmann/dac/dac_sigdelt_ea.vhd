--*******************************************************************************
--
--  D/A Converter based on 1st order Delta-Sigma Modulator
--
--  Coded by and Private Property of Prof. Dr. Martin Schubert
--
--  14. February 2005
--
--  FH Regensburg, Univ. of Applied Sciences
--  Seybothstrasse 2, D-93053 Regensburg
--  Email: martin.schubert@e-technik.fh-regensburg.de
--
--*******************************************************************************

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;

entity sigdelt is
    generic(c_dacin_length:positive:=8); -- length of binary input vector dac_in
    port(
      reset:in std_logic;     -- resets integrator, high-active
      clock:in std_logic;     -- sampling clock
      dac_in:in std_logic_vector(c_dacin_length-1 downto 0); -- input vector
      dac_out:out std_logic   -- pseudo-random output bit stream
    );
end sigdelt;

architecture rtl of sigdelt is
  signal delta:std_logic_vector(c_dacin_length+1 downto 0); -- input - feedback
  signal state:std_logic_vector(c_dacin_length+1 downto 0); -- integrator's state vector
begin
 --
  delta(c_dacin_length+1)<=state(c_dacin_length+1);
  delta(c_dacin_length)  <=state(c_dacin_length+1);
  delta(c_dacin_length-1 downto 0)<=dac_in;
  --
  -- integrator
  pr_integrator:process(reset,clock)
  begin
    if reset='1' then
      state<=(others=>'0');
    elsif clock'event and clock='1' then
      state<=state+delta;
    end if;
  end process pr_integrator;
  --
  -- generating a postponed flipflop
  pr_postponed:process(reset,clock)
  begin
    if reset='1' then
      dac_out<='0';
    elsif clock'event and clock='1' then
      dac_out<=state(c_dacin_length+1);
    end if;
  end process pr_postponed;
 --
end rtl;


configuration con_sigdelt of sigdelt is
  for rtl
  end for;
end con_sigdelt;
