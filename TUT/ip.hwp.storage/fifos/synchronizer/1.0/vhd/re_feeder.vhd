-- Simple block to test Synchronizer, no real testbench included.
-- tested on FPGA.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity re_feeder is
  generic (
    pulse_width_g : integer := 8
    );
  port (
    clk : in  std_logic;
    rst_n  : in  std_logic;
    re_out : out std_logic
    );

end re_feeder;

architecture rtl of re_feeder is
  signal counter_r : integer range 0 to pulse_width_g-1 ;
  signal re_r : std_logic;
begin  -- rtl

  re_out <= re_r;
  
  process (clk, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      counter_r <= 0;
      re_r <= '0';
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      if counter_r = pulse_width_g-1 then
        re_r <= not re_r;
        counter_r <= 0;
      else
        re_r <= re_r;
        counter_r <= counter_r+1;
      end if;
    end if;
  end process;
  

end rtl;
