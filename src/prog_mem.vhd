-------------------------------------------------------------------------------
-- 
-- Copyright (C) 2009, 2010 Dr. Juergen Sauermann
-- 
--  This code is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This code is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this code (see the file named COPYING).
--  If not, see http://www.gnu.org/licenses/.
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- Module Name:    prog_mem - Behavioral 
-- Create Date:    14:09:04 10/30/2009 
-- Description:    the program memory of a CPU.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- the content of the program memory.
--
use work.prog_mem_content.all;

entity prog_mem is
    port (  I_CLK       : in  std_logic;

            I_WAIT      : in  std_logic;
            I_PC        : in  std_logic_vector(15 downto 0); -- word address
            I_PM_ADR    : in  std_logic_vector(11 downto 0); -- byte address

            Q_OPC       : out std_logic_vector(31 downto 0);
            Q_PC        : out std_logic_vector(15 downto 0);
            Q_PM_DOUT   : out std_logic_vector( 7 downto 0));
end prog_mem;

architecture Behavioral of prog_mem is

constant zero_256 : bit_vector := X"00000000000000000000000000000000"
                                & X"00000000000000000000000000000000";

component RAMB4_S4_S4
    generic(INIT_00 : bit_vector := zero_256;
            INIT_01 : bit_vector := zero_256;
            INIT_02 : bit_vector := zero_256;
            INIT_03 : bit_vector := zero_256;
            INIT_04 : bit_vector := zero_256;
            INIT_05 : bit_vector := zero_256;
            INIT_06 : bit_vector := zero_256;
            INIT_07 : bit_vector := zero_256;
            INIT_08 : bit_vector := zero_256;
            INIT_09 : bit_vector := zero_256;
            INIT_0A : bit_vector := zero_256;
            INIT_0B : bit_vector := zero_256;
            INIT_0C : bit_vector := zero_256;
            INIT_0D : bit_vector := zero_256;
            INIT_0E : bit_vector := zero_256;
            INIT_0F : bit_vector := zero_256);

    port(   ADDRA   : in  std_logic_vector(9 downto 0);
            ADDRB   : in  std_logic_vector(9 downto 0);
            CLKA    : in  std_ulogic;
            CLKB    : in  std_ulogic;
            DIA     : in  std_logic_vector(3 downto 0);
            DIB     : in  std_logic_vector(3 downto 0);
            ENA     : in  std_ulogic;
            ENB     : in  std_ulogic;
            RSTA    : in  std_ulogic;
            RSTB    : in  std_ulogic;
            WEA     : in  std_ulogic;
            WEB     : in  std_ulogic;

            DOA     : out std_logic_vector(3 downto 0);
            DOB     : out std_logic_vector(3 downto 0));
end component;

signal M_OPC_E      : std_logic_vector(15 downto 0);
signal M_OPC_O      : std_logic_vector(15 downto 0);
signal M_PMD_E      : std_logic_vector(15 downto 0);
signal M_PMD_O      : std_logic_vector(15 downto 0);

signal L_WAIT_N     : std_logic;
signal L_PC_0       : std_logic;
signal L_PC_E       : std_logic_vector(10 downto 1);
signal L_PC_O       : std_logic_vector(10 downto 1);
signal L_PMD        : std_logic_vector(15 downto 0);
signal L_PM_ADR_1_0 : std_logic_vector( 1 downto 0);

begin

    pe_0 : RAMB4_S4_S4 ---------------------------------------------------------
    generic map(INIT_00 => p0_00, INIT_01 => p0_01, INIT_02 => p0_02, 
                INIT_03 => p0_03, INIT_04 => p0_04, INIT_05 => p0_05,
                INIT_06 => p0_06, INIT_07 => p0_07, INIT_08 => p0_08,
                INIT_09 => p0_09, INIT_0A => p0_0A, INIT_0B => p0_0B, 
                INIT_0C => p0_0C, INIT_0D => p0_0D, INIT_0E => p0_0E,
                INIT_0F => p0_0F)
    port map(ADDRA => L_PC_E,                   ADDRB => I_PM_ADR(11 downto 2),
             CLKA  => I_CLK,                    CLKB  => I_CLK,
             DIA   => "0000",                   DIB   => "0000",
             ENA   => L_WAIT_N,                 ENB   => '1',
             RSTA  => '0',                      RSTB  => '0',
             WEA   => '0',                      WEB   => '0',
             DOA   => M_OPC_E(3 downto 0),      DOB   => M_PMD_E(3 downto 0));
 
    pe_1 : RAMB4_S4_S4 ---------------------------------------------------------
    generic map(INIT_00 => p1_00, INIT_01 => p1_01, INIT_02 => p1_02,
                INIT_03 => p1_03, INIT_04 => p1_04, INIT_05 => p1_05,
                INIT_06 => p1_06, INIT_07 => p1_07, INIT_08 => p1_08,
                INIT_09 => p1_09, INIT_0A => p1_0A, INIT_0B => p1_0B,
                INIT_0C => p1_0C, INIT_0D => p1_0D, INIT_0E => p1_0E,
                INIT_0F => p1_0F)
    port map(ADDRA => L_PC_E,                   ADDRB => I_PM_ADR(11 downto 2),
             CLKA  => I_CLK,                    CLKB  => I_CLK,
             DIA   => "0000",                   DIB   => "0000",
             ENA   => L_WAIT_N,                 ENB   => '1',
             RSTA  => '0',                      RSTB  => '0',
             WEA   => '0',                      WEB   => '0',
             DOA   => M_OPC_E(7 downto 4),      DOB   => M_PMD_E(7 downto 4));
 
    pe_2 : RAMB4_S4_S4 ---------------------------------------------------------
    generic map(INIT_00 => p2_00, INIT_01 => p2_01, INIT_02 => p2_02,
                INIT_03 => p2_03, INIT_04 => p2_04, INIT_05 => p2_05,
                INIT_06 => p2_06, INIT_07 => p2_07, INIT_08 => p2_08,
                INIT_09 => p2_09, INIT_0A => p2_0A, INIT_0B => p2_0B,
                INIT_0C => p2_0C, INIT_0D => p2_0D, INIT_0E => p2_0E,
                INIT_0F => p2_0F)
    port map(ADDRA => L_PC_E,                   ADDRB => I_PM_ADR(11 downto 2),
             CLKA  => I_CLK,                    CLKB  => I_CLK,
             DIA   => "0000",                   DIB   => "0000",
             ENA   => L_WAIT_N,                 ENB   => '1',
             RSTA  => '0',                      RSTB  => '0',
             WEA   => '0',                      WEB   => '0',
             DOA   => M_OPC_E(11 downto 8),     DOB   => M_PMD_E(11 downto 8));
 
    pe_3 : RAMB4_S4_S4 ---------------------------------------------------------
    generic map(INIT_00 => p3_00, INIT_01 => p3_01, INIT_02 => p3_02,
                INIT_03 => p3_03, INIT_04 => p3_04, INIT_05 => p3_05,
                INIT_06 => p3_06, INIT_07 => p3_07, INIT_08 => p3_08,
                INIT_09 => p3_09, INIT_0A => p3_0A, INIT_0B => p3_0B,
                INIT_0C => p3_0C, INIT_0D => p3_0D, INIT_0E => p3_0E,
                INIT_0F => p3_0F)
    port map(ADDRA => L_PC_E,                   ADDRB => I_PM_ADR(11 downto 2),
             CLKA  => I_CLK,                    CLKB  => I_CLK,
             DIA   => "0000",                   DIB   => "0000",
             ENA   => L_WAIT_N,                 ENB   => '1',
             RSTA  => '0',                      RSTB  => '0',
             WEA   => '0',                      WEB   => '0',
             DOA   => M_OPC_E(15 downto 12),    DOB   => M_PMD_E(15 downto 12));
 
    po_0 : RAMB4_S4_S4 ---------------------------------------------------------
    generic map(INIT_00 => p4_00, INIT_01 => p4_01, INIT_02 => p4_02,
                INIT_03 => p4_03, INIT_04 => p4_04, INIT_05 => p4_05,
                INIT_06 => p4_06, INIT_07 => p4_07, INIT_08 => p4_08,
                INIT_09 => p4_09, INIT_0A => p4_0A, INIT_0B => p4_0B, 
                INIT_0C => p4_0C, INIT_0D => p4_0D, INIT_0E => p4_0E,
                INIT_0F => p4_0F)
    port map(ADDRA => L_PC_O,                   ADDRB => I_PM_ADR(11 downto 2),
             CLKA  => I_CLK,                    CLKB  => I_CLK,
             DIA   => "0000",                   DIB   => "0000",
             ENA   => L_WAIT_N,                 ENB   => '1',
             RSTA  => '0',                      RSTB  => '0',
             WEA   => '0',                      WEB   => '0',
             DOA   => M_OPC_O(3 downto 0),      DOB   => M_PMD_O(3 downto 0));
 
    po_1 : RAMB4_S4_S4 ---------------------------------------------------------
    generic map(INIT_00 => p5_00, INIT_01 => p5_01, INIT_02 => p5_02,
                INIT_03 => p5_03, INIT_04 => p5_04, INIT_05 => p5_05,
                INIT_06 => p5_06, INIT_07 => p5_07, INIT_08 => p5_08,
                INIT_09 => p5_09, INIT_0A => p5_0A, INIT_0B => p5_0B, 
                INIT_0C => p5_0C, INIT_0D => p5_0D, INIT_0E => p5_0E,
                INIT_0F => p5_0F)
    port map(ADDRA => L_PC_O,                   ADDRB => I_PM_ADR(11 downto 2),
             CLKA  => I_CLK,                    CLKB  => I_CLK,
             DIA   => "0000",                   DIB   => "0000",
             ENA   => L_WAIT_N,                 ENB   => '1',
             RSTA  => '0',                      RSTB  => '0',
             WEA   => '0',                      WEB   => '0',
             DOA   => M_OPC_O(7 downto 4),      DOB   => M_PMD_O(7 downto 4));
 
    po_2 : RAMB4_S4_S4 ---------------------------------------------------------
    generic map(INIT_00 => p6_00, INIT_01 => p6_01, INIT_02 => p6_02,
                INIT_03 => p6_03, INIT_04 => p6_04, INIT_05 => p6_05,
                INIT_06 => p6_06, INIT_07 => p6_07, INIT_08 => p6_08,
                INIT_09 => p6_09, INIT_0A => p6_0A, INIT_0B => p6_0B,
                INIT_0C => p6_0C, INIT_0D => p6_0D, INIT_0E => p6_0E,
                INIT_0F => p6_0F)
    port map(ADDRA => L_PC_O,                   ADDRB => I_PM_ADR(11 downto 2),
             CLKA  => I_CLK,                    CLKB  => I_CLK,
             DIA   => "0000",                   DIB   => "0000",
             ENA   => L_WAIT_N,                 ENB   => '1',
             RSTA  => '0',                      RSTB  => '0',
             WEA   => '0',                      WEB   => '0',
             DOA   => M_OPC_O(11 downto 8),     DOB   => M_PMD_O(11 downto 8));
 
    po_3 : RAMB4_S4_S4 ---------------------------------------------------------
    generic map(INIT_00 => p7_00, INIT_01 => p7_01, INIT_02 => p7_02,
                INIT_03 => p7_03, INIT_04 => p7_04, INIT_05 => p7_05,
                INIT_06 => p7_06, INIT_07 => p7_07, INIT_08 => p7_08,
                INIT_09 => p7_09, INIT_0A => p7_0A, INIT_0B => p7_0B, 
                INIT_0C => p7_0C, INIT_0D => p7_0D, INIT_0E => p7_0E,
                INIT_0F => p7_0F)
    port map(ADDRA => L_PC_O,                   ADDRB => I_PM_ADR(11 downto 2),
             CLKA  => I_CLK,                    CLKB  => I_CLK,
             DIA   => "0000",                   DIB   => "0000",
             ENA   => L_WAIT_N,                 ENB   => '1',
             RSTA  => '0',                      RSTB  => '0',
             WEA   => '0',                      WEB   => '0',
             DOA   => M_OPC_O(15 downto 12),    DOB   => M_PMD_O(15 downto 12));

    -- remember I_PC0 and I_PM_ADR for the output mux.
    --
    pc0: process(I_CLK)
    begin
        if (rising_edge(I_CLK)) then
            Q_PC <= I_PC;
            L_PM_ADR_1_0 <= I_PM_ADR(1 downto 0);
            if ((I_WAIT = '0')) then
                L_PC_0 <= I_PC(0);
            end if;
        end if;
    end process;

    L_WAIT_N <= not I_WAIT;

    -- we use two memory blocks _E and _O (even and odd).
    -- This gives us a quad-port memory so that we can access
    -- I_PC, I_PC + 1, and PM simultaneously.
    --
    -- I_PC and I_PC + 1 are handled by port A of the memory while PM
    -- is handled by port B.
    --
    -- Q_OPC(15 ... 0) shall contain the word addressed by I_PC, while
    -- Q_OPC(31 ... 16) shall contain the word addressed by I_PC + 1.
    --
    -- There are two cases:
    --
    -- case A: I_PC     is even, thus I_PC + 1 is odd
    -- case B: I_PC + 1 is odd , thus I_PC is even
    --
    L_PC_O <= I_PC(10 downto 1);
    L_PC_E <= I_PC(10 downto 1) + ("000000000" & I_PC(0));
    Q_OPC(15 downto  0) <= M_OPC_E when L_PC_0 = '0' else M_OPC_O;
    Q_OPC(31 downto 16) <= M_OPC_E when L_PC_0 = '1' else M_OPC_O;

    L_PMD <= M_PMD_E               when (L_PM_ADR_1_0(1) = '0') else M_PMD_O;
    Q_PM_DOUT <= L_PMD(7 downto 0) when (L_PM_ADR_1_0(0) = '0')
            else L_PMD(15 downto 8);
    
end Behavioral;

