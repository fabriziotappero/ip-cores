library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity serparser is
  port ( 
        clk : in  std_logic;
        rst : in  std_logic; 
		  a : in  std_logic;
        b : out std_logic);
end serparser;

architecture serparser of serparser is

  component parallel
    port (
      clk    : in  std_logic;
      rst    : in  std_logic;
      input  : in  std_logic;
      output : out std_logic_vector(1 downto 0));
  end component;

  component serial
    port (
      clk    : in  std_logic;
      rst    : in  std_logic;
      input  : in  std_logic_vector(1 downto 0);
      output : out std_logic);
  end component;

  signal aux : std_logic_vector(1 downto 0);

begin

  parallel_1 : parallel
    port map (
      clk    => clk,
      rst    => rst,
      input  => a,
      output => aux);

  serial_1 : serial
    port map (
      clk    => clk,
      rst    => rst,
      input  => aux,
      output => b);

end serparser;
