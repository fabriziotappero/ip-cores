library ieee;
library generics;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use generics.components.all;
use work.design_top_constants.all;

entity design_top_tb is
  port(
    clk      : out   std_logic_vector(1 downto 0);
    rstN     : out   std_logic_vector(1 downto 0);
    cpu_cs1  : out   std_logic_vector(1 downto 0);
    cpu_cs2  : out   std_logic_vector(1 downto 0);
    cpu_cs3  : out   std_logic_vector(1 downto 0);
    cpu_we   : out   std_logic_vector(1 downto 0);
    cpu_a    : out   std_logic_vector(9 downto 0);
    cpu_d    : inout std_logic_vector(15 downto 0);
    cpu_irq4 : in    std_logic_vector(1 downto 0);
    cpu_irq7 : in    std_logic_vector(1 downto 0)
    );
end design_top_tb;

architecture behavior of design_top_tb is
  component cpu_sim is
    port(
      fname    : in    filename;
      clk      : out   std_logic;
      rstN     : out   std_logic;
      cpu_cs1  : out   std_logic;
      cpu_cs2  : out   std_logic;
      cpu_cs3  : out   std_logic;
      cpu_we   : out   std_logic;
      cpu_a    : out   std_logic_vector(4 downto 0);
      cpu_d    : inout std_logic_vector(7 downto 0);
      cpu_irq4 : in    std_logic;
      cpu_irq7 : in    std_logic
      );
  end component;

  signal fnames : array2xfilename := (mk_filename("cpu1.txt"), mk_filename("cpu0.txt"));

begin
  gen_blocks : for i in 0 to 1 generate
    cpu_sim_inst : cpu_sim port map(
      fname    => fnames(i),
      clk      => clk(i),
      rstN     => rstN(i),
      cpu_cs1  => cpu_cs1(i),
      cpu_cs2  => cpu_cs2(i),
      cpu_cs3  => cpu_cs3(i),
      cpu_we   => cpu_we(i),
      cpu_a    => cpu_a(i * 5 + 4 downto i * 5),
      cpu_d    => cpu_d(i * 8 + 7 downto i * 8),
      cpu_irq4 => cpu_irq4(i),
      cpu_irq7 => cpu_irq7(i)
      );
  end generate gen_blocks;
end;
