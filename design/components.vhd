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
-- $Id: components.vhd,v 1.2 2008-11-07 04:54:32 jwdonal Exp $
--
-- Description:
--   This is a package that lists all of the components used in the design.
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
--       - pix_enab_clk_cntr.vhd
--     - image_gen.vhd
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
--   generic                                                  "C_*"
--   user defined type                                        "TYPE_*"
--   state machine next state                                 "*_ns"
--   state machine current state                              "*_cs""
--   pipelined signals                                        "*_d#"
--   register delay signals                                   "*_p#"
--   signal                                                   "*_sig"
--   variable                                                 "*_var"
--   clock enable signals                                     "*_ce"
--   internal version of output port used as register         "*_reg"
--   internal version of output port used as connecting wire  "*_wire"
--   input/output port                                        "ALL_CAPS"
--   process                                                  "*_PROC"
--
------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

PACKAGE components IS

  ATTRIBUTE BOX_TYPE: string; -- used to remove "Black Box" warning messages in the synthesis report

  ----------------------
  -- DCM LCD Clock
  ----------------------
  COMPONENT dcm_sys_to_lcd
  PORT (
    RST_IN,
    CLKIN_IN : IN std_logic;
    
    CLKIN_IBUFG_OUT,
    CLK0_OUT,
    CLKDV_OUT,
    CLKFX_OUT       : OUT std_logic
  );
  END COMPONENT dcm_sys_to_lcd;


  ----------------------
  -- CLK_LCD Cycle Counter for ENAB and
  -- image_gen_bram controllers
  ----------------------
  COMPONENT clk_lcd_cyc_cntr is
  GENERIC (
    C_VSYNC_TVS,
    C_LINE_NUM_WIDTH,
    
    C_CLK_LCD_CYC_NUM_WIDTH,

    C_ENAB_TEP,
    C_ENAB_THE : POSITIVE
  );

  PORT (
    RSTx,
    CLK_LCD,
    HSYNCx,
    VSYNCx : IN std_logic;
    
    LINE_NUM : IN std_logic_vector(C_LINE_NUM_WIDTH-1 downto 0);
    
    CLK_LCD_CYC_NUM : OUT std_logic_vector(C_CLK_LCD_CYC_NUM_WIDTH-1 downto 0)
  );
  END COMPONENT clk_lcd_cyc_cntr;

  ----------------------
  -- Video Controller
  ----------------------
  COMPONENT video_controller is
  GENERIC (
    --Video Controller
    C_RL_STATUS,
    C_UD_STATUS,
    C_VQ_STATUS : std_logic;
      
    --VSYNCx Controller (pass thru)
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
  
  PORT (
    RSTx,
    CLK_LCD : IN  std_logic;
    
    LINE_NUM : OUT std_logic_VECTOR(C_LINE_NUM_WIDTH-1 downto 0);
    
    CLK_LCD_CYC_NUM : OUT std_logic_VECTOR(C_CLK_LCD_CYC_NUM_WIDTH-1 downto 0);
    
    HSYNCx,
    VSYNCx,
    ENAB,
    RL,
    UD,
    VQ    : OUT std_logic
  );
  END COMPONENT video_controller;
  
  
  ----------------------
  -- HSYNCx Control
  ----------------------
  COMPONENT hsyncx_control is  
  GENERIC (
    C_HSYNC_TH,
    C_HSYNC_THP,
    C_NUM_CLKS_WIDTH : POSITIVE
  );
  PORT (
    RSTx,
    CLK_LCD : IN  std_logic;
    
    HSYNCx  : OUT std_logic
  );
  END COMPONENT hsyncx_control;


  ----------------------
  -- VSYNCx Control
  ----------------------
  COMPONENT vsyncx_control is
  GENERIC (
    C_VSYNC_TV,
    C_VSYNC_TVP,
    C_LINE_NUM_WIDTH : POSITIVE
  );
  
  PORT (
    RSTx,
    CLK_LCD,
    HSYNCx   : IN  std_logic;
    
    LINE_NUM : OUT std_logic_VECTOR(C_LINE_NUM_WIDTH-1 downto 0);
  
    VSYNCx   : OUT std_logic
  );
  END COMPONENT vsyncx_control;


  ----------------------
  -- ENAB Control
  ----------------------
  COMPONENT enab_control is
  GENERIC (
    C_VSYNC_TVS,
    
    C_CLK_LCD_CYC_NUM_WIDTH,
    
    C_ENAB_TEP,
    C_ENAB_THE : POSITIVE
  );
  PORT (
    RSTx,
    CLK_LCD : IN std_logic;
    
    CLK_LCD_CYC_NUM : IN std_logic_VECTOR(C_CLK_LCD_CYC_NUM_WIDTH-1 downto 0);
    
    ENAB  : OUT std_logic
  );
  END COMPONENT enab_control;


  -----------------------
  -- BRAM Image Generator
  -----------------------
  COMPONENT image_gen_bram is
  GENERIC (
    C_BIT_DEPTH,
    
    C_VSYNC_TVS,
    C_LINE_NUM_WIDTH,
    
    C_CLK_LCD_CYC_NUM_WIDTH,
    
    C_ENAB_TEP,
    C_ENAB_THE,

    C_BRAM_ADDR_WIDTH,
    C_IMAGE_WIDTH,
    C_IMAGE_HEIGHT : POSITIVE
  );
  PORT (
    RSTx,
    CLK_LCD : IN std_logic;
    
    LINE_NUM : IN std_logic_VECTOR(C_LINE_NUM_WIDTH-1 downto 0);
    
    CLK_LCD_CYC_NUM : IN std_logic_VECTOR(C_CLK_LCD_CYC_NUM_WIDTH-1 downto 0);
    
    R,
    G,
    B : OUT std_logic_VECTOR(C_BIT_DEPTH/3-1 downto 0)
  );
  END COMPONENT image_gen_bram;


  --------------------------
  -- Image Generator BRAM --
  --------------------------
  --You can't simply instantiate one XCO BRAM component 3 times because all
  --three components are initialized with 3 different COE files!
  --We also use SINIT in place of EN port because disabling EN (i.e. making it '0')
  --cuases the output ports to remain at the last output value.  SINIT
  --resets the output back to '0' whenever it is disabled.  Which is exactly what we want
  --b/c if the last value reamins (as it would with EN) the last pixel drawn for the
  --image in each row would be "smeared" across the remaining pixels in the row!
  COMPONENT image_gen_bram_red
  PORT (
    clka : IN std_logic;
    addra : IN std_logic_VECTOR(17-1 downto 0);    
    douta : OUT std_logic_VECTOR(6-1 downto 0)
  );
  END COMPONENT;
  ATTRIBUTE BOX_TYPE of image_gen_bram_red: component is "USER_BLACK_BOX";
  
  COMPONENT image_gen_bram_green
  PORT (
    clka : IN std_logic;
    addra : IN std_logic_VECTOR(17-1 downto 0);    
    douta : OUT std_logic_VECTOR(6-1 downto 0)
  );
  END COMPONENT;
  ATTRIBUTE BOX_TYPE of image_gen_bram_green: component is "USER_BLACK_BOX";
  
  COMPONENT image_gen_bram_blue
  PORT (
    clka : IN std_logic;
    addra : IN std_logic_VECTOR(17-1 downto 0);    
    douta : OUT std_logic_VECTOR(6-1 downto 0)
  );
  END COMPONENT;
  ATTRIBUTE BOX_TYPE of image_gen_bram_blue: component is "USER_BLACK_BOX";


END PACKAGE components;
