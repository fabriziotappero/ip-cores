#ifndef _ALTERA_VIRTUAL_JTAG_H_
#define _ALTERA_VIRTUAL_JTAG_H_

// Contains constants relevant to the Altera Virtual JTAG
// device, which are not included in the BSDL.
// As of this writing, these are constant across every
// device which supports virtual JTAG.

// These are commands for the FPGA's IR
#define ALTERA_CYCLONE_CMD_VIR     0x0E
#define ALTERA_CYCLONE_CMD_VDR     0x0C

// These defines are for the virtual IR (not the FPGA's)
// The virtual TAP was defined in hardware to match the OpenCores native
// TAP in both IR size and DEBUG command.
#define ALT_VJTAG_IR_SIZE    4
#define ALT_VJTAG_CMD_DEBUG  0x8

#endif
