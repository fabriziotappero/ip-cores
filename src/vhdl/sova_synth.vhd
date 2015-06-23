----------------------------------------------------------------------
----                                                              ----
----  sova_synth.vhd                                              ----
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



architecture synth of sova is
    signal selStateL2   : std_logic_vector(2 downto 0);
    signal selStateL1   : std_logic_vector(2 downto 0);
    signal selState     : std_logic_vector(2 downto 0);
    signal selTransL2   : std_logic_vector(1 downto 0);
    signal selTrans     : ARRAY8b;
    signal selTransL1   : ARRAY8b;
    signal weight       : ARRAY4a;
    signal stateL1      : ARRAY4d;
    signal llr0         : std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);
    signal llr1         : std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);
    signal llr2         : std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);
    signal llr3         : std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);
    signal zinDel       : ARRAY4c;
    signal aNoisyDel    : std_logic_vector(SIG_WIDTH - 1 downto 0);
    signal bNoisyDel    : std_logic_vector(SIG_WIDTH - 1 downto 0);
begin
    acs_i0 : acs    port map    (
                                clk         => clk,
                                rst         => rst,
                                a           => aNoisy,
                                b           => bNoisy,
                                y           => yNoisy,
                                w           => wNoisy,
                                z           => zin,
                                selStateL   => selStateL2,
                                selTransL   => selTransL2,
                                selState    => selState,
                                stateDist   => selTrans,
                                weight      => weight
                                );
    trellis1_i0 : trellis1  port map    (
                                        clk         => clk,
                                        rst         => rst,
                                        selState    => selState,
                                        selTrans    => selTrans,
                                        selStateL2  => selStateL2,
                                        selStateL1  => selStateL1,
                                        stateL1     => stateL1,
                                        selTransL2  => selTransL2
                                        );
    trellis2_i0 : trellis2  port map    (
                                        clk         => clk,
                                        rst         => rst,
                                        selState    => selStateL1,
                                        state       => stateL1,
                                        selTrans    => selTransL1,
                                        weight      => weight,
                                        llr0        => llr0,
                                        llr1        => llr1,
                                        llr2        => llr2,
                                        llr3        => llr3,
                                        a           => aClean,
                                        b           => bClean
                                        );
    delayer_g0 : for i in 0 to 7 generate
        delayer_i : delayer generic map (
                                        delay   => TREL1_LEN - 1
                                        )
                            port map    (
                                        clk     => clk,
                                        rst     => rst,
                                        d       => selTrans(i),
                                        q       => selTransL1(i)
                                        );
    end generate;
    delayer_g1 : for i in 0 to 3 generate
        delayer_i : delayer generic map (
                                        delay   => TREL1_LEN + TREL2_LEN
                                        )
                            port map    (
                                        clk     => clk,
                                        rst     => rst,
                                        d       => zin(i),
                                        q       => zinDel(i)
                                        );
    end generate;
    delayer_i0 : delayer    generic map (
                                        delay   => TREL1_LEN + TREL2_LEN
                                        )
                            port map    (
                                        clk     => clk,
                                        rst     => rst,
                                        d       => aNoisy,
                                        q       => aNoisyDel
                                        );
    delayer_i1 : delayer    generic map (
                                        delay   => TREL1_LEN + TREL2_LEN
                                        )
                            port map    (
                                        clk     => clk,
                                        rst     => rst,
                                        d       => bNoisy,
                                        q       => bNoisyDel
                                        );
    extInf_i0 : extInf  port map    (
                                    llr0    => llr0,
                                    llr1    => llr1,
                                    llr2    => llr2,
                                    llr3    => llr3,
                                    zin     => zinDel,
                                    a       => aNoisyDel,
                                    b       => bNoisyDel,
                                    zout    => zout
                                    );
end;
