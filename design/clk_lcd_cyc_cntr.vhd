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
-- $Id: clk_lcd_cyc_cntr.vhd,v 1.1 2008-11-07 00:48:12 jwdonal Exp $
--
-- Description:
--   Counts the number of CLK_LCD cycles that have occured after C_VSYNC_TVS
--   lines have passed.  The output vector is then used by ENAB and the IMAGE
--   generator for pulse and data timing.  This method allows for a single
--   common counter for both the ENAB and image controller blocks.  THe less
--   efficient way would be to have two counters - one for each block.
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
ENTITY clk_lcd_cyc_cntr IS

  generic (
    C_VSYNC_TVS,
    C_LINE_NUM_WIDTH,
    
    C_CLK_LCD_CYC_NUM_WIDTH,

    C_ENAB_TEP,
    C_ENAB_THE : POSITIVE
  );

  port (

    RSTx,
    CLK_LCD,
    HSYNCx,
    VSYNCx : IN std_logic;
    
    LINE_NUM : IN std_logic_vector(C_LINE_NUM_WIDTH-1 downto 0);
    
    CLK_LCD_CYC_NUM : OUT std_logic_vector(C_CLK_LCD_CYC_NUM_WIDTH-1 downto 0)

  );
  
END ENTITY clk_lcd_cyc_cntr;

--////////////////////////--
-- ARCHITECTURE OF ENTITY --
--////////////////////////--
ARCHITECTURE clk_lcd_cyc_cntr_arch OF clk_lcd_cyc_cntr IS

  constant C_NUM_LCD_LINES : positive := 240;  -- number of drawable lines in the LCD
  constant C_NUM_LCD_PIXELS : positive := 320; -- number of drawable pixels per line in the LCD
  
  --Enables/disables counter for pixel/enab counter process
  signal clk_cyc_cnt_en_sig : std_logic := '0';
  
  --Stores the number of CLK_LCD cycles that have occurred
  signal clk_cyc_num_reg : std_logic_vector(C_CLK_LCD_CYC_NUM_WIDTH-1 downto 0) := (others => '0');

  ---------------------------------------------------------------
  -- States for CLK_Cntr_cntrl_*_PROC
  ---------------------------------------------------------------
  --INACTIVE_WAIT_1 => wait here until new screen or new line starts
  --INACTIVE_WAIT_2 => wait for HSYNCx pulse to deactivate b/c THE is measured from rising edge of HSYNCx pulse
  --INACTIVE_WAIT_TVS => wait for TVS timespec to pass
  --INACTIVE_WAIT_THE => wait THE timespec to pass
  --ACTIVE => enable clock cycle counter
  type TYPE_CLK_Cntr_sts is ( INACTIVE_WAIT_1, INACTIVE_WAIT_2,
                              INACTIVE_WAIT_TVS, INACTIVE_WAIT_THE,
                              ACTIVE );
  signal CLK_Cntr_cs : TYPE_CLK_Cntr_sts;
  signal CLK_Cntr_ns : TYPE_CLK_Cntr_sts;

begin

  --///////////////////////--
  -- CONCURRENT STATEMENTS --
  --///////////////////////--
  CLK_LCD_CYC_NUM <= clk_cyc_num_reg;
  
  
  ------------------------------------------------------------------
  --  Process Description:
  --    This is finite state machine process 1 of 3 for counting the
  --    number of CLK_LCD cycles that have passed which controls
  --    the pixel and ENAB count value (clk_cyc_num_reg).  This process
  --    only controls the reset of the state and the "current state to
  --    next state" assignment.
  --  
  --  Inputs:
  --    RSTx
  --    CLK_LCD
  --  
  --  Outputs:
  --    CLK_Cntr_cs
  --
  --  Notes:
  --    N/A
  ------------------------------------------------------------------
  CLK_Cntr_cntrl_1_PROC : process( RSTx, CLK_LCD )
  begin
  
    if( RSTx = '0' ) then
    
      CLK_Cntr_cs <= INACTIVE_WAIT_1;
      
    elsif( CLK_LCD'event and CLK_LCD = '1' ) then
    
      CLK_Cntr_cs <= CLK_Cntr_ns;
    
    end if;
    
  end process CLK_Cntr_cntrl_1_PROC;


  ------------------------------------------------------------------
  --  Process Description:
  --    This is finite state machine process 2 of 3 for counting the
  --    number of CLK_LCD cycles that have passed which controls
  --    the pixel and ENAB count value (clk_cyc_num_reg).  This process
  --    controls all of the state changes.
  --  
  --  Inputs:
  --    CLK_Cntr_cs
  --    HSYNCx
  --    VSYNCx
  --    LINE_NUM
  --    clk_cyc_num_reg
  --  
  --  Outputs:
  --    CLK_Cntr_ns
  --
  --  Notes:
  --    N/A
  ------------------------------------------------------------------
  CLK_Cntr_cntrl_2_PROC : process( CLK_Cntr_cs, HSYNCx, VSYNCx, LINE_NUM, clk_cyc_num_reg )
  begin
  
    case CLK_Cntr_cs is
    
      when INACTIVE_WAIT_1 => -- once we are in WAIT_1 we are either going to (A) be completely finished drawing the screen or (B) go to the next line.
      
        if( HSYNCx = '0' and VSYNCx = '0' ) then -- if new frame has begun
        
          CLK_Cntr_ns <= INACTIVE_WAIT_TVS; -- go to next state (the reason we do not have to wait for HSYNCx to go high (i.e. go to state INACTIVE_WAIT_2) is b/c LINE_NUM will not change until HSYNCx has already gone high - therefore we do not need to enter WAIT_2 state waiting for HSYNCx to go high.  We can just skip that state! :-))
        
        elsif( HSYNCx = '0' and LINE_NUM < (C_VSYNC_TVS + 1) + (C_NUM_LCD_LINES - 1) ) then --if only a new line has begun, not a whole new frame.  And only if we have not drawn all the lines already (there is a delay between the last line drawn to the screen and the next VSYNCx pulse!)
        
          CLK_Cntr_ns <= INACTIVE_WAIT_2;  -- Once HSYNCx is activated we need to wait for it to deactivate before couting 'THE' CLK_LCD cycles b/c THE timespec is measured from the rising edge of the HSYNCx pulse!!!

        else
        
          CLK_Cntr_ns <= INACTIVE_WAIT_1;  -- we haven't drawn a full screen yet!  Get ready to send another line of data when HSYNCx activates!
        
        end if;
      
      when INACTIVE_WAIT_2 => -- wait for HSYNCx pulse to be deactivated (rise)
      
        if( HSYNCx = '1' ) then
        
          CLK_Cntr_ns <= INACTIVE_WAIT_THE;  -- Once HSYNCx is deactivated we need to wait THE CLK_LCD cycles before activating again
          
        else
        
          CLK_Cntr_ns <= INACTIVE_WAIT_2; -- keep waiting for HSYNCx pulse to disable
          
        end if;
      
      when INACTIVE_WAIT_TVS =>
      
        if( LINE_NUM = C_VSYNC_TVS + 1 ) then -- if enough lines (HSYNCx pulses) have passed after the *falling* edge of VSYNCx pulse (timespec TVS).  We need to start sending exactly on the 8th line (i.e. TVS + 1)!!  If we start sending even one line before or even one line after the entire screen will not be drawn!
        
          CLK_Cntr_ns <= INACTIVE_WAIT_THE;  -- go to next state
        
        else
        
          CLK_Cntr_ns <= INACTIVE_WAIT_TVS;  -- still inactive until _after_ 7 lines (HSYNCx pulses) have passed!
          
        end if;
        
      when INACTIVE_WAIT_THE =>
      
        if( clk_cyc_num_reg = C_ENAB_THE - 1 ) then -- 0 to (THE - 1) = THE clocks!
        
          CLK_Cntr_ns <= ACTIVE; -- go to next state (PHEW!  We can finally start sending data!)
          
        else
        
          CLK_Cntr_ns <= INACTIVE_WAIT_THE; -- still inactive until after timespec THE has passed
          
        end if;
        
      when ACTIVE =>  -- Now that ENAB is active we want it to stay active for TEP CLK_LCD cycles
      
        if( clk_cyc_num_reg = C_ENAB_THE + C_NUM_LCD_PIXELS - 1 ) then -- C_ENAB_THE to C_ENAB_THE + (320 - 1) = C_ENAB_TEP clocks!
        
          CLK_Cntr_ns <= INACTIVE_WAIT_1; -- once TEP clocks have passed we disable ENAB!
          
        else 
        
          CLK_Cntr_ns <= ACTIVE; --enable counter (whose value is used by ENAB controller and image generator)
          
        end if;
      
      when others => --UH OH! How did we get here???
      
        CLK_Cntr_ns <= INACTIVE_WAIT_1;
        
    end case;
    
  end process CLK_Cntr_cntrl_2_PROC;
  

  ------------------------------------------------------------------
  --  Process Description:
  --    This is finite state machine process 3 of 3 for counting the
  --    number of CLK_LCD cycles that have passed which controls
  --    the pixel and ENAB count value (clk_cyc_num_reg).  This process
  --    only controls the change of output values based on the current
  --    state.
  --  
  --  Inputs:
  --    CLK_Cntr_cs
  --  
  --  Outputs:
  --    clk_cyc_cnt_en_sig
  --
  --  Notes:
  --    N/A
  ------------------------------------------------------------------
  CLK_Cntr_cntrl_3_PROC : process( CLK_Cntr_cs )
  begin
  
    case CLK_Cntr_cs is
    
      when INACTIVE_WAIT_1 => --reset counter when not sending data (will go to either TVS-wait if a new frame is starting or INACTIVE_WAIT_2 if just a new line is starting)
      
        clk_cyc_cnt_en_sig <= '0';

      when INACTIVE_WAIT_2 => --reset counter when not sending data (not a new frame, but we still need to wait for HSYNCx to go high, then go to THE)
      
        clk_cyc_cnt_en_sig <= '0';
        
      when INACTIVE_WAIT_TVS => --reset counter when waiting for 7 lines (TVS) to pass
      
        clk_cyc_cnt_en_sig <= '0';
        
      when INACTIVE_WAIT_THE =>  --count THE clock wait for ENAB
      
        clk_cyc_cnt_en_sig <= '1';
      
      when ACTIVE => --count number of pixels to send (320 pixels across)
      
        clk_cyc_cnt_en_sig <= '1';
        
      when others => --UH OH! How did we get here???
      
        clk_cyc_cnt_en_sig <= '0';
      
    end case;
    
  end process CLK_Cntr_cntrl_3_PROC;
  
  
  ------------------------------------------------------------------
  --  Process Description:
  --    This process enables/disables the pixel/enab counter dependent
  --    upon the value of clk_cyc_cnt_en_sig.
  --  
  --  Inputs:
  --    RSTx
  --    CLK_LCD
  --  
  --  Outputs:
  --    clk_cyc_num_reg
  --
  --  Notes:
  --    N/A
  ------------------------------------------------------------------
  CLK_Cycle_Cntr_PROC : process( RSTx, CLK_LCD )
  begin
  
    if( RSTx = '0' ) then
    
      clk_cyc_num_reg <= (others => '0');
      
    elsif( CLK_LCD'event and CLK_LCD = '1' ) then
    
      if( clk_cyc_cnt_en_sig = '1' ) then
      
        clk_cyc_num_reg <= clk_cyc_num_reg + 1;
        
      else
      
        clk_cyc_num_reg <= (others => '0');
        
      end if;
    
    end if;
    
  end process CLK_Cycle_Cntr_PROC;
  

END ARCHITECTURE clk_lcd_cyc_cntr_arch;
