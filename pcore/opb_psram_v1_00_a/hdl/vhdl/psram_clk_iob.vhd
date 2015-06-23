library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;


entity psram_clk_iob is
  port (
    clk    : in  std_logic;
    clk_en : in  std_logic;
    clk_q  : out std_logic);
end psram_clk_iob;


architecture rtl of psram_clk_iob is
  signal c0         : std_logic;
  signal c1         : std_logic;
  signal clk_en_inv : std_logic;


  attribute iob                 : string;
  attribute iob of psram_clk_iob : label is "true";
  
begin  -- rtl

  c0         <= clk;
  c1         <= not clk;
  clk_en_inv <= not clk_en;


  -- clock output register
  psram_clk_iob : FDDRRSE
    port map (
      Q  => clk_Q,       -- Data output (connect directly to top-level port)
      C0 => c0,                         -- 0 degree clock input
      C1 => c1,                         -- 180 degree clock input
      CE => '1',                        -- Clock enable input
      D0 => '1',                        -- Posedge data input
      D1 => '0',                        -- Negedge data input
      R  => clk_en_inv,                 -- Synchronous reset input
      S  => '0'                         -- Synchronous preset input
      );



end rtl;
