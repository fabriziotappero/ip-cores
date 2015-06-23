-- ########################################################
-- #         << ATLAS Project - Memory Gateway >>         #
-- # **************************************************** #
-- #  Gateway between CPU instruction/data interface and  #
-- #  bootloader ROM / memory/IO bus system.              #
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

entity mem_gate is
  port	(
        -- host interface --
        clk_i           : in  std_ulogic; -- global clock line
        rst_i           : in  std_ulogic; -- global reset line, sync, high-active

        i_adr_i         : in  std_ulogic_vector(15 downto 0); -- instruction adr
        i_dat_o         : out std_ulogic_vector(15 downto 0); -- instruction out
        d_req_i         : in  std_ulogic; -- request access in next cycle
        d_rw_i          : in  std_ulogic; -- read/write
        d_adr_i         : in  std_ulogic_vector(15 downto 0); -- data adr
        d_dat_i         : in  std_ulogic_vector(15 downto 0); -- data in
        d_dat_o         : out std_ulogic_vector(15 downto 0); -- data out
        mem_ip_adr_i    : in  std_ulogic_vector(15 downto 0); -- instruction page
        mem_dp_adr_i    : in  std_ulogic_vector(15 downto 0); -- data page

        -- boot rom interface --
        boot_i_adr_o    : out std_ulogic_vector(15 downto 0); -- instruction adr
        boot_i_dat_i    : in  std_ulogic_vector(15 downto 0); -- instruction out
        boot_d_en_o     : out std_ulogic; -- access enable
        boot_d_rw_o     : out std_ulogic; -- read/write
        boot_d_adr_o    : out std_ulogic_vector(15 downto 0); -- data adr
        boot_d_dat_o    : out std_ulogic_vector(15 downto 0); -- data in
        boot_d_dat_i    : in  std_ulogic_vector(15 downto 0); -- data out

        -- memory interface --
        mem_i_page_o    : out std_ulogic_vector(15 downto 0); -- instruction page
        mem_i_adr_o     : out std_ulogic_vector(15 downto 0); -- instruction adr
        mem_i_dat_i     : in  std_ulogic_vector(15 downto 0); -- instruction out
        mem_d_en_o      : out std_ulogic; -- access enable
        mem_d_rw_o      : out std_ulogic; -- read/write
        mem_d_page_o    : out std_ulogic_vector(15 downto 0); -- data page
        mem_d_adr_o     : out std_ulogic_vector(15 downto 0); -- data adr
        mem_d_dat_o     : out std_ulogic_vector(15 downto 0); -- data in
        mem_d_dat_i     : in  std_ulogic_vector(15 downto 0)  -- data out
      );
end mem_gate;

architecture mem_gate_behav of mem_gate is

  -- local signals --
  signal mem_dacc_ff : std_ulogic;
  signal d_gate_sel  : std_ulogic;
  signal i_gate_sel  : std_ulogic;

begin

  -- Gateway ---------------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    mem_acc_flag: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          mem_dacc_ff <= '0';
        else
          mem_dacc_ff <= d_req_i;
        end if;
      end if;
    end process mem_acc_flag;

    -- switch --
    i_gate_sel   <= '1' when (mem_ip_adr_i(15) = boot_page_c(15)) else '0';
    d_gate_sel   <= '1' when (mem_dp_adr_i(15) = boot_page_c(15)) else '0';

    -- bootloader rom --
    boot_i_adr_o <= i_adr_i;
    boot_d_en_o  <= mem_dacc_ff when (d_gate_sel = '1') else '0';
    boot_d_adr_o <= d_adr_i when (mem_dacc_ff = '1') and (d_gate_sel = '1') else (others => '0'); -- to reduce switching activity
    boot_d_dat_o <= d_dat_i when (mem_dacc_ff = '1') and (d_gate_sel = '1') else (others => '0'); -- to reduce switching activity
    boot_d_rw_o  <= d_rw_i;

    -- memory system --
    mem_i_page_o <= '0' & mem_ip_adr_i(14 downto 0);
    mem_i_adr_o  <= i_adr_i;
    mem_d_en_o   <= mem_dacc_ff when (d_gate_sel = '0') else '0';
    mem_d_page_o <= '0' & mem_dp_adr_i(14 downto 0);
    mem_d_adr_o  <= d_adr_i when (mem_dacc_ff = '1') and (d_gate_sel = '0') else (others => '0'); -- to reduce switching activity
    mem_d_dat_o  <= d_dat_i when (mem_dacc_ff = '1') and (d_gate_sel = '0') else (others => '0'); -- to reduce switching activity
    mem_d_rw_o   <= d_rw_i;

    -- cpu --
    i_dat_o      <= boot_i_dat_i when (i_gate_sel = '1') else mem_i_dat_i;
    d_dat_o      <= boot_d_dat_i when (d_gate_sel = '1') else mem_d_dat_i;



end mem_gate_behav;
