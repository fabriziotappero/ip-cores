library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity async_dpram is
  
  generic (
    addrw_g : integer := 0;
    dataw_g : integer := 0);

  port (
    rd_clk, wr_clk         : in  std_logic;
    wr_en_in               : in  std_logic;
    data_in                : in  std_logic_vector(dataw_g-1 downto 0);
    data_out               : out std_logic_vector(dataw_g-1 downto 0);
    rd_addr_in, wr_addr_in : in  std_logic_vector (addrw_g-1 downto 0));

end entity async_dpram;
