-- $Id: pdp11_irq.vhd 677 2015-05-09 21:52:32Z mueller $
--
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    pdp11_irq - syn
-- Description:    pdp11: interrupt requester
--
-- Dependencies:   ib_sel
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-18   427   1.2.2  now numeric_std clean
-- 2010-10-23   335   1.2.1  use ib_sel
-- 2010-10-17   333   1.2    use ibus V2 interface
-- 2008-08-22   161   1.1.4  use iblib
-- 2008-04-25   138   1.1.3  use BRESET to clear pirq
-- 2008-01-06   111   1.1.2  rename signal EI_ACK->EI_ACKM (master ack)
-- 2008-01-05   110   1.1.1  rename IB_MREQ(ena->req) SRES(sel->ack, hold->busy)
-- 2007-12-30   107   1.1    use IB_MREQ/IB_SRES interface now
-- 2007-10-12    88   1.0.2  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-06-14    56   1.0.1  Use slvtypes.all
-- 2007-05-12    26   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.iblib.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_irq is                     -- interrupt requester
  port (
    CLK : in slbit;                     -- clock
    BRESET : in slbit;                  -- bus reset
    INT_ACK : in slbit;                 -- interrupt acknowledge from CPU
    EI_PRI : in slv3;                   -- external interrupt priority
    EI_VECT : in slv9_2;                -- external interrupt vector
    EI_ACKM : out slbit;                -- external interrupt acknowledge
    PRI : out slv3;                     -- interrupt priority
    VECT : out slv9_2;                  -- interrupt vector
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response
  );
end pdp11_irq;

architecture syn of pdp11_irq is
  
  constant ibaddr_pirq : slv16 := slv(to_unsigned(8#177772#,16));

  subtype  pirq_ubf_pir    is integer range 15 downto 9;
  subtype  pirq_ubf_pia_h  is integer range  7 downto 5;
  subtype  pirq_ubf_pia_l  is integer range  3 downto 1;

  signal IBSEL_PIRQ : slbit := '0';
  signal R_PIRQ : slv8_1 := (others => '0');  -- pirq register
  signal PI_PRI : slv3 := (others => '0');   -- prog.int. priority

--  attribute PRIORITY_EXTRACT : string;
--  attribute PRIORITY_EXTRACT of PI_PRI : signal is "force";
  
begin

  SEL : ib_sel
    generic map (
      IB_ADDR => ibaddr_pirq)
    port map (
      CLK     => CLK,
      IB_MREQ => IB_MREQ,
      SEL     => IBSEL_PIRQ
    );

  proc_ibres : process (IBSEL_PIRQ, IB_MREQ, R_PIRQ, PI_PRI)
    variable idout : slv16 := (others=>'0');
  begin
    idout := (others=>'0');
    if IBSEL_PIRQ = '1' then
      idout(pirq_ubf_pir)   := R_PIRQ;
      idout(pirq_ubf_pia_h) := PI_PRI;
      idout(pirq_ubf_pia_l) := PI_PRI;
    end if;
    IB_SRES.dout <= idout;
    IB_SRES.ack  <= IBSEL_PIRQ and (IB_MREQ.re or IB_MREQ.we); -- ack all
    IB_SRES.busy <= '0';
  end process proc_ibres;
 
  proc_pirq : process (CLK)
  begin
    if rising_edge(CLK) then
      if BRESET = '1' then
        R_PIRQ <= (others => '0');
      elsif IBSEL_PIRQ='1' and IB_MREQ.we='1'and IB_MREQ.be1='1'  then
        R_PIRQ <= IB_MREQ.din(pirq_ubf_pir);
      end if;     
    end if;
  end process proc_pirq;
    
  PI_PRI <= "111" when R_PIRQ(7)='1' else
            "110" when R_PIRQ(6)='1' else
            "101" when R_PIRQ(5)='1' else
            "100" when R_PIRQ(4)='1' else
            "011" when R_PIRQ(3)='1' else
            "010" when R_PIRQ(2)='1' else
            "001" when R_PIRQ(1)='1' else
            "000";

  proc_irq : process (PI_PRI, EI_PRI, EI_VECT, INT_ACK)
    constant vect_default : slv9 := slv(to_unsigned(8#240#,9));
  begin

    EI_ACKM <= '0';
    
    if unsigned(EI_PRI) > unsigned(PI_PRI) then
      PRI  <= EI_PRI;
      VECT <= EI_VECT;
      EI_ACKM <= INT_ACK;
    else
      PRI  <= PI_PRI;
      VECT <= vect_default(8 downto 2);
    end if;
    
  end process proc_irq;
  
end syn;
