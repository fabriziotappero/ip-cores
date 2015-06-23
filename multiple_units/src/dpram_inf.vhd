-- A parameterized, inferable, true dual-port, common-clock block RAM in VHDL.
-- Original file was taken from: http://danstrother.com/2010/09/11/inferring-rams-in-fpgas/
-- No license information were provided by the original author.
-- Minimal modifications were introduced by me to make it suitable for my sorter.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity dp_ram_scl is
  generic (
    DATA_WIDTH : integer := 72;
    ADDR_WIDTH : integer := 10
    );
  port (
-- common clock
    clk    : in  std_logic;
    -- Port A
    we_a   : in  std_logic;
    addr_a : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    data_a : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    q_a    : out std_logic_vector(DATA_WIDTH-1 downto 0);

    -- Port B
    we_b   : in  std_logic;
    addr_b : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    data_b : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    q_b    : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end dp_ram_scl;

architecture rtl of dp_ram_scl is
  -- Shared memory
  type mem_type is array ((2**ADDR_WIDTH)-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
  shared variable mem : mem_type;
begin

-- Port A
  process(clk)
  begin
    if(clk'event and clk = '1') then
      if(we_a = '1') then
        mem(conv_integer(addr_a)) := data_a;
      end if;
      q_a <= mem(conv_integer(addr_a));
    end if;
  end process;

-- Port B
  process(clk)
  begin
    if(clk'event and clk = '1') then
      if(we_b = '1') then
        mem(conv_integer(addr_b)) := data_b;
      end if;
      q_b <= mem(conv_integer(addr_b));
    end if;
  end process;

end rtl;
