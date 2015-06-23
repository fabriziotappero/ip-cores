library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;


entity psram_off_iob is
  port (
    off_d   : in  std_logic;
    off_q   : out std_logic;
    off_clk : in  std_logic);
end psram_off_iob;


architecture rtl of psram_off_iob is
  attribute iob                       : string;
  attribute iob of psram_off_iob : label is "true";
  
begin  -- rtl

-- off
  psram_off_iob : FDRSE
    generic map (
      INIT => '1')    -- Initial value of register ('0' or '1')  
    port map (
      Q  => off_q,                      -- Data output
      C  => off_clk,                    -- Clock input
      CE => '1',                        -- Clock enable input
      D  => off_d,                      -- Data input
      R  => '0',                        -- Synchronous reset input
      S  => '0'                         -- Synchronous set input
      );        


end rtl;
