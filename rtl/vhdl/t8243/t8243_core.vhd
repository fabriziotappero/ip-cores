-------------------------------------------------------------------------------
--
-- The T8243 Core
-- This is the core module implementing all functionality of the
-- original 8243 chip.
--
-- $Id: t8243_core.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2006, Arnim Laeuger (arniml@opencores.org)
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
use ieee. std_logic_1164.all;

entity t8243_core is

  generic (
    clk_fall_level_g : integer := 0
  );
  port (
    -- System Interface -------------------------------------------------------
    clk_i         : in  std_logic;
    clk_rise_en_i : in  std_logic;
    clk_fall_en_i : in  std_logic;
    reset_n_i     : in  std_logic;
    -- Control Interface ------------------------------------------------------
    cs_n_i        : in  std_logic;
    prog_n_i      : in  std_logic;
    -- Port 2 Interface -------------------------------------------------------
    p2_i          : in  std_logic_vector(3 downto 0);
    p2_o          : out std_logic_vector(3 downto 0);
    p2_en_o       : out std_logic;
    -- Port 4 Interface -------------------------------------------------------
    p4_i          : in  std_logic_vector(3 downto 0);
    p4_o          : out std_logic_vector(3 downto 0);
    p4_en_o       : out std_logic;
    -- Port 5 Interface -------------------------------------------------------
    p5_i          : in  std_logic_vector(3 downto 0);
    p5_o          : out std_logic_vector(3 downto 0);
    p5_en_o       : out std_logic;
    -- Port 6 Interface -------------------------------------------------------
    p6_i          : in  std_logic_vector(3 downto 0);
    p6_o          : out std_logic_vector(3 downto 0);
    p6_en_o       : out std_logic;
    -- Port 7 Interface -------------------------------------------------------
    p7_i          : in  std_logic_vector(3 downto 0);
    p7_o          : out std_logic_vector(3 downto 0);
    p7_en_o       : out std_logic
  );

end t8243_core;


library ieee;
use ieee.numeric_std.all;

architecture rtl of t8243_core is

  function int2stdlogic_f(level_i : in integer) return std_logic is
  begin
    if level_i = 0 then
      return '0';
    else
      return '1';
    end if;
  end;

  constant clk_fall_level_c : std_logic := int2stdlogic_f(clk_fall_level_g);

  type     instr_t is (INSTR_READ, INSTR_WRITE, INSTR_ORLD, INSTR_ANLD);
  signal   instr_q : instr_t;

  constant port_4_c : integer := 4;
  constant port_5_c : integer := 5;
  constant port_6_c : integer := 6;
  constant port_7_c : integer := 7;

  subtype port_range_t is natural range port_7_c downto port_4_c;
  signal  px_sel_q : std_logic_vector(port_range_t);

  signal  px_en_q  : std_logic_vector(port_range_t);
  signal  p2_en_q  : std_logic;

  subtype port_vector_t is std_logic_vector(3 downto 0);
  type    four_ports_t  is array (port_range_t) of port_vector_t;
  signal  px_latch_q    : four_ports_t;

  signal  data_s        : port_vector_t;

  signal  p2_s,
          p4_s,
          p5_s,
          p6_s,
          p7_s          : port_vector_t;

begin

  -- get rid of H and L
  p2_s <= to_X01(p2_i);
  p4_s <= to_X01(p4_i);
  p5_s <= to_X01(p5_i);
  p6_s <= to_X01(p6_i);
  p7_s <= to_X01(p7_i);

  -----------------------------------------------------------------------------
  -- Process ctrl_seq
  --
  -- Purpose:
  --   Implements the sequential elements that control the T8243 core.
  --     * latch port number
  --     * latch instruction
  --
  ctrl_seq: process (clk_i, cs_n_i)
  begin
    if cs_n_i = '1' then
      px_sel_q <= (others => '0');
      p2_en_q  <= '0';
      instr_q  <= INSTR_WRITE;

    elsif clk_i'event and clk_i = clk_fall_level_c then
      if cs_n_i = '0' and clk_fall_en_i = '1' then
        -- enable addressed port ----------------------------------------------
        px_sel_q <= (others => '0');
        px_sel_q(to_integer(unsigned(p2_s(1 downto 0))) +
                 port_range_t'low) <= '1';

        p2_en_q <= '0';

        -- decode instruction -------------------------------------------------
        case p2_s(3 downto 2) is
          when "00" =>
            instr_q <= INSTR_READ;
            p2_en_q <= '1';
          when "01" =>
            instr_q <= INSTR_WRITE;
          when "10" =>
            instr_q <= INSTR_ORLD;
          when "11" =>
            instr_q <= INSTR_ANLD;
          when others =>
            null;
        end case;

      end if;

    end if;
  end process ctrl_seq;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process port_seq
  --
  -- Purpose:
  --   Implements the sequential elements of the four ports.
  --
  port_seq: process (clk_i, reset_n_i)
  begin
    if reset_n_i = '0' then
      px_en_q    <= (others => '0');
      px_latch_q <= (others => (others => '0'));

    elsif rising_edge(clk_i) then
      if cs_n_i = '0' and clk_rise_en_i = '1' then
        for idx in port_range_t loop
          if px_sel_q(idx) = '1' then
            if instr_q = INSTR_READ then
              -- port is being read from, switch off output enable
              px_en_q(idx) <= '0';

            else
              -- port is being written to, enable output
              px_en_q(idx) <= '1';
              -- and latch value
              px_latch_q(idx) <= data_s;
            end if;
          end if;
        end loop;
      end if;

    end if;
  end process port_seq;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process data_gen
  --
  -- Purpose:
  --   Generates the data for the four port latches.
  --     * determines data inputs
  --     * calculates result of instruction
  --
  --   Multiplexes the read value for P2.
  --
  data_gen: process (px_sel_q,
                     instr_q,
                     p2_s,
                     px_latch_q,
                     p4_s, p5_s, p6_s, p7_s)
    variable port_v : port_vector_t;
  begin
    -- select addressed port
    case px_sel_q is
      when "0001" =>
        port_v := px_latch_q(port_4_c);
        p2_o   <= p4_s;
      when "0010" =>
        port_v := px_latch_q(port_5_c);
        p2_o   <= p5_s;
      when "0100" =>
        port_v := px_latch_q(port_6_c);
        p2_o   <= p6_s;
      when "1000" =>
        port_v := px_latch_q(port_7_c);
        p2_o   <= p7_s;
      when others =>
        port_v := (others => '-');
        p2_o   <= (others => '-');
    end case;

    case instr_q is
      when INSTR_WRITE =>
        data_s <= p2_s;
      when INSTR_ORLD =>
        data_s <= p2_s or port_v;
      when INSTR_ANLD =>
        data_s <= p2_s and port_v;
      when others =>
        data_s <= (others => '-');
    end case;

  end process;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Output mapping
  -----------------------------------------------------------------------------
  p2_en_o <=   '1'
             when cs_n_i = '0' and prog_n_i = '0' and p2_en_q = '1' else
               '0';
  p4_o    <= px_latch_q(port_4_c);
  p4_en_o <= px_en_q(port_4_c);
  p5_o    <= px_latch_q(port_5_c);
  p5_en_o <= px_en_q(port_5_c);
  p6_o    <= px_latch_q(port_6_c);
  p6_en_o <= px_en_q(port_6_c);
  p7_o    <= px_latch_q(port_7_c);
  p7_en_o <= px_en_q(port_7_c);

end rtl;
