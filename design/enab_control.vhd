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
-- $Id: enab_control.vhd,v 1.1 2008-11-07 00:48:12 jwdonal Exp $
--
-- Description:
--  This file controls ENAB.  ENAB is dependent upon both HSYNCx, VSYNCx, and
--  the number of CLK_LCD cycles that have passed.  ENAB "tells" (i.e.
--  "enables") the shift registers inside the LCD to start accepting data.
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

--////////////////////--
-- ENTITY DECLARATION --
--////////////////////--
ENTITY enab_control IS
  
  generic (    
    C_VSYNC_TVS,
    
    C_CLK_LCD_CYC_NUM_WIDTH,
    
    C_ENAB_TEP,
    C_ENAB_THE : POSITIVE
  );
  
  port (
    RSTx,
    CLK_LCD : IN std_logic;
        
    CLK_LCD_CYC_NUM : IN std_logic_vector(C_CLK_LCD_CYC_NUM_WIDTH-1 downto 0);
    
    ENAB : OUT std_logic
  );
  
END ENTITY enab_control;

--////////////////////////--
-- ARCHITECTURE OF ENTITY --
--////////////////////////--
ARCHITECTURE enab_control_arch OF enab_control IS

begin

  ------------------------------------------------------------------
  --  Process Description:
  --    This process enables/disables the ENAB output signal depending
  --    on the value of the pixel/enab cycle counter and the user-defined
  --    timing parameters.
  --  
  --  Inputs:
  --    RSTx
  --    CLK_LCD
  --  
  --  Outputs:
  --    ENAB
  --
  --  Notes:
  --    N/A
  ------------------------------------------------------------------
  ENAB_cntrl_PROC : process( RSTx, CLK_LCD )
  begin
  
    if( RSTx = '0' ) then
    
      ENAB <= '0';
      
    elsif( CLK_LCD'event and CLK_LCD = '1' ) then
    
      if( CLK_LCD_CYC_NUM >= (C_ENAB_THE - 1) and --start
          CLK_LCD_CYC_NUM < (C_ENAB_THE + C_ENAB_TEP - 1) ) then --stop
      
        ENAB <= '1'; --active
        
      else
      
        ENAB <= '0';
        
      end if;
    
    end if;
    
  end process ENAB_cntrl_PROC;

END ARCHITECTURE enab_control_arch;
