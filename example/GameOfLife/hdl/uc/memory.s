; ram.s
; Copyright 2012-2013, Sinclair R.F., Inc.
;
; RAM definition for Conway's Game of Life, SSBCC.9x8 implementation

.memory RAM ram
; commanded mode
.variable       cmd_frame_waits         0       ; number of frames between updates
.variable       cmd_stop                0       ; don't propagate the state
.variable       cmd_wrap                0       ; wrap at the top/bottom and left/right boundaries
; internal status
.variable       cnt_frame_waits         0       ; current count against cmd_frame_waits
.variable       sel_rd                  0       ; index for ping pong buffer being displayed
; buffered game state for computing each line of output
.variable       line_prev               0*${N_MEM_WORDS+2}      ; values from previous line
.variable       line_curr               0*${N_MEM_WORDS+2}      ; values from current line
.variable       line_next               0*${N_MEM_WORDS+2}      ; values from next line

;
; Define ROM "nBitsSet".
;

.memory ROM nBitsSet
; Translate the values 0 through 7 inclusive into the number of ones in the value.
.variable       bit_counts              0 1 1 2 1 2 2 3
