-------------------------------------------------------------------------------
--
-- The T8243 asynchronous toplevel
--
-- $Id: t8243.vhd 295 2009-04-01 19:32:48Z arniml $
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

entity t8243 is

  port (
    -- Control Interface ------------------------------------------------------
    cs_n_i   : in    std_logic;
    prog_n_i : in    std_logic;
    -- Port 2 Interface -------------------------------------------------------
    p2_b     : inout std_logic_vector(3 downto 0);
    -- Port 4 Interface -------------------------------------------------------
    p4_b     : inout std_logic_vector(3 downto 0);
    -- Port 5 Interface -------------------------------------------------------
    p5_b     : inout std_logic_vector(3 downto 0);
    -- Port 6 Interface -------------------------------------------------------
    p6_b     : inout std_logic_vector(3 downto 0);
    -- Port 7 Interface -------------------------------------------------------
    p7_b     : inout std_logic_vector(3 downto 0)
  );

end t8243;


use work.t8243_comp_pack.t8243_async_notri;

architecture struct of t8243 is

  signal p2_s,
         p4_s,
         p5_s,
         p6_s,
         p7_s     : std_logic_vector(3 downto 0);
  signal p2_en_s,
         p4_en_s,
         p5_en_s,
         p6_en_s,
         p7_en_s  : std_logic;

  signal vdd_s    : std_logic;

begin

  vdd_s <= '1';


  -----------------------------------------------------------------------------
  -- The asynchronous T8243
  -----------------------------------------------------------------------------
  t8243_async_notri_b : t8243_async_notri
    port map (
      reset_n_i => vdd_s,               -- or generate power-on reset
      cs_n_i    => cs_n_i,
      prog_n_i  => prog_n_i,
      p2_i      => p2_b,
      p2_o      => p2_s,
      p2_en_o   => p2_en_s,
      p4_i      => p4_b,
      p4_o      => p4_s,
      p4_en_o   => p4_en_s,
      p5_i      => p5_b,
      p5_o      => p5_s,
      p5_en_o   => p5_en_s,
      p6_i      => p6_b,
      p6_o      => p6_s,
      p6_en_o   => p6_en_s,
      p7_i      => p7_b,
      p7_o      => p7_s,
      p7_en_o   => p7_en_s
    );


  -----------------------------------------------------------------------------
  -- Bidirectional pad structures
  -----------------------------------------------------------------------------
  p2_b <=   p2_s
          when p2_en_s = '1' else
            (others => 'Z');
  p4_b <=   p4_s
          when p4_en_s = '1' else
            (others => 'Z');
  p5_b <=   p5_s
          when p5_en_s = '1' else
            (others => 'Z');
  p6_b <=   p6_s
          when p6_en_s = '1' else
            (others => 'Z');
  p7_b <=   p7_s
          when p7_en_s = '1' else
            (others => 'Z');

end struct;
