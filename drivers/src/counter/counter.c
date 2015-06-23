#include "counter.h"

void counter_initHandle(module_handle_t *h, scarts_addr_t baseAddress)
{
  h->baseAddress = baseAddress;
}

void counter_releaseHandle(module_handle_t *h)
{
}

void counter_setPrescaler(module_handle_t *h, uint8_t prescaler)
{
  volatile uint8_t *reg = (uint8_t *)(h->baseAddress+COUNTER_PRESCALER_BOFF);
  *reg = prescaler;
}

void counter_start(module_handle_t *h)
{
  volatile uint8_t *reg = (uint8_t *)(h->baseAddress+COUNTER_CONFIG_C_BOFF);
  *reg = (1 << COUNTER_CLEAR_BIT);
  *reg = (1 << COUNTER_COUNT_BIT);
}

void counter_stop(module_handle_t *h)
{
  volatile uint8_t *reg = (uint8_t *)(h->baseAddress+COUNTER_CONFIG_C_BOFF);
  *reg = 0;
}

void counter_resume(module_handle_t *h)
{
  volatile uint8_t *reg = (uint8_t *)(h->baseAddress+COUNTER_CONFIG_C_BOFF);
  *reg = (1 << COUNTER_COUNT_BIT);
}

void counter_reset(module_handle_t *h)
{
  volatile uint8_t *reg = (uint8_t *)(h->baseAddress+COUNTER_CONFIG_C_BOFF);
  *reg = (1 << COUNTER_CLEAR_BIT);
}

uint32_t counter_getValue(module_handle_t *h)
{
  volatile uint32_t *reg = (uint32_t *)(h->baseAddress+COUNTER_VALUE_BOFF);
  return *reg;
}
