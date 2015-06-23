-------------------------------------------------------------------------------
--
-- The Program Status Word (PSW).
-- Implements the PSW with its special bits.
--
-- $Id: psw.vhd 295 2009-04-01 19:32:48Z arniml $
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

use work.t48_pack.word_t;

entity t48_psw is

  port (
    -- Global Interface -------------------------------------------------------
    clk_i              : in  std_logic;
    res_i              : in  std_logic;
    en_clk_i           : in  boolean;
    -- T48 Bus Interface ------------------------------------------------------
    data_i             : in  word_t;
    data_o             : out word_t;
    read_psw_i         : in  boolean;
    read_sp_i          : in  boolean;
    write_psw_i        : in  boolean;
    write_sp_i         : in  boolean;
    -- Decoder Interface ------------------------------------------------------
    special_data_i     : in  std_logic;
    inc_stackp_i       : in  boolean;
    dec_stackp_i       : in  boolean;
    write_carry_i      : in  boolean;
    write_aux_carry_i  : in  boolean;
    write_f0_i         : in  boolean;
    write_bs_i         : in  boolean;
    carry_o            : out std_logic;
    aux_carry_i        : in  std_logic;
    aux_carry_o        : out std_logic;
    f0_o               : out std_logic;
    bs_o               : out std_logic
  );

end t48_psw;


library ieee;
use ieee.numeric_std.all;

use work.t48_pack.clk_active_c;
use work.t48_pack.res_active_c;
use work.t48_pack.bus_idle_level_c;
use work.t48_pack.nibble_t;

architecture rtl of t48_psw is

  -- special bit positions in PSW
  constant carry_c     : natural := 3;
  constant aux_carry_c : natural := 2;
  constant f0_c        : natural := 1;
  constant bs_c        : natural := 0;

  -- the PSW register
  signal psw_q : nibble_t;
  -- the Stack Pointer
  signal sp_q  : unsigned(2 downto 0);

  -- pragma translate_off
  signal psw_s : word_t;
  -- pragma translate_on

begin

  -----------------------------------------------------------------------------
  -- Process psw_reg
  --
  -- Purpose:
  --   Implements the PSW register.
  --
  psw_reg: process (res_i, clk_i)
  begin
    if res_i = res_active_c then
      psw_q <= (others => '0');
      sp_q  <= (others => '0');

    elsif clk_i'event and clk_i = clk_active_c then
      if en_clk_i then

        -- T48 bus access
        if write_psw_i then
          psw_q  <= data_i(7 downto 4);
        end if;
        if write_sp_i then
          sp_q <= unsigned(data_i(2 downto 0));
        end if;

        -- increment Stack Pointer
        if inc_stackp_i then
          sp_q  <= sp_q + 1;
        end if;
        -- decrement Stack Pointer
        if dec_stackp_i then
          sp_q  <= sp_q - 1;
        end if;

        -- access to special bits
        if write_carry_i then
          psw_q(carry_c)     <= special_data_i;
        end if;
        --
        if write_aux_carry_i then
          psw_q(aux_carry_c) <= aux_carry_i;
        end if;
        --
        if write_f0_i then
          psw_q(f0_c)        <= special_data_i;
        end if;
        --
        if write_bs_i then
          psw_q(bs_c)        <= special_data_i;
        end if;

      end if;

    end if;

  end process psw_reg;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process data_out
  --
  -- Purpose:
  --   Output multiplexer for T48 Data Bus.
  --
  data_out: process (read_psw_i,
                     read_sp_i,
                     psw_q,
                     sp_q)
  begin
    data_o <= (others => bus_idle_level_c);

    if read_psw_i then
      data_o(7 downto 4) <= psw_q;
    end if;

    if read_sp_i then
      data_o(3 downto 0) <= '1' & std_logic_vector(sp_q);
    end if;

  end process data_out;
  --
  -----------------------------------------------------------------------------


  -- pragma translate_off
  tb: process (psw_q, sp_q)
  begin
    psw_s(7 downto 4) <= psw_q;
    psw_s(3)          <= '1';
    psw_s(2 downto 0) <= std_logic_vector(sp_q);
  end process tb;
  -- pragma translate_on

  -----------------------------------------------------------------------------
  -- Output mapping.
  -----------------------------------------------------------------------------
  carry_o     <= psw_q(carry_c);
  aux_carry_o <= psw_q(aux_carry_c);
  f0_o        <= psw_q(f0_c);
  bs_o        <= psw_q(bs_c);

end rtl;
