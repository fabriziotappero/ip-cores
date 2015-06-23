----------------------------------------------------------------------
----                                                              ----
----  trellis1_synth.vhd                                          ----
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



architecture synth of trellis1 is
    signal pathIdReg    : ARRAY8d;
    signal reg          : ARRAY_TREL1_LENx8;
begin
    process (clk, rst)
        variable free       : std_logic_vector(7 downto 0);
        variable freeBeg    : std_logic_vector(7 downto 0);
        variable pastState  : ARRAY8d;
        variable pathId     : ARRAY8d;
        variable current_state  : INT3BIT;
        variable freePathId : INT3BIT;
        variable state_l3   : INT2BIT;
        variable state_l2   : INT2BIT;
        variable state_l1   : INT2BIT;
        variable outState_l2    : std_logic_vector(2 downto 0);
        variable outState_l1    : std_logic_vector(2 downto 0);
    begin
        if rst = '0' then
            for i in 0 to 3 loop
                stateL1(i) <= (others => '0');
            end loop;
            selStateL1 <= (others => '0');
            selStateL2 <= (others => '0');
            selTransL2 <= (others => '0');
            for i in 0 to 7 loop
                pathIdReg(i) <= 0;
                for j in 0 to TREL1_LEN - 1 loop
                    reg(j * 8 + i) <= 0;
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
                current_state   := i;
                if freeBeg(pathId(current_state)) = '1' then
                    reg(pathId(current_state)) <= conv_integer(unsigned(std_logic_vector(conv_unsigned(current_state, 3))(1 downto 0)));
                    freeBeg(pathId(i)) := '0';
                    pathIdReg(current_state) <= pathId(current_state);
                    for j in 0 to TREL1_LEN - 2 loop
                        reg((j + 1) * 8 + pathId(current_state)) <= reg(j * 8 + pathId(current_state));
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
                    reg(freePathId) <= conv_integer(unsigned(std_logic_vector(conv_unsigned(current_state, 3))(1 downto 0)));
                    free(freePathId) := '0';
                    pathIdReg(current_state) <= freePathId;
                    for j in 0 to TREL1_LEN - 2 loop
                        reg((j + 1) * 8 + freePathId) <= reg(j * 8 + pathId(current_state));
                    end loop;
                end if;
            end loop;
            state_l3 := reg((TREL1_LEN - 3) * 8 + pathId(conv_integer(unsigned(selState))));
            state_l2 := reg((TREL1_LEN - 2) * 8 + pathId(conv_integer(unsigned(selState))));
            state_l1 := reg((TREL1_LEN - 1) * 8 + pathId(conv_integer(unsigned(selState))));
            outState_l2(2) := std_logic_vector(conv_unsigned(state_l3, 2))(1) xor (std_logic_vector(conv_unsigned(state_l3, 2))(0) xor std_logic_vector(conv_unsigned(state_l2, 2))(1));
            outState_l2(1 downto 0) := std_logic_vector(conv_unsigned(state_l2, 2));
            outState_l1(2) := std_logic_vector(conv_unsigned(state_l2, 2))(1) xor (std_logic_vector(conv_unsigned(state_l2, 2))(0) xor std_logic_vector(conv_unsigned(state_l1, 2))(1));
            outState_l1(1 downto 0) := std_logic_vector(conv_unsigned(state_l1, 2));
            selStateL1 <= outState_l1;
            selStateL2 <= outState_l2;
            selTransL2 <= std_logic_vector(conv_unsigned(STATE2TRANS(conv_integer(unsigned(outState_l2)) * 4 + state_l1), 2));
            for i in 0 to 3 loop
                stateL1(i) <= std_logic_vector(conv_unsigned(TRANS2STATE(conv_integer(unsigned(outState_l2)) * 4 + i), 3));
            end loop;
        end if;
    end process;
end;
