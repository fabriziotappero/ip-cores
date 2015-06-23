/**
 * \brief Driver for apbvga AMBA module from the GRLIB 
 * \author Martin Luipersbeck
 */


#ifndef __VGATEXT_H__
#define __VGATEXT_H__

#include "drivers.h"

#define VGATEXT_DATA             0
#define VGATEXT_BG_COLOR         4
#define VGATEXT_FG_COLOR         8

/**
 * \struct module_handle_t
 * \brief Stores context for access of a specific extension module.
 */
typedef struct {
  scarts_addr_t baseAddress;
  uint16_t cursor;
} vgatext_handle_t;


#include <stdint.h>

/**
 * \brief Initializes handle. Clears the screen and sets back- and 
 *   foreground color to default values.
 * \param h Handle.
 * \param baseAddress Base address of the hardware module.
 */
void vgatext_initHandle(vgatext_handle_t *h, scarts_addr_t baseAddress);

/**
 * \brief Frees all allocated resources for module handle.
 * \param h Handle.
 */
void vgatext_releaseHandle(vgatext_handle_t *h);

/**
 * \brief Clears the screen.
 * \param h Handle.
 */
void vgatext_clear(vgatext_handle_t *h);

/**
 * \brief Sets the cursor position where characters are drawn.
 * \param h Handle.
 * \param c Cursor position. Possible value range: 0 - 4079.
 */
void vgatext_set_cursor(vgatext_handle_t *h, uint16_t c);

/**
 * \brief Moves the cursor to the next line.
 * \param h Handle.
 */
void vgatext_newline(vgatext_handle_t *h);

/**
 * \brief Draws a given 8-bit value as hexadecimal string 
 *   at the current cursor position.
 * \param h Handle.
 * \param value Output value.
 */
void vgatext_printByteHex(vgatext_handle_t *h, uint8_t value);

/**
 * \brief Draws a given 32-bit value as hexadecimal string 
 * at the current cursor position.
 * \param h Handle.
 * \param value Output value.
 */
void vgatext_printIntHex(vgatext_handle_t *h, uint32_t value);

/**
 * \brief Draws a given 32-bit value as decimal string 
 *   at the current cursor position.
 * \param h Handle.
 * \value value Output value.
 */
void vgatext_printUInt(vgatext_handle_t *h, uint32_t value);

/**
 * \brief Draws a given string at the current cursor position. 
 * \param h Handle.
 * \param pStr String pointer.
 * \param length String length.
 */
void vgatext_print_str(vgatext_handle_t *h, const char* pStr, int length);

/**
 * \brief Draws a character at the current cursor position.
 * \param h Handle.
 * \param c Output character.
 */
void vgatext_print_char(vgatext_handle_t *h, uint8_t c);

/**
 * \brief Sets the foreground color.
 * \param h Handle.
 * \param r Red color value.
 * \param g Green color value.
 * \param b Blue color value.
 */
void vgatext_set_fg_color(vgatext_handle_t *h, uint8_t r, uint8_t g, uint8_t b);

/**
 * \brief Sets the background color.
 * \param h Handle.
 * \param r Red color value.
 * \param g Green color value.
 * \param b Blue color value.
 */
void vgatext_set_bg_color(vgatext_handle_t *h, uint8_t r, uint8_t g, uint8_t b);

#endif // __VGATEXT_H__
