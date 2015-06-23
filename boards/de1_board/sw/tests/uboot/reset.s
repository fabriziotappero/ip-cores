/*  */
/*  */

/* #define STACK_SIZE 0x2000 */

.section .stack, "aw", @nobits
.space  0x0800
_stack:

.section .vectors, "ax"
# .org 0x100
  
_reset:

  /* Set stack pointer */
  l.movhi r1,hi(_stack)
  l.ori   r1,r1,lo(_stack)
  
  /* Jump to main */
  l.movhi r2,hi(_main)
  l.ori   r2,r2,lo(_main)
  l.jr    r2
  l.nop

