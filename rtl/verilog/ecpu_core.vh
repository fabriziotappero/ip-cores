`define INITIALIZE        0
`define IDLE              1
`define INSTR_FETCH       2
`define DATA_FETCH        3
`define READ_ALU          4
`define RAM_READ          5
`define RAM_WRITE         6
`define HALT_CPU          7

/////////////////////////////
// ACC select options
// size of the ACC select bus
`define A_ACC_SEL         4
`define B_ACC_SEL         4
// ACC select options
`define ROM_OUT           4'd0
`define ALU_OUT           4'd1
