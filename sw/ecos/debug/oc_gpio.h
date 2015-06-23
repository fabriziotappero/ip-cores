//
//
//

#ifndef __OC_GPIO_H
#define __OC_GPIO_H


// opencore gpio register offesets
#define OC_GPIO_RGPIO_IN      0x00
#define OC_GPIO_RGPIO_OUT     0x04
#define OC_GPIO_RGPIO_OE      0x08
#define OC_GPIO_RGPIO_INTE    0x0c
#define OC_GPIO_RGPIO_PTRIG   0x10
#define OC_GPIO_RGPIO_AUX     0x14
#define OC_GPIO_RGPIO_CTRL    0x18
#define OC_GPIO_RGPIO_INTS    0x1c
#define OC_GPIO_RGPIO_ECLK    0x20
#define OC_GPIO_RGPIO_NEC     0x24

// GPIO A
#define OC_GPIO_A_BASE          0x83100000
#define OC_GPIO_A_RGPIO_IN      (*( (volatile unsigned int *) (OC_GPIO_A_BASE + OC_GPIO_RGPIO_IN) )) 
#define OC_GPIO_A_RGPIO_OUT     (*( (volatile unsigned int *) (OC_GPIO_A_BASE + OC_GPIO_RGPIO_OUT) )) 
#define OC_GPIO_A_RGPIO_OE      (*( (volatile unsigned int *) (OC_GPIO_A_BASE + OC_GPIO_RGPIO_OE) )) 
#define OC_GPIO_A_RGPIO_INTE    (*( (volatile unsigned int *) (OC_GPIO_A_BASE + OC_GPIO_RGPIO_INTE) )) 
#define OC_GPIO_A_RGPIO_PTRIG   (*( (volatile unsigned int *) (OC_GPIO_A_BASE + OC_GPIO_RGPIO_PTRIG) )) 
#define OC_GPIO_A_RGPIO_AUX     (*( (volatile unsigned int *) (OC_GPIO_A_BASE + OC_GPIO_RGPIO_AUX) )) 
#define OC_GPIO_A_RGPIO_CTRL    (*( (volatile unsigned int *) (OC_GPIO_A_BASE + OC_GPIO_RGPIO_CTRL) )) 
#define OC_GPIO_A_RGPIO_INTS    (*( (volatile unsigned int *) (OC_GPIO_A_BASE + OC_GPIO_RGPIO_INTS) )) 
#define OC_GPIO_A_RGPIO_ECLK    (*( (volatile unsigned int *) (OC_GPIO_A_BASE + OC_GPIO_RGPIO_ECLK) )) 
#define OC_GPIO_A_RGPIO_NEC     (*( (volatile unsigned int *) (OC_GPIO_A_BASE + OC_GPIO_RGPIO_NEC) )) 

// GPIO B
#define OC_GPIO_B_BASE          0x83200000
#define OC_GPIO_B_RGPIO_IN      (*( (volatile unsigned int *) (OC_GPIO_B_BASE + OC_GPIO_RGPIO_IN) )) 
#define OC_GPIO_B_RGPIO_OUT     (*( (volatile unsigned int *) (OC_GPIO_B_BASE + OC_GPIO_RGPIO_OUT) )) 
#define OC_GPIO_B_RGPIO_OE      (*( (volatile unsigned int *) (OC_GPIO_B_BASE + OC_GPIO_RGPIO_OE) )) 
#define OC_GPIO_B_RGPIO_INTE    (*( (volatile unsigned int *) (OC_GPIO_B_BASE + OC_GPIO_RGPIO_INTE) )) 
#define OC_GPIO_B_RGPIO_PTRIG   (*( (volatile unsigned int *) (OC_GPIO_B_BASE + OC_GPIO_RGPIO_PTRIG) )) 
#define OC_GPIO_B_RGPIO_AUX     (*( (volatile unsigned int *) (OC_GPIO_B_BASE + OC_GPIO_RGPIO_AUX) )) 
#define OC_GPIO_B_RGPIO_CTRL    (*( (volatile unsigned int *) (OC_GPIO_B_BASE + OC_GPIO_RGPIO_CTRL) )) 
#define OC_GPIO_B_RGPIO_INTS    (*( (volatile unsigned int *) (OC_GPIO_B_BASE + OC_GPIO_RGPIO_INTS) )) 
#define OC_GPIO_B_RGPIO_ECLK    (*( (volatile unsigned int *) (OC_GPIO_B_BASE + OC_GPIO_RGPIO_ECLK) )) 
#define OC_GPIO_B_RGPIO_NEC     (*( (volatile unsigned int *) (OC_GPIO_B_BASE + OC_GPIO_RGPIO_NEC) )) 


// DE1 hex led display commands
#define DE1_HEX_LED_WRITE     1
#define DE1_HEX_LED_READ      2
#define DE1_HEX_LED_INCREMENT 3


//functions
extern void fled_init( unsigned int data);
extern void hex_led_init( unsigned int data);
extern unsigned int hex_led_command( unsigned int command, unsigned int data);



#endif  // __OC_GPIO_H
