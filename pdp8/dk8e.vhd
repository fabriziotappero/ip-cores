--------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      DK8E Real Time Clock
--!
--! \details
--!      This device emulates a K8EA/DK8EC/DK8EP Real Time Clock
--!      (RTC).  The RTC configuration is controlled by the 'swRTC'
--!      input which is typically routed to a DIP switch.
--!
--!      The following interrupt rates can be acheived:
--!      -#   000 : 1 Hz (DK8EC)
--!      -#   001 : 50 Hz (DK8EC)
--!      -#   010 : 100 Hz (DK8-EA with 50 Hz Primary Power)
--!      -#   011 : 120 Hz (DK8-EA with 60 Hz Primary Power)
--!      -#   100 : 500 Hz (DK8-EC)
--!      -#   101 : 5 KHz (DK8-EC)
--!      -#   110 : Variable (DK8-EP)
--!      -#   111 : Variable (DK8-ES)
--!
--! \todo
--!      This file is mostly a stub.  The DK8E needs to be
--!      implemented.
--!
--! \file
--!      dk8e.vhd
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
use work.dk8e_types.all;                        --! DK8E Types
use work.cpu_types.all;                         --! CPU Types

--
--! DK8E Real Time Clock Entity
--

entity eDK8E is port (
    sys       : in  sys_t;                      --! Clock/Reset
    swRTC     : in  swRTC_t;                    --! Baud Rate Select
    devNUM    : in  devNUM_t;                   --! IOT Device
    cpu       : in  cpu_t;                      --! CPU Input
    dev       : out dev_t;                      --! Device Output
    schmittIN : in  schmitt_t;                  --! Schmitt Trigger Inputs
    clkTRIG   : out std_logic                   --! Trigger Output
);
end eDK8E;

--
--! DK8E Real Time Clock RTL
--

architecture rtl of eDK8E is

    type   clkOP_t    is (clkopNOP,
                          clkopCLZE,
                          clkopCLDE,
                          clkopCLAB);

    signal clkOP      : clkOP_t;                --! Decoded Clock IOT Operation

    signal clkIeMUX   : std_logic;              --! Clock Interrupt Enable MUX
    signal clkIeREG   : std_logic;              --! Clock Interrupt Enable REG

    signal clkIrMUX   : std_logic;              --! Clock Interrupt Request MUX
    signal clkIrREG   : std_logic;              --! Clock Interrupt Request REG


    signal clkEnREG   : data_t;                 --! Clock Enable Register
    signal clkEnMUX   : data_t;                 --! Clock Enable Multiplexor
    signal clkCntREG  : data_t;                 --! Clock Count Register
    signal clkBufREG  : data_t;                 --! Clock Buffer Register
    signal clkStatREG : data_t;                 --! Clock Status Register

    alias  clkEnCE    : std_logic                is clkEnREG(0);        --! Clock Enable
    alias  clkEnME    : std_logic_vector(0 to 1) is clkEnREG(1 to 2);   --! Mode Enable
    alias  clkEnRE    : std_logic_vector(0 to 2) is clkEnReg(3 to 5);   --! Rate Enable

    signal count      : integer range 0 to 49999999;

begin

    --
    --! Bus Decoder
    --

    DK8E_BUSINTF : process(cpu.buss, devNUM, swRTC, clkEnREG, clkIeREG,
                           clkIrREG, clkStatREG, clkBufREG, clkCntREG)
    begin

        dev      <= nulldev;
        clkOP    <= clkopNOP;
        clkEnMUX <= clkEnREG;
        clkIeMUX <= clkIeREG;
        clkIrMUX <= clkIrREG;

        if cpu.buss.addr(0 to 2) = opIOT and cpu.buss.addr(3 to 8) = devNUM and cpu.buss.lxdar = '1' then

            case cpu.buss.addr(9 to 11) is

                --
                -- IOT 6xx0: DK8-EA - NOP
                --           DK8-EC - NOP
                --           DK8-EP - CLZE: Clear Clock Enable Register Per AC
                --

                when opCLZE =>
                    if swRTC = clkDK8EP then
                        dev.ack  <= '1';
                        dev.devc <= devWR;
                        dev.skip <= '0';
                        clkOP    <= clkopCLZE;
                        clkEnMUX <= clkEnREG and not cpu.buss.data;
                    end if;

                --
                -- IOT 6xx1: DK8-EA - CLEI: Enable Interrupts
                --           DK8-EC - CLEI: Enable Interrupts
                --           DK8-EP - CLSK: Skip on Clock Interrupt

                when opCLSK =>
                    if ((swRTC = clkDK8EA1) or
                        (swRTC = clkDK8EA2) or
                        (swRTC = clkDK8EC1) or
                        (swRTC = clkDK8EC2) or
                        (swRTC = clkDK8EC3) or
                        (swRTC = clkDK8EC4)) then
                        dev.ack  <= '1';
                        dev.devc <= devWR;
                        dev.skip <= '0';
                        clkIeMUX <= '1';
                    elsif swRTC = clkDK8EP then
                        dev.ack  <= '1';
                        dev.devc <= devWR;
                        dev.skip <= '1';  -- FIXME
                    end if;

                --
                -- IOT 6xx2: DK8-EA - CLDI: Disable Interrupts
                --           DK8-EC - CLDI: Disable Interrupts
                --           DK8-EP - CLDE: Set Clock Enable Register Per AC
                --

                when opCLDE =>
                    if ((swRTC = clkDK8EA1) or
                        (swRTC = clkDK8EA2) or
                        (swRTC = clkDK8EC1) or
                        (swRTC = clkDK8EC2) or
                        (swRTC = clkDK8EC3) or
                        (swRTC = clkDK8EC4)) then
                        dev.ack  <= '1';
                        dev.devc <= devWR;
                        dev.skip <= '0';
                        clkIeMUX <= '0';
                    elsif swRTC = clkDK8EP then
                        dev.ack  <= '1';
                        dev.devc <= devWR;
                        dev.skip <= '0';
                        clkOP    <= clkopCLDE;
                        clkEnMUX <= clkEnREG or cpu.buss.data;
                    end if;

                --
                -- IOT 6xx3: DK8-EA - CLSK: Skip on Clock Flag and Clear Flag
                --           DK8-EC - CLSK: Skip on Clock Flag and Clear Flag
                --           DK8-EP - CLAB: AC Register to Clock Buffer Register
                --

                when opCLAB =>
                    if ((swRTC = clkDK8EA1) or
                        (swRTC = clkDK8EA2) or
                        (swRTC = clkDK8EC1) or
                        (swRTC = clkDK8EC2) or
                        (swRTC = clkDK8EC3) or
                        (swRTC = clkDK8EC4)) then
                        dev.ack  <= '1';
                        dev.devc <= devWR;
                        dev.skip <= clkIrREG and clkIeREG;
                        clkIrMUX <= '0';
                    elsif swRTC = clkDK8EP then
                        dev.ack  <= '1';
                        dev.devc <= devRD;
                        dev.skip <= '0';
                        clkOP    <= clkopCLAB;
                    end if;

                --
                -- IOT 6xx4: DK8-EA - NOP
                --           DK8-EC - NOP
                --           DK8-EP - CLEN: Clock Enable Register to AC
                --

                when opCLEN =>
                     if swRTC = clkDK8EP then
                         dev.ack  <= '1';
                         dev.devc <= devRD;
                         dev.skip <= '0';
                         dev.data <= clkEnREG;
                    end if;

                --
                -- IOT 6xx5: DK8-EA - NOP
                --           DK8-EC - NOP
                --           DK8-EP - CLSA: Status Register to AC
                --

                when opCLSA =>
                    if swRTC = clkDK8EP then
                        dev.ack  <= '1';
                        dev.devc <= devRDCLR;
                        dev.skip <= '0';
                        dev.data <= clkStatREG;
                        clkOP    <= clkopNOP;
                    end if;

                --
                -- IOT 6xx6: DK8-EA - NOP
                --           DK8-EC - NOP
                --           DK8-EP - CLBA: Clock Buffer Register to AC
                --

                when opCLBA =>
                    if swRTC = clkDK8EP then
                        dev.ack  <= '1';
                        dev.devc <= devRDCLR;
                        dev.skip <= '0';
                        dev.data <= clkBufREG;
                        clkOP    <= clkopNOP;
                    end if;

                --
                -- IOT 6xx7: DK8-EA - NOP
                --           DK8-EC - NOP
                --           DK8-EP - CLCA: Clock Count Register to AC
                --

                when opCLCA =>
                    if swRTC = clkDK8EP then
                        dev.ack  <= '1';
                        dev.devc <= devRDCLR;
                        dev.skip <= '0';
                        dev.data <= clkCntREG;
                        clkOP    <= clkopNOP;
                    end if;

                --
                -- Anything Else?
                --

                when others =>
                    null;

            end case;
        end if;

        dev.intr <= clkIrREG and clkIeREG;

    end process DK8E_BUSINTF;

    --
    --! DK8E Registers
    --! \todo
    --!    This is really broken and generates some nasty warnings.
    --!

    DK8E_REGS : process(sys)

    begin
        if sys.rst = '1' then

             clkEnREG   <= (others => '0');
             clkCntREG  <= (others => '0');
             clkBufREG  <= (others => '0');
             clkStatREG <= (others => '0');

        elsif rising_edge(sys.clk) then

            if cpu.buss.ioclr = '1' then

                clkEnREG   <= (others => '0');
                clkCntREG  <= (others => '0');
                clkBufREG  <= (others => '0');
                clkStatREG <= (others => '0');

            else

                case clkOP is
                    when clkopNOP =>
                    when clkopCLZE =>
                    when clkopCLDE =>
                    when clkopCLAB =>
                    when others =>
                        null;
                end case;

            end if;
        end if;
    end process DK8E_REGS;

    --
    --! DK8-EA/DK8-EC Interrupt Flag
    --

    DK8E_INTR : process(sys)
    begin
        if sys.rst = '1' then
            clkIeREG <= '0';
        elsif rising_edge(sys.clk) then
            if cpu.buss.ioclr = '1' then
                clkIeREG <= '0';
            else
               clkIeREG <= clkIeMUX;
            end if;
        end if;
    end process DK8E_INTR;

    --
    --! DK8-EA/DK8-EC Down Counter
    --

    DK8E_COUNTER : process(sys)
    begin
        if sys.rst = '1' then
            count    <= 0;
            clkIrREG <= '0';
        elsif rising_edge(sys.clk) then
            if cpu.buss.ioclr = '1' then
                count    <= 0;
                clkIrREG <= '0';
            elsif ((swRTC = clkDK8EA1 and count =   500000) or  -- 100 Hz
                   (swRTC = clkDK8EA2 and count =   416667) or  -- 120 Hz
                   (swRTC = clkDK8EC1 and count = 50000000) or  -- 1 Hz
                   (swRTC = clkDK8EC2 and count =  1000000) or  -- 50 Hz
                   (swRTC = clkDK8EC3 and count =   100000) or  -- 500 Hz
                   (swRTC = clkDK8EC4 and count =    10000)) then  -- 5KHz
                count    <= 0;
                clkIrREG <= '1';
            else
                count <= count + 1;
                clkIrREG <= clkIrMUX;
            end if;
        end if;
    end process DK8E_COUNTER;

end rtl;
