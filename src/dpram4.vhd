-- Simulation model of the dual port RAM (DP RAM) with single clock
-- and with "read-after-write" operation.
-- This file was combined from multiple descriptions and models of dual port RAMs
-- which I was able to find in the Internet and in the documentation provided
-- by vendors like Xilinx or Altera.
-- Therefore the only thing I can do is to publish it as PUBLIC DOMAIN
--
-- Please note, that for synthesis you should replace this file with
-- another DP RAM wrapper inferring the real DP RAM
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dp_ram_scl is

  generic
    (
      DATA_WIDTH : natural;
      ADDR_WIDTH : natural
      );

  port
    (
      clk    : in  std_logic;
      addr_a : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      addr_b : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      data_a : in  std_logic_vector((DATA_WIDTH-1) downto 0);
      data_b : in  std_logic_vector((DATA_WIDTH-1) downto 0);
      we_a   : in  std_logic := '1';
      we_b   : in  std_logic := '1';
      q_a    : out std_logic_vector((DATA_WIDTH -1) downto 0);
      q_b    : out std_logic_vector((DATA_WIDTH -1) downto 0)
      );

end dp_ram_scl;

architecture rtl of dp_ram_scl is

  signal    v_addr_a :  natural range 0 to 2**ADDR_WIDTH - 1;
  signal    v_addr_b :  natural range 0 to 2**ADDR_WIDTH - 1;
  subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
  type memory_t is array((2**ADDR_WIDTH-1) downto 0) of word_t;

  signal ram : memory_t := (others => x"33");  -- For debugging - initialize
                                               -- simulated RAM with x"33"

begin

  v_addr_a <= to_integer(unsigned(addr_a(ADDR_WIDTH-1 downto 0)));
  v_addr_b <= to_integer(unsigned(addr_b(ADDR_WIDTH-1 downto 0)));

  process(clk)
  begin

    if(rising_edge(clk)) then
      -- Port A
      if(we_a = '1') then
        ram(v_addr_a) <= data_a;
        -- read-after-write behavior
        q_a <= data_a;
      else
        -- simulate "unknown" value when the same address is written via one port
        -- and immediately read via another port
        if we_b='1' and v_addr_a=v_addr_b then
          q_a <= (others => 'X');
        else
          q_a <= ram(v_addr_a);          
        end if;
      end if;
      -- Port B 
      if(we_b = '1') then
        ram(v_addr_b) <= data_b;
        -- read-after-write behavior
        q_b         <= data_b;
      else
        -- simulate "unknown" value when the same address is written via one port
        -- and immediately read via another port
        if we_a='1' and v_addr_a=v_addr_b then
          q_b <= (others => 'X');
        else
          q_b <= ram(v_addr_b);          
        end if;
      end if;
    end if;
  end process;

end rtl;
