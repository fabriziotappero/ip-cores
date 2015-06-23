/*
 * Maximally equidistributed combined Tausworthe generator
 * (k1,k2,k3) = (63,58,55); (q1,q2,q3) = (5,19,24); (s1,s2,s3) = (24,13,7)
 * Period is approximately 2^176
 */

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


#ifndef TAUS176_H
#define TAUS176_H

#ifdef __cplusplus
extern "C" {
#endif

/* Generator internal state */
typedef struct {
    unsigned long long z1, z2, z3;
} taus_state_t;

/* Update state */
unsigned long long taus_get(taus_state_t *state);

/* Set state using seed */
void taus_set(taus_state_t *state, unsigned long s);


#ifdef __cplusplus
}
#endif

#endif
