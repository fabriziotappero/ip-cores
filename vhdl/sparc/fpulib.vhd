



----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 1999  European Space Agency (ESA)
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.


-----------------------------------------------------------------------------
-- Entity: 	fpulib
-- File:	fpulib.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	component declarations for FPU related modules
------------------------------------------------------------------------------

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_iface.all;

package fpulib is

-- meiko core

component fpu 
  port (
    ss_clock   : in  clk_type;
    FpInst     : in  std_logic_vector(9 downto 0);
    FpOp       : in  std_logic;
    FpLd       : in  std_logic;
    Reset      : in  std_logic;
    fprf_dout1 : in  std_logic_vector(63 downto 0);
    fprf_dout2 : in  std_logic_vector(63 downto 0);
    RoundingMode : in  std_logic_vector(1 downto 0);
    FpBusy     : out std_logic;
    FracResult : out std_logic_vector(54 downto 3);
    ExpResult  : out std_logic_vector(10 downto 0);
    SignResult : out std_logic;
    SNnotDB    : out std_logic;
    Excep      : out std_logic_vector(5 downto 0);
    ConditionCodes : out std_logic_vector(1 downto 0);
    ss_scan_mode : in  std_logic;
    fp_ctl_scan_in : in  std_logic;
    fp_ctl_scan_out : out std_logic
  );
end component;

-- Martin Kasprzyk core

component fpu_lth 
  port (
    ss_clock   : in  std_logic;
    FpInst     : in  std_logic_vector(9 downto 0);
    FpOp       : in  std_logic;
    FpLd       : in  std_logic;
    Reset      : in  std_logic;
    fprf_dout1 : in  std_logic_vector(63 downto 0);
    fprf_dout2 : in  std_logic_vector(63 downto 0);
    RoundingMode : in  std_logic_vector(1 downto 0);
    FpBusy     : out std_logic;
    FracResult : out std_logic_vector(54 downto 3);
    ExpResult  : out std_logic_vector(10 downto 0);
    SignResult : out std_logic;
    SNnotDB    : out std_logic;
    Excep      : out std_logic_vector(5 downto 0);
    ConditionCodes : out std_logic_vector(1 downto 0);
    ss_scan_mode : in  std_logic;
    fp_ctl_scan_in : in  std_logic;
    fp_ctl_scan_out : out std_logic
  );
end component;

-- wrapper for meiko-compatible cores

component fpu_core 
port (
    clk    : in  clk_type;
    fpui   : in  fpu_in_type;
    fpuo   : out fpu_out_type
  );
end component;

component fp
port (
    rst    : in  std_logic;			-- Reset
    clk    : in  clk_type;			-- main clock	
    iuclk  : in  clk_type;			-- gated IU clock
    holdn  : in  std_logic;			-- pipeline hold
    xholdn : in  std_logic;			-- pipeline hold
    cpi    : in  cp_in_type;
    cpo    : out cp_out_type
  );
end component;

component fp1eu
port (
    rst    : in  std_logic;			-- Reset
    clk    : in  clk_type;
    holdn  : in  std_logic;			-- Reset
    xholdn : in  std_logic;			-- Reset
    cpi    : in  cp_in_type;
    cpo    : out cp_out_type
  );
end component;

component grfpc 
port (
    rst    : in  std_logic;			-- Reset
    clk    : in  clk_type;
    holdn  : in  std_logic;			-- pipeline hold
    xholdn : in  std_logic;			-- pipeline hold
    cpi    : in  cp_in_type;
    cpo    : out cp_out_type    
    );
end component; 

end; 



