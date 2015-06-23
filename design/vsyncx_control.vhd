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
-- $Id: vsyncx_control.vhd,v 1.1 2008-11-07 00:48:12 jwdonal Exp $
--
-- Description:
--  This file controls VSYNCx.  VSYNCx is dependent upon the number of HSYNCx
--  activations (i.e. the numbers of lines) that have passed.  The really cool
--  thing about the VSYNCx control state machine is that it is _EXACTLY_ the
--  same as the HSYNCx control state machine expect that instead of have the
--  counter process counting CLK_LCD cycles we have counting HSYNCx cycles!
--  It's really that simple!
--
--  VSYNCx signifies the start of a frame.  HSYNCx must pulse exactly 7 times
--  (i.e. 7 lines) after (minimum of 0 ns after - TVh) VSYNCx pulse occurs
--  before sending data to the LCD.  You can consider these 7 lines as blank
--  lines that "live" above the physical top of the screen.  After 7 HSYNCx
--  pulses have passed we can then start with line 1 and go to line 240 for a
--  total of 7 + 240 lines = 247 lines (or HSYNCx pulses) for every complete
--  image or "frame" drawn to the screen!
--
-- Note: Even though VSYNCx controls the start of a frame you cannot simply
-- disable HSYNCx cycling once the data has been shifted into the LCD.  This
-- is b/c there is a MAX cycle time spec in the datasheet of 450 clocks!
-- It is simplest to just leave HSYNCx running at all times no matter what.
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
ENTITY vsyncx_control IS
  
  -----------------------------------------------------------------
  -- Generic Descriptions:
  --
  -- C_LINE_NUM_WIDTH   -- Must be at least 9 bits to hold maximum
  --                    -- timespec of 280 lines.
  -----------------------------------------------------------------
  generic (
  
    C_VSYNC_TV,
    C_VSYNC_TVP,
    C_LINE_NUM_WIDTH : POSITIVE

  );
  
  port (
  
    RSTx,
    CLK_LCD,
    HSYNCx : IN STD_LOGIC;
    
    LINE_NUM : OUT STD_LOGIC_VECTOR(C_LINE_NUM_WIDTH-1 downto 0);
    
    VSYNCx : OUT STD_LOGIC
    
  );
  
END ENTITY vsyncx_control;

--////////////////////////--
-- ARCHITECTURE OF ENTITY --
--////////////////////////--
ARCHITECTURE vsyncx_control_arch OF vsyncx_control IS

  --Enables/Disables the line counter process
  signal line_cnt_en_sig : std_logic;
  
  --Stores current line number.
  --This register is attached to the LINE_NUM output.
  signal line_num_reg : std_logic_vector(C_LINE_NUM_WIDTH-1 downto 0) := (others => '0');

  ---------------------------------------------------------------
  -- States for VSYNCx_Line_Cntr_*_PROC
  ---------------------------------------------------------------
  --FRAME_START => Start of a new frame
  --ADD => Add one (1) to the line count
  --ADD_WAIT => Wait for HSYNCx pulse to pass
  --READY => Get ready to add one (1) for the next line
  type TYPE_Line_Cntr_Sts is ( FRAME_START, ADD, ADD_WAIT, READY );
  signal Line_Cntr_cs : TYPE_Line_Cntr_Sts;
  signal Line_Cntr_ns : TYPE_Line_Cntr_Sts;
  
begin

  --///////////////////////--
  -- CONCURRENT STATEMENTS --
  --///////////////////////--
  LINE_NUM <= line_num_reg;


  --///////////--
  -- PROCESSES --
  --///////////--
  
  ------------------------------------------------------------------
  --  Process Description:
  --    This is finite state machine process 1 of 3 for the VSYNCx
  --    signal controller.  This process only controls the reset of
  --    the state and the "current state to next state" assignment.
  --  
  --  Inputs:
  --    RSTx
  --    CLK_LCD
  --  
  --  Outputs:
  --    Line_Cntr_cs
  --
  --  Notes:
  --    N/A
  ------------------------------------------------------------------
  VSYNCx_Line_Cntr_1_PROC : process( RSTx, CLK_LCD )
  begin

    if( RSTx = '0' ) then
    
      Line_Cntr_cs <= READY;

    elsif( CLK_LCD'event and CLK_LCD = '1' ) then
    
      Line_Cntr_cs <= Line_Cntr_ns;
      
    end if;
    
  end process VSYNCx_Line_Cntr_1_PROC;


  ------------------------------------------------------------------
  --  Process Description:
  --    This is finite state machine process 2 of 3 for the VSYNCx
  --    signal controller.  This process controls all of the state
  --    changes.
  --  
  --  Inputs:
  --    Line_Cntr_cs
  --    HSYNCx
  --    line_num_reg
  --  
  --  Outputs:
  --    Line_Cntr_ns
  --
  --  Notes:
  --    We only want to start counting lines at the first HSYNCx pulse
  --    we see _after_ VSYNCx has been activated.  This is because
  --    VSYNCx must occur before HSYNCx can be counted (NOTE: there is
  --    no sense in couting lines unless we know that a new frame has
  --    started - this is _most_ important for the ENAB_Cntrl process!)
  ------------------------------------------------------------------
  VSYNCx_Line_Cntr_2_PROC : process( Line_Cntr_cs, HSYNCx, line_num_reg )
  begin
  
    case Line_Cntr_cs is
    
      when FRAME_START =>  --reset the counter because we have started a new frame!
      
        if( HSYNCx = '0' ) then -- a new frame is starting (controlled by VSYNCx_control state machine) and here is our first line!
      
          Line_Cntr_ns <= ADD_WAIT; -- do not add +1 lines until HSYNCx goes high!  The rising edge is what counts as a line, not the falling edge!
          
        else
        
          Line_Cntr_ns <= FRAME_START; -- keep waiting for first line to occur after start of new frame
          
        end if;
        
      when ADD_WAIT =>
      
        if( HSYNCx = '1' ) then
          
          Line_Cntr_ns <= ADD;  -- line_num_reg + 1 !
          
        else
          
          Line_Cntr_ns <= ADD_WAIT; -- stay here until HSYNCx has been released b/c we only want to count the rising edge of HSYNCx as a line!
          
        end if;
      
      when ADD =>
      
        Line_Cntr_ns <= READY;  -- get ready to count another line if necessary
      
      when READY =>
      
        if( line_num_reg = C_VSYNC_TV - 1 ) then -- 0 to 254 = 255 lines (first make sure we haven't reach the end of the VSYNC cycle - which is just a little bit longer than the actual number of lines on the screen - TV)
        
          Line_Cntr_ns <= FRAME_START; -- if we've reached the max VSYNC cycle time (i.e. TV) then start over!
          
        elsif( HSYNCx = '0' ) then
          
          Line_Cntr_ns <= ADD_WAIT; -- a new line has started!  line_num_reg + 1!!
          
        else
        
          Line_Cntr_ns <= READY; -- stay here until HSYNCx pulse occurs
          
        end if;
        
      when others => --UH OH!  How did we get here???
      
        Line_Cntr_ns <= FRAME_START;
      
    end case;
  
  end process VSYNCx_Line_Cntr_2_PROC;
  
  
  ------------------------------------------------------------------
  --  Process Description:
  --    This is finite state machine process 3 of 3 for the VSYNCx
  --    signal controller.  This process only controls the change of
  --    of output values based on the current state.
  --  
  --  Inputs:
  --    Line_Cntr_cs
  --  
  --  Outputs:
  --    line_cnt_en_sig
  --
  --  Notes:
  --    N/A
  ------------------------------------------------------------------
  VSYNCx_Line_Cntr_3_PROC : process( Line_Cntr_cs )
  begin
  
    case Line_Cntr_cs is
    
      when FRAME_START => --reset line_num_reg at start of new frame
      
        line_cnt_en_sig <= '0';
    
      when READY =>
      
        line_cnt_en_sig <= '0';
    
      when ADD_WAIT =>
      
        line_cnt_en_sig <= '0';
      
      when ADD => --we will only ever be in this state for one CLK_LCD cycle.  This is IMPORTANT! b/c we only want to count one CLK_LCD cycle worth of the HSYNCx active pulse no matter how long the HSYNCx pulse is!
        
        line_cnt_en_sig <= '1';
      
      when others => --UH OH!  How did we get here???
      
        line_cnt_en_sig <= '0';
        
    end case;
  
  end process VSYNCx_Line_Cntr_3_PROC;

  
  ------------------------------------------------------------------
  --  Process Description:
  --    This process starts, stops, and resets the line counter
  --    based on the line count enable signal and the current state
  --    of the line counter state machine.
  --  
  --  Inputs:
  --    RSTx
  --    CLK_LCD
  --  
  --  Outputs:
  --    line_num_reg
  --
  --  Notes:
  --    N/A
  ------------------------------------------------------------------
  Line_cntr_PROC : process( RSTx, CLK_LCD )
  begin
  if( RSTx = '0' ) then
  
    line_num_reg <= (others => '0');
    
  elsif( CLK_LCD'event and CLK_LCD = '1' ) then
  
    if( line_cnt_en_sig = '1' ) then
    
      line_num_reg <= line_num_reg + 1;
    
    elsif( Line_Cntr_cs = FRAME_START ) then
    
      line_num_reg <= (others => '0');
    
    else
    
      line_num_reg <= line_num_reg;
      
    end if;
    
  end if;
  
  end process Line_cntr_PROC;

  
  ------------------------------------------------------------------
  --  Process Description:
  --    This process activates/deactivates the VSYNCx signal depending
  --    on the current line number relative to the VSYNC pulse width
  --    paramter.
  --  
  --  Inputs:
  --    RSTx
  --    CLK_LCD
  --  
  --  Outputs:
  --    VSYNCx
  --
  --  Notes:
  --    N/A
  ------------------------------------------------------------------
  VSYNCx_cntrl_PROC : process( RSTx, CLK_LCD )
  begin
  
    if( RSTx = '0' ) then
    
      VSYNCx <= '1';  --INACTIVE
      
    elsif( CLK_LCD'event and CLK_LCD = '1' ) then
    
      if( line_num_reg < C_VSYNC_TVP ) then
    
        VSYNCx <= '0'; --ACTIVE
        
      else
      
        VSYNCx <= '1'; --INACTIVE
        
      end if;
    
    end if;
  
  end process VSYNCx_cntrl_PROC;


END ARCHITECTURE vsyncx_control_arch;
