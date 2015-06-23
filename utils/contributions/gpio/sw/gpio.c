#include "../support/support.h"
#include "../support/board.h"

#include "../support/spr_defs.h"

#include "../drivers/uart.h"

#include "gpio.h"

void gpio_init(gpio_t *gpio, long instance_num, unsigned long base_addr)
{
    int i = MIN_GPIO_BIT;

    if ( gpio != NULL ) {
	    gpio->instance_num = instance_num;
	    gpio->base_addr = (unsigned char*)base_addr;
	    for ( ;i<=MAX_GPIO_BIT;i++)
		    gpio->vectors[i].vec = NULL;
	    return;
    } else {
	    // Print the error msgs here
	    //
	    uart_print_str("gpio inst in NULL.\n");
	    return;
    }
}

void gpio_config_bit(gpio_t *gpio, unsigned long bit, iotype_t io)
{
    if ( gpio != NULL ) {
	    if ( io == IO_INPUT ) {
	        gpio->io_config |= (1 << bit);
		*(unsigned long*)(gpio->base_addr + OE_REG_OFFSET) &= (~(1 << bit));
	    } else {
		gpio->io_config &= (~(1 << bit));
                *(unsigned long*)(gpio->base_addr + OE_REG_OFFSET) |= (1 << bit);
	    }	
	    return;
    } else {
	    // Print the error msgs here
	    //
	    uart_print_str("gpio inst in NULL.\n");
	    return;
    }
}

void gpio_set_bit(gpio_t *gpio, unsigned long bit, unsigned long val)
{
    if ( gpio != NULL ) {
	    if ( val != 0 )
                *(unsigned long*)(gpio->base_addr + OUT_REG_OFFSET) |= (1 << bit);
	    else
                *(unsigned long*)(gpio->base_addr + OUT_REG_OFFSET) &= (~(1 << bit));
	    return;
    } else {
	    // Print the error msgs here
	    //
	    uart_print_str("gpio inst in NULL.\n");
	    return;
    }
}

void gpio_get_bit(gpio_t *gpio, unsigned long bit, unsigned long *val)
{
    unsigned long temp;

    if ( gpio != NULL ) {
	    temp = *(unsigned long*)(gpio->base_addr + IN_REG_OFFSET);
	    *val = (temp & (1 << bit))? 1 : 0;
	    return;
    } else {
	    // Print the error msgs here
	    //
	    uart_print_str("gpio inst in NULL.\n");
	    return;
    }
}


void gpio_add_interrupt(gpio_t *gpio, unsigned int bit, edge_t edge,void (*func)() )
{
    if ( gpio != NULL ) {
        if ( ( gpio->io_config &(1 << bit)) != 0 ) {  // Port bit is configured as IO_INPUT
		//
		// Disable the interrupts
		//
		*(unsigned long*)(gpio->base_addr + CTRL_REG_OFFSET) &= (~0x01);

		// Enable the interrupt bit
		//
                *(unsigned long*)(gpio->base_addr + INTE_REG_OFFSET) |= (1 << bit);

		// Enable the edge type
		//
		if ( edge == POS_EDGE )
                    *(unsigned long*)(gpio->base_addr + PTRIG_REG_OFFSET) |= (1 << bit);
		else
		    *(unsigned long*)(gpio->base_addr + PTRIG_REG_OFFSET) &= (~(1 << bit));
		              
		// Set the function vector
		//
                gpio->vectors[bit].vec = func;

		int_add( 6, gpio_interrupt, gpio );

		// Re-enable the global control bit
		//
		    *(unsigned long*)(gpio->base_addr + CTRL_REG_OFFSET) |= 0x01;
	} else {
		// Port is configured as IO_OUTPUT
	        uart_print_str("gpio pin is not an input pin.\n");
	        return;
	}

    } else {
	    // Print the error msgs here
	    //
	    uart_print_str("gpio inst in NULL.\n");
	    return;
    }

}

void gpio_interrupt(gpio_t *gpio)
{
    int i;	
    unsigned long int interrupt_status;

    if ( (*(unsigned long*)(gpio->base_addr + CTRL_REG_OFFSET)) & 0x02 )
    {
	    // Interrupt is pending here
	    //
	    interrupt_status = *(unsigned long*)(gpio->base_addr + INTS_REG_OFFSET);

	    // Prioritize from lower bits(0) to higher ones(31)
	    //

	    for ( i=MIN_GPIO_BIT; i<=MAX_GPIO_BIT; i++ ) {
                if ( (interrupt_status & (1<<i)) ) {
                    *(unsigned long*)(gpio->base_addr + INTS_REG_OFFSET) &= (~( 1 << i ));
		    (gpio->vectors[i].vec)();
		}
	    }

            *(unsigned long*)(gpio->base_addr + CTRL_REG_OFFSET) &= (~0x02);

    }
}

void hello_east()
{
	uart_print_str("Hello from PUSH Button EAST.\n");
}


void hello_west()
{
	uart_print_str("Hello from PUSH Button WEST.\n");
}


void hello_south()
{
	uart_print_str("Hello from PUSH Button SOUTH.\n");
}




#define MAX_COUNT 10

int main()
{
	gpio_t gpio_1;
        unsigned long t0, t1, t2, t3;
	unsigned long count = 0;

    	tick_init();
	uart_init();
	int_init();
	int_add(2,&uart_interrupt);

        gpio_init( &gpio_1, 1, GPIO_BASE );

	gpio_config_bit( &gpio_1, LED_0, IO_OUTPUT);
        gpio_config_bit( &gpio_1, LED_1, IO_OUTPUT);
	gpio_config_bit( &gpio_1, LED_2, IO_OUTPUT);
        gpio_config_bit( &gpio_1, LED_3, IO_OUTPUT);
	gpio_config_bit( &gpio_1, LED_4, IO_OUTPUT);
        gpio_config_bit( &gpio_1, LED_5, IO_OUTPUT);
	gpio_config_bit( &gpio_1, LED_6, IO_OUTPUT);
        gpio_config_bit( &gpio_1, LED_7, IO_OUTPUT);

        while ( count++ < MAX_COUNT ) {	
		gpio_set_bit( &gpio_1, LED_7, 0 );
		gpio_set_bit( &gpio_1, LED_0, 1 );
		udelay();
		gpio_set_bit( &gpio_1, LED_0, 0 );
		gpio_set_bit( &gpio_1, LED_1, 1 );
        	udelay();
		gpio_set_bit( &gpio_1, LED_1, 0 );
		gpio_set_bit( &gpio_1, LED_2, 1 );
		udelay();
		gpio_set_bit( &gpio_1, LED_2, 0 );
		gpio_set_bit( &gpio_1, LED_3, 1 );
        	udelay();
		gpio_set_bit( &gpio_1, LED_3, 0 );
		gpio_set_bit( &gpio_1, LED_4, 1 );
		udelay();
		gpio_set_bit( &gpio_1, LED_4, 0 );
		gpio_set_bit( &gpio_1, LED_5, 1 );
	        udelay();
		gpio_set_bit( &gpio_1, LED_5, 0 );
		gpio_set_bit( &gpio_1, LED_6, 1 );
		udelay();
		gpio_set_bit( &gpio_1, LED_6, 0 );
		gpio_set_bit( &gpio_1, LED_7, 1 );
        	udelay();
        }

	gpio_set_bit( &gpio_1, LED_7, 0 );

	report(0xdeaddead);
	or32_exit(0);
}
