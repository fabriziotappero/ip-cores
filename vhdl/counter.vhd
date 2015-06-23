
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity counter is
  
  generic (
    stage : natural := 3);

  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    mem_ready : in  std_logic;
    mem_bk : out std_logic;
    count      : out std_logic_vector(2*stage+2 downto 0));

end counter;

architecture counter of counter is

signal aux_mem_bk : std_logic;
signal count_aux : std_logic_vector(2*stage+2 downto 0);
constant max_count : std_logic_vector(2*stage+2 downto 0) := conv_std_logic_vector(stage-1,3)&conv_std_logic_vector(-1,2*stage);

  
begin
  count <=  count_aux;
  mem_bk <= aux_mem_bk;

process (clk, rst)
    variable initialize : std_logic_vector(1 downto 0);
  begin  -- process
    if rst = '1' then                   -- asynchronous reset (active low)
      count_aux <= max_count;
		aux_mem_bk <= '1';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if count_aux = max_count then
        if mem_ready = '1' then
          aux_mem_bk <= not(aux_mem_bk);        
          count_aux <= (others => '0');
        end if;
      else
        count_aux <= count_aux + 1;
      end if;
    end if;
  end process;

end counter;
