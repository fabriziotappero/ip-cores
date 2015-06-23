--
-- T80 Registers for Xilinx Select RAM
--
-- Version : 0244
--
-- Copyright (c) 2002 Daniel Wallner (jesus@opencores.org)
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
--	0242 : Initial release
--
--	0244 : Removed UNISIM library and added componet declaration
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity T80_Reg is
	port(
		Clk			: in std_logic;
		CEN			: in std_logic;
		WEH			: in std_logic;
		WEL			: in std_logic;
		AddrA		: in std_logic_vector(2 downto 0);
		AddrB		: in std_logic_vector(2 downto 0);
		AddrC		: in std_logic_vector(2 downto 0);
		DIH			: in std_logic_vector(7 downto 0);
		DIL			: in std_logic_vector(7 downto 0);
		DOAH		: out std_logic_vector(7 downto 0);
		DOAL		: out std_logic_vector(7 downto 0);
		DOBH		: out std_logic_vector(7 downto 0);
		DOBL		: out std_logic_vector(7 downto 0);
		DOCH		: out std_logic_vector(7 downto 0);
		DOCL		: out std_logic_vector(7 downto 0)
	);
end T80_Reg;

architecture rtl of T80_Reg is

	component RAM16X1D
		port(
			DPO		: out std_ulogic;
			SPO		: out std_ulogic;
			A0		: in std_ulogic;
			A1		: in std_ulogic;
			A2		: in std_ulogic;
			A3		: in std_ulogic;        
			D		: in std_ulogic;
			DPRA0	: in std_ulogic;
			DPRA1	: in std_ulogic;
			DPRA2	: in std_ulogic;
			DPRA3	: in std_ulogic;
			WCLK	: in std_ulogic;        
			WE		: in std_ulogic);
	end component;

	signal	ENH		: std_logic;
	signal	ENL		: std_logic;

begin

	ENH <= CEN and WEH;
	ENL <= CEN and WEL;

	bG1: for I in 0 to 7 generate
	begin
		Reg1H : RAM16X1D
			port map(
			DPO => DOBH(i),
			SPO => DOAH(i),
			A0 => AddrA(0),
			A1 => AddrA(1),
			A2 => AddrA(2),
			A3 => '0',
			D => DIH(i),
			DPRA0 => AddrB(0),
			DPRA1 => AddrB(1),
			DPRA2 => AddrB(2),
			DPRA3 => '0',
			WCLK => Clk,
			WE => ENH);
		Reg1L : RAM16X1D
			port map(
			DPO => DOBL(i),
			SPO => DOAL(i),
			A0 => AddrA(0),
			A1 => AddrA(1),
			A2 => AddrA(2),
			A3 => '0',
			D => DIL(i),
			DPRA0 => AddrB(0),
			DPRA1 => AddrB(1),
			DPRA2 => AddrB(2),
			DPRA3 => '0',
			WCLK => Clk,
			WE => ENL);
		Reg2H : RAM16X1D
			port map(
			DPO => DOCH(i),
			SPO => open,
			A0 => AddrA(0),
			A1 => AddrA(1),
			A2 => AddrA(2),
			A3 => '0',
			D => DIH(i),
			DPRA0 => AddrC(0),
			DPRA1 => AddrC(1),
			DPRA2 => AddrC(2),
			DPRA3 => '0',
			WCLK => Clk,
			WE => ENH);
		Reg2L : RAM16X1D
			port map(
			DPO => DOCL(i),
			SPO => open,
			A0 => AddrA(0),
			A1 => AddrA(1),
			A2 => AddrA(2),
			A3 => '0',
			D => DIL(i),
			DPRA0 => AddrC(0),
			DPRA1 => AddrC(1),
			DPRA2 => AddrC(2),
			DPRA3 => '0',
			WCLK => Clk,
			WE => ENL);
	end generate;

end;
