-- File: ex_stage.vhd
-- Author: Jakob Lechner, Urban Stadler, Harald Trinkl, Christian Walter
-- Created: 2006-11-29
-- Last updated: 2006-11-29

-- Description:
-- Execute stage
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.rise_pack.all;
use work.RISE_PACK_SPECIFIC.all;

entity tb_rise_vhd is
end tb_rise_vhd;

architecture behavior of tb_rise_vhd is

  component rise
    port(
      clk   : in  std_logic;
      reset : in  std_logic;
      rx    : in  std_logic;
      tx    : out std_logic
      );
  end component;

  --Inputs
  signal clk   : std_logic := '0';
  signal reset : std_logic := '0';
  signal rx    : std_logic := '1';

  --Outputs
  signal tx : std_logic;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : rise port map(
    clk   => clk,
    reset => reset,
    rx    => rx,
    tx    => tx
    );

  clk_gen : process
  begin
    clk <= '1';
    wait for 10 ns;
    clk <= '0';
    wait for 10 ns;
  end process;

  tb : process
  begin

    wait for 5 ns;

    -- Place stimulus here
    reset <= '1';

    -- Let the simulation run for 200 ns;
    wait for 200 ns;

    rx <= '0';                          --startbit
    wait for 8600 ns;                   -- zellenzeit 8,6 us
    rx <= '0';                          -- 8 datenbits
    wait for 8600ns;
    rx <= '1';                          -- 8 datenbits
    wait for 8600ns;
    rx <= '0';                          -- 8 datenbits
    wait for 8600ns;
    rx <= '0';                          -- 8 datenbits
    wait for 8600ns;
    rx <= '0';                          -- 8 datenbits
    wait for 8600ns;
    rx <= '1';                          -- 8 datenbits
    wait for 8600ns;
    rx <= '1';                          -- 8 datenbits
    wait for 8600ns;
    rx <= '0';                          -- 8 datenbits
    wait for 8600ns;
    rx <= '1';                          -- 8 stopbit
    wait for 8600ns;

    wait for 20us;

    -- send a 'CR' = 0x0A
    rx <= '0';                          -- 8 startbit
    wait for 8600ns;
    rx <= '0';                          -- 8 datenbits
    wait for 8600ns;
    rx <= '1';                          -- 8 datenbits
    wait for 8600ns;
    rx <= '0';                          -- 8 datenbits
    wait for 8600ns;
    rx <= '1';                          -- 8 datenbits
    wait for 8600ns;
    rx <= '0';                          -- 8 datenbits
    wait for 8600ns;
    rx <= '0';                          -- 8 datenbits
    wait for 8600ns;
    rx <= '0';                          -- 8 datenbits
    wait for 8600ns;
    rx <= '0';                          -- 8 datenbits
    wait for 8600ns;
    rx <= '1';                          -- 8 stopbit
    wait for 8600ns;

    wait;
  end process;

end;
