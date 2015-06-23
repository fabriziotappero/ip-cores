/* Constraints */
CLK_UNCERTAINTY = 0.1	/* 100 ps */
DFFPQ2_CKQ = 0.2	/* Clk to Q in technology time units */
DFFPQ2_SETUP = 0.1	/* Setup time in technology time units */

/* Clocks constraints */
create_clock CLK -period CLK_PERIOD
create_clock ECLK -period CLK_PERIOD
set_clock_skew all_clocks() -uncertainty CLK_UNCERTAINTY
set_dont_touch_network all_clocks()

/* Reset constraints */
set_driving_cell -none RST
set_drive 0 RST
set_dont_touch_network RST

/* All inputs except reset and clock */
all_inputs_wo_rst_clk = all_inputs() - CLK - RST

/* Set output delays and load for output signals
 *
 * All outputs are assumed to go directly into
 * external flip-flops for the purpose of this
 * synthesis
 */
set_output_delay DFFPQ2_SETUP -clock CLK all_outputs()
set_load load_of(umcl18u250t2_typ/DFFPQ2/D) * 4 all_outputs()

/* Input delay and driving cell of all inputs
 *
 * All these signals are assumed to come directly from
 * flip-flops for the purpose of this synthesis 
 *
 */
set_input_delay DFFPQ2_CKQ -clock CLK all_inputs_wo_rst_clk
set_driving_cell -cell DFFPQ2 -pin Q all_inputs_wo_rst_clk

/* Set design fanout */
/*
set_max_fanout 10 TOPLEVEL
*/

/* Set area constraint */
set_max_area MAX_AREA

/* Optimize all near-critical paths to give extra slack for layout */
c_range = CLK_PERIOD * 0.1
group_path -critical_range c_range -name CLK -to CLK

/* Operating conditions */
set_operating_conditions TYPICAL
