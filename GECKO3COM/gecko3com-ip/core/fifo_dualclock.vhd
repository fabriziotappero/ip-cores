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
----------------------------------------------------------------------------------
--
--  Author:  Christoph Zimmermann
--  Date of creation: 17. December 2009
--  Description:
--   	This is a wrapper for a FIFO that was generated with the Xilinx Coregenerator
--    to hide the vendor specific stuff and match our naming conventions.
--
--  Target Devices:	Xilinx FPGA's due to use of Coregenerator IP cores
--  Tool versions: 	11.1
--  Dependencies:
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

Library UNISIM;
use UNISIM.vcomponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;

library work;
use work.GECKO3COM_defines.all;

entity fifo_dualclock is
  port (
    i_din          : IN  std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
    i_rd_clk       : IN  std_logic;
    i_rd_en        : IN  std_logic;
    i_rst          : IN  std_logic;
    i_wr_clk       : IN  std_logic;
    i_wr_en        : IN  std_logic;
    o_almost_empty : OUT std_logic;
    o_almost_full  : OUT std_logic;
    o_dout         : OUT std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
    o_empty        : OUT std_logic;
    o_full         : OUT std_logic);
end fifo_dualclock;

architecture wrapper of fifo_dualclock is
  
  -- interconection signals
	
 

  -----------------------------------------------------------------------------
  -- COMPONENTS
  -----------------------------------------------------------------------------

component coregenerator_fifo_dualclock
        port (
        din          : IN  std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
        rd_clk       : IN  std_logic;
        rd_en        : IN  std_logic;
        rst          : IN  std_logic;
        wr_clk       : IN  std_logic;
        wr_en        : IN  std_logic;
        almost_empty : OUT std_logic;
        almost_full  : OUT std_logic;
        dout         : OUT std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
        empty        : OUT std_logic;
        full         : OUT std_logic);
        --PROG_EMPTY_THRESH         : IN  std_logic;
        --PROG_EMPTY_THRESH_ASSERT  : IN  std_logic;
        --PROG_EMPTY_THRESH_NEGATE  : IN  std_logic);
end component;
attribute box_type of coregenerator_fifo_dualclock : component is "black_box";
  
begin

  -----------------------------------------------------------------------------
  -- Port map
  -----------------------------------------------------------------------------

FIFO : coregenerator_fifo_dualclock
                port map (
                        din          => i_din,
                        rd_clk       => i_rd_clk,
                        rd_en        => i_rd_en,
                        rst          => i_rst,
                        wr_clk       => i_wr_clk ,
                        wr_en        => i_wr_en,
                        almost_empty => o_almost_empty,
                        almost_full  => o_almost_full,
                        dout         => o_dout,
                        empty        => o_empty,
                        full         => o_full
                        --PROG_EMPTY_THRESH         => '0',
                        --PROG_EMPTY_THRESH_ASSERT  => '0',
                        --PROG_EMPTY_THRESH_NEGATE  => '0'
                        );

end wrapper;
