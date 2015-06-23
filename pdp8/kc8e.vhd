--------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      KC8E Front Panel
--!
--! \details
--!      This package contatins the interface to the front panel
--!      switches and LEDs.
--!
--! \file
--!      kc8e.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2010, 2011 Rob Doyle
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
use work.kc8e_types.all;                        --! KC8E Types
use work.cpu_types.all;                         --! CPU Types

--
--! KC8E Front Panel Entity
--

entity eKC8E is port (
    sys     : in  sys_t;                        --! Clock/Reset
    cpu     : in  cpu_t;                        --! CPU Registers
    swROT   : in  swROT_t;                      --! Rotary Switch
    swDATA  : in  data_t;                       --! Switch Data
    ledRUN  : out std_logic;                    --! RUN LED
    ledADDR : out xaddr_t;                      --! Address LEDS
    ledDATA : out data_t;                       --! Data LEDS
    dev     : out dev_t                         --! Device Data
);
                
end eKC8E;

--
--! KC8E Front Panel RTL
--

architecture rtl of eKC8E is
                       
begin

    with swROT select
        ledDATA <= cpu.regs.PC     when dispPC,
                   cpu.regs.AC     when dispAC,
                   cpu.regs.IR     when dispIR,
                   cpu.regs.MA     when dispMA,
                   cpu.regs.MD     when dispMD,
                   cpu.regs.MQ     when dispMQ,
                   cpu.regs.ST     when dispST,
                   cpu.regs.SC     when dispSC,
                   (others => '0') when others;

    ledADDR <= cpu.regs.XMA & cpu.regs.MA;
    ledRUN  <= cpu.run;
    dev     <= nullDEV;

end rtl;
