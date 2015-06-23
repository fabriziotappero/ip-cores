library ieee;
use ieee.std_logic_1164.all;

package i2c is

  component ParToI2s
    generic (
      SampleSize_g : natural);
    port (
      Clk_i           : in  std_ulogic;
      Reset_i         : in  std_ulogic;
      SampleLeft_i    : in  std_ulogic_vector(SampleSize_g - 1 downto 0);
      SampleRight_i   : in  std_ulogic_vector(SampleSize_g - 1 downto 0);
      StrobeLeft_i    : in  std_ulogic;
      StrobeRight_i   : in  std_ulogic;
      SampleAck_o     : out std_ulogic;
      WaitForSample_o : out std_ulogic;
      SClk_i          : in  std_ulogic;
      LRClk_i         : in  std_ulogic;
      SdnyData_o      : out std_ulogic);
  end component;

end i2c;
