--------------------------------------------------------------------------------
-- This file is part of the project  avs_aes
-- see: http://opencores.org/project,avs_aes
--
-- description: Mux2, 2-Port-N-Bit Bit Mulitplexer
--
-------------------------------------------------------------------------------
--
-- Author(s):
--	   Thomas Ruschival -- ruschi@opencores.org (www.ruschival.de)
--
--------------------------------------------------------------------------------
-- Copyright (c) 2009, Authors and opencores.org
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--    * Redistributions of source code must retain the above copyright notice,
--    this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
--    * Neither the name of the organization nor the names of its contributors
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


library ieee;
use ieee.std_logic_1164.all;

entity mux2 is
	generic (
		IOwidth : POSITIVE := 32			-- width of I/O ports
		);
	port (
		inport_a : in  STD_LOGIC_VECTOR (IOwidth-1 downto 0);  -- port 1
		inport_b : in  STD_LOGIC_VECTOR (IOwidth-1 downto 0);  -- port 2
		selector : in  STD_LOGIC;		-- switch to select ports
		outport	 : out STD_LOGIC_VECTOR (IOwidth-1 downto 0)   -- output
		); 
end mux2;


architecture arch1 of mux2 is

begin  -- arch1

	-- purpose: switch the ports
	-- type	  : combinational
	-- inputs : selector,inport_a,inport_b
	-- outputs: outport
	muxing : process (inport_a, inport_b, selector)
	begin  -- PROCESS selector
		-- default behaviour to avoid latch
		outport <= inport_a;
		case selector is
			when '0' =>
				outport <= inport_a;
			when '1' =>
				outport <= inport_b;
			when others =>
				--pragma synthesis_off
				report "!! selector in arch1 of mux2 has strange value !!" severity warning;
				--pragma synthesis_on
		end case;
	end process muxing;

end arch1;
