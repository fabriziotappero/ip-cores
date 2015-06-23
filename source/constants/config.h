#ifndef _CONFIG_H
#define _CONFIG_H

/*
  add Pipelined Multiplicator
*/
#define _MULT_PIPELINE_

/*
  set the depth of the pipeline Multiplicator
  For combinatorial Multiplier, set 0
*/
#define DEPTH_MULT_PIPE 3  


/*!
  add ocp connection to the cpu
*/
#define _OCP_

/*
 * The starting address for PC upon RESET
 */
#define PC_START 0

/*!
  Size of memory ramb4_s16_s16
*/
#define MEMSIZE 32768
// #define _MEMOFF_ 492


/*!
  no speciel elements for synthesis or back ann
*/
#define _HIGH_LEVEL_SIM_ 1
#include <stdio.h>

/*
  Write various debug output...
 */
#define _DEBUG_ 1

/*!
  Write signal values with every clock cycle
*/
#define DEBUG_SIGNALS 1

/*
  Write instructions to output
 */
#define _DEBUG_INSTRUCTION_ 1

/*
  Write ***...for each clock tick
 */
#define CLOCK_DEBUG 1

/*
  Write regfile contents upon writes
 */
#define REGFILE_DEBUG 1

/*
  Each clock cycle (cc), do a memory-dump to file...
 */
#define _CC_MEMDUMP_ 1

/*
 Write PC (in ID stage) every cc.
 */
#define DEBUG_PC 1

/*
  Write RAM inputs and outputs
 */
//#define _DEBUG_MEMORY_ 1


/*!
  Memory map
  From: 0x7FFFFF00
  To  : 0x7FFFFFFC
*/
#define OCP_MAP      "01111111111111111111111000000000"
#define OCP_MAP_STOP "01111111111111111111111111110100"
#define FD3_MAP      "01111111111111111111111111111000"
#define STOP_CPU_MAP "01111111111111111111111111111100"

/*!
  Memory map
  From: 0x7FFFFD00
  To  : 0x7FFFFDFC
*/
#define OCP_MAP_GCD      "01111111111111111111110100000000"
#define OCP_MAP_STOP_GCD "01111111111111111111110111111100"


/*
  Defines for including various stages of the pipeline in the trace-file.
*/
#define SIGNAL_SC_CPU 1
#define SIGNAL_PC_STAGE 1
#define SIGNAL_IF_STAGE 1
#define SIGNAL_ID_STAGE 1
#define SIGNAL_EX_STAGE 1
#define SIGNAL_MEM_STAGE 1
#define SIGNAL_WB_STAGE 1
#define SIGNAL_CP0 1
#define SIGNAL_OCP 1
#define SIGNAL_OCP_GCD 1
#define SIGNAL_DATAMEM 1


/*
  Very special options for creating traces for Power Compiler
  Don't define more than one of these at a time!
*/
//#define SIGNAL_SC_CPU_INPUTS_ONLY 1
//#define SIGNAL_PC_STAGE_INPUTS_ONLY 1
//define SIGNAL_IF_STAGE_INPUTS_ONLY 1
//#define SIGNAL_ID_STAGE_INPUTS_ONLY 1
//#define SIGNAL_EX_STAGE_INPUTS_ONLY 1
//#define SIGNAL_MEM_STAGE_INPUTS_ONLY 1

/*
  Do not modify below!
*/
#if defined(SIGNAL_SC_CPU_INPUTS_ONLY)
#undef SIGNAL_PC_STAGE
#undef SIGNAL_IF_STAGE
#undef SIGNAL_ID_STAGE
#undef SIGNAL_EX_STAGE
#undef SIGNAL_MEM_STAGE
#undef SIGNAL_WB_STAGE
#undef SIGNAL_CP0
#undef SIGNAL_OCP
#undef SIGNAL_OCP_GCD
#undef SIGNAL_DATAMEM
#endif

#if defined(SIGNAL_PC_STAGE_INPUTS_ONLY)
#undef SIGNAL_SC_CPU
#undef SIGNAL_IF_STAGE
#undef SIGNAL_ID_STAGE
#undef SIGNAL_EX_STAGE
#undef SIGNAL_MEM_STAGE
#undef SIGNAL_WB_STAGE
#undef SIGNAL_CP0
#undef SIGNAL_OCP
#undef SIGNAL_OCP_GCD
#undef SIGNAL_DATAMEM
#endif

#if defined(SIGNAL_IF_STAGE_INPUTS_ONLY)
#undef SIGNAL_SC_CPU
#undef SIGNAL_PC_STAGE
#undef SIGNAL_ID_STAGE
#undef SIGNAL_EX_STAGE
#undef SIGNAL_MEM_STAGE
#undef SIGNAL_WB_STAGE
#undef SIGNAL_CP0
#undef SIGNAL_OCP
#undef SIGNAL_OCP_GCD
#undef SIGNAL_DATAMEM
#endif

#if defined(SIGNAL_ID_STAGE_INPUTS_ONLY)
#undef SIGNAL_SC_CPU
#undef SIGNAL_PC_STAGE
#undef SIGNAL_IF_STAGE
#undef SIGNAL_EX_STAGE
#undef SIGNAL_MEM_STAGE
#undef SIGNAL_WB_STAGE
#undef SIGNAL_CP0
#undef SIGNAL_OCP
#undef SIGNAL_OCP_GCD
#undef SIGNAL_DATAMEM
#endif

#if defined(SIGNAL_EX_STAGE_INPUTS_ONLY)
#undef SIGNAL_SC_CPU
#undef SIGNAL_PC_STAGE
#undef SIGNAL_IF_STAGE
#undef SIGNAL_ID_STAGE
#undef SIGNAL_MEM_STAGE
#undef SIGNAL_WB_STAGE
#undef SIGNAL_CP0
#undef SIGNAL_OCP
#undef SIGNAL_OCP_GCD
#undef SIGNAL_DATAMEM
#endif

#if defined(SIGNAL_EX_STAGE_INPUTS_ONLY)
#undef SIGNAL_SC_CPU
#undef SIGNAL_PC_STAGE
#undef SIGNAL_IF_STAGE
#undef SIGNAL_ID_STAGE
#undef SIGNAL_MEM_STAGE
#undef SIGNAL_WB_STAGE
#undef SIGNAL_CP0
#undef SIGNAL_OCP
#undef SIGNAL_OCP_GCD
#undef SIGNAL_DATAMEM
#endif

#if defined(SIGNAL_MEM_STAGE_INPUTS_ONLY)
#undef SIGNAL_SC_CPU
#undef SIGNAL_PC_STAGE
#undef SIGNAL_IF_STAGE
#undef SIGNAL_ID_STAGE
#undef SIGNAL_EX_STAGE
#undef SIGNAL_WB_STAGE
#undef SIGNAL_CP0
#undef SIGNAL_OCP
#undef SIGNAL_OCP_GCD
#undef SIGNAL_DATAMEM
#endif

#endif
