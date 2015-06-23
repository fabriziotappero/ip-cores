#include "io_driver.h"
#include "storm_core.h"
#include "storm_soc_basic.h"

// ###########################################################################################################################
// General Purpose IO (GENERAL_PURPOSE_CONTROLLER_0)
// ###########################################################################################################################

// ******************************************************************************
// Read general purpose IO pin
   unsigned long io_read_gpio0_pin(unsigned char pin)
// ******************************************************************************
{
//	unsigned long _cmsr = get_cmsr();
//	set_cmsr(_cmsr  | (1<<CMSR_IRQ) | (1<<CMSR_FIQ));

		unsigned long temp = GPIO0_IN & (1<<pin);
	
//	set_cmsr(_cmsr);
	return temp;
}

// ******************************************************************************
// Read general purpose IO port
   unsigned long io_read_gpio0_port(void)
// ******************************************************************************
{
//	unsigned long _cmsr = get_cmsr();
//	set_cmsr(_cmsr  | (1<<CMSR_IRQ) | (1<<CMSR_FIQ));

		unsigned long temp = GPIO0_IN;

//	set_cmsr(_cmsr);
	return temp;
}

// ******************************************************************************
// Set general purpose IO port
   void io_set_gpio0_pin(unsigned char pin)
// ******************************************************************************
{
//	unsigned long _cmsr = get_cmsr();
//	set_cmsr(_cmsr  | (1<<CMSR_IRQ) | (1<<CMSR_FIQ));

		GPIO0_OUT = GPIO0_OUT | (1<<pin);

//	set_cmsr(_cmsr);
}

// ******************************************************************************
// Clear general purpose IO port
   void io_clr_gpio0_pin(unsigned char pin)
// ******************************************************************************
{
//	unsigned long _cmsr = get_cmsr();
//	set_cmsr(_cmsr  | (1<<CMSR_IRQ) | (1<<CMSR_FIQ));

		GPIO0_OUT = GPIO0_OUT & ~(1<<pin);

//	set_cmsr(_cmsr);
}
// ******************************************************************************
// Set general purpose IO port
   void io_toggle_gpio0_pin(unsigned char pin)
// ******************************************************************************
{
//	unsigned long _cmsr = get_cmsr();
//	set_cmsr(_cmsr  | (1<<CMSR_IRQ) | (1<<CMSR_FIQ));

		GPIO0_OUT = GPIO0_OUT ^ (1<<pin);

//	set_cmsr(_cmsr);
}

// ******************************************************************************
// Clear general purpose IO port
   void io_set_gpio0_port(unsigned long value)
// ******************************************************************************
{
//	unsigned long _cmsr = get_cmsr();
//	set_cmsr(_cmsr  | (1<<CMSR_IRQ) | (1<<CMSR_FIQ));

		GPIO0_OUT = value;

//	set_cmsr(_cmsr);
}



// ###########################################################################################################################
// Pulse-Width-Modulation Controller
// ###########################################################################################################################

// ******************************************************************************
// Set pwm value
   void io_set_pwm(unsigned char port, unsigned char data)
// ******************************************************************************
{
//	unsigned long _cmsr = get_cmsr();
//	set_cmsr(_cmsr  | (1<<CMSR_IRQ) | (1<<CMSR_FIQ));

	unsigned long temp = 0;

	// value adjustment
	if(port > 7)
		port = 0;

	if(port < 4){
		temp = PWM0_CONF0; // get working copy
		temp = temp & ~(0xFF << (port*8)); // clear old value
		temp = temp | (unsigned long)(data << (port*8)); // insert new value
		PWM0_CONF0 = temp;
	}
	else{
		port = port-4;
		temp = PWM0_CONF1; // get working copy
		temp = temp & ~(0xFF << (port*8)); // clear old value
		temp = temp | (unsigned long)(data << (port*8)); // insert new value
		PWM0_CONF1 = temp;
	}
//	set_cmsr(_cmsr);
}

// ******************************************************************************
// Set pwm value
   unsigned char io_get_pwm(unsigned char port)
// ******************************************************************************
{
//	unsigned long _cmsr = get_cmsr();
//	set_cmsr(_cmsr  | (1<<CMSR_IRQ) | (1<<CMSR_FIQ));

	unsigned long temp = 0;

	// value adjustment
	if(port > 7)
		port = 0;

	if(port < 4)
		temp = PWM0_CONF0; // get config register
	else{
		port = port-4;
		temp = PWM0_CONF1; // get config register
	}

	temp = temp >> (port*8); // only keep designated byte

//	set_cmsr(_cmsr);
	return (unsigned char)temp;
}



// ###########################################################################################################################
// General Purpose UART "miniUART" (UART_0)
// ###########################################################################################################################

// ******************************************************************************
// Read one byte via UART 0
   int io_uart0_read_byte(void)
// ******************************************************************************
{
//	unsigned long _cmsr = get_cmsr();
//	set_cmsr(_cmsr  | (1<<CMSR_IRQ) | (1<<CMSR_FIQ));

	int temp;
	if ((UART0_SREG & (1<<CUART_RXD)) != 0) // byte available?
		temp = UART0_DATA;
	else
		temp = -1;

//	set_cmsr(_cmsr);
	return temp;
}

// ******************************************************************************
// Write one byte via UART 0
   int io_uart0_send_byte(int ch)
// ******************************************************************************
{
//	unsigned long _cmsr = get_cmsr();
//	set_cmsr(_cmsr  | (1<<CMSR_IRQ) | (1<<CMSR_FIQ));

	while((UART0_SREG & (1<<CUART_TXB)) == 0); // uart busy?
	UART0_DATA = (ch & 0x000000FF);

//	set_cmsr(_cmsr);
	return ch;
}



// ###########################################################################################################################
// Serial Peripherial Interface (SPI_CONTROLLER_0)
// ###########################################################################################################################

// ******************************************************************************
// Configure SPI 0
   void io_spi0_config(unsigned char auto_cs, unsigned long data_size)
// ******************************************************************************
{
//	unsigned long _cmsr = get_cmsr();
//	set_cmsr(_cmsr  | (1<<CMSR_IRQ) | (1<<CMSR_FIQ));
	// devices update their serial input on a rising edge of sclk,
	// so we need to update the mosi output of the core before
	// -> at the falling edge of sclk = set SPI_TX_NEG
	if(auto_cs == 1)
		SPI0_CONF = (1<<SPI_ACS) | (1<<SPI_TX_NEG) | data_size; // auto assert cs
	else
		SPI0_CONF = (0<<SPI_ACS) | (1<<SPI_TX_NEG) | data_size; // manual assert cs
//	set_cmsr(_cmsr);
}

// ******************************************************************************
// Configure SPI 0 CLK frequency -> (sys_clk/(spi_clk*2))-1
   void io_spi0_speed(unsigned long clk_divider)
// ******************************************************************************
{
//	unsigned long _cmsr = get_cmsr();
//	set_cmsr(_cmsr  | (1<<CMSR_IRQ) | (1<<CMSR_FIQ));

		SPI0_PRSC = clk_divider; // (sys_clk/(spi_clk*2))-1;

//	set_cmsr(_cmsr);
}

// ******************************************************************************
// Sends/receives max 32 bits via SPI, CS and config must be done outside
   unsigned long io_spi0_trans(unsigned long data)
// ******************************************************************************
{
//	unsigned long _cmsr = get_cmsr();
//	set_cmsr(_cmsr  | (1<<CMSR_IRQ) | (1<<CMSR_FIQ));

	// spi transmission
	while((SPI0_CONF & (1<<SPI_BUSY)) != 0); // wait for prev tx to finish
	SPI0_DAT0 = data;
	SPI0_CONF = SPI0_CONF | (1<<SPI_BUSY); // start transmitter
	while((SPI0_CONF & (1<<SPI_BUSY)) != 0); // wait for rx to finish
	unsigned long temp = SPI0_DAT0;

//	set_cmsr(_cmsr);
	return temp;
}

// ******************************************************************************
// Controls the CS of SPI0, enables a connected CS (turns it LOW)
   void io_spi0_enable(unsigned char device)
// ******************************************************************************
{
//	unsigned long _cmsr = get_cmsr();
//	set_cmsr(_cmsr  | (1<<CMSR_IRQ) | (1<<CMSR_FIQ));

		SPI0_SCSR = SPI0_SCSR | (1<<device);

//	set_cmsr(_cmsr);
}

// ******************************************************************************
// Controls the CS of SPI0, disables a connected CS (turns it HIGH)
   void io_spi0_disable(unsigned char device)
// ******************************************************************************
{
//	unsigned long _cmsr = get_cmsr();
//	set_cmsr(_cmsr  | (1<<CMSR_IRQ) | (1<<CMSR_FIQ));

		SPI0_SCSR = SPI0_SCSR & ~(1<<device);

//	set_cmsr(_cmsr);
}




// ###########################################################################################################################
// Inter Intergrated Circuit Interface (I²C_CONTROLLER_0)
// ###########################################################################################################################

// ******************************************************************************
// Configure SPI 0 CLK frequency -> (sys_clk/(5*i2c_clock)-1
   void io_i2c0_speed(unsigned long clk_divider)
// ******************************************************************************
{
//	unsigned long _cmsr = get_cmsr();
//	set_cmsr(_cmsr  | (1<<CMSR_IRQ) | (1<<CMSR_FIQ));
		I2C0_CTRL = I2C0_CTRL & ~(1<<I2C_EN); // disable i2c core
		I2C0_PRLO = clk_divider;
		I2C0_PRHI = clk_divider >> 8;
		I2C0_CTRL = I2C0_CTRL | (1<<I2C_EN); // enable i2c core
//	set_cmsr(_cmsr);
}

// ******************************************************************************
// Read/write byte from/to I²C slave, max 2 address bytes
   int io_i2c0_byte_transfer(unsigned char rw,        // 'r' read / 'w' write cycle
                             unsigned char id,        // device ID
							 unsigned long data_adr,  // data address
							 unsigned char adr_bytes, // number of adr bytes
							 unsigned char data)      // data byte
// ******************************************************************************
{
//	unsigned long _cmsr = get_cmsr();
//	set_cmsr(_cmsr  | (1<<CMSR_IRQ) | (1<<CMSR_FIQ));

	// transfer slave identification address
	I2C0_DATA = id & 0xFE;                  // device id and write
	I2C0_CMD = (1<<I2C_STA) | (1<<I2C_WR);  // start condition and write cycle
	while((I2C0_STAT & (1<<I2C_TIP)) != 0); // wait for transfer to finish
	if((I2C0_STAT & (1<<I2C_RXACK)) != 0){  // ack received?
//		set_cmsr(_cmsr);
		return -1;
	}

	// transfer data address
	while(adr_bytes != 0){
		adr_bytes--;
		if(adr_bytes == 1)
			I2C0_DATA = data_adr >> 8;          // high byte
		else
			I2C0_DATA = data_adr;               // low byte
		I2C0_CMD = (1<<I2C_WR);                 // write cycle
		while((I2C0_STAT & (1<<I2C_TIP)) != 0); // wait for transfer to finish
		if((I2C0_STAT & (1<<I2C_RXACK)) != 0){  // ack received?
//			set_cmsr(_cmsr);
			return -2;
		}
	}

	if(rw == 'w'){
		// write adressed byte
		I2C0_DATA = data;                       // send data
		I2C0_CMD = (1<<I2C_STO) | (1<<I2C_WR);  // stop condition and write cycle
		while((I2C0_STAT & (1<<I2C_TIP)) != 0); // wait for transfer to finish
		if((I2C0_STAT & (1<<I2C_RXACK)) != 0){  // ack received?
//			set_cmsr(_cmsr);
			return -3;
		}
		else{
//			set_cmsr(_cmsr);
			return 0;
		}
	}

	if(rw == 'r'){
		// re-send control byte - this time with read-bit
		I2C0_DATA = id | 0x01;                  // device id and READ
		I2C0_CMD = (1<<I2C_STA) | (1<<I2C_WR);  // start condition and write cycle
		while((I2C0_STAT & (1<<I2C_TIP)) != 0); // wait for transfer to finish
		if((I2C0_STAT & (1<<I2C_RXACK)) != 0){  // ack received?
//			set_cmsr(_cmsr);
			return -3;
		}
		// read adressed byte
		I2C0_CMD = (1<<I2C_STO) | (1<<I2C_RD) | (1<<I2C_ACK);
		while((I2C0_STAT & (1<<I2C_TIP)) != 0); // wait for transfer to finish
		return I2C0_DATA;
	}

//	set_cmsr(_cmsr);
	return -4;
}




// ###########################################################################################################################
// System
// ###########################################################################################################################

// ******************************************************************************
// read system coprocessor register x
   unsigned long get_syscpreg(unsigned char index)
// ******************************************************************************
{
	unsigned long _cp_val;
	switch(index){
		case ID_REG_0:   asm volatile ("mrc p15,0,%0, c0, c0" : "=r" (_cp_val) : /* no inputs */  ); break;
		case ID_REG_1:   asm volatile ("mrc p15,0,%0, c1, c1" : "=r" (_cp_val) : /* no inputs */  ); break;
		case ID_REG_2:   asm volatile ("mrc p15,0,%0, c2, c2" : "=r" (_cp_val) : /* no inputs */  ); break;
		case 3:          asm volatile ("mrc p15,0,%0, c3, c3" : "=r" (_cp_val) : /* no inputs */  ); break;
		case 4:          asm volatile ("mrc p15,0,%0, c4, c4" : "=r" (_cp_val) : /* no inputs */  ); break;
		case 5:          asm volatile ("mrc p15,0,%0, c5, c5" : "=r" (_cp_val) : /* no inputs */  ); break;
		case SYS_CTRL_0: asm volatile ("mrc p15,0,%0, c6, c6" : "=r" (_cp_val) : /* no inputs */  ); break;
		case 7:          asm volatile ("mrc p15,0,%0, c7, c7" : "=r" (_cp_val) : /* no inputs */  ); break;
		case CSTAT:      asm volatile ("mrc p15,0,%0, c8, c8" : "=r" (_cp_val) : /* no inputs */  ); break;
		case ADR_FB:     asm volatile ("mrc p15,0,%0, c9, c9" : "=r" (_cp_val) : /* no inputs */  ); break;
		case 10:         asm volatile ("mrc p15,0,%0,c10,c10" : "=r" (_cp_val) : /* no inputs */  ); break;
		case LFSR_POLY:  asm volatile ("mrc p15,0,%0,c11,c11" : "=r" (_cp_val) : /* no inputs */  ); break;
		case LFSR_DATA:  asm volatile ("mrc p15,0,%0,c12,c12" : "=r" (_cp_val) : /* no inputs */  ); break;
		case SYS_IO:     asm volatile ("mrc p15,0,%0,c13,c13" : "=r" (_cp_val) : /* no inputs */  ); break;
		case 14:         asm volatile ("mrc p15,0,%0,c14,c14" : "=r" (_cp_val) : /* no inputs */  ); break;
		case 15:         asm volatile ("mrc p15,0,%0,c15,c15" : "=r" (_cp_val) : /* no inputs */  ); break;
		default:         _cp_val = 0; break;
	}
	return _cp_val;
}

// ******************************************************************************
// write system coprocessor register x
   void set_syscpreg(unsigned long _cp_val, unsigned char index)
// ******************************************************************************
{
	switch(index){
//		case ID_REG_0:   asm volatile ("mcr p15,0,%0, c0, c0,0" : /* no outputs */ : "r" (_cp_val)); break;
//		case ID_REG_1:   asm volatile ("mcr p15,0,%0, c1, c1,0" : /* no outputs */ : "r" (_cp_val)); break;
//		case ID_REG_2:   asm volatile ("mcr p15,0,%0, c2, c2,0" : /* no outputs */ : "r" (_cp_val)); break;
//		case 3:          asm volatile ("mcr p15,0,%0, c3, c3,0" : /* no outputs */ : "r" (_cp_val)); break;
//		case 4:          asm volatile ("mcr p15,0,%0, c4, c4,0" : /* no outputs */ : "r" (_cp_val)); break;
//		case 5:          asm volatile ("mcr p15,0,%0, c5, c5,0" : /* no outputs */ : "r" (_cp_val)); break;
		case SYS_CTRL_0: asm volatile ("mcr p15,0,%0, c6, c6,0" : /* no outputs */ : "r" (_cp_val)); break;
//		case 7:          asm volatile ("mcr p15,0,%0, c7, c7,0" : /* no outputs */ : "r" (_cp_val)); break;
//		case CSTAT:      asm volatile ("mcr p15,0,%0, c8, c8,0" : /* no outputs */ : "r" (_cp_val)); break;
//		case ADR_FB:     asm volatile ("mcr p15,0,%0, c9, c9,0" : /* no outputs */ : "r" (_cp_val)); break;
//		case 10:         asm volatile ("mcr p15,0,%0,c10,c10,0" : /* no outputs */ : "r" (_cp_val)); break;
		case LFSR_POLY:  asm volatile ("mcr p15,0,%0,c11,c11,0" : /* no outputs */ : "r" (_cp_val)); break;
		case LFSR_DATA:  asm volatile ("mcr p15,0,%0,c12,c12,0" : /* no outputs */ : "r" (_cp_val)); break;
		case SYS_IO:     asm volatile ("mcr p15,0,%0,c13,c13,0" : /* no outputs */ : "r" (_cp_val)); break;
//		case 14:         asm volatile ("mcr p15,0,%0,c14,c14,0" : /* no outputs */ : "r" (_cp_val)); break;
//		case 15:         asm volatile ("mcr p15,0,%0,c15,c15,0" : /* no outputs */ : "r" (_cp_val)); break;
		default:         break;
	}
}
// ******************************************************************************
// read CMSR value
   static inline unsigned long get_cmsr(void)
// ******************************************************************************
{
	unsigned long _cmsr;
	asm volatile (" mrs %0, cpsr" : "=r" (_cmsr) : /* no inputs */  );
	return _cmsr;
}

// ******************************************************************************
// write CMSR value
   static inline void set_cmsr(unsigned long _cmsr)
// ******************************************************************************
{
	asm volatile (" msr cpsr, %0" : /* no outputs */ : "r" (_cmsr)  );
}

// ******************************************************************************
// Enable all external INTs
   void io_enable_xint(void)
// ******************************************************************************
{
	unsigned long _cmsr = get_cmsr();
	_cmsr = _cmsr & ~(1<<CMSR_FIQ) &~(1<<CMSR_IRQ);
	set_cmsr(_cmsr);
}

// ******************************************************************************
// Disable all global IBTs
   void io_disable_xint(void)
// ******************************************************************************
{
	unsigned long _cmsr = get_cmsr();
	_cmsr = _cmsr | (1<<CMSR_FIQ) | (1<<CMSR_IRQ);
	set_cmsr(_cmsr);
}
