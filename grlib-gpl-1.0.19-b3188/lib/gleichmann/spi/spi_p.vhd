library ieee;
use ieee.std_logic_1164.all;

package spi is

  component spi_xmit
    generic (
      data_width : integer := 16);
    port (
      clk_i      : in  std_ulogic;
      rst_i      : in  std_ulogic;
      data_i     : in  std_logic_vector(data_width-1 downto 0);
      CODEC_SDIN : out std_ulogic;
      CODEC_CS   : out std_ulogic);
  end component;

end spi;
