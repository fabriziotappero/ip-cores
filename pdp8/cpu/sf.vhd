------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Save Flag (SF) Memory Extension Register
--!
--! \details
--!      The Save Flags (SF) Register is a temporary register
--!      that is used for saving the Memory Extension Registers
--!      context during an interrupt.
--!
--!      When an interrupt occurs, the contents of the UF, IF,
--!      and DF registers are saved into the SF Register.
--!
--!      The contents of the SF register is saved into the
--!      AC register during the RIB instruction.
--!
--!      The RMF instruction restores the UB, IB, and DF
--!      from the SF register; i.e., it restores what the
--!      interrupt did.
--!
--!      When a JMP, JMS, RET1 or RET2 instruction is executed,
--!      the IF and UF registers are updated with contents of
--!      the IB and UB registers.
--!
--!      The SF Register is set to zero when the Front Panel
--!      CLEAR Switch is asserted.
--!
--! \file
--!      sf.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2009, 2010, 2011 Rob Doyle
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- version 2.1 of the License.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE. See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.gnu.org/licenses/lgpl.txt
--
--------------------------------------------------------------------
--
-- Comments are formatted for doxygen
--

library ieee;                                   --! IEEE Library
use ieee.std_logic_1164.all;                    --! IEEE 1164
use work.cpu_types.all;                         --! Types

--
--! CPU Save Flag (SF) Memory Extension Register Entity
--

entity eSF is port (
    sys  : in  sys_t;                           --! Clock/Reset
    sfOP : in  sfop_t;                          --! SF Operation
    DF   : in  field_t;                         --! DF Register
    IB   : in  field_t;                         --! IB Register
    UB   : in  std_logic;                       --! UF Register
    SF   : out sf_t                             --! SF Output
);
end eSF;

--
--! CPU Save Flag (SF) Memory Extension Register RTL
--

architecture rtl of eSF is

    signal sfREG : sf_t;                        --! Save Flag
    signal sfMUX : sf_t;                        --! Save Flag Multiplexer
    
begin
  
    --
    -- SF Multiplexer
    --
  
    with sfOP select
        sfMUX <= sfREG        when sfopNOP,
                 UB & IB & DF when sfopUBIBDF;
  
    --
    --! SF Register
    --
  
    REG_SF : process(sys)
    begin
        if sys.rst = '1' then
            sfREG <= (others => '0');
        elsif rising_edge(sys.clk) then
            sfREG <= sfMUX;
        end if;
    end process REG_SF;

    SF <= sfREG;
    
end rtl;
