/**
    @file b51_mcu.h
    @brief MCU model -- core peripherals.
*/

#ifndef S51_PERIPHERALS_H_INCLUDED
#define S51_PERIPHERALS_H_INCLUDED

#include <stdint.h>
#include <stdbool.h>

#define MAX_XCODE_SIZE              (64 * 1024)
#define MAX_XDATA_SIZE              (64 * 1024)

#define NUM_IRQS (5)


/** SFRs for this implementation of the MCU. */
/* FIXME remove unused stock SFRs */
typedef struct mcu51_sfr_s {
    uint8_t p0;
    uint8_t p1;
    uint8_t p2;
    uint8_t p3;
    uint8_t pcon;
    uint8_t sbuf;
    uint8_t scon;
    uint8_t tcon;
    uint8_t th0;
    uint8_t th1;
    uint8_t tl0;
    uint8_t tl1;
    uint8_t tmod;
} mcu51_sfr_t;

/**
    MCU model.
    In its present state, this is neither a MCS51 model nor a light52.
    Consider this a dummy.
*/
typedef struct mcu51_s {
    uint8_t xcode[MAX_XCODE_SIZE];      /**< XCODE memory image */
    uint8_t xdata[MAX_XDATA_SIZE];      /**< XDATA memory image */

    mcu51_sfr_t sfr;                    /**< MCU (peripheral) SFRs */
    uint32_t irq_countdown[NUM_IRQS];   /**< Dummy IRQ simulators */
} mcu51_t;

/*-- Public functions --------------------------------------------------------*/

/**
    Initialize MCU model.
    This does NOT perform a reset on the simulated HW.
    Call this once before calling any other function in this API.

    @arg mcu MCU model.
*/
extern void mcu_init(mcu51_t *mcu);

/**
    Reset simulated hardware.

    @arg mcu MCU model.
*/
extern void mcu_reset(mcu51_t *mcu);

/**
    Write data to SFR and simulate side effects if any.

    @arg mcu MCU model.
    @arg dir Address of SFR.
    @arg value Data written to SFR.
*/
extern uint16_t mcu_set_sfr(mcu51_t *mcu, uint8_t dir, uint8_t value);

/**
    Read from SFR.

    @arg mcu MCU model.
    @arg dir SFR address.
    @return Value of SFR or undefined value for unimplemented SFRs.
*/
extern uint16_t mcu_get_sfr(mcu51_t *mcu, uint8_t dir);

/**
    Simulates a given number of clock cycles in the peripheral hardware.
    Call this at the end of every simulated instruction to keep the peripheral
    HW state in sync with the CPU state.

    @arg mcu MCU model.
    @arg states Number of clock cycles o simulate.
*/
extern void mcu_update(mcu51_t *mcu, uint32_t states);

#endif // S51_PERIPHERALS_H_INCLUDED
