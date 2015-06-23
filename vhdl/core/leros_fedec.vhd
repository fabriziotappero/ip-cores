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

-- fetch and decode stage

entity leros_fedec is
	port  (
		clk : in std_logic;
		reset : in std_logic;
		din : in fedec_in_type;
		dout : out fedec_out_type
	);
end leros_fedec;

architecture rtl of leros_fedec is

	signal imin : im_in_type;
	signal imout : im_out_type;
	
	signal zf, do_branch : std_logic;
	
	signal pc, pc_next, pc_op, pc_add : unsigned(IM_BITS-1 downto 0);
	signal decode : decode_type;

begin

	dout.pc <= std_logic_vector(pc_add);
	
	imin.rdaddr <= std_logic_vector(pc_next);
	
	im: entity work.leros_im port map(
		clk, reset, imin, imout
	);

	dec: entity work.leros_decode port map(
		imout.data(15 downto 8), decode
	);
	
-- DM address selection
process(decode, din, imout)
	variable addr : std_logic_vector(15 downto 0);
begin
	addr := std_logic_vector(unsigned(din.dm_data) + unsigned(imout.data(7 downto 0)));
	-- MUX for indirect load/store (from unregistered decode)
	if decode.indls='1' then
		dout.dm_addr <= addr(DM_BITS-1 downto 0);
	else
		-- If DM > 256 zero extend the varidx
		dout.dm_addr <= imout.data(DM_BITS-1 downto 0);
	end if;

end process;

-- branch 
process(decode, din, do_branch, imout, pc, pc_add, pc_op, zf)
begin
	-- should be checked in ModelSim
	if unsigned(din.accu)=0 then
		zf <= '1';
	else
		zf <= '0';
	end if;
	do_branch <= '0'; -- is setting and reading a signal in on process ok style?
	
	-- check branch condition
	if decode.br_op='1' then
		case imout.data(10 downto 8) is
			when "000" =>		-- branch
				do_branch <= '1';
			when "001" =>		-- brz
				if zf='1' then
					do_branch <= '1';
				end if;
			when "010" =>		-- brnz
				if zf='0' then
					do_branch <= '1';
				end if;
			when "011" =>		-- brp
				if din.accu(15)='0' then
					do_branch <= '1';
				end if;
			when "100" =>		-- brn
				if din.accu(15)='1' then
					do_branch <= '1';
				end if;
			when others =>
				null;
		end case;
	end if;
	
	-- shall we do the branch in the ex stage so
	-- we will have a real branch delay slot?
	-- branch
	if do_branch='1' then
		pc_op <= unsigned(resize(signed(imout.data(7 downto 0)), IM_BITS));
	else
		pc_op <= to_unsigned(1, IM_BITS);
	end if;
	pc_add <= pc + pc_op;
	-- jump and link
	if decode.jal='1' then
		pc_next <= unsigned(din.accu(IM_BITS-1 downto 0));
	else
		pc_next <= pc_add;
	end if;
	
end process;
	
-- pc register
process(clk, reset)
begin
	if reset='1' then
		pc <= (others => '0');
	elsif rising_edge(clk) then
		pc <= pc_next;
		dout.dec <= decode;
--		if decode.add_sub='1' then
		-- sign extension depends on loadh?????
		if decode.loadh='1' then
			dout.imm(7 downto 0) <= (others => '0');
			dout.imm(15 downto 8) <= imout.data(7 downto 0);
		else
			dout.imm <= std_logic_vector(resize(signed(imout.data(7 downto 0)), 16));
		end if;
--		else
--			immr(7 downto 0) <= imout.data(7 downto 0);
--			immr(15 downto 0) <= (others => '0');
--		end if;
	end if;
end process;

end rtl;