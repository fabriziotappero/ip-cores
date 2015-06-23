library ieee;
use ieee.std_logic_1164.all;

-- PREFIX: arith_xxx
package arith_cnt_comp is

-------------------------------------------------------------------------------


constant arith_cnt8_SZ : integer := 8;
constant arith_cnt8_BSZ : integer := 3;

type arith_cnt8_in is record
    data : std_logic_vector(arith_cnt8_SZ-1 downto 0);
end record;

type arith_cnt8_out is record
    res : std_logic_vector(arith_cnt8_BSZ-1 downto 0);
end record;

component arith_cnt8
port (
    rst    : in  std_logic;
    clk    : in  std_logic;
    si : in  arith_cnt8_in;
    so : out arith_cnt8_out
);
end component;




-------------------------------------------------------------------------------

  
end arith_cnt_comp;
