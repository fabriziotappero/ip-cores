-------------------------------------------------------------------------------
--
-- The serial input/output unit.
--
-- $Id: t400_sio.vhd 179 2009-04-01 19:48:38Z arniml $
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

use work.t400_pack.all;
use work.t400_opt_pack.all;

entity t400_sio is

  generic (
    opt_so_output_type_g : integer := t400_opt_out_type_std_c;
    opt_sk_output_type_g : integer := t400_opt_out_type_std_c
  );
  port (
    -- System Interface -------------------------------------------------------
    ck_i       : in  std_logic;
    ck_en_i    : in  boolean;
    por_i      : in  boolean;
    res_i      : in  boolean;
    phi1_i     : in  std_logic;
    out_en_i   : in  boolean;
    in_en_i    : in  boolean;
    -- Control Interface ------------------------------------------------------
    op_i       : in  sio_op_t;
    en0_i      : in  std_logic;
    en3_i      : in  std_logic;
    -- SIO Interface ----------------------------------------------------------
    a_i        : in  dw_t;
    c_i        : in  std_logic;
    sio_o      : out dw_t;
    -- Pad Interface ----------------------------------------------------------
    si_i       : in  std_logic;
    so_o       : out std_logic;
    so_en_o    : out std_logic;
    sk_o       : out std_logic;
    sk_en_o    : out std_logic
  );

end t400_sio;


library ieee;
use ieee.numeric_std.all;

use work.t400_io_pack.all;

architecture rtl of t400_sio is

  signal si_q       : std_logic;
  type   si_flt_t   is (SI_LOW_0, SI_LOW_1,
                        SI_HIGH_0, SI_HIGH_1);
  signal si_flt_s,
         si_flt_q   : si_flt_t;
  signal si_0_ok_s,
         si_1_ok_s  : boolean;
  signal si_0_ok_q,
         si_1_ok_q  : boolean;
  signal dec_sio_s  : boolean;

  signal new_sio_s,
         sio_q      : unsigned(dw_range_t);
  signal skl_q      : std_logic;
  signal phi1_en_q  : std_logic;

  signal so_s,
         sk_s       : std_logic;

  signal vdd_s      : std_logic;

begin

  vdd_s <= '1';

  -----------------------------------------------------------------------------
  -- Process seq
  --
  -- Purpose:
  --   Implements the sequential elements.
  --
  seq: process (ck_i, por_i)
  begin
    if    por_i then
      sio_q     <= (others => '0');
      skl_q     <= '1';
      phi1_en_q <= '1';
      si_q      <= '1';
      si_flt_q  <= SI_LOW_0;
      si_0_ok_q <= false;
      si_1_ok_q <= false;

    elsif ck_i'event and ck_i = '1' then
      if res_i then
        -- synchronous reset upon external reset event
        skl_q     <= '1';
        phi1_en_q <= '1';
      else
        if in_en_i then
          -- sample asynchronous SI input
          si_q      <= si_i;
        end if;

        if out_en_i then
          -- SI filter FSM
          si_flt_q  <= si_flt_s;
          -- SI low/high markers
          si_0_ok_q <= si_0_ok_s;
          si_1_ok_q <= si_1_ok_s;
        end if;

        -- SIO shift register / counter
        if    op_i = SIO_LOAD and ck_en_i then
          -- parallel update has priority
          sio_q <= unsigned(a_i);
          skl_q <= c_i;

        else
          sio_q <= new_sio_s;
        end if;

        if ck_en_i then
          -- delay enable of PHI1 by one clock cycle
          -- this prevents glitches on sk_o when enabling/disabling
          -- sk_o as a clock output
          phi1_en_q <= skl_q;
        end if;

      end if;
    end if;
  end process seq;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process new_sio
  --
  -- Purpose:
  --   Calculates the new value of SIO.
  --   Splitting this from the sequential process is required to deliver
  --   the transient new value of SIO to sio_o upon reading SIO.
  --
  new_sio: process (out_en_i,
                    en0_i,
                    sio_q,
                    si_q,
                    dec_sio_s)
  begin
    -- default value
    new_sio_s <= sio_q;

    if out_en_i then
      if en0_i = '0' then
        -- shift register mode
        new_sio_s(3 downto 1) <= sio_q(2 downto 0);
        new_sio_s(0)          <= si_q;

      else
        -- counter mode
        if dec_sio_s then
          new_sio_s <= sio_q - 1;
        end if;

      end if;
    end if;
  end process new_sio;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process si_sample
  --
  -- Purpose:
  --   Implements the low pass filter on SI for low and high levels.
  --
  si_sample: process (si_q,
                      si_flt_q,
                      si_0_ok_q, si_1_ok_q)
  begin
    -- default assignments
    si_flt_s  <= si_flt_q;
    si_0_ok_s <= si_0_ok_q;
    si_1_ok_s <= si_1_ok_q;
    dec_sio_s <= false;

    case si_flt_q is
      when SI_LOW_0 =>
        if si_q = '0' then
          si_flt_s  <= SI_LOW_1;
        else
          si_flt_s  <= SI_HIGH_0;
        end if;

      when SI_LOW_1 =>
        if si_q = '0' then
          si_0_ok_s <= true;            -- enough '0' on SI

          if not si_0_ok_q and si_1_ok_q then
            -- decrement counter if durations of high and low phases
            -- were long enough
            dec_sio_s <= true;
          end if;
        else
          si_flt_s  <= SI_HIGH_0;
          si_1_ok_s <= false;           -- restart measuring
        end if;

      when SI_HIGH_0 =>
        si_1_ok_s <= false;             -- restart marker
        if si_q = '1' then
          si_flt_s <= SI_HIGH_1;
        else
          si_flt_s <= SI_LOW_0;
        end if;

      when SI_HIGH_1 =>
        if si_q = '1' then
          si_1_ok_s   <= true;          -- enough '1' on SI
        else
          si_flt_s    <= SI_LOW_0;
          si_0_ok_s   <= false;         -- restart measuring
        end if;

      when others =>
        null;
    end case;
  end process si_sample;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Output mapping
  -----------------------------------------------------------------------------
  sio_o   <= std_logic_vector(new_sio_s);
  so_s    <= en3_i and (en0_i or sio_q(3));
  sk_s    <= phi1_en_q and (en0_i or phi1_i);
  so_o    <= io_out_f(dat => so_s, opt => opt_so_output_type_g);
  so_en_o <= io_en_f (en  => vdd_s,
                      dat => so_s, opt => opt_so_output_type_g);
  sk_o    <= io_out_f(dat => sk_s, opt => opt_sk_output_type_g);
  sk_en_o <= io_en_f (en  => vdd_s,
                      dat => sk_s, opt => opt_sk_output_type_g);

end rtl;
