/* Maximally equidistributed combined Tausworthe generator */

/*
 * Copyright (C) 2014, Guangxi Liu <guangxi.liu@opencores.org>
 *
 * This source file may be used and distributed without restriction provided
 * that this copyright statement is not removed from the file and that any
 * derivative work contains the original copyright notice and the associated
 * disclaimer.
 *
 * This source file is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License,
 * or (at your option) any later version.
 *
 * This source is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
 * License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this source; if not, download it from
 * http://www.opencores.org/lgpl.shtml
 */
 
 
#include "taus176.h"


/* Update state */
unsigned long long taus_get(taus_state_t *state)
{
    unsigned long long b;
    
    b = (((state->z1 << 5) ^ state->z1) >> 39);
    state->z1 = (((state->z1 & 18446744073709551614ULL) << 24) ^ b);
    b = (((state->z2 << 19) ^ state->z2) >> 45);
    state->z2 = (((state->z2 & 18446744073709551552ULL) << 13) ^ b);
    b = (((state->z3 << 24) ^ state->z3) >> 48);
    state->z3 = (((state->z3 & 18446744073709551104ULL) << 7) ^ b);
    
    return (state->z1 ^ state->z2 ^ state->z3);
}


/* Set state using seed */
#define LCG(n) (4294967291ULL * n)

void taus_set(taus_state_t *state, unsigned long s)
{
    if (s == 0)    s = 1;    /* default seed is 1 */
    
    state->z1 = LCG(s);
    if (state->z1 < 2ULL)    state->z1 += 2ULL;
    state->z2 = LCG(state->z1);
    if (state->z2 < 64ULL)    state->z2 += 64ULL;
    state->z3 = LCG(state->z2);
    if (state->z3 < 512ULL)    state->z3 += 512ULL;
    
    /* "warm it up" */
    taus_get(state);
    taus_get(state);
    taus_get(state);
    taus_get(state);
    taus_get(state);
    taus_get(state);
    taus_get(state);
    taus_get(state);
    taus_get(state);
    taus_get(state);
}
