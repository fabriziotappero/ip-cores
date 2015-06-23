#include "dis7seg.h"

#define CMD_SETVALUE 0x40
#define CMD_SETDOT 0x80
#define CMD_GETVALUE 0xC0
#define MIN(x,y) (((x) < (y)) ? (x) : (y))

void dis7seg_initHandle(dis7seg_handle_t *h, scarts_addr_t baseAddress, uint8_t segmentCount) {
  h->baseAddress = baseAddress;
  h->segmentCount = segmentCount;
}

void dis7seg_releaseHandle(dis7seg_handle_t *h) {
}

void dis7seg_setPrescaler(dis7seg_handle_t *h, uint16_t value) {
  volatile uint16_t *reg = (uint16_t *)(h->baseAddress+DISP7SEG_PRESC_L_BOFF);
  *reg = value;
}

void dis7seg_setDigitValue(dis7seg_handle_t *h, uint8_t index, uint8_t value) {
  volatile uint8_t *reg;
  reg = (uint8_t *)(h->baseAddress+DISP7SEG_DISPLAY_CMD);
  *reg = CMD_SETVALUE | (index & 0x3F);
  reg = (uint8_t *)(h->baseAddress+DISP7SEG_DISPLAY_VALUE);
  *reg = value;
}


void dis7seg_displayUInt8(dis7seg_handle_t *h, uint8_t index, uint8_t value) {  
  int i=0;
  for (i=0; i<MIN(3, h->segmentCount); i++) {
    dis7seg_setDigitValue(h, index+i, (value % 10));    
    value /= 10;
  }
}

void dis7seg_displayUInt16(dis7seg_handle_t *h, uint8_t index, uint16_t value) {  
  int i=0;
  for (i=0; i<MIN(5, h->segmentCount); i++) {
    dis7seg_setDigitValue(h, index+i, (value % 10));    
    value /= 10;
  }
}

void dis7seg_displayUInt32(dis7seg_handle_t *h, uint8_t index, uint32_t value) {  
  int i=0;
  for (i=0; i<MIN(10, h->segmentCount); i++) {
    dis7seg_setDigitValue(h, index+i, (value % 10));    
    value /= 10;
  }
}

void dis7seg_displayHexUInt8(dis7seg_handle_t *h, uint8_t index, uint8_t value) {
  dis7seg_setDigitValue(h, index, value & 0x0F);
  dis7seg_setDigitValue(h, index+1, value >> 4);
}

void dis7seg_displayHexUInt16(dis7seg_handle_t *h, uint8_t index, uint16_t value) {
  int i=0;
  for (i=0; i<4; i++) {
    dis7seg_setDigitValue(h, index+i, value >> (i*4) & 0x000F);
  }
}

void dis7seg_displayHexUInt32(dis7seg_handle_t *h, uint8_t index, uint32_t value) {
  int i=0;
  for (i=0; i<8; i++) {
    dis7seg_setDigitValue(h, index+i, value >> (i*4) & 0x000F);
  }
}

uint8_t dis7seg_getDigitValue(dis7seg_handle_t *h, uint8_t index) {
  volatile uint8_t *reg;
  // set display index
  reg = (uint8_t *)(h->baseAddress+DISP7SEG_DISPLAY_CMD);
  *reg = CMD_GETVALUE | (index & 0x3F);
  // get value
  reg = (uint8_t *)(h->baseAddress+DISP7SEG_DISPLAY_VALUE);
  return *reg;
}

void dis7seg_setDigitDot(dis7seg_handle_t *h, uint8_t index, uint8_t enabled) {
  // not implemented
}
