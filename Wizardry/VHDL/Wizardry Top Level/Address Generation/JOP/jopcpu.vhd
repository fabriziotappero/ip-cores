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
--	jopcpu.vhd
--
--	The JOP CPU
--
--	2007-03-16	creation
--	2007-04-13	Changed memory connection to records
--	2008-02-20	memory - I/O muxing after the memory controller (mem_sc)
--	2008-03-03	added scratchpad RAM
--	2008-03-04	correct MUX selection
--
--	todo: clean up: substitute all signals by records


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.jop_types.all;
use work.sc_pack.all;


entity jopcpu is

generic (
	jpc_width	: integer;			-- address bits of java bytecode pc = cache size
	block_bits	: integer;			-- 2*block_bits is number of cache blocks
	spm_width	: integer := 0		-- size of scratchpad RAM (in number of address bits)
);

port (
	clk		: in std_logic;
	reset	: in std_logic;

--
--	SimpCon memory interface
--
	sc_mem_out		: out sc_out_type;
	sc_mem_in		: in sc_in_type;

--
--	SimpCon IO interface
--
	sc_io_out		: out sc_out_type;
	sc_io_in		: in sc_in_type;

--
--	Interrupts from sc_sys
--
	irq_in			: in irq_bcf_type;
	irq_out			: out irq_ack_type;
	exc_req			: out exception_type
);
end jopcpu;

architecture rtl of jopcpu is

--
--	Signals
--

	signal stack_tos		: std_logic_vector(31 downto 0);
	signal stack_nos		: std_logic_vector(31 downto 0);
	signal rd, wr			: std_logic;
	signal ext_addr			: std_logic_vector(EXTA_WIDTH-1 downto 0);
	signal stack_din		: std_logic_vector(31 downto 0);

-- extension/mem interface

	signal mem_in			: mem_in_type;
	signal mem_out			: mem_out_type;

	signal sc_ctrl_mem_out	: sc_out_type;
	signal sc_ctrl_mem_in	: sc_in_type;

	signal sc_scratch_out	: sc_out_type;
	signal sc_scratch_in	: sc_in_type;

	signal next_mux_mem		: std_logic_vector(1 downto 0);
	signal dly_mux_mem		: std_logic_vector(1 downto 0);
	signal mux_mem			: std_logic_vector(1 downto 0);
	signal is_pipelined		: std_logic;

	signal mem_access		: std_logic;
	signal scratch_access	: std_logic;
	signal io_access		: std_logic;

	signal bsy				: std_logic;

	signal jbc_addr			: std_logic_vector(jpc_width-1 downto 0);
	signal jbc_data			: std_logic_vector(7 downto 0);

-- SimpCon io interface

	signal sp_ov			: std_logic;

begin

--
--	components of jop
--

	cmp_core: entity work.core
		generic map(jpc_width)
		port map (clk, reset,
			bsy,
			stack_din, ext_addr,
			rd, wr,
			jbc_addr, jbc_data,
			irq_in, irq_out, sp_ov,
			stack_tos, stack_nos
		);

	exc_req.spov <= sp_ov;

	cmp_ext: entity work.extension 
		port map (
			clk => clk,
			reset => reset,
			ain => stack_tos,
			bin => stack_nos,

			ext_addr => ext_addr,
			rd => rd,
			wr => wr,
			bsy => bsy,
			dout => stack_din,

			mem_in => mem_in,
			mem_out => mem_out
		);

	cmp_mem: entity work.mem_sc
		generic map (
			jpc_width => jpc_width,
			block_bits => block_bits
		)
		port map (
			clk => clk,
			reset => reset,
			ain => stack_tos,
			bin => stack_nos,

			np_exc => exc_req.np,
			ab_exc => exc_req.ab,

			mem_in => mem_in,
			mem_out => mem_out,
	
			jbc_addr => jbc_addr,
			jbc_data => jbc_data,

			sc_mem_out => sc_ctrl_mem_out,
			sc_mem_in => sc_ctrl_mem_in
		);


	--
	-- Generate scratchpad memory when size is != 0.
	-- Results in warnings when the size is 0.
	--
	sc1: if spm_width /= 0 generate
		cmp_scm: entity work.sdpram
			generic map (
				width => 32,
				addr_width => spm_width
			)
			port map (
				wrclk => clk,
				data => sc_scratch_out.wr_data,
				wraddress => sc_scratch_out.address(spm_width-1 downto 0),
				wren => sc_scratch_out.wr,
				rdclk => clk,
				rdaddress => sc_scratch_out.address(spm_width-1 downto 0),
				rden => sc_scratch_out.rd,
				dout => sc_scratch_in.rd_data
		);
	end generate;

	sc_scratch_in.rdy_cnt <= (others => '0');

	--
	--	Select for the read mux
	--
	--	TODO: this mux selection works ONLY for two cycle pipelining!
	--

process(clk, reset)
begin
	if (reset='1') then
		dly_mux_mem <= (others => '0');
		next_mux_mem <= (others => '0');
		is_pipelined <= '0';
	elsif rising_edge(clk) then

		if sc_ctrl_mem_out.rd='1' or sc_ctrl_mem_out.wr='1' then
			-- highest address bits decides between IO, memory, and on-chip memory
			-- save the mux selection on read or write
			next_mux_mem <= sc_ctrl_mem_out.address(SC_ADDR_SIZE-1 downto SC_ADDR_SIZE-2);
			-- a read or write with rdy_cnt of 1 means pipelining
			if sc_ctrl_mem_in.rdy_cnt(1) = '0' then
				is_pipelined <= '1';
			end if;
		end if;
		-- delayed mux selection for pipelined access
		if sc_ctrl_mem_in.rdy_cnt(1) = '0' then
			dly_mux_mem <= next_mux_mem;
		end if;
		-- pipelining is over
		if sc_ctrl_mem_in.rdy_cnt = "00" then
			is_pipelined <= '0';
		end if;

	end if;
end process;

process(next_mux_mem, dly_mux_mem, sc_ctrl_mem_out, sc_ctrl_mem_in, sc_mem_in, sc_io_in, sc_scratch_in, is_pipelined, mux_mem)
begin

	mem_access <= '0';
	scratch_access <= '0';
	io_access <= '0';

	-- for one cycle peripherals we need to set the mux from next_mux_mem
	mux_mem <= next_mux_mem;
	-- for pipelining we need to delay the mux selection
	if is_pipelined='1' then
		mux_mem <= dly_mux_mem;
	end if;

	-- read MUX
	case mux_mem is
		when "10" =>
			sc_ctrl_mem_in <= sc_scratch_in;
		when "11" =>
			sc_ctrl_mem_in <= sc_io_in;
		when others =>
			sc_ctrl_mem_in <= sc_mem_in;
	end case;

	-- select
	case sc_ctrl_mem_out.address(SC_ADDR_SIZE-1 downto SC_ADDR_SIZE-2) is
		when "10" =>
			scratch_access <= '1';
		when "11" =>
			io_access <= '1';
		when others =>
			mem_access <= '1';
	end case;

end process;

	sc_mem_out.address <= sc_ctrl_mem_out.address;
	sc_mem_out.wr_data <= sc_ctrl_mem_out.wr_data;
	sc_mem_out.wr <= sc_ctrl_mem_out.wr and mem_access;
	sc_mem_out.rd <= sc_ctrl_mem_out.rd and mem_access;

	sc_scratch_out.address <= sc_ctrl_mem_out.address;
	sc_scratch_out.wr_data <= sc_ctrl_mem_out.wr_data;
	sc_scratch_out.wr <= sc_ctrl_mem_out.wr and scratch_access;
	sc_scratch_out.rd <= sc_ctrl_mem_out.rd and scratch_access;

	sc_io_out.address <= sc_ctrl_mem_out.address;
	sc_io_out.wr_data <= sc_ctrl_mem_out.wr_data;
	sc_io_out.wr <= sc_ctrl_mem_out.wr and io_access;
	sc_io_out.rd <= sc_ctrl_mem_out.rd and io_access;

end rtl;
