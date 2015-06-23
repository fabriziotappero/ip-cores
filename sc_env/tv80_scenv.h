/* This file contains defines which are common to both the
 * SystemC testbench and the SDCC/Z80 C tests.  This should
 * contain only defines and statements which can be understood
 * by both SDCC and gcc.  Any types referenced should use the
 * stdint.h types rather than int/char.
 */

#ifndef TV80_SCENV_H_
#define TV80_SCENV_H_

#define SIM_CTL_PORT     0x80
#define MSG_PORT         0x81
#define TIMEOUT_PORT     0x82
#define MAX_TIMEOUT_LOW  0x83
#define MAX_TIMEOUT_HIGH 0x84
#define INTR_CNTDWN      0x90
#define CKSUM_VALUE      0x91
#define CKSUM_ACCUM      0x92
#define INC_ON_READ      0x93
#define RANDVAL          0x94
#define NMI_CNTDWN       0x95
#define NMI_TRIG_OPCODE  0xA0

#define SC_TEST_PASSED   0x01
#define SC_TEST_FAILED   0x02
#define SC_DUMPON        0x03
#define SC_DUMPOFF       0x04

#endif /*TV80_SCENV_H_*/
