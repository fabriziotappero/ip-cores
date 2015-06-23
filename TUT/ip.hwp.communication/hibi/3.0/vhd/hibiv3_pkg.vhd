-------------------------------------------------------------------------------
-- Title      : HIBI package, command constants
-- Project    : HIBI
-------------------------------------------------------------------------------
-- File       : hibiv3_pkg.vhd
-- Authors    : Lasse Lehtonen
-- Company    : Tampere University of Technology
-- Created    :
-- Last update: 2012-02-06
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Command constants for HIBI. Use these and not magic numbers.
-- 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 Tampere University of Technology
--
-- 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-10-13  1.0      ase     Created
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
use ieee.numeric_std.all;


package hibiv3_pkg is
  -----------------------------------------------------------------------------
  -- DO NOT EDIT !
  -----------------------------------------------------------------------------

  -- IDLE : No operation
  -- WR   : Write, posted, (same as old write)
  -- RD   : Read
  -- RDL  : Read linked, IP takes care
  -- WRNP : Write, nonposted, IP responsible for answering
  -- WRC  : Write, conditional, IP responsible for this
  

  
  constant comm_width_c : integer := 5;  -- width of the command bus
  constant priority_bit : integer := 0;  -- which bit is priority

  constant IDLE_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(0, comm_width_c));
  constant NOT_USED_1_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(1, comm_width_c));
  
  constant DATA_WR_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(2, comm_width_c));
  constant MSG_WR_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(3, comm_width_c));
  
  constant DATA_RD_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(4, comm_width_c));
  constant MSG_RD_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(5, comm_width_c));
  
  constant DATA_RDL_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(6, comm_width_c));
  constant MSG_RDL_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(7, comm_width_c));
  
  constant DATA_WRNP_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(8, comm_width_c));
  constant MSG_WRNP_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(9, comm_width_c));
  
  constant DATA_WRC_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(10, comm_width_c));
  constant MSG_WRC_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(11, comm_width_c));

  constant NOT_USED_2_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(12, comm_width_c));
  constant EXCL_LOCK_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(13, comm_width_c));  

  constant NOT_USED_3_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(14, comm_width_c));  
  constant EXCL_WR_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(15, comm_width_c));
  
  constant NOT_USED_4_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(16, comm_width_c));  
  constant EXCL_RD_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(17, comm_width_c));
  
  constant NOT_USED_5_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(18, comm_width_c));  
  constant EXCL_RELEASE_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(19, comm_width_c));  
  
  constant NOT_USED_6_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(20, comm_width_c));
  constant CFG_WR_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(21, comm_width_c));
  
  constant NOT_USED_7_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(22, comm_width_c));
  constant CFG_RD_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(23, comm_width_c));
  
  constant NOT_USED_8_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(24, comm_width_c));
  constant NOT_USED_9_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(25, comm_width_c));
  
  constant NOT_USED_10_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(26, comm_width_c));
  constant NOT_USED_11_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(27, comm_width_c));
  
  constant NOT_USED_12_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(28, comm_width_c));
  constant NOT_USED_13_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(29, comm_width_c));
  
  constant NOT_USED_14_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(30, comm_width_c));    
  constant NOT_USED_15_c : std_logic_vector (comm_width_c-1 downto 0) :=
    std_logic_vector(to_unsigned(31, comm_width_c));

  -----------------------------------------------------------------------------
  -- OLD COMMAND CONSTANTS FOR COMPATIBILITY (DON'T USE IN FUTURE)
  -----------------------------------------------------------------------------
  
  constant w_cfg_c : std_logic_vector (comm_width_c-1 downto 0) :=
    CFG_WR_c;
  constant w_data_c : std_logic_vector (comm_width_c-1 downto 0) :=
    DATA_WRNP_c;
  constant w_msg_c : std_logic_vector (comm_width_c-1 downto 0) :=
    MSG_WRNP_c;

  constant r_data_c : std_logic_vector (comm_width_c-1 downto 0) :=
    DATA_RD_c;
  constant r_cfg_c : std_logic_vector (comm_width_c-1 downto 0) :=
    CFG_RD_c;

  -- These are not supported anymore
  --
  --constant multicast_data_c : std_logic_vector (comm_width_c-1 downto 0) :=
  --  DATA_BCST_c;
  --constant multicast_msg_c : std_logic_vector (comm_width_c-1 downto 0) :=
  --  MSG_BCST_c;



  
end hibiv3_pkg;



