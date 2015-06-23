-----------------------------------------------------------------------
----                                                               ----
---- Montgomery modular multiplier and exponentiator               ----
----                                                               ----
---- This file is part of the Montgomery modular multiplier        ----
---- and exponentiator project                                     ----
---- http://opencores.org/project,mod_mult_exp                     ----
----                                                               ----
---- Description:                                                  ----
----   Montgomery modular exponentiator main module. It combines   ----
----   all subomponents. It takes four numbers as the input:       ----
----   base, power, modulus and Montgomery residuum                ----
----   (2^(2*word_length) mod N) and results the modular           ----
----   exponentiation A^B mod M.                                   ----
----   In fact input data are read through one input controlled by ----
----   the ctrl input.                                             ----
---- To Do:                                                        ----
----                                                               ----
---- Author(s):                                                    ----
---- - Krzysztof Gajewski, gajos@opencores.org                     ----
----                       k.gajewski@gmail.com                    ----
----                                                               ----
-----------------------------------------------------------------------
----                                                               ----
---- Copyright (C) 2014 Authors and OPENCORES.ORG                  ----
----                                                               ----
---- This source file may be used and distributed without          ----
---- restriction provided that this copyright statement is not     ----
---- removed from the file and that any derivative work contains   ----
---- the original copyright notice and the associated disclaimer.  ----
----                                                               ----
---- This source file is free software; you can redistribute it    ----
---- and-or modify it under the terms of the GNU Lesser General    ----
---- Public License as published by the Free Software Foundation;  ----
---- either version 2.1 of the License, or (at your option) any    ----
---- later version.                                                ----
----                                                               ----
---- This source is distributed in the hope that it will be        ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied    ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR       ----
---- PURPOSE. See the GNU Lesser General Public License for more   ----
---- details.                                                      ----
----                                                               ----
---- You should have received a copy of the GNU Lesser General     ----
---- Public License along with this source; if not, download it    ----
---- from http://www.opencores.org/lgpl.shtml                      ----
----                                                               ----
-----------------------------------------------------------------------
library IEEE;
use work.properties.ALL;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ModExp is
    generic (
        word_size   : integer := WORD_LENGTH;
        word_binary : integer := WORD_INTEGER
    );
    Port ( 
        input         : in  STD_LOGIC_VECTOR(word_size - 1 downto 0);
        ctrl          : in  STD_LOGIC_VECTOR(2 downto 0);
        clk           : in  STD_LOGIC;
        reset         : in  STD_LOGIC;
        data_in_ready : in  STD_LOGIC;
        ready         : out STD_LOGIC;
        output        : out STD_LOGIC_VECTOR(word_size - 1 downto 0)
    );
end ModExp;

architecture Behavioral of ModExp is

-- Montgomery modular multiplier component
component ModularMultiplierIterative is
    generic (
        word_size : integer := WORD_LENGTH
    );
    port (
        A       : in  STD_LOGIC_VECTOR(word_size - 1 downto 0);     -- multiplicand
        B       : in  STD_LOGIC_VECTOR(word_size - 1 downto 0);     -- multiplier
        M       : in  STD_LOGIC_VECTOR(word_size - 1 downto 0);     -- modulus
        start   : in  STD_LOGIC;
        product : out STD_LOGIC_VECTOR(word_size - 1 downto 0); -- product
        ready   : out STD_LOGIC;
        clk     : in  STD_LOGIC
    );
end component ModularMultiplierIterative;

-- Block memory component generated through ISE
-- It is used like multiple cell register
COMPONENT blockMemory
    PORT (
        clka  : in  STD_LOGIC;
        rsta  : in  STD_LOGIC;
        wea   : in  STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : in  STD_LOGIC_VECTOR(3 DOWNTO 0);
        dina  : in  STD_LOGIC_VECTOR(word_size - 1 DOWNTO 0);
        douta : out STD_LOGIC_VECTOR(word_size - 1 DOWNTO 0)
    );
END COMPONENT;

-- Register
component Reg is
    generic(
        word_size : integer := WORD_LENGTH
    );
    port(
        input  : in  STD_LOGIC_VECTOR(word_size - 1 downto 0);
        output : out STD_LOGIC_VECTOR(word_size - 1 downto 0);
        enable : in  STD_LOGIC;
        clk    : in  STD_LOGIC;
        reset  : in  STD_LOGIC
    );
end component Reg;

-- Multiplexer
component MontMult4inMux is
    generic (
        word_size : integer := WORD_LENGTH - 1
    );
    port ( 
        ctrl   : in  STD_LOGIC_VECTOR(1 downto 0);
        zero   : in  STD_LOGIC_VECTOR(word_size downto 0);
        M      : in  STD_LOGIC_VECTOR(word_size downto 0);
        Y      : in  STD_LOGIC_VECTOR(word_size downto 0);
        YplusM : in  STD_LOGIC_VECTOR(word_size downto 0);
        output : out STD_LOGIC_VECTOR(word_size downto 0)
    );
end component MontMult4inMux;

-- State machine
component ModExpSM is
    generic(
        word_size : integer := WORD_LENGTH;
        word_binary : integer := WORD_INTEGER
    );
    port (
        data_in_ready  : in  STD_LOGIC;
        clk            : in  STD_LOGIC;
        exp_ctrl       : in  STD_LOGIC_VECTOR(2 downto 0);
        reset          : in  STD_LOGIC;
        in_mux_control : out STD_LOGIC_VECTOR(1 downto 0);
        -- finalizer end status
        ready          : out STD_LOGIC;
        -- control for multiplier
        modMultStart   : out STD_LOGIC;
        modMultReady   : in  STD_LOGIC;
        -- control for memory and registers
        addr_dataA     : out STD_LOGIC_VECTOR(3 downto 0);
        addr_dataB     : out STD_LOGIC_VECTOR(3 downto 0);
        regData_EnA    : out STD_LOGIC_VECTOR(0 downto 0);
        regData_EnB    : out STD_LOGIC_VECTOR(0 downto 0);
        regData_EnC    : out STD_LOGIC;
        regData_EnExponent   : out STD_LOGIC;
        ExponentData         : in  STD_LOGIC_VECTOR(word_size - 1 downto 0);
        memory_reset   : out STD_LOGIC
    );
end component ModExpSM;

-- data registers signals
signal addr_dataA : STD_LOGIC_VECTOR(3 downto 0);
signal addr_dataB : STD_LOGIC_VECTOR(3 downto 0);

signal memDataLoadA  : STD_LOGIC_VECTOR(0 downto 0);
signal memDataLoadB  : STD_LOGIC_VECTOR(0 downto 0);
signal memDataLoadC  : STD_LOGIC;
signal memDataLoadExponent : STD_LOGIC;

signal memDataA  : STD_LOGIC_VECTOR(word_size - 1 downto 0);
signal memDataB  : STD_LOGIC_VECTOR(word_size - 1 downto 0);
signal memDataC  : STD_LOGIC_VECTOR(word_size - 1 downto 0);
signal memDataExponent : STD_LOGIC_VECTOR(word_size - 1 downto 0);
signal memoryIn  : STD_LOGIC_VECTOR(word_size - 1 downto 0);

signal in_mux_control : STD_LOGIC_VECTOR(1 downto 0);

-- signal for multiplier
signal multStart       : STD_LOGIC;
signal multReady       : STD_LOGIC;
signal modMultToBuffer : STD_LOGIC_VECTOR(word_size - 1 downto 0);

signal zero : STD_LOGIC_VECTOR(word_size - 1 downto 0) := (others => '0');
signal one  : STD_LOGIC_VECTOR(word_size - 1 downto 0) := (0 => '1', others => '0');

signal memory_reset : STD_LOGIC;

begin
    -- connections between components
    zero <= (others => '0');
    one <=  (0 => '1', others => '0');

    -- Montgomery modular multiplier component
    modMult : ModularMultiplierIterative 
    port map (
        A       => memDataA, 
        B       => memDataB, 
        M       => memDataC, 
        start   => multStart,
        product => modMultToBuffer, 
        ready   => multReady, 
        clk     => clk
    );

    -- Multiplexer
    mux : MontMult4inMux 
    port map ( 
        ctrl   => in_mux_control,
        zero   => zero,
        M      => one,
        Y      => modMultToBuffer,
        YplusM => input,
        output => memoryIn
    );
	
    -- Block memory for the first input of the multiplier
    memoryA : blockMemory 
    port map (
        clka  => clk, 
        rsta  => memory_reset, 
        wea   => memDataLoadA, 
        addra => addr_dataA, 
        dina  => memoryIn, 
        douta => memDataA
    );

    -- Block memory for the second input of the multiplier
    memoryB : blockMemory 
    port map (
        clka  => clk, 
        rsta  => memory_reset, 
        wea   => memDataLoadB, 
        addra => addr_dataB, 
        dina  => memoryIn, 
        douta => memDataB
    );

    -- Register for the modulus for the multiplier
    memoryModulus : Reg 
    port map (
        input  => memoryIn, 
        output => memDataC, 
        enable => memDataLoadC, 
        clk    => clk, 
        reset  => memory_reset
    );

    -- Register for the exponent - it feeds also the state machine for the control of the exponentiation process
    memoryExponent : Reg 
    port map (
        input  => memoryIn, 
        output => memDataExponent, 
        enable => memDataLoadExponent, 
        clk    => clk, 
        reset  => memory_reset
    );

    -- State machine of the Montgomery modular exponentiator
    stateMachine : ModExpSM 
    port map( 
        data_in_ready  => data_in_ready, 
        clk            => clk, 
        exp_ctrl       => ctrl, 
        reset          => reset, 
        in_mux_control => in_mux_control, 
        ready          => ready, 
        modMultStart   => multStart, 
        modMultReady   => multReady, 
        addr_dataA     => addr_dataA, 
        addr_dataB     => addr_dataB, 
        regData_EnA    => memDataLoadA, 
        regData_EnB    => memDataLoadB, 
        regData_EnC    => memDataLoadC,
        regData_EnExponent   => memDataLoadExponent,
        ExponentData         => memDataExponent,
        memory_reset   => memory_reset
    );

    output <= memDataA;

end Behavioral;