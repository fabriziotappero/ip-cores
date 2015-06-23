------------------------------------------------------------------------------
--
-- The Program memory controller.
--
-- $Id: t400_pmem_ctrl.vhd 179 2009-04-01 19:48:38Z arniml $
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

entity t400_pmem_ctrl is

  generic (
    opt_type_g : integer := t400_opt_type_420_c
  );
  port (
    -- System Interface -------------------------------------------------------
    ck_i       : in  std_logic;
    ck_en_i    : in  boolean;
    por_i      : in  boolean;
    res_i      : in  boolean;
    a_i        : in  dw_t;
    m_i        : in  dw_t;
    -- Control Interface ------------------------------------------------------
    op_i       : in  pc_op_t;
    dec_data_i : in  dec_data_t;
    -- Stack Interface --------------------------------------------------------
    pc_o       : out pc_t;
    pc_i       : in  pc_t;
    -- Program Memory Interface -----------------------------------------------
    pm_addr_o  : out pc_t
  );

end t400_pmem_ctrl;


library ieee;
use ieee.numeric_std.all;

-- pragma translate_off
use work.tb_pack.tb_pc_s;
-- pragma translate_on

architecture rtl of t400_pmem_ctrl is

  signal pc_q      : pc_t;
  signal last_pc_s : pc_t;

begin

  -----------------------------------------------------------------------------
  -- Determine last program counter address
  -----------------------------------------------------------------------------
  last_pc_s <=   to_unsigned(16#1ff#, pc_t'length)
               when opt_type_g = t400_opt_type_410_c else
                 to_unsigned(16#3ff#, pc_t'length);


  -----------------------------------------------------------------------------
  -- Process pc
  --
  -- Purpose:
  --   Implements the program counter.
  --
  pc: process (ck_i, por_i)
  begin
    if por_i then
      pc_q <= (others => '0');

    elsif ck_i'event and ck_i = '1' then
      if    res_i then
        -- synchronous reset upon external reset event
        pc_q                 <= (others => '0');

      elsif ck_en_i then
        -- determine PC update mode
        case op_i is
          -- increment program counter ----------------------------------------
          when PC_INC_PC =>
            if pc_q = last_pc_s then
              -- roll over
              pc_q           <= (others => '0');
            else
              pc_q           <= pc_q + 1;
            end if;

          -- Load lower 6 bits from program memory data -----------------------
          when PC_LOAD_6 =>
            pc_q(5 downto 0) <= unsigned(dec_data_i(5 downto 0));

          -- Load lower 7 bits from program memory data -----------------------
          when PC_LOAD_7 =>
            pc_q(6 downto 0) <= unsigned(dec_data_i(6 downto 0));

          -- Load lower 8 bits from program memory data -----------------------
          when PC_LOAD_8 =>
            pc_q(7 downto 0) <= unsigned(dec_data_i(7 downto 0));

          -- Load all bits from program memory data ---------------------------
          when PC_LOAD =>
            pc_q             <= unsigned(dec_data_i);

          -- pop program counter from stack -----------------------------------
          when PC_POP =>
            pc_q             <= pc_i;

          -- update program counter for LQID instruction ----------------------
          when PC_LOAD_A_M =>
            pc_q(7 downto 4) <= unsigned(a_i);
            pc_q(3 downto 0) <= unsigned(m_i);

          -- load interrupt vector --------------------------------------------
          when PC_INT =>
            if opt_type_g = t400_opt_type_420_c then
              -- load address 0x100, i.e. skip first instruction at
              -- vector address 0x0ff which has to be a NOP :-)
              pc_q <= (8 => '1', others => '0');
            end if;

          when others =>
            null;
        end case;
      end if;
    end if;
  end process pc;
  --
  -----------------------------------------------------------------------------


  -- pragma translate_off
  -- instrument interrupt testbench
  tb_pc_s <= pc_q;
  -- pragma translate_on


  -----------------------------------------------------------------------------
  -- Output mapping
  -----------------------------------------------------------------------------
  pc_o      <= pc_q;
  pm_addr_o <= pc_q;

end rtl;
