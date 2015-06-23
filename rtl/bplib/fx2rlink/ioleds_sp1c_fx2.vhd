-- $Id: ioleds_sp1c_fx2.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 2, or at your option any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
-- 
------------------------------------------------------------------------------
-- Module Name:    ioleds_sp1c_fx2 - syn
-- Description:    io activity leds for rlink+serport_1clk+fx2_ic combo
--
-- Dependencies:   genlib/led_pulse_stretch
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 13.1-14.7; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2013-04-21   509   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.genlib.all;
use work.rblib.all;
use work.rlinklib.all;
use work.serportlib.all;

entity ioleds_sp1c_fx2 is               -- io activity leds for rlink_sp1c_fx2
  port (
    CLK  : in slbit;                    -- clock
    CE_USEC : in slbit;                 -- 1 usec clock enable
    RESET  : in slbit;                  -- reset
    ENAFX2 : in slbit;                  -- enable fx2 usage
    RB_SRES : in rb_sres_type;          -- rbus: response
    RLB_MONI : in rlb_moni_type;        -- rlink 8b: monitor port
    SER_MONI : in serport_moni_type;    -- ser: monitor port
    IOLEDS : out slv4                   -- 4 bit IO monitor (e.g. for DSP_DP)
  );
end entity ioleds_sp1c_fx2;


architecture syn of ioleds_sp1c_fx2 is

  signal R_LEDDIV : slv6 := (others=>'0');   -- clock divider for LED pulses
  signal R_LEDCE : slbit := '0';             -- ce every 64 usec

  signal TXENA_LED : slbit := '0';
  signal RXVAL_LED : slbit := '0';

begin
  
  RXVAL_PSTR : led_pulse_stretch
    port map (
      CLK        => CLK,
      CE_INT     => R_LEDCE,
      RESET      => '0',
      DIN        => RLB_MONI.rxval,
      POUT       => RXVAL_LED
    );

  TXENA_PSTR : led_pulse_stretch
    port map (
      CLK        => CLK,
      CE_INT     => R_LEDCE,
      RESET      => '0',
      DIN        => RLB_MONI.txena,
      POUT       => TXENA_LED
    );

  proc_leddiv: process (CLK)
  begin

    if rising_edge(CLK) then
      R_LEDCE  <= '0';
      if CE_USEC = '1' then
        R_LEDDIV <= slv(unsigned(R_LEDDIV) - 1);
        if unsigned(R_LEDDIV) = 0 then
          R_LEDCE <= '1';
        end if;
      end if;
    end if;

  end process proc_leddiv;

  proc_ledmux : process (ENAFX2, SER_MONI, RLB_MONI, RB_SRES,
                         TXENA_LED, RXVAL_LED)
  begin

    if ENAFX2 = '0' then 
      IOLEDS(3) <= not SER_MONI.txok;
      IOLEDS(2) <= SER_MONI.txact;
      IOLEDS(1) <= not SER_MONI.rxok;
      IOLEDS(0) <= SER_MONI.rxact;
    else
      IOLEDS(3) <= RB_SRES.busy;
      IOLEDS(2) <= RLB_MONI.txbusy;
      IOLEDS(1) <= TXENA_LED;
      IOLEDS(0) <= RXVAL_LED;
    end if;      
    
  end process proc_ledmux;

end syn;
