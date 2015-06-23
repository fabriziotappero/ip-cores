----------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2004 GAISLER RESEARCH
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  See the file COPYING for the full details of the license.
--
-----------------------------------------------------------------------------
-- package: 	cancomp
-- File:	cancomp.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Opencores CAN core components
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package cancomp is

  component can_top
    port(
        rst             : IN std_logic;   
        addr            : IN std_logic_vector(7 DOWNTO 0);   
        data_in         : IN std_logic_vector(7 DOWNTO 0);   
        data_out        : OUT std_logic_vector(7 DOWNTO 0);   
        cs              : IN std_logic;   
        we              : IN std_logic;   
        clk_i           : in    std_logic;
        rx_i            : in    std_logic;
        tx_o            : out   std_logic;
        bus_off_on      : out   std_logic;
        irq_on          : out   std_logic;
        clkout_o        : out   std_logic;
  	q_dp_64x8	: in  std_logic_vector(7 downto 0);
  	data_64x8	: out std_logic_vector(7 downto 0);
  	wren_64x8	: out std_logic;
  	rden_64x8	: out std_logic;
  	wraddress_64x8	: out std_logic_vector(5 downto 0);
  	rdaddress_64x8	: out std_logic_vector(5 downto 0);
	q_dp_64x4	: in std_logic_vector(3 downto 0);
	data_64x4	: out std_logic_vector(3 downto 0);
	wren_64x4x1	: out std_logic;
	wraddress_64x4x1: out std_logic_vector(5 downto 0);
	rdaddress_64x4x1: out std_logic_vector(5 downto 0);
  	q_dp_64x1	: in std_logic;
  	data_64x1	: out std_logic

    );
  end component;

  component can_top_sync
    port(
        rst             : IN std_logic;   
        addr            : IN std_logic_vector(7 DOWNTO 0);   
        data_in         : IN std_logic_vector(7 DOWNTO 0);   
        data_out        : OUT std_logic_vector(7 DOWNTO 0);   
        cs              : IN std_logic;   
        we              : IN std_logic;   
        clk_i           : in    std_logic;
        rx_i            : in    std_logic;
        tx_o            : out   std_logic;
        bus_off_on      : out   std_logic;
        irq_on          : out   std_logic;
        clkout_o        : out   std_logic;
  	q_dp_64x8	: in  std_logic_vector(7 downto 0);
  	data_64x8	: out std_logic_vector(7 downto 0);
  	wren_64x8	: out std_logic;
  	rden_64x8	: out std_logic;
  	wraddress_64x8	: out std_logic_vector(5 downto 0);
  	rdaddress_64x8	: out std_logic_vector(5 downto 0);
	q_dp_64x4	: in std_logic_vector(3 downto 0);
	data_64x4	: out std_logic_vector(3 downto 0);
	wren_64x4x1	: out std_logic;
	wraddress_64x4x1: out std_logic_vector(5 downto 0);
	rdaddress_64x4x1: out std_logic_vector(5 downto 0);
  	q_dp_64x1	: in std_logic;
  	data_64x1	: out std_logic

    );
  end component;

end;

