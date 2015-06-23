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
-- $Id: image_gen_bram.vhd,v 1.2 2008-11-07 04:54:32 jwdonal Exp $
--
-- Description: This file controls the BRAM components for each color.
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
ENTITY image_gen_bram IS

  generic (
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

  port(
    RSTx,
    CLK_LCD : IN std_logic;

    LINE_NUM : IN std_logic_vector(C_LINE_NUM_WIDTH-1 downto 0);
    
    CLK_LCD_CYC_NUM : IN std_logic_vector(C_CLK_LCD_CYC_NUM_WIDTH-1 downto 0);

    R,
    G,
    B : OUT std_logic_vector(C_BIT_DEPTH/3-1 downto 0)
  );
  
END ENTITY image_gen_bram;

--////////////////////////--
-- ARCHITECTURE OF ENTITY --
--////////////////////////--
ARCHITECTURE image_gen_bram_arch OF image_gen_bram IS
   
   constant C_NUM_LCD_PIXELS : positive := 320;  -- number of drawable pixels per line in the LCD
   
   --Connecting signal wires between components
   signal SINIT_wire : std_logic := '0';
   signal ADDR_wire  : std_logic_vector(C_BRAM_ADDR_WIDTH-1 downto 0) := (others => '0');

begin

  --//////////////////////////--
  -- COMPONENT INSTANTIATIONS --
  --//////////////////////////--
  --You can't simply instantiate one XCO BRAM component 3 times because all
  --three components are initialized with 3 different COE files!
  image_RED_data : image_gen_bram_red
  port map (
    clka => CLK_LCD,
    addra => ADDR_wire,
    
    -- OUTPUTS --
    douta => R
  );
  
  image_GREEN_data : image_gen_bram_green
  port map (
    clka => CLK_LCD,
    addra => ADDR_wire,
    
    -- OUTPUTS --
    douta => G
  );
  
  image_BLUE_data : image_gen_bram_blue
  port map (
    clka => CLK_LCD,
    addra => ADDR_wire,
    
    -- OUTPUTS --
    douta => B
  );


  ------------------------------------------------------------------
  --  Process Description:
  --    This process controls the BRAM's SINIT signal which sets the
  --    DOUT pins of the BRAM to the value defined at the time of
  --    the Xilinx core customization.  The SINIT signal is enabled
  --    b/w every line and b/w every new frame.  This value is recommended
  --    to be zero to conserver power but it doesn't really matter what
  --    it is.  In this design it is not connected but feel free to connect
  --    it up yourself - everything should work exactly the same.
  --  
  --  Inputs:
  --    RSTx
  --    CLK_LCD
  --  
  --  Outputs:
  --    SINIT_wire
  --
  --  Notes:
  --    N/A
  ------------------------------------------------------------------
  image_gen_bram_sinit_cntrl_PROC : process( RSTx, CLK_LCD )
  begin
  
    if( RSTx = '0' ) then
    
      SINIT_wire <= '0';
      
    elsif( CLK_LCD'event and CLK_LCD = '1' ) then
    
      if( CLK_LCD_CYC_NUM >= (C_ENAB_THE - 2) -- start of image... Change from -1 to -2 to enable one clock earlier
          and
          CLK_LCD_CYC_NUM < (C_IMAGE_WIDTH - 1 + C_ENAB_THE - 1)
          and
          LINE_NUM < (C_IMAGE_HEIGHT + C_VSYNC_TVS + 1) ) then
          
        SINIT_wire <= '1'; --allow output to change based on ADDR
        
      else
      
        SINIT_wire <= '0';--reset output pins back to user-defined initial value (should be 0h to conserve power)
        
      end if;
    
    end if;
    
  end process image_gen_bram_sinit_cntrl_PROC;


  ------------------------------------------------------------------
  --  Process Description:
  --    This process controls the address value input to the BRAMs.
  --  
  --  Inputs:
  --    RSTx
  --    CLK_LCD
  --  
  --  Outputs:
  --    ADDR_wire
  --
  --  Notes:
  --    This process causes the Xilinx BRAM IP cores (instantiated
  --    above for each color) to generate warnings saying "Memory
  --    address is out of range" during simulation.  This is only
  --    because ADDR_wire is 76800 for a few clocks after it finishes
  --    drawing the last pixel on the screen.  The allowable range
  --    is only 0 - 76799, but driving 76800 doesn't cause any issues.
  --    I could fix it, but I'm too lazy.  :-)
  ------------------------------------------------------------------
  image_gen_bram_addr_cntrl_PROC : process( RSTx, CLK_LCD )
  begin
  
    if( RSTx = '0' ) then
    
      ADDR_wire <= (others => '0');
            
    elsif( CLK_LCD'event and CLK_LCD = '1' ) then
      
      --this condition signifies the start and end of each line
      if( CLK_LCD_CYC_NUM >= (C_ENAB_THE - 1)
          and
          CLK_LCD_CYC_NUM < (C_IMAGE_WIDTH + C_ENAB_THE - 1)
          and
          LINE_NUM < (C_IMAGE_HEIGHT + C_VSYNC_TVS + 1) ) then

        ADDR_wire <= ADDR_wire + 1;

      --reset address back to zero once a complete image has been drawn
      --(+ TVS timespec of course).  We only have to do this in case the
      --number of addressable image data bytes is less than
      --2^#BRAM_ADDR_bits (i.e. the number of addressable BRAM bytes).
      --This is almost always likely to be the case since the chances of
      --Xilinx automatically generating a BRAM block the _exact_ same size
      --as your image is highly unlikey.  This conditional statement will work
      --in either case.  :-)
      elsif( LINE_NUM >= (C_IMAGE_HEIGHT + C_VSYNC_TVS + 1) ) then

        ADDR_wire <= (others => '0');

      --if data should not be sent then just wait for the next line before
      --incrementing the address again
      else
      
        ADDR_wire <= ADDR_wire;
        
      end if; --end data OK TO SEND check
      
    end if; --end CLK'event and CLK = '1'
    
  end process image_gen_bram_addr_cntrl_PROC;


END ARCHITECTURE image_gen_bram_arch;
