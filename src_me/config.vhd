----------------------------------------------------------------------------
--  This file is a part of the LM VHDL IP LIBRARY
--  Copyright (C) 2009 Jose Nunez-Yanez
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  See the file COPYING for the full details of the license.
--
--  The license allows free and unlimited use of the library and tools for research and education purposes. 
--  The full LM core supports many more advanced motion estimation features and it is available under a 
--  low-cost commercial license. See the readme file to learn more or contact us at 
--  eejlny@byacom.co.uk or www.byacom.co.uk

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


package config is

constant CFG_PIPELINE_COUNT : integer := (1); -- Number of integer execution units
constant CFG_PIPELINE_COUNT_QP : integer := (0); -- Number of fractional execution units
constant CFG_CM : integer := (0); --compact memory configuration switch
constant CFG_MV_COST : integer := (0); -- set to one to enable adding the cost of the motion vector to the SAD
constant CFG_USE_MVC : integer := (0); -- set to use motion vector candidates

type rest_type_points is array(CFG_PIPELINE_COUNT-1 downto 0) of std_logic_vector(7 downto 0); 
type rest_type_displacement is array(CFG_PIPELINE_COUNT-1 downto 0) of std_logic_vector(15 downto 0);
type rest_type_points_qp is array(CFG_PIPELINE_COUNT_QP-1 downto 0) of std_logic_vector(7 downto 0); 
type rest_type_displacement_qp is array(CFG_PIPELINE_COUNT_QP-1 downto 0) of std_logic_vector(15 downto 0);  
type mode_type is (m16x16,m8x8,m16x8,m8x16);
type standard_type is (h264,vc1,avs);


end;
