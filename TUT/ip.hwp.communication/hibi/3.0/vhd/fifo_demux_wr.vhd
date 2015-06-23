-------------------------------------------------------------------------------
-- File        : fifo_demux_wr.vhd
-- Description : Makes two fifos look like a single fifo for the writer.
--                The FIFO where to write is selected according to incoming command
--
--               Write_demux:
--               Input : data, addr valid and command 
--               Out   : data, addr valid and command to two fifos
--
--              Note. Fifo_demux_write does not fully support One_Place_Left_Out!
----               To be on the safe side, one-place_left signals are ORred
----               together when command is IDLE.
--                 This may prevent writing to one fifo if the other fifo is
--                 is geting full.
--
--              
-- Author      : Erno Salminen
-- Project     : Nocbench, Funbasse
-- Date        : 05.02.2003
-- Modified    : 
-- 1.4.2011    ase Modified the commands for HIBI v.3
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
-- This file is part of HIBI
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.hibiv3_pkg.all;


entity fifo_demux_wr is

  generic (
    data_width_g : integer := 0;
    comm_width_g : integer := 0
    );
  port (
    data_in   : in  std_logic_vector (data_width_g-1 downto 0);
    av_in     : in  std_logic;
    comm_in   : in  std_logic_vector (comm_width_g-1 downto 0);
    we_in     : in  std_logic;
    full_out  : out std_logic;
    one_p_out : out std_logic;

    -- Data/Comm/AV conencted to both fifos
    -- Distinction made with WE!
    data_out   : out std_logic_vector (data_width_g-1 downto 0);
    comm_out   : out std_logic_vector (comm_width_g-1 downto 0);
    av_out     : out std_logic;
    we_0_out   : out std_logic;
    we_1_out   : out std_logic;
    full_0_in  : in  std_logic;
    full_1_in  : in  std_logic;
    one_p_0_in : in  std_logic;
    one_p_1_in : in  std_logic
    );

end fifo_demux_wr;





architecture rtl of fifo_demux_wr is

  -- Selects if debug prints are used (1-3) or not ('0')
  constant dbg_level : integer range 0 to 3 := 0;  -- 0= no debug, use 0 for synthesis

  -- Registers may be reset to 'Z' to 'X' so that reset state is clearly
  -- distinguished from active state. Using value of rst_value_arr array(dbg_level),
  -- the rst value may be easily set to '0' for synthesis.
  constant rst_value_arr : std_logic_vector (6 downto 0) := 'X' & 'Z' & 'X' & 'Z' & 'X' & 'Z' & '0';


begin  -- rtl


  -- Concurrent assignments, these go straight through
  -- and only write enable and full outputs are controlled
  av_out   <= av_in;
  data_out <= data_in;
  comm_out <= comm_in;


  -- COMB PROC
  -- Fully combinational
  Demultiplex_data : process (          -- data_in,
    -- av_in,
    comm_in, we_in,
    one_p_0_in, one_p_1_in,
    full_0_in, full_1_in)
  begin  -- process Demultiplex_data

    

    if comm_in = MSG_WR_c
      or comm_in = MSG_RD_c
      or comm_in = MSG_RDL_c
      or comm_in = MSG_WRNP_c
      or comm_in = MSG_WRC_c
      or comm_in = CFG_WR_c
      or comm_in = CFG_RD_c
      or comm_in = EXCL_LOCK_c
      or comm_in = EXCL_WR_c
      or comm_in = EXCL_RD_c
      or comm_in = EXCL_RELEASE_c
    then
      -- MESSAGE
      we_0_out  <= we_in;
      we_1_out  <= '0';
      full_out  <= full_0_in;
      one_p_out <= one_p_0_in;

    elsif comm_in = DATA_WR_c
      or comm_in = DATA_RD_c
      or comm_in = DATA_RDL_c
      or comm_in = DATA_WRNP_c
      or comm_in = DATA_WRC_c
    then
      -- DATA
      we_0_out  <= '0';
      we_1_out  <= we_in;
      full_out  <= full_1_in;
      one_p_out <= one_p_1_in;

    else
      --IDLE
      we_0_out  <= '0';
      we_1_out  <= '0';
      full_out  <= full_1_in or full_0_in;
      one_p_out <= one_p_0_in or one_p_1_in;
    end if;
  end process Demultiplex_data;


  
end rtl;  --fifo_demux_wr
