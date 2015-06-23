/**
 * \brief Driver for key matrix module.
 */

#ifndef __key_matrix_h__
#define __key_matrix_h__

#include "drivers.h"

#define KEY_MATRIX_PRESSED_KEY          4

/**
 * \brief Initilizes a new handle for a memory mapped module.
 * \param h The handle which is initialized.
 * \param baseAddress The base addresse where the module is mapped.
 */
void key_matrix_initHandle(module_handle_t *h, scarts_addr_t baseAddress);

/**
 * \brief Free dynamically allocated resources.
 * \param h Handle.
 */
void key_matrix_releaseHandle(module_handle_t *h);

/**
 * \brief Query which button has been pressed last.
 *   This is typically done in the interrupt service routine.
 * \param h Handle.
 */
uint8_t key_matrix_get_key(module_handle_t *h);

/**
 * \brief Send acknowledgement to hardware module that interrupt
 *   has been processed. This needs to be done at the end of the
 *   interrupt service routine.
 * \param h Handle.
 */
void key_matrix_irq_ack(module_handle_t *h);


#endif // __key_matrix_h__
