#ifndef _IO_DRIVER_H_
  #define _IO_DRIVER_H_

// System parameters
#define clk_speed 50000000 // 50MHz

// Prototypes

/* -- IO CTRL 0 -- */
unsigned long io_read_gpio0_pin(unsigned char pin);
unsigned long io_read_gpio0_port(void);
void io_set_gpio0_pin(unsigned char pin);
void io_clr_gpio0_pin(unsigned char pin);
void io_toggle_gpio0_pin(unsigned char pin);
void io_set_gpio0_port(unsigned long value);

/* -- PWM CTRL 0 -- */
void io_set_pwm(unsigned char port, unsigned char data);
unsigned char io_get_pwm(unsigned char port);

/* -- UART 0 -- */
int io_uart0_read_byte(void);
int io_uart0_send_byte(int ch);

/* -- SPI 0 -- */
void io_spi0_config(unsigned char auto_cs, unsigned long data_size);
void io_spi0_speed(unsigned long clk_divider);
unsigned long io_spi0_trans(unsigned long data);
void io_spi0_enable(unsigned char device);
void io_spi0_disable(unsigned char device);

/* -- I²C 0 -- */
void io_i2c0_speed(unsigned long clk_divider);
int io_i2c0_byte_transfer(unsigned char rw, unsigned char id, unsigned long data_adr, unsigned char adr_bytes, unsigned char data);

/* -- System -- */
unsigned long get_syscpreg(unsigned char index);
void set_syscpreg(unsigned long _cp_val, unsigned char index);
static inline unsigned long get_cmsr(void);
static inline void set_cmsr(unsigned long _cpsr);
void io_enable_xint(void);
void io_disable_xint(void);

#endif // _IO_DRIVER_H_
