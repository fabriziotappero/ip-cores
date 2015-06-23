library ieee;
use ieee.std_logic_1164.all;

package helpers_pkg is

  component regFileModel
    port
    (
      clr        : in  std_logic;
      clk        : in  std_logic;
      intAddress : in  std_logic_vector(7 downto 0);
      intWrData  : in  std_logic_vector(7 downto 0);
      intWrite   : in  std_logic;
      intRead    : in  std_logic;
      intRdData  : out std_logic_vector(7 downto 0));
  end component;

end helpers_pkg;
