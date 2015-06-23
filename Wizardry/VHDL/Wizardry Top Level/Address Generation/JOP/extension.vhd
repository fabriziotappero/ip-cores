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
--	extension.vhd
--
--	contains interface to memory, multiplier and IO
--	MUX for din from stack
--	
--	resources on Cyclone
--	
--		 55 LCs (+xxx for mul)
--
--		ext_addr and wr are one cycle earlier than data
--		dout is read one cycle after rd
--
--	address mapping see jop_tpyes.vhd
--
--
--	2004-09-11	first version
--	2005-04-05	Reserve negative addresses for wishbone interface
--	2005-04-07	generate bsy from delayed wr or'ed with mem_out.bsy
--	2005-05-30	added wishbone interface
--	2005-11-28	Substitute WB interface by the SimpCon IO interface ;-)
--				All IO devices are now memory mapped
--	2007-04-13	Changed memory connection to records
--				New array instructions
--	2007-12-22	Correction of data MUX bug for array read access
--	2008-02-20	Removed memory - I/O muxing
--


library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

use work.jop_types.all;

entity extension is

port (
	clk, reset	: in std_logic;

-- core interface

	ain		: in std_logic_vector(31 downto 0);		-- TOS
	bin		: in std_logic_vector(31 downto 0);		-- NOS
	ext_addr	: in std_logic_vector(exta_width-1 downto 0);
	rd, wr		: in std_logic;
	bsy		: out std_logic;
	dout		: out std_logic_vector(31 downto 0);	-- to stack

-- memory interface
	mem_in		: out mem_in_type;
	mem_out		: in mem_out_type

);
end extension;

architecture rtl of extension is

--
--	components:
--

component mul is

port (
	clk			: in std_logic;

	ain			: in std_logic_vector(31 downto 0);
	bin			: in std_logic_vector(31 downto 0);
	wr			: in std_logic;		-- write starts multiplier
	dout		: out std_logic_vector(31 downto 0)
);
end component mul;

--
--	signals for mulitiplier
--
	signal mul_dout				: std_logic_vector(31 downto 0);
	signal mul_wr				: std_logic;

--
--	Signals
--
	signal mem_scio_rd			: std_logic;	-- memory or SimpCon IO read
	signal mem_scio_wr			: std_logic;	-- memory or SimpCon IO write
	signal wraddr_wr			: std_logic;

	signal wr_dly				: std_logic;	-- generate a bsy with delayed wr

	signal exr					: std_logic_vector(31 downto 0); 	-- extension data register

begin

	cmp_mul : mul
			port map (clk,
				ain, bin, mul_wr,
				mul_dout
		);

	dout <= exr;

--
--	read
--
--	TODO: the read MUX could be set by using the
--	according wr/ext_addr from JOP and not the
--	following rd/ext_addr
--	Than no intermixing of mul/mem and io operations
--	is allowed. But we are not using interleaved mul/mem/io
--	operations in jvm.asm anyway.
--
--	TAKE CARE when mem_out.bcstart is read!
--
--   ** bcstart is also read without a mem_bc_rd JOP wr !!! ***
--		=> a combinatorial mux select on rd and ext_adr==7!
--
--		The rest could be set with JOP wr start transaction 
--		Is this also true for io_data?
--
--	29.11.2005 evening: I think this solution driving the exr
--	mux from ext_addr is quite ok. The pipelining from rd/ext_adr
--	to A is fixed.
--
process(clk, reset)
begin
	if (reset='1') then
		exr <= (others => '0');
	elsif rising_edge(clk) then

		if (ext_addr=LDMRD) then
			exr <= mem_out.dout;
		elsif (ext_addr=LDMUL) then
			exr <= mul_dout;
		-- elsif (ext_addr=LDBCSTART) then
		else
			exr <= mem_out.bcstart;
		end if;

	end if;
end process;


--
--	write
--
process(clk, reset)
begin
	if (reset='1') then
		mem_scio_rd <= '0';
		mem_scio_wr <= '0';
		wraddr_wr <= '0';
		mem_in.bc_rd <= '0';
		mem_in.iaload <= '0';
		mem_in.iastore <= '0';
		mem_in.getfield <= '0';
		mem_in.putfield <= '0';
		mul_wr <= '0';
		wr_dly <= '0';


	elsif rising_edge(clk) then
		mem_scio_rd <= '0';
		mem_scio_wr <= '0';
		wraddr_wr <= '0';
		mem_in.bc_rd <= '0';
		mem_in.iaload <= '0';
		mem_in.iastore <= '0';
		mem_in.getfield <= '0';
		mem_in.putfield <= '0';
		mem_in.copy <= '0';
		mul_wr <= '0';

		wr_dly <= wr;

--
--	wr is generated in decode and one cycle earlier than
--	the data to be written (e.g. read address for the memory interface)
--
		if wr='1' then

			if ext_addr=STMRA then
				mem_scio_rd <= '1';		-- start memory or io read
			elsif ext_addr=STMWA then
				wraddr_wr <= '1';		-- store write address
			elsif ext_addr=STMWD then
				mem_scio_wr <= '1';		-- start memory or io write
			elsif ext_addr=STALD then
				mem_in.iaload <= '1';	-- start an array load
			elsif ext_addr=STAST then
				mem_in.iastore <= '1';	-- start an array store
			elsif ext_addr=STGF then
				mem_in.getfield <= '1';	-- start getfield
			elsif ext_addr=STPF then
				mem_in.putfield <= '1';	-- start getfield
			elsif ext_addr=STCP then
				mem_in.copy <= '1';		-- start copy
			elsif ext_addr=STMUL then
				mul_wr <= '1';			-- start multiplier
			-- elsif ext_addr=STBCR then
			else
				mem_in.bc_rd <= '1';	-- start bc read
			end if;
		end if;

	end if;
end process;

--
--	memory read/write
--
	mem_in.rd <= mem_scio_rd;
	mem_in.wr <= mem_scio_wr;
	mem_in.addr_wr <= wraddr_wr;

	-- a JOP wr generates the first bsy cycle
	-- the following are generated by the memory
	-- system or the SimpCon device
	bsy <= wr_dly or mem_out.bsy;


end rtl;
