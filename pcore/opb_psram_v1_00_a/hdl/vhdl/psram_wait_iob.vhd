library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;


entity psram_wait_iob is
  
  port (
    iff_d   : in  std_logic;
    iff_q   : out std_logic;
    iff_clk : in  std_logic;
    iff_en  : in  std_logic);
end psram_wait_iob;


architecture rtl of psram_wait_iob is
  attribute iob                       : string;
  attribute iob of psram_wait_iob_iff : label is "true";
  
begin  -- rtl

-- iff
  psram_wait_iob_iff : FDRSE
    generic map (
      INIT => '0')    -- Initial value of register ('0' or '1')  
    port map (
      Q  => iff_q,                      -- Data output
      C  => iff_clk,                    -- Clock input
      CE => '1',                        -- Clock enable input
      D  => iff_d,                      -- Data input
      R  => '0',                        -- Synchronous reset input
      S  => iff_en                      -- Synchronous set input
      );  


end rtl;
