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
-- $Id: lq057q3dc02_tb.vhd,v 1.2 2008-11-07 05:41:08 jwdonal Exp $
--
-- Description:
--   Test bench to verify lq057q3dc02 pcore.
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

ENTITY lq057q3dc02_tb IS
END ENTITY lq057q3dc02_tb;

ARCHITECTURE lq057q3dc02_tb_arch OF lq057q3dc02_tb IS 

  COMPONENT lq057q3dc02_top
    PORT(
      RSTx,
      CLK_100M_PAD : IN std_logic;
   
      CLK_LCD,
      HSYNCx,
      VSYNCx,
      ENAB,
      RL,
      UD,
      VQ      : OUT std_logic;
   
      R,
      G,
      B       : OUT std_logic_vector(6-1 downto 0)
    );
  END COMPONENT;

   --////////////////--
   -- INITIAL VALUES --
   --////////////////--
   signal
     RSTx,
     CLK_100M_PAD :  std_logic := '0';
   
   signal
     CLK_LCD,
     HSYNCx,
     VSYNCx,
     ENAB,
     RL,
     UD,
     VQ : std_logic := 'U';
   
   signal
     R,
     G,
     B :  std_logic_vector(6-1 downto 0) := (others => 'U');

   signal verifyDone : std_logic := '0';

BEGIN

  --/////////////////--
  -- UNIT UNDER TEST --
  --/////////////////--
  uut: lq057q3dc02_top
  port map (
  
     RSTx => RSTx,
     CLK_100M_PAD => CLK_100M_PAD,
     
     CLK_LCD => CLK_LCD,
     HSYNCx => HSYNCx,
     VSYNCx => VSYNCx,
     ENAB => ENAB,
     RL => RL,
     UD => UD,
     VQ => VQ,
     
     R => R,
     G => G,
     B => B

  );

  -- System clock generation - 100MHz (50% duty-cycle)
  CLK_100M_PAD_gen_PROC : process( CLK_100M_PAD )
  begin
  
    if( verifyDone = '0' ) then
  
      if( CLK_100M_PAD = '0' ) then
        CLK_100M_PAD <= '1' after 5 ns;
     
      elsif( CLK_100M_PAD = '1' ) then
        CLK_100M_PAD <= '0' after 5 ns;
       
      end if;
     
    end if;
    
  end process CLK_100M_PAD_gen_PROC;
  
  
  --////////////////////--
  -- BEGIN VERIFICATION --
  --////////////////////-- 
  lq057q3dc02_verify_PROC : process
  begin

    RSTx <= '0';

    wait for 1000 ns; --wait 100 clock cycles
    
    RSTx <= '1'; --release reset
    
    wait for 20 ms; --allow to run long enough to draw one full screen (320x240x160ns ~= 13ms + ~4ms overhead + a little extra)

    verifyDone <= '1'; --stops clock from running and prevents simulation from running indefinitely

    assert false report "====================================";
    assert false report "    lq057q3dc02 TEST COMPLETE!!!    ";
    assert false report "    ***This is NOT a failure.***    ";
    assert false report "====================================" severity failure;
    wait;

  end process lq057q3dc02_verify_PROC;

END ARCHITECTURE lq057q3dc02_tb_arch;
