library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

entity mux_control is
  
  generic (
    stage : natural);

  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    Gen_state : in  std_logic_vector(8 downto 0);
    sel_mux   : out std_logic);
end mux_control;

architecture mux_control of mux_control is

  alias state   : std_logic_vector(2 downto 0) is Gen_state(2*stage+2 downto 2*stage);
  alias counter : std_logic_vector(2*stage-1 downto 0) is Gen_state(2*stage-1 downto 0);

begin

  process(clk, rst)
  begin
    if rst = '1' then
      sel_mux <= '0';
    elsif clk'event and clk = '1' then
      if unsigned(state) = 0 and unsigned(counter) = 1 then
        sel_mux <= '0';
      elsif unsigned(state) = 1 and unsigned(counter) = 1 then
        sel_mux <= '1';
      end if;
    end if;
  end process;

end mux_control;
