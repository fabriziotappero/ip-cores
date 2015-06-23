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

package leros_types is

	-- should this later go to a lerso_config package?
	constant DM_BITS : integer := 8;
	constant IM_BITS : integer := 9;

	type alu_log_type is (op_and, op_or, op_xor, op_ld);
	
	type decode_type is record
		op : alu_log_type;
		al_ena : std_logic;
		ah_ena : std_logic;
		log_add : std_logic;
		add_sub : std_logic;
		shr : std_logic;
		sel_imm : std_logic;
		store : std_logic;
		outp : std_logic;
		inp : std_logic;
		-- the following are used *in* the decode stage, not in the ex stage
		indls : std_logic;
		br_op : std_logic;
		jal : std_logic;
		loadh : std_logic;
	end record;

	type im_in_type is record
		rdaddr : std_logic_vector(IM_BITS-1 downto 0);
		wraddr : std_logic_vector(IM_BITS-1 downto 0);
		wrdata : std_logic_vector(15 downto 0);
		wren : std_logic;
	end record;

	type im_out_type is record
		data : std_logic_vector(15 downto 0);
	end record;

	type fedec_in_type is record
		accu : std_logic_vector(15 downto 0);
		dm_data : std_logic_vector(15 downto 0);
	end record;

	type fedec_out_type is record
		dec : decode_type;
		imm : std_logic_vector(15 downto 0);
		dm_addr : std_logic_vector(DM_BITS-1 downto 0);
		pc : std_logic_vector(IM_BITS-1 downto 0);
	end record;

-- 	type ex_in_type is record
-- 		dec : decode_type;
-- 		imm : std_logic_vector(15 downto 0);
-- 	end record;

	type ex_out_type is record
		accu : std_logic_vector(15 downto 0);
		dm_data : std_logic_vector(15 downto 0);
	end record;
	
	type io_out_type is record
		addr : std_logic_vector(7 downto 0);
		rd : std_logic;
		wr : std_logic;
		wrdata : std_logic_vector(15 downto 0);
	end record;

	type io_in_type is record
		rddata : std_logic_vector(15 downto 0);
	end record;
	

end package;

