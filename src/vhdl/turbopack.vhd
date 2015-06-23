----------------------------------------------------------------------
----                                                              ----
----  turbopack.vhd                                               ----
----                                                              ----
----  This file is part of the turbo decoder IP core project      ----
----  http://www.opencores.org/projects/turbocodes/               ----
----                                                              ----
----  Author(s):                                                  ----
----      - David Brochart(dbrochart@opencores.org)               ----
----                                                              ----
----  All additional information is available in the README.txt   ----
----  file.                                                       ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2005 Authors                                   ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU Lesser General Public License for more  ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;

package turbopack is
    constant RATE           : integer := 12;    -- code rate (e.g. 13 for rate 1/3)
    constant IT             : integer := 5;     -- number of decoding iterations
    constant FRSIZE         : integer := 64;    -- interleaver frame size in bit couples
    constant TREL1_LEN      : integer := 24;    -- first trellis length
    constant TREL2_LEN      : integer := 12;    -- second trellis length
    constant SIG_WIDTH      : integer := 4;     -- received decoder signal width
    constant Z_WIDTH        : integer := 5;     -- extrinsic information width
    constant ACC_DIST_WIDTH : integer := 9;     -- accumulated distance width
    subtype INT2BIT         is integer range 0 to 3;
    subtype INT3BIT         is integer range 0 to 7;
    subtype SUBINT0         is integer range -(2**(SIG_WIDTH-1)) - (2**Z_WIDTH) to 2**ACC_DIST_WIDTH + 2**(SIG_WIDTH-1) - 1;
    subtype SUBINT1         is integer range 0 to 2**ACC_DIST_WIDTH + 2**(SIG_WIDTH-1) + 2**(SIG_WIDTH-1) + 2**Z_WIDTH - 1;
    type ARRAY32a           is array (0 to 31)  of integer;
    type ARRAY32b           is array (0 to 31)  of std_logic_vector(ACC_DIST_WIDTH downto 0);
    type ARRAY32c           is array (0 to 31)  of std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);
    constant FROM2TO        : ARRAY32a := (0, 25,  6, 31,  8, 17, 14, 23, 20, 13, 18, 11, 28,  5, 26,  3,  4, 29,  2, 27, 12, 21, 10, 19, 16,  9, 22, 15, 24,  1, 30,  7);
    constant DISTINDEX      : ARRAY32a := (0,  7, 11, 12,  0,  7, 11, 12,  2,  5,  9, 14,  2,  5,  9, 14,  3,  4,  8, 15,  3,  4,  8, 15,  1,  6, 10, 13,  1,  6, 10, 13);
    constant TRANS2STATE    : ARRAY32a := (0,  6,  1,  7,  2,  4,  3,  5,  5,  3,  4,  2,  7,  1,  6,  0,  1,  7,  0,  6,  3,  5,  2,  4,  4,  2,  5,  3,  6,  0,  7,  1);
    constant STATE2TRANS    : ARRAY32a := (0,  2,  1,  3,  1,  3,  0,  2,  2,  0,  3,  1,  3,  1,  2,  0,  2,  0,  3,  1,  3,  1,  2,  0,  0,  2,  1,  3,  1,  3,  0,  2);
    type ARRAY2a            is array (0 to 1)   of std_logic_vector(SIG_WIDTH - 1 downto 0);
    type ARRAY3a            is array (0 to 2)   of std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);
    type ARRAY4a            is array (0 to 3)   of std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);
    type ARRAY4b            is array (0 to 3)   of std_logic_vector(ACC_DIST_WIDTH downto 0);
    type ARRAY4c            is array (0 to 3)   of std_logic_vector(Z_WIDTH - 1 downto 0);
    type ARRAY4d            is array (0 to 3)   of std_logic_vector(2 downto 0);
    type ARRAY4e            is array (0 to 3)   of SUBINT1;
    type ARRAY6a            is array (0 to 5)   of std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);
    type ARRAY6b            is array (0 to 5)   of INT2BIT;
    type ARRAY7a            is array (0 to 6)   of SUBINT0;
    type ARRAY8a            is array (0 to 7)   of std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);
    type ARRAY8b            is array (0 to 7)   of std_logic_vector(1 downto 0);
    type ARRAY8d            is array (0 to 7)   of INT3BIT;
    type ARRAY16a           is array (0 to 15)  of std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);
    type ARRAY16b           is array (0 to 15)  of std_logic_vector(SIG_WIDTH + 1 downto 0);
    type ARRAY_TREL1_LENx8  is array (0 to TREL1_LEN * 8 - 1) of INT2BIT;
    type ARRAY_TREL2_LENx8  is array (0 to TREL2_LEN * 8 - 1) of std_logic_vector(1 downto 0);
    type ARRAY_4xTREL2_LEN  is array (0 to 4 * TREL2_LEN - 1) of std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);
    type ARRAY_ITa          is array (0 to IT) of std_logic_vector(SIG_WIDTH - 1 downto 0);
    type ARRAY_ITb          is array (0 to IT) of ARRAY4c;
    
    component delayer
        generic (
                delay   : integer := 1          -- number of clock cycles to delay
                );
        port    (
                clk     : in  std_logic;        -- clock
                rst     : in  std_logic;        -- negative reset
                d       : in  std_logic_vector; -- signal to be delayed by "delay" clock cycles
                q       : out std_logic_vector  -- delayed signal
                );
    end component;
    
    component subs
        port    (
                op1     : in  std_logic_vector; -- first operand
                op2     : in  std_logic_vector; -- second operand
                res     : out std_logic_vector  -- result of the substraction
                );
    end component;
    
    component mux4
        port    (
                in1     : in  std_logic_vector;             -- first input signal
                in2     : in  std_logic_vector;             -- second input signal
                in3     : in  std_logic_vector;             -- third input signal
                in4     : in  std_logic_vector;             -- fourth input signal
                sel     : in  std_logic_vector(1 downto 0); -- 2-bit control signal
                outSel  : out std_logic_vector              -- selected output signal
                );
    end component;
    
    component mux8
        port    (
                in8x4   : in  ARRAY32c; -- 8x4 input signals
                sel     : in  std_logic_vector(2 downto 0); -- 3-bit control signal
                outSel4 : out ARRAY4a   -- selected output signals
                );
    end component;
    
    component distances
        port    (
                a           : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                b           : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                y           : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                w           : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                z           : in  ARRAY4c;                                  -- extrinsic information array
                distance16  : out ARRAY16a                                  -- distance signals (x16)
                );
    end component;
    
    component partDistance
        generic (
                ref : integer := 0                                  -- reference to compute the distance from
                );
        port    (
                a   : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                b   : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                y   : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                w   : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                res : out std_logic_vector(SIG_WIDTH + 1 downto 0)  -- partial distance signal
                );
    end component;

    component opposite
        port    (
                pos : in  std_logic_vector(SIG_WIDTH + 1 downto 0); -- original number
                neg : out std_logic_vector(SIG_WIDTH + 1 downto 0)  -- opposite number
                );
    end component;

    component distance
        port    (
                partDist    : in  std_logic_vector(SIG_WIDTH + 1 downto 0);     -- sum of the decoder input signals
                z           : in  std_logic_vector(Z_WIDTH - 1 downto 0);       -- extrinsic information
                dist        : out std_logic_vector(ACC_DIST_WIDTH - 1 downto 0) -- distance
                );
    end component;
    
    component reg
        port    (
                clk     : in  std_logic;        -- clock
                rst     : in  std_logic;        -- negative reset
                d       : in  std_logic_vector; -- next value
                q       : out std_logic_vector  -- current value
                );
    end component;
    
    component adder
        port    (
                op1     : in  std_logic_vector; -- first operand
                op2     : in  std_logic_vector; -- second operand
                res     : out std_logic_vector  -- result of the addition
                );
    end component;
    
    component reduction
        port    (
                org : in  ARRAY8a;  -- original array of 8 accumulated distances
                chd : out ARRAY8a   -- reduced array of 8 accumulated distances
                );
    end component;
    
    component accDist
        port    (
                clk         : in  std_logic;    -- clock
                rst         : in  std_logic;    -- negative reset
                accDistReg  : in  ARRAY8a;      -- original array of 8 accumulated distance registers
                dist        : in  ARRAY16a;     -- array of 16 distances
                accDistNew  : out ARRAY32c      -- array of 32 accumulated distances
                );
    end component;
    
    component cmp2
        port    (
                op1     : in  std_logic_vector; -- first operand
                op2     : in  std_logic_vector; -- second operand
                res     : out std_logic         -- compare result (0 if op2 < op1, 1 otherwise)
                );
    end component;
    
    component mux2
        port    (
                in1     : in  std_logic_vector; -- first input signal
                in2     : in  std_logic_vector; -- second input signal
                sel     : in  std_logic;        -- 1-bit control signal
                outSel  : out std_logic_vector  -- selected output signal
                );
    end component;
    
    component min4
        port    (
                op1     : in  std_logic_vector; -- first input signal
                op2     : in  std_logic_vector; -- second input signal
                op3     : in  std_logic_vector; -- third input signal
                op4     : in  std_logic_vector; -- fourth input signal
                res1    : out std_logic;        -- partial code of the minimum value
                res2    : out std_logic;        -- partial code of the minimum value
                res3    : out std_logic         -- partial code of the minimum value
                );
    end component;
    
    component accDistSel
        port    (
                accDist     : in  ARRAY32c; -- array of 32 accumulated distances
                accDistCod  : out ARRAY8b;  -- array of 8 2-bit selection signals
                accDistOut  : out ARRAY8a   -- array of 8 selected accumulated distances
                );
    end component;
    
    component cod2
        port    (
                in1     : in  std_logic;                    -- 1-bit first input signal
                in2     : in  std_logic;                    -- 1-bit second input signal
                in3     : in  std_logic;                    -- 1-bit third input signal
                outCod  : out std_logic_vector(1 downto 0)  -- 2-bit coded value
                );
    end component;
    
    component min8
        port    (
                op  : in  ARRAY8a;                      -- input signals
                res : out std_logic_vector(6 downto 0)  -- code of the minimum value
                );
    end component;
    
    component cod3
        port    (
                inSig   : in  std_logic_vector(6 downto 0); -- 7 1-bit input signals
                outCod  : out std_logic_vector(2 downto 0)  -- 3-bit coded value
                );
    end component;
    
    component stateSel
        port    (
                stateDist   : in ARRAY8a;                       -- state accumulated distance
                selState    : out std_logic_vector(2 downto 0)  -- selected state code
                );
    end component;
    
    component acs
        port    (
                clk         : in  std_logic;                            -- clock
                rst         : in  std_logic;                            -- negative reset
                a           : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                b           : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                y           : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                w           : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                z           : in  ARRAY4c;                              -- extrinsic information array
                selStateL   : in  std_logic_vector(2 downto 0);         -- selected state at t = L
                selTransL   : in  std_logic_vector(1 downto 0);         -- selected transition at selStateL
                selState    : out std_logic_vector(2 downto 0);         -- selected state
                stateDist   : out ARRAY8b;                              -- selected accumulated distances (per state)
                weight      : out ARRAY4a                               -- four weights sorted by transition code
                );
    end component;
    
    component trellis1
        port    (
                clk         : in  std_logic;                    -- clock
                rst         : in  std_logic;                    -- negative reset
                selState    : in  std_logic_vector(2 downto 0); -- selected state at time 0
                selTrans    : in  ARRAY8b;                      -- 8 selected transitions (1 per state) at time 0
                selStateL2  : out std_logic_vector(2 downto 0); -- selected state at time (l - 2)
                selStateL1  : out std_logic_vector(2 downto 0); -- selected state at time (l - 1)
                stateL1     : out ARRAY4d;                      -- 4 possible states at time (l - 1)
                selTransL2  : out std_logic_vector(1 downto 0)  -- selected transition at time (l - 2)
                );
    end component;
    
    component trellis2
        port    (
                clk         : in  std_logic;                    -- clock
                rst         : in  std_logic;                    -- negative reset
                selState    : in  std_logic_vector(2 downto 0); -- selected state at time (l - 1)
                state       : in  ARRAY4d;                      -- 4 possible states at time (l - 1)
                selTrans    : in  ARRAY8b;                      -- 8 selected transitions (1 per state) at time (l - 1)
                weight      : in  ARRAY4a;                      -- four weights sorted by transition code at time (l - 1)
                llr0        : out std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);    -- LLR for (a, b) = (0, 0) at time (l + m - 1)
                llr1        : out std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);    -- LLR for (a, b) = (0, 1) at time (l + m - 1)
                llr2        : out std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);    -- LLR for (a, b) = (1, 0) at time (l + m - 1)
                llr3        : out std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);    -- LLR for (a, b) = (1, 1) at time (l + m - 1)
                a           : out std_logic;                    -- decoded value of a at time (l + m - 1)
                b           : out std_logic                     -- decoded value of b at time (l + m - 1)
                );
    end component;
    
    component extInf
        port    (
                llr0    : in  std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);    -- LLR for (a, b) = (0, 0)
                llr1    : in  std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);    -- LLR for (a, b) = (0, 1)
                llr2    : in  std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);    -- LLR for (a, b) = (1, 0)
                llr3    : in  std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);    -- LLR for (a, b) = (1, 1)
                zin     : in  ARRAY4c;                                          -- extrinsic information input signal
                a       : in  std_logic_vector(SIG_WIDTH - 1 downto 0);         -- decoder systematic input signal
                b       : in  std_logic_vector(SIG_WIDTH - 1 downto 0);         -- decoder systematic input signal
                zout    : out ARRAY4c                                           -- extrinsic information output signal
                );
    end component;
    
    component sova
        port    (
                clk     : in  std_logic;                                -- clock
                rst     : in  std_logic;                                -- negative reset
                aNoisy  : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                bNoisy  : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                yNoisy  : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                wNoisy  : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                zin     : in  ARRAY4c;                                  -- extrinsic information input
                zout    : out ARRAY4c;                                  -- extrinsic information output
                aClean  : out std_logic;                                -- decoded systematic data
                bClean  : out std_logic                                 -- decoded systematic data
                );
    end component;
    
    component zPermut
        generic (
                flip        : integer := 0      -- initialisation (permutation on/off)
                );
        port    (
                flipflop    : in  std_logic;    -- permutation control signal (on/off)
                z           : in  ARRAY4c;      -- original extrinsic information
                zPerm       : out ARRAY4c       -- permuted extrinsic information
                );
    end component;
    
    component interleaver
        generic (
                delay       : integer := 0;     -- number of clock cycles to wait before starting the (de)interleaver
                way         : integer := 0      -- 0 for interleaving, 1 for deinterleaving
                );
        port    (
                clk         : in  std_logic;        -- clock
                rst         : in  std_logic;        -- negative reset
                d           : in  std_logic_vector; -- input data
                q           : out std_logic_vector  -- interleaved data
                );
    end component;
    
    component abPermut
        generic (
                flip        : integer := 0                                  -- initialisation (permutation on/off)
                );
        port    (
                flipflop    : in  std_logic;                                -- permutation control signal (on/off)
                a           : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- origiral systematic information
                b           : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- origiral systematic information
                abPerm      : out ARRAY2a                                   -- permuted systematic information
                );
    end component;
    
    component iteration
        generic (
                delay       : integer := 0                                  -- additional delay created by the previous iterations
                );
        port    (
                clk         : in  std_logic;                                -- clock
                rst         : in  std_logic;                                -- negative reset
                flipflop    : in  std_logic;                                -- permutation control signal (on/off)
                a           : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                b           : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                y           : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                w           : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                yInt        : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                wInt        : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
                zin         : in  ARRAY4c;                                  -- extrinsic information from the previous iteration
                zout        : out ARRAY4c;                                  -- extrinsic information to the next iteration
                aDec        : out std_logic;                                -- decoded signal
                bDec        : out std_logic;                                -- decoded signal
                aDel        : out std_logic_vector(SIG_WIDTH - 1 downto 0); -- delayed received decoder signal
                bDel        : out std_logic_vector(SIG_WIDTH - 1 downto 0); -- delayed received decoder signal
                yDel        : out std_logic_vector(SIG_WIDTH - 1 downto 0); -- delayed received decoder signal
                wDel        : out std_logic_vector(SIG_WIDTH - 1 downto 0); -- delayed received decoder signal
                yIntDel     : out std_logic_vector(SIG_WIDTH - 1 downto 0); -- delayed received decoder signal
                wIntDel     : out std_logic_vector(SIG_WIDTH - 1 downto 0)  -- delayed received decoder signal
                );
    end component;
    
    component clkDiv
        port    (
                clk     : in  std_logic;    -- clock
                rst     : in  std_logic;    -- negative reset
                clkout  : out std_logic     -- clock which frequency is half of the input clock
                );
    end component;
    
    component limiter
        port    (
                a       : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- decoder input signal
                b       : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- decoder input signal
                y       : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- decoder input signal
                w       : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- decoder input signal
                yInt    : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- decoder input signal
                wInt    : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- decoder input signal
                aLim    : out std_logic_vector(SIG_WIDTH - 1 downto 0); -- limited signal
                bLim    : out std_logic_vector(SIG_WIDTH - 1 downto 0); -- limited signal
                yLim    : out std_logic_vector(SIG_WIDTH - 1 downto 0); -- limited signal
                wLim    : out std_logic_vector(SIG_WIDTH - 1 downto 0); -- limited signal
                yIntLim : out std_logic_vector(SIG_WIDTH - 1 downto 0); -- limited signal
                wIntLim : out std_logic_vector(SIG_WIDTH - 1 downto 0)  -- limited signal
                );
    end component;
    
    component punct
        port    (
                clk         : in  std_logic;                                -- clock
                rst         : in  std_logic;                                -- negative reset
                y           : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- original data
                w           : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- original data
                yInt        : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- original data
                wInt        : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- original data
                yPunct      : out std_logic_vector(SIG_WIDTH - 1 downto 0); -- punctured data
                wPunct      : out std_logic_vector(SIG_WIDTH - 1 downto 0); -- punctured data
                yIntPunct   : out std_logic_vector(SIG_WIDTH - 1 downto 0); -- punctured data
                wIntPunct   : out std_logic_vector(SIG_WIDTH - 1 downto 0)  -- punctured data
                );
    end component;
end;
