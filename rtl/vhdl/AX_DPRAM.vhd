--
-- AT90Sxxxx compatible microcontroller core
--
-- Version : 0221
--
-- Copyright (c) 2001-2002 Daniel Wallner (jesus@opencores.org)
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
--	http://www.opencores.org/cvsweb.shtml/t51/
--
-- Limitations :
--
-- File history :
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity AX_DPRAM is
	port(
		Clk			: in std_logic;
		Rst_n		: in std_logic;
		Wr			: in std_logic;
		Rd_Addr		: in std_logic_vector(4 downto 0);
		Wr_Addr		: in std_logic_vector(4 downto 0);
		Data_In		: in std_logic_vector(7 downto 0);
		Data_Out	: out std_logic_vector(7 downto 0)
	);
end AX_DPRAM;

architecture rtl of AX_DPRAM is

	type Reg_Image is array (31 downto 0) of std_logic_vector(7 downto 0);
	signal	Reg			: Reg_Image;
	signal	Rd_Addr_r	: std_logic_vector(4 downto 0);

begin

	process (Rst_n, Clk)
	begin
-- pragma translate_off
		if Rst_n = '0' then
			Reg <= (others => "00000000");
		else
-- pragma translate_on
		if Clk'event and Clk = '1' then
			if Wr = '1' then
				Reg(to_integer(unsigned(Wr_Addr))) <= Data_In;
			end if;
			Rd_Addr_r <= Rd_Addr;
		end if;
-- pragma translate_off
		end if;
-- pragma translate_on
	end process;

	Data_Out <= Reg(to_integer(unsigned(Rd_Addr_r)))
-- pragma translate_off
		when not is_x(Rd_Addr_r) else "--------"
-- pragma translate_on
	;

end;
