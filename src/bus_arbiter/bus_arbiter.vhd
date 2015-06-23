------------------------------------------------------------------
-- Universal dongle board source code
-- 
-- Copyright (C) 2006 Artec Design <jyrit@artecdesign.ee>
-- 
-- This source code is free hardware; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
-- 
-- This source code is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
-- 
-- 
-- The complete text of the GNU Lesser General Public License can be found in 
-- the file 'lesser.txt'.


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

use bus_arbiter_pkg.all;

		

entity bus_arbiter is
  generic (
	 dev_count: integer:= 1;
	 has_clock: array(integer range 0 to dev_count-1) of std_logic:=(others=>'0')  --if provided clock should be used
  );
  port (
    clk       : in  std_logic;  --default system clock
    reset_n   : in  std_logic;
    -- mem Bus out
    
    mem_clk   : out std_logic;
    mem_rstn  : out std_logic;   --reset to mem block (used when mux'ing clock)
    mem_addr  : out std_logic_vector(23 downto 0);
    mem_do    : out std_logic_vector(15 downto 0);
    mem_di    : in  std_logic_vector(15 downto 0);
     
    mem_wr    : out  std_logic;  --write not read signal
    mem_val   : out  std_logic;
    mem_ack   : in std_logic;


    -- dev Bus in
    dev_clk   : in  array(integer range 0 to dev_count-1) of std_logic;  --clock option
    dev_addr  : in  array(integer range 0 to dev_count-1) of std_logic_vector(23 downto 0);
    dev_do    : out array(integer range 0 to dev_count-1) of std_logic_vector(15 downto 0);
    dev_di    : in  array(integer range 0 to dev_count-1) of std_logic_vector(15 downto 0);
     
    dev_wr    : in  array(integer range 0 to dev_count-1) of std_logic;  --write not read signal
    dev_val   : in  array(integer range 0 to dev_count-1) of std_logic;
    dev_ack   : out array(integer range 0 to dev_count-1) of std_logic
    ); 
end bus_arbiter;
		
		
		
architecture RTL of bus_arbiter is


begin




end RTL;

