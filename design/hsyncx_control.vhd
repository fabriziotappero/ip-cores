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
-- $Id: hsyncx_control.vhd,v 1.1 2008-11-07 00:48:12 jwdonal Exp $
--
-- Description:
--  This file controls the HSYNCx signal.  The HSYNCx state machine is
--  very simplistic since the current state is only dependent on the number
--  of LCD clocks that have occurred.  It has no other dependencies whatsoever!
--  However, all other controllers (i.e. VSYNCx, ENAB, PIX_gen) are all dependent
--  upon HSYNCx.
--
-- Notes: that even though VSYNCx controls the start of a frame
--  you cannot simply disable HSYNCx cycling once the data has been shifted
--  into the LCD.  This is b/c there is a MAX cycle time spec in the datasheet
--  of 450 clocks!  It is simplest to just leave HSYNCx running at all times
--  no matter what.
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
ENTITY hsyncx_control IS
  
  generic (
    C_HSYNC_TH,
    C_HSYNC_THP,
    C_NUM_CLKS_WIDTH : POSITIVE
  );
  
  port (
    RSTx,
    CLK_LCD : IN std_logic;
    
    HSYNCx : OUT std_logic
  );
  
END ENTITY hsyncx_control;

--////////////////////////--
-- ARCHITECTURE OF ENTITY --
--////////////////////////--
ARCHITECTURE hsyncx_control_arch OF hsyncx_control IS
  
  signal num_hsyncx_clks_reg : std_logic_vector(C_NUM_CLKS_WIDTH-1 downto 0) := (others => '0');
    
begin

  ------------------------------------------------------------------
  --  Process Description:
  --    This process enables or disables the HSYNCx port depending
  --    upon the number of clocks that have passed (num_hsyncx_clks_reg)
  --    relative to C_HSYNC_THP.
  --  
  --  Inputs:
  --    RSTx
  --    CLK_LCD
  --  
  --  Outputs:
  --    HSYNCx
  --
  --  Notes:
  --    N/A
  ------------------------------------------------------------------
  HSYNCx_cntrl_PROC : process( RSTx, CLK_LCD )
  begin
  
    if( RSTx = '0' ) then
    
      HSYNCx <= '1';
    
    elsif( CLK_LCD'event and CLK_LCD = '1' ) then
    
      if( num_hsyncx_clks_reg < C_HSYNC_THP ) then
      
        HSYNCx <= '0';
      
      else
      
        HSYNCx <= '1';
        
      end if;
    
    end if;
    
  end process HSYNCx_cntrl_PROC;
  

  ------------------------------------------------------------------
  --  Process Description:
  --    This process controls the num_hsyncx_clks_reg counter
  --    and resets it when it has reached the defined C_HSYNC_TH
  --    parameter.
  --  
  --  Inputs:
  --    RSTx
  --    CLK_LCD
  --  
  --  Outputs:
  --    num_hsyncx_clks_reg
  --
  --  Notes:
  --    N/A
  ------------------------------------------------------------------
  HSYNCx_CLK_LCD_Cntr_PROC : process( RSTx, CLK_LCD )
  begin

    if( RSTx = '0' ) then
    
      num_hsyncx_clks_reg <= (others => '0');
    
    elsif( CLK_LCD'event and CLK_LCD = '1' ) then
      
      if( num_hsyncx_clks_reg = C_HSYNC_TH - 1 ) then -- 0 to (TH - 1) = TH clocks!
      
        num_hsyncx_clks_reg <= (others => '0'); -- a full HSYNC cycle has completed.  START OVER!
      
      else
      
        num_hsyncx_clks_reg <= num_hsyncx_clks_reg + 1;  -- keep counting until we have reached a full HSYNC cycle
      
      end if;

    end if;
    
  end process HSYNCx_CLK_LCD_Cntr_PROC;
  
  
END ARCHITECTURE hsyncx_control_arch;
