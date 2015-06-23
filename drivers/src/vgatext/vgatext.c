/*
 * Project: AMBA-Modules for SCARTS
 * Author : Martin Luipersbeck
 * 
 * Description: Driver for apbvga module
 *
 */

#include "vgatext.h"

#define TO_HEX_CHAR(num) ((num) < 10 ? (num) + 0x30 : (num) + 0x37)
#define TO_DEC_CHAR(num) ((num) + 0x30)

#define CURSOR_MAX 4079
#define CAP_CURSOR(cursor) (cursor) = ((cursor) > CURSOR_MAX ? 0 : (cursor))
#define INC_CURSOR(cursor) (cursor) = ((cursor)++; (cursor) > CURSOR_MAX ? 0 : (cursor))

#define GET_HEX_LETTER(value, index, cursor) (TO_HEX_CHAR((((value)>>((index)*4)) & 0x0F)) + ((cursor)<<8))


void vgatext_initHandle(vgatext_handle_t *h, scarts_addr_t baseAddress) 
{
  h->baseAddress = baseAddress;
  h->cursor = 0;
  
  vgatext_set_fg_color(h, 0, 255, 0);
  vgatext_set_bg_color(h, 0, 0, 0);
  
  vgatext_clear(h);
}

void vgatext_releaseHandle(vgatext_handle_t *h)
{
}

void vgatext_clear(vgatext_handle_t *h) 
{
  uint8_t i, j;
  volatile uint32_t *data;
  
  data = (uint32_t *)(h->baseAddress+VGATEXT_DATA);

  while(h->cursor < CURSOR_MAX) {
    for(j = 0; j < 80; j++) {
      *data = (uint32_t)((h->cursor<<8) + 0x20);
      h->cursor++;
    }
  }
  h->cursor = 0;
  for(i = 0; i < 36; i++) {
    vgatext_newline(h);
  }

  h->cursor = 0;
}

void vgatext_set_cursor(vgatext_handle_t *h, uint16_t c)
{
  h->cursor = c;
}

void vgatext_newline(vgatext_handle_t *h)
{
  uint8_t j;
  volatile uint32_t *data = (uint32_t *)(h->baseAddress+VGATEXT_DATA);

  h->cursor = h->cursor - h->cursor % 0x50 + 0x50;
  for(j = 0; j < 80; j++) {
    *data = (uint32_t)((h->cursor<<8) + 0x20);
    h->cursor++;
  }
  h->cursor -= 0x50;
  CAP_CURSOR(h->cursor);
}

void vgatext_printByteHex(vgatext_handle_t *h, uint8_t value)
{
  uint8_t out;
  volatile uint32_t *data = (uint32_t *)(h->baseAddress+VGATEXT_DATA);

  out = (value>>4) & 0x0F;
  *data = (uint32_t)(TO_HEX_CHAR(out)) + (uint32_t)(h->cursor<<8);
  h->cursor++;
  CAP_CURSOR(h->cursor);
	
  out = value & 0x0F;
  *data = (uint32_t)(TO_HEX_CHAR(out)) + (uint32_t)(h->cursor<<8);
  h->cursor++;
  CAP_CURSOR(h->cursor);
}

void vgatext_printIntHex(vgatext_handle_t *h, uint32_t value)
{
  uint8_t i;
  volatile uint32_t *data = (uint32_t *)(h->baseAddress+VGATEXT_DATA);

  for(i = 0; i < 8; i++) {
    *data = GET_HEX_LETTER(value, (7-i), h->cursor);
    h->cursor++;
    CAP_CURSOR(h->cursor);
  }
}

void vgatext_printUInt(vgatext_handle_t *h, uint32_t value)
{
  uint8_t length = 0;
  uint8_t chars[10];
  volatile uint32_t *data = (uint32_t *)(h->baseAddress+VGATEXT_DATA);

  while(length < 10) {
    chars[length] = TO_DEC_CHAR(value % 10);
    length++;
    value /= 10;
    if(value == 0) {
      break;
    }
  }

  while(length > 0) {
    *data = chars[length-1] + (h->cursor<<8);
    length--;
    h->cursor++;
    CAP_CURSOR(h->cursor);
  }
}

void vgatext_print_str(vgatext_handle_t *h, const char* pStr, int length)
{
  uint8_t i = 0;
  volatile uint32_t *data = (uint32_t *)(h->baseAddress+VGATEXT_DATA);
  for(i = 0; i < length; i++) {
    *data = (uint32_t)(pStr[i]) + (uint32_t)(h->cursor<<8);
    h->cursor++;
    CAP_CURSOR(h->cursor);
  }
}

void vgatext_print_char(vgatext_handle_t *h, uint8_t c)
{
  volatile uint32_t *data = (uint32_t *)(h->baseAddress+VGATEXT_DATA);
  *data = (uint32_t)(c) + (uint32_t)(h->cursor<<8);
  h->cursor++;
  CAP_CURSOR(h->cursor);
}

void vgatext_set_fg_color(vgatext_handle_t *h, uint8_t r, uint8_t g, uint8_t b)
{
  volatile uint32_t *data = (uint32_t *)(h->baseAddress+VGATEXT_FG_COLOR);
  uint32_t color = (r << 16) | (g << 8) | b;
  *data = color;
}

void vgatext_set_bg_color(vgatext_handle_t *h, uint8_t r, uint8_t g, uint8_t b)
{
  volatile uint32_t *data = (uint32_t *)(h->baseAddress+VGATEXT_BG_COLOR);
  uint32_t color = (r << 16) | (g << 8) | b;
  *data = color;
}

