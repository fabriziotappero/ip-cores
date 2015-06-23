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
--	xs3_jbc.vhd
--
--	bytecode memory/cache for JOP
--	Version for Xilinx Spartan-3
--
--	address, data in are registered
--	data out is unregistered
--
--
--	Changes:
--		2003-08-14	load start address with jpc_wr and do autoincrement
--					load 32 bit data and do the 4 byte writes serial
--		2005-02-17	extracted again from mem32.vhd
--		2005-05-03	address width is jpc_width
--		2005-11-24	adapted for S3
--
--

library ieee;
use ieee.std_logic_1164.all;
Library UNISIM;
use UNISIM.vcomponents.all;

entity jbc is
generic (jpc_width : integer);
port (
	clk			: in std_logic;
	data		: in std_logic_vector(31 downto 0);
	rd_addr		: in std_logic_vector(jpc_width-1 downto 0);
	wr_addr		: in std_logic_vector(jpc_width-3 downto 0);
	wr_en		: in std_logic;
	q			: out std_logic_vector(7 downto 0)
);
end jbc;

--
--	registered wraddress, wren
--	registered din
--	registered rdaddress
--	unregistered dout
--
architecture rtl of jbc is


----- Component RAMB16_S9_S36 -----
component RAMB16_S9_S36 
--
  generic (
	   WRITE_MODE_A : string := "WRITE_FIRST";
	   WRITE_MODE_B : string := "WRITE_FIRST";
	   INIT_A : bit_vector  := X"000";
	   SRVAL_A : bit_vector  := X"000";

	   INIT_B : bit_vector  := X"000000000";
	   SRVAL_B : bit_vector  := X"000000000"
  );
--
  port (DIA	: in STD_LOGIC_VECTOR (7 downto 0);
		DIB	: in STD_LOGIC_VECTOR (31 downto 0);
		DIPA	: in STD_LOGIC_VECTOR (0 downto 0);
		DIPB	: in STD_LOGIC_VECTOR (3 downto 0);
		ENA	: in STD_logic;
		ENB	: in STD_logic;
		WEA	: in STD_logic;
		WEB	: in STD_logic;
		SSRA   : in STD_logic;
		SSRB   : in STD_logic;
		CLKA   : in STD_logic;
		CLKB   : in STD_logic;
		ADDRA  : in STD_LOGIC_VECTOR (10 downto 0);
		ADDRB  : in STD_LOGIC_VECTOR (8 downto 0);
		DOA	: out STD_LOGIC_VECTOR (7 downto 0);
		DOB	: out STD_LOGIC_VECTOR (31 downto 0);
		DOPA	: out STD_LOGIC_VECTOR (0 downto 0);
		DOPB	: out STD_LOGIC_VECTOR (3 downto 0)
	   ); 

end component;

begin
	-- the block ram is 2KB
	assert jpc_width=11 report "Xilinx jbc is fixed to 2KB - use jbc_width of 11";

	cmp_jbc : RAMB16_S9_S36 
	port map (
  		DIA => "00000000",
		DIB => data,
		DIPA => "0",
		DIPB => "0000",
		ENA => '1',
		ENB => '1',
		WEA => '0',
		WEB => wr_en,
		SSRA => '0',
		SSRB => '0',
		CLKA => clk,
		CLKB => clk,
		ADDRA => rd_addr,
		ADDRB => wr_addr,
		DOA => q,
		DOB => open,
		DOPA => open,
		DOPB => open
	);

end rtl;
