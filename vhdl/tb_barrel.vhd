-------------------------------------------------------------------------------
-- File: tb_barrel.vhd
-- Author: Jakob Lechner, Urban Stadler, Harald Trinkl, Christian Walter
-- Created: 2007-01-24
-- Last updated: 2006-11-29

-- Description:
-- Execute stage
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity tb_barrel_vhd is
end tb_barrel_vhd;

architecture behavior of tb_barrel_vhd is

  -- Component Declaration for the Unit Under Test (UUT)
  component barrel_shifter
    port(
      reg_a      : in  std_logic_vector(15 downto 0);
      reg_b      : in  std_logic_vector(15 downto 0);
      left       : in  std_logic;
      arithmetic : in  std_logic;
      reg_q      : out std_logic_vector(15 downto 0)
      );
  end component;

  --Inputs
  signal left       : std_logic                     := '0';
  signal arithmetic : std_logic                     := '0';
  signal reg_a      : std_logic_vector(15 downto 0) := (others => '0');
  signal reg_b      : std_logic_vector(15 downto 0) := (others => '0');

  --Outputs
  signal reg_q : std_logic_vector(15 downto 0);

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : barrel_shifter port map(
    reg_a      => reg_a,
    reg_b      => reg_b,
    left       => left,
    arithmetic => arithmetic,
    reg_q      => reg_q
    );

  tb : process
  begin

    -- Wait 100 ns for global reset to finish
    wait for 100 ns;

    -- shift left one bit
    left       <= '1';
    arithmetic <= '0';
    reg_a      <= x"0020";
    reg_b      <= x"0001";
    wait for 10 ns;
    assert reg_q = x"0040";

    -- shift left four bits
    left       <= '1';
    arithmetic <= '0';
    reg_a      <= x"0021";
    reg_b      <= x"0004";
    wait for 10 ns;
    assert reg_q = x"0210";

    -- shift right two bits
    left       <= '0';
    arithmetic <= '0';
    reg_a      <= x"0300";
    reg_b      <= x"0002";
    wait for 10 ns;
    assert reg_q = x"00C0";

    -- shift right two bits with arithmetic shift
    left       <= '0';
    arithmetic <= '1';
    reg_a      <= x"8010";
    reg_b      <= x"0002";
    wait for 10 ns;
    assert reg_q = x"E004";
    wait;                               -- will wait forever
    
  end process;

end;
