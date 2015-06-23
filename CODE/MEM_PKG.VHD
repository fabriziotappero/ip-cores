-------------------------------------------------------------------------------
-- Title      : Memory Package
-- Project    : Memory Cores
-------------------------------------------------------------------------------
-- File        : mem_pkg.vhd
-- Author      : Jamil Khatib  <khatib@ieee.org>
-- Organization: OpenIPCore Project
-- Created     : 2000/02/29
-- Last update: 2001/03/20
-- Platform    : 
-- Simulators  : Modelsim 5.2EE / Windows98, NC-Sim/Linux
-- Synthesizers: Leonardo / Windows98
-- Target      : Flex10K
-- Dependency  : ieee.std_logic_1164
--               utility.tools_pkg
-------------------------------------------------------------------------------
-- Description: Memory Package
-------------------------------------------------------------------------------
-- Copyright (c) 2000 Jamil Khatib
-- 
-- This VHDL design file is an open design; you can redistribute it and/or
-- modify it and/or implement it under the terms of the Openip General Public
-- License as it is going to be published by the OpenIPCore Organization and
-- any coming versions of this license.
-- You can check the draft license at
-- http://www.openip.org/oc/license.html

-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   1
-- Version         :   0.1
-- Date            :   29th Feb 2000
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   2
-- Version         :   0.2
-- Date            :   29th Mar 2000
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Memory components are added.
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   3
-- Version         :   0.3
-- Date            :   12 Jan 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Memory components updated
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   4
-- Version         :   0.31
-- Date            :   11 March 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   FIFO component added
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   5
-- Version         :   0.5
-- Date            :   16 April 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   WISHBONE components added
--
-------------------------------------------------------------------------------
-- $Log: not supported by cvs2svn $
-- Revision 1.4  2001/04/16 20:14:35  jamil
-- WishBone components added
--
-- Revision 1.3  2001/03/20 19:39:32  jamil
-- tools pkg bug fixed
--
-- Revision 1.2  2001/03/11 21:22:55  jamil
-- FIFO component added
--
-------------------------------------------------------------------------------

library ieee; 
use ieee.std_logic_1164.all; 

library utility;
use utility.tools_pkg.all;

package mem_pkg is

  constant ADD_WIDTH : integer := 8;    -- Address width
  constant WIDTH     : integer := 4;    -- Data width
-------------------------------------------------------------------------------
  component dpmem_ent
    generic (
      USE_RESET   : boolean;
      USE_CS      : boolean;
      DEFAULT_OUT : std_logic;
      CLK_DOMAIN  : integer;
      ADD_WIDTH   : integer;
      WIDTH       : integer);
    port (
      W_clk    : in  std_logic;
      R_clk    : in  std_logic;
      reset    : in  std_logic;
      W_add    : in  std_logic_vector(add_width -1 downto 0);
      R_add    : in  std_logic_vector(add_width -1 downto 0);
      Data_In  : in  std_logic_vector(WIDTH - 1 downto 0);
      Data_Out : out std_logic_vector(WIDTH -1 downto 0);
      WR       : in  std_logic;
      RE       : in  std_logic);
  end component;
-------------------------------------------------------------------------------
  COMPONENT wb_dpmem
    GENERIC (
      ADD_WIDTH  : INTEGER;
      WIDTH      : INTEGER;
      CLK_DOMAIN : INTEGER);
    PORT (
      CLK_I_1 : IN  STD_LOGIC;
      CLK_I_2 : IN  STD_LOGIC;
      ADR_I_1 : IN  STD_LOGIC_VECTOR(ADD_WIDTH-1 DOWNTO 0);
      ADR_I_2 : IN  STD_LOGIC_VECTOR(ADD_WIDTH-1 DOWNTO 0);
      DAT_O   : OUT STD_LOGIC_VECTOR(WIDTH -1 DOWNTO 0);
      DAT_I   : IN  STD_LOGIC_VECTOR(WIDTH -1 DOWNTO 0);
      WE_I_1  : IN  STD_LOGIC;
      WE_I_2  : IN  STD_LOGIC;
      ACK_O_1 : OUT STD_LOGIC;
      ACK_O_2 : OUT STD_LOGIC;
      STB_I_1 : IN  STD_LOGIC;
      STB_I_2 : IN  STD_LOGIC);
  END COMPONENT;
-------------------------------------------------------------------------------
  component Spmem_ent
    generic (
      USE_RESET   : boolean;
      USE_CS      : boolean;
      DEFAULT_OUT : std_logic;
      OPTION      : integer;
      ADD_WIDTH   : integer;
      WIDTH       : integer);
    port (
      cs       :     std_logic;
      clk      : in  std_logic;
      reset    : in  std_logic;
      add      : in  std_logic_vector(add_width -1 downto 0);
      Data_In  : in  std_logic_vector(WIDTH -1 downto 0);
      Data_Out : out std_logic_vector(WIDTH -1 downto 0);
      WR       : in  std_logic);
  end component;

-------------------------------------------------------------------------------
  COMPONENT WB_spmem
    GENERIC (
      ADD_WIDTH : INTEGER;
      WIDTH     : INTEGER;
      OPTION    : INTEGER);
    PORT (
      DAT_O : OUT STD_LOGIC_VECTOR(ADD_WIDTH -1 DOWNTO 0);
      DAT_I : IN  STD_LOGIC_VECTOR(WIDTH -1 DOWNTO 0);
      CLK_I : IN  STD_LOGIC;
      ADR_I : IN  STD_LOGIC_VECTOR(ADD_WIDTH -1 DOWNTO 0);
      STB_I : IN  STD_LOGIC;
      WE_I  : IN  STD_LOGIC;
      ACK_O : OUT STD_LOGIC);
  END COMPONENT;
-------------------------------------------------------------------------------  
  component FIFO_ent
    generic (
      ARCH        : integer;
      USE_CS      : boolean;
      DEFAULT_OUT : std_logic;
      CLK_DOMAIN  : integer;
      MEM_CORE    : integer;
      BLOCK_SIZE  : integer;
      WIDTH       : integer;
      DEPTH       : integer);
    port (
      rst_n      : in  std_logic;
      Rclk       : in  std_logic;
      Wclk       : in  std_logic;
      cs         : in  std_logic;
      Din        : in  std_logic_vector(WIDTH-1 downto 0);
      Dout       : out std_logic_vector(WIDTH-1 downto 0);
      Re         : in  std_logic;
      wr         : in  std_logic;
      UsedCount  : out std_logic_vector(log2(DEPTH)-1 downto 0);
      RFull      : out std_logic;
      RHalf_full : out std_logic;
      REmpty     : out std_logic;
      WFull      : out std_logic;
      WHalf_full : out std_logic;
      WEmpty     : out std_logic);
  end component;

end mem_pkg; 

-------------------------------------------------------------------------------
