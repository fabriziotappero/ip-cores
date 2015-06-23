
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
-- Filename: fifo_allvhdl.vhd
-- 
-- Description: a vhdl based FIFO implementation
-- 


-------------------------------------------------------------------------------
--
-- This implementation was heavily modified from 
--       http://www.geocities.com/SiliconValley/Pines/6639/ip/fifo_vhdl.html
--
-- and the following comment section describes the licensing and authorship
-- 
--	
-- NOTES:
--		1. removed buffer type ports because they are bad
--		2. usig FIFO_v7
--    
--
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 
-- Copyright Jamil Khatib 1999
-- 
--
-- This VHDL design file is an open design; you can redistribute it and/or
-- modify it and/or implement it under the terms of the Openip General Public
-- License as it is going to be published by the OpenIP Organization and any
-- coming versions of this license.
-- You can check the draft license at
-- http://www.openip.org/oc/license.html
--
--
-- Creator : Jamil Khatib
-- Date 10/10/99
--
-- version 0.19991226
--
-- This file was tested on the ModelSim 5.2EE
-- The test vecors for model sim is included in vectors.do file
-- This VHDL design file is proved through simulation but not verified on Silicon
-- 
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
--entity listing in this file
--
--	1. dpmem: used in Khatib's FIFO implementation
--	3. fifo_allvhdl: my wrapper to match nocem interfaces
--
--
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.pkg_nocem.all;
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


ENTITY dpmem IS
generic ( ADD_WIDTH: integer := 8 ;
		 WIDTH : integer := 8);
  port (
    clk      : in  std_logic;                                -- write clock
    reset    : in  std_logic;                                -- System Reset
    W_add    : in  std_logic_vector(ADD_WIDTH -1 downto 0);  -- Write Address
    R_add    : in  std_logic_vector(ADD_WIDTH -1 downto 0);  -- Read Address
    Data_In  : in  std_logic_vector(WIDTH - 1  downto 0);    -- input data
    Data_Out : out std_logic_vector(WIDTH -1   downto 0);    -- output Data
    WR       : in  std_logic;                                -- Write Enable
    RE       : in  std_logic);                               -- Read Enable
end dpmem;

ARCHITECTURE dpmem_v3 OF dpmem IS

  type dpmemdata_array is array (integer range <>) of std_logic_vector(WIDTH -1  downto 0);                                        -- Memory Type
  signal data : dpmemdata_array(0 to (2** ADD_WIDTH)-1 );  -- Local data

begin  -- dpmem_v3

  mem_clkd : process (clk, reset,data)

  begin  -- PROCESS


    -- activities triggered by asynchronous reset (active low)
    if reset = '0' then

	    for i in 0 to (2** add_width)-1 loop
	      data(i) <= (others => '0');
	    end loop;

      -- activities triggered by rising edge of clock
    elsif clk'event and clk = '1' then
      if WR = '1' then
        data(conv_integeR(W_add)) <= Data_In;
      end if;

    end if;
  end process;

	mem_uclkd : process (RE,data,r_add)
	begin
		data_out <= data(conv_integer(R_add));
	end process;




end dpmem_v3;



-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.pkg_nocem.all;


entity fifo_allvhdl is
    generic(
	 	WIDTH : integer := 16;
		ADDR_WIDTH : integer := 3
	 );
	 port (
			din : in std_logic_vector(WIDTH-1 downto 0);  -- Input data
			dout : out std_logic_vector(WIDTH-1 downto 0);  -- Output data
			clk : in std_logic;  		-- System Clock
			rst : in std_logic;  	-- System global Reset
			rd_en : in std_logic;  		-- Read Enable
			wr_en : in std_logic;  		-- Write Enable
			full : out std_logic;  	-- Full Flag
			empty : out std_logic	-- empty Flag
			); 	

end fifo_allvhdl;

architecture behavioral of fifo_allvhdl is

begin

	I_fk : fifo_gfs 
	Generic MAP(
		WIDTH => WIDTH,
		ADD_WIDTH => ADDR_WIDTH
	)		
	PORT MAP(
		Data_in => din,
		clk => clk,
		Reset => rst,
		RE => rd_en,
		WE => wr_en,
		Data_out => dout,
		Full => full,
		Half_full => open,
		empty => empty
	);



end behavioral;