-------------------------------------------------------------------------------
--
-- The testbench for t48_core.
--
-- $Id: tb.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-- The latest version of this file can be found at:
--      http://www.opencores.org/cvsweb.shtml/t48/
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb is

end tb;


use work.t48_core_comp_pack.all;

use work.t48_tb_pack.all;

architecture behav of tb is

  -- clock period, 11 MHz
  constant period_c : time := 90 ns;

  component if_timing
    port(
      xtal_i   : in std_logic;
      ale_i    : in std_logic;
      psen_n_i : in std_logic;
      rd_n_i   : in std_logic;
      wr_n_i   : in std_logic;
      prog_n_i : in std_logic;
      db_bus_i : in std_logic_vector(7 downto 0);
      p2_i     : in std_logic_vector(7 downto 0)
    );
  end component;

  component lpm_rom
    generic (
      LPM_WIDTH           : positive;
      LPM_TYPE            : string    := "LPM_ROM";
      LPM_WIDTHAD         : positive;
      LPM_NUMWORDS        : natural   := 0;
      LPM_FILE            : string;
      LPM_ADDRESS_CONTROL : string    := "REGISTERED";
      LPM_OUTDATA         : string    := "REGISTERED";
      LPM_HINT            : string    := "UNUSED"
    );
    port (
      address             : in  std_logic_vector(LPM_WIDTHAD-1 downto 0);
      inclock             : in  std_logic;
      outclock            : in  std_logic;
      memenab             : in  std_logic;
      q                   : out std_logic_vector(LPM_WIDTH-1 downto 0)
    );
  end component;

  signal xtal_s          : std_logic;
  signal xtal_n_s        : std_logic;
  signal res_n_s         : std_logic;
  signal xtal3_s         : std_logic;
  signal int_n_s         : std_logic;
  signal ale_s           : std_logic;
  signal rom_addr_s      : std_logic_vector(11 downto 0);
  signal rom_data_s      : std_logic_vector( 7 downto 0);
  signal ram_data_to_s   : std_logic_vector( 7 downto 0);
  signal ram_data_from_s : std_logic_vector( 7 downto 0);
  signal ram_addr_s      : std_logic_vector( 7 downto 0);
  signal ram_we_s        : std_logic;

  signal p1_s            : std_logic_vector( 7 downto 0);
  signal t48_p1_s        : std_logic_vector( 7 downto 0);
  signal p1_low_imp_s    : std_logic;
  signal p2_s            : std_logic_vector( 7 downto 0);
  signal t48_p2_s        : std_logic_vector( 7 downto 0);
  signal p2l_low_imp_s   : std_logic;
  signal p2h_low_imp_s   : std_logic;
  signal psen_n_s        : std_logic;
  signal prog_n_s        : std_logic;

  signal bus_s           : std_logic_vector( 7 downto 0);
  signal t48_bus_s       : std_logic_vector( 7 downto 0);
  signal bus_dir_s       : std_logic;

  signal ext_mem_addr_q      : std_logic_vector( 7 downto 0);
  signal ext_ram_data_from_s : std_logic_vector( 7 downto 0);
  signal ext_ram_we_q        : std_logic;
  signal rd_n_s              : std_logic;
  signal wr_n_s              : std_logic;

  signal ext_rom_data_s  : std_logic_vector( 7 downto 0);
  signal ext_rom_addr_s  : std_logic_vector(11 downto 0);

  signal tb_p1_q : std_logic_vector( 7 downto 0);
  signal tb_p2_q : std_logic_vector( 7 downto 0);

  signal ext_mem_sel_we_q : boolean;
  signal ena_ext_ram_q    : boolean;
  signal ena_tb_periph_q  : boolean;

  signal zero_s          : std_logic;
  signal one_s           : std_logic;
  signal zero_byte_s     : std_logic_vector( 7 downto 0);

begin

  zero_s      <= '0';
  one_s       <= '1';
  zero_byte_s <= (others => '0');

  -----------------------------------------------------------------------------
  -- Internal ROM, 2k bytes
  -- Initialized by file rom_t49.hex.
  -----------------------------------------------------------------------------
  rom_internal_2k : lpm_rom
    generic map (
      LPM_WIDTH           => 8,
      LPM_TYPE            => "LPM_ROM",
      LPM_WIDTHAD         => 11,
      LPM_NUMWORDS        => 2 ** 11,
      LPM_FILE            => "rom_t49.hex",
      LPM_ADDRESS_CONTROL => "REGISTERED",
      LPM_OUTDATA         => "UNREGISTERED",
      LPM_HINT            => "UNUSED"
    )
    port map (
      address  => rom_addr_s(10 downto 0),
      inclock  => xtal_s,
      outclock => zero_s,               -- unused
      memenab  => one_s,
      q        => rom_data_s
    );

  -----------------------------------------------------------------------------
  -- External ROM, 2k bytes
  -- Initialized by file rom_t49_ext.hex.
  -----------------------------------------------------------------------------
  ext_rom_addr_s(11 downto 8) <= t48_p2_s(3 downto 0);
  ext_rom_addr_s( 7 downto 0) <= ext_mem_addr_q;
  rom_external_2k : lpm_rom
    generic map (
      LPM_WIDTH           => 8,
      LPM_TYPE            => "LPM_ROM",
      LPM_WIDTHAD         => 11,
      LPM_NUMWORDS        => 2 ** 11,
      LPM_FILE            => "rom_t49_ext.hex",
      LPM_ADDRESS_CONTROL => "REGISTERED",
      LPM_OUTDATA         => "UNREGISTERED",
      LPM_HINT            => "UNUSED"
    )
    port map (
      address  => ext_rom_addr_s(10 downto 0),
      inclock  => xtal_s,
      outclock => zero_s,               -- unused
      memenab  => one_s,
      q        => ext_rom_data_s
    );

  -----------------------------------------------------------------------------
  -- Internal RAM, 256 bytes
  -----------------------------------------------------------------------------
  ram_256 : generic_ram_ena
    generic map (
      addr_width_g => 8,
      data_width_g => 8
    )
    port map (
      clk_i => xtal_s,
      a_i   => ram_addr_s,
      we_i  => ram_we_s,
      ena_i => one_s,
      d_i   => ram_data_to_s,
      d_o   => ram_data_from_s
    );

  -----------------------------------------------------------------------------
  -- External RAM, 256 bytes
  -----------------------------------------------------------------------------
  ext_ram_b : generic_ram_ena
    generic map (
      addr_width_g => 8,
      data_width_g => 8
    )
    port map (
      clk_i => xtal_s,
      a_i   => ext_mem_addr_q,
      we_i  => ext_ram_we_q,
      ena_i => one_s,
      d_i   => bus_s,
      d_o   => ext_ram_data_from_s
    );

  t48_core_b : t48_core
    generic map (
      xtal_div_3_g        => 1,
      register_mnemonic_g => 1,
      include_port1_g     => 1,
      include_port2_g     => 1,
      include_bus_g       => 1,
      include_timer_g     => 1,
      sample_t1_state_g   => 4
    )
    port map (
      xtal_i        => xtal_s,
      xtal_en_i     => one_s,
      reset_i       => res_n_s,
      t0_i          => p1_s(0),
      t0_o          => open,
      t0_dir_o      => open,
      int_n_i       => int_n_s,
      ea_i          => rom_addr_s(11),
      rd_n_o        => rd_n_s,
      psen_n_o      => psen_n_s,
      wr_n_o        => wr_n_s,
      ale_o         => ale_s,
      db_i          => bus_s,
      db_o          => t48_bus_s,
      db_dir_o      => bus_dir_s,
      t1_i          => p1_s(1),
      p2_i          => p2_s,
      p2_o          => t48_p2_s,
      p2l_low_imp_o => p2l_low_imp_s,
      p2h_low_imp_o => p2h_low_imp_s,
      p1_i          => p1_s,
      p1_o          => t48_p1_s,
      p1_low_imp_o  => p1_low_imp_s,
      prog_n_o      => prog_n_s,
      clk_i         => xtal_s,
      en_clk_i      => xtal3_s,
      xtal3_o       => xtal3_s,
      dmem_addr_o   => ram_addr_s,
      dmem_we_o     => ram_we_s,
      dmem_data_i   => ram_data_from_s,
      dmem_data_o   => ram_data_to_s,
      pmem_addr_o   => rom_addr_s,
      pmem_data_i   => rom_data_s
    );

  if_timing_b : if_timing
    port map (
      xtal_i   => xtal_s,
      ale_i    => ale_s,
      psen_n_i => psen_n_s,
      rd_n_i   => rd_n_s,
      wr_n_i   => wr_n_s,
      prog_n_i => prog_n_s,
      db_bus_i => bus_s,
      p2_i     => t48_p2_s
    );


  -----------------------------------------------------------------------------
  -- Port logic
  --
  ports: process (t48_p1_s,
                  p1_low_imp_s,
                  t48_p2_s,
                  p2l_low_imp_s,
                  p2h_low_imp_s)
    function t48_port_f(t48_p   : std_logic_vector;
                        low_imp : std_logic) return std_logic_vector is
      variable p_v : std_logic_vector(t48_p'range);
    begin
      if low_imp = '1' then
        p_v := t48_p;

      else
        for i in p_v'range loop
          if t48_p(i) = '1' then
            p_v(i) := 'H';
          else
            p_v(i) := t48_p(i);
          end if;
        end loop;

      end if;

      return p_v;
    end;

  begin

    p1_s <= t48_port_f(t48_p   => t48_p1_s,
                       low_imp => p1_low_imp_s);

    p2_s(3 downto 0) <= t48_port_f(t48_p   => t48_p2_s(3 downto 0),
                                   low_imp => p2l_low_imp_s);
    p2_s(7 downto 4) <= t48_port_f(t48_p   => t48_p2_s(7 downto 4),
                                   low_imp => p2h_low_imp_s);

  end process ports;
  --
  -----------------------------------------------------------------------------

  bus_s <=   t48_bus_s
           when bus_dir_s = '1' else
             (others => 'Z');

  bus_s <=   ext_ram_data_from_s
           when rd_n_s = '0' and ena_ext_ram_q else
             (others => 'Z');

  bus_s <=   ext_rom_data_s
           when psen_n_s = '0' else
             (others => 'Z');


  -----------------------------------------------------------------------------
  -- External memory access signals
  --
  ext_mem: process (wr_n_s,
                    ext_mem_addr_q,
                    ena_ext_ram_q,
                    ale_s,
                    bus_s,
                    xtal_s)
  begin
    if ale_s'event and ale_s = '0' then
      if not is_X(bus_s) then
        ext_mem_addr_q <= bus_s;
      else
        ext_mem_addr_q <= (others => '0');
      end if;
    end if;

    if wr_n_s'event and wr_n_s = '1' then
      -- write enable for external RAM
      if ena_ext_ram_q then
        ext_ram_we_q <= '1';
      end if;

      -- process external memory selector
      if ext_mem_addr_q = "11111111" then
        ext_mem_sel_we_q <= true;
      end if;

    end if;

    if xtal_s'event and xtal_s = '1' then
      ext_ram_we_q     <= '0';
      ext_mem_sel_we_q <= false;
    end if;

  end process ext_mem;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process ext_mem_sel
  --
  -- Purpose:
  --   Select external memory address space.
  --   This is either
  --     + external RAM
  --     + testbench peripherals
  --
  ext_mem_sel: process (res_n_s, xtal_s)
  begin
    if res_n_s = '0' then
      ena_ext_ram_q       <= true;
      ena_tb_periph_q     <= false;

    elsif xtal_s'event and xtal_s = '1' then
      if ext_mem_sel_we_q then
        if bus_s(0) = '1' then
          ena_ext_ram_q   <= true;
        else
          ena_ext_ram_q   <= false;
        end if;

        if bus_s(1) = '1' then
          ena_tb_periph_q <= true;
        else
          ena_tb_periph_q <= false;
        end if;
      end if;

    end if;

  end process ext_mem_sel;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process tb_periph
  --
  -- Purpose:
  --   Implements the testbenc peripherals driving P1 and P2.
  --
  tb_periph: process (res_n_s, wr_n_s)

    function oc_f (pX : std_logic_vector) return std_logic_vector is
      variable r_v : std_logic_vector(pX'range);
    begin
      for i in pX'range loop
        if pX(i) = '0' then
          r_v(i) := '0';
        else
          r_v(i) := 'H';
        end if;
      end loop;

      return r_v;
    end;

  begin
    if res_n_s = '0' then
      tb_p1_q <= (others => 'H');
      tb_p2_q <= (others => 'H');

    elsif wr_n_s'event and wr_n_s = '1' then
      if ena_tb_periph_q then
        case ext_mem_addr_q is
          -- P1
          when "00000000" =>
            tb_p1_q <= oc_f(t48_bus_s);

          -- P2
          when "00000001" =>
            tb_p2_q <= oc_f(t48_bus_s);

          when others =>
            null;

        end case;

      end if;

    end if;

  end process tb_periph;
  --
  -----------------------------------------------------------------------------

  p1_s <= tb_p1_q;
  p2_s <= tb_p2_q;


  xtal_n_s <= not xtal_s;

  -----------------------------------------------------------------------------
  -- The clock generator
  --
  clk_gen: process
  begin
    xtal_s <= '0';
    wait for period_c/2;
    xtal_s <= '1';
    wait for period_c/2;
  end process clk_gen;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- The reset generator
  --
  res_gen: process
  begin
    res_n_s <= '0';
    wait for 5 * period_c;
    res_n_s <= '1';
    wait;
  end process res_gen;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- The interrupt generator
  --
  int_gen: process
  begin
    int_n_s <= '1';
    wait for 750 * period_c;
    int_n_s <= '0';
    wait for  45 * period_c;
  end process int_gen;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- End of simulation detection
  --
  eos: process
  begin

    outer: loop
      wait on tb_accu_s;
      if tb_accu_s = "10101010" then
        wait on tb_accu_s;
        if tb_accu_s = "01010101" then
          wait on tb_accu_s;
          if tb_accu_s = "00000001" then
            -- wait for instruction strobe of this move
            wait until tb_istrobe_s'event and tb_istrobe_s = '1';
            -- wait for next strobe
            wait until tb_istrobe_s'event and tb_istrobe_s = '1';
            assert false
              report "Simulation Result: PASS."
              severity note;
          else
            assert false
              report "Simulation Result: FAIL."
              severity note;
          end if;

          assert false
            report "End of simulation reached."
            severity failure;

        end if;
      end if;
    end loop;

  end process eos;
  --
  -----------------------------------------------------------------------------

end behav;
