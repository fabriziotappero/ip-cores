--
--  Copyright 2011 Martin Schoeberl <masca@imm.dtu.dk>,
--                 Technical University of Denmark, DTU Informatics. 
--  All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
-- 
--    1. Redistributions of source code must retain the above copyright notice,
--       this list of conditions and the following disclaimer.
-- 
--    2. Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ``AS IS'' AND ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
-- OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
-- NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
-- THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- The views and conclusions contained in the software and documentation are
-- those of the authors and should not be interpreted as representing official
-- policies, either expressed or implied, of the copyright holder.
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.leros_types.all;

-- decode logic

entity leros_decode is
	port  (
		instr : in std_logic_vector(7 downto 0);
		dec : out decode_type
	);
end leros_decode;

architecture rtl of leros_decode is

begin

process(instr)
begin
	-- some defaults
	dec.op <= op_ld;
	dec.al_ena <= '0';
	dec.ah_ena <= '0';
	dec.log_add <= '0';
	dec.add_sub <= '0';
	dec.shr <= '0';
	dec.sel_imm <= '0';
	dec.store <= '0';
	dec.outp <= '0';
	dec.inp <= '0';
	-- used in decode, not in ex
	dec.br_op <= '0';
	dec.jal <= '0';
	dec.loadh <= '0';
	dec.indls<= '0';	
	
	-- start decoding
	dec.add_sub <= instr(2);
	dec.sel_imm <= instr(0);
	-- bit 1 and 2 partially unused
	case instr(7 downto 3) is
		when "00000" =>		-- nop
		when "00001" =>		-- add, sub
			dec.al_ena <= '1';
			dec.ah_ena <= '1';
			dec.log_add <= '1';
		when "00010" =>		-- shr
			dec.al_ena <= '1';
			dec.ah_ena <= '1';
			dec.shr <= '1';
		when "00011" =>		-- reserved
			null;
		when "00100" =>		-- alu
			dec.al_ena <= '1';
			dec.ah_ena <= '1';
		when "00101" =>		-- loadh
			dec.loadh <= '1';
			dec.ah_ena <= '1';
		when "00110" =>		-- store
			dec.store <= '1';
		when "00111" =>		-- I/O
			if instr(2)='0' then
				dec.outp <= '1';
			else
				dec.al_ena <= '1';
				dec.ah_ena <= '1';
				dec.inp <= '1';
			end if;
		when "01000" =>		-- jal
			dec.jal <= '1';
			dec.store <= '1';
		when "01001" =>		-- branch
			dec.br_op <= '1';
		when "01010" =>		-- loadaddr
			null;
		when "01100" =>		-- load indirect
			dec.al_ena <= '1';
			dec.ah_ena <= '1';
			dec.indls <= '1';
		when "01110" =>		-- store indirect
			dec.indls <= '1';
			dec.store <= '1';
		when others =>
			null;
	end case;

	case instr(2 downto 1) is
		when "00" =>
			dec.op <= op_ld;
		when "01" =>
			dec.op <= op_and;
		when "10" =>
			dec.op <= op_or;
		when "11" =>
			dec.op <= op_xor;
		when others =>
			null;
	end case;
end process;

end rtl;