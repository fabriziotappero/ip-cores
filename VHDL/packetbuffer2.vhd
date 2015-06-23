
-----------------------------------------------------------------------------
-- NoCem -- Network on Chip Emulation Tool for System on Chip Research 
-- and Implementations
-- 
-- Copyright (C) 2006  Graham Schelle, Dirk Grunwald
-- 
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  
-- 02110-1301, USA.
-- 
-- The authors can be contacted by email: <schelleg,grunwald>@cs.colorado.edu 
-- 
-- or by mail: Campus Box 430, Department of Computer Science,
-- University of Colorado at Boulder, Boulder, Colorado 80309
-------------------------------------------------------------------------------- 


-- 
-- Filename: packetbuffer2.vhd
-- 
-- Description: packetbuffer for noc2proc bridging
-- 



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.pkg_nocem.all;


entity packetbuffer2 is
   generic(
--	 DATAIN_WIDTH : integer := 64;
--	 DATAOUT_WIDTH : integer := 32;
	 METADATA_WIDTH : integer := 8;
	 METADATA_LENGTH : integer := 8
	);	
    Port ( 
		din   : IN std_logic_VECTOR(31 downto 0);
		
		rd_en : IN std_logic;
		
		wr_en : IN std_logic;
		dout  : OUT std_logic_VECTOR(31 downto 0);
		empty : OUT std_logic;
		full  : OUT std_logic;



--		pkt_len : in std_logic_vector(7 downto 0);
		pkt_metadata_din 		: in std_logic_vector(METADATA_WIDTH-1 downto 0);		
		pkt_metadata_re		: IN std_logic;				
		pkt_metadata_we		: IN std_logic;
		pkt_metadata_dout 	: out std_logic_vector(METADATA_WIDTH-1 downto 0);
		--pkt_metadata_empty	: out std_logic;
		--pkt_metadata_full		: out std_logic	 
	 	clk : in std_logic;
      rst : in std_logic);
end packetbuffer2;

architecture Behavioral of packetbuffer2 is

	COMPONENT fifo32
	PORT(
		din : IN std_logic_vector(31 downto 0);
		rd_clk : IN std_logic;
		rd_en : IN std_logic;
		rst : IN std_logic;
		wr_clk : IN std_logic;
		wr_en : IN std_logic;          
		dout : OUT std_logic_vector(31 downto 0);
		empty : OUT std_logic;
		full : OUT std_logic
		);
	END COMPONENT;


	signal pb_full,pkt_metadata_full,pb_empty,pkt_metadata_empty : std_logic;

begin

	full <= pb_full or pkt_metadata_full;
	--empty <= pb_empty and pkt_metadata_empty;
	empty <= pkt_metadata_empty;

-- lets just wrap a 32/32 FIFO and let outside world set up reads and write appropriately.

		fifo_pb : fifo32 PORT MAP(
			din => din,
			rd_clk => clk,
			rd_en => rd_en,
			rst => rst,
			wr_clk => clk,
			wr_en => wr_en,
			dout => dout,
			empty => pb_empty,
			full => pb_full
		);						  	

	

	
	I_metadata : fifo_gfs 
	Generic MAP(
		WIDTH => METADATA_WIDTH,
		ADD_WIDTH => Log2(METADATA_LENGTH)
	)		
	PORT MAP(
		Data_in => pkt_metadata_din,
		clk => clk,
		Reset => rst,
		RE => pkt_metadata_re,
		WE => pkt_metadata_we,
		Data_out => pkt_metadata_dout,
		Full => pkt_metadata_full,
		Half_full => open,
		empty => pkt_metadata_empty
	);


end Behavioral;
