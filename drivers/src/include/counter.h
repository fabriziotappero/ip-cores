/**
 * \brief Driver for simple counter module.
 * \author Jakob Lechner
 */

#ifndef __counter_h__
#define __counter_h__

#include "drivers.h"

#define COUNTER_CONFIG_C_BOFF      3
#define COUNTER_PRESCALER_BOFF     4
#define COUNTER_COUNT_BIT          0
#define COUNTER_CLEAR_BIT          1
#define COUNTER_VALUE_BOFF         8
/**
 * \brief Initilizes a new handle for a memory mapped module.
 * \param h The handle which is initialized.
 * \param baseAddress The base addresse where the module is mapped.
 */
void counter_initHandle(module_handle_t *h, scarts_addr_t baseAddress);

/**
 * \brief Free dynamically allocated resources.
 * \param h Handle.
 */
void counter_releaseHandle(module_handle_t *h);

/**
 * \brief Set prescaler.
 * \param h Handle.
 * \param prescaler Counter increments every "prescaler+1" clock ticks.
 */
void counter_setPrescaler(module_handle_t *h, uint8_t prescaler);

/**
 * \brief Start counter.
 * \param h Handle.
 */
void counter_start(module_handle_t *h);

/**
 * \brief Stop counter.
 * \param h Handle.
 */
void counter_stop(module_handle_t *h);

/**
 * \brief Resume stopped counter.
 * \param h Handle.
 */
void counter_resume(module_handle_t *h);

/**
 * \brief Reset counter value to zero.
 * \param h Handle.
 */
void counter_reset(module_handle_t *h);

/**
 * \brief Get current counter value.
 * \param h Handle.
 */
uint32_t counter_getValue(module_handle_t *h);

#endif // __counter_h__
