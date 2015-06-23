--
-- Simple SRAM model without timing
--
-- Version : 0247
--
-- Copyright (c) 2001 Daniel Wallner (jesus@opencores.org)
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
--	http://www.opencores.org/cvsweb.shtml/t80/
--
-- Limitations :
--
-- File history :
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SRAM is
	generic(
		AddrWidth	: integer := 16;
		DataWidth	: integer := 8
	);
	port(
		CE_n		: in std_logic;
		OE_n		: in std_logic;
		WE_n		: in std_logic;
		A			: in std_logic_vector(AddrWidth - 1 downto 0);
		D			: inout std_logic_vector(DataWidth - 1 downto 0)
	);
end SRAM;

architecture behaviour of SRAM is

	type Memory_Image is array (natural range <>) of std_logic_vector(DataWidth - 1 downto 0);
	signal RAM : Memory_Image(0 to 2 ** AddrWidth - 1);

	signal Write : std_logic;
	signal D_del : std_logic_vector(7 downto 0);

begin

	Write <= '1' when CE_n = '0' and WE_n = '0' else '0';
	D_del <= D after 1 ns;

	process (Write)
	begin
		if Write'event and Write = '0' then
			RAM(to_integer(unsigned(A))) <= D_del;
		end if;
	end process;

	D <= RAM(to_integer(unsigned(A)))
-- pragma translate_off
			when OE_n = '0' and CE_n = '0' and WE_n = '1' and not is_x(A) else (others => 'Z')
-- pragma translate_on
			;

end;
