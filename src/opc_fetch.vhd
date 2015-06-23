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
-- Module Name:    opc_fetch - Behavioral 
-- Create Date:    13:00:44 10/30/2009 
-- Description:    the opcode fetch stage of a CPU.
--
-------------------------------------------------------------------------------
--
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

entity opc_fetch is
    port (  I_CLK       : in  std_logic;

            I_CLR       : in  std_logic;
            I_INTVEC    : in  std_logic_vector( 5 downto 0);
            I_LOAD_PC   : in  std_logic;
            I_NEW_PC    : in  std_logic_vector(15 downto 0);
            I_PM_ADR    : in  std_logic_vector(11 downto 0);
            I_SKIP      : in  std_logic;

            Q_OPC       : out std_logic_vector(31 downto 0);
            Q_PC        : out std_logic_vector(15 downto 0);
            Q_PM_DOUT   : out std_logic_vector( 7 downto 0);
            Q_T0        : out std_logic);
end opc_fetch;

architecture Behavioral of opc_fetch is

component prog_mem
    port (  I_CLK       : in  std_logic;

            I_WAIT      : in  std_logic;
            I_PC        : in  std_logic_vector (15 downto 0);
            I_PM_ADR    : in  std_logic_vector (11 downto 0);

            Q_OPC       : out std_logic_vector (31 downto 0);
            Q_PC        : out std_logic_vector (15 downto 0);
            Q_PM_DOUT   : out std_logic_vector ( 7 downto 0));
end component;

signal P_OPC            : std_logic_vector(31 downto 0);
signal P_PC             : std_logic_vector(15 downto 0);

signal L_INVALIDATE     : std_logic;
signal L_LONG_OP        : std_logic;
signal L_NEXT_PC        : std_logic_vector(15 downto 0);
signal L_OPC_1_0123     : std_logic;
signal L_OPC_8A_014589CD: std_logic;
signal L_OPC_9_01       : std_logic;
signal L_OPC_9_5_01_8   : std_logic;
signal L_OPC_9_5_CD_8   : std_logic;
signal L_OPC_9_9B       : std_logic;
signal L_OPC_F_CDEF     : std_logic;
signal L_PC             : std_logic_vector(15 downto 0);
signal L_T0             : std_logic;
signal L_WAIT           : std_logic;

begin

    pmem : prog_mem
    port map(   I_CLK       => I_CLK,

                I_WAIT      => L_WAIT,
                I_PC        => L_NEXT_PC,
                I_PM_ADR    => I_PM_ADR,

                Q_OPC       => P_OPC,
                Q_PC        => P_PC,
                Q_PM_DOUT   => Q_PM_DOUT);

   lpc: process(I_CLK)
    begin
        if (rising_edge(I_CLK)) then
            L_PC <= L_NEXT_PC;
            L_T0 <= not L_WAIT;
        end if;
    end process;

    L_NEXT_PC <= X"0000"        when (I_CLR     = '1')
            else L_PC           when (L_WAIT    = '1')
            else I_NEW_PC       when (I_LOAD_PC = '1')
            else L_PC + X"0002" when (L_LONG_OP = '1')
            else L_PC + X"0001";

    -- Two word opcodes:
    --
    --        9       3210
    -- 1001 000d dddd 0000 kkkk kkkk kkkk kkkk - LDS
    -- 1001 001d dddd 0000 kkkk kkkk kkkk kkkk - SDS
    -- 1001 010k kkkk 110k kkkk kkkk kkkk kkkk - JMP
    -- 1001 010k kkkk 111k kkkk kkkk kkkk kkkk - CALL
    --
    L_LONG_OP <= '1' when (((P_OPC(15 downto  9) = "1001010") and
                            (P_OPC( 3 downto  2) = "11"))       -- JMP, CALL
                       or  ((P_OPC(15 downto 10) = "100100") and
                            (P_OPC( 3 downto  0) = "0000")))    -- LDS, STS
            else '0';

    ----------------------------------
    -- Two cycle opcodes...         --
    ----------------------------------

    -------------------------------------------------
    -- 0001 00rd dddd rrrr - CPSE
    --
    L_OPC_1_0123      <= '1' when  (P_OPC(15 downto 10) = "000100" )
                    else '0';

    -------------------------------------------------
    -- 10q0 qq0d dddd 1qqq - LDD (Y + q)
    -- 10q0 qq0d dddd 0qqq - LDD (Z + q)
    --
    L_OPC_8A_014589CD <= '1' when ((P_OPC(15 downto 14) = "10" )
                              and  (P_OPC(12) = '0')
                              and  (P_OPC( 9) = '0'))
                    else '0';

    -------------------------------------------------
    -- 1001 000d dddd .... - LDS, LD, LPM (ii/iii), ELPM, POP
    --
    L_OPC_9_01        <= '1' when ( P_OPC(15 downto  9) = "1001000")
                    else '0';

    -------------------------------------------------
    -- 1001 0101 0000 1000 - RET
    -- 1001 0101 0001 1000 - RETI
    --
    L_OPC_9_5_01_8    <= '1' when ((P_OPC(15 downto  5) = "10010101000")
                              and  (P_OPC( 3 downto  0) = "1000"))
                    else '0';

    -------------------------------------------------
    -- 1001 0101 1100 1000 - LPM (i)
    -- 1001 0101 1101 1000 - ELPM
    --
    L_OPC_9_5_CD_8    <= '1' when ((P_OPC(15 downto  5) = "10010101110")
                              and  (P_OPC( 3 downto  0) = "1000"))
                    else '0';

    -------------------------------------------------
    -- 1001 1001 AAAA Abbb - SBIC
    -- 1001 1011 AAAA Abbb - SBIS
    --
    L_OPC_9_9B        <= '1' when ((P_OPC(15 downto 10) = "100110")
                              and  (P_OPC(8) = '1'))
                    else '0';

    -------------------------------------------------
    -- 1111 110r rrrr 0bbb - SBRC
    -- 1111 111r rrrr 0bbb - SBRS
    --
    L_OPC_F_CDEF      <= '1' when ( P_OPC(15 downto  10) = "111111")
                    else '0';

    L_WAIT <=  L_T0 and (not L_INVALIDATE)
                    and (not I_INTVEC(5))
                    and (L_OPC_1_0123      or       -- CPSE
                         L_OPC_8A_014589CD or       -- LDD
                         L_OPC_9_01        or       -- LDS, LD, LPM, POP
                         L_OPC_9_5_01_8    or       -- RET, RETI
                         L_OPC_9_5_CD_8    or       -- LPM, ELPM
                         L_OPC_9_9B        or       -- SBIC, SBIS
                         L_OPC_F_CDEF);             -- SBRC, SBRS

    L_INVALIDATE <= I_CLR or I_SKIP;

    Q_OPC <= X"00000000" when (L_INVALIDATE = '1')
        else P_OPC       when (I_INTVEC(5) = '0')
        else (X"000000" & "00" & I_INTVEC);     -- "interrupt opcode"

    Q_PC <= P_PC;
    Q_T0 <= L_T0;

end Behavioral;

