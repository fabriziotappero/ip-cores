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
--	sc2wb.vhd
--
--	SimpCon/Wishbone bridge
--
--	Author: Martin Schoeberl	martin@jopdesign.com
--
--
--          
--          WISHBONE DATA SHEET
--          
--          Revision Level: B.3, Released: September 7, 2002
--          Type: MASTER
--          
--          Signals: record and address size is defined in wb_pack.vhd
--          
--          Port    Width   Direction   Description
--          ------------------------------------------------------------------------
--          clk       1     Input       Master clock, see JOP top level
--          reset     1     Input       Reset, see JOP top level
--          dat_o    32     Output      Data from SimpCon
--          adr_o     8     Output      Address bits for the slaves, see wb_pack.vhd
--                                      Only addr_bits bits are actually used
--          we_o      1     Output      Write enable output
--          cyc_o     1     Output      Valid bus cycle output
--          stb_o     1     Output      Strobe signal output
--          dat_i    32     Input       Data from the slaves to JOP
--          ack_i     1     Input       Bus cycle acknowledge input
--          
--          Port size: 32-bit
--          Port granularity: 32-bit
--          Maximum operand size: 32-bit
--          Data transfer ordering: BIG/LITTLE ENDIAN
--          Sequence of data transfer: UNDEFINED
--          
--          
--	2005-12-20	first version
--
--


library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

use work.wb_pack.all;

entity sc2wb is

generic (addr_bits : integer);
port (
	clk		: in std_logic;
	reset	: in std_logic;

-- SimpCon interface

	address		: in std_logic_vector(addr_bits-1 downto 0);
	wr_data		: in std_logic_vector(31 downto 0);
	rd, wr		: in std_logic;
	rd_data		: out std_logic_vector(31 downto 0);
	rdy_cnt		: out unsigned(1 downto 0);

-- Wishbone interfac

	wb_out	: out wb_master_out_type;
	wb_in	: in wb_master_in_type

);
end sc2wb;

architecture rtl of sc2wb is

--
--	Wishbone specific signals
--
	signal wb_data				: std_logic_vector(31 downto 0); 	-- output of wishbone module
	signal wb_addr				: std_logic_vector(7 downto 0);		-- wishbone read/write address
	signal wb_rd, wb_wr, wb_bsy	: std_logic;
	signal wb_rd_reg, wb_wr_reg	: std_logic;

begin

--
--	Wishbone interface
--

	-- just use the SimpCon rd/wr
	wb_rd <= rd;
	wb_wr <= wr;

	rd_data <= wb_data;

	wb_out.adr_o <= wb_addr;

	rdy_cnt <= "11" when wb_bsy='1' else "00";

--
--	Handle the Wishbone protocoll.
--	rd and wr request are registered for additional WSs.
--
process(clk, reset)
begin
	if (reset='1') then

		wb_addr <= (others => '0');

		wb_out.stb_o <= '0';
		wb_out.cyc_o <= '0';
		wb_out.we_o <= '0';

		wb_rd_reg <= '0';
		wb_wr_reg <= '0';
		wb_bsy <= '0';

	elsif rising_edge(clk) then

		-- read request:
		-- address is registered from SimpCon address and valid in the next
		-- cycle
		if wb_rd='1' then
			-- store read address
			wb_addr(M_ADDR_SIZE-1 downto addr_bits) <= (others => '0');
			wb_addr(addr_bits-1 downto 0) <= address;

			wb_out.stb_o <= '1';
			wb_out.cyc_o <= '1';
			wb_out.we_o <= '0';
			wb_rd_reg <= '1';
			wb_bsy <= '1';
		elsif wb_rd_reg='1' then
			-- do we need a timeout???
			if wb_in.ack_i='1' then
				wb_out.stb_o <= '0';
				wb_out.cyc_o <= '0';
				wb_rd_reg <= '0';
				wb_bsy <= '0';
				wb_data <= wb_in.dat_i;
			end if;
		-- write request
		-- address and data are stored and valid in
		-- the next cycle
		elsif wb_wr='1' then
			-- store write address
			wb_addr(M_ADDR_SIZE-1 downto addr_bits) <= (others => '0');
			wb_addr(addr_bits-1 downto 0) <= address;

			-- this keeps the write data registered,
			-- but costs a latency of one cycle.
			wb_out.dat_o <= wr_data;

			wb_out.stb_o <= '1';
			wb_out.cyc_o <= '1';
			wb_out.we_o <= '1';
			wb_wr_reg <= '1';
			wb_bsy <= '1';
		elsif wb_wr_reg='1' then
			-- do we need a timeout???
			if wb_in.ack_i='1' then
				wb_out.stb_o <= '0';
				wb_out.cyc_o <= '0';
				wb_out.we_o <= '0';
				wb_wr_reg <= '0';
				wb_bsy <= '0';
			end if;
		end if;

	end if;
end process;

end rtl;
