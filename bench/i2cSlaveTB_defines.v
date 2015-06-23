// ---------------------------- i2cSlaveTB_defines.v -----------------
`define SEND_START 1'b1
`define SEND_STOP 1'b1
`define NULL 1'b0
`define ACK 1'b0
`define NACK 1'b1

`define DEV_I2C_ADDR 8'hcc 

`define PRER_LO_REG 3'b000
`define PRER_HI_REG 3'b001
`define CTR_REG 3'b010
`define RXR_REG 3'b011
`define TXR_REG 3'b011
`define CR_REG 3'b100
`define SR_REG 3'b100

