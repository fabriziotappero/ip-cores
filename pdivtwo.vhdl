--
-- * pipelined synchronous pulse counter *
--  pdivtwo -- core 1-stage element (pipelined f/2 divider)
--
-- fast counter for slow-carry architectures
-- non-monotonic counting, value calculable by HDL/CPU
--
-- idea&code by Marek Peca <mp@duch.cz> 08/2012
-- Vyzkumny a zkusebni letecky ustav, a.s. http://vzlu.cz/
-- thanks to Michael Vacek <michael.vacek@vzlu.cz> for testing
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pdivtwo is
  port (
    clock: in std_logic;
    en: in std_logic;
    q, p: out std_logic
  );
end pdivtwo;

architecture behavioral of pdivtwo is
  signal state: std_logic := '1';
  signal pipe: std_logic := '0';
  signal next_state, next_pipe: std_logic;
begin
  next_state <= not state when en = '1' else state;
  next_pipe <= state and en;
  p <= pipe;
  q <= state;
  
  process
  begin
    wait until clock'event and clock = '1';
    state <= next_state;
    pipe <= next_pipe;
  end process;
end behavioral;
