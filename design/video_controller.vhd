------------------------------------------------------------------------------
-- Copyright (C) 2007 Jonathon W. Donaldson
--                    jwdonal a t opencores DOT org
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
--
------------------------------------------------------------------------------
--
-- $Id: video_controller.vhd,v 1.1 2008-11-07 00:48:12 jwdonal Exp $
--
-- Description:
--  This file instantiates the components which control HSYNCx, VSYNCx, ENAB,
--  and the CLK_LCD cycle counter.
--
-- Structure:
--   - xupv2p.ucf
--   - components.vhd
--   - lq057q3dc02_tb.vhd
--   - lq057q3dc02.vhd
--     - dcm_sys_to_lcd.xaw
--     - video_controller.vhd
--       - enab_control.vhd
--       - hsyncx_control.vhd
--       - vsyncx_control.vhd
--       - clk_lcd_cyc_cntr.vhd
--     - image_gen_bram.vhd
--       - image_gen_bram_red.xco
--       - image_gen_bram_green.xco
--       - image_gen_bram_blue.xco
--
------------------------------------------------------------------------------
--
-- Naming Conventions:
--   active low signals                                       "*x"
--   clock signal                                             "CLK_*"
--   reset signal                                             "RST"
--   generic/constant                                         "C_*"
--   user defined type                                        "TYPE_*"
--   state machine next state                                 "*_ns"
--   state machine current state                              "*_cs""
--   pipelined signals                                        "*_d#"
--   register delay signals                                   "*_p#"
--   signal                                                   "*_sig"
--   variable                                                 "*_var"
--   storage register                                         "*_reg"
--   clock enable signals                                     "*_ce"
--   internal version of output port used as connecting wire  "*_wire"
--   input/output port                                        "ALL_CAPS"
--   process                                                  "*_PROC"
--
------------------------------------------------------------------------------

--////////////////////--
-- LIBRARY INCLUSIONS --
--////////////////////--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.components.ALL;

--////////////////////--
-- ENTITY DECLARATION --
--////////////////////--
ENTITY video_controller IS
  
  generic (
    --Video Controller
    C_RL_STATUS,
    C_UD_STATUS,
    C_VQ_STATUS : STD_LOGIC;
  
    --VSYNC Controller (pass thru)
    C_VSYNC_TV,
    C_VSYNC_TVP,
    C_VSYNC_TVS,
    C_LINE_NUM_WIDTH,
    
    --HSYNCx Controller (pass thru)
    C_HSYNC_TH,
    C_HSYNC_THP,
    C_NUM_CLKS_WIDTH,
    
    --CLK_LCD Cycle Counter (pass thru)
    C_CLK_LCD_CYC_NUM_WIDTH,
    
    --ENAB Controller (pass thru)
    C_ENAB_TEP,
    C_ENAB_THE : POSITIVE
  );
  
  port (
    RSTx,
    CLK_LCD : IN std_logic;
    
    LINE_NUM : OUT std_logic_vector(C_LINE_NUM_WIDTH-1 downto 0);
    
    CLK_LCD_CYC_NUM : OUT std_logic_vector(C_CLK_LCD_CYC_NUM_WIDTH-1 downto 0);
    
    HSYNCx,
    VSYNCx,
    ENAB,
    RL,
    UD,
    VQ : OUT  std_logic
  );
  
END ENTITY video_controller;

--////////////////////////--
-- ARCHITECTURE OF ENTITY --
--////////////////////////--
ARCHITECTURE video_controller_arch OF video_controller IS

  --Connecting wires between components
  signal HSYNCx_wire   : std_logic := '1';
  signal VSYNCx_wire   : std_logic := '1';
  signal LINE_NUM_wire : std_logic_vector(C_LINE_NUM_WIDTH-1 downto 0) := (others => '0');
  signal CLK_LCD_CYC_NUM_wire : std_logic_vector(C_CLK_LCD_CYC_NUM_WIDTH-1 downto 0) := (others => '0');

begin

  --///////////////////////--
  -- CONCURRENT STATEMENTS --
  --///////////////////////--  
  RL <= C_RL_STATUS;
  UD <= C_UD_STATUS;
  VQ <= C_VQ_STATUS;
  HSYNCx <= HSYNCx_wire;
  VSYNCx <= VSYNCx_wire;
  LINE_NUM <= LINE_NUM_wire;  -- line number required by image generator used at top-level
  CLK_LCD_CYC_NUM <= CLK_LCD_CYC_NUM_wire; -- pixel number required by image generator used at top-level


  --//////////////////////////--
  -- COMPONENT INSTANTIATIONS --
  --//////////////////////////--
  ----------------------
  -- HSYNCx Control
  ----------------------
  HSYNCx_C : hsyncx_control
  generic map (
    C_HSYNC_TH => C_HSYNC_TH,
    C_HSYNC_THP => C_HSYNC_THP,
    C_NUM_CLKS_WIDTH => C_NUM_CLKS_WIDTH
  )
  port map (
    RSTx => RSTx,
    CLK_LCD => CLK_LCD,
    
    --OUTPUTS
    HSYNCx => HSYNCx_wire
  );


  ----------------------
  -- VSYNCx Control
  ----------------------
  VSYNCx_C : vsyncx_control
  generic map (
    C_VSYNC_TV => C_VSYNC_TV,
    C_VSYNC_TVP => C_VSYNC_TVP,
    C_LINE_NUM_WIDTH => C_LINE_NUM_WIDTH
  )
  port map (
    RSTx => RSTx,
    CLK_LCD => CLK_LCD,
    HSYNCx => HSYNCx_wire,
    
    --OUTPUTS
    LINE_NUM => LINE_NUM_wire,    
    VSYNCx => VSYNCx_wire
  );
  
  ---------------------------
  -- CLK_LCD Cycle Counter
  ---------------------------
  CLK_LCD_CYCLE_Cntr : clk_lcd_cyc_cntr
  GENERIC MAP (
    C_VSYNC_TVS => C_VSYNC_TVS,
    C_LINE_NUM_WIDTH => C_LINE_NUM_WIDTH,
    
    C_CLK_LCD_CYC_NUM_WIDTH => C_CLK_LCD_CYC_NUM_WIDTH,
    
    C_ENAB_TEP => C_ENAB_TEP,
    C_ENAB_THE => C_ENAB_THE
  )
  PORT MAP (
    RSTx     => RSTx,
    CLK_LCD  => CLK_LCD,
    LINE_NUM => LINE_NUM_wire,
    HSYNCx  => HSYNCx_wire,
    VSYNCx  => VSYNCx_wire,
    
    --OUTPUTS
    CLK_LCD_CYC_NUM => CLK_LCD_CYC_NUM_wire
  );

  ----------------------
  -- ENAB Control
  ----------------------
  ENAB_C : enab_control
  generic map (  
    C_VSYNC_TVS => C_VSYNC_TVS,
    
    C_CLK_LCD_CYC_NUM_WIDTH => C_CLK_LCD_CYC_NUM_WIDTH,
    
    C_ENAB_TEP => C_ENAB_TEP,
    C_ENAB_THE => C_ENAB_THE
  )
  port map (
    RSTx => RSTx,
    CLK_LCD => CLK_LCD,
    CLK_LCD_CYC_NUM => CLK_LCD_CYC_NUM_wire,
    
    -- OUTPUTS
    ENAB => ENAB
  );
  
END ARCHITECTURE video_controller_arch;
