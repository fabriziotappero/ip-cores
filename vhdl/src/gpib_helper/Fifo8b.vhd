--------------------------------------------------------------------------------
--This file is part of fpga_gpib_controller.
--
-- Fpga_gpib_controller is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- Fpga_gpib_controller is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with Fpga_gpib_controller.  If not, see <http://www.gnu.org/licenses/>.
--------------------------------------------------------------------------------
-- Entity: Fifo8b
-- Date:2011-11-28  
-- Author: Andrzej Paluch
--
-- Description ${cursor}
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.utilPkg.all;
use work.helperComponents.all;


entity Fifo8b is
	generic (
		MAX_ADDR_BIT_NUM : integer := 10
	);
	port (
		reset : in std_logic;
		clk : in std_logic;
		-------------- fifo --------------------
		bytesAvailable : out std_logic;
		availableBytesCount : out std_logic_vector(MAX_ADDR_BIT_NUM downto 0);
		bufferFull : out std_logic;
		resetFifo : in std_logic;
		----------------------------------------
		data_in : in std_logic_vector(7 downto 0);
		ready_to_write :out std_logic;
		strobe_write : in std_logic;
		----------------------------------------
		data_out : out std_logic_vector(7 downto 0);
		ready_to_read : out std_logic;
		strobe_read : in std_logic
	);
end Fifo8b;

architecture arch of Fifo8b is

	constant ADDR_BITS_COUNT : integer := MAX_ADDR_BIT_NUM + 1;
	constant MEMORY_CELLS_COUNT : integer := 2**ADDR_BITS_COUNT;
	constant MAX_DATA_LENGTH : integer := MEMORY_CELLS_COUNT - 1;
	constant MAX_ADDR : integer := MAX_DATA_LENGTH;

	-------------- memory ----------------
	signal n_clk : std_logic;
	signal p1_addr : std_logic_vector(MAX_ADDR_BIT_NUM downto 0);
	signal p1_data_in : std_logic_vector(7 downto 0);
	signal p1_strobe : std_logic;
	signal p1_data_out : std_logic_vector(7 downto 0);
	-------------------------------------------------
	signal p2_addr : std_logic_vector(MAX_ADDR_BIT_NUM downto 0);
	signal p2_data_in : std_logic_vector(7 downto 0);
	signal p2_strobe : std_logic;
	signal p2_data_out : std_logic_vector(7 downto 0);

	------------- fifo --------------------
	signal writeAddr : integer range 0 to MAX_ADDR;
	signal readAddr : integer range 0 to MAX_ADDR;
	signal readAddrValid : std_logic;
	signal currentDataLen : integer range 0 to MAX_DATA_LENGTH;

	-------- control ----------------------
	signal ss_r, sr_r, ss_w, sr_w : std_logic;
	

begin

	n_clk <= not clk;

	p2_strobe <= '0';

	ready_to_write <= to_stdl((ss_w = sr_w) and currentDataLen < MAX_DATA_LENGTH);
	ready_to_read <= to_stdl((ss_r = sr_r) and currentDataLen > 0);

	bytesAvailable <= to_stdl(currentDataLen > 0);
	availableBytesCount <= conv_std_logic_vector(currentDataLen, ADDR_BITS_COUNT);

	p1_data_in <= data_in;
	data_out <= p2_data_out;

	bufferFull <= to_stdl(currentDataLen = MAX_DATA_LENGTH);

	p1_addr <= conv_std_logic_vector(writeAddr, ADDR_BITS_COUNT);
	p2_addr <= conv_std_logic_vector(readAddr, ADDR_BITS_COUNT);


	process (reset, clk) begin
		if reset = '1' then
			writeAddr <= 1;
			readAddr <= 0;
			readAddrValid <= '0';
	
			sr_w <= '0';
			sr_r <= '0';
			
			p1_strobe <= '0';
		elsif rising_edge(clk) then
			if resetFifo = '1' then
				writeAddr <= 1;
				readAddr <= 0;
				readAddrValid <= '0';
				
				sr_w <= ss_w;
				sr_r <= ss_r;
				
				p1_strobe <= '0';
			else
				if sr_w /= ss_w and currentDataLen < MAX_DATA_LENGTH and
						p1_strobe = '0' then
					p1_strobe <= '1';
				elsif sr_w /= ss_w and currentDataLen < MAX_DATA_LENGTH and
						p1_strobe = '1' then
					p1_strobe <= '0';
					sr_w <= ss_w;
					
					if writeAddr < MAX_ADDR then
						writeAddr <= writeAddr + 1;
					else
						writeAddr <= 0;
					end if;
					
					if readAddrValid = '0' then
						if readAddr < MAX_ADDR then
							readAddr <= readAddr + 1;
						else
							readAddr <= 0;
						end if;
					
						readAddrValid <= '1';
					end if;
				end if;
				
				if sr_r /= ss_r and currentDataLen > 0 and
						readAddrValid = '1' then
					sr_r <= ss_r;
					
					if currentDataLen = 1 and
						-- and last writing phase is not ongoing
						not(sr_w /= ss_w and p1_strobe = '1') then
							-- if writing is not ongoing
							readAddrValid <= '0';
					else
						if readAddr < MAX_ADDR then
							readAddr <= readAddr + 1;
						else
							readAddr <= 0;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	-- calculate current length
	process(writeAddr, readAddr, readAddrValid) begin
		if readAddrValid = '0' then
			currentDataLen <= 0;
		elsif readAddr < writeAddr then
			currentDataLen <= writeAddr - readAddr;
		else -- readAddr > writeAddr, readAddr = writeAddr shoud never happen
			currentDataLen <= (MEMORY_CELLS_COUNT - readAddr) + writeAddr;
		end if;
	end process;

	-- subscribe write
	process (reset, strobe_write) begin
		if reset = '1' then
			ss_w <= '0';
		elsif rising_edge(strobe_write) then
			if ss_w = sr_w then
				ss_w <= not sr_w;
			end if;
		end if;
	end process;

	-- subscribe read
	process (reset, strobe_read) begin
		if reset = '1' then
			ss_r <= '0';
		elsif rising_edge(strobe_read) then
			if ss_r = sr_r then
				ss_r <= not sr_r;
			end if;
		end if;
	end process;

	-- target memory
	mb: MemoryBlock port map (
		reset => reset,
		clk => n_clk,
		-------------------------------------------------
		p1_addr => p1_addr,
		p1_data_in => p1_data_in,
		p1_strobe => p1_strobe,
		p1_data_out => p1_data_out,
		-------------------------------------------------
		p2_addr => p2_addr,
		p2_data_in => p2_data_in,
		p2_strobe => p2_strobe,
		p2_data_out => p2_data_out
	);

end arch;

