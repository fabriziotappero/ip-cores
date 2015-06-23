// ----------------------- i2cSlave_define.v --------------------

// stream states
`define STREAM_IDLE 2'b00
`define STREAM_READ 2'b01
`define STREAM_WRITE_ADDR 2'b10
`define STREAM_WRITE_DATA 2'b11

// start stop detection states
`define NULL_DET 2'b00
`define START_DET 2'b01
`define STOP_DET 2'b10

// i2c ack and nak
`define I2C_NAK 1'b1
`define I2C_ACK 1'b0

// ----------------------------------------------------------------
// ------------- modify constants below this line -----------------
// ----------------------------------------------------------------

// i2c device address
`define I2C_ADDRESS 7'h3c

// System clock frequency in MHz
// If you are using a clock frequency below 24MHz, then the macro
// for SDA_DEL_LEN will result in compile errors for i2cSlave.v
// you will need to hand tweak the SDA_DEL_LEN constant definition
`define CLK_FREQ 48

// Debounce SCL and SDA over this many clock ticks
// The rise time of SCL and SDA can be up to 1000nS (in standard mode)
// so it is essential to debounce the inputs.
// The spec requires 0.05V of hysteresis, but in practise
// simply debouncing the inputs is sufficient
// I2C spec requires suppresion of spikes of 
// maximum duration 50nS, so this debounce time should be greater than 50nS
// Also increases data hold time and decreases data setup time
// during an I2C read operation
// 10 ticks = 208nS @ 48MHz
`define DEB_I2C_LEN (10*`CLK_FREQ)/48

// Delay SCL for use as internal sampling clock
// Using delayed version of SCL to ensure that 
// SDA is stable when it is sampled.
// Not entirely citical, as according to I2C spec
// SDA should have a minimum of 100nS of set up time
// with respect to SCL rising edge. But with the very slow edge 
// speeds used in I2C it is better to err on the side of caution.
// This delay also has the effect of adding extra hold time to the data
// with respect to SCL falling edge. I2C spec requires 0nS of data hold time.
// 10 ticks = 208nS @ 48MHz
`define SCL_DEL_LEN (10*`CLK_FREQ)/48

// Delay SDA for use in start/stop detection
// Use delayed SDA during start/stop detection to avoid
// incorrect detection at SCL falling edge.
// From I2C spec start/stop setup is 600nS with respect to SCL rising edge
// and start/stop hold is 600nS wrt SCL falling edge.
// So it is relatively easy to discriminate start/stop,
// but data setup time is a minimum of 100nS with respect to SCL rising edge
// and 0nS hold wrt to SCL falling edge.
// So the tricky part is providing robust start/stop detection
// in the presence of regular data transitions.
// This delay time should be less than 100nS
// 4 ticks = 83nS @ 48MHz
`define SDA_DEL_LEN (4*`CLK_FREQ)/48

