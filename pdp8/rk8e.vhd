--------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      RK8E Disk Controller
--!
--! \file
--!      rk8e.vhd
--!
--! \details
--!      The RK8E Disk Controller is designed to be register
--!      compatible with real RK8E controller.  Instead of
--!      interfacing to 4 RK05 disk drives, this controller
--!      interfaces to a single Secure Digital memory chip
--!      which contains the storage equivalent of 4 RK05
--!      disk drives.
--!
--!      In this case, the term 'compatible' is a matter of
--!      opinion.  The Secure Digital chip does not have the
--!      delays associated with the rotational latency of a
--!      disk drive and does not have delays associated with
--!      head motion.  The Secure Digital chip also transfers
--!      data (read and write) faster than a RK05 disk.
--!
--!      The disk drive can be configured to emulated these
--!      latencies.  It is not well tested and fortunately it
--!      appears that most applications do not require this
--!      level of timing fidelity.  Alternately small delays
--!      can be used which seem to work.
--!
--!      The Cylinder, Head, and Sector (CHS) addressing of
--!      the Secure Digital chip  has been borrowed from the
--!      SIMH simulator.  This allows SIMH RK05 disk images
--!      which are readily available on the internet to be
--!      used without modification.
--!
--!      The details of this mapping is described in the RK05
--!      device where the RK05 CHS addressing is manipulated to
--!      form the 32-bit linear sector address used by the
--!      Secure Digial Chip.
--!
--!      Since an RK05 image is somewhat less than 4 MB, the four
--!      RK05 images are aligned on 4 MB addresses.  Therefore
--!      a 16 MB Secure Digital chip is suffient storage for four
--!      RK05 disk drives.  I used a 4 GB Secure Digital chip
--!      because it was the smallest I could find.
--!
--!      The Secure Digital disk image for four RK05 disks is
--!      built as follows:
--!
--! \code
--! dd if=advent.rk05            of=/dev/sdc seek=0     count=6496
--! dd if=diagpack2.rk05         of=/dev/sdc seek=8192  count=6496
--! dd if=diag-games-kermit.rk05 of=/dev/sdc seek=16384 count=6496
--! dd if=multos8.rk05           of=/dev/sdc seek=24576 count=6496
--! \endcode
--!
--!      Your choice of disk images may vary.
--!
--!      The VHDL Code below is organized as follows:
--!      -# Bus Interface
--!      -# RK8E Registers
--!      -# 4x RK05 Timing Simulators
--!      -# Secure Digital Interface.
--!
--!      The Bus Interface operates asynchronously as requried for
--!      the the bus operation.   The Bus Interface decodes the
--!      various IOTs and creates "rk8eOPs" that are passed to the
--!      "RK8E Registers" process for action.
--!
--!      The "RK8E Registers" process maintains the controller state.
--!      When a disk command is received, it dispatches the command
--!      to one of the four RK05 where the delays associated with
--!      the disk drive are simulated.  (Each RK05 maintains a
--!      a notion of head, cyclinder, and sector so rotational
--!      and head motion delays can be accurate simulated).  Once
--!      The RK05 has completed it's operation, the command is
--!      forwarded to the Secure Digial disk device where the
--!      read or write is actually performed.
--!
--!      How this all works:
--!
--!      When the unit is powered-up, it runs through the SD Card
--!      initialization sequence.   This takes 3 or 4 milliseconds.
--!
--!      When the SD interface is initializing, the SD device
--!      asserts the sdINIT output which holds the processor in
--!      RESET.  That prevents the processor from giving the Disk
--!      Controller a command before it is finished initializing
--!      the SD Interface and the SD Card.
--!
--!      Once the SD Card is initialized, the SD interface waits
--!      in the stateIDLE state for a read command or a write
--!      command.
--!
--! \todo
--!      -# Most the of RK8E diagnostics are not implemented.
--!      -# The DMAN register and most of it's functionality is
--!         not implemented.
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

library ieee;                                           --! IEEE Library
use ieee.std_logic_1164.all;                            --! IEEE 1164
use ieee.numeric_std.all;                               --! IEEE Numeric Standard
use work.sd_types.all;                                  --! SD Types
use work.sdspi_types.all;                               --! SPI Types
use work.rk8e_types.all;                                --! RK8E types
use work.rk05_types.all;                                --! RK05 types
use work.cpu_types.all;                                 --! CPU types

--
--! RK8E Disk Controller Entity
--

entity eRK8E is port (
    sys       : in  sys_t;                              --! Clock/Reset
    -- Config
    devNUM    : in  devNUM_t;                           --! Device Number
    rk05INH   : in  std_logic_vector(0 to 3);           --! Write Inhibit
    rk05MNT   : in  std_logic_vector(0 to 3);           --! Device is Mounted
    -- DMA
    cpu       : in  cpu_t;                              --! CPU Output
    dev       : out dev_t;                              --! Device Output
    -- SD Interface
    sdCD      : in  std_logic;                          --! CD
    sdWP      : in  std_logic;                          --! WP
    sdMISO    : in  std_logic;                          --! Data In
    sdMOSI    : out std_logic;                          --! Data Out
    sdSCLK    : out std_logic;                          --! Clock
    sdCS      : out std_logic;                          --! Chip Select
    -- RK8E Status
    rk8eINIT  : out std_logic;                          --! RK8E is initializing
    rk8eSTAT  : out rk8eSTAT_t                          --! RK8E Status
);
end eRK8E;

--
--! RK8E Disk Controller RTL
--

architecture rtl of eRK8E is

    --
    -- Command Register
    --

    signal   rkcm        : data_t;                      --! Command Register
    subtype  rkcmFUN_t   is std_logic_vector(0 to 2);   --! FUN field type
    subtype  rkcmDRV_t   is std_logic_vector(0 to 1);   --! DRV Field type
    alias    rkcmFUN     : rkcmFUN_t is rkcm(0 to 2);   --! Function
    alias    rkcmIOD     : std_logic is rkcm(3);        --! Interrupt On Done
    alias    rkcmDOSD    : std_logic is rkcm(4);        --! Assert Done on Seek Done
    alias    rkcmLEN     : std_logic is rkcm(5);        --! Block Length
    alias    rkcmEMA     : field_t   is rkcm(6 to 8);   --! Extended Memory Address
    alias    rkcmDRV     : rkcmDRV_t is rkcm(9 to 10);  --! Drive Select
    alias    rkcmCYL0    : std_logic is rkcm(11);       --! Cylinder MSB
    constant funREAD     : rkcmFUN_t := "000";          --! Read Data Command
    constant funREADALL  : rkcmFUN_t := "001";          --! Read All Command
    constant funWRPROT   : rkcmFUN_t := "010";          --! Set write protect Command
    constant funSEEK     : rkcmFUN_t := "011";          --! Seek Command
    constant funWRITE    : rkcmFUN_t := "100";          --! Write Data Command
    constant funWRITEALL : rkcmFUN_t := "101";          --! Write All Command

    --
    -- Status Register bits that are implemented
    --

    signal   rkst        : data_t;                      --! Status register
    signal   rkstDONE    : std_logic;                   --! Device is done
    signal   rkstMOT     : std_logic;                   --! Head in Motion (seeking)
    signal   rkstFNR     : std_logic;                   --! File not ready
    signal   rkstBUSY    : std_logic;                   --! Controller is busy
    signal   rkstTME     : std_logic;                   --! Timing Error
    signal   rkstWLE     : std_logic;                   --! Write Lock Error
    signal   rkstSTE     : std_logic;                   --! Status Error

    --
    -- Memory Address Register
    --

    signal   rkma        : addr_t;                      --! Memory Address Register

    --
    -- Disk Address Register
    --

    subtype  rkdaCYL_t   is std_logic_vector(0 to 6);   --! RKDA Cylinder type
    subtype  rkdaSECT_t  is std_logic_vector(0 to 3);   --! RKDA Sector type
    subtype  rkdaHEAD_t  is std_logic;                  --! RKDA Head type
    signal   rkda        : data_t;                      --! Disk Address Register
    alias    rkdaCYL     : rkdaCYL_t  is rkda(0 to 6);  --! Cylinder
    alias    rkdaHEAD    : rkdaHEAD_t is rkda(7);       --! Head
    alias    rkdaSECT    : rkdaSECT_t is rkda(8 to 11); --! Sector

    --
    -- Maintenance Mode Registers
    --

    signal  maintMODE    : std_logic;                   --! Maintenance Mode
    signal  shiftEN      : std_logic;                   --! Shifter Enable
    signal  shiftCNT     : unsigned(0 to 3);            --! Shift Count

    --
    -- Disk Operations
    --

    type     rk8eOP_t    is (rk8eopNOP,                 --! Nothing to do
                             rk8eopDCLS,                --! Disk Clear Status
                             rk8eopDCLC,                --! Disk Clear Control
                             rk8eopDCLD,                --! Disk Clear Drive
                             rk8eopDLAG,                --! Disk Load and Go
                             rk8eopDLCA,                --! Disk Load Current Address
                             rk8eopDLDC,                --! Disk Load Command
                             rk8eopDMAN);               --! Disk Maintenace Mode
    signal   rk8eOP      : rk8eOP_t;                    --! Disk Operation

    --
    -- Device OP Codes
    -- Normally Device is 7x
    --

    constant opDSKP      : devOP_t    := o"1";          --! 6xx1 : Disk Skip on Flag
    constant opDCLR      : devOP_t    := o"2";          --! 6xx2 : Disk Clear
    constant opDLAG      : devOP_t    := o"3";          --! 6xx3 : Disk Load Address and Go
    constant opDLCA      : devOP_t    := o"4";          --! 6xx4 : Disk Load Current Address
    constant opDRST      : devOP_t    := o"5";          --! 6xx5 : Disk Read Status
    constant opDLDC      : devOP_t    := o"6";          --! 6xx6 : Disk Load Command
    constant opDMAN      : devOP_t    := o"7";          --! 6xx6 : Disk Maintenance

    --
    -- Clear Commands
    --

    subtype  clrOP_t     is std_logic_vector(0 to 1);
    constant clropCLS    : clrOP_t    := "00";          --! Clear Status
    constant clropCLC    : clrOP_t    := "01";          --! Clear Control
    constant clropCLD    : clrOP_t    := "10";          --! Clear Drive
    constant clropCLSA   : clrOP_t    := "11";          --! Clear Status Alt

    --
    -- RK05 Interfaces
    --

    signal   rk05OP      : rk05OP_tt;                   --! Array of RK05 OPs
    signal   rk05STAT    : rk05STAT_tt;                 --! Array of RK05 Status
    signal   rk05CYL     : rk05CYL_t;                   --! Cylinder

    --
    -- Interface to SD Controller
    --

    signal   sdOP        : sdOP_t;                      --! SD Device Command
    signal   sdLEN       : sdLEN_t;                     --! 128/256 Word access
    signal   sdMEMaddr   : addr_t;                      --! Memory Address
    signal   sdDISKaddr  : sdDISKaddr_t;                --! Linear Disk Address
    signal   sdFAIL      : std_logic;                   --! SD Failed
    signal   sdSTAT      : sdSTAT_t;                    --! SD Device Status

    --
    -- DMA Interface
    --

    signal   dmaDOUT     : data_t;                      --! DMA Data Out
    signal   dmaADDR     : addr_t;                      --! DMA Address
    signal   dmaRD       : std_logic;                   --! DMA Read
    signal   dmaWR       : std_logic;                   --! DMA Write
    signal   dmaREQ      : std_logic;                   --! DMA Request

    --
    -- Misc
    --

    signal   skipFLAG    : std_logic;                   --! Skip Flag

    --
    -- Drives
    --

    signal   driveSelect : rk05drvNUM_t;
    signal   rk05BUSY    : rk05drvNUM_t;

    --
    -- Bit OPs
    --

    type     bitOP_t     is (bitopNOP,
                             bitopSET,
                             bitopCLR);
    signal   bitopDONE   : bitOP_t;
    signal   bitopMOT    : bitOP_t;
    signal   bitopFNR    : bitOP_t;
    signal   bitopBUSY   : bitOP_t;
    signal   bitopTME    : bitOP_t;
    signal   bitopWLE    : bitOP_t;
    signal   bitopSTE    : bitOP_t;

    --
    -- Configuration
    --

    constant simh        : std_logic := '1';
    constant test        : std_logic := '0';
    constant simtime     : std_logic := '0';            --! Simulate disk timing

    --
    --! isBUSY:
    --!  Returns true if the controller is busy, false otherwise.
    --

    function isBUSY(rk05BUSY : rk05drvNUM_t) return boolean is
    begin
        if ((rk05BUSY = DRIVE0) or (rk05BUSY = DRIVE1) or
            (rk05BUSY = DRIVE2) or (rk05BUSY = DRIVE3)) then
            return true;
        else
            return false;
        end if;
    end isBUSY;

begin

    --
    -- RK05 Drive Select
    --

    driveSelect <= to_integer(unsigned(rkcmDRV));

    --
    -- RK05 Cylinder
    --

    rk05CYL <= rkcmCYL0 & rkdaCYL;

    --
    -- SD Failure
    --

    sdFAIL    <= '1' when ((sdSTAT.state = sdstateINFAIL) or
                           (sdSTAT.state = sdstateRWFAIL)) else '0';

    --
    -- SD Initializing
    --
    
    rk8eINIT  <= '1' when sdSTAT.state = sdstateINIT else '0';
    
    --
    --! RK8E Bus Interface
    --!
    --! \details
    --!     The Bus Interface decodes the individual RK8E IOT instructions.
    --!     The various disk operations are encoded into the rk8eOP command
    --!     which is applied to the RK8E state machine.
    --!
    --! \note
    --!     The Bus Interface is totally asynchronous.  The dev.ack,
    --!     dev.skip, and dev.devc signals are combinationally derived from
    --!     CPU output bus signals.  These signals will be sampled by the
    --!     CPU on the device bus input on the next clock cycle.
    --

    RK8E_BUSINTF : process(cpu.buss, devNUM, rkst, rkcm, dmaRD, dmaWR, dmaREQ,
                           skipFLAG, dmaDOUT, dmaADDR, sdDISKaddr)
    begin

        dev.ack   <= '0';
        dev.data  <= (others => '0');
        dev.devc  <= devWR;
        dev.skip  <= '0';
        dev.cpreq <= '0';
        dev.intr  <= rkcmIOD and skipFLAG;
        rk8eOP    <= rk8eopNOP;

        if cpu.buss.addr(0 to 2) = opIOT and cpu.buss.addr(3 to 8) = devNUM and cpu.buss.lxdar = '1' then

            case cpu.buss.addr(9 to 11) is

                --
                -- IOT 6xx1: DSKP - Disk Skip on Flag
                --

                when opDSKP =>
                    dev.ack  <= '1';
                    dev.devc <= devWR;
                    dev.skip <= skipFLAG;
                    rk8eOP   <= rk8eopNOP;

                --
                -- IOT 6xx2: DCLR - Disk Clear
                --

                when opDCLR =>
                    dev.ack   <= '1';
                    dev.devc  <= devWRCLR;
                    dev.skip  <= '0';

                    case cpu.buss.data(10 to 11) is

                        --
                        -- DCLS: Clear AC and Status Register
                        --

                        when clropCLS =>
                            rk8eOP <= rk8eopDCLS;

                        --
                        -- DCLC: Clear AC, Control, everything.
                        --

                        when clropCLC =>
                            rk8eOP <= rk8eopDCLC;

                        --
                        -- DCLD: Clear AC, recalibrate to track 0,
                        -- and clear Status Register
                        --

                        when clropCLD =>
                            rk8eOP <= rk8eopDCLD;

                        --
                        -- DCLSA: Clear Status (Alt Decode of DCLS)
                        --

                        when clropCLSA =>
                            rk8eOP <= rk8eopDCLS;

                        --
                        -- Everything else
                        --

                        when others =>
                            rk8eOP <= rk8eopNOP;

                    end case;

                --
                -- IOT 6xx3: DLAG - Disk Load Address and Go
                --

                when opDLAG =>
                    dev.ack  <= '1';
                    dev.devc <= devWRCLR;
                    rk8eOP   <= rk8eopDLAG;

                --
                -- IOT 6xx4: DLCA - Disk Load Current Address
                --

                when opDLCA =>
                    dev.ack  <= '1';
                    dev.devc <= devWRCLR;
                    rk8eOP   <= rk8eopDLCA;

                --
                -- IOT 6xx5: DRST - Disk Read STatus
                --

                when opDRST =>
                    dev.ack  <= '1';
                    dev.devc <= devRDCLR;
                    dev.data <= rkst;
                    rk8eOP   <= rk8eopNOP;

                --
                -- IOT 6xx6: DLDC - Disk Load Disk Command
                --

                when opDLDC =>
                    dev.ack  <= '1';
                    dev.devc <= devWRCLR;
                    rk8eOP   <= rk8eopDLDC;

                --
                -- IOT 6xx7: DMAN - Maintenance Instruction
                --

                when opDMAN =>
                    dev.ack <= '1';
                    rk8eOP  <= rk8eopDMAN;
                    if cpu.buss.data(7) = '1' then
                        dev.devc <= devRDCLR;
                        dev.data <= o"5555";
                    else
                        dev.devc <= devWRCLR;
                    end if;

                --
                -- Everthing else
                --

                when others =>
                    rk8eOP <= rk8eopNOP;

            end case;

        --
        -- DMA Operation
        --

        else

            if dmaWR = '1' then
                dev.data(0 to 11) <= dmaDOUT;
            end if;

        end if;

        dev.dma.rd     <= dmaRD;
        dev.dma.wr     <= dmaWR;
        dev.dma.req    <= dmaREQ;
        dev.dma.memsel <= dmaRD or dmaWR;
        dev.dma.lxmar  <= dmaRD or dmaWR;
        dev.dma.lxpar  <= '0';
        dev.dma.addr   <= dmaADDR;
        dev.dma.eaddr  <= rkcmEMA;

    end process RK8E_BUSINTF;

    --
    --! RK8E Register Set and State Machine
    --!
    --! \details
    --!     The various rk8eOPs that were decoded by the Bus Interface
    --!     are dispatched and handled by this state machine.

    RK8E_REGS : process(sys)

    begin

        if sys.rst = '1' then
            rkcm           <= (others => '0');
            rkma           <= (others => '0');
            rkda           <= (others => '0');
            shiftCNT       <= (others => '0');
            maintMODE      <= '0';
            shiftEN        <= '0';
            skipFLAG       <= '0';
            bitopDONE      <= bitopCLR;
            bitopMOT       <= bitopCLR;
            bitopFNR       <= bitopCLR;
            bitopBUSY      <= bitopCLR;
            bitopTME       <= bitopCLR;
            bitopWLE       <= bitopCLR;
            bitopSTE       <= bitopCLR;
            rk05OP(DRIVE0) <= rk05opCLR;
            rk05OP(DRIVE1) <= rk05opCLR;
            rk05OP(DRIVE2) <= rk05opCLR;
            rk05OP(DRIVE3) <= rk05opCLR;
            rk05BUSY       <= DRIVENULL;

        elsif rising_edge(sys.clk) then

            bitopDONE      <= bitopNOP;
            bitopMOT       <= bitopNOP;
            bitopFNR       <= bitopNOP;
            bitopBUSY      <= bitopNOP;
            bitopTME       <= bitopNOP;
            bitopWLE       <= bitopNOP;
            bitopSTE       <= bitopNOP;
            rk05OP(DRIVE0) <= rk05opNOP;
            rk05OP(DRIVE1) <= rk05opNOP;
            rk05OP(DRIVE2) <= rk05opNOP;
            rk05OP(DRIVE3) <= rk05opNOP;

            if cpu.buss.ioclr = '1' then

                rkcm           <= (others => '0');
                rkma           <= (others => '0');
                rkda           <= (others => '0');
                shiftCNT       <= (others => '0');
                maintMODE      <= '0';
                shiftEN        <= '0';
                skipFLAG       <= '0';
                bitopDONE      <= bitopCLR;
                bitopMOT       <= bitopCLR;
                bitopFNR       <= bitopCLR;
                bitopBUSY      <= bitopCLR;
                bitopTME       <= bitopCLR;
                bitopWLE       <= bitopCLR;
                bitopSTE       <= bitopCLR;
                rk05OP(DRIVE0) <= rk05opCLR;
                rk05OP(DRIVE1) <= rk05opCLR;
                rk05OP(DRIVE2) <= rk05opCLR;
                rk05OP(DRIVE3) <= rk05opCLR;
                rk05BUSY       <= DRIVENULL;

            else

                case rk8eOP is

                    --
                    -- Nothing to do
                    --

                    when rk8eopNOP =>
                        null;

                    --
                    -- DCLS: Disk Clear Status - Clear AC and Status Register
                    --

                    when rk8eopDCLS =>
                        skipFLAG  <= '0';
                        bitopDONE <= bitopCLR;
                        bitopMOT  <= bitopCLR;
                        bitopFNR  <= bitopCLR;
                        bitopBUSY <= bitopCLR;
                        bitopTME  <= bitopCLR;
                        bitopWLE  <= bitopCLR;
                        bitopSTE  <= bitopCLR;

                        if simh = '1' then
                            if isBUSY(rk05BUSY) then
                                bitopBUSY <= bitopSET;
                            end if;
                        else
                            if rk05STAT(driveSelect).mounted = '0' then
                                bitopMOT <= bitopSET;
                                bitopFNR <= bitopSET;
                            end if;
                            if rk05STAT(driveSelect).recal = '1' then
                                bitopBUSY <= bitopSET;
                                bitopSTE  <= bitopSET;
                                skipFLAG  <= '1';
                            end if;
                        end if;

                    --
                    -- DCLC: Disk Clear Control - Clear AC, Control, and Major Registers
                    --

                    when rk8eopDCLC =>
                        skipFLAG       <= '0';
                        rkcm           <= (others => '0');
                        rkma           <= (others => '0');
                        rkda           <= (others => '0');
                        shiftCNT       <= (others => '0');
                        maintMODE      <= '0';
                        shiftEN        <= '0';
                        bitopDONE      <= bitopCLR;
                        bitopMOT       <= bitopCLR;
                        bitopFNR       <= bitopCLR;
                        bitopBUSY      <= bitopCLR;
                        bitopTME       <= bitopCLR;
                        bitopWLE       <= bitopCLR;
                        bitopSTE       <= bitopCLR;
                        rk05OP(DRIVE0) <= rk05opCLR;
                        rk05OP(DRIVE1) <= rk05opCLR;
                        rk05OP(DRIVE2) <= rk05opCLR;
                        rk05OP(DRIVE3) <= rk05opCLR;
                        rk05BUSY       <= DRIVENULL;

                        if simh = '0' then
                            if rk05STAT(DRIVE0).mounted = '0' then
                                bitopMOT <= bitopSET;
                                bitopFNR <= bitopSET;
                            end if;
                        end if;

                    --
                    -- DCLD: Disk Clear Drive - Clear AC, recalibrate selected
                    -- drive to track 0, and clear Status Register.
                    --

                    when rk8eopDCLD =>
                        bitopDONE <= bitopCLR;
                        bitopMOT  <= bitopCLR;
                        bitopFNR  <= bitopCLR;
                        bitopBUSY <= bitopCLR;
                        bitopTME  <= bitopCLR;
                        bitopWLE  <= bitopCLR;
                        bitopSTE  <= bitopCLR;

                        if simh = '1' then
                            if isBUSY(rk05BUSY) then
                                bitopBUSY <= bitopSET;
                            else
                                if rk05STAT(driveSelect).mounted = '0' then
                                    bitopDONE <= bitopSET;
                                    bitopFNR  <= bitopSET;
                                    bitopSTE  <= bitopSET;
                                    skipFLAG  <= '1';
                                elsif isBUSY(rk05BUSY) then
                                    bitopDONE <= bitopSET;
                                    bitopSTE  <= bitopSET;
                                    skipFLAG  <= '1';
                                else
                                    bitopDONE <= bitopSET;
                                    skipFLAG  <= '1';
                                    rk05OP(driveSelect) <= rk05opRECAL;
                                 end if;
                            end if;
                        else
                            if rk05STAT(driveSelect).mounted = '0' then
                                bitopMOT <= bitopSET;
                                bitopFNR <= bitopSET;
                                bitopSTE <= bitopSET;
                                if rk05STAT(driveSelect).recal = '1' then
                                    bitopBUSY <= bitopSET;
                                end if;
                                if maintMODE = '0' then
                                    skipFLAG  <= '1';
                                end if;
                            else
                                rk05OP(driveSelect) <= rk05opRECAL;
                                bitopDONE <= bitopSET;
                                skipFLAG  <= '1';
                            end if;

                        end if;

                    --
                    -- DLAG: Disk Load and Go.  If the disk is not already busy,
                    -- the contents of AC are loaded into the Disk Address
                    -- Register.  Run the command from the command register.
                    --

                    when rk8eopDLAG =>

                        if simh = '1' then
                            if isBUSY(rk05BUSY) then
                                bitopBUSY <= bitopSET;
                            else
                                rkda <= cpu.buss.data;
                                if rk05STAT(driveSelect).mounted = '0' then
                                    bitopDONE <= bitopSET;
                                    bitopFNR  <= bitopSET;
                                    bitopSTE  <= bitopSET;
                                    skipFLAG  <= '1';
                                elsif rk05STAT(driveSelect).state = rk05stBUSY then
                                    bitopDONE <= bitopSET;
                                    bitopSTE  <= bitopSET;
                                    skipFLAG  <= '1';
                                elsif unsigned(rkcmCYL0 & cpu.buss.data(0 to 6)) > 202 then
                                    bitopDONE <= bitopSET;
                                    bitopSTE  <= bitopSET;
                                    skipFLAG  <= '1';
                                else
                                    case rkcmFUN is

                                        --
                                        -- Write Protect Command
                                        --

                                        when funWRPROT =>
                                            bitopDONE <= bitopSET;
                                            skipFLAG  <= '1';
                                            rk05OP(driveSelect) <= rk05opWRPROT;

                                        --
                                        -- Seek Command
                                        --

                                        when funSEEK =>
                                            bitopDONE <= bitopSET;
                                            bitopMOT  <= bitopSET;
                                            skipFLAG  <= '1';
                                            rk05OP(driveSelect) <= rk05opSEEK;

                                        --
                                        -- Read Command
                                        --

                                        when funREAD | funREADALL =>
                                            bitopBUSY <= bitopSET;
                                            bitopMOT  <= bitopSET;
                                            rk05BUSY  <= driveSelect;
                                            rk05OP(driveSelect) <= rk05opREAD;

                                        --
                                        -- Write Command
                                        --

                                        when funWRITE | funWRITEALL =>
                                            if rk05STAT(driveSelect).WRINH = '1' then
                                                bitopDONE <= bitopSET;
                                                bitopMOT  <= bitopSET;
                                                bitopWLE  <= bitopSET;
                                                skipFLAG  <= '1';
                                            else
                                                bitopBUSY <= bitopSET;
                                                bitopMOT  <= bitopSET;
                                                rk05BUSY  <= driveSelect;
                                                rk05OP(driveSelect) <= rk05opWRITE;
                                            end if;

                                        --
                                        -- Functions 6 and 7 are unused.
                                        --

                                        when others =>
                                            bitopDONE <= bitopSET;
                                            bitopTME  <= bitopSET;
                                            skipFLAG  <= '1';

                                    end case;
                                end if;
                            end if; --! BUSY
                        else -- !SIMH
                            if ((rk05STAT(driveSelect).recal = '0' and rk05STAT(driveSelect).WRINH = '0') or
                                (rk05STAT(driveSelect).recal = '0' and maintMODE = '1')) then
                                rkda <= cpu.buss.data;
                            end if;
                            if rk05STAT(driveSelect).mounted = '0' then
                                bitopMOT <= bitopSET;
                                bitopFNR <= bitopSET;
                                bitopSTE <= bitopSET;
                                skipFLAG <= '1';
                            else
                                null;
                            end if;
                        end if;

                    --
                    -- DLCA: Disk Load Current Address.  If the disk is not already
                    -- busy, the contents of AC are loaded into the Current Address
                    -- Register.
                    --

                    when rk8eopDLCA =>

                        if simh = '1' then
                            if isBUSY(rk05BUSY) then
                                bitopBUSY <= bitopSET;
                            else
                                rkma <= cpu.buss.data;
                            end if;
                        else
                            rkma <= cpu.buss.data;
                            if rk05STAT(driveSelect).recal = '1' then
                                bitopBUSY <= bitopSET;
                                skipFLAG <= '1';
                            end if;
                        end if;

                    --
                    -- DLDC: Load Command - The content of the AC is loaded
                    -- into the disk command register.  The AC and the Status
                    -- Register are cleared.
                    --

                    when rk8eopDLDC =>
                        bitopDONE <= bitopCLR;
                        bitopMOT  <= bitopCLR;
                        bitopFNR  <= bitopCLR;
                        bitopBUSY <= bitopCLR;
                        bitopTME  <= bitopCLR;
                        bitopWLE  <= bitopCLR;
                        bitopSTE  <= bitopCLR;
                        skipFLAG  <= '0';

                        if simh = '1' then
                            if isBUSY(rk05BUSY) then
                               bitopBUSY <= bitopSET;
                             else
                                rkcm <= cpu.buss.data;
                            end if;
                        else
                            if maintMODE = '0' or rk05STAT(driveSelect).recal = '0' then
                                rkcm <= cpu.buss.data;
                            end if;
                            if rk05STAT(driveSelect).mounted = '1' then
                                if isBUSY(rk05BUSY) then
                                    bitopMOT <= bitopSET;
                                end if;
                            else
                                bitopMOT <= bitopSET;
                                bitopFNR <= bitopSET;
                                if rk05STAT(driveSelect).recal = '1' then
                                    bitopBUSY <= bitopSET;
                                    bitopSTE  <= bitopSET;
                                    skipFLAG  <= '1';
                                end if;
                            end if;
                        end if;

                    --
                    -- DMAN: Disk Maintenance Mode - AC(0) Enables maintence mode.
                    --

                    when rk8eopDMAN =>
                        maintMODE <= cpu.buss.data(0);
                        shiftEN   <= '0';
                        shiftCNT  <= "0000";
                        if maintMODE = '1' then

                            --
                            -- Enable shift to data buffer (DB4)
                            --

                            if cpu.buss.data(1) = '1' then

                            --
                            --
                            --

                            elsif cpu.buss.data(2) = '1' then

                            elsif cpu.buss.data(3) = '1' then



                            end if;
                        end if;

                    --
                    -- Everthing else
                    --

                    when others =>
                        null;

                end case;

                --
                -- Handle RK05 completion events
                --

                sdOP <= sdopNOP;
                if isBUSY(rk05BUSY) then

                    if rk05STAT(rk05BUSY).state = rk05stDONE then
                        bitopMOT <= bitopCLR;
                        case rk05STAT(rk05BUSY).sdOP is

                            --
                            -- sdopNOP
                            --  This is asserted on a SEEK or RECALIBRATE completion.
                            --

                            when sdopNOP =>
                                if rkcmDOSD = '1' then
                                    bitopDONE <= bitopSET;
                                end if;

                            --
                            -- sdopABORT
                            --  This is asserted on a DCLC command
                            --

                            when sdopABORT =>
                                sdOP <= sdopABORT;

                            --
                            -- sdopRD
                            --

                            when sdopRD =>
                                if rk05STAT(rk05BUSY).mounted = '0' then
                                    bitopDONE <= bitopSET;
                                    bitopSTE  <= bitopSET;
                                    rk05BUSY  <= DRIVENULL;
                                else
                                    sdOP       <= rk05STAT(rk05BUSY).sdOP;
                                    sdLEN      <= rk05STAT(rk05BUSY).sdLEN;
                                    sdMEMaddr  <= rk05STAT(rk05BUSY).sdMEMaddr;
                                    sdDISKaddr <= rk05STAT(rk05BUSY).sdDISKaddr;
                                end if;

                            --
                            -- sdopWR
                            --

                            when sdopWR =>
                                if rk05STAT(rk05BUSY).mounted = '0' then
                                    bitopDONE <= bitopSET;
                                    bitopSTE  <= bitopSET;
                                    rk05BUSY  <= DRIVENULL;
                                elsif rk05STAT(driveSelect).WRINH = '1' then
                                    bitopWLE  <= bitopSET;
                                    bitopDONE <= bitopSET;
                                    rk05BUSY  <= DRIVENULL;
                                else
                                    sdOP       <= rk05STAT(rk05BUSY).sdOP;
                                    sdLEN      <= rk05STAT(rk05BUSY).sdLEN;
                                    sdMEMaddr  <= rk05STAT(rk05BUSY).sdMEMaddr;
                                    sdDISKaddr <= rk05STAT(rk05BUSY).sdDISKaddr;
                                end if;

                            --
                            -- Anything else
                            --

                            when others =>
                                null;
                        end case;
                    end if;
                end if;

                --
                -- Handle SD completion events
                --

                if sdSTAT.state = sdstateDONE then
                    bitopDONE <= bitopSET;
                    bitopBUSY <= bitopCLR;
                    skipFLAG  <= '1';
                    rk05BUSY  <= DRIVENULL;
                    rkma      <= dmaADDR;
                end if;

            end if;
        end if;

    end process RK8E_REGS;

    --
    --! RK8E Status Register
    --

    RK8E_STATUS : process(sys)
    begin
        if sys.rst = '1' then

            rkstDONE <= '0';
            rkstMOT  <= '0';
            rkstFNR  <= '0';
            rkstBUSY <= '0';
            rkstTME  <= '0';
            rkstWLE  <= '0';
            rkstSTE  <= '0';

        elsif rising_edge(sys.clk) then

            if cpu.buss.ioclr = '1' then

                rkstDONE <= '0';
                rkstMOT  <= '0';
                rkstFNR  <= '0';
                rkstBUSY <= '0';
                rkstTME  <= '0';
                rkstWLE  <= '0';
                rkstSTE  <= '0';

            else

                case bitopDONE is
                    when bitopSET => rkstDONE <= '1';
                    when bitopCLR => rkstDONE <= '0';
                    when others   => null;
                end case;
                case bitopMOT is
                    when bitopSET => rkstMOT <= '1';
                    when bitopCLR => rkstMOT <= '0';
                    when others   => null;
                end case;
                case bitopFNR is
                    when bitopSET => rkstFNR <= '1';
                    when bitopCLR => rkstFNR <= '0';
                    when others   => null;
                end case;
                case bitopBUSY is
                    when bitopSET => rkstBUSY <= '1';
                    when bitopCLR => rkstBUSY <= '0';
                    when others   => null;
                end case;
                case bitopTME  is
                    when bitopSET => rkstTME <= '1';
                    when bitopCLR => rkstTME <= '0';
                    when others   => null;
                end case;
                case bitopWLE  is
                    when bitopSET => rkstWLE <= '1';
                    when bitopCLR => rkstWLE <= '0';
                    when others   => null;
                end case;
                case bitopSTE is
                    when bitopSET => rkstSTE <= '1';
                    when bitopCLR => rkstSTE <= '0';
                    when others   => null;
                end case;
            end if;
        end if;
    end process RK8E_STATUS;

    --
    -- Status Register
    --

    rkst <= rkstDONE & rkstMOT & '0' & '0' & rkstFNR  & rkstBUSY &
            rkstTME  & rkstWLE & '0' & '0' & rkstSTE  & '0';

    --
    --! RK05 Device #0
    --

    iRK05_0 : entity work.eRK05 (rtl) port map (
        sys         => sys,
        ioclr       => cpu.buss.ioclr,
        simtime     => simtime,
        sdWP        => sdWP,
        sdCD        => sdCD,
        sdFAIL      => sdFAIL,
        rk05INH     => rk05INH(DRIVE0),
        rk05MNT     => rk05MNT(DRIVE0),
        rk05OP      => rk05OP(DRIVE0),
        rk05CYL     => rk05CYL,
        rk05HEAD    => rkdaHEAD,
        rk05SECT    => rkdaSECT,
        rk05DRIVE   => "00",
        rk05LEN     => rkcmLEN,
        rk05MEMaddr => rkma,
        rk05STAT    => rk05STAT(DRIVE0)
    );

    --
    --! RK05 Device #1
    --

    iRK05_1 : entity work.eRK05 (rtl) port map (
        sys         => sys,
        ioclr       => cpu.buss.ioclr,
        simtime     => simtime,
        sdWP        => sdWP,
        sdCD        => sdCD,
        sdFAIL      => sdFAIL,
        rk05INH     => rk05INH(DRIVE1),
        rk05MNT     => rk05MNT(DRIVE1),
        rk05OP      => rk05OP(DRIVE1),
        rk05CYL     => rk05CYL,
        rk05HEAD    => rkdaHEAD,
        rk05SECT    => rkdaSECT,
        rk05DRIVE   => "01",
        rk05LEN     => rkcmLEN,
        rk05MEMaddr => rkma,
        rk05STAT    => rk05STAT(DRIVE1)
    );

    --
    --! RK05 Device #2
    --

    iRK05_2 : entity work.eRK05 (rtl) port map (
        sys         => sys,
        ioclr       => cpu.buss.ioclr,
        simtime     => simtime,
        sdWP        => sdWP,
        sdCD        => sdCD,
        sdFAIL      => sdFAIL,
        rk05INH     => rk05INH(DRIVE2),
        rk05MNT     => rk05MNT(DRIVE2),
        rk05OP      => rk05OP(DRIVE2),
        rk05CYL     => rk05CYL,
        rk05HEAD    => rkdaHEAD,
        rk05SECT    => rkdaSECT,
        rk05DRIVE   => "10",
        rk05LEN     => rkcmLEN,
        rk05MEMaddr => rkma,
        rk05STAT    => rk05STAT(DRIVE2)
    );

    --
    --! RK05 Device #3
    --

    iRK05_3 : entity work.eRK05 (rtl) port map (
        sys         => sys,
        ioclr       => cpu.buss.ioclr,
        simtime     => simtime,
        sdWP        => sdWP,
        sdCD        => sdCD,
        sdFAIL      => sdFAIL,
        rk05INH     => rk05INH(DRIVE3),
        rk05MNT     => rk05MNT(DRIVE3),
        rk05OP      => rk05OP(DRIVE3),
        rk05CYL     => rk05CYL,
        rk05HEAD    => rkdaHEAD,
        rk05SECT    => rkdaSECT,
        rk05DRIVE   => "11",
        rk05LEN     => rkcmLEN,
        rk05MEMaddr => rkma,
        rk05STAT    => rk05STAT(DRIVE3)
    );

    --
    --! Secure Digital Interface
    --

    iSD : entity work.eSD (rtl) port map (
        sys        => sys,
        ioclr      => cpu.buss.ioclr,
        -- PDP8 Interface
        dmaDIN     => cpu.buss.data,
        dmaDOUT    => dmaDOUT,
        dmaADDR    => dmaADDR,
        dmaRD      => dmaRD,
        dmaWR      => dmaWR,
        dmaREQ     => dmaREQ,
        dmaGNT     => cpu.buss.dmagnt,
        -- Interface to SD Hardware
        sdMISO     => sdMISO,
        sdMOSI     => sdMOSI,
        sdSCLK     => sdSCLK,
        sdCS       => sdCS,
        -- Interface to SD Controller
        sdOP       => sdOP,
        sdDISKaddr => sdDISKaddr,
        sdMEMaddr  => sdMEMaddr,
        sdLEN      => sdLEN,
        sdSTAT     => sdSTAT
    );

    rk8eSTAT.sdCD     <= sdCD;
    rk8eSTAT.sdWP     <= sdWP;
    rk8eSTAT.sdSTAT   <= sdSTAT;
    rk8eSTAT.rk05STAT <= rk05STAT;

end rtl;
