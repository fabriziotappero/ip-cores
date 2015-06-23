-------------------------------------------------------------------------------
--
-- The Data Memory control unit.
-- All accesses to the Data Memory are managed here.
--
-- $Id: dmem_ctrl.vhd 295 2009-04-01 19:32:48Z arniml $
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

use work.t48_pack.dmem_addr_t;
use work.t48_pack.word_t;
use work.t48_dmem_ctrl_pack.dmem_addr_ident_t;

entity t48_dmem_ctrl is

  port (
    -- Global Interface -------------------------------------------------------
    clk_i             : in  std_logic;
    res_i             : in  std_logic;
    en_clk_i          : in  boolean;
    -- Control Interface ------------------------------------------------------
    data_i            : in  word_t;
    write_dmem_addr_i : in  boolean;
    write_dmem_i      : in  boolean;
    read_dmem_i       : in  boolean;
    addr_type_i       : in  dmem_addr_ident_t;
    bank_select_i     : in  std_logic;
    data_o            : out word_t;
    -- Data Memory Interface --------------------------------------------------
    dmem_data_i       : in  word_t;
    dmem_addr_o       : out dmem_addr_t;
    dmem_we_o         : out std_logic;
    dmem_data_o       : out word_t
  );

end t48_dmem_ctrl;


library ieee;
use ieee.numeric_std.all;

use work.t48_pack.clk_active_c;
use work.t48_pack.res_active_c;
use work.t48_pack.bus_idle_level_c;
use work.t48_pack.to_stdLogic;

use work.t48_dmem_ctrl_pack.all;

architecture rtl of t48_dmem_ctrl is

  signal dmem_addr_s,
         dmem_addr_q  : dmem_addr_t;
begin

  -----------------------------------------------------------------------------
  -- Process addr_decode
  --
  -- Purpose:
  --   Decode/multiplex the address information for the Data Memory.
  --
  addr_decode: process (data_i,
                        addr_type_i,
                        bank_select_i,
                        dmem_addr_q)
    variable stack_addr_v : unsigned(5 downto 0);
  begin
    -- default assignment
    dmem_addr_s  <= dmem_addr_q;
    stack_addr_v := (others => '0');

    case addr_type_i is
      when DM_PLAIN =>
        dmem_addr_s <= data_i;

      when DM_REG =>
        dmem_addr_s               <= (others => '0');
        dmem_addr_s(2 downto 0)   <= data_i(2 downto 0);
        -- implement bank switching
        if bank_select_i = '1' then
          -- dmem address 24 - 31: access proper set
          dmem_addr_s(4 downto 3) <= "11";
        end if;

      when DM_STACK =>
        -- build address from stack pointer
        stack_addr_v(3 downto 1)  := unsigned(data_i(2 downto 0));
        -- dmem address 8 - 23
        stack_addr_v              := stack_addr_v + 8;

        dmem_addr_s <= (others => '0');
        dmem_addr_s(5 downto 0) <= std_logic_vector(stack_addr_v);

      when DM_STACK_HIGH =>
        dmem_addr_s(0) <= '1';

      when others =>
        -- do nothing

        -- pragma translate_off
        assert false
          report "Unknown address type identification for Data Memory controller!"
          severity error;
        -- pragma translate_on

    end case;

  end process addr_decode;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process dmem_addr_reg
  --
  -- Purpose:
  --   Implements the Data Memory Address Register.
  --   This register is required to hold the address during a write operation
  --   as we cannot hold the address in the input register of the
  --   synchronous RAM (no clock suppression/gating).
  --
  --   NOTE: May be obsoleted by clock enable feature of generic RTL RAM.
  --
  dmem_addr_reg: process (res_i, clk_i)
  begin
    if res_i = res_active_c then
      dmem_addr_q <= (others => '0');

    elsif clk_i'event and clk_i = clk_active_c then
      if en_clk_i then

        if write_dmem_addr_i then
          dmem_addr_q <= dmem_addr_s;
        end if;

      end if;

    end if;

  end process dmem_addr_reg;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Output mapping.
  -----------------------------------------------------------------------------
  dmem_addr_o <=   dmem_addr_s
                 when write_dmem_addr_i and en_clk_i else
                   dmem_addr_q;

  -- data from bus is fed through
  dmem_data_o <= data_i;

  -- data to bus is enabled upon read request
  data_o      <=   dmem_data_i
                 when read_dmem_i else
                   (others => bus_idle_level_c);

  -- write enable to Data Memory is fed through
  dmem_we_o   <= to_stdLogic(write_dmem_i);

end rtl;
