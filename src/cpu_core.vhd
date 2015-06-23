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
-- Module Name:    cpu_core - Behavioral 
-- Create Date:    13:51:24 11/07/2009 
-- Description:    the instruction set implementation of a CPU.
--
-------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cpu_core is
    port (  I_CLK       : in  std_logic;
            I_CLR       : in  std_logic;
            I_INTVEC    : in  std_logic_vector( 5 downto 0);
            I_DIN       : in  std_logic_vector( 7 downto 0);

            Q_OPC       : out std_logic_vector(15 downto 0);
            Q_PC        : out std_logic_vector(15 downto 0);
            Q_DOUT      : out std_logic_vector( 7 downto 0);
            Q_ADR_IO    : out std_logic_vector( 7 downto 0);
            Q_RD_IO     : out std_logic;
            Q_WE_IO     : out std_logic);
end cpu_core;

architecture Behavioral of cpu_core is

component opc_fetch
    port(   I_CLK       : in  std_logic;

            I_CLR       : in  std_logic;
            I_INTVEC    : in  std_logic_vector( 5 downto 0);
            I_NEW_PC    : in  std_logic_vector(15 downto 0);
            I_LOAD_PC   : in  std_logic;
            I_PM_ADR    : in  std_logic_vector(11 downto 0);
            I_SKIP      : in  std_logic;

            Q_OPC       : out std_logic_vector(31 downto 0);
            Q_PC        : out std_logic_vector(15 downto 0);
            Q_PM_DOUT   : out std_logic_vector( 7 downto 0);
            Q_T0        : out std_logic);
end component;

signal F_PC             : std_logic_vector(15 downto 0);
signal F_OPC            : std_logic_vector(31 downto 0);
signal F_PM_DOUT        : std_logic_vector( 7 downto 0);
signal F_T0             : std_logic;

component opc_deco is
    port (  I_CLK       : in  std_logic;

            I_OPC       : in  std_logic_vector(31 downto 0);
            I_PC        : in  std_logic_vector(15 downto 0);
            I_T0        : in  std_logic;

            Q_ALU_OP    : out std_logic_vector( 4 downto 0);
            Q_AMOD      : out std_logic_vector( 5 downto 0);
            Q_BIT       : out std_logic_vector( 3 downto 0);
            Q_DDDDD     : out std_logic_vector( 4 downto 0);
            Q_IMM       : out std_logic_vector(15 downto 0);
            Q_JADR      : out std_logic_vector(15 downto 0);
            Q_OPC       : out std_logic_vector(15 downto 0);
            Q_PC        : out std_logic_vector(15 downto 0);
            Q_PC_OP     : out std_logic_vector( 2 downto 0);
            Q_PMS       : out std_logic;  -- program memory select
            Q_RD_M      : out std_logic;
            Q_RRRRR     : out std_logic_vector( 4 downto 0);
            Q_RSEL      : out std_logic_vector( 1 downto 0);
            Q_WE_01     : out std_logic;
            Q_WE_D      : out std_logic_vector( 1 downto 0);
            Q_WE_F      : out std_logic;
            Q_WE_M      : out std_logic_vector( 1 downto 0);
            Q_WE_XYZS   : out std_logic);
end component;

signal D_ALU_OP         : std_logic_vector( 4 downto 0);
signal D_AMOD           : std_logic_vector( 5 downto 0);
signal D_BIT            : std_logic_vector( 3 downto 0);
signal D_DDDDD          : std_logic_vector( 4 downto 0);
signal D_IMM            : std_logic_vector(15 downto 0);
signal D_JADR           : std_logic_vector(15 downto 0);
signal D_OPC            : std_logic_vector(15 downto 0);
signal D_PC             : std_logic_vector(15 downto 0);
signal D_PC_OP          : std_logic_vector(2 downto 0);
signal D_PMS            : std_logic;
signal D_RD_M           : std_logic;
signal D_RRRRR          : std_logic_vector( 4 downto 0);
signal D_RSEL           : std_logic_vector( 1 downto 0);
signal D_WE_01          : std_logic;
signal D_WE_D           : std_logic_vector( 1 downto 0);
signal D_WE_F           : std_logic;
signal D_WE_M           : std_logic_vector( 1 downto 0);
signal D_WE_XYZS        : std_logic;

component data_path
    port(   I_CLK       : in    std_logic;

            I_ALU_OP    : in  std_logic_vector( 4 downto 0);
            I_AMOD      : in  std_logic_vector( 5 downto 0);
            I_BIT       : in  std_logic_vector( 3 downto 0);
            I_DDDDD     : in  std_logic_vector( 4 downto 0);
            I_DIN       : in  std_logic_vector( 7 downto 0);
            I_IMM       : in  std_logic_vector(15 downto 0);
            I_JADR      : in  std_logic_vector(15 downto 0);
            I_PC_OP     : in  std_logic_vector( 2 downto 0);
            I_OPC       : in  std_logic_vector(15 downto 0);
            I_PC        : in  std_logic_vector(15 downto 0);
            I_PMS       : in  std_logic;  -- program memory select
            I_RD_M      : in  std_logic;
            I_RRRRR     : in  std_logic_vector( 4 downto 0);
            I_RSEL      : in  std_logic_vector( 1 downto 0);
            I_WE_01     : in  std_logic;
            I_WE_D      : in  std_logic_vector( 1 downto 0);
            I_WE_F      : in  std_logic;
            I_WE_M      : in  std_logic_vector( 1 downto 0);
            I_WE_XYZS   : in  std_logic;
 
            Q_ADR       : out std_logic_vector(15 downto 0);
            Q_DOUT      : out std_logic_vector( 7 downto 0);
            Q_INT_ENA   : out std_logic;
            Q_LOAD_PC   : out std_logic;
            Q_NEW_PC    : out std_logic_vector(15 downto 0);
            Q_OPC       : out std_logic_vector(15 downto 0);
            Q_PC        : out std_logic_vector(15 downto 0);
            Q_RD_IO     : out std_logic;
            Q_SKIP      : out std_logic;
            Q_WE_IO     : out std_logic);
end component;

signal R_INT_ENA        : std_logic;
signal R_NEW_PC         : std_logic_vector(15 downto 0);
signal R_LOAD_PC        : std_logic;
signal R_SKIP           : std_logic;
signal R_ADR            : std_logic_vector(15 downto 0);

-- local signals
--
signal L_DIN            : std_logic_vector( 7 downto 0);
signal L_INTVEC_5       : std_logic;

begin

    opcf : opc_fetch
    port map(   I_CLK       => I_CLK,

                I_CLR       => I_CLR,
                I_INTVEC(5) => L_INTVEC_5,
                I_INTVEC(4 downto 0) => I_INTVEC(4 downto 0),
                I_LOAD_PC   => R_LOAD_PC,
                I_NEW_PC    => R_NEW_PC,
                I_PM_ADR    => R_ADR(11 downto 0),
                I_SKIP      => R_SKIP,

                Q_PC        => F_PC,
                Q_OPC       => F_OPC,
                Q_T0        => F_T0,
                Q_PM_DOUT   => F_PM_DOUT);
 
    odec : opc_deco
    port map(   I_CLK       => I_CLK,

                I_OPC       => F_OPC,
                I_PC        => F_PC,
                I_T0        => F_T0,

                Q_ALU_OP    => D_ALU_OP,
                Q_AMOD      => D_AMOD,
                Q_BIT       => D_BIT,
                Q_DDDDD     => D_DDDDD,
                Q_IMM       => D_IMM,
                Q_JADR      => D_JADR,
                Q_OPC       => D_OPC,
                Q_PC        => D_PC,
                Q_PC_OP     => D_PC_OP,
                Q_PMS       => D_PMS,
                Q_RD_M      => D_RD_M,
                Q_RRRRR     => D_RRRRR,
                Q_RSEL      => D_RSEL,
                Q_WE_01     => D_WE_01,
                Q_WE_D      => D_WE_D,
                Q_WE_F      => D_WE_F,
                Q_WE_M      => D_WE_M,
                Q_WE_XYZS   => D_WE_XYZS);

    dpath : data_path
    port map(   I_CLK       => I_CLK,

                I_ALU_OP    => D_ALU_OP,
                I_AMOD      => D_AMOD,
                I_BIT       => D_BIT,
                I_DDDDD     => D_DDDDD,
                I_DIN       => L_DIN,
                I_IMM       => D_IMM,
                I_JADR      => D_JADR,
                I_OPC       => D_OPC,
                I_PC        => D_PC,
                I_PC_OP     => D_PC_OP,
                I_PMS       => D_PMS,
                I_RD_M      => D_RD_M,
                I_RRRRR     => D_RRRRR,
                I_RSEL      => D_RSEL,
                I_WE_01     => D_WE_01,
                I_WE_D      => D_WE_D,
                I_WE_F      => D_WE_F,
                I_WE_M      => D_WE_M,
                I_WE_XYZS   => D_WE_XYZS,

                Q_ADR       => R_ADR,
                Q_DOUT      => Q_DOUT,
                Q_INT_ENA   => R_INT_ENA,
                Q_NEW_PC    => R_NEW_PC,
                Q_OPC       => Q_OPC,
                Q_PC        => Q_PC,
                Q_LOAD_PC   => R_LOAD_PC,
                Q_RD_IO     => Q_RD_IO,
                Q_SKIP      => R_SKIP,
                Q_WE_IO     => Q_WE_IO);

    L_DIN <= F_PM_DOUT when (D_PMS = '1') else I_DIN(7 downto 0);
    L_INTVEC_5 <= I_INTVEC(5) and R_INT_ENA;
    Q_ADR_IO <= R_ADR(7 downto 0);

end Behavioral;

