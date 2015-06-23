-- Dual port, single clock memory, inferrable in Xilinx and Altera FPGA

library ieee;
use ieee.std_logic_1164.all;

entity dp_ram_scl is
   
  generic
    (
      DATA_WIDTH : natural := 8;
      ADDR_WIDTH : natural := 6
      );

  port
    (
      clk    : in  std_logic;
      addr_a : in  natural range 0 to 2**ADDR_WIDTH - 1;
      addr_b : in  natural range 0 to 2**ADDR_WIDTH - 1;
      data_a : in  std_logic_vector((DATA_WIDTH-1) downto 0);
      data_b : in  std_logic_vector((DATA_WIDTH-1) downto 0);
      we_a   : in  std_logic := '1';
      we_b   : in  std_logic := '1';
      q_a    : out std_logic_vector((DATA_WIDTH -1) downto 0);
      q_b    : out std_logic_vector((DATA_WIDTH -1) downto 0)
      );

end dp_ram_scl;


architecture rtl of dp_ram_scl is

  -- Create a type for data word
  subtype data_word is std_logic_vector((DATA_WIDTH-1) downto 0);
  type ram_memory is array((2**ADDR_WIDTH-1) downto 0) of data_word;

  -- Declare the RAM variable.    
  shared variable ram : ram_memory;

begin

  process(clk)
  begin
    if(rising_edge(clk)) then
      -- Port B 
      if(we_b = '1') then
        ram(addr_b) := data_b;
      end if;
      q_b <= ram(addr_b);
    end if;
  end process;

  process(clk)
  begin
    if(rising_edge(clk)) then
      -- Port A
      if(we_a = '1') then
        ram(addr_a) := data_a;
      end if;
      q_a <= ram(addr_a);
    end if;
  end process;

end rtl;
