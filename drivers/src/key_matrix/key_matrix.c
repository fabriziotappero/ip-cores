#include "key_matrix.h"

void key_matrix_initHandle(module_handle_t *h, scarts_addr_t baseAddress) {
  h->baseAddress = baseAddress;
}

void key_matrix_releaseHandle(module_handle_t *h) {
}

uint8_t key_matrix_get_key(module_handle_t *h) {
  volatile uint8_t *reg;
  reg = (uint8_t *)(h->baseAddress+KEY_MATRIX_PRESSED_KEY);
  return *reg;
}

void key_matrix_irq_ack(module_handle_t *h) {
  volatile uint8_t *reg;
  reg = (uint8_t *)(h->baseAddress+MODULE_CONFIG_BOFF);
  *reg |= (1<<MODULE_CONFIG_INTA);
}

