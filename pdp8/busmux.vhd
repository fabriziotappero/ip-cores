--------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      PDP8 Bus Multiplexer
--!
--! \details
--!      This package contains the multiplexer that simulates a
--!      bi-directional bus.
--!
--!      External IOTs are different that other bus cycles.  If
--!      an external IOT is not implemented, it behaves like a
--!      no-op.  In order to keep the system from 'hanging' on
--!      a unimplemented IOT, this device start an ACK  Timer
--!      when an external IOT is detected.  If no external device
--!      acknowledges the IOT cycle, the ACK Timer will handle it
--!      when it times out.  The ACK Timer should be set for
--!      longer than the most amount of wait-states for a normal
--!      bus cycle.
--!
--! \todo
--!      DMA Request and DMA Grant logic is incorrect.  This code
--!      assumes the only DMA source is the disk.   The DMA should
--!      be aribrated like everything else.
--!
--! \file
--!      busmux.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2009, 2010, 2011, 2012 Rob Doyle
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
use work.cpu_types.all;                         --! CPU Types

--
--! PDP8 Bus Multiplexer Entity
--

entity eBUSMUX is port (
    sys      : in  sys_t;                       --! Clock / Reset
    cpu      : in  cpu_t;                       --! CPU Registers
    ramDEV   : in  dev_t;                       --! RAM Device
    diskDEV  : in  dev_t;                       --! DISK Disk Device
    tty1DEV  : in  dev_t;                       --! TTY1 Device
    tty2DEV  : in  dev_t;                       --! TTY2 Device
    lprDEV   : in  dev_t;                       --! LPR Device
    ptrDEV   : in  dev_t;                       --! PTR Device
    rtcDEV   : in  dev_t;                       --! Real Time Clock
    xramDEV  : in  dev_t;                       --! External RAM Device
    romDEV   : in  dev_t;                       --! ROM Device
    panelDEV : in  dev_t;                       --! Front Panel Device
    postDEV  : in  dev_t;                       --! POST Device
    mmapDEV  : in  dev_t;                       --! Memory Map Device
    cpuDEV   : out dev_t                        --! CPU Device
);
end eBUSMUX;

--
--!  PDP8 Bus Multiplexer RTL
--

architecture rtl of eBUSMUX is

    type   ackSTATE_t is (idle, run, done);
    signal ackSTATE   : ackSTATE_t;
    signal ackSTART   : std_logic;
    signal ackIOT     : std_logic;
    signal ackTIMER   : integer range 0 to 10;
    signal ackDEV     : std_logic;
    signal muxDEV     : dev_t;
    
begin
    
    --
    --! ACK Timer:
    --! This process will eventually generate a Bus Ack for an
    --! unimplemented internal IOT.
    --

    ACK_TIMER : process(sys)
    begin
        if sys.rst = '1' then
            ackTIMER <= 0;
            ackSTATE <= idle;
        elsif rising_edge(sys.clk) then
            case ackSTATE is
                when idle =>
                    if ackSTART = '1' then
                        ackTIMER <= ackTIMER + 1;
                        ackSTATE <= run;
                    else
                        ackTIMER <= 0;
                    end if;
                when run =>
                    if ackDEV = '1' then
                        ackState <= idle;
                    else
                        if ackTIMER = 10 then
                            ackTIMER <= 0;
                            ackSTATE <= done;
                        else
                            ackTIMER <= ackTIMER + 1;
                        end if;
                    end if;
                when done =>
                    ackSTATE <= idle;
                when others =>
                    null;
            end case;
        end if;
    end process ACK_TIMER;

    --
    -- ackIOT during last state of state machine
    --
    
    ackIOT       <= '1' when ackSTATE = done else
                    '0';
    
    --
    -- This is the bus multiplexer.  It simulates a bi-directional bus.
    --
  
    muxDEV       <= ramDEV   when ramDEV.ack   = '1' else
                    diskDEV  when diskDEV.ack  = '1' else
                    tty1DEV  when tty1DEV.ack  = '1' else
                    tty2DEV  when tty2DEV.ack  = '1' else
                    lprDEV   when lprDEV.ack   = '1' else
                    ptrDEV   when ptrDEV.ack   = '1' else
                    rtcDEV   when rtcDEV.ack   = '1' else
                    xramDEV  when xramDEV.ack  = '1' else
                    romDEV   when romDEV.ack   = '1' else
                    panelDEV when panelDEV.ack = '1' else
                    postDEV  when postDEV.ack  = '1' else
                    mmapDEV  when mmapDEV.ack  = '1' else
                    nullDEV;

    --
    --! Detect External IOTs for ACK timer.
    --
    
    ackSTART     <= '1' when ((cpu.buss.lxdar = '1' and cpu.buss.wr = '1' and muxDEV.ack = '0') or
                              (cpu.buss.lxdar = '1' and cpu.buss.rd = '1' and muxDEV.ack = '0')) else
                    '0';

    --
    -- ACK is combinational.  This is the fastest way to
    -- generate an ACK signal.
    --
    
    ackDEV       <= ramDEV.ack  or diskDEV.ack or tty1DEV.ack or tty2DEV.ack or lprDEV.ack   or
                    ptrDEV.ack  or rtcDEV.ack  or xramDEV.ack or romDEV.ack  or panelDEV.ack or
                    postDEV.ack or mmapDEV.ack;
    
    --
    -- Muxed signals.
    --

    cpuDEV.ack   <= ackDEV or ackIOT;
    cpuDEV.devc  <= muxDEV.devc;
    cpuDEV.skip  <= muxDEV.skip;

    --
    -- INTR  comes from most IO Devices
    -- CPREQ comes from Panel only
    --
    
    cpuDEV.intr  <= diskDEV.intr or tty1DEV.intr or tty2DEV.intr or lprDEV.intr or ptrDEV.intr or rtcDEV.intr;
    cpuDEV.cpreq <= panelDEV.intr;

    --
    -- FIXME: This isn't right.  It should arbirtrate, but right
    -- now disk is the only DMA.
    --
    
    cpuDEV.dma   <= diskDEV.dma;
    cpuDEV.data  <= diskDEV.data when cpu.buss.dmagnt = '1' and diskDEV.dma.wr = '1' else
                    muxDEV.data;
    
end rtl;
