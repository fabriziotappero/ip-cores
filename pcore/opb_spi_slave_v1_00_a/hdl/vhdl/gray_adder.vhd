-------------------------------------------------------------------------------
--* 
--* @short gray Adder
--* 
--* @generic width              with of adder vector
--*
--*    @author: Daniel Köthe
--*   @version: 1.0
--* @date:      2007-11-11
--/
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity gray_adder is
  generic (
    width : integer := 4);
  port (
    in_gray  : in  std_logic_vector(width-1 downto 0);
    out_gray : out std_logic_vector(width-1 downto 0));
end gray_adder;

architecture behavior of gray_adder is
  --* convert gray to bin
  component gray2bin
    generic (
      width : integer);
    port (
      in_gray : in  std_logic_vector(width-1 downto 0);
      out_bin : out std_logic_vector(width-1 downto 0));
  end component;
  --* convert bin to gray
  component bin2gray
    generic (
      width : integer);
    port (
      in_bin   : in  std_logic_vector(width-1 downto 0);
      out_gray : out std_logic_vector(width-1 downto 0));
  end component;

  signal out_bin : std_logic_vector(width-1 downto 0);
  signal bin_add : std_logic_vector(width-1 downto 0);
  
begin  -- behavior
  --* convert input gray signal to binary 
  gray2bin_1 : gray2bin
    generic map (
      width => width)
    port map (
      in_gray => in_gray,
      out_bin => out_bin);

  --* add one to signal
  bin_add <= out_bin + 1;
  --* convert signal back to gray 
  bin2gray_1 : bin2gray
    generic map (
      width => width)
    port map (
      in_bin   => bin_add,
      out_gray => out_gray);



end behavior;
