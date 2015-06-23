-- 10/24/2005
-- 16 bit register

library ieee;
use ieee.std_logic_1164.all;

entity reg is port(
  d    : in std_logic_vector(15 downto 0);
  clk  : in std_logic;
  wr_en: in std_logic;
  q    : out std_logic_vector(15 downto 0)
  );
end reg;

architecture reg_arch of reg is

  signal temp_q : std_logic_vector(15 downto 0) := x"0000";
  
begin
  process(clk, wr_en, d)
  begin
    if (clk'event and clk='1') then
      if wr_en = '1' then
        temp_q <= d;
      end if;
    end if;
  end process;

  -- concurrent assignment
  q <= temp_q;
  
end reg_arch;
