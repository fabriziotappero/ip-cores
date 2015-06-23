-- $Id: ib_intmap.vhd 641 2015-02-01 22:12:15Z mueller $
--
-- Copyright 2006-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    ib_intmap - syn
-- Description:    pdp11: external interrupt mapper
--
-- Dependencies:   -
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-18   427   1.2.2  now numeric_std clean
-- 2008-08-22   161   1.2.1  renamed pdp11_ -> ib_; use iblib
-- 2008-01-20   112   1.2    add INTMAP generic to externalize config
-- 2008-01-06   111   1.1    add EI_ACK output lines, remove EI_LINE
-- 2007-10-12    88   1.0.2  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-06-14    56   1.0.1  Use slvtypes.all
-- 2007-05-12    26   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.iblib.all;

-- ----------------------------------------------------------------------------

entity ib_intmap is                     -- external interrupt mapper
  generic (
    INTMAP : intmap_array_type := intmap_array_init);                       
  port (
    EI_REQ : in slv16_1;                -- interrupt request lines
    EI_ACKM : in slbit;                 -- interrupt acknowledge (from master)
    EI_ACK : out slv16_1;               -- interrupt acknowledge (to requestor)
    EI_PRI : out slv3;                  -- interrupt priority
    EI_VECT : out slv9_2                -- interrupt vector
  );
end ib_intmap;

architecture syn of ib_intmap is

  signal EI_LINE : slv4 := (others=>'0');    -- external interrupt line

  type intp_type is array (15 downto 0) of slv3;
  type intv_type is array (15 downto 0) of slv9;

  constant conf_intp : intp_type :=
    (slv(to_unsigned(INTMAP(15).pri,3)),  -- line 15
     slv(to_unsigned(INTMAP(14).pri,3)),  -- line 14
     slv(to_unsigned(INTMAP(13).pri,3)),  -- line 13
     slv(to_unsigned(INTMAP(12).pri,3)),  -- line 12
     slv(to_unsigned(INTMAP(11).pri,3)),  -- line 11
     slv(to_unsigned(INTMAP(10).pri,3)),  -- line 10
     slv(to_unsigned(INTMAP( 9).pri,3)),  -- line  9
     slv(to_unsigned(INTMAP( 8).pri,3)),  -- line  8
     slv(to_unsigned(INTMAP( 7).pri,3)),  -- line  7
     slv(to_unsigned(INTMAP( 6).pri,3)),  -- line  6
     slv(to_unsigned(INTMAP( 5).pri,3)),  -- line  5
     slv(to_unsigned(INTMAP( 4).pri,3)),  -- line  4
     slv(to_unsigned(INTMAP( 3).pri,3)),  -- line  3
     slv(to_unsigned(INTMAP( 2).pri,3)),  -- line  2
     slv(to_unsigned(INTMAP( 1).pri,3)),  -- line  1     
     slv(to_unsigned(             0,3))   -- line  0 (always 0 !!)
     ); 

  constant conf_intv : intv_type :=
    (slv(to_unsigned(INTMAP(15).vec,9)),  -- line 15
     slv(to_unsigned(INTMAP(14).vec,9)),  -- line 14
     slv(to_unsigned(INTMAP(13).vec,9)),  -- line 13
     slv(to_unsigned(INTMAP(12).vec,9)),  -- line 12
     slv(to_unsigned(INTMAP(11).vec,9)),  -- line 11
     slv(to_unsigned(INTMAP(10).vec,9)),  -- line 10
     slv(to_unsigned(INTMAP( 9).vec,9)),  -- line  9
     slv(to_unsigned(INTMAP( 8).vec,9)),  -- line  8
     slv(to_unsigned(INTMAP( 7).vec,9)),  -- line  7
     slv(to_unsigned(INTMAP( 6).vec,9)),  -- line  6
     slv(to_unsigned(INTMAP( 5).vec,9)),  -- line  5
     slv(to_unsigned(INTMAP( 4).vec,9)),  -- line  4
     slv(to_unsigned(INTMAP( 3).vec,9)),  -- line  3
     slv(to_unsigned(INTMAP( 2).vec,9)),  -- line  2
     slv(to_unsigned(INTMAP( 1).vec,9)),  -- line  1     
     slv(to_unsigned(             0,9))   -- line  0 (always 0 !!)
     ); 

--  attribute PRIORITY_EXTRACT : string;
--  attribute PRIORITY_EXTRACT of EI_LINE : signal is "force";
  
begin

  EI_LINE <= "1111" when EI_REQ(15)='1' else
             "1110" when EI_REQ(14)='1' else
             "1101" when EI_REQ(13)='1' else
             "1100" when EI_REQ(12)='1' else
             "1011" when EI_REQ(11)='1' else
             "1010" when EI_REQ(10)='1' else
             "1001" when EI_REQ( 9)='1' else
             "1000" when EI_REQ( 8)='1' else
             "0111" when EI_REQ( 7)='1' else
             "0110" when EI_REQ( 6)='1' else
             "0101" when EI_REQ( 5)='1' else
             "0100" when EI_REQ( 4)='1' else
             "0011" when EI_REQ( 3)='1' else
             "0010" when EI_REQ( 2)='1' else
             "0001" when EI_REQ( 1)='1' else
             "0000";

  proc_intmap : process (EI_LINE, EI_ACKM)
    variable iline : integer := 0;
    variable iei_ack : slv16 := (others=>'0');
  begin

    iline := to_integer(unsigned(EI_LINE));

    iei_ack := (others=>'0');
    if EI_ACKM = '1' then
      iei_ack(iline) := '1';
    end if;

    EI_ACK  <= iei_ack(EI_ACK'range);
    EI_PRI  <= conf_intp(iline);
    EI_VECT <= conf_intv(iline)(8 downto 2);  
    
  end process proc_intmap;
  
end syn;
