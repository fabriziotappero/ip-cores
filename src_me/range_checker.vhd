
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
-----------------------------------------------------------------------------
-- Entity: 	range_checker
-- File:	range_checker.vhd
-- Author:	Jose Luis Nunez 
-- Description:	range checker to be able to process frame edges
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.config.all;
use IEEE.std_logic_signed."+";
use IEEE.std_logic_signed."<";
use IEEE.std_logic_signed.">";
use work.config.all;


entity range_checker is --make sure that MVs are not out of range
port (
clk : in std_logic;
clear : in std_logic;
reset : in std_logic;
candidate_mvx : in std_logic_vector(7 downto 0);
candidate_mvy : in std_logic_vector(7 downto 0);
frame_dimension_x : in std_logic_vector(7 downto 0); --in mb  
frame_dimension_y : in std_logic_vector(7 downto 0);
mbx_coordinate : in std_logic_vector(7 downto 0); --in mb
mby_coordinate : in std_logic_vector(7 downto 0);
range_ok : out std_logic
); 
end;

architecture behav of range_checker is


signal mbx_coordinate_pixels : std_logic_vector(11 downto 0);
signal mby_coordinate_pixels : std_logic_vector(11 downto 0);
signal frame_dimension_x_pixels,candidate_mvx_long,candidate_mvy_long : std_logic_vector(11 downto 0);
signal frame_dimension_y_pixels : std_logic_vector(11 downto 0);
signal range_x_low,range_x_high,range_y_low,range_y_high : std_logic;

begin


mbx_coordinate_pixels <= mbx_coordinate & "0000"; 
mby_coordinate_pixels <= mby_coordinate & "0000"; 
frame_dimension_x_pixels <= frame_dimension_x & "0000";
frame_dimension_y_pixels <= frame_dimension_y & "0000";
candidate_mvx_long <= "0000" & candidate_mvx when candidate_mvx(7)='0' else "1111" & candidate_mvx; --sign extension
candidate_mvy_long <= "0000" & candidate_mvy when candidate_mvy(7)='0' else "1111" & candidate_mvy;

range_process_x_low : process(candidate_mvx_long,mbx_coordinate_pixels)

begin

if ((candidate_mvx_long + mbx_coordinate_pixels) < 0) then
	range_x_low <= '0';
else
	range_x_low <= '1';
end if;

end process;

range_process_x_high : process(candidate_mvx_long,mbx_coordinate_pixels,frame_dimension_x_pixels)

begin

if ((candidate_mvx_long + 16 + mbx_coordinate_pixels) > frame_dimension_x_pixels) then
	range_x_high <= '0';
else
	range_x_high <= '1';
end if;

end process;


range_process_y_low : process(candidate_mvy_long,mby_coordinate_pixels)

begin

if ((candidate_mvy_long + mby_coordinate_pixels) < 0) then
	range_y_low <= '0';
else
	range_y_low <= '1';
end if;

end process;

range_process_y_high : process(candidate_mvy_long,mby_coordinate_pixels,frame_dimension_y_pixels)

begin

if ((candidate_mvy_long + 16 + mby_coordinate_pixels) > frame_dimension_y_pixels) then
	range_y_high <= '0';
else
	range_y_high <= '1';
end if;

end process;

--rangec1 : if CFG_PIPELINE_COUNT_QP = 1 generate
--	range_ok <= range_x_low and range_x_high and range_y_low and range_y_high; -- if all ranges ok then ok
--end generate;

--rangec0 : if CFG_PIPELINE_COUNT_QP = 1 generate
	range_ok <= '1';  -- Hardwired to one since the codec can pad the reference memory with pixels. 
--end generate;

end behav;
