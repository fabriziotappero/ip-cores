//============================================================================
// Bus switch in bus A-Z80 CPU
//
// Copyright 2014 Goran Devic
//
// This module provides control data bus switch signals. The sole purpose of
// having these wires defined in this module is to get all control signals
// (which are processed by genglobals.py) to appear in the list of global
// control signals ("globals.vh") for consistency.
//============================================================================

module bus_switch
(
    input wire ctl_sw_1u,               // Control input for the SW1 upstream
    input wire ctl_sw_1d,               // Control input for the SW1 downstream

    input wire ctl_sw_2u,               // Control input for the SW2 upstream
    input wire ctl_sw_2d,               // Control input for the SW2 downstream

    input wire ctl_sw_mask543_en,       // Enables masking [5:3] on the data bus switch 1

    //--------------------------------------------------------------------

    output wire bus_sw_1u,              // SW1 upstream
    output wire bus_sw_1d,              // SW1 downstream

    output wire bus_sw_2u,              // SW2 upstream
    output wire bus_sw_2d,              // SW2 downstream

    output wire bus_sw_mask543_en       // Affects SW1 downstream
);

assign bus_sw_1u = ctl_sw_1u;
assign bus_sw_1d = ctl_sw_1d;

assign bus_sw_2u = ctl_sw_2u;
assign bus_sw_2d = ctl_sw_2d;

assign bus_sw_mask543_en = ctl_sw_mask543_en;

endmodule
