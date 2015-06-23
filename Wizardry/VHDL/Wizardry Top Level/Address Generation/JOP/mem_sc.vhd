--
--
--  This file is a part of JOP, the Java Optimized Processor
--
--  Copyright (C) 2001-2008, Martin Schoeberl (martin@jopdesign.com)
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--


--
--	mem_sc.vhd
--
--	External memory interface with SimpCon.
--	Translates between JOP/extension memory interface
--	and SimpCon memory interface.
--	Does the method cache load.
--
--
--	todo:
--
--	2005-11-22  first version adapted from mem(_wb)
--	2006-06-15	removed unnecessary state in BC load
--				len decrement in bc_rn and exit from bc_wr
--	2007-04-13	Changed memory connection to records
--	2007-04-14	xaload and xastore in hardware
--	2008-02-19	put/getfield in hardware
--	2008-04-30  copy step in hardware
--	2008-10-10	correct array access for fast (SPM) memory (+iald23 state)
--

Library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.jop_types.all;
use work.sc_pack.all;

entity mem_sc is
generic (jpc_width : integer; block_bits : integer);

port (

-- jop interface

	clk, reset	: in std_logic;

	ain		: in std_logic_vector(31 downto 0);		-- TOS
	bin		: in std_logic_vector(31 downto 0);		-- NOS

-- exceptions

	np_exc		: out std_logic;
	ab_exc		: out std_logic;

-- extension connection
	mem_in		: in mem_in_type;
	mem_out		: out mem_out_type;

-- jbc connections

	jbc_addr	: in std_logic_vector(jpc_width-1 downto 0);
	jbc_data	: out std_logic_vector(7 downto 0);

-- SimpCon interface

	sc_mem_out	: out sc_out_type;
	sc_mem_in	: in sc_in_type
);
end mem_sc;

architecture rtl of mem_sc is

component cache is
generic (jpc_width : integer; block_bits : integer);

port (

	clk, reset	: in std_logic;

	bc_len		: in std_logic_vector(METHOD_SIZE_BITS-1 downto 0);	-- length of method in words
	bc_addr		: in std_logic_vector(17 downto 0);		-- memory address of bytecode

	find		: in std_logic;					-- start lookup

	bcstart		: out std_logic_vector(jpc_width-3 downto 0); 	-- start of method in bc cache

	rdy		: out std_logic;				-- lookup finished
	in_cache	: out std_logic					-- method is in cache

);
end component;

--
--	jbc component (use technology specific vhdl-file cyc_jbc,...)
--
--	ajbc,xjbc are OLD!
--	check if ajbc.vhd can still be used (multicycle write!)
--
--	dual port ram
--	wraddr and wrena registered
--	rdaddr is registered
--	indata registered
--	outdata is unregistered
--

component jbc is
generic (jpc_width : integer);
port (
	clk		: in std_logic;
	data		: in std_logic_vector(31 downto 0);
	rd_addr		: in std_logic_vector(jpc_width-1 downto 0);
	wr_addr		: in std_logic_vector(jpc_width-3 downto 0);
	wr_en		: in std_logic;
	q		: out std_logic_vector(7 downto 0)
);
end component;


--
--	signals for mem interface
--
	type state_type		is (
							idl, rd1, wr1,
							bc_cc, bc_r1, bc_w, bc_rn, bc_wr, bc_wl,
							iald0, iald1, iald2, iald23, iald3, iald4,
							iasrd, ialrb,
							iast0, iaswb, iasrb, iasst,
							gf0, gf1, gf2, gf3,
							pf0, pf3,
							cp0, cp1, cp2, cp3, cp4, cpstop,
							last,
							npexc, abexc, excw
						);
	signal state 		: state_type;
	signal next_state	: state_type;

	-- length should be 'real' RAM size and not RAM + Flash + NAND
	-- should also be considered in the cacheable range

	-- addr_reg used to 'store' the address for wr, bc load, and array access
	signal addr_reg		: unsigned(SC_ADDR_SIZE-1 downto 0);
	signal addr_next	: unsigned(SC_ADDR_SIZE-1 downto 0);

	-- MUX for SimpCon address and write data
	signal ram_addr		: std_logic_vector(SC_ADDR_SIZE-1 downto 0);
	signal ram_wr_data	: std_logic_vector(31 downto 0);

--
--      signals for access from the state machine
--
	signal state_bsy	: std_logic;
	signal state_rd		: std_logic;
	signal state_wr		: std_logic;

--
--	signals for object and array access
--
	signal index		: std_logic_vector(SC_ADDR_SIZE-1 downto 0);	-- array or field index
	signal value		: std_logic_vector(31 downto 0);		-- store value

	signal null_pointer	: std_logic;
	signal bounds_error	: std_logic;

	signal was_a_store	: std_logic;

--
--	values for bytecode read/cache
--
--	len is in words, 10 bits range is 'hardcoded' in JOPWriter.java
--	start is address in external memory (rest of the word)
--
	signal bc_len		: unsigned(METHOD_SIZE_BITS-1 downto 0);	-- length of method in words
	signal inc_addr_reg	: std_logic;
	signal dec_len		: std_logic;
	signal bc_wr_addr	: unsigned(jpc_width-3 downto 0);	-- address for jbc (in words!)
	signal bc_wr_data	: std_logic_vector(31 downto 0);	-- write data for jbc
	signal bc_wr_ena	: std_logic;

--
--	signals for cache connection
--
	signal cache_rdy	: std_logic;
	signal cache_in_cache	: std_logic;
	signal cache_bcstart	: std_logic_vector(jpc_width-3 downto 0);

--
-- signals for copying and address translation
--
	signal base_reg		: unsigned(SC_ADDR_SIZE-1 downto 0);
	signal pos_reg		: unsigned(SC_ADDR_SIZE-1 downto 0);
    signal offset_reg	: unsigned(SC_ADDR_SIZE-1 downto 0);
	signal translate_bit : std_logic;
	signal cp_stopbit   : std_logic;

begin

process(sc_mem_in, state_bsy, state)
begin
	mem_out.bsy <= '0';
	if sc_mem_in.rdy_cnt=3 then
		mem_out.bsy <= '1';
	else
		if state/=ialrb and state/=last and state_bsy='1' then
			mem_out.bsy <= '1';
		end if;
	end if;
end process;

	mem_out.bcstart <= std_logic_vector(to_unsigned(0, 32-jpc_width)) & cache_bcstart & "00";


	np_exc <= null_pointer;
	ab_exc <= bounds_error;

	-- change byte order for jbc memory (high byte first)
	bc_wr_data <= sc_mem_in.rd_data(7 downto 0) &
				sc_mem_in.rd_data(15 downto 8) &
				sc_mem_in.rd_data(23 downto 16) &
				sc_mem_in.rd_data(31 downto 24);


	cmp_cache: cache generic map (jpc_width, block_bits) port map(
		clk, reset,
		std_logic_vector(bc_len), std_logic_vector(addr_reg(17 downto 0)),
		mem_in.bc_rd,
		cache_bcstart,
		cache_rdy, cache_in_cache
	);


	cmp_jbc: jbc generic map (jpc_width)
	port map(
		clk => clk,
		data => bc_wr_data,
		wr_en => bc_wr_ena,
		wr_addr => std_logic_vector(bc_wr_addr),
		rd_addr => jbc_addr,
		q => jbc_data
	);

--
--	SimpCon connections
--

	sc_mem_out.address <= ram_addr;
	sc_mem_out.wr_data <= ram_wr_data;
	sc_mem_out.rd <= mem_in.rd or state_rd;
	sc_mem_out.wr <= mem_in.wr or state_wr;
	mem_out.dout <= sc_mem_in.rd_data;


--
--	Store the write address
--	TODO: wouldn't it be easier to use A and B
--		for data and address with a single write
--		command?
--		- see jvm.asm...
--
--	and array access stores
--
process(clk, reset)
begin
	if reset='1' then
		addr_reg <= (others => '0');
		index <= (others => '0');
		value <= (others => '0');
		was_a_store <= '0';
		bc_len <= (others => '0');

		base_reg <= (others => '0');
		pos_reg <= (others => '0');
		offset_reg <= (others => '0');
		
	elsif rising_edge(clk) then
		if mem_in.bc_rd='1' then
			bc_len <= unsigned(ain(METHOD_SIZE_BITS-1 downto 0));
		else
			if dec_len='1' then
				bc_len <= bc_len-1;
			end if;
		end if;

		-- save array address and index
		if mem_in.iaload='1' or mem_in.getfield='1' then
			index <= ain(SC_ADDR_SIZE-1 downto 0);		-- store array index
		end if;
		-- first step of three-operand operations
		if mem_in.iastore='1' or mem_in.putfield='1' then
			value <= ain;
		end if;
		-- get reference and index for putfield and array stores
		if state=pf0 or state=iast0 then
			index <= ain(SC_ADDR_SIZE-1 downto 0);		-- store array index			
		end if;

		-- get source and index for copying
		if mem_in.copy='1' then
			base_reg <= unsigned(bin(SC_ADDR_SIZE-1 downto 0));
			pos_reg <= unsigned(ain(SC_ADDR_SIZE-1 downto 0)) + unsigned(bin(SC_ADDR_SIZE-1 downto 0));
			cp_stopbit <= ain(31);
		end if;
		-- get destination for copying
		if state=cp0 then
			offset_reg <= unsigned(bin(SC_ADDR_SIZE-1 downto 0)) - base_reg;
		end if;

		-- address and data tweaking for copying
		if state=cp3 then
			pos_reg <= pos_reg+1;
			value <= sc_mem_in.rd_data;
		end if;
		if state=cpstop then
			pos_reg <= base_reg;
		end if;

		-- precompute address translation
		if addr_next >= base_reg and addr_next < pos_reg then
			translate_bit <= '1';
		else
			translate_bit <= '0';
		end if;
		addr_reg <= addr_next;
		
		-- set flag for state sharing
		if mem_in.iaload='1' or mem_in.getfield='1' then
			was_a_store <= '0';
		elsif mem_in.iastore='1' or mem_in.putfield='1' then
			was_a_store <= '1';
		end if;		
	end if;
end process;


--
--	RAM address MUX (combinational)
--
process(ain, addr_reg, offset_reg, mem_in, base_reg, pos_reg, translate_bit)
begin
	if mem_in.rd='1' then
		if unsigned(ain(SC_ADDR_SIZE-1 downto 0)) >= base_reg and unsigned(ain(SC_ADDR_SIZE-1 downto 0)) < pos_reg then
			ram_addr <= std_logic_vector(unsigned(ain(SC_ADDR_SIZE-1 downto 0)) + offset_reg);
		else
			ram_addr <= ain(SC_ADDR_SIZE-1 downto 0);
		end if;
	else
		-- default is the registered address for wr, bc load
		if translate_bit='1' then
			ram_addr <= std_logic_vector(addr_reg(SC_ADDR_SIZE-1 downto 0) + offset_reg);
		else
			ram_addr <= std_logic_vector(addr_reg(SC_ADDR_SIZE-1 downto 0));
		end if;
	end if;
end process;

--
-- prepare RAM address registering
--
process(addr_reg, sc_mem_in, mem_in, ain, bin, state, inc_addr_reg, index, pos_reg, offset_reg)
begin

	-- default values
	addr_next <= addr_reg;	
	if inc_addr_reg='1' then
		addr_next <= addr_reg+1;
	end if;

	-- computations that depend on mem_in
	if mem_in.addr_wr='1' then
		addr_next <= unsigned(ain(SC_ADDR_SIZE-1 downto 0));
	end if;
	
	if mem_in.bc_rd='1' then
		addr_next(17 downto 0) <= unsigned(ain(27 downto 10));
		-- addr_bits is 17
		if SC_ADDR_SIZE>18 then
			addr_next(SC_ADDR_SIZE-1 downto 18) <= (others => '0');
		end if;
	end if;
	
	if mem_in.iaload='1' or mem_in.getfield='1' then
		addr_next <= unsigned(bin(SC_ADDR_SIZE-1 downto 0));
	end if;

	-- computations that depend on the state
	if state=pf0 or state=iast0 then
		addr_next <= unsigned(bin(SC_ADDR_SIZE-1 downto 0));
	end if;

	-- get/putfield could be optimized for faster memory (e.g. SPM)
	if state=iald3 or state=iald23 or state=gf2 then
		addr_next <= unsigned(sc_mem_in.rd_data(SC_ADDR_SIZE-1 downto 0))+unsigned(index);
	end if;

	if state=cp0 then
		addr_next <= pos_reg;
	end if;		

	if state=cp3 then
		addr_next <= pos_reg + offset_reg;
	end if;
	
end process;


--
--	RAM write data MUX (combinational)
--
process(ain, addr_reg, mem_in, value)
begin
	if mem_in.wr='1' then
		ram_wr_data <= ain;
	else
		-- default is the registered value
		ram_wr_data <= value;
	end if;
end process;


--
--	next state logic
--
process(state, mem_in, sc_mem_in,
	cache_rdy, cache_in_cache, bc_len, value, index, 
	addr_reg, cp_stopbit, was_a_store)
begin

	next_state <= state;

	case state is

		when idl =>
			if mem_in.rd='1' then
				next_state <= rd1;
			elsif mem_in.wr='1' then
				next_state <= wr1;
			elsif mem_in.bc_rd='1' then
				next_state <= bc_cc;
			elsif mem_in.iaload='1' then
				next_state <= iald0;
			elsif mem_in.getfield='1' then
				next_state <= gf0;
			elsif mem_in.putfield='1' then
				next_state <= pf0;
			elsif mem_in.copy='1' then
				next_state <= cp0;				
			elsif mem_in.iastore='1' then
				next_state <= iast0;
			end if;

		-- after a read the idl state is the result cycle
		-- where the data is available
		when rd1 =>
			-- either 1 or 0
			if sc_mem_in.rdy_cnt(1)='0' then
				next_state <= idl;
			end if;

		-- We could avoid the idl state after wr1 to
		-- get back to back wr/wr or wr/rd.
		-- However, it is not used in JOP (at the moment).
		when wr1 =>
			-- either 1 or 0
			if sc_mem_in.rdy_cnt(1)='0' then
				next_state <= idl;
			end if;

--
--	bytecode read
--
		-- cache lookup
		when bc_cc =>
			if cache_rdy = '1' then
				if cache_in_cache = '1' then
					next_state <= idl;
				else
					next_state <= bc_r1;
				end if;
			end if;

		-- not in cache
		-- start first read
		when bc_r1 =>
			next_state <= bc_w;
			-- even for a two cycle memory we have to go to
			-- wait for the first time as rdy_cnt is 0 in
			-- this state. Becomes valid in the next cycle

		-- wait
		when bc_w =>
			-- this works with pipeline level 1
			-- if sc_mem_in.rdy_cnt(1)='0' then
			-- we need a pipeline level of 2 in
			-- the memory interface for this to work!
			if sc_mem_in.rdy_cnt/=3 then
				next_state <= bc_rn;
			end if;

		-- start read 2 to n
		when bc_rn =>
			next_state <= bc_wr;

		when bc_wr =>
			if bc_len=to_unsigned(0, jpc_width-3) then
				next_state <= bc_wl;
			else
				-- w. pipeline level 2
				if sc_mem_in.rdy_cnt/=3 then
					next_state <= bc_rn;
				else
					next_state <= bc_w;
				end if;
			end if;

		-- wait for the last ack
		when bc_wl =>
			if sc_mem_in.rdy_cnt(1)='0' then
				next_state <= idl;
			end if;

--
--	array access
--
		when iast0 =>
			-- just one cycle wait to store the value
			next_state <= iald0;

		--
		-- iald0 to iald3 are shared with iastore
		--
		when iald0 =>
			if addr_reg=0 then
				next_state <= npexc;
			elsif index(SC_ADDR_SIZE-1)='1' then
				next_state <= abexc;
			else
				next_state <= iald1;
			end if;
			
		when iald1 =>
			-- w. pipeline level 2
			-- would waste one cycle in a single cycle memory (similar
			-- to bc load) - SimpCon rd comes from registered state_rd.
			if sc_mem_in.rdy_cnt<=1 then
				next_state <= iald23;
			elsif sc_mem_in.rdy_cnt/=3 then
				next_state <= iald2;
			end if;

		--
		-- a quick hack for faster memory: we need to read
		-- it now! TODO: get better state names
		-- it's a mix of iald2 and iald3
		--
		when iald23 =>
			next_state <= iald4;
------ that's now load specific!
-- we start loading before we know the upper bound exception!
-- is there an issue with read peripherals????
			if was_a_store='1' then
				next_state <= iaswb;
			-- w. pipeline level 2
			elsif sc_mem_in.rdy_cnt/=3 then
				next_state <= iasrd;
			end if;

		when iald2 =>
			next_state <= iald3;

		when iald3 =>
			next_state <= iald4;
------ that's now load specific!
-- we start loading before we know the upper bound exception!
-- is there an issue with read peripherals????
			if was_a_store='1' then
				next_state <= iaswb;
			-- w. pipeline level 2
			elsif sc_mem_in.rdy_cnt/=3 then
				next_state <= iasrd;
			end if;

		when iald4 =>
			if sc_mem_in.rdy_cnt/=3 then
				next_state <= iasrd;
			end if;

		-- rdy_cnt is less than 3 we can move on
		when iasrd =>
			next_state <= ialrb;

		when ialrb =>
			-- can we optimize this when we increment index at some state?
			if unsigned(index) >= unsigned(sc_mem_in.rd_data(SC_ADDR_SIZE-1 downto 0)) then
				next_state <= abexc;
			-- either 1 or 0
			elsif sc_mem_in.rdy_cnt(1)='0' then
				next_state <= idl;
			end if;

		when iaswb =>
			if sc_mem_in.rdy_cnt(1)='0' then
				next_state <= iasrb;
			end if;

		when iasrb =>
			next_state <= iasst;
			-- can we optimize this when we increment index at some state?
			if unsigned(index) >= unsigned(sc_mem_in.rd_data(SC_ADDR_SIZE-1 downto 0)) then
				next_state <= abexc;
			end if;

		when iasst =>
			next_state <= last;

		when gf0 =>
			if addr_reg=0 then
				next_state <= npexc;
			else
				next_state <= gf1;
			end if;
		when gf1 =>
			-- either 1 or 0
			if sc_mem_in.rdy_cnt(1)='0' then
				next_state <= gf2;
			end if;
		when gf2 =>
			next_state <= gf3;
			if was_a_store='1' then
				next_state <= pf3;
			end if;
		when gf3 =>
			next_state <= last;

		when pf0 =>
			-- just one cycle wait to store the value
			next_state <= gf0;
			-- states pf1 and pf2 are shared with getfield
		when pf3 =>
			next_state <= last;

		when cp0 =>
			next_state <= cp1;
			if cp_stopbit = '1' then
				next_state <= cpstop;
			end if;
		when cp1 =>
			next_state <= cp2;
		when cp2 =>
			-- either 1 or 0
			if sc_mem_in.rdy_cnt(1)='0' then
				next_state <= cp3;
			end if;
		when cp3 =>
			next_state <= cp4;
		when cp4 =>
			next_state <= last;
		when cpstop =>
			next_state <= idl;
			
		when last =>
			-- either 1 or 0
			if sc_mem_in.rdy_cnt(1)='0' then
				next_state <= idl;
			end if;

		when npexc =>
			next_state <= excw;

		when abexc =>
			next_state <= excw;

		when excw =>
			if sc_mem_in.rdy_cnt="00" then
				next_state <= idl;
			end if;

	end case;
end process;

--
--	state machine register
--	output register
--
process(clk, reset)

begin
	if (reset='1') then
		state <= idl;
		bc_wr_ena <= '0';
		inc_addr_reg <= '0';
		dec_len <= '0';
		state_rd <= '0';
		state_bsy <= '0';
		null_pointer <= '0';
		bounds_error <= '0';
		state_wr <= '0';
		sc_mem_out.atomic	<= '0';

	elsif rising_edge(clk) then

		state <= next_state;

		bc_wr_ena <= '0';
		inc_addr_reg <= '0';
		dec_len <= '0';
		state_rd <= '0';
		null_pointer <= '0';
		bounds_error <= '0';
		state_wr <= '0';
		sc_mem_out.atomic	<= '0';

		case next_state is

			when idl =>
				state_bsy <= '0';

			when rd1 =>

			when wr1 =>

			when bc_cc =>
				state_bsy <= '1';
				-- cache check

			when bc_r1 =>
				-- setup data
				bc_wr_addr <= unsigned(cache_bcstart);
				-- first memory read
				inc_addr_reg <= '1';
				state_rd <= '1';
				sc_mem_out.atomic	<= '1';

			when bc_w =>
				-- wait
				sc_mem_out.atomic	<= '1';

			when bc_rn =>
				-- following memory reads
				inc_addr_reg <= '1';
				dec_len <= '1';
				state_rd <= '1';
				sc_mem_out.atomic	<= '1';

			when bc_wr =>
				-- BC write
				bc_wr_ena <= '1';
				sc_mem_out.atomic	<= '1';
				
				if bc_len=to_unsigned(1, jpc_width-3) then
					sc_mem_out.atomic	<= '0';				
				end if;

			when bc_wl =>
				-- wait for last (unnecessary read)

			when iast0 =>
				state_bsy <= '1';

			when iald0 =>
				state_rd <= '1';
				state_bsy <= '1';
				inc_addr_reg <= '1';
				sc_mem_out.atomic <= '1';

			when iald1 =>
				sc_mem_out.atomic <= '1';

			when iald2 =>
				state_rd <= '1';
				sc_mem_out.atomic <= '1';

			when iald23 =>
				state_rd <= '1';
				sc_mem_out.atomic <= '1';

			when iald3 =>
				sc_mem_out.atomic <= '1';

			when iald4 =>
				sc_mem_out.atomic <= '1';

			when iasrd =>
				state_rd <= '1';
				sc_mem_out.atomic <= '1';

			when ialrb =>
				sc_mem_out.atomic <= '1';

			when iaswb =>
				sc_mem_out.atomic <= '1';

			when iasrb =>
				sc_mem_out.atomic <= '1';
				
			when iasst =>
				state_wr <= '1';
				sc_mem_out.atomic <= '1';

			when gf0 =>
				state_rd <= '1';
				state_bsy <= '1';
				sc_mem_out.atomic <= '1';

			when gf1 =>
				sc_mem_out.atomic <= '1';

			when gf2 =>
				sc_mem_out.atomic <= '1';

			when gf3 =>
				state_rd <= '1';
				sc_mem_out.atomic <= '1';
                          
			when pf0 =>
				state_bsy <= '1';

			when pf3 =>
				state_wr <= '1';
				sc_mem_out.atomic <= '1';
                          
			when cp0 =>
				sc_mem_out.atomic <= '1';
				state_bsy <= '1';

			when cp1 =>
				state_rd <= '1';
				sc_mem_out.atomic <= '1';
				
			when cp2 =>
				sc_mem_out.atomic <= '1';

			when cp3 =>
				sc_mem_out.atomic <= '1';

			when cp4 =>
				state_wr <= '1';
				sc_mem_out.atomic <= '1';

			when cpstop =>

			when last =>
				sc_mem_out.atomic <= '1';

			when npexc =>
				null_pointer <= '1';

			when abexc =>
				bounds_error <= '1';

			when excw =>

		end case;
					
		-- increment in state write
		if state=bc_wr then
			bc_wr_addr <= bc_wr_addr+1;		-- next jbc address
		end if;
	end if;
end process;

end rtl;
