-------------------------------------------------------------------------------
--
-- The L port controller.
--
-- $Id: t400_io_l.vhd 179 2009-04-01 19:48:38Z arniml $
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
use work.t400_pack.all;

entity t400_io_l is

  generic (
    opt_out_type_7_g : integer := t400_opt_out_type_std_c;
    opt_out_type_6_g : integer := t400_opt_out_type_std_c;
    opt_out_type_5_g : integer := t400_opt_out_type_std_c;
    opt_out_type_4_g : integer := t400_opt_out_type_std_c;
    opt_out_type_3_g : integer := t400_opt_out_type_std_c;
    opt_out_type_2_g : integer := t400_opt_out_type_std_c;
    opt_out_type_1_g : integer := t400_opt_out_type_std_c;
    opt_out_type_0_g : integer := t400_opt_out_type_std_c;
    opt_microbus_g   : integer := t400_opt_no_microbus_c
  );
  port (
    -- System Interface -------------------------------------------------------
    ck_i      : in  std_logic;
    ck_en_i   : in  boolean;
    por_i     : in  boolean;
    in_en_i   : in  boolean;
    -- Control Interface ------------------------------------------------------
    op_i      : in  io_l_op_t;
    en2_i     : in  std_logic;
    m_i       : in  dw_t;
    a_i       : in  dw_t;
    pm_data_i : in  byte_t;
    q_o       : out byte_t;
    -- Microbus Interface -----------------------------------------------------
    cs_n_i    : in  std_logic;
    rd_n_i    : in  std_logic;
    wr_n_i    : in  std_logic;
    -- Port L Interface -------------------------------------------------------
    io_l_i    : in  byte_t;
    io_l_o    : out byte_t;
    io_l_en_o : out byte_t
  );

end t400_io_l;


use work.t400_io_pack.all;

architecture rtl of t400_io_l is

  signal q_q   : byte_t;

  signal en2_s : std_logic;

begin

  -----------------------------------------------------------------------------
  -- Process q_reg
  --
  -- Purpose:
  --   Implements the Q register.
  --
  q_reg: process (ck_i, por_i)
  begin
    if por_i then
      q_q <= (others => '0');
    elsif ck_i'event and ck_i = '1' then
      if ck_en_i then
        case op_i is
          -- Load Q from accumulator and data memory --------------------------
          when IOL_LOAD_AM =>
            q_q(7 downto 4) <= a_i;
            q_q(3 downto 0) <= m_i;

          -- Load Q from program memory ---------------------------------------
          when IOL_LOAD_PM =>
            q_q <= pm_data_i;

          when others =>
            null;
        end case;
      end if;

      -- Microbus functionality
      if opt_microbus_g = t400_opt_microbus_c and
         cs_n_i = '0' and wr_n_i = '0' then
        q_q <= to_X01(io_l_i);
      end if;
    end if;
  end process q_reg;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Multiplexer providing read data to the system.
  -----------------------------------------------------------------------------
  q_o <=   to_X01(io_l_i)
         when op_i = IOL_OUTPUT_L else
           q_q;


  -----------------------------------------------------------------------------
  -- Dedicated output enable when in Microbus mode
  -----------------------------------------------------------------------------
  en2_s <=   cs_n_i nor rd_n_i
           when opt_microbus_g = t400_opt_microbus_c else
             en2_i;

  -----------------------------------------------------------------------------
  -- Process out_driver
  --
  -- Purpose:
  --   Implements the output driver data and enable.
  --
  out_driver: process (en2_s,
                       q_q)
  begin
    -- bit 7
    io_l_o(7)    <= io_out_f(dat => q_q(7),
                             opt => opt_out_type_7_g);
    io_l_en_o(7) <= io_en_f (en  => en2_s, dat => q_q(7),
                             opt => opt_out_type_7_g);

    -- bit 6
    io_l_o(6)    <= io_out_f(dat => q_q(6),
                             opt => opt_out_type_6_g);
    io_l_en_o(6) <= io_en_f (en  => en2_s, dat => q_q(6),
                             opt => opt_out_type_6_g);

    -- bit 5
    io_l_o(5)    <= io_out_f(dat => q_q(5),
                             opt => opt_out_type_5_g);
    io_l_en_o(5) <= io_en_f (en  => en2_s, dat => q_q(5),
                             opt => opt_out_type_5_g);

    -- bit 4
    io_l_o(4)    <= io_out_f(dat => q_q(4),
                             opt => opt_out_type_4_g);
    io_l_en_o(4) <= io_en_f (en  => en2_s, dat => q_q(4),
                             opt => opt_out_type_4_g);

    -- bit 3
    io_l_o(3)    <= io_out_f(dat => q_q(3),
                             opt => opt_out_type_3_g);
    io_l_en_o(3) <= io_en_f (en  => en2_s, dat => q_q(3),
                             opt => opt_out_type_3_g);

    -- bit 2
    io_l_o(2)    <= io_out_f(dat => q_q(2),
                             opt => opt_out_type_2_g);
    io_l_en_o(2) <= io_en_f (en  => en2_s, dat => q_q(2),
                             opt => opt_out_type_2_g);

    -- bit 1
    io_l_o(1)    <= io_out_f(dat => q_q(1),
                             opt => opt_out_type_1_g);
    io_l_en_o(1) <= io_en_f (en  => en2_s, dat => q_q(1),
                             opt => opt_out_type_1_g);

    -- bit 0
    io_l_o(0)    <= io_out_f(dat => q_q(0),
                             opt => opt_out_type_0_g);
    io_l_en_o(0) <= io_en_f (en  => en2_s, dat => q_q(0),
                             opt => opt_out_type_0_g);

  end process out_driver;
  --
  -----------------------------------------------------------------------------

end rtl;
