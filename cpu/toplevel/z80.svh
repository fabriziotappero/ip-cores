//============================================================================
// Z80 Top level interface
//============================================================================
`ifndef Z80_IFC
`define Z80_IFC

`timescale 100 ns/ 100 ns

// Define set and clear for the negative logic pins
`define CLR 1
`define SET 0

interface z80_if (input logic CLK);
    logic nM1, nMREQ, nIORQ, nRD, nWR, nRFSH, nHALT, nBUSACK;
    logic nWAIT, nINT, nNMI, nRESET, nBUSRQ;
    logic [15:0] A;
    wire  [7:0] D;

//=================================================
// Modport for the CPU module (internal) interface
// Also considered "design under test" port
//=================================================
modport dut (
    output nM1, nMREQ, nIORQ, nRD, nWR, nRFSH, nHALT, nBUSACK,
    input  nWAIT, nINT, nNMI, nRESET, nBUSRQ,
    input  CLK,
    output A,
    inout  D);

//=================================================
// Modport for the user (external) pin interface
// Also considered a "test bench" port
//=================================================
modport tb (
    input  nM1, nMREQ, nIORQ, nRD, nWR, nRFSH, nHALT, nBUSACK,
    output nWAIT, nINT, nNMI, nRESET, nBUSRQ,
    input  CLK,
    input  A,
    inout  D);

endinterface : z80_if

`endif
