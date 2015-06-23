-- Copyright (C) 2004 DSP&FPGA
-- Author: SaVa <s.valach@dspfpga.com>
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the OpenIPCore Hardware General Public
-- License as published by the OpenIPCore Organization; either version
-- 0.20-15092000 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- OpenIPCore Hardware General Public License for more details.
--
-- You should have received a copy of the OpenIPCore Hardware Public
-- License along with this program; if not, download it from
-- OpenCores.org (http://www.opencores.org/OIPC/OHGPL.shtml).


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity clk_gen is
Generic (
      ACTIVE_RST     : std_logic := '1';
      CLK_M_RATIO    : integer := 2;
      CLK_D_RATIO    : integer := 2;
      CLK_DIV_RATIO  : real := 8.0;
      POWER_UP_T     : integer := 20         -- Clk numbers - should be 200ms, for sim is shorter 
      );
Port (
-- Clocks & Resets
      CLK_IN      : in     std_logic;
      CLK_FB      : in     std_logic;
      RESET_IN    : in     std_logic;
      RESET_OUT   : out    std_logic;
      CLK         : out    std_logic;        -- System Clock
      SD_CLK_I    : out    std_logic;        -- Internal SDRAM Clock
      SD_CLK      : out    std_logic;        -- SDRAM Clock     
      LCD_CLK_I   : out    std_logic;        -- Internal Clock for LCD controller, usually CLK divided by 16 - see M/D ratio 
      POWER_UP    : out    std_logic         -- SDRAM Initial time after stable CLK
);
end clk_gen;

architecture Behavioral of clk_gen is

component BUFG 
port( I           : in     std_logic;
      O           : out    std_logic); 
end component;

component IBUFG 
port( I           : in     std_logic;
      O           : out    std_logic); 
end component;

component FDDRRSE
port( Q           : out    std_logic;
      D0          : in     std_logic;
      D1          : in     std_logic;      	
      C0          : in     std_logic;
      C1          : in     std_logic;      	
      CE          : in     std_logic;
      R           : in     std_logic;
      S           : in     std_logic);
end component;

component DCM
-- pragma translate_off
   generic ( 
            DLL_FREQUENCY_MODE      : string    := "LOW";
            DUTY_CYCLE_CORRECTION   : boolean   := TRUE;
            CLKDV_DIVIDE            : real      := CLK_DIV_RATIO;
            CLKFX_DIVIDE            : integer   := CLK_D_RATIO;
            CLKFX_MULTIPLY          : integer   := CLK_M_RATIO;
            STARTUP_WAIT            : boolean   := FALSE);  
-- pragma translate_on

   port (
         CLKIN       : in     std_logic;
         CLKFB       : in     std_logic;
         DSSEN       : in     std_logic;
         PSINCDEC    : in     std_logic;
         PSEN        : in     std_logic;
         PSCLK       : in     std_logic;
         RST         : in     std_logic;
         CLK0        : out    std_logic;
         CLK90       : out    std_logic;
         CLK180      : out    std_logic;
         CLK270      : out    std_logic;
         CLK2X       : out    std_logic;
         CLK2X180    : out    std_logic;
         CLKDV       : out    std_logic;
         CLKFX       : out    std_logic;
         CLKFX180    : out    std_logic;
         LOCKED      : out    std_logic;
         PSDONE      : out    std_logic;
         STATUS      : out    std_logic_vector(7 downto 0));
end component;

attribute DLL_FREQUENCY_MODE        : string; 
attribute DUTY_CYCLE_CORRECTION     : string; 
attribute CLKDV_DIVIDE              : real; 
attribute STARTUP_WAIT              : string; 
attribute CLKFX_DIVIDE              : integer;
attribute CLKFX_MULTIPLY            : integer; 


attribute DLL_FREQUENCY_MODE of SDRAM_DCM: label is "LOW";
attribute DUTY_CYCLE_CORRECTION of SDRAM_DCM: label is "TRUE";
attribute CLKDV_DIVIDE of SDRAM_DCM: label is CLK_DIV_RATIO;
attribute STARTUP_WAIT of SDRAM_DCM: label is "FALSE";
attribute CLKFX_DIVIDE of SDRAM_DCM: label is CLK_D_RATIO;
attribute CLKFX_MULTIPLY of SDRAM_DCM: label is CLK_M_RATIO;

attribute iob   : string;
attribute iob of SDRAM_CLK_O : label is "true"; 

signal CLK_I         : std_logic;
signal CLK_I_0       : std_logic;
signal CLK_0         : std_logic;

signal GND           : std_logic;
signal VCC           : std_logic;
signal reset_i       : std_logic;
signal lock_sh       : std_logic_vector(15 downto 0) := (Others => '0');
signal locked        : std_logic;

signal reset_out_i   : std_logic;

signal power_up_cnt  : integer range POWER_UP_T downto 0;
signal clk2x_i       : std_logic;
signal clk2x         : std_logic;
signal clk2x_i_n     : std_logic;

signal lcd_clk_ii    : std_logic;

BEGIN
GND <= '0';
VCC <= '1';

reset_i <= '1' When RESET_IN = ACTIVE_RST Else '0';

-- IBUFG Instantiation for CLK
U0_IBUFG: IBUFG
   port map (
            I        => CLK_IN,
            O        => CLK_I);

-- BUFG for system clock
SYS_CLK : BUFG
   port map (
            I        => CLK_I_0,
            O        => CLK_0);              -- System clock

-- BUFG for SDRAM clock
SDRAM_CLK : BUFG
   port map (
            I        => clk2x_i,
            O        => clk2x);

-- BUFG for SDRAM clock
LCD_CLK_GEN : BUFG
   port map (
            I        => lcd_clk_ii,
            O        => LCD_CLK_I);


SDRAM_DCM: DCM
   port map (
            CLKIN    => CLK_I,               -- Input clock, based on ETRAX SDRAM Clock
            CLKFB    => CLK_0,               -- System clock
            DSSEN    => GND,
            PSINCDEC => GND,
            PSEN     => GND,
            PSCLK    => GND,
            RST      => GND,
            CLK0     => CLK_I_0,
            CLK90    => open,
            CLK180   => open,
            CLK270   => open,
            CLK2X    => clk2x_i,            -- SDRAM Clocks
            CLK2X180 => open,
            CLKFX    => open,
            CLKDV    => lcd_clk_ii,
            LOCKED   => locked);

CLK <= CLK_0;                 -- System Clock
SD_CLK_I <= clk2x;

--- Component Generates SDRAM Clock
clk2x_i_n <= Not clk2x;

SDRAM_CLK_O : FDDRRSE
   port map (
            Q        => SD_CLK,
      	    D0       => GND,
      	    D1       => VCC,
      	    C0       => clk2x,
      	    C1       => clk2x_i_n,      	
      	    CE       => VCC,
      	    R        => GND,
      	    S        => GND);

lock_sh(0) <= locked;

GEN_LOCK : PROCESS(CLK_0, reset_i, locked)
BEGIN
--   If reset_i = '1' Then
--      lock_sh <= (Others => '0');
   If CLK_0'event And CLK_0 = '1' Then
      lock_sh(15 downto 1) <= lock_sh(14 downto 0); 
   End If;   
END PROCESS;


GEN_RST : PROCESS(CLK_0, reset_i, lock_sh)
BEGIN
   If reset_i = '1' Then
--      reset_out_i <= '1';
   ElsIf CLK_0'event And CLK_0 = '1' Then
      If lock_sh(15) = '0' Then
         reset_out_i <= '1';
      Else
         reset_out_i <= '0';
      End If;   
   End If;   
END PROCESS;

GEN_POWER_UP : PROCESS(CLK_0, reset_out_i, power_up_cnt)
BEGIN
   If CLK_0'event And CLK_0 = '1' Then
      If reset_out_i = '1' Then
         power_up_cnt <= 0;
         POWER_UP <= '0';
      ElsIf power_up_cnt < POWER_UP_T Then
         power_up_cnt <= power_up_cnt + 1;
         POWER_UP <= '0';
      Else
         POWER_UP <= '1';
      End If;
   End If;   
END PROCESS;

PROCESS(CLK_0)
BEGIN
   If CLK_0'event And CLK_0 = '1' Then
      RESET_OUT <= reset_out_i;
   End If;
END PROCESS;

END Behavioral;
