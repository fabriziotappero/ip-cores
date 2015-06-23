--
-- 8051 compatible microcontroller core
--
-- Version : 0300
--
-- Copyright (c) 2001-2002 Daniel Wallner (jesus@opencores.org)
--           (c) 2004-2005 Andreas Voggeneder (andreas.voggeneder@fh-hagenberg.at)
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
--	Uses two RAMs instead of DP-RAM as not all synthesis tools support DP-RAM inferring
--
-- File history :
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity T51_RAM is
	generic(
		RAMAddressWidth : integer := 8
	);
	port (
		Clk			: in std_logic;
		Rst_n		: in std_logic;
		ARE			: in std_logic;
		Wr			: in std_logic;
		DIn			: in std_logic_vector(7 downto 0);
		Int_AddrA	: in std_logic_vector(7 downto 0);
		Int_AddrA_r	: out std_logic_vector(7 downto 0);
		Int_AddrB	: in std_logic_vector(7 downto 0);
		Mem_A		: out std_logic_vector(7 downto 0);
		Mem_B		: out std_logic_vector(7 downto 0)
	);
end T51_RAM;

architecture rtl of T51_RAM is

	type RAM_Image is array (2**RAMAddressWidth - 1 downto 0) of std_logic_vector(7 downto 0);
	signal	IRAMA	: RAM_Image;
	signal	IRAMB	: RAM_Image;

	signal	Int_AddrA_r_i	: std_logic_vector(7 downto 0);

begin

	Int_AddrA_r <= Int_AddrA_r_i;

	process (Rst_n, Clk)
	begin
-- pragma translate_off
		if Rst_n = '0' then
			Int_AddrA_r_i <= (others => '0');
			IRAMA <= (others => "00000000");
			IRAMB <= (others => "00000000");
		else
-- pragma translate_on
		if Clk'event and Clk = '1' then
-- pragma translate_off
			if not is_x(Int_AddrA) then
-- pragma translate_on
				if ARE = '1' then
					Mem_A <= IRAMA(to_integer(unsigned(Int_AddrA)));
				end if;
-- pragma translate_off
      else
        Mem_A <= (others =>'-');
			end if;
			if not is_x(Int_AddrB) then
-- pragma translate_on
				if ARE = '1' then
					Mem_B <= IRAMB(to_integer(unsigned(Int_AddrB)));
				end if;
-- pragma translate_off
      else
        Mem_B <= (others =>'-');
			end if;
-- pragma translate_on
			if Wr = '1' then
				IRAMA(to_integer(unsigned(Int_AddrA_r_i))) <= DIn;
				IRAMB(to_integer(unsigned(Int_AddrA_r_i))) <= DIn;
				if Int_AddrA_r_i = Int_AddrA then
					Mem_A <= DIn;
				end if;
				if Int_AddrA_r_i = Int_AddrB then
					Mem_B <= DIn;
				end if;
			end if;
			Int_AddrA_r_i <= Int_AddrA;
		end if;
-- pragma translate_off
		end if;
-- pragma translate_on
	end process;

end;
