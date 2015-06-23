--------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      PDP8 Bus Monitor
--!
--! \details
--!      This module watches for invalid bus cycles.
--!
--! \file
--!      busmon.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2010 Rob Doyle
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

-- synthesis translate_off

library ieee;                                                   --! IEEE Library
use ieee.std_logic_1164.all;                                    --! IEEE 1164
use ieee.numeric_std.all;                                       --! IEEE Numeric Standard
use work.cpu_types.all;                                         --! Types
use STD.TEXTIO.all;
  
--
--! PDP8 Bus Monitor Entity
--

entity eBUSMON is port (
    sys : in sys_t;                                             --! Clock/Reset
    cpu : in cpu_t                                              --! CPU State
);
end eBUSMON;

--
--! PDP8 Bus Monitor RTL
--

architecture rtl of eBUSMON is
    
    --
    -- Bus Monitor States
    --
    
    type busState_t is (
        busIdle,
        busReset,
        busInsRdPanelAddr,
        busInsRdPanelData,
        busInsWrPanelData,
        busInsRdMemoryAddr,
        busInsRdMemoryData,
        busInsWrMemoryData,
        busDatRdPanelAddr,
        busDatRdPanelData,
        busDatWrPanelData,
        busDatRdMemoryAddr,
        busDatRdMemoryData,
        busDatWrMemoryData,
        busDatRdIotAddr,
        busDatRdIotData,
        busDatWrIotData,
        busDatRdDMA,
        busDatWrDMA,
        what1,
        what2,
        busUnknown
    );
    
    signal busStateMux : busState_t;
    signal busStateReg : busState_t;
    signal vector      : std_logic_vector(0 to 8);
    
begin

    --
    -- Bus Monitor
    -- 

    vector <= cpu.buss.memsel & cpu.buss.ifetch & cpu.buss.dataf &
              cpu.buss.lxpar  & cpu.buss.lxmar  & cpu.buss.lxdar &
              cpu.buss.rd     & cpu.buss.wr     &
              cpu.buss.ioclr;

    with vector select
        busStateMux <= busIdle            when b"000_000_00_0",
                       busReset           when b"000_000_00_1",
                       busInsRdPanelAddr  when b"110_100_00_0",
                       busInsRdPanelData  when b"110_100_10_0",
                       busInsWrPanelData  when b"110_100_01_0",
                       busInsRdMemoryAddr when b"110_010_00_0",
                       busInsRdMemoryData when b"110_010_10_0",
                       busInsWrMemoryData when b"110_010_01_0",
                       busDatRdPanelAddr  when b"101_100_00_0",
                       busDatRdPanelData  when b"101_100_10_0",
                       busDatWrPanelData  when b"101_100_01_0",
                       busDatRdMemoryAddr when b"101_010_00_0",
                       busDatRdMemoryData when b"101_010_10_0",
                       busDatWrMemoryData when b"101_010_01_0",
                       busDatRdIotAddr    when b"001_001_00_0",
                       busDatRdIotData    when b"001_001_10_0",
                       busDatWrIotData    when b"001_001_01_0",
                       busDatRdDMA        when b"100_010_10_0",
                       busDatWrDMA        when b"100_010_01_0",
                       what1              when b"001_001_00_1",
                       what2              when b"100_010_00_0",
                       busUnknown         when others;

    --
    --! BUS_MON:
    --! This process implements a bus monitor.
    --
    
    BUS_MON : process(sys.clk)
        file     F : text is out "STD_OUTPUT";
        variable L : line;
    begin
        if rising_edge(sys.clk) then
            busStateReg <= busStateMux;
            if busStateMux = busUnknown then
                write(L, string'("Bus Monitor: Unknown Cycle.  Vector was "));
                --write(L, vector);
                --assert false report "Unknown bus cycle" severity failure;
            end if;
        end if;
    end process BUS_MON;
 
end rtl;

-- synthesis translate_on
