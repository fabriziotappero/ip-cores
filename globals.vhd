library ieee;
use ieee.std_logic_1164.all;

package globals is 
  -- number of data bits
  constant WORD_LENGTH : integer := 4;

  -- when each transmitter bit is 3.24 ms and the FPGA clock is 50 MHz
  -- then:

  -- single is nominally 23200
  constant INTERVAL_MIN_SINGLE: integer := 34000;--10000
  constant INTERVAL_MAX_SINGLE: integer := 65000;
  
  -- double is nominally 43000-50000
  constant INTERVAL_MIN_DOUBLE: integer := 80000;--90000
  constant INTERVAL_MAX_DOUBLE: integer := 120000;

  constant INTERVAL_QUADRUPLE: integer  := 650000;--350000
end globals;