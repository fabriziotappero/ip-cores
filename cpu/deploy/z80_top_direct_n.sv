//============================================================================
// Z80 Top level using the direct module declaration
//============================================================================
`timescale 1us/ 100 ns

module z80_top_direct_n(
    output wire nM1,
    output wire nMREQ,
    output wire nIORQ,
    output wire nRD,
    output wire nWR,
    output wire nRFSH,
    output wire nHALT,
    output wire nBUSACK,

    input wire nWAIT,
    input wire nINT,
    input wire nNMI,
    input wire nRESET,
    input wire nBUSRQ,

    input wire CLK,
    output wire [15:0] A,
    inout wire [7:0] D
);

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Include core A-Z80 level connecting all internal modules
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
`include "core.vh"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Address, Data and Control bus drivers connecting to external pins
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
address_pins   address_pins_( .*, .abus(A[15:0]) );
data_pins      data_pins_   ( .*, .db(db0[7:0]), .D(D[7:0]) );
control_pins_n control_pins_( .*,
    .pin_nM1      (nM1),
    .pin_nMREQ    (nMREQ),
    .pin_nIORQ    (nIORQ),
    .pin_nRD      (nRD),
    .pin_nWR      (nWR),
    .pin_nRFSH    (nRFSH),
    .pin_nHALT    (nHALT),
    .pin_nWAIT    (nWAIT),
    .pin_nBUSACK  (nBUSACK),
    .pin_nINT     (nINT),
    .pin_nNMI     (nNMI),
    .pin_nRESET   (nRESET),
    .pin_nBUSRQ   (nBUSRQ),
    .CPUCLK       (CLK)
 );

endmodule
