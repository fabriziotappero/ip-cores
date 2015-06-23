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


--                   bit 0,A
--                 ----------
--                |          | 
--                |          |
--             5,F|          |  1,B
--                |    6,G   |
--                 ----------
--                |          |
--                |          |
--             4,E|          |  2,C
--                |    3,D   |
--                 ----------  
--                              # 7,H


-- Select signal order
--   ---    ---      ---    --- 
--  |   |  |   |    |   |  |   |  
--  |   |  |   |    |   |  |   |
--   ---    ---      ---    ---
--  |   |  |   |    |   |  |   |
--  |   |  |   |    |   |  |   |
--   ---    ---      ---    ---
--  sel(3) sel(2)   sel(1) sel(0)



library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


entity led_sys is  --toplevel for led system
  generic(
	msn_hib : std_logic_vector(7 downto 0);  --Most signif. of hi byte
	lsn_hib : std_logic_vector(7 downto 0);  --Least signif. of hi byte
 	msn_lob : std_logic_vector(7 downto 0);  --Most signif. of hi byte
	lsn_lob : std_logic_vector(7 downto 0)  --Least signif. of hi byte	
  );
  port (
    clk				: in std_logic;
    reset_n			: in std_logic;
	led_data_i		: in  std_logic_vector(15 downto 0);   --binary data in
    seg_out			: out std_logic_vector(7 downto 0); --one segment out
    sel_out			: out std_logic_vector(3 downto 0)  --segment scanner with one bit low
    );
end led_sys;

architecture rtl of led_sys is

component led_coder
  port (
    led_data_i : in  std_logic_vector(7 downto 0);
    hi_seg     : out std_logic_vector(7 downto 0);
    lo_seg     : out std_logic_vector(7 downto 0)
    );
end component;

component byte_scan
  port (
    clk          : in std_logic;
    hi_seg_1     : in std_logic_vector(7 downto 0);
    lo_seg_1     : in std_logic_vector(7 downto 0);
    hi_seg_0     : in std_logic_vector(7 downto 0);
    lo_seg_0     : in std_logic_vector(7 downto 0);    
    seg_out      : out std_logic_vector(7 downto 0);
    sel_out      : out std_logic_vector(3 downto 0)
    );
end component;


-- input signals
signal    hi_seg1    : std_logic_vector(7 downto 0);
signal    lo_seg1    : std_logic_vector(7 downto 0);
signal    hi_seg0    : std_logic_vector(7 downto 0);
signal    lo_seg0    : std_logic_vector(7 downto 0);

--data containing signals
signal    data_hi_seg1    : std_logic_vector(7 downto 0);
signal    data_lo_seg1    : std_logic_vector(7 downto 0);
signal    data_hi_seg0    : std_logic_vector(7 downto 0);
signal    data_lo_seg0    : std_logic_vector(7 downto 0);

--constant display
signal    cons_hi_seg1    : std_logic_vector(7 downto 0);
signal    cons_lo_seg1    : std_logic_vector(7 downto 0);
signal    cons_hi_seg0    : std_logic_vector(7 downto 0);
signal    cons_lo_seg0    : std_logic_vector(7 downto 0);

signal	  disp_cnt		  : std_logic_vector(15 downto 0):=(others=>'0'); --this enables correct simulation

begin  -- rtl
---------------------------HGFEDCBA
cons_hi_seg1 <= msn_hib;--"01111111";  --8
cons_lo_seg1 <= lsn_hib;--"01111101";  --6
cons_hi_seg0 <= msn_lob;--"01011100";  -- small o
cons_lo_seg0 <= lsn_lob;--"01011100";  -- small o




process (clk)  --enable the scanning while in reset 
begin  -- process
  if clk'event and clk = '0' then    -- rising clock edge
	 disp_cnt <= disp_cnt + 1;
  end if;
end process;

LED_CODE0: led_coder
  port map(
    led_data_i => led_data_i(7 downto 0), -- in  std_logic_vector(7 downto 0);
    hi_seg     => data_hi_seg0, -- out std_logic_vector(7 downto 0);
    lo_seg     => data_lo_seg0 -- out std_logic_vector(7 downto 0)
    );

LED_CODE1: led_coder
  port map(
    led_data_i => led_data_i(15 downto 8), -- in  std_logic_vector(7 downto 0);
    hi_seg     => data_hi_seg1, -- out std_logic_vector(7 downto 0);
    lo_seg     => data_lo_seg1 -- out std_logic_vector(7 downto 0)
    );


lo_seg1 <= data_hi_seg1 when reset_n='1' else cons_hi_seg1;
hi_seg1 <= data_lo_seg1 when reset_n='1' else cons_lo_seg1;

lo_seg0 <= data_hi_seg0 when reset_n='1' else cons_hi_seg0;
hi_seg0 <= data_lo_seg0 when reset_n='1' else cons_lo_seg0;

SCAN : byte_scan
  port map(
    clk          => disp_cnt(15), -- in std_logic;
    hi_seg_1     => hi_seg1, -- in std_logic_vector(7 downto 0);
    lo_seg_1     => lo_seg1, -- in std_logic_vector(7 downto 0);
    hi_seg_0     => hi_seg0, -- in std_logic_vector(7 downto 0);
    lo_seg_0     => lo_seg0, -- in std_logic_vector(7 downto 0);    
    seg_out      => seg_out, -- out std_logic_vector(7 downto 0);
    sel_out      => sel_out  -- out std_logic_vector(3 downto 0)
    );




end rtl;
