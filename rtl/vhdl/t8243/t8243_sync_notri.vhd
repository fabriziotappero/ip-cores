-------------------------------------------------------------------------------
--
-- The T8243 synchronous toplevel without tri-state signals
--
-- $Id: t8243_sync_notri.vhd 295 2009-04-01 19:32:48Z arniml $
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
use ieee.std_logic_1164.all;

entity t8243_sync_notri is

  port (
    -- System Interface -------------------------------------------------------
    clk_i     : in  std_logic;
    clk_en_i  : in  std_logic;
    reset_n_i : in  std_logic;
    -- Control Interface ------------------------------------------------------
    cs_n_i    : in  std_logic;
    prog_n_i  : in  std_logic;
    -- Port 2 Interface -------------------------------------------------------
    p2_i      : in  std_logic_vector(3 downto 0);
    p2_o      : out std_logic_vector(3 downto 0);
    p2_en_o   : out std_logic;
    -- Port 4 Interface -------------------------------------------------------
    p4_i      : in  std_logic_vector(3 downto 0);
    p4_o      : out std_logic_vector(3 downto 0);
    p4_en_o   : out std_logic;
    -- Port 5 Interface -------------------------------------------------------
    p5_i      : in  std_logic_vector(3 downto 0);
    p5_o      : out std_logic_vector(3 downto 0);
    p5_en_o   : out std_logic;
    -- Port 6 Interface -------------------------------------------------------
    p6_i      : in  std_logic_vector(3 downto 0);
    p6_o      : out std_logic_vector(3 downto 0);
    p6_en_o   : out std_logic;
    -- Port 7 Interface -------------------------------------------------------
    p7_i      : in  std_logic_vector(3 downto 0);
    p7_o      : out std_logic_vector(3 downto 0);
    p7_en_o   : out std_logic
  );

end t8243_sync_notri;


use work.t8243_comp_pack.t8243_core;

architecture struct of t8243_sync_notri is

  signal prog_n_q       : std_logic;
  signal clk_rise_en_s,
         clk_fall_en_s  : std_logic;

begin

  -----------------------------------------------------------------------------
  -- Process edge_detect
  --
  -- Purpose:
  --   Implements the sequential element required for edge detection
  --   on the PROG input.
  --
  edge_detect: process (clk_i, reset_n_i)
  begin
    if reset_n_i = '0' then
      prog_n_q <= '1';
    elsif rising_edge(clk_i) then
      if clk_en_i = '1' then
        prog_n_q <= prog_n_i;
      end if;
    end if;
  end process edge_detect;
  --
  -----------------------------------------------------------------------------


  -- clock enables to detect rising and falling edges of PROG
  clk_rise_en_s <= clk_en_i and
                   not prog_n_q and prog_n_i;
  clk_fall_en_s <= clk_en_i and
                   prog_n_q and not prog_n_i;


  -----------------------------------------------------------------------------
  -- The T8243 Core
  -----------------------------------------------------------------------------
  t8243_core_b : t8243_core
    generic map (
      clk_fall_level_g => 1
    )
    port map (
      clk_i         => clk_i,
      clk_rise_en_i => clk_rise_en_s,
      clk_fall_en_i => clk_fall_en_s,
      reset_n_i     => reset_n_i,
      cs_n_i        => cs_n_i,
      prog_n_i      => prog_n_i,
      p2_i          => p2_i,
      p2_o          => p2_o,
      p2_en_o       => p2_en_o,
      p4_i          => p4_i,
      p4_o          => p4_o,
      p4_en_o       => p4_en_o,
      p5_i          => p5_i,
      p5_o          => p5_o,
      p5_en_o       => p5_en_o,
      p6_i          => p6_i,
      p6_o          => p6_o,
      p6_en_o       => p6_en_o,
      p7_i          => p7_i,
      p7_o          => p7_o,
      p7_en_o       => p7_en_o
    );

end struct;
