-- Copyright 2015, Jürgen Defurne
--
-- This file is part of the Experimental Unstable CPU System.
--
-- The Experimental Unstable CPU System Is free software: you can redistribute
-- it and/or modify it under the terms of the GNU Lesser General Public License
-- as published by the Free Software Foundation, either version 3 of the
-- License, or (at your option) any later version.
--
-- The Experimental Unstable CPU System is distributed in the hope that it will
-- be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
-- General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with Experimental Unstable CPU System. If not, see
-- http://www.gnu.org/licenses/lgpl.txt.


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY t_qctrl IS
END t_qctrl;

ARCHITECTURE behavior OF t_qctrl IS

  -- Component Declaration for the Unit Under Test (UUT)
  
  COMPONENT qctrl
    PORT(
      CLK : IN  STD_LOGIC;
      RST : IN  STD_LOGIC;
      WR  : IN  STD_LOGIC;
      SH  : IN  STD_LOGIC;
      EN  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      SEL : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
      );
  END COMPONENT;


  --Inputs
  SIGNAL CLK : STD_LOGIC := '0';
  SIGNAL RST : STD_LOGIC := '0';
  SIGNAL WR  : STD_LOGIC := '0';
  SIGNAL SH  : STD_LOGIC := '0';

  --Outputs
  SIGNAL EN  : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL SEL : STD_LOGIC_VECTOR(2 DOWNTO 0);

  -- Clock period definitions
  CONSTANT CLK_period : TIME := 5.2 ns;
  
BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut : qctrl PORT MAP (
    CLK => CLK,
    RST => RST,
    WR  => WR,
    SH  => SH,
    EN  => EN,
    SEL => SEL
    );

  -- Clock process definitions
  CLK_process : PROCESS
  BEGIN
    CLK <= '0';
    WAIT FOR CLK_period/2;
    CLK <= '1';
    WAIT FOR CLK_period/2;
  END PROCESS;


  -- Stimulus process
  stim_proc : PROCESS
  BEGIN

    RST <= '1';

    WAIT FOR CLK_period*8;

    RST <= '0';
    WR  <= '1';

    WAIT FOR CLK_period*8;

    WR <= '0';
    RST <= '1';

    WAIT FOR CLK_period * 4;

    RST <= '0';

    WAIT FOR CLK_period + 0.1ns;

    WR <= '1';
    WAIT FOR CLK_period;
    
    WR <= '0';
    WAIT FOR CLK_period;

    WR <= '1';
    WAIT FOR CLK_period;
    
    WR <= '0';
    WAIT FOR CLK_period;
    WR <= '1';
    WAIT FOR CLK_period;
    
    WR <= '0';
    WAIT FOR CLK_period;
    
    WR <= '1';
    WAIT FOR CLK_period;
    
    WR <= '0';
    WAIT FOR CLK_period;

    WAIT;
  END PROCESS;

END;
