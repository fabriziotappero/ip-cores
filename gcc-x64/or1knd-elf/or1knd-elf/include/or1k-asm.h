#ifndef OR1K_ASM_H
#define OR1K_ASM_H

/* The purpose of the OR1K_INST macro is simply to protect the commas
   embedded within an instruction from the C preprocessor.  An entire
   instruction can be safely embedded within its arguments, including
   an arbitrary number of commas, and it will be reproduced
   exactly. */
#define OR1K_INST(...) __VA_ARGS__

/* OR1K_DELAYED takes two arguments which must be instructions.  They
   should be wrapped in OR1K_INST if the instructions require commas.
   The second argument should be a jump or branch instruction.  If we
   are assembling the code in delay-slot mode (e.g., for the standard
   OR1K) the first instruction will be emitted in the delay slot of
   the second instruction.  In no-delay-slot mode they will be emitted
   in order.  If we are using compat-delay mode, they will be emitted
   in order, but an l.nop instruction will be emitted immediately
   after. */

/* OR1K_DELAYED_NOP takes a single argument, which should be a
   branch/jump instruction.  In delay-slot or compat-delay modes, the
   instruction will be emitted with an l.nop in its delay slot. In
   no-delay mode, the instruction will be emitted by itself. */

#if defined(__OR1K_NODELAY__)

#define OR1K_DELAYED(a, b) a; b
#define OR1K_DELAYED_NOP(a) a

/* Go ahead and emit the .nodelay directive when in no-delay mode, so
   that the flags are appropriately set in the binary. */
.nodelay

#elif defined(__OR1K_DELAY__)

#define OR1K_DELAYED(a, b) b; a
#define OR1K_DELAYED_NOP(a) a; l.nop

#elif defined(__OR1K_DELAY_COMPAT__)

#define OR1K_DELAYED(a, b) a; b; l.nop
#define OR1K_DELAYED_NOP(a) a; l.nop

#else

#error One of __OR1K_NODELAY__, __OR1K_DELAY__, or __OR1K_DELAY_COMPAT__ must be defined

#endif

#endif
