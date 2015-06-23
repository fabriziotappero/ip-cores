library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity inv_control is
  generic (
    stage : natural:=3);

  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    Gen_state : in  std_logic_vector(2*stage+2 downto 0);
    inv       : out std_logic);
end inv_control;

architecture inv_control of inv_control is

  alias state   : std_logic_vector(2 downto 0) is Gen_state(2*stage+2 downto 2*stage);
  alias counter : std_logic_vector(2*stage-1 downto 0) is Gen_state(2*stage-1 downto 0);

begin

  process (clk, rst)
  begin  -- process
    if rst = '1' then                   -- asynchronous reset (active low)
      inv <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if (unsigned(state) = 0) or (unsigned(state) = 1 and unsigned(counter)< 4) then
        inv <= not(counter(1));
      else
		  inv <= '0';
      end if;
    end if;
  end process;

end inv_control;
