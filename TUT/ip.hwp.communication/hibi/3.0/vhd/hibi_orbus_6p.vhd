-------------------------------------------------------------------------------
-- file        : hibi_orbus_6p.vhd
-- description : Bus resolution is done by ORring all the inputs. E.g.
--               data_out <= data_0_in or data_1_in or...
-- author      : Erno Salminen
-- date        : 2012-03-07
-- modified    : 
-- 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
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
-- useful, but WITHOUT ANY WARRANTY; without even the impliedlk
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
--use work.hibiv3_pkg.all;                -- hibi v3 commands

entity hibi_orbus_6p is
  generic (
    data_width_g           : integer := 32;
    comm_width_g           : integer := 5
  );

  port (
    bus_av_out   : out std_logic;
    bus_data_out : out std_logic_vector(data_width_g-1 downto 0);
    bus_comm_out : out std_logic_vector (comm_width_g-1 downto 0);
    bus_lock_out : out std_logic;
    bus_full_out : out std_logic;
    
    bus_av_0_in   : in std_logic;
    bus_data_0_in : in std_logic_vector(data_width_g-1 downto 0);
    bus_comm_0_in : in std_logic_vector (comm_width_g-1 downto 0);
    bus_lock_0_in : in std_logic;
    bus_full_0_in : in std_logic;
    
    bus_av_1_in   : in std_logic;
    bus_data_1_in : in std_logic_vector(data_width_g-1 downto 0);
    bus_comm_1_in : in std_logic_vector (comm_width_g-1 downto 0);
    bus_lock_1_in : in std_logic;
    bus_full_1_in : in std_logic;
    
    bus_av_2_in   : in std_logic;
    bus_data_2_in : in std_logic_vector(data_width_g-1 downto 0);
    bus_comm_2_in : in std_logic_vector (comm_width_g-1 downto 0);
    bus_lock_2_in : in std_logic;
    bus_full_2_in : in std_logic;
    
    bus_av_3_in   : in std_logic;
    bus_data_3_in : in std_logic_vector(data_width_g-1 downto 0);
    bus_comm_3_in : in std_logic_vector (comm_width_g-1 downto 0);
    bus_lock_3_in : in std_logic;
    bus_full_3_in : in std_logic;
    
    bus_av_4_in   : in std_logic;
    bus_data_4_in : in std_logic_vector(data_width_g-1 downto 0);
    bus_comm_4_in : in std_logic_vector (comm_width_g-1 downto 0);
    bus_lock_4_in : in std_logic;
    bus_full_4_in : in std_logic;

    bus_av_5_in   : in std_logic;
    bus_data_5_in : in std_logic_vector(data_width_g-1 downto 0);
    bus_comm_5_in : in std_logic_vector (comm_width_g-1 downto 0);
    bus_lock_5_in : in std_logic;
    bus_full_5_in : in std_logic
    );
end hibi_orbus_6p;

architecture structural of hibi_orbus_6p is
  
begin  -- structural
  
  
  -- continuous assignments
  bus_av_out  <= bus_av_0_in    or bus_av_1_in   or bus_av_2_in   or bus_av_3_in or  bus_av_4_in or  bus_av_5_in ;

  bus_data_out <= bus_data_0_in or bus_data_1_in or bus_data_2_in or bus_data_3_in or bus_data_4_in or bus_data_5_in ;

  bus_comm_out <= bus_comm_0_in or bus_comm_1_in or bus_comm_2_in or bus_comm_3_in or  bus_comm_4_in  or bus_comm_5_in ;
  
  bus_lock_out <= bus_lock_0_in or bus_lock_1_in or bus_lock_2_in or bus_lock_3_in or  bus_lock_4_in or  bus_lock_5_in;

  bus_full_out <= bus_full_0_in or bus_full_1_in or bus_full_2_in or bus_full_3_in or bus_full_4_in or bus_full_5_in ;


end structural;

