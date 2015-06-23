-------------------------------------------------------------------------------
--
-- The clock generation unit.
-- PHI1 clock and input/output clock enables are generated here.
--
-- $Id: t400_clkgen.vhd 179 2009-04-01 19:48:38Z arniml $
--
-- Copyright (c) 2006 Arnim Laeuger (arniml@opencores.org)
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
--      http://www.opencores.org/cvsweb.shtml/t400/
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.t400_opt_pack.all;

entity t400_clkgen is

  generic (
    opt_ck_div_g : integer := t400_opt_ck_div_16_c
  );
  port (
    -- System Interface -------------------------------------------------------
    ck_i      : in  std_logic;
    ck_en_i   : in  boolean;
    por_i     : in  boolean;
    -- Clock Interface --------------------------------------------------------
    phi1_o    : out std_logic;
    out_en_o  : out boolean;
    in_en_o   : out boolean;
    icyc_en_o : out boolean
  );

end t400_clkgen;


library ieee;
use ieee.numeric_std.all;

architecture rtl of t400_clkgen is

  subtype  ck_div_t       is unsigned(5 downto 0);
  type     ck_div_a_t     is array(natural range t400_opt_ck_div_32_c
                                   downto        t400_opt_ck_div_4_c) of
                             ck_div_t;
  -- reload values for the CK dividing counter
  constant ck_div_a_c     : ck_div_a_t := (
    t400_opt_ck_div_32_c  => to_unsigned(31, ck_div_t'length),
    t400_opt_ck_div_16_c  => to_unsigned(15, ck_div_t'length),
    t400_opt_ck_div_8_c   => to_unsigned( 7, ck_div_t'length),
    t400_opt_ck_div_4_c   => to_unsigned( 3, ck_div_t'length));

  signal   ck_div_cnt_q   : ck_div_t;
  signal   ck_div_zero_s,
           ck_div_half_s  : boolean;
  signal   phi1_q         : std_logic;

begin

  -----------------------------------------------------------------------------
  -- Process ck_div
  --
  -- Purpose:
  --   Divide the incoming clock on ck_i and generate the derived clock
  --   enable for the core.
  --
  ck_div: process (ck_i, por_i)
  begin
    if por_i then
      ck_div_cnt_q <= ck_div_a_c(opt_ck_div_g);
      phi1_q       <= '0';

    elsif ck_i'event and ck_i = '1' then
      if ck_en_i then
        if ck_div_zero_s then
          ck_div_cnt_q <= ck_div_a_c(opt_ck_div_g);
          phi1_q       <= '0';
        else
          ck_div_cnt_q <= ck_div_cnt_q - 1;

          if ck_div_half_s then
            phi1_q     <= '1';
          end if;
        end if;
      end if;
    end if;

  end process ck_div;
  --
  ck_div_zero_s <= ck_div_cnt_q = 0;
  ck_div_half_s <= ck_div_cnt_q = SHIFT_RIGHT(ck_div_a_c(opt_ck_div_g), 1) + 1;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Output mapping
  -----------------------------------------------------------------------------
  phi1_o    <= phi1_q;
  -- Instruction cycle enable
  icyc_en_o <= ck_en_i and ck_div_zero_s;
  -- Output update enable
  out_en_o  <= ck_en_i and ck_div_zero_s;
  -- Input sample enable
  in_en_o   <= ck_en_i and ck_div_half_s; 

end rtl;
