/**
 * \brief Driver for 7-segment module.
 */

#ifndef __dis7seg_h__
#define __dis7seg_h__

#include "drivers.h"

#define DISP7SEG_STATUS_BOFF            0
#define DISP7SEG_STATUS_LOOR            0x7
#define DISP7SEG_STATUS_FSS             0x4
#define DISP7SEG_STATUS_BUSY            0x3
#define DISP7SEG_STATUS_ERR             0x2
#define DISP7SEG_STATUS_RDY             0x1
#define DISP7SEG_STATUS_INT             0x0

#define DISP7SEG_CONFIG_BOFF            2
#define DISP7SEG_CONFIG_LOOW            0x7
#define DISP7SEG_CONFIG_EFSS            0x4
#define DISP7SEG_CONFIG_OUTD            0x3
#define DISP7SEG_CONFIG_SRES            0x2
#define DISP7SEG_CONFIG_ID              0x1
#define DISP7SEG_CONFIG_INTA            0x0

#define DISP7SEG_PRESC_L_BOFF           4
#define DISP7SEG_PRESC_H_BOFF           5
#define DISP7SEG_DISPLAY_CMD            6
#define DISP7SEG_DISPLAY_VALUE          7

/**
 * \struct dis7seg_handle_t
 * \brief Stores context for access of a specific extension module.
 */
typedef struct {
  scarts_addr_t baseAddress;
  uint8_t segmentCount;
} dis7seg_handle_t;


/**
 * \brief Initilizes a new handle for a memory mapped module.
 * \param h The handle which is initialized.
 * \param baseAddress The base addresse where the module is mapped.
 * \param segmentCount The number of available segments.
 */
void dis7seg_initHandle(dis7seg_handle_t *h, scarts_addr_t baseAddress, uint8_t segmentCount);

/**
 * \brief Free dynamically allocated resources.
 * \param h Handle.
 */
void dis7seg_releaseHandle(dis7seg_handle_t *h);

/**
 * \brief Sets the prescaler for multiplexing digits.
 * \param h Handle.
 * \param value Specifies the number of clock cycles for multiplexing the digits.
 */
void dis7seg_setPrescaler(dis7seg_handle_t *h, uint16_t value);

/**
 * \brief Display a value on a specific digit.
 * \param h Handle.
 * \param index Specifies which digit is used.
 * \param value Displayed value.
 */
void dis7seg_setDigitValue(dis7seg_handle_t *h, uint8_t index, uint8_t value);


void dis7seg_displayUInt(dis7seg_handle_t *h, uint8_t index, uint32_t value);


/**
 * \brief Display a byte value on two digits.
 * \param h Handle.
 * \param index Specifies the index of the first digit. 
 *    The second digit is written on index+1.
 * \param value Displayed value.
 */
void dis7seg_displayUInt8(dis7seg_handle_t *h, uint8_t index, uint8_t value);

/**
 * \brief Display a 2-byte value on four digits.
 * \param h Handle.
 * \param index Specifies the index of the first digit. 
 *    The second digit is written on index+1, etc.
 * \param value Displayed value.
 */
void dis7seg_displayUInt16(dis7seg_handle_t *h, uint8_t index, uint16_t value);

/**
 * \brief Display a 4-byte value on eight digits.
 * \param h Handle.
 * \param index Specifies the index of the first digit. 
 *    The second digit is written on index+1, etc.
 * \param value Displayed value.
 */
void dis7seg_displayUInt32(dis7seg_handle_t *h, uint8_t index, uint32_t value);

/**
 * \brief Display a byte value as hexadecimal number on two digits.
 * \param h Handle.
 * \param index Specifies the index of the first digit. 
 *    The second digit is written on index+1.
 * \param value Displayed value.
 */
void dis7seg_displayHexUInt8(dis7seg_handle_t *h, uint8_t index, uint8_t value);

/**
 * \brief Display a 2-byte value as hexadecimal number on four digits.
 * \param h Handle.
 * \param index Specifies the index of the first digit. 
 *    The second digit is written on index+1, etc.
 * \param value Displayed value.
 */
void dis7seg_displayHexUInt16(dis7seg_handle_t *h, uint8_t index, uint16_t value);

/**
 * \brief Display a 4-byte value as hexadecimal number on eight digits.
 * \param h Handle.
 * \param index Specifies the index of the first digit. 
 *    The second digit is written on index+1, etc.
 * \param value Displayed value.
 */
void dis7seg_displayHexUInt32(dis7seg_handle_t *h, uint8_t index, uint32_t value);


/**
 * \brief Get the currently displayed value of a specific digit.
 * \param h Handle.
 * \param index Specifies the index of the digit. 
 * \return The Displayed value.
 */
uint8_t dis7seg_getDigitValue(dis7seg_handle_t *h, uint8_t index);

/**
 * \brief Enable/disable the dot segment of a specific digit.
 * \param h Handle.
 * \param index Specifies the index of the digit. 
 * \param enabled 1..enabled, 0..disabled.
 */

/**
 * \brief Display a byte value on two digits.
 * \param h Handle.
 * \param index Specifies the index of the first digit. 
 *    The second digit is written on index+1.
 * \param value Displayed value.
 */
void dis7seg_displayByte(dis7seg_handle_t *h, uint8_t index, uint8_t value);

/**
 * \brief Display a 2-byte value on four digits.
 * \param h Handle.
 * \param index Specifies the index of the first digit. 
 *    The second digit is written on index+1, etc.
 * \param value Displayed value.
 */
void dis7seg_displayHalfword(dis7seg_handle_t *h, uint8_t index, uint16_t value);

/**
 * \brief Display a 4-byte value on eight digits.
 * \param h Handle.
 * \param index Specifies the index of the first digit. 
 *    The second digit is written on index+1, etc.
 * \param value Displayed value.
 */
void dis7seg_displayWord(dis7seg_handle_t *h, uint8_t index, uint32_t value);


void dis7seg_setDigitDot(dis7seg_handle_t *h, uint8_t index, uint8_t enabled);

#endif // __dis7seg_h__
