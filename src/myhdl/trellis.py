######################################################################
####                                                              ####
####  trellis.py                                                  ####
####                                                              ####
####  This file is part of the turbo decoder IP core project      ####
####  http://www.opencores.org/projects/turbocodes/               ####
####                                                              ####
####  Author(s):                                                  ####
####      - David Brochart(dbrochart@opencores.org)               ####
####                                                              ####
####  All additional information is available in the README.txt   ####
####  file.                                                       ####
####                                                              ####
######################################################################
####                                                              ####
#### Copyright (C) 2005 Authors                                   ####
####                                                              ####
#### This source file may be used and distributed without         ####
#### restriction provided that this copyright statement is not    ####
#### removed from the file and that any derivative work contains  ####
#### the original copyright notice and the associated disclaimer. ####
####                                                              ####
#### This source file is free software; you can redistribute it   ####
#### and/or modify it under the terms of the GNU Lesser General   ####
#### Public License as published by the Free Software Foundation; ####
#### either version 2.1 of the License, or (at your option) any   ####
#### later version.                                               ####
####                                                              ####
#### This source is distributed in the hope that it will be       ####
#### useful, but WITHOUT ANY WARRANTY; without even the implied   ####
#### warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ####
#### PURPOSE. See the GNU Lesser General Public License for more  ####
#### details.                                                     ####
####                                                              ####
#### You should have received a copy of the GNU Lesser General    ####
#### Public License along with this source; if not, download it   ####
#### from http://www.opencores.org/lgpl.shtml                     ####
####                                                              ####
######################################################################



from myhdl import Signal, posedge, negedge, intbv, always

trans2state = [[0, 6, 1, 7], [2, 4, 3, 5], [5, 3, 4, 2], [7, 1, 6, 0], [1, 7, 0, 6], [3, 5, 2, 4], [4, 2, 5, 3], [6, 0, 7, 1]]
state2trans = [[0, 2, 1, 3], [1, 3, 0, 2], [2, 0, 3, 1], [3, 1, 2, 0], [2, 0, 3, 1], [3, 1, 2, 0], [0, 2, 1, 3], [1, 3, 0, 2]]

def trellis1(clk, rst, selState, selTrans, selStateL2, selStateL1, stateL1, selTransL2, l = 20):
    """ First trellis.

    l           -- first trellis length
    clk, rst    -- in  : clock and negative reset
    selState    -- in  : selected state at time 0
    selTrans    -- in  : 8 selected transitions (1 per state) at time 0
    selStateL2  -- out : selected state at time (l - 2)
    selStateL1  -- out : selected state at time (l - 1)
    stateL1     -- out : 4 possible states at time (l - 1)
    selTransL2  -- out : selected transition at time (l - 2)

    """
    reg = [[Signal(intbv(0, 0, 4)) for i in range(8)] for j in range(l)]
    free = intbv(255, 0, 256)
    freeBeg = [bool(1) for i in range(8)]
    pastState = [intbv(0, 0, 8) for i in range(8)]
    pathIdReg = [Signal(intbv(i, 0, 8)) for i in range(8)]
    pathId = [intbv(0, 0, 8) for i in range(8)]
    freePathId = intbv(0, 0, 8)
    current_state = intbv(0, 0, 8)
    outState_l2 = intbv(0, 0, 8)
    outState_l1 = intbv(0, 0, 8)
    state_l3 = intbv(0, 0, 4)
    state_l2 = intbv(0, 0, 4)
    state_l1 = intbv(0, 0, 4)
    @always(clk.posedge, rst.negedge)
    def trellis1Logic():
        if rst.val == 0:
            for i in range(4):
                stateL1[i].next = 0
            selStateL1.next = 0
            selStateL2.next = 0
            selTransL2.next = 0
            for i in range(8):
                pathIdReg[i].next = i
                for j in range(l):
                    reg[j][i].next = 0
        else:
            free = intbv(255)
            for i in range(8):
                pastState[i] = trans2state[i][int(selTrans[i].val)]
                pathId[i] = pathIdReg[pastState[i]].val
                free[int(pathId[i])] = 0
            freeBeg = [bool(1) for i in range(8)]
            for i in range(8):
                current_state = intbv(i)
                if freeBeg[int(pathId[int(current_state)])] == 1:
                    reg[0][int(pathId[int(current_state)])].next = current_state[2:0]
                    freeBeg[int(pathId[i])] = 0
                    pathIdReg[int(current_state)].next = pathId[int(current_state)]
                    for j in range(l - 1):
                        reg[j + 1][int(pathId[int(current_state)])].next = reg[j][int(pathId[int(current_state)])].val
                else:
                    if free[0] == 1:
                        freePathId = 0
                    if free[2:0] == 2:
                        freePathId = 1
                    if free[3:0] == 4:
                        freePathId = 2
                    if free[4:0] == 8:
                        freePathId = 3
                    if free[5:0] == 16:
                        freePathId = 4
                    if free[6:0] == 32:
                        freePathId = 5
                    if free[7:0] == 64:
                        freePathId = 6
                    if free[8:0] == 128:
                        freePathId = 7
                    reg[0][freePathId].next = current_state[2:0]
                    free[freePathId] = 0
                    pathIdReg[int(current_state)].next = freePathId
                    for j in range(l - 1):
                        reg[j + 1][freePathId].next = reg[j][int(pathId[int(current_state)])].val
            state_l3 = reg[l - 3][int(pathId[int(selState.val)])].val
            state_l2 = reg[l - 2][int(pathId[int(selState.val)])].val
            state_l1 = reg[l - 1][int(pathId[int(selState.val)])].val
            outState_l2[2] = state_l3[1] ^ (state_l3[0] ^ state_l2[1])
            outState_l2[2:0] = state_l2
            outState_l1[2] = state_l2[1] ^ (state_l2[0] ^ state_l1[1])
            outState_l1[2:0] = state_l1
            selStateL1.next = outState_l1
            selStateL2.next = outState_l2
            selTransL2.next = state2trans[int(outState_l2)][int(state_l1)]
            for i in range(4):
                stateL1[i].next = trans2state[int(outState_l2)][i]
            if __debug__:
                # Monitor: checks that in the first trellis, from each of the 8 states (trellis' beginning) we arrive at the same state (trellis' end).
                #          (Ignore this message until every iteration is fully started)
                diff = 0
                ref = intbv(0)
                tmp = intbv(0)
                state_l2_deb = reg[l - 2][int(pathId[7])].val
                state_l1_deb = reg[l - 1][int(pathId[7])].val
                ref[2] = state_l2_deb[1] ^ (state_l2_deb[0] ^ state_l1_deb[1])
                ref[2:0] = state_l1_deb
                for i in range(7):
                    state_l2_deb = reg[l - 2][int(pathId[i])].val
                    state_l1_deb = reg[l - 1][int(pathId[i])].val
                    tmp[2] = state_l2_deb[1] ^ (state_l2_deb[0] ^ state_l1_deb[1])
                    tmp[2:0] = state_l1_deb
                    if ref != tmp:
                        diff = 1
                if diff == 1:
                    print "WARNING: all paths don't arrive at same state at end of first trellis (you should think about increasing its length)"
    return trellis1Logic

def trellis2(clk, rst, selState, state, selTrans, weight, llr0, llr1, llr2, llr3, a, b, m = 10, q = 8):
    """ Second trellis and revision logic.
    
    m           -- second trellis length
    q           -- accumulated distance width
    clk, rst    -- in  : clock and negative reset
    selState    -- in  : selected state at time (l - 1)
    state       -- in  : 4 possible states at time (l - 1)
    selTrans    -- in  : 8 selected transitions (1 per state) at time (l - 1)
    weight      -- in  : four weights sorted by transition code at time (l - 1)
    llr0        -- out : LLR for (a, b) = (0, 0) at time (l + m - 1)
    llr1        -- out : LLR for (a, b) = (0, 1) at time (l + m - 1)
    llr2        -- out : LLR for (a, b) = (1, 0) at time (l + m - 1)
    llr3        -- out : LLR for (a, b) = (1, 1) at time (l + m - 1)
    a, b        -- out : decoded values of (a, b) at time (l + m - 1)

    """
    reg = [[Signal(intbv(0, 0, 4)) for i in range(8)] for j in range(m)]
    free = intbv(255, 0, 256)
    freeBeg = [bool(1) for i in range(8)]
    pastState = [intbv(0, 0, 8) for i in range(8)]
    pathIdReg = [Signal(intbv(i, 0, 8)) for i in range(8)]
    pathId = [intbv(0, 0, 8) for i in range(8)]
    freePathId = intbv(0, 0, 8)
    revWeight = [[Signal(intbv(0, 0, 2**q)) for i in range(m)] for j in range(4)]
    revWeightTmp = [[intbv(0, 0, 2**q) for i in range(m)] for j in range(4)]
    revWeightFilt = [intbv(0, 0, 2**q) for j in range(3)]
    op = [intbv(0, 0, 2**q) for i in range(4)]
    tmp = [intbv(0, 0, 2**q) for i in range(4)]
    tmp4 = intbv(0, 0, 2**(q+1))
    notZero = [[intbv(0, 0, 4) for i in range(3)] for j in range(2)]
    ind = [[intbv(0, 0, 4) for i in range(3)] for j in range(2)]
    minTmp = [bool(0) for i in range(3)]
    @always(clk.posedge, rst.negedge)
    def trellis2Logic():
        if rst.val == 0:
            for i in range(4):
                for j in range(m):
                    revWeight[i][j].next = 0
            a.next = 0
            b.next = 0
            llr0.next = 0
            llr1.next = 0
            llr2.next = 0
            llr3.next = 0
            for i in range(8):
                pathIdReg[i].next = i
                for j in range(m):
                    reg[j][i].next = 0
        else:
            free = intbv(255)
            for i in range(8):
                pastState[i] = trans2state[i][int(selTrans[i].val)]
                pathId[i] = pathIdReg[pastState[i]].val
                free[int(pathId[i])] = 0
            freeBeg = [bool(1) for i in range(8)]
            for i in range(8):
                if freeBeg[int(pathId[i])] == 1:
                    reg[0][int(pathId[i])].next = selTrans[i].val
                    freeBeg[int(pathId[i])] = 0
                    pathIdReg[i].next = pathId[i]
                    for j in range(m - 1):
                        reg[j + 1][int(pathId[i])].next = reg[j][int(pathId[i])].val
                else:
                    if free[1:0] == 1:
                        freePathId = 0
                    if free[2:0] == 2:
                        freePathId = 1
                    if free[3:0] == 4:
                        freePathId = 2
                    if free[4:0] == 8:
                        freePathId = 3
                    if free[5:0] == 16:
                        freePathId = 4
                    if free[6:0] == 32:
                        freePathId = 5
                    if free[7:0] == 64:
                        freePathId = 6
                    if free[8:0] == 128:
                        freePathId = 7
                    reg[0][freePathId].next = selTrans[i].val
                    free[freePathId] = 0
                    pathIdReg[i].next = freePathId
                    for j in range(m - 1):
                        reg[j + 1][freePathId].next = reg[j][int(pathId[i])].val
            a.next = reg[m - 1][int(pathId[int(selState.val)])].val[1]
            b.next = reg[m - 1][int(pathId[int(selState.val)])].val[0]
            for i in range(4):
                for j in range(m - 1):
                    for k in range(4):
                        if reg[j][int(pathId[int(state[k].val)])].val == i and state[k].val != selState.val:
                            op[k] = weight[k].val
                        else:
                            op[k] = (2 ** q) - 1
                    if op[0] < op[1]:
                        tmp[0] = op[0]
                    else:
                        tmp[0] = op[1]
                    if op[2] < op[3]:
                        tmp[1] = op[2]
                    else:
                        tmp[1] = op[3]
                    if tmp[0] < tmp[1]:
                        tmp[2] = tmp[0]
                    else:
                        tmp[2] = tmp[1]
                    if tmp[2] < revWeight[i][j].val:
                        revWeightTmp[i][j + 1] = tmp[2]
                    else:
                        revWeightTmp[i][j + 1] = revWeight[i][j].val
                revWeightTmp[i][0] = weight[i].val
            for j in range(2):
                if revWeightTmp[0][j] == 0:
                    notZero[j] = [1, 2, 3]
                elif revWeightTmp[1][j] == 0:
                    notZero[j] = [0, 2, 3]
                elif revWeightTmp[2][j] == 0:
                    notZero[j] = [0, 1, 3]
                elif revWeightTmp[3][j] == 0:
                    notZero[j] = [0, 1, 2]
                if revWeightTmp[int(notZero[j][0])][j] <= revWeightTmp[int(notZero[j][1])][j]:
                    minTmp[0] = 0
                else:
                    minTmp[0] = 1
                if revWeightTmp[int(notZero[j][0])][j] <= revWeightTmp[int(notZero[j][2])][j]:
                    minTmp[1] = 0
                else:
                    minTmp[1] = 1
                if revWeightTmp[int(notZero[j][1])][j] <= revWeightTmp[int(notZero[j][2])][j]:
                    minTmp[2] = 0
                else:
                    minTmp[2] = 1
                if minTmp == [0, 0, 0]:
                    ind[j] = [0, 1, 2]
                elif minTmp == [0, 0, 1]:
                    ind[j] = [0, 2, 1]
                elif minTmp == [1, 0, 0]:
                    ind[j] = [1, 0, 2]
                elif minTmp == [0, 1, 1]:
                    ind[j] = [1, 2, 0]
                elif minTmp == [1, 1, 0]:
                    ind[j] = [2, 0, 1]
                elif minTmp == [1, 1, 1]:
                    ind[j] = [2, 1, 0]
                else:
                    print "ERROR: Configuration does not exist", minTmp
            for i in range(3):
                tmp[3]  = revWeightTmp[int(notZero[0][int(ind[0][i])])][0]
                tmp4    = revWeightTmp[int(notZero[1][int(ind[1][i])])][1] + (2 ** (q - 4))
                if tmp[3] < tmp4:
                    revWeightFilt[int(ind[0][i])] = tmp[3]
                else:
                    revWeightFilt[int(ind[0][i])] = intbv(tmp4)[q:0]
            for i in range(3):
                revWeightTmp[int(notZero[0][i])][0] = revWeightFilt[i]
            for i in range(4):
                for j in range(m):
                    revWeight[i][j].next = revWeightTmp[i][j]
            llr0.next = revWeight[0][m - 1]
            llr1.next = revWeight[1][m - 1]
            llr2.next = revWeight[2][m - 1]
            llr3.next = revWeight[3][m - 1]
    return trellis2Logic
