#ifndef LOG_H_INCLUDED
#define LOG_H_INCLUDED

#include <stdint.h>
#include <stdbool.h>


/**
    Information needed by the MCS51 logger functions.
    Mostly copies of previous values of CPU registers, used to detect and log
    changes to them.
*/
typedef struct log51_s {
    uint16_t pc;
    uint8_t psw;
    uint8_t sp;
    uint8_t a;
    uint32_t executed_instructions;
} log51_t;

/**
    Open log files for writing (erasing previous contents).
    @return True if both files were open successfully.
*/
extern bool log_init(const char *sw_log_file, const char *con_log_file);

/** Close both log files. */
extern void log_close(void);

/**
    Update the logger status: transfer the CPU state to the logger state.
    Do this at the START of every instruction.

    @arg log Logger object.
    @arg pc CPU PC value.
    @arg sp CPU SP value.
    @arg a CPU ACC value.
    @arg psw CPU PSW value.
*/
extern void log_baseline(log51_t *log, uint16_t pc, uint8_t sp, uint8_t a, uint8_t psw);

/**
    Log write access to IDATA memory.

    @arg log Logger object.
    @arg addr IDATA address written to.
    @arg value Value written to IDATA.
*/
extern void log_idata(log51_t *log, uint8_t addr, uint8_t value);

/**
    Log write access to XDATA.

    @arg log Logger object.
    @arg addr XDATA address written to.
    @arg value Value written to XDATA.
*/
extern void log_xdata(log51_t *log, uint16_t addr, uint8_t value);

/**
    Log write access to SFR space.

    @arg log Logger object.
    @arg addr Address of SFR written to.
    @arg value Value written to SFR.
*/
extern void log_sfr(log51_t *log, uint8_t addr, uint8_t value);

/**
    Log jump (including calls and returns).

    @arg log Logger object.
    @arg addr Jump target address.
*/
extern bool log_jump(log51_t *log, uint16_t addr);

/**
    Log attemp to execute an unimplemented instruction.
    (Unimplemented by the simulator OR by the core).

    @arg log Logger object.
    @arg opcode Instruction opcode that triggered the log.
*/
extern void log_unimplemented(log51_t *log, uint8_t opcode);

/**
    Log change to 16-bit register -- DPTR.

    @arg log Logger object.
    @arg msg Name of 16-bit register.
    @arg value Value written to register.
*/
extern void log_reg16(log51_t *log, const char *msg, uint16_t value);

/**
    Compare CPU state (as given by register arguments sp, a and psw) with
    logger state and log any changes.

    @arg log Logger object.
    @arg sp CPU sp value.
    @arg a CPU ACC value.
    @arg psw CPU psw value.
*/
extern void log_status(log51_t *log, uint8_t sp, uint8_t a, uint8_t psw);

/**
    Log character written to the MCU serial port to serial log file.
    FIXME supports only 1 serial port and 1 serial log file.

    @arg c Byte written to the serial port.
*/
extern void log_con_output(char c);

#endif // LOG_H_INCLUDED
