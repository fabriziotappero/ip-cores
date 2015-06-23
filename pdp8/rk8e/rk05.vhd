--------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      RK05 Disk Simulation
--!
--! \file
--!      rk05.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--! \details
--!
--!      An RK05 has the following parameters:
--!
--!      -#    2 heads per disk
--!      -#  203 cylinders (or tracks) per head.
--!      -#   16 sectors per cylinder (or track).
--!      -#  256 words per sector.
--!
--!      Assuming the 12-bit word is stored in two bytes, an
--!      RK05 image requires 3,325,952 bytes of storage.
--!
--!      It is a matter of good fortune that the RK05 has 256
--!      word sectors and a standard Secure Digital chip has
--!      512 byte sectors.  As before, the mapping between the
--!      12 bit data and the two bytes of the Secure Digital
--!      chip is borrowed from SIMH.
--!
--!      The SD drive requires a 32-bit address that selects 512-
--!      byte sectors.  512 byte sectors work nicely because a 512-
--!      byte sector maps nicely to a 256 word (12-bit) sector by
--!      ignoring the 4- MSB bits out of every 16-bits.
--!
--!      The mapping between DISK, HEAD, CYL, and SECTOR and Secure
--!      Digital (SD) Sectors is as follows:
--!
--! \verbatim
--!
--!             +-----+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
--!        SD:  |31-15|14|13|12|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
--!             +-----+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
--!       RK8E: |  0  |D0|D1|C0|C1|C2|C3|C4|C5|C6|C7|H0|S0|S1|S2|S3|
--!             +-----+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
--!
--!       where:
--!          D(0:1) : RK8E Disk Select
--!          C(0:7) : RK8E Cylinder Select
--!          H(0:0) : RK8E Head Select
--!          S(0:3) : RK8E Sector Select
--!
--! \endverbatim
--!
--!      Therefore the total system capacity is 6651904 words.  This
--!      occupies 8388608 words (16 MB) of disk space because we
--!      round up the 203 cylinders to 256 and convert to bytes.
--!
--!      The Secure Digital card can read or write a sector in about
--!      400 microseconds.  Obviously this is way faster than a real
--!      RK05 Disk Drive operated.
--!
--!      In order to simulate the actual timing, four RK05 "Disk
--!      Simulators" are implemented in this code.   The purpose of
--!      Disk Simulators is to simulate the head seek timing and to
--!      simulate the rotational latency of a real disk.  Note: the
--!      Disk Simulators don't actually read or write data - their
--!      purpose is strictly to simulate timing.
--!
--!      When the RK05 simulator finishes, the Secure Digital
--!      Interface device reads or writes the data to the physical
--!      media.
--!
--!      This device simulates the timing of an RK05.
--!
--!      The following table is used for determining seek timing:
--!
--! \verbatim
--!      +-----+----------+
--!      |   0 |    0 ms  |
--!      +-----+----------+
--!      |   1 |   10 ms  |
--!      +-----+----------+
--!      |   2 |   20 ms  |
--!      +-----+----------+
--!      |   4 |   30 ms  |
--!      +-----+----------+
--!      |   7 |   40 ms  |
--!      +-----+----------+
--!      |  15 |   50 ms  |
--!      +-----+----------+
--!      |  30 |   60 ms  |
--!      +-----+----------+
--!      |  55 |   70 ms  |
--!      +-----+----------+
--!      |  99 |   80 ms  |
--!      +-----+----------+
--!      | 205 |   90 ms  |
--!      +-----+----------+
--! \endverbatim
--!
--! \note
--!      The sector mapping described above has matches SIMH.
--!      Therefore SIMH disk images may be used for this
--!      application without reformatting.
--!
--! \note
--!      This doesn't simulate the read/write actions of the RK05.
--!      It merely simulates the latency on the RK05.
--!      When the RK8E receives a command to do something, it
--!      determines which RK05 the command is intended.  The RK8E
--!      passes the command to the RK05 where the disk latencies
--!      are simulated.  When the latencies have expired, the RK05
--!      passes the command to the single Secure Disk device where
--!      the actual read/write operation occurs.
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

library ieee;                                           --! IEEE Library
use ieee.std_logic_1164.all;                            --! IEEE 1164
use ieee.numeric_std.all;                               --! IEEE Numeric Standard
use work.cpu_types.all;                                 --! CPU types
use work.rk05_types.all;                                --! RK05 types
use work.sd_types.all;                                  --! SD Types

--
--! RK05 Disk Simulation Entity
--

entity eRK05 is port (
    sys         : in  sys_t;                            --! Clock/Reset
    ioclr       : in  std_logic;                        --! IOCLR
    simtime     : in  std_logic;                        --! Simulate RK05 Timing
    sdWP        : in  std_logic;                        --! WP from SD Card (Asserted when WP)
    sdCD        : in  std_logic;                        --! CD from SD Card (Asserted when No Card)
    sdFAIL      : in  std_logic;                        --! SD Failure
    rk05INH     : in  rk05WRINH_t;                      --! Write Inhibited
    rk05MNT     : in  rk05MNT_t;                        --! Drive is Mounted
    rk05OP      : in  rk05OP_t;                         --! RK05 OP
    rk05CYL     : in  rk05CYL_t;                        --! RK05 Cylinder
    rk05HEAD    : in  rk05HEAD_t;                       --! RK05 Head
    rk05SECT    : in  rk05SECT_t;                       --! RK05 Sector
    rk05DRIVE   : in  rk05DRIVE_t;                      --! RK05 Drive
    rk05LEN     : in  rk05LEN_t;                        --! RK05 Read/Write Length
    rk05MEMaddr : in  addr_t;                           --! RK05 Memory Address
    rk05STAT    : out rk05STAT_t                        --! RK05 Status
);
end eRK05;

--
--! RK05 Disk Simulation RTL
--

architecture rtl of eRK05 is

    type     state_t    is (stateIDLE,
                            stateSeekONLY,
                            stateSeekRDWR,
                            stateWaitRDWR,
                            stateDONE);                 --! State type definition
    signal   state      : state_t;                      --! State
    signal   active     : std_logic;                    --! Activity (timed oneshot)
    signal   rk05WRLOCK : rk05WRINH_t;                  --! write locked
    signal   rk05state  : rk05STATE_t;                  --! Returned State
    signal   rk05RECAL  : std_logic;                    --! Recalibrate
    signal   curCYL     : rk05CYL_t;                    --! Current Cylinder
    signal   diskADDR   : sdDISKaddr_t;                 --! Disk Address
    signal   delayCount : integer range 0 to 45000000;  --! time delay counter
    signal   sdOP       : sdOP_t;                       --! SD OP
    signal   sdLEN      : sdLEN_t;                      --! SD Read/Write Length
    signal   sdMEMaddr  : addr_t;                       --! SD Memory Address
    signal   sdDISKaddr : sdDISKaddr_t;                 --! SD Disk Address
    constant tenMS      : integer := 500000;            --! 10 milliseconds
    constant shortDelay : integer := 50;                --!  1 microseconds
    constant sdADDRpad  : std_logic_vector(0 to 16) := (others => '0');
    constant rk05CYL0   : rk05CYL_t := (others => '0');

    --!
    --! This function returns the number of 50 MHz clock cycles to delay
    --! for the seek delay simulation.
    --!

    function seekDelay(newCYL : rk05CYL_t; oldCYL : rk05CYL_t) return integer is
        variable diffCYL : integer range 0 to 255;
    begin

        if newCYL > oldCYL then
            diffCYL := to_integer(unsigned(newCYL) - unsigned(oldCYL));
        else
            diffCYL := to_integer(unsigned(oldCYL) - unsigned(newCYL));
        end if;

        if diffCYL < 1 then
            return 0;                   -- 0 ms
        elsif diffCYL < 2 then
            return tenMS * 1;           -- 10 ms
        elsif diffCYL < 3 then
            return tenMS * 2;           -- 20 ms
        elsif diffCYL < 5 then
            return tenMS * 3;           -- 30 ms
        elsif diffCYL < 8 then
            return tenMS * 4;           -- 40 ms
        elsif diffCYL < 16 then
            return tenMS * 5;           -- 50 ms
        elsif diffCYL < 31 then
            return tenMS * 6;           -- 60 ms
        elsif diffCYL < 56 then
            return tenMS * 7;           -- 70 ms
        elsif diffCYL < 100 then
            return tenMS * 8;           -- 80 ms
        else
            return tenMS * 9;           -- 90 ms
        end if;

    end seekDelay;

begin

    --
    -- Disk Address
    --

    diskADDR <= sdADDRpad & rk05DRIVE & rk05CYL & rk05HEAD & rk05SECT;

    --
    --! State machine
    --

    RK05_SIM : process(sys, ioclr)
    begin

        if sys.rst = '1' or ioclr = '1' then

            delayCount      <= 0;
            rk05WRLOCK <= '0';
            rk05RECAL  <= '0';
            state      <= stateIdle;
            sdOP       <= sdopNOP;
            sdLEN      <= '0';
            curCYL     <= (others => '0');
            sdMEMaddr  <= (others => '0');
            sdDISKaddr <= (others => '0');

        elsif rising_edge(sys.clk) then

            if ioclr = '1' then

                delayCount      <= 0;
                rk05WRLOCK <= '0';
                rk05RECAL  <= '0';
                state      <= stateIdle;
                sdOP       <= sdopNOP;
                sdLEN      <= '0';
                curCYL     <= (others => '0');
                sdMEMaddr  <= (others => '0');
                sdDISKaddr <= (others => '0');

            else

                if rk05OP = rk05opCLR then
                    rk05WRLOCK <= '0';
                    sdOP       <= sdopABORT;
                    state      <= stateDONE;

                else

                    case state is

                        --
                        -- Nothing happening
                        --

                        when stateIDLE =>
                            case rk05OP is

                                --
                                -- IDLE:
                                -- Nothing to do
                                --

                                when rk05opNOP =>
                                    null;

                                --
                                -- Reset:
                                -- Handled above
                                --

                                when rk05opCLR =>
                                    null;

                                --
                                -- Wrprot:
                                -- Write protect the drive
                                --

                                when rk05opWRPROT =>
                                    rk05WRLOCK <= '1';
                                --
                                -- Recalibrate:
                                -- Seek to cylinder 0
                                --

                                when rk05opRECAL =>
                                    sdOP       <= sdopNOP;
                                    sdLEN      <= rk05LEN;
                                    sdMEMaddr  <= rk05MEMaddr;
                                    sdDISKaddr <= diskADDR;
                                    rk05RECAL  <= '1';
                                    curCYL     <= rk05CYL0;
                                    if simtime = '1' then
                                        delayCount <= seekDelay(curCYL, rk05CYL0);
                                    else
                                        delayCount <= shortDelay;
                                    end if;
                                    state <= stateSeekONLY;

                                --
                                -- Seek Operation
                                -- Seek to new cyclinder
                                --

                                when rk05opSEEK =>
                                    sdOP       <= sdopNOP;
                                    sdLEN      <= rk05LEN;
                                    sdMEMaddr  <= rk05MEMaddr;
                                    sdDISKaddr <= diskADDR;
                                    curCYL     <= rk05CYL;
                                    if simtime = '1' then
                                        delayCount <= seekDelay(curCYL, rk05CYL);
                                    else
                                        delayCount <= shortDelay;
                                    end if;
                                    state <= stateSeekONLY;

                                --
                                -- Read Operation
                                --

                                when rk05opREAD =>
                                    sdOP       <= sdopRD;
                                    sdLEN      <= rk05LEN;
                                    sdMEMaddr  <= rk05MEMaddr;
                                    sdDISKaddr <= diskADDR;
                                    curCyl     <= rk05CYL;
                                    if simtime = '1' then
                                        delayCount <= seekDelay(curCYL, rk05CYL);
                                    else
                                        delayCount <= shortDelay;
                                    end if;
                                    state <= stateSeekRDWR;

                                --
                                -- Write Operation
                                --

                                when rk05opWRITE =>
                                    sdOP       <= sdopWR;
                                    sdLEN      <= rk05LEN;
                                    sdMEMaddr  <= rk05MEMaddr;
                                    sdDISKaddr <= diskADDR;
                                    curCyl     <= rk05CYL;
                                    if simtime = '1' then
                                        delayCount <= seekDelay(curCYL, rk05CYL);
                                    else
                                        delayCount <= shortDelay;
                                    end if;
                                    state <= stateSeekRDWR;

                                --
                                -- Anything else?
                                --

                                when others =>
                                    null;

                            end case;

                        --
                        -- stateSeekONLY:
                        --  Simulate Seek Timing on Seeks
                        --

                        when stateSeekONLY =>
                            if delayCount = 0 then
                                state <= stateDONE;
                            else
                                delayCount <= delayCount - 1;
                            end if;

                        --
                        -- stateSeekRDWR:
                        --  Simulate Seek Timing on Read/Writes
                        --

                        when stateSeekRDWR =>
                            if delayCount = 0 then
                                if simtime = '1' then
                                    delayCount <= tenMS;
                                else
                                    delayCount <= shortDelay;
                                end if;
                                state <= stateWaitRDWR;
                            else
                                delayCount <= delayCount - 1;
                            end if;

                        --
                        -- stateWaitRDWR:
                        --  Simuate rotational latency on Read/Writes
                        --

                        when stateWaitRDWR =>
                            if delayCount = 0 then
                                state <= stateDone;
                            else
                                delayCount <= delayCount - 1;
                            end if;

                        --
                        -- stateDone:
                        --

                        when stateDONE =>
                            rk05RECAL <= '0';
                            state     <= stateIDLE;

                        --
                        -- Anything else?
                        --

                        when others =>
                            null;

                    end case;
                end if;
            end if;
        end if;
    end process RK05_SIM;

    --
    --! Activity Timer for LED
    --

    ACTIVITY : process(sys)
        variable timer   : integer range 0 to 4999999;  --! Timer
        constant maxTIME : integer := 4999999;          --! Time delay
    begin
        if sys.rst = '1' then
            timer  := 0;
            active <= '0';
        elsif rising_edge(sys.clk) then
            if ((rk05OP =  rk05opRECAL) or
                (rk05OP =  rk05opSEEK ) or
                (rk05OP =  rk05opREAD ) or
                (rk05OP =  rk05opWRITE)) then
                timer  := maxTIME;
                active <= '1';
            elsif timer = 0 then
                active <= '0';
            else
                timer := timer - 1;
            end if;
        end if;
    end process ACTIVITY;

    --
    -- Combinational logic
    --

    with state select
        rk05state <= rk05stIDLE when stateIDLE,
                     rk05stDONE when stateDONE,
                     rk05stBUSY when others;

    rk05STAT.active     <= active;
    rk05STAT.state      <= rk05state;
    rk05STAT.mounted    <= rk05MNT and not(sdFAIL) and not(sdCD);
    rk05STAT.WRINH      <= rk05INH or rk05WRLOCK or sdWP;
    rk05STAT.recal      <= rk05RECAL;
    rk05STAT.sdOP       <= sdOP;
    rk05STAT.sdLEN      <= sdLEN;
    rk05STAT.sdMEMaddr  <= sdMEMaddr;
    rk05STAT.sdDISKaddr <= sdDISKaddr;

end rtl;
