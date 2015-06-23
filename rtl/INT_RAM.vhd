-- ########################################################
-- #            << ATLAS Project - Demo RAM >>            #
-- # **************************************************** #
-- #  Core-compatible example RAM component.              #
-- # **************************************************** #
-- #  Last modified: 28.11.2014                           #
-- # **************************************************** #
-- #  by Stephan Nolting 4788, Hanover, Germany           #
-- ########################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.atlas_core_package.all;

entity int_ram is
  generic	(
        mem_size_g : natural := 256 -- memory size in bytes
      );
  port	(
        -- host interface --
        clk_i   : in  std_ulogic; -- global clock line
        i_adr_i : in  std_ulogic_vector(31 downto 0); -- instruction adr
        i_dat_o : out std_ulogic_vector(15 downto 0); -- instruction out
        d_en_i  : in  std_ulogic; -- access enable
        d_rw_i  : in  std_ulogic; -- read/write
        d_adr_i : in  std_ulogic_vector(31 downto 0); -- data adr
        d_dat_i : in  std_ulogic_vector(15 downto 0); -- data in
        d_dat_o : out std_ulogic_vector(15 downto 0)  -- data out
      );
end int_ram;

architecture int_ram_structure of int_ram is

  -- internal constants --
  constant log2_mem_size_c : natural := log2(mem_size_g/2); -- address width

  -- memory type --
  type int_mem_file_t is array (0 to (mem_size_g/2)-1) of std_ulogic_vector(data_width_c-1 downto 0);

--	======================================================================
  signal mem_file : int_mem_file_t;   -- use this for implementation
--	signal mem_file : int_mem_file_t := -- use this for simulation
--	(
--        others => x"0000"  -- nop
--	);
--	======================================================================

  -- ram attribute to inhibit bypass-logic - altera only! --
  attribute ramstyle : string;
  attribute ramstyle of mem_file : signal is "no_rw_check";

begin

  -- Data Memory Access ----------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    mem_file_d_access: process(clk_i)
    begin
      if rising_edge(clk_i) then
        -- data read/write --
        if (d_en_i = '1') then -- valid access
          if (d_rw_i = '1') then -- write data access
            if (word_mode_en_c = true) then
              mem_file(to_integer(unsigned(d_adr_i(log2_mem_size_c-1 downto 0)))) <= d_dat_i;
            else
              mem_file(to_integer(unsigned(d_adr_i(log2_mem_size_c downto 1)))) <= d_dat_i;
            end if;
          end if;
        end if;
        if (word_mode_en_c = true) then
          d_dat_o <= mem_file(to_integer(unsigned(d_adr_i(log2_mem_size_c-1 downto 0))));
        else
          d_dat_o <= mem_file(to_integer(unsigned(d_adr_i(log2_mem_size_c downto 1))));
        end if;
      end if;
    end process mem_file_d_access;


  -- Instruction Memory Access ---------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    mem_file_i_access: process(clk_i)
    begin
      if rising_edge(clk_i) then
        -- instruction read --
        if (word_mode_en_c = true) then
          i_dat_o <= mem_file(to_integer(unsigned(i_adr_i(log2_mem_size_c-1 downto 0))));
        else
          i_dat_o <= mem_file(to_integer(unsigned(i_adr_i(log2_mem_size_c downto 1))));
        end if;
      end if;
    end process mem_file_i_access;



end int_ram_structure;
