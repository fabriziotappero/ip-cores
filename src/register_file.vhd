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
-- Module Name:    RegisterFile - Behavioral 
-- Create Date:    12:43:34 10/28/2009 
-- Description:    a register file (16 register pairs) of a CPU.
--
-------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.common.ALL;

entity register_file is
    port (  I_CLK       : in  std_logic;

            I_AMOD      : in  std_logic_vector( 5 downto 0);
            I_COND      : in  std_logic_vector( 3 downto 0);
            I_DDDDD     : in  std_logic_vector( 4 downto 0);
            I_DIN       : in  std_logic_vector(15 downto 0);
            I_FLAGS     : in  std_logic_vector( 7 downto 0);
            I_IMM       : in  std_logic_vector(15 downto 0);
            I_RRRR      : in  std_logic_vector( 4 downto 1);
            I_WE_01     : in  std_logic;
            I_WE_D      : in  std_logic_vector( 1 downto 0);
            I_WE_F      : in  std_logic;
            I_WE_M      : in  std_logic;
            I_WE_XYZS   : in  std_logic;

            Q_ADR       : out std_logic_vector(15 downto 0);
            Q_CC        : out std_logic;
            Q_D         : out std_logic_vector(15 downto 0);
            Q_FLAGS     : out std_logic_vector( 7 downto 0);
            Q_R         : out std_logic_vector(15 downto 0);
            Q_S         : out std_logic_vector( 7 downto 0);
            Q_Z         : out std_logic_vector(15 downto 0));
end register_file;

architecture Behavioral of register_file is

component reg_16
    port (  I_CLK       : in    std_logic;

            I_D         : in    std_logic_vector(15 downto 0);
            I_WE        : in    std_logic_vector( 1 downto 0);

            Q           : out   std_logic_vector(15 downto 0));
end component;

signal R_R00            : std_logic_vector(15 downto 0);
signal R_R02            : std_logic_vector(15 downto 0);
signal R_R04            : std_logic_vector(15 downto 0);
signal R_R06            : std_logic_vector(15 downto 0);
signal R_R08            : std_logic_vector(15 downto 0);
signal R_R10            : std_logic_vector(15 downto 0);
signal R_R12            : std_logic_vector(15 downto 0);
signal R_R14            : std_logic_vector(15 downto 0);
signal R_R16            : std_logic_vector(15 downto 0);
signal R_R18            : std_logic_vector(15 downto 0);
signal R_R20            : std_logic_vector(15 downto 0);
signal R_R22            : std_logic_vector(15 downto 0);
signal R_R24            : std_logic_vector(15 downto 0);
signal R_R26            : std_logic_vector(15 downto 0);
signal R_R28            : std_logic_vector(15 downto 0);
signal R_R30            : std_logic_vector(15 downto 0);
signal R_SP             : std_logic_vector(15 downto 0);    -- stack pointer

component status_reg is
    port (  I_CLK       : in  std_logic;

            I_COND      : in  std_logic_vector ( 3 downto 0);
            I_DIN       : in  std_logic_vector ( 7 downto 0);
            I_FLAGS     : in  std_logic_vector ( 7 downto 0);
            I_WE_F      : in  std_logic;
            I_WE_SR     : in  std_logic;

            Q           : out std_logic_vector ( 7 downto 0);
            Q_CC        : out std_logic);
end component;

signal S_FLAGS          : std_logic_vector( 7 downto 0);

signal L_ADR            : std_logic_vector(15 downto 0);
signal L_BASE           : std_logic_vector(15 downto 0);
signal L_DDDD           : std_logic_vector( 4 downto 1);
signal L_DSP            : std_logic_vector(15 downto 0);
signal L_DX             : std_logic_vector(15 downto 0);
signal L_DY             : std_logic_vector(15 downto 0);
signal L_DZ             : std_logic_vector(15 downto 0);
signal L_PRE            : std_logic_vector(15 downto 0);
signal L_POST           : std_logic_vector(15 downto 0);
signal L_S              : std_logic_vector(15 downto 0);
signal L_WE_SP_AMOD     : std_logic;
signal L_WE             : std_logic_vector(31 downto 0);
signal L_WE_A           : std_logic;
signal L_WE_D           : std_logic_vector(31 downto 0);
signal L_WE_D2          : std_logic_vector( 1 downto 0);
signal L_WE_DD          : std_logic_vector(31 downto 0);
signal L_WE_IO          : std_logic_vector(31 downto 0);
signal L_WE_MISC        : std_logic_vector(31 downto 0);
signal L_WE_X           : std_logic;
signal L_WE_Y           : std_logic;
signal L_WE_Z           : std_logic;
signal L_WE_SP          : std_logic_vector( 1 downto 0);
signal L_WE_SR          : std_logic;
signal L_XYZS           : std_logic_vector(15 downto 0);

begin

    r00: reg_16 port map(I_CLK => I_CLK, I_WE => L_WE( 1 downto  0), I_D => I_DIN, Q => R_R00);
    r02: reg_16 port map(I_CLK => I_CLK, I_WE => L_WE( 3 downto  2), I_D => I_DIN, Q => R_R02);
    r04: reg_16 port map(I_CLK => I_CLK, I_WE => L_WE( 5 downto  4), I_D => I_DIN, Q => R_R04);
    r06: reg_16 port map(I_CLK => I_CLK, I_WE => L_WE( 7 downto  6), I_D => I_DIN, Q => R_R06);
    r08: reg_16 port map(I_CLK => I_CLK, I_WE => L_WE( 9 downto  8), I_D => I_DIN, Q => R_R08);
    r10: reg_16 port map(I_CLK => I_CLK, I_WE => L_WE(11 downto 10), I_D => I_DIN, Q => R_R10);
    r12: reg_16 port map(I_CLK => I_CLK, I_WE => L_WE(13 downto 12), I_D => I_DIN, Q => R_R12);
    r14: reg_16 port map(I_CLK => I_CLK, I_WE => L_WE(15 downto 14), I_D => I_DIN, Q => R_R14);
    r16: reg_16 port map(I_CLK => I_CLK, I_WE => L_WE(17 downto 16), I_D => I_DIN, Q => R_R16);
    r18: reg_16 port map(I_CLK => I_CLK, I_WE => L_WE(19 downto 18), I_D => I_DIN, Q => R_R18);
    r20: reg_16 port map(I_CLK => I_CLK, I_WE => L_WE(21 downto 20), I_D => I_DIN, Q => R_R20);
    r22: reg_16 port map(I_CLK => I_CLK, I_WE => L_WE(23 downto 22), I_D => I_DIN, Q => R_R22);
    r24: reg_16 port map(I_CLK => I_CLK, I_WE => L_WE(25 downto 24), I_D => I_DIN, Q => R_R24);
    r26: reg_16 port map(I_CLK => I_CLK, I_WE => L_WE(27 downto 26), I_D => L_DX,  Q => R_R26);
    r28: reg_16 port map(I_CLK => I_CLK, I_WE => L_WE(29 downto 28), I_D => L_DY,  Q => R_R28);
    r30: reg_16 port map(I_CLK => I_CLK, I_WE => L_WE(31 downto 30), I_D => L_DZ,  Q => R_R30);
    sp:  reg_16 port map(I_CLK => I_CLK, I_WE => L_WE_SP,            I_D => L_DSP, Q => R_SP);

    sr: status_reg
    port map(   I_CLK       => I_CLK,
                I_COND      => I_COND,
                I_DIN       => I_DIN(7 downto 0),
                I_FLAGS     => I_FLAGS,
                I_WE_F      => I_WE_F,
                I_WE_SR     => L_WE_SR,
                Q           => S_FLAGS,
                Q_CC        => Q_CC);

    -- The output of the register selected by L_ADR.
    --
    process(R_R00, R_R02, R_R04, R_R06, R_R08, R_R10, R_R12, R_R14,
            R_R16, R_R18, R_R20, R_R22, R_R24, R_R26, R_R28, R_R30,
            R_SP, S_FLAGS, L_ADR(6 downto 1))
    begin
        case L_ADR(6 downto 1) is
            when "000000" => L_S <= R_R00;
            when "000001" => L_S <= R_R02;
            when "000010" => L_S <= R_R04;
            when "000011" => L_S <= R_R06;
            when "000100" => L_S <= R_R08;
            when "000101" => L_S <= R_R10;
            when "000110" => L_S <= R_R12;
            when "000111" => L_S <= R_R14;
            when "001000" => L_S <= R_R16;
            when "001001" => L_S <= R_R18;
            when "001010" => L_S <= R_R20;
            when "001011" => L_S <= R_R22;
            when "001100" => L_S <= R_R24;
            when "001101" => L_S <= R_R26;
            when "001110" => L_S <= R_R28;
            when "001111" => L_S <= R_R30;
            when "101110" => L_S <= R_SP ( 7 downto 0) & X"00";     -- SPL
            when others   => L_S <= S_FLAGS & R_SP (15 downto 8);   -- SR/SPH
        end case;
    end process;
    
    -- The output of the register pair selected by I_DDDDD.
    --
    process(R_R00, R_R02, R_R04, R_R06, R_R08, R_R10, R_R12, R_R14,
            R_R16, R_R18, R_R20, R_R22, R_R24, R_R26, R_R28, R_R30,
            I_DDDDD(4 downto 1))
    begin
        case I_DDDDD(4 downto 1) is
            when "0000" => Q_D <= R_R00;
            when "0001" => Q_D <= R_R02;
            when "0010" => Q_D <= R_R04;
            when "0011" => Q_D <= R_R06;
            when "0100" => Q_D <= R_R08;
            when "0101" => Q_D <= R_R10;
            when "0110" => Q_D <= R_R12;
            when "0111" => Q_D <= R_R14;
            when "1000" => Q_D <= R_R16;
            when "1001" => Q_D <= R_R18;
            when "1010" => Q_D <= R_R20;
            when "1011" => Q_D <= R_R22;
            when "1100" => Q_D <= R_R24;
            when "1101" => Q_D <= R_R26;
            when "1110" => Q_D <= R_R28;
            when others => Q_D <= R_R30;
        end case;
    end process;

    -- The output of the register pair selected by I_RRRR.
    --
    process(R_R00, R_R02, R_R04,  R_R06, R_R08, R_R10, R_R12, R_R14,
            R_R16, R_R18, R_R20, R_R22, R_R24, R_R26, R_R28, R_R30, I_RRRR)
    begin
        case I_RRRR is
            when "0000" => Q_R <= R_R00;
            when "0001" => Q_R <= R_R02;
            when "0010" => Q_R <= R_R04;
            when "0011" => Q_R <= R_R06;
            when "0100" => Q_R <= R_R08;
            when "0101" => Q_R <= R_R10;
            when "0110" => Q_R <= R_R12;
            when "0111" => Q_R <= R_R14;
            when "1000" => Q_R <= R_R16;
            when "1001" => Q_R <= R_R18;
            when "1010" => Q_R <= R_R20;
            when "1011" => Q_R <= R_R22;
            when "1100" => Q_R <= R_R24;
            when "1101" => Q_R <= R_R26;
            when "1110" => Q_R <= R_R28;
            when others => Q_R <= R_R30;
        end case;
    end process;

    -- the base value of the X/Y/Z/SP register as per I_AMOD.
    --
    process(I_AMOD(2 downto 0), I_IMM, R_SP, R_R26, R_R28, R_R30)
    begin
        case I_AMOD(2 downto 0) is
            when AS_SP  => L_BASE <= R_SP;
            when AS_Z   => L_BASE <= R_R30;
            when AS_Y   => L_BASE <= R_R28;
            when AS_X   => L_BASE <= R_R26;
            when AS_IMM => L_BASE <= I_IMM;
            when others => L_BASE <= X"0000";
        end case;
    end process;

    -- the value of the X/Y/Z/SP register after a potential PRE-inc/decrement
    -- (by 1 or 2) and POST-inc/decrement (by 1 or 2).
    --
    process(I_AMOD, I_IMM)
    begin
        case I_AMOD is
            when AMOD_Xq | AMOD_Yq | AMOD_Zq  =>
                L_PRE <= I_IMM;      L_POST <= X"0000";

            when AMOD_Xi | AMOD_Yi | AMOD_Zi  =>
                L_PRE <= X"0000";    L_POST <= X"0001";

            when AMOD_dX  | AMOD_dY  | AMOD_dZ  =>
                L_PRE <= X"FFFF";    L_POST <= X"FFFF";

            when AMOD_iSP =>
                L_PRE <= X"0001";    L_POST <= X"0001";

            when AMOD_iiSP=>
                L_PRE <= X"0001";    L_POST <= X"0002";

            when AMOD_SPd =>
                L_PRE <= X"0000";    L_POST <= X"FFFF";

            when AMOD_SPdd=>
                L_PRE <= X"FFFF";    L_POST <= X"FFFE";

            when others =>
                L_PRE <= X"0000";    L_POST <= X"0000";
        end case;
    end process;

    L_XYZS <= L_BASE + L_POST;
    L_ADR  <= L_BASE + L_PRE;
    
    L_WE_A <= I_WE_M when (L_ADR(15 downto 5) = "00000000000") else '0';
    L_WE_SR    <= I_WE_M when (L_ADR = X"005F") else '0';
    L_WE_SP_AMOD <= I_WE_XYZS when (I_AMOD(2 downto 0) = AS_SP) else '0';
    L_WE_SP(1) <= I_WE_M when (L_ADR = X"005E") else L_WE_SP_AMOD;
    L_WE_SP(0) <= I_WE_M when (L_ADR = X"005D") else L_WE_SP_AMOD;

    L_DX  <= L_XYZS when (L_WE_MISC(26) = '1')        else I_DIN;
    L_DY  <= L_XYZS when (L_WE_MISC(28) = '1')        else I_DIN;
    L_DZ  <= L_XYZS when (L_WE_MISC(30) = '1')        else I_DIN;
    L_DSP <= L_XYZS when (I_AMOD(3 downto 0) = AM_WS) else I_DIN;
    
    -- the WE signals for the differen registers.
    --
    -- case 1: write to an 8-bit register addressed by DDDDD.
    --
    -- I_WE_D(0) = '1' and I_DDDDD matches,
    --
    L_WE_D( 0) <= I_WE_D(0) when (I_DDDDD = "00000") else '0';
    L_WE_D( 1) <= I_WE_D(0) when (I_DDDDD = "00001") else '0';
    L_WE_D( 2) <= I_WE_D(0) when (I_DDDDD = "00010") else '0';
    L_WE_D( 3) <= I_WE_D(0) when (I_DDDDD = "00011") else '0';
    L_WE_D( 4) <= I_WE_D(0) when (I_DDDDD = "00100") else '0';
    L_WE_D( 5) <= I_WE_D(0) when (I_DDDDD = "00101") else '0';
    L_WE_D( 6) <= I_WE_D(0) when (I_DDDDD = "00110") else '0';
    L_WE_D( 7) <= I_WE_D(0) when (I_DDDDD = "00111") else '0';
    L_WE_D( 8) <= I_WE_D(0) when (I_DDDDD = "01000") else '0';
    L_WE_D( 9) <= I_WE_D(0) when (I_DDDDD = "01001") else '0';
    L_WE_D(10) <= I_WE_D(0) when (I_DDDDD = "01010") else '0';
    L_WE_D(11) <= I_WE_D(0) when (I_DDDDD = "01011") else '0';
    L_WE_D(12) <= I_WE_D(0) when (I_DDDDD = "01100") else '0';
    L_WE_D(13) <= I_WE_D(0) when (I_DDDDD = "01101") else '0';
    L_WE_D(14) <= I_WE_D(0) when (I_DDDDD = "01110") else '0';
    L_WE_D(15) <= I_WE_D(0) when (I_DDDDD = "01111") else '0';
    L_WE_D(16) <= I_WE_D(0) when (I_DDDDD = "10000") else '0';
    L_WE_D(17) <= I_WE_D(0) when (I_DDDDD = "10001") else '0';
    L_WE_D(18) <= I_WE_D(0) when (I_DDDDD = "10010") else '0';
    L_WE_D(19) <= I_WE_D(0) when (I_DDDDD = "10011") else '0';
    L_WE_D(20) <= I_WE_D(0) when (I_DDDDD = "10100") else '0';
    L_WE_D(21) <= I_WE_D(0) when (I_DDDDD = "10101") else '0';
    L_WE_D(22) <= I_WE_D(0) when (I_DDDDD = "10110") else '0';
    L_WE_D(23) <= I_WE_D(0) when (I_DDDDD = "10111") else '0';
    L_WE_D(24) <= I_WE_D(0) when (I_DDDDD = "11000") else '0';
    L_WE_D(25) <= I_WE_D(0) when (I_DDDDD = "11001") else '0';
    L_WE_D(26) <= I_WE_D(0) when (I_DDDDD = "11010") else '0';
    L_WE_D(27) <= I_WE_D(0) when (I_DDDDD = "11011") else '0';
    L_WE_D(28) <= I_WE_D(0) when (I_DDDDD = "11100") else '0';
    L_WE_D(29) <= I_WE_D(0) when (I_DDDDD = "11101") else '0';
    L_WE_D(30) <= I_WE_D(0) when (I_DDDDD = "11110") else '0';
    L_WE_D(31) <= I_WE_D(0) when (I_DDDDD = "11111") else '0';

    --
    -- case 2: write to a 16-bit register pair addressed by DDDD.
    --
    -- I_WE_DD(1) = '1' and L_DDDD matches,
    --
    L_DDDD <= I_DDDDD(4 downto 1);
    L_WE_D2 <= I_WE_D(1) & I_WE_D(1);
    L_WE_DD( 1 downto  0) <= L_WE_D2 when (L_DDDD = "0000") else "00";
    L_WE_DD( 3 downto  2) <= L_WE_D2 when (L_DDDD = "0001") else "00";
    L_WE_DD( 5 downto  4) <= L_WE_D2 when (L_DDDD = "0010") else "00";
    L_WE_DD( 7 downto  6) <= L_WE_D2 when (L_DDDD = "0011") else "00";
    L_WE_DD( 9 downto  8) <= L_WE_D2 when (L_DDDD = "0100") else "00";
    L_WE_DD(11 downto 10) <= L_WE_D2 when (L_DDDD = "0101") else "00";
    L_WE_DD(13 downto 12) <= L_WE_D2 when (L_DDDD = "0110") else "00";
    L_WE_DD(15 downto 14) <= L_WE_D2 when (L_DDDD = "0111") else "00";
    L_WE_DD(17 downto 16) <= L_WE_D2 when (L_DDDD = "1000") else "00";
    L_WE_DD(19 downto 18) <= L_WE_D2 when (L_DDDD = "1001") else "00";
    L_WE_DD(21 downto 20) <= L_WE_D2 when (L_DDDD = "1010") else "00";
    L_WE_DD(23 downto 22) <= L_WE_D2 when (L_DDDD = "1011") else "00";
    L_WE_DD(25 downto 24) <= L_WE_D2 when (L_DDDD = "1100") else "00";
    L_WE_DD(27 downto 26) <= L_WE_D2 when (L_DDDD = "1101") else "00";
    L_WE_DD(29 downto 28) <= L_WE_D2 when (L_DDDD = "1110") else "00";
    L_WE_DD(31 downto 30) <= L_WE_D2 when (L_DDDD = "1111") else "00";

    --
    -- case 3: write to an 8-bit register pair addressed by an I/O address.
    --
    -- L_WE_A = '1' and L_ADR(4 downto 0) matches
    --
    L_WE_IO( 0) <= L_WE_A when (L_ADR(4 downto 0) = "00000") else '0';
    L_WE_IO( 1) <= L_WE_A when (L_ADR(4 downto 0) = "00001") else '0';
    L_WE_IO( 2) <= L_WE_A when (L_ADR(4 downto 0) = "00010") else '0';
    L_WE_IO( 3) <= L_WE_A when (L_ADR(4 downto 0) = "00011") else '0';
    L_WE_IO( 4) <= L_WE_A when (L_ADR(4 downto 0) = "00100") else '0';
    L_WE_IO( 5) <= L_WE_A when (L_ADR(4 downto 0) = "00101") else '0';
    L_WE_IO( 6) <= L_WE_A when (L_ADR(4 downto 0) = "00110") else '0';
    L_WE_IO( 7) <= L_WE_A when (L_ADR(4 downto 0) = "00111") else '0';
    L_WE_IO( 8) <= L_WE_A when (L_ADR(4 downto 0) = "01000") else '0';
    L_WE_IO( 9) <= L_WE_A when (L_ADR(4 downto 0) = "01001") else '0';
    L_WE_IO(10) <= L_WE_A when (L_ADR(4 downto 0) = "01010") else '0';
    L_WE_IO(11) <= L_WE_A when (L_ADR(4 downto 0) = "01011") else '0';
    L_WE_IO(12) <= L_WE_A when (L_ADR(4 downto 0) = "01100") else '0';
    L_WE_IO(13) <= L_WE_A when (L_ADR(4 downto 0) = "01101") else '0';
    L_WE_IO(14) <= L_WE_A when (L_ADR(4 downto 0) = "01110") else '0';
    L_WE_IO(15) <= L_WE_A when (L_ADR(4 downto 0) = "01111") else '0';
    L_WE_IO(16) <= L_WE_A when (L_ADR(4 downto 0) = "10000") else '0';
    L_WE_IO(17) <= L_WE_A when (L_ADR(4 downto 0) = "10001") else '0';
    L_WE_IO(18) <= L_WE_A when (L_ADR(4 downto 0) = "10010") else '0';
    L_WE_IO(19) <= L_WE_A when (L_ADR(4 downto 0) = "10011") else '0';
    L_WE_IO(20) <= L_WE_A when (L_ADR(4 downto 0) = "10100") else '0';
    L_WE_IO(21) <= L_WE_A when (L_ADR(4 downto 0) = "10101") else '0';
    L_WE_IO(22) <= L_WE_A when (L_ADR(4 downto 0) = "10110") else '0';
    L_WE_IO(23) <= L_WE_A when (L_ADR(4 downto 0) = "10111") else '0';
    L_WE_IO(24) <= L_WE_A when (L_ADR(4 downto 0) = "11000") else '0';
    L_WE_IO(25) <= L_WE_A when (L_ADR(4 downto 0) = "11001") else '0';
    L_WE_IO(26) <= L_WE_A when (L_ADR(4 downto 0) = "11010") else '0';
    L_WE_IO(27) <= L_WE_A when (L_ADR(4 downto 0) = "11011") else '0';
    L_WE_IO(28) <= L_WE_A when (L_ADR(4 downto 0) = "11100") else '0';
    L_WE_IO(29) <= L_WE_A when (L_ADR(4 downto 0) = "11101") else '0';
    L_WE_IO(30) <= L_WE_A when (L_ADR(4 downto 0) = "11110") else '0';
    L_WE_IO(31) <= L_WE_A when (L_ADR(4 downto 0) = "11111") else '0';

    -- case 4 special cases.
    -- 4a. WE_01 for register pair 0/1 (multiplication opcode).
    -- 4b. I_WE_XYZS for X (register pairs 26/27) and I_AMOD matches
    -- 4c. I_WE_XYZS for Y (register pairs 28/29) and I_AMOD matches
    -- 4d. I_WE_XYZS for Z (register pairs 30/31) and I_AMOD matches
    --
    L_WE_X <= I_WE_XYZS when (I_AMOD(3 downto 0) = AM_WX) else '0';
    L_WE_Y <= I_WE_XYZS when (I_AMOD(3 downto 0) = AM_WY) else '0';
    L_WE_Z <= I_WE_XYZS when (I_AMOD(3 downto 0) = AM_WZ) else '0';
    L_WE_MISC <= L_WE_Z & L_WE_Z &      -- -Z and Z+ address modes  r30
                 L_WE_Y & L_WE_Y &      -- -Y and Y+ address modes  r28
                 L_WE_X & L_WE_X &      -- -X and X+ address modes  r26
                 X"000000" &            -- never                    r24 - r02
                 I_WE_01 & I_WE_01;     -- multiplication result    r00

    L_WE <= L_WE_D or L_WE_DD or L_WE_IO or L_WE_MISC;

    Q_S <= L_S( 7 downto 0) when (L_ADR(0) = '0') else L_S(15 downto 8);
    Q_FLAGS <= S_FLAGS;
    Q_Z <= R_R30;
    Q_ADR <= L_ADR;

end Behavioral;

