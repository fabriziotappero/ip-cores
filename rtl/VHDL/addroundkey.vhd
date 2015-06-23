-------------------------------------------------------------------------------
-- This file is part of the project  avs_aes
-- see:  http://opencores.org/project,avs_aes
--
-- description:
-- AddRoundKey module for AES algorithm, basically a simple XOR for states and
-- keyblocks.... just a simple XOR wrapped into a component for nicer usage.
--
--
-------------------------------------------------------------------------------
-- Author(s):
--	   Thomas Ruschival -- ruschi@opencores.org (www.ruschival.de)
--
--------------------------------------------------------------------------------
-- Copyright (c) 2009, Thomas Ruschival
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--    * Redistributions of source code must retain the above copyright notice,
--    this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
--    * Neither the name of the  nor the names of its contributors
--    may be used to endorse or promote products derived from this software without
--    specific prior written permission.
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
-- OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
-- THE POSSIBILITY OF SUCH DAMAGE
-------------------------------------------------------------------------------
-- version management:
-- $Author::                                         $
-- $Date::                                           $
-- $Revision::                                       $			
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library avs_aes_lib;
use avs_aes_lib.avs_aes_pkg.all;

entity AddRoundKey is
	port (
		roundkey	: in  KEYBLOCK;		-- Roundkey
		cypherblock : in  STATE;		-- State for this round
		result		: out STATE);		-- result
end entity AddRoundKey;

architecture arch1 of AddRoundKey is

begin  -- architecture arch1

	-- purpose: Adding (Xor) roundkey words with Keywords
	-- type	  : combinational
	-- inputs : cypherblock, roundkey
	-- outputs: result
	Xoring : process (cypherblock, roundkey) is
	begin  -- process Xoring
		for cnt in cypherblock'range loop
			result(cnt) <= cypherblock(cnt) xor roundkey(cnt);
		end loop;  -- cnt
	end process Xoring;

end architecture arch1;
