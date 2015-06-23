//
//
//

#include <stdio.h>
#include <math.h>
#include <stdlib.h>

#include <cyg/kernel/kapi.h>

#include "LPC22xx.h"
#include "lib_dbg_sh.h"
#include "oc_gpio.h"


cyg_mutex_t   hex_led_lock;


void 
hex_led_init( unsigned int data)
{
  OC_GPIO_A_RGPIO_OE  = 0x7f7f7f7f;
  OC_GPIO_A_RGPIO_AUX = 0x7f7f7f7f;

  cyg_mutex_init(&hex_led_lock);
  
  *((unsigned int *)0x83300004) = data;
  
}

  
unsigned int
hex_led_command( unsigned int command, unsigned int data)
{
  unsigned int ret_data = 0;
  
  cyg_mutex_lock(&hex_led_lock);
  
  switch (command) {
    case DE1_HEX_LED_WRITE:
      *((unsigned int *)0x83300004) = data;
      break;

    case DE1_HEX_LED_READ:
      ret_data = *((unsigned int *)0x83300004);
      break;

    case DE1_HEX_LED_INCREMENT:
      *((unsigned int *)0x83300004) += 1;
      break;

    default:
      break;
  }
  
  cyg_mutex_unlock(&hex_led_lock);
   
  return( ret_data );
  
}


void 
fled_init( unsigned int data)
{
  OC_GPIO_B_RGPIO_OE  = 0x0003ffff;
  OC_GPIO_B_RGPIO_OUT = data;
}

