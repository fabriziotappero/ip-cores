--
--  Synchronous two-port RAM with separate clocks for read and write ports.
--  The synthesizer for Xilinx Spartan-3 will infer Block RAM for this entity.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spwram is

    generic (
        abits:      integer;
        dbits:      integer );

    port (
        rclk:       in  std_logic;
        wclk:       in  std_logic;
        ren:        in  std_logic;
        raddr:      in  std_logic_vector(abits-1 downto 0);
        rdata:      out std_logic_vector(dbits-1 downto 0);
        wen:        in  std_logic;
        waddr:      in  std_logic_vector(abits-1 downto 0);
        wdata:      in  std_logic_vector(dbits-1 downto 0) );

end entity spwram;

architecture spwram_arch of spwram is

    type mem_type is array(0 to (2**abits - 1)) of
                     std_logic_vector(dbits-1 downto 0);

    signal s_mem:   mem_type;

begin

    -- read process
    process (rclk) is
    begin
        if rising_edge(rclk) then
            if ren = '1' then
                rdata <= s_mem(to_integer(unsigned(raddr)));
            end if;
        end if;
    end process;

    -- write process
    process (wclk) is
    begin
        if rising_edge(wclk) then
            if wen = '1' then
                s_mem(to_integer(unsigned(waddr))) <= wdata;
            end if;
        end if;
    end process;

end architecture;

