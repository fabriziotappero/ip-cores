
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
-- Entity: 	meiko
-- File:	meiko.vhd
-- Description:	Dummy version of Meiko FPU
------------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use work.leon_iface.all;

entity fpu is
  port(
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
end;

architecture rtl of fpu is
begin
  FpBusy <= '1';
  FracResult <= (others => '0');
  ExpResult <= (others => '0');
  Excep <= (others => '0');
  ConditionCodes <= (others => '0');
  SignResult <= '0';
  SNnotDB <= '0';

end;

