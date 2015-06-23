-----------------------------------------------------------------------
-- This file is part of SCARTS.
-- 
-- SCARTS is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- SCARTS is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with SCARTS.  If not, see <http://www.gnu.org/licenses/>.
-----------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


package scarts_amba_pkg is

  constant MAX_AHB_IRQ    : integer := 8;   -- maximum interrupts
  
  constant HSIZE_BYTE:    std_logic_vector(2 downto 0) := "000";
  constant HSIZE_HWORD:   std_logic_vector(2 downto 0) := "001";
  constant HSIZE_WORD:    std_logic_vector(2 downto 0) := "010";
  constant HSIZE_DWORD:   std_logic_vector(2 downto 0) := "011";
  constant HSIZE_4WORD:   std_logic_vector(2 downto 0) := "100";
  constant HSIZE_8WORD:   std_logic_vector(2 downto 0) := "101";
  constant HSIZE_16WORD:  std_logic_vector(2 downto 0) := "110";
  constant HSIZE_32WORD:  std_logic_vector(2 downto 0) := "111";

  constant HRESP_OKAY:    std_logic_vector(1 downto 0) := "00";
  constant HRESP_ERROR:   std_logic_vector(1 downto 0) := "01";
  constant HRESP_RETRY:   std_logic_vector(1 downto 0) := "10";
  constant HRESP_SPLIT:   std_logic_vector(1 downto 0) := "11";

  constant HBURST_SINGLE: std_logic_vector(2 downto 0) := "000";
  constant HBURST_INCR:   std_logic_vector(2 downto 0) := "001";
  constant HBURST_WRAP4:  std_logic_vector(2 downto 0) := "010";
  constant HBURST_INCR4:  std_logic_vector(2 downto 0) := "011";
  constant HBURST_WRAP8:  std_logic_vector(2 downto 0) := "100";
  constant HBURST_INCR8:  std_logic_vector(2 downto 0) := "101";
  constant HBURST_WRAP16: std_logic_vector(2 downto 0) := "110";
  constant HBURST_INCR16: std_logic_vector(2 downto 0) := "111";

  constant HTRANS_IDLE:   std_logic_vector(1 downto 0) := "00";
  constant HTRANS_BUSY:   std_logic_vector(1 downto 0) := "01";
  constant HTRANS_NONSEQ: std_logic_vector(1 downto 0) := "10";
  constant HTRANS_SEQ:    std_logic_vector(1 downto 0) := "11";

  -- AHB master inputs (based on AMBA 2.0 specification)

  type ahb_master_in_type is record
    hgrant      : std_logic;                            
    hready      : std_ulogic;                           
    hresp       : std_logic_vector(1 downto 0);         
    hrdata      : std_logic_vector(31 downto 0);        
    hirq        : std_logic_vector(MAX_AHB_IRQ-1 downto 0); -- interrupt bus   
  end record;

  constant AMBA_MASTER_IN_VOID : ahb_master_in_type := ('0', '0',
                                                        (others => '0'),
                                                        (others => '0'),
                                                        (others => '0'));                                                        
  
  -- AHB master outputs (based on AMBA 2.0 specification) 
  
  type ahb_master_out_type is record
    hbusreq     : std_ulogic;                           
    hlock       : std_ulogic;                           
    htrans      : std_logic_vector(1 downto 0);         
    haddr       : std_logic_vector(31 downto 0);        
    hwrite      : std_ulogic;                           
    hsize       : std_logic_vector(2 downto 0);         
    hburst      : std_logic_vector(2 downto 0);         
    hprot       : std_logic_vector(3 downto 0);         
    hwdata      : std_logic_vector(31 downto 0);       
  end record;

  constant AMBA_MASTER_OUT_VOID : ahb_master_out_type := ('0', '0', (others => '0'),
                                                          (others => '0'), '0',
                                                          (others => '0'),
                                                          (others => '0'),
                                                          (others => '0'),
                                                          (others => '0'));
  
end scarts_amba_pkg;

