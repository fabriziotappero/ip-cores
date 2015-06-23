/*****************************************************************
//                                                              //
//  Amber 2 Core Cache Test                                     //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests simple cache operation                                //
//                                                              //
//  Contains a long but simple code sequence                    //
//  The entire sequence can fit in the cache                    //
//  This sequence is executes 4 times, so three times it        //
//  will execute from the cache. Test passes if sequence        //
//  executes correctly.                                         //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
*****************************************************************/

#include "amber_registers.h"

	.section .text

        @ ---------------------
        @ Enable the cache
        @ ---------------------
        mov     r0,  #0xffffffff
	mcr	15, 0, r0, cr3, cr0, 0   @ cacheable area
        mov     r0,  #1
	mcr	15, 0, r0, cr2, cr0, 0   @ cache enable
        nop
        nop
        
        mov     r3, #10
        mov     r4, #0
        mov     r5, #0

loop:        
        add     r4, r4, #17
        add     r5, r5, #9
        subs    r3, r3, #1
        bne     loop

        @ setup loop2
        ldr     r9, WriteLocation
        mov     r3, #9
        mov     r8, #4
loop2: 

        mov     r6, #0
        
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1

        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2

        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3

        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4

        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5

        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6

        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7

        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8

        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9

        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10

        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1

        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2

        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3

        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4

        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5

        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6

        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7

        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8

        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9

        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10


        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1

        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2

        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3

        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4

        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5

        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6

        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7

        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8

        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9

        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10


        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1

        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2

        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3

        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4

        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5

        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6

        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7

        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8

        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9

        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10


        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1

        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2

        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3

        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4

        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5

        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6

        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7

        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8

        str     r3, [r9]
        
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9

        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10


        
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1
        add     r6, r6,#1

        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2
        add     r6, r6,#2

        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3
        add     r6, r6,#3

        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4
        add     r6, r6,#4

        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5
        add     r6, r6,#5

        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6
        add     r6, r6,#6

        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7
        add     r6, r6,#7

        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8
        add     r6, r6,#8

        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
                
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9
        add     r6, r6,#9

        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10
        add     r6, r6,#10

        ldr     r7, Result
        cmp     r6, r7
        movne   r10, #100
        bne     testfail

        subs    r8, r8, #1
        bne     loop2        

        b       testpass

@ ------------------------------------------        
@ ------------------------------------------        

testfail:
        ldr     r11, AdrTestStatus
        str     r10, [r11]
        b       testfail
        
testpass:             
        ldr     r11, AdrTestStatus
        mov     r10, #17
        str     r10, [r11]
        b       testpass
                    


/* Write 17 to this address to generate a Test Passed message */
AdrTestStatus:              .word ADR_AMBER_TEST_STATUS
Result:                     .word 3300
WriteLocation:              .word 0xffc


/* ========================================================================= */
/* ========================================================================= */
        
