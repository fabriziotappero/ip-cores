--  GECKO3COM IP Core
--
--  Copyright (C) 2009 by
--   ___    ___   _   _
--  (  _ \ (  __)( ) ( )
--  | (_) )| (   | |_| |   Bern University of Applied Sciences
--  |  _ < |  _) |  _  |   School of Engineering and
--  | (_) )| |   | | | |   Information Technology
--  (____/ (_)   (_) (_)
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
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
--  URL to the project description: 
--    http://labs.ti.bfh.ch/gecko/wiki/systems/gecko3com/start
--------------------------------------------------------------------------------
--
--  Author:  Andreas Habegger, Christoph Zimmermann
--  Date of creation: 23. December 2009
--  Description:
--   	F
--
--  Tool versions: 	11.1
--  Dependencies:
--
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

library XilinxCoreLib;

library work;
use work.GECKO3COM_defines.all;

entity gpif_com_test_tb is
end  gpif_com_test_tb;

architecture simulation of gpif_com_test_tb is

  -- components

  component gpif_com_test
    port (
      i_nReset   : in    std_logic;
      i_IFCLK    : in    std_logic;
      i_SYSCLK   : in    std_logic;
      i_WRU      : in    std_logic;
      i_RDYU     : in    std_logic;
      o_WRX      : out   std_logic;
      o_RDYX     : out   std_logic;
      b_gpif_bus : inout std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
      o_LEDrx    : out   std_logic;
      o_LEDtx    : out   std_logic;
      o_LEDrun   : out   std_logic;
      o_dummy    : out   std_logic);
  end component;



	-- simulation types
	type TsimSend is (finish, sending, waiting); 
  -- simulation constants

 --constant TIME_BASE  : time := 1 ns;

  constant CLK_PERIOD : time := 20 ns;

  constant DATA_BUS_SIZE  : integer := SIZE_DBUS_GPIF;
  constant WORD_VALUE1    : std_logic_vector(DATA_BUS_SIZE-1 downto 0) := x"FF00";
  constant WORD_VALUE2    : std_logic_vector(DATA_BUS_SIZE-1 downto 0) := x"B030";
  constant WORD_VALUE3    : std_logic_vector(DATA_BUS_SIZE-1 downto 0) := x"50A0";
  -- signals

  signal sim_clk : std_logic;
  signal sim_rst : std_logic;

  signal s_LEDrun, s_LEDtx, s_LEDrx, s_dummy : std_logic;
  
  
  signal sim_1      : boolean := false;
  
  signal send_data  : TsimSend := finish;


  signal s_WRU  : std_logic;
  signal s_RDYU : std_logic;

  signal s_WRX  : std_logic;
  signal s_RDYX : std_logic;


  signal s_data_bus : std_logic_vector(DATA_BUS_SIZE-1 downto 0);


begin  -- simulation

-------------------------------------------------------------------------------
-- Design maps
-------------------------------------------------------------------------------

  DUT : gpif_com_test
    port map (
        i_nReset   => sim_rst,
        i_IFCLK    => sim_clk,
        i_SYSCLK   => sim_clk,
        i_WRU      => s_WRU,
        i_RDYU     => s_RDYU,
        o_WRX      => s_WRX,
        o_RDYX     => s_RDYX,
        b_gpif_bus => s_data_bus,
        o_LEDrx    => s_LEDrx,
        o_LEDtx    => s_LEDtx,
        o_LEDrun   => s_LEDrun,
        o_dummy    => s_dummy);   
   


-------------------------------------------------------------------------------
-- CLK process
-------------------------------------------------------------------------------
   clk_process: process
	begin
		sim_clk<='0';
		wait for CLK_PERIOD/2;
		sim_clk<='1';
		wait for CLK_PERIOD/2;
		if sim_1 then
			wait;
		end if;
	end process;
	
	
	
	rst_process: process
	begin
		sim_rst<='0';
		wait for CLK_PERIOD;
		sim_rst<='1';
		wait;
	end process;
	

end simulation;
