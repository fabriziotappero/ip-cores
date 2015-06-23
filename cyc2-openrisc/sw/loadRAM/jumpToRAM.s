#include "board.h"
#include "mc.h"

	.global _jumpToRAM

        .section .text, "ax"
_jumpToRAM:
        l.movhi r2,hi(SDRAM_RESET_ADDR)
        l.ori   r2,r2,lo(SDRAM_RESET_ADDR)
        l.jr    r2
        l.addi  r2,r0,0


