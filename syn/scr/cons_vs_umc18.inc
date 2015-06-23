/* Constraints */
CLK_UNCERTAINTY = 0.1	/* 100 ps */
DFFPQ2_CKQ = 0.2	/* Clk to Q in technology time units */
DFFPQ2_SETUP = 0.1	/* Setup time in technology time units */

/* Clocks constraints */
set_clock_skew all_clocks() -uncertainty CLK_UNCERTAINTY
set_dont_touch_network all_clocks()

/* Reset constraints */
set_driving_cell -none RST
set_drive 0 RST
set_dont_touch_network RST

/* All inputs except reset and clock */
all_inputs_wo_rst_clk = all_inputs() - PCI_CLK - WB_CLK - RST

/* Set output delays and load for output signals
 *
 * All outputs are assumed to go directly into
 * external flip-flops for the purpose of this
 * synthesis
 */
set_load load_of(umcl18u250t2_typ/DFFPQ2/D) * 4 all_outputs()

/* Input delay and driving cell of all inputs
 *
 * All these signals are assumed to come directly from
 * flip-flops for the purpose of this synthesis 
 *
 */
set_driving_cell -cell DFFPQ2 -pin Q all_inputs_wo_rst_clk

/* Set design fanout */
/*
set_max_fanout 10 TOPLEVEL
*/

/* Set area constraint */
set_max_area MAX_AREA

set_operating_conditions -max WORST -max_library umcl18u250t2_wc
