-------------------------------------------------------------------------------
--
-- The D port controller.
--
-- $Id: t400_io_d.vhd 179 2009-04-01 19:48:38Z arniml $
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

entity t400_io_d is

  generic (
    opt_out_type_3_g : integer := t400_opt_out_type_std_c;
    opt_out_type_2_g : integer := t400_opt_out_type_std_c;
    opt_out_type_1_g : integer := t400_opt_out_type_std_c;
    opt_out_type_0_g : integer := t400_opt_out_type_std_c
  );
  port (
    -- System Interface -------------------------------------------------------
    ck_i      : in  std_logic;
    ck_en_i   : in  boolean;
    por_i     : in  boolean;
    res_i     : in  boolean;
    -- Control Interface ------------------------------------------------------
    op_i      : in  io_d_op_t;
    bd_i      : in  bd_t;
    -- Port D Interface -------------------------------------------------------
    io_d_o    : out dw_t;
    io_d_en_o : out dw_t
  );

end t400_io_d;


use work.t400_io_pack.all;

architecture rtl of t400_io_d is

  signal d_q   : dw_t;

  signal vdd_s : std_logic;

begin

  vdd_s <= '1';

  -----------------------------------------------------------------------------
  -- Process d_reg
  --
  -- Purpose:
  --   Implements the D output register.
  --
  d_reg: process (ck_i, por_i)
  begin
    if por_i then
      d_q <= (others => '0');

    elsif ck_i'event and ck_i = '1' then
      if    res_i then
        -- synchronous reset upon external reset event
        d_q   <= (others => '0');

      elsif ck_en_i then
        if op_i = IOD_LOAD then
          d_q <= bd_i;
        end if;
      end if;

    end if;
  end process d_reg;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process out_driver
  --
  -- Purpose:
  --   Implements the output driver data and enable.
  --
  out_driver: process (d_q,
                       vdd_s)
  begin
    -- bit 3
    io_d_o(3)    <= io_out_f(dat => d_q(3),
                             opt => opt_out_type_3_g);
    io_d_en_o(3) <= io_en_f (en  => vdd_s, dat => d_q(3),
                             opt => opt_out_type_3_g);

     -- bit 2
    io_d_o(2)    <= io_out_f(dat => d_q(2),
                             opt => opt_out_type_2_g);
    io_d_en_o(2) <= io_en_f (en  => vdd_s, dat => d_q(2),
                             opt => opt_out_type_2_g);

    -- bit 1
    io_d_o(1)    <= io_out_f(dat => d_q(1),
                             opt => opt_out_type_1_g);
    io_d_en_o(1) <= io_en_f (en  => vdd_s, dat => d_q(1),
                             opt => opt_out_type_1_g);

    -- bit 0
    io_d_o(0)    <= io_out_f(dat => d_q(0),
                             opt => opt_out_type_0_g);
    io_d_en_o(0) <= io_en_f (en  => vdd_s, dat => d_q(0),
                             opt => opt_out_type_0_g);

  end process out_driver;
  --
  -----------------------------------------------------------------------------

end rtl;
