library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.leval_package.all;

entity pc_incer is
  port(
    clk       : in std_logic;
    rst				   : in std_logic;
    pause				 : in std_logic;
    offset			 : in std_logic_vector(MC_ADDR_SIZE - 1 downto 0);
    branch   	: in std_logic;
    pc_next		 : out std_logic_vector(MC_ADDR_SIZE - 1 downto 0) );
end entity;

architecture behav of pc_incer is
  signal pc_reg : std_logic_vector(MC_ADDR_SIZE-1 downto 0) := (others => '0');
begin
  pc_next <= pc_reg;
  pc_inc : process(clk, rst)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        pc_reg <= (others => '0');
      elsif pause = '1' then
        if branch = '1' then
          pc_reg <= offset;
        elsif pc_reg > "1010111111111" then
          pc_reg <= (others => '0');
        else
          pc_reg <= pc_reg + 1;
        end if;
      end if;
    end if;
  end process pc_inc;
end architecture behav;
