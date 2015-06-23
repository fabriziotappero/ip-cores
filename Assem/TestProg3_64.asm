	.WORDSIZE 64
	.ORG	0
        AMOV   R7, start
        .DC    2
        .DC    $FF00
        .DC    3
start   AMOV   R0, 1
loop    AMOV   R1, [R0]
dly     UASUB  R1, 1
        NEMOV  R7, dly
        AADD   R0, 1
        AMOV   R1, [R0]
        AADD   R2, 1
        AMOV   [R1], R2
        ASUB   R0, 1
        AMOV   R7, loop
