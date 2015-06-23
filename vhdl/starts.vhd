library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

entity starts is
  generic (
    stage : natural);

  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    Gen_state   : in  std_logic_vector(2*stage+2 downto 0);
    factorstart : out std_logic;
    cfft4start  : out std_logic);
end starts;

architecture starts of starts is

  alias state   : std_logic_vector(2 downto 0) is Gen_state(2*stage+2 downto 2*stage);
  alias counter : std_logic_vector(2*stage-1 downto 0) is Gen_state(2*stage-1 downto 0);

begin

  process( clk, rst )
  begin
    if rst = '1' then
      factorstart <= '0';
      cfft4start  <= '0';
    elsif clk'event and clk = '1' then
      if unsigned(state) = 0 and unsigned(counter) = 2 then
        cfft4start <= '1';
      else
        cfft4start <= '0';
      end if;
      if unsigned(state) = 0 and unsigned(counter) = 8 then
        factorstart <= '1';
      else
        factorstart <= '0';
      end if;
    end if;
  end process;

end starts;
