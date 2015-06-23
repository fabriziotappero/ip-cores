/**
    @file b51_cpu.h
    @brief CPU model.

    This file includes the CPU simulation model. Excludes the behavior of the
    CPU peripherals, which is done in b51_mcu.c.

    When implementing different CPU core models, you should modify this file
    by adding conditional code and new functions. Differences between CPU
    cores are going to be small enough -- cycle counts, implementation of
    certain instructions, etc.

    Different cores will have a different set of peripherals, though. That must
    be modelled with a function pointer table against different b51_mcu
    implementations -- meaning one different source file per different core.

    TODO CPU & MCU polymorphism to be done.
*/

#ifndef S51_H_INCLUDED
#define S51_H_INCLUDED

#include <stdint.h>
#include <stdbool.h>

#include "b51_mcu.h"
#include "b51_log.h"


/*-- Configuration macros ----------------------------------------------------*/

/** Size of IRAM in bytes */
#define MAX_IDATA_SIZE              (256)


/*-- Public data types & macros ----------------------------------------------*/


/**
    MCS51 CPU SFRs.
    FIXME should only include the CPU SFRs and not the peripherals.
    Note that ACC, while accessible as an SFR, is not in this struct and is
    handled separately.
*/
typedef struct cpu51_sfr_s {
    uint8_t b;
    uint8_t dph;
    uint8_t dpl;
    uint8_t ie;
    uint8_t ip;
    uint8_t p0;
    uint8_t p1;
    uint8_t p2;
    uint8_t p3;
    uint8_t pcon;
    uint8_t psw;
    uint8_t sbuf;
    uint8_t scon;
    uint8_t sp;
    uint8_t tcon;
    uint8_t th0;
    uint8_t th1;
    uint8_t tl0;
    uint8_t tl1;
    uint8_t tmod;
} cpu51_sfr_t;


typedef struct cpu51_options_s {
    bool bcd;
} cpu51_options_t;


/**
    CPU object. This is the CPU model, which includes the peripherals block
    and the XDATA and XCODE memory blocks as a member object (struct field).
*/
typedef struct cpu51_s {
    uint8_t idata[MAX_IDATA_SIZE];  /**< IDATA RAM */
    uint16_t pc;                    /**< PC -- addr of instruction being run */
    uint8_t a;                      /**< ACC */

    cpu51_sfr_t sfr;                /**< CPU core (non-peripheral) SFRs */
    mcu51_t mcu;                    /**< MCU peripherals model */
    uint32_t cycles;                /**< Clock cycles since last reset */
    bool max_cycle_count;           /**< Last instr. used the max # of cycles */
    bool implemented_as_nop;        /**< Last instr. was decoded as NOP */

    log51_t log;                    /**< Logger data */

    uint16_t breakpoint;            /**< Address of breakpoint */

    cpu51_options_t options;        /**< Core implementation options */
} cpu51_t;


/*-- Public functions --------------------------------------------------------*/

/**
    Initialize CPU model, including peripheral models.
    This does not reset the CPU or the peripherals.
    Use at least once before calling any other function in this API.

    @arg cpu CPU model.
*/
extern void cpu_init(cpu51_t *cpu);

/**
    Simulate a CPU reset, which includes the peripherals too.

    @arg cpu CPU model.
*/
extern void cpu_reset(cpu51_t *cpu);

/**
    Run a number of CPU instructions.
    Execution will stop after running num_inst instructions, or if a
    single-instruction infinite loop is detected, or if a breakpoint is hit.

    @arg cpu CPU model.
    @arg num_inst Number of instructions to be run.
    @return 0 if execution timed out,
            1 if it was interrupted,
            2 for breakpoints.
*/
extern uint32_t cpu_exec(cpu51_t *cpu, uint32_t num_inst);

/**
    Load object code onto XCODE memory.
    Every object byte that fits the XCODE memory will be loaded onto it.
    Note that bytes out of memory bounds will be dropped silently.

    @arg cpu CPU model.
    @arg hex_filename Nam of Intel-HEX file to be loaded.
    @return Number of bytes read from HEX file -- some may have been dropped!.
*/
extern uint16_t cpu_load_code(cpu51_t *cpu, const char *hex_filename);

/**
    Add a new breakpoint at given address.
    The only reasons this function might fail (returning false) are:
    -# Breakpoint address out of XCODE bounds.
    -# Too many breakpoints.

    There's no way to delete breakpoints, and the logic is still weak so this
    must be considered a stub.

    @arg cpu CPU model.
    @arg address Breakpoint address.
    @return True if the breakpoint could be added.
*/
extern bool cpu_add_breakpoint(cpu51_t *cpu, uint16_t address);


#endif // S51_H_INCLUDED
