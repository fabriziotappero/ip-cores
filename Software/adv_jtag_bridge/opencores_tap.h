#ifndef _OPENCORES_TAP_H_
#define _OPENCODER_TAP_H_


// Information on the OpenCores JTAG TAP
// Included as a default, in place of a BSDL file
// with the data.

#define JI_SIZE (4)
enum jtag_instr
  {
    JI_EXTEST = 0x0,
    JI_SAMPLE_PRELOAD = 0x1,
    JI_IDCODE = 0x2,
    JI_CHAIN_SELECT = 0x3,
    JI_INTEST = 0x4,
    JI_CLAMP = 0x5,
    JI_CLAMPZ = 0x6,
    JI_HIGHZ = 0x7,
    JI_DEBUG = 0x8,
    JI_BYPASS = 0xF
  };

#endif
