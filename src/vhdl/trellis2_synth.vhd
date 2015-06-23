----------------------------------------------------------------------
----                                                              ----
----  trellis2_synth.vhd                                          ----
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



architecture synth of trellis2 is
    signal revWeight    : ARRAY_4xTREL2_LEN;
    signal pathIdReg    : ARRAY8d;
    signal reg          : ARRAY_TREL2_LENx8;
begin
    process (clk, rst)
        variable free       : std_logic_vector(7 downto 0);
        variable freeBeg    : std_logic_vector(7 downto 0);
        variable pastState  : ARRAY8d;
        variable pathId     : ARRAY8d;
        variable freePathId : INT3BIT;
        variable op         : ARRAY4a;
        variable tmp        : ARRAY4a;
        variable revWeightTmp   : ARRAY_4xTREL2_LEN;
        variable revWeightFilt  : ARRAY3a;
        variable notZero    : ARRAY6b;
        variable minTmp     : std_logic_vector(0 to 2);
        variable ind        : ARRAY6b;
        variable tmp4       : std_logic_vector(ACC_DIST_WIDTH downto 0);
    begin
        if rst = '0' then
            for i in 0 to 3 loop
                for j in 0 to TREL2_LEN - 1 loop
                    revWeight(i * TREL2_LEN + j) <= (others => '0');
                end loop;
            end loop;
            a       <= '0';
            b       <= '0';
            llr0    <= (others => '0');
            llr1    <= (others => '0');
            llr2    <= (others => '0');
            llr3    <= (others => '0');
            for i in 0 to 7 loop
                pathIdReg(i) <= i;
                for j in 0 to TREL2_LEN - 1 loop
                    reg(j * 8 + i) <= "00";
                end loop;
            end loop;
        elsif clk = '1' and clk'event then
            free := "11111111";
            for i in 0 to 7 loop
                pastState(i) := TRANS2STATE(i * 4 + conv_integer(unsigned(selTrans(i))));
                pathId(i) := pathIdReg(pastState(i));
                free(pathId(i)) := '0';
            end loop;
            freeBeg := "11111111";
            for i in 0 to 7 loop
                if freeBeg(pathId(i)) = '1' then
                    reg(0 * 8 + pathId(i)) <= selTrans(i);
                    freeBeg(pathId(i)) := '0';
                    pathIdReg(i) <= pathId(i);
                    for j in 0 to TREL2_LEN - 2 loop
                        reg((j + 1) * 8 + pathId(i)) <= reg(j * 8 + pathId(i));
                    end loop;
                else
                    if free(0) = '1' then
                        freePathId := 0;
                    end if;
                    if free(1 downto 0) = "10" then
                        freePathId := 1;
                    end if;
                    if free(2 downto 0) = "100" then
                        freePathId := 2;
                    end if;
                    if free(3 downto 0) = "1000" then
                        freePathId := 3;
                    end if;
                    if free(4 downto 0) = "10000" then
                        freePathId := 4;
                    end if;
                    if free(5 downto 0) = "100000" then
                        freePathId := 5;
                    end if;
                    if free(6 downto 0) = "1000000" then
                        freePathId := 6;
                    end if;
                    if free(7 downto 0) = "10000000" then
                        freePathId := 7;
                    end if;
                    reg(0 * 8 + freePathId) <= selTrans(i);
                    free(freePathId) := '0';
                    pathIdReg(i) <= freePathId;
                    for j in 0 to TREL2_LEN - 2 loop
                        reg((j + 1) * 8 + freePathId) <= reg(j * 8 + pathId(i));
                    end loop;
                end if;
            end loop;
            a <= reg((TREL2_LEN - 1) * 8 + pathId(conv_integer(unsigned(selState))))(1);
            b <= reg((TREL2_LEN - 1) * 8 + pathId(conv_integer(unsigned(selState))))(0);
            for i in 0 to 3 loop
                for j in 0 to TREL2_LEN - 2 loop
                    for k in 0 to 3 loop
                        if reg(j * 8 + pathId(conv_integer(unsigned(state(k))))) = std_logic_vector(conv_unsigned(i, 2)) and state(k) /= selState then
                            op(k) := weight(k);
                        else
                            op(k) := std_logic_vector(conv_unsigned((2 ** ACC_DIST_WIDTH) - 1, ACC_DIST_WIDTH));
                        end if;
                    end loop;
                    if conv_integer(unsigned(op(0))) < conv_integer(unsigned(op(1))) then
                        tmp(0) := op(0);
                    else
                        tmp(0) := op(1);
                    end if;
                    if conv_integer(unsigned(op(2))) < conv_integer(unsigned(op(3))) then
                        tmp(1) := op(2);
                    else
                        tmp(1) := op(3);
                    end if;
                    if conv_integer(unsigned(tmp(0))) < conv_integer(unsigned(tmp(1))) then
                        tmp(2) := tmp(0);
                    else
                        tmp(2) := tmp(1);
                    end if;
                    if conv_integer(unsigned(tmp(2))) < conv_integer(unsigned(revWeight(i * TREL2_LEN + j))) then
                        revWeightTmp(i * TREL2_LEN + j + 1) := tmp(2);
                    else
                        revWeightTmp(i * TREL2_LEN + j + 1) := revWeight(i * TREL2_LEN + j);
                    end if;
                end loop;
                revWeightTmp(i * TREL2_LEN + 0) := weight(i);
            end loop;
            for j in 0 to 1 loop
                if revWeightTmp(0 * TREL2_LEN + j) =  std_logic_vector(conv_unsigned(0, ACC_DIST_WIDTH)) then
                    notZero(j * 3 + 0)  := 1;
                    notZero(j * 3 + 1)  := 2;
                    notZero(j * 3 + 2)  := 3;
                elsif revWeightTmp(1 * TREL2_LEN + j) = std_logic_vector(conv_unsigned(0, ACC_DIST_WIDTH)) then
                    notZero(j * 3 + 0)  := 0;
                    notZero(j * 3 + 1)  := 2;
                    notZero(j * 3 + 2)  := 3;
                elsif revWeightTmp(2 * TREL2_LEN + j) = std_logic_vector(conv_unsigned(0, ACC_DIST_WIDTH)) then
                    notZero(j * 3 + 0)  := 0;
                    notZero(j * 3 + 1)  := 1;
                    notZero(j * 3 + 2)  := 3;
                elsif revWeightTmp(3 * TREL2_LEN + j) = std_logic_vector(conv_unsigned(0, ACC_DIST_WIDTH)) then
                    notZero(j * 3 + 0)  := 0;
                    notZero(j * 3 + 1)  := 1;
                    notZero(j * 3 + 2)  := 2;
                end if;
                if conv_integer(unsigned(revWeightTmp(notZero(j * 3 + 0) * TREL2_LEN + j))) <= conv_integer(unsigned(revWeightTmp(notZero(j * 3 + 1) * TREL2_LEN + j))) then
                    minTmp(0) := '0';
                else
                    minTmp(0) := '1';
                end if;
                if conv_integer(unsigned(revWeightTmp(notZero(j * 3 + 0) * TREL2_LEN + j))) <= conv_integer(unsigned(revWeightTmp(notZero(j * 3 + 2) * TREL2_LEN + j))) then
                    minTmp(1) := '0';
                else
                    minTmp(1) := '1';
                end if;
                if conv_integer(unsigned(revWeightTmp(notZero(j * 3 + 1) * TREL2_LEN + j))) <= conv_integer(unsigned(revWeightTmp(notZero(j * 3 + 2) * TREL2_LEN + j))) then
                    minTmp(2) := '0';
                else
                    minTmp(2) := '1';
                end if;
                if minTmp = "000" then
                    ind(j * 3 + 0)  := 0;
                    ind(j * 3 + 1)  := 1;
                    ind(j * 3 + 2)  := 2;
                elsif minTmp = "001" then
                    ind(j * 3 + 0)  := 0;
                    ind(j * 3 + 1)  := 2;
                    ind(j * 3 + 2)  := 1;
                elsif minTmp = "100" then
                    ind(j * 3 + 0)  := 1;
                    ind(j * 3 + 1)  := 0;
                    ind(j * 3 + 2)  := 2;
                elsif minTmp = "011" then
                    ind(j * 3 + 0)  := 1;
                    ind(j * 3 + 1)  := 2;
                    ind(j * 3 + 2)  := 0;
                elsif minTmp = "110" then
                    ind(j * 3 + 0)  := 2;
                    ind(j * 3 + 1)  := 0;
                    ind(j * 3 + 2)  := 1;
                else    -- if minTmp = "111" then
                    ind(j * 3 + 0)  := 2;
                    ind(j * 3 + 1)  := 1;
                    ind(j * 3 + 2)  := 0;
                end if;
            end loop;
            for i in 0 to 2 loop
                tmp(3)  := revWeightTmp(notZero(0 * 3 + ind(0 * 3 + i)) * TREL2_LEN + 0);
                tmp4    := std_logic_vector(conv_unsigned(conv_integer(unsigned(revWeightTmp(notZero(1 * 3 + ind(1 * 3 + i)) * TREL2_LEN + 1))) + (2 ** (ACC_DIST_WIDTH - 4)), ACC_DIST_WIDTH + 1));
                if conv_integer(unsigned(tmp(3))) < conv_integer(unsigned(tmp4)) then
                    revWeightFilt(ind(0 * 3 + i)) := tmp(3);
                else
                    revWeightFilt(ind(0 * 3 + i)) := tmp4(ACC_DIST_WIDTH - 1 downto 0);
                end if;
            end loop;
            for i in 0 to 2 loop
                revWeightTmp(notZero(0 * 3 + i) * TREL2_LEN + 0) := revWeightFilt(i);
            end loop;
            for i in 0 to 3 loop
                for j in 0 to TREL2_LEN - 1 loop
                    revWeight(TREL2_LEN * i + j) <= revWeightTmp(TREL2_LEN * i + j);
                end loop;
            end loop;
            llr0 <= revWeight(1 * TREL2_LEN - 1);
            llr1 <= revWeight(2 * TREL2_LEN - 1);
            llr2 <= revWeight(3 * TREL2_LEN - 1);
            llr3 <= revWeight(4 * TREL2_LEN - 1);
        end if;
    end process;
end;
