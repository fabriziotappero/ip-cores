//============================================================================
// Z80 Top level using the interface declaration
//============================================================================
`include "z80.svh"

module z80_top_ifc_n (z80_if.dut z80);

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Include core A-Z80 level connecting all internal modules
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
`include "core.vh"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Address, Data and Control bus drivers connecting to external pins
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
address_pins   address_pins_( .*, .abus(z80.A[15:0]) );
data_pins      data_pins_   ( .*, .db(db0[7:0]), .D(z80.D[7:0]) );
control_pins_n control_pins_( .*,
    .pin_nM1      (z80.nM1),
    .pin_nMREQ    (z80.nMREQ),
    .pin_nIORQ    (z80.nIORQ),
    .pin_nRD      (z80.nRD),
    .pin_nWR      (z80.nWR),
    .pin_nRFSH    (z80.nRFSH),
    .pin_nHALT    (z80.nHALT),
    .pin_nWAIT    (z80.nWAIT),
    .pin_nBUSACK  (z80.nBUSACK),
    .pin_nINT     (z80.nINT),
    .pin_nNMI     (z80.nNMI),
    .pin_nRESET   (z80.nRESET),
    .pin_nBUSRQ   (z80.nBUSRQ),
    .CPUCLK       (z80.CLK)
 );

endmodule
