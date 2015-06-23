	.WORDSIZE 32
	.ORG	0
        AMOV   R7, start
        .DC    2
        .DC    $FF00
        .DC    3
start   AMOV   R0, 1
loop    AMOV   R1, [R0]
dly     UASUB  R1, 1
        NEMOV  R7, dly
        AINC   R0
        AMOV   R1, [R0]
        AINC   R2
        AMOV   [R1], R2
        ADEC   R0
        AMOV   R7, loop
