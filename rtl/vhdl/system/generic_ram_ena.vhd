-------------------------------------------------------------------------------
--
-- Parametrizable, generic RAM with enable.
--
-- $Id: generic_ram_ena.vhd 295 2009-04-01 19:32:48Z arniml $
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
--      http://www.opencores.org/cvsweb.shtml/t48/
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity generic_ram_ena is

  generic (
    addr_width_g : integer := 10;
    data_width_g : integer := 8
  );
  port (
    clk_i : in  std_logic;
    a_i   : in  std_logic_vector(addr_width_g-1 downto 0);
    we_i  : in  std_logic;
    ena_i : in  std_logic;
    d_i   : in  std_logic_vector(data_width_g-1 downto 0);
    d_o   : out std_logic_vector(data_width_g-1 downto 0)
  );

end generic_ram_ena;


library ieee;
use ieee.numeric_std.all;

architecture rtl of generic_ram_ena is

  type mem_t is array (natural range 0 to 2**addr_width_g-1) of
    std_logic_vector(d_i'range);
  signal mem_q : mem_t
    -- pragma translate_off
    := (others => (others => '0'))
    -- pragma translate_on
    ;
  signal a_q : std_logic_vector(a_i'range);

begin

  mem: process (clk_i)
  begin

    if clk_i'event and clk_i = '1' then
      if ena_i = '1' then
        if we_i = '1' then
          mem_q(to_integer(unsigned(a_i))) <= d_i;
        end if;

        a_q <= a_i;
      end if;

    end if;
  end process mem;

  d_o <= mem_q(to_integer(unsigned(a_q)));

end rtl;
