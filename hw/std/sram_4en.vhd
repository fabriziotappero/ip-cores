----------------------------------------------------------------------------------------------
--
--      Input file         : sram_4en.vhd
--      Design name        : sram_4en
--      Author             : Tamar Kranenburg
--      Company            : Delft University of Technology
--                         : Faculty EEMCS, Department ME&CE
--                         : Systems and Circuits group
--
--      Description          : Single Port Synchronous Random Access Memory with 4 write enable
--                             ports.
--      Architecture 'arch'  : Default implementation
--      Architecture 'arch2' : Alternative implementation
--
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library mblite;
use mblite.std_Pkg.all;

entity sram_4en is generic
(
    WIDTH : positive := 32;
    SIZE  : positive := 16
);
port
(
    dat_o : out std_logic_vector(WIDTH - 1 downto 0);
    dat_i : in std_logic_vector(WIDTH - 1 downto 0);
    adr_i : in std_logic_vector(SIZE - 1 downto 0);
    wre_i : in std_logic_vector(WIDTH/8 - 1 downto 0);
    ena_i : in std_logic;
    clk_i : in std_logic
);
end sram_4en;

-- Although this memory is very easy to use in conjunction with Modelsims mem load, it is not
-- supported by many devices (although it comes straight from the library. Many devices give
-- cryptic synthesization errors on this implementation, so it is not the default.
architecture arch2 of sram_4en is

    type ram_type is array(2 ** SIZE - 1 downto 0) of std_logic_vector(WIDTH - 1 downto 0);
    type sel_type is array(WIDTH/8 - 1 downto 0) of std_logic_vector(7 downto 0);

    signal ram: ram_type;
    signal di: sel_type;
begin
    process(wre_i, dat_i, adr_i)
    begin
        for i in 0 to WIDTH/8 - 1 loop
            if wre_i(i) = '1' then
                di(i) <= dat_i((i+1)*8 - 1 downto i*8);
            else
                di(i) <= ram(my_conv_integer(adr_i))((i+1)*8 - 1 downto i*8);
            end if;
        end loop;
    end process;

    process(clk_i)
    begin
        if rising_edge(clk_i) then
            if ena_i = '1' then
                ram(my_conv_integer(adr_i)) <= di(3) & di(2) & di(1) & di(0);
                dat_o <= di(3) & di(2) & di(1) & di(0);
            end if;
        end if;
    end process;
end arch2;

-- Less convenient but very general memory block with four separate write
-- enable signals. (4x8 bit)
architecture arch of sram_4en is
begin
   mem: for i in 0 to WIDTH/8 - 1 generate
       mem : sram generic map
       (
           WIDTH   => 8,
           SIZE    => SIZE
       )
       port map
       (
           dat_o   => dat_o((i+1)*8 - 1 downto i*8),
           dat_i   => dat_i((i+1)*8 - 1 downto i*8),
           adr_i   => adr_i,
           wre_i   => wre_i(i),
           ena_i   => ena_i,
           clk_i   => clk_i
       );
   end generate;
end arch;
