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
--      This is a wrapper for a FIFO that was generated with the Xilinx
--      Coregenerator to hide the vendor specific stuff and match our naming
--      conventions.
--
--  Target Devices:     Xilinx FPGA's due to use of Coregenerator IP cores
--  Tool versions:      11.1
--  Dependencies:
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.vcomponents.all;

library UNIMACRO;
use UNIMACRO.vcomponents.all;

library work;
use work.GECKO3COM_defines.all;

entity receive_fifo is
  generic (
    BUSWIDTH : integer := 32);          -- vector size of the FIFO databusses
  port (
    i_din    : in  std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
    i_clk    : in  std_logic;    
    i_rd_en  : in  std_logic;
    i_rst    : in  std_logic;
    i_wr_en  : in  std_logic;
    o_dout   : out std_logic_vector(BUSWIDTH-1 downto 0);
    o_empty  : out std_logic;
    o_full   : out std_logic);
end receive_fifo;

architecture wrapper of receive_fifo is

  -----------------------------------------------------------------------------
  -- COMPONENTS
  -----------------------------------------------------------------------------

  component coregenerator_fifo_receive
    port (
      din    : in  std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
      rd_clk : in  std_logic;
      rd_en  : in  std_logic;
      rst    : in  std_logic;
      wr_clk : in  std_logic;
      wr_en  : in  std_logic;
      dout   : out std_logic_vector(31 downto 0);
      empty  : out std_logic;
      full   : out std_logic);
  end component;

  -- Synplicity black box declaration
  attribute syn_black_box                               : boolean;
  attribute syn_black_box of coregenerator_fifo_receive : component is true;
  attribute box_type of coregenerator_fifo_receive      : component is "black_box";
  
begin

  -----------------------------------------------------------------------------
  -- Port map
  -----------------------------------------------------------------------------

  FIFO : coregenerator_fifo_receive
    port map (
      din    => i_din,
      rd_clk => i_clk,
      rd_en  => i_rd_en,
      rst    => i_rst,
      wr_clk => i_clk ,
      wr_en  => i_wr_en,
      dout   => o_dout,
      empty  => o_empty,
      full   => o_full
      );

end wrapper;
