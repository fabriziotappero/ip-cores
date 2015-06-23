-------------------------------------------------------------------------------
--
-- The Program Memory control unit.
-- All operations related to the Program Memory are managed here.
--
-- $Id: pmem_ctrl.vhd 295 2009-04-01 19:32:48Z arniml $
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

use work.t48_pack.pmem_addr_t;
use work.t48_pack.word_t;
use work.t48_pmem_ctrl_pack.pmem_addr_ident_t;

entity t48_pmem_ctrl is

  port (
    -- Global Interface -------------------------------------------------------
    clk_i             : in  std_logic;
    res_i             : in  std_logic;
    en_clk_i          : in  boolean;
    -- T48 Bus Interface ------------------------------------------------------
    data_i            : in  word_t;
    data_o            : out word_t;
    write_pcl_i       : in  boolean;
    read_pcl_i        : in  boolean;
    write_pch_i       : in  boolean;
    read_pch_i        : in  boolean;
    inc_pc_i          : in  boolean;
    write_pmem_addr_i : in  boolean;
    addr_type_i       : in  pmem_addr_ident_t;
    read_pmem_i       : in  boolean;
    -- Porgram Memroy Interface -----------------------------------------------
    pmem_addr_o       : out pmem_addr_t;
    pmem_data_i       : in  word_t
  );

end t48_pmem_ctrl;


library ieee;
use ieee.numeric_std.all;

use work.t48_pmem_ctrl_pack.all;
use work.t48_pack.res_active_c;
use work.t48_pack.clk_active_c;
use work.t48_pack.bus_idle_level_c;
use work.t48_pack.pmem_addr_width_c;
use work.t48_pack.dmem_addr_width_c;
use work.t48_pack.page_t;

architecture rtl of t48_pmem_ctrl is

  -- implemented counter width of Program Counter
  -- the upper bit is only altered by JMP, CALL and RET(R)
  subtype pc_count_range_t is natural range pmem_addr_width_c-2 downto 0;

  -- the Program Counter
  signal program_counter_q : unsigned(pmem_addr_t'range);


  -- the Program Memory address
  signal pmem_addr_s,
         pmem_addr_q       : std_logic_vector(pmem_addr_t'range);

begin

  -----------------------------------------------------------------------------
  -- Process program_counter
  --
  -- Purpose:
  --   Implements the Program Counter.
  --
  program_counter: process (res_i, clk_i)
  begin
    if res_i = res_active_c then
      program_counter_q <= (others => '0');
      pmem_addr_q       <= (others => '0');

    elsif clk_i'event and clk_i = clk_active_c then
      if en_clk_i then

        -- parallel load mode
        if write_pcl_i then
          program_counter_q(data_i'range) <= UNSIGNED(data_i);
        elsif write_pch_i then
          program_counter_q(pmem_addr_width_c-1 downto data_i'high+1) <=
            UNSIGNED(data_i(pmem_addr_width_c - dmem_addr_width_c - 1 downto 0));
        elsif inc_pc_i then
          -- increment mode
          -- the MSB is not modified by linear increments
          -- it can only be altered by JMP, CALL or RET(R)
          program_counter_q(pc_count_range_t) <=
            program_counter_q(pc_count_range_t) + 1;
        end if;

        -- set pmem address
        if write_pmem_addr_i then
          pmem_addr_q <= pmem_addr_s;
        end if;

      end if;

    end if;

  end process program_counter;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process pmem_addr
  --
  -- Purpose:
  --   Multiplex the Program Memory address.
  --
  pmem_addr: process (program_counter_q,
                      addr_type_i,
                      pmem_addr_q,
                      data_i)
  begin
    -- default assignment
    pmem_addr_s <= STD_LOGIC_VECTOR(program_counter_q);
 
    case addr_type_i is
      when PM_PC =>
        -- default is ok
        null;

      when PM_PAGE =>
        pmem_addr_s(word_t'range) <= data_i;
        -- take page address from program counter
        --   => important for JMPP, MOVP!
        --      they must wrap to next page when at FF!

      when PM_PAGE3 =>
        pmem_addr_s(word_t'range) <= data_i;
        -- page address is explicitely specified
        pmem_addr_s(page_t'range) <= "0011";

      when others =>
        null;

    end case;

  end process pmem_addr;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process data_output
  --
  -- Purpose:
  --   Multiplex the data bus output.
  --
  data_output: process (read_pmem_i,
                        read_pcl_i,
                        read_pch_i,
                        pmem_data_i,
                        program_counter_q)
  begin
    data_o <= (others => bus_idle_level_c);

    if read_pmem_i then
      data_o <= pmem_data_i;
    elsif read_pcl_i then
      data_o <= STD_LOGIC_VECTOR(program_counter_q(data_o'range));
    elsif read_pch_i then
      data_o(3 downto 0) <= STD_LOGIC_VECTOR(program_counter_q(pmem_addr_width_c-1 downto data_o'high+1));
    end if;

  end process data_output;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Output Mapping.
  -----------------------------------------------------------------------------
  pmem_addr_o <= pmem_addr_q;

end rtl;
