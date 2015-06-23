----------------------------------------------------------------------
----                                                              ----
----  iteration_synth.vhd                                         ----
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



architecture synth of iteration is
    signal zout1        : ARRAY4c;
    signal zout2        : ARRAY4c;
    signal zout1Perm    : ARRAY4c;
    signal zoutInt1     : ARRAY4c;
    signal zout2Int     : ARRAY4c;
    signal tmp0         : std_logic_vector(Z_WIDTH * 4 + SIG_WIDTH * 2 - 1 downto 0);
    signal tmp1         : std_logic_vector(Z_WIDTH * 4 + SIG_WIDTH * 2 - 1 downto 0);
    signal tmp2         : std_logic_vector(SIG_WIDTH * 6 - 1 downto 0);
    signal tmp3         : std_logic_vector(SIG_WIDTH * 6 - 1 downto 0);
    signal tmp4         : std_logic_vector(SIG_WIDTH * 4 - 1 downto 0);
    signal tmp5         : std_logic_vector(SIG_WIDTH * 4 - 1 downto 0);
    signal tmp6         : std_logic_vector(Z_WIDTH * 4 - 1 downto 0);
    signal tmp7         : std_logic_vector(Z_WIDTH * 4 - 1 downto 0);
    signal tmp8         : std_logic_vector(SIG_WIDTH * 6 - 1 downto 0);
    signal tmp9         : std_logic_vector(SIG_WIDTH * 6 - 1 downto 0);
    signal tmp10        : std_logic_vector(SIG_WIDTH * 8 - 1 downto 0);
    signal tmp11        : std_logic_vector(SIG_WIDTH * 8 - 1 downto 0);
    signal abDel1Perm   : ARRAY2a;
    signal abDel1PermInt: ARRAY2a;
    signal aDel1        : std_logic_vector(SIG_WIDTH - 1 downto 0);
    signal bDel1        : std_logic_vector(SIG_WIDTH - 1 downto 0);
    signal yDel1        : std_logic_vector(SIG_WIDTH - 1 downto 0);
    signal wDel1        : std_logic_vector(SIG_WIDTH - 1 downto 0);
    signal yIntDel1     : std_logic_vector(SIG_WIDTH - 1 downto 0);
    signal wIntDel1     : std_logic_vector(SIG_WIDTH - 1 downto 0);
    signal aDel2        : std_logic_vector(SIG_WIDTH - 1 downto 0);
    signal bDel2        : std_logic_vector(SIG_WIDTH - 1 downto 0);
    signal yDel2        : std_logic_vector(SIG_WIDTH - 1 downto 0);
    signal wDel2        : std_logic_vector(SIG_WIDTH - 1 downto 0);
    signal aDecInt      : std_logic;
    signal bDecInt      : std_logic;
    signal aDel3        : std_logic_vector(SIG_WIDTH - 1 downto 0);
    signal bDel3        : std_logic_vector(SIG_WIDTH - 1 downto 0);
    signal yDel3        : std_logic_vector(SIG_WIDTH - 1 downto 0);
    signal wDel3        : std_logic_vector(SIG_WIDTH - 1 downto 0);
    signal yIntDel3     : std_logic_vector(SIG_WIDTH - 1 downto 0);
    signal wIntDel3     : std_logic_vector(SIG_WIDTH - 1 downto 0);
    signal yIntDel4     : std_logic_vector(SIG_WIDTH - 1 downto 0);
    signal wIntDel4     : std_logic_vector(SIG_WIDTH - 1 downto 0);
begin
    sova_i0 : sova  port map    (
                                clk     => clk,
                                rst     => rst,
                                aNoisy  => a,
                                bNoisy  => b,
                                yNoisy  => y,
                                wNoisy  => w,
                                zin     => zin,
                                zout    => zout1,
                                aClean  => aDec,
                                bClean  => bDec
                                );
    zPermut_i0 : zPermut    generic map (
                                        flip        => (TREL1_LEN + TREL2_LEN + 2 + delay + 1) mod 2
                                        )
                            port map    (
                                        flipflop    => flipflop,
                                        z           => zout1,
                                        zPerm       => zout1Perm
                                        );
    
    tmp0 <= zout1Perm(0) & zout1Perm(1) & zout1Perm(2) & zout1Perm(3) & abDel1Perm(0) & abDel1Perm(1);
    
    interleaver_i0 : interleaver    generic map (
                                                delay       => TREL1_LEN + TREL2_LEN + 2 + delay,
                                                way         => 0
                                                )
                                    port map    (
                                                clk         => clk,
                                                rst         => rst,
                                                d           => tmp0,
                                                q           => tmp1
                                                );
    
    zoutInt1(0)         <= tmp1(Z_WIDTH * 4 + SIG_WIDTH * 2 - 1 downto Z_WIDTH * 3 + SIG_WIDTH * 2);
    zoutInt1(1)         <= tmp1(Z_WIDTH * 3 + SIG_WIDTH * 2 - 1 downto Z_WIDTH * 2 + SIG_WIDTH * 2);
    zoutInt1(2)         <= tmp1(Z_WIDTH * 2 + SIG_WIDTH * 2 - 1 downto Z_WIDTH * 1 + SIG_WIDTH * 2);
    zoutInt1(3)         <= tmp1(Z_WIDTH * 1 + SIG_WIDTH * 2 - 1 downto Z_WIDTH * 0 + SIG_WIDTH * 2);
    abDel1PermInt(0)    <= tmp1(SIG_WIDTH * 2 - 1 downto SIG_WIDTH * 1);
    abDel1PermInt(1)    <= tmp1(SIG_WIDTH * 1 - 1 downto SIG_WIDTH * 0);
    
    tmp2 <= a & b & y & w & yInt & wInt;
    
    delayer_i0 : delayer    generic map (
                                        delay   => TREL1_LEN + TREL2_LEN
                                        )
                            port map    (
                                        clk     => clk,
                                        rst     => rst,
                                        d       => tmp2,
                                        q       => tmp3
                                        );
    
    aDel1       <= tmp3(SIG_WIDTH * 6 - 1 downto SIG_WIDTH * 5);
    bDel1       <= tmp3(SIG_WIDTH * 5 - 1 downto SIG_WIDTH * 4);
    yDel1       <= tmp3(SIG_WIDTH * 4 - 1 downto SIG_WIDTH * 3);
    wDel1       <= tmp3(SIG_WIDTH * 3 - 1 downto SIG_WIDTH * 2);
    yIntDel1    <= tmp3(SIG_WIDTH * 2 - 1 downto SIG_WIDTH * 1);
    wIntDel1    <= tmp3(SIG_WIDTH * 1 - 1 downto SIG_WIDTH * 0);
    
    abPermut_i0 : abPermut  generic map (
                                        flip        => (TREL1_LEN + TREL2_LEN + 2 + delay + 1) mod 2
                                        )
                            port map    (
                                        flipflop    => flipflop,
                                        a           => aDel1,
                                        b           => bDel1,
                                        abPerm      => abDel1Perm
                                        );
    
    tmp4 <= aDel1 & bDel1 & yDel1 & wDel1;
    
    delayer_i1 : delayer    generic map (
                                        delay   => FRSIZE
                                        )
                            port map    (
                                        clk     => clk,
                                        rst     => rst,
                                        d       => tmp4,
                                        q       => tmp5
                                        );
    
    aDel2   <= tmp5(SIG_WIDTH * 4 - 1 downto SIG_WIDTH * 3);
    bDel2   <= tmp5(SIG_WIDTH * 3 - 1 downto SIG_WIDTH * 2);
    yDel2   <= tmp5(SIG_WIDTH * 2 - 1 downto SIG_WIDTH * 1);
    wDel2   <= tmp5(SIG_WIDTH * 1 - 1 downto SIG_WIDTH * 0);

    sova_i1 : sova  port map    (
                                clk     => clk,
                                rst     => rst,
                                aNoisy  => abDel1PermInt(1),
                                bNoisy  => abDel1PermInt(0),
                                yNoisy  => yIntDel1,
                                wNoisy  => wIntDel1,
                                zin     => zoutInt1,
                                zout    => zout2,
                                aClean  => aDecInt,
                                bClean  => bDecInt
                                );
    
    tmp6 <= zout2(0) & zout2(1) & zout2(2) & zout2(3);
    
    deinterleaver_i0 : interleaver  generic map (
                                                delay       => 2 * (TREL1_LEN + TREL2_LEN + 2) + FRSIZE + delay,
                                                way         => 1
                                                )
                                    port map    (
                                                clk         => clk,
                                                rst         => rst,
                                                d           => tmp6,
                                                q           => tmp7
                                                );
    
    zout2Int(0) <= tmp7(Z_WIDTH * 4 - 1 downto Z_WIDTH * 3);
    zout2Int(1) <= tmp7(Z_WIDTH * 3 - 1 downto Z_WIDTH * 2);
    zout2Int(2) <= tmp7(Z_WIDTH * 2 - 1 downto Z_WIDTH * 1);
    zout2Int(3) <= tmp7(Z_WIDTH * 1 - 1 downto Z_WIDTH * 0);
    
    zPermut_i1 : zPermut    generic map (
                                        flip        => (2 * (TREL1_LEN + TREL2_LEN + 2) + FRSIZE + delay) mod 2
                                        )
                            port map    (
                                        flipflop    => flipflop,
                                        z           => zout2Int,
                                        zPerm       => zout
                                        );
    
    tmp8 <= aDel2 & bDel2 & yDel2 & wDel2 & yIntDel1 & wIntDel1;
    
    delayer_i2 : delayer    generic map (
                                        delay   => TREL1_LEN + TREL2_LEN
                                        )
                            port map    (
                                        clk     => clk,
                                        rst     => rst,
                                        d       => tmp8,
                                        q       => tmp9
                                        );
    
    aDel3       <= tmp9(SIG_WIDTH * 6 - 1 downto SIG_WIDTH * 5);
    bDel3       <= tmp9(SIG_WIDTH * 5 - 1 downto SIG_WIDTH * 4);
    yDel3       <= tmp9(SIG_WIDTH * 4 - 1 downto SIG_WIDTH * 3);
    wDel3       <= tmp9(SIG_WIDTH * 3 - 1 downto SIG_WIDTH * 2);
    yIntDel3    <= tmp9(SIG_WIDTH * 2 - 1 downto SIG_WIDTH * 1);
    wIntDel3    <= tmp9(SIG_WIDTH * 1 - 1 downto SIG_WIDTH * 0);
    
    tmp10 <= aDel3 & bDel3 & yDel3 & wDel3 & yIntDel3 & wIntDel3 & yIntDel4 & wIntDel4;
    
    delayer_i3 : delayer    generic map (
                                        delay   => FRSIZE
                                        )
                            port map    (
                                        clk     => clk,
                                        rst     => rst,
                                        d       => tmp10,
                                        q       => tmp11
                                        );
    
    aDel        <= tmp11(SIG_WIDTH * 8 - 1 downto SIG_WIDTH * 7);
    bDel        <= tmp11(SIG_WIDTH * 7 - 1 downto SIG_WIDTH * 6);
    yDel        <= tmp11(SIG_WIDTH * 6 - 1 downto SIG_WIDTH * 5);
    wDel        <= tmp11(SIG_WIDTH * 5 - 1 downto SIG_WIDTH * 4);
    yIntDel4    <= tmp11(SIG_WIDTH * 4 - 1 downto SIG_WIDTH * 3);
    wIntDel4    <= tmp11(SIG_WIDTH * 3 - 1 downto SIG_WIDTH * 2);
    yIntDel     <= tmp11(SIG_WIDTH * 2 - 1 downto SIG_WIDTH * 1);
    wIntDel     <= tmp11(SIG_WIDTH * 1 - 1 downto SIG_WIDTH * 0);
    
end;
