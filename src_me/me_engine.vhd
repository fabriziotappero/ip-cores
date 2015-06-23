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
-- File:	me_engine.vhd
-- Author:	Jose Luis Nunez-Yanez
-- Description:	me entities
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package me_engine is

component me_top
 port ( clk : in std_logic;
        clear : in std_logic;
        reset : in std_logic;
	     register_file_address : in std_logic_vector(4 downto 0); -- 32 general purpose registers
        register_file_write : in std_logic;
	     register_file_data_in : in std_logic_vector(31 downto 0);
	     register_file_data_out : out std_logic_vector(31 downto 0);
	     done_interrupt : out std_logic; -- high when macroblock processing has completed
	     best_sad_debug : out std_logic_vector(15 downto 0); --debugging ports
	     best_mv_debug : out std_logic_vector(15 downto 0);
		 best_eu_debug : out std_logic_vector(3 downto 0);
		 partition_mode_debug : out std_logic_vector(3 downto 0);
		 qp_on_debug : out std_logic;	   --running qp
	     dma_rm_re_debug : in std_logic; --set to one to enable reading the reference area
	     dma_rm_debug : out std_logic_vector(63 downto 0); -- reference area data out
	     dma_address : in std_logic_vector(10 downto 0); -- next reference memory address
        dma_data_in : in std_logic_vector(63 downto 0); -- pixel in for reference memory or macroblock memory
        dma_rm_we : in std_logic; --enable writing to reference memory
	   dma_cm_we : in std_logic; --enable writing to current macroblock memory
	   dma_pom_we : in std_logic; -- enable writing to point memory
	   dma_prm_we : in std_logic;  -- enable writing to program memory
	     dma_residue_out : out std_logic_vector(63 downto 0); -- get residue from winner mv
	     dma_re_re : in std_logic -- enable reading residue
      ); 
end component;  

end;