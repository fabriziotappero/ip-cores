--
-- File I/O test-bench utilities
--
-- Version : 0146
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
--	http://www.opencores.org/cvsweb.shtml/t51/
--
-- Limitations :
--
-- File history :
--

library IEEE;
use IEEE.std_logic_1164.all;

package StimLog is

	component AsyncStim
	generic(
		FileName		: string;
		Baud			: integer;
		InterCharDelay	: time := 0 ns;
		Bits			: integer := 8;		-- Data bits
		Parity			: boolean := false;	-- Enable Parity
		P_Odd_Even_n	: boolean := false	-- false => Even Parity, true => Odd Parity
	);
	port(
		TXD				: out std_logic
	);
	end component;

	component AsyncLog
	generic(
		FileName		: string;
		Baud			: integer;
		Bits			: integer := 8;		-- Data bits
		Parity			: boolean := false;	-- Enable Parity
		P_Odd_Even_n	: boolean := false	-- false => Even Parity, true => Odd Parity
	);
	port(
		RXD				: in std_logic
	);
	end component;

	component BinaryStim
	generic(
		FileName		: string;
		Bytes			: integer := 1;		-- Number of bytes per word
		LittleEndian	: boolean := true	-- Byte order
	);
	port(
		Rd				: in std_logic;
		Data			: out std_logic_vector(Bytes * 8 - 1 downto 0)
	);
	end component;

	component BinaryLog
	generic(
		FileName		: string;
		Bytes			: integer := 1;		-- Number of bytes per word
		LittleEndian	: boolean := true	-- Byte order
	);
	port(
		Clk				: in std_logic;
		En				: in std_logic;
		Data			: in std_logic_vector(Bytes * 8 - 1 downto 0)
	);
	end component;

	component I2SStim is
	generic(
		FileName		: string;
		Bytes			: integer := 2;		-- Number of bytes per word (1 to 4)
		LittleEndian	: boolean := true	-- Byte order
	);
	port(
		BClk			: in std_logic;
		FSync			: in std_logic;
		SData			: out std_logic
	);
	end component;

	component I2SLog is
	generic(
		FileName		: string;
		Bytes			: integer := 2;		-- Number of bytes per word
		LittleEndian	: boolean := true	-- Byte order
	);
	port(
		BClk			: in std_logic;
		FSync			: in std_logic;
		SData			: in std_logic
	);
	end component;

	component IntegerLog is
	generic(
		FileName		: string
	);
	port(
		Clk				: in std_logic;
		En				: in std_logic;
		Data			: in integer
	);
	end component;

end;
