#ifndef __GPIO_H__

#define __GPIO_H__

#define MIN_GPIO_BIT		0
#define MAX_GPIO_BIT		31

#define TOTAL_GPIO_BITS		((MAX_GPIO_BIT-MIN_GPIO_BIT+1))


#define IN_REG_OFFSET		0x00
#define OUT_REG_OFFSET		0x04
#define OE_REG_OFFSET		0x08
#define INTE_REG_OFFSET		0x0C
#define PTRIG_REG_OFFSET	0x10
#define AUX_REG_OFFSET		0x14
#define CTRL_REG_OFFSET		0x18
#define INTS_REG_OFFSET		0x1C
#define ECLK_REG_OFFSET		0x20
#define NEC_REG_OFFSET		0x24


typedef struct vector_t_
{
	void (*vec)();        
} vector_t;

typedef struct gpio_t_
{
	volatile unsigned char *base_addr;
	unsigned int instance_num;
	unsigned int io_config;
	vector_t vectors[TOTAL_GPIO_BITS];
} gpio_t;

typedef enum iotype_t_
{
	IO_OUTPUT = 0,
	IO_INPUT = 1
} iotype_t;

typedef enum edge_t_
{
	NEG_EDGE = 0,
	POS_EDGE = 1
} edge_t;


#define LED_0			0x00
#define LED_1			0x01
#define LED_2			0x02
#define LED_3			0x03
#define LED_4			0x04
#define LED_5			0x05
#define LED_6			0x06
#define LED_7			0x07

#define DIP_0			0x08
#define DIP_1			0x09
#define DIP_2			0x0A
#define DIP_3			0x0B

#define PUSH_EAST		0x0C
#define PUSH_WEST		0x0D
#define PUSH_NORTH		0x0E
#define PUSH_SOUTH		0x0F


void gpio_init(gpio_t *, long, unsigned long);
void gpio_config_bit(gpio_t *, unsigned long, iotype_t);
void gpio_set_bit(gpio_t *, unsigned long, unsigned long);
void gpio_get_bit(gpio_t *, unsigned long, unsigned long *);
void gpio_add_interrupt(gpio_t *, unsigned int, edge_t,void (*func)() );
void gpio_interrupt(gpio_t *gpio);

#endif
