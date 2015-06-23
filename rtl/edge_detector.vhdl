-- 
-- author:   Claudio Talarico
-- file:     ed-mealy-rtl.vhd
-- comments: edge detector (Mealy FSM)
--

library ieee;
use ieee.std_logic_1164.all;

entity edge_detector is
port ( din   : in  std_logic;
       clk   : in  std_logic;
       rst_n : in  std_logic;
       dout  : out std_logic
     );

end edge_detector;

architecture rtl of edge_detector is
type state_t is (zero, one);
signal state, next_state : state_t;
signal pulse : std_logic;

begin
 
  the_machine: process(din,state)
  begin

    -- defaults  
    next_state <= zero;
    pulse      <= '0';

    case state is
      when zero =>
        if (din = '0') then
          next_state <= zero;
        else
          next_state <= one;
          pulse      <= '1';
        end if;
      when one =>
        if (din = '0') then
          next_state <= zero;
          -- We only want a positive edge detector JRW
          pulse      <= '0';
        else
          next_state <= one;
        end if;
     when others =>
       -- do nothing
   end case; 
  end process the_machine;
    
  the_registers: process(clk, rst_n)
  begin
    if (rst_n = '0') then
      state <= zero;
    elsif (clk='1' and clk'event) then
      state <= next_state;
    end if;
  end process the_registers;

  --dummy assignment
  dout <= pulse;
end rtl;

