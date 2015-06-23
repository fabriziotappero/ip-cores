-- SDHC-SC-Core
-- Secure Digital High Capacity Self Configuring Core
-- 
-- (C) Copyright 2010, Rainer Kastl
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--     * Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--     * Neither the name of the <organization> nor the
--       names of its contributors may be used to endorse or promote products
--       derived from this software without specific prior written permission.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS  "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- File        : TestWbMaster-e.vhdl
-- Owner       : Rainer Kastl
-- Description : Wishbone master for testing SDHC-SC-Core on the SbX
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TestWbMaster is
	port (
		-- Wishbone interface
		CLK_I : in std_ulogic;
		RST_I : in std_ulogic;

		-- Wishbone master
		ERR_I : in std_ulogic;
		RTY_I : in std_ulogic;
		ACK_I : in std_ulogic;
		DAT_I : in std_ulogic_vector(31 downto 0);

		CYC_O : out std_ulogic;
		STB_O : out std_ulogic;
		WE_O  : out std_ulogic;
		CTI_O : out std_ulogic_vector(2 downto 0);
		BTE_O : out std_ulogic_vector(1 downto 0);

		ADR_O : out std_ulogic_vector(6 downto 4);
		DAT_O : out std_ulogic_vector(31 downto 0);
		SEL_O : out std_ulogic_vector(0 downto 0);

		-- status signal
		LEDBANK_O : out std_ulogic_vector(7 downto 0)
	);
end entity TestWbMaster;

