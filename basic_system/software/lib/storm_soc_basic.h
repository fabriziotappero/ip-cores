#ifndef storm_soc_basic_h
#define storm_soc_basic_h

/////////////////////////////////////////////////////////////////
// storm_soc_basic.h - STORM SoC Basic Configuration
// Based on the STORM Core Processor System
//
// Created by Stephan Nolting (stnolting@googlemail.com)
// http://www.opencores.com/project,storm_core
// http://www.opencores.com/project,storm_soc
// Last modified 15. May 2012
/////////////////////////////////////////////////////////////////

#define REG32 (volatile unsigned long*)

/* Internal RAM */
#define IRAM_BASE       (*(REG32 (0x00000000)))
#define IRAM_SIZE       32*1024

/* External RAM */
#define XRAM_BASE       (*(REG32 (0x00002000)))
#define XRAM_SIZE       0//32*1024*1024

/* Complete RAM */
#define RAM_BASE        (*(REG32 (0x00000000)))
#define RAM_SIZE        IRAM_SIZE + XRAM_SIZE

/* Internal ROM (boot ROM) */
#define ROM_BASE        (*(REG32 (0xFFF00000)))
#define ROM_SIZE        8*1024

/* De-Cached IO Area */
#define IO_AREA_BEGIN   (*(REG32 (0xFFFF0000)))
#define IO_AREA_END     (*(REG32 (0xFFFFFFFF)))
#define IO_AREA_SIZE    524288;

/* General Purpose IO Controller 0 */
#define GPIO0_BASE      (*(REG32 (0xFFFF0000)))
#define GPIO0_SIZE      2*4
#define GPIO0_OUT       (*(REG32 (0xFFFF0000)))
#define GPIO0_IN        (*(REG32 (0xFFFF0004)))

/* UART 0 - miniUART */
#define UART0_BASE      (*(REG32 (0xFFFF0018)))
#define UART0_SIZE      2*4
#define UART0_DATA      (*(REG32 (0xFFFF0018)))
#define UART0_SREG      (*(REG32 (0xFFFF001C)))

/* Mini UART */
#define CUART_TXB       0 // transmitter busy
#define CUART_RXD       1 // byte available

/* System Timer 0 */
#define STME0_BASE      (*(REG32 (0xFFFF0020)))
#define STME0_SIZE      4*4
#define STME0_CNT       (*(REG32 (0xFFFF0020)))
#define STME0_VAL       (*(REG32 (0xFFFF0024)))
#define STME0_CONF      (*(REG32 (0xFFFF0028)))
#define STME0_SCRT      (*(REG32 (0xFFFF002C)))

/* SPI Controller 0 */
#define SPI0_BASE       (*(REG32 (0xFFFF0030)))
#define SPI0_SIZE       8*4
#define SPI0_CONF       (*(REG32 (0xFFFF0030)))
#define SPI0_PRSC       (*(REG32 (0xFFFF0034)))
#define SPI0_SCSR       (*(REG32 (0xFFFF0038)))
// unused location      (*(REG32 (0xFFFF003C)))
#define SPI0_DAT0       (*(REG32 (0xFFFF0040)))
#define SPI0_DAT1       (*(REG32 (0xFFFF0044)))
#define SPI0_DAT2       (*(REG32 (0xFFFF0048)))
#define SPI0_DAT3       (*(REG32 (0xFFFF004C)))

/* Serial Peripherial Interface Controller 0 */
#define SPI_BUSY         8 // spi busy
#define SPI_RX_NEG       9 // load miso on falling edge of sclk
#define SPI_TX_NEG      10 // change mosi on falling edge of sclk
#define SPI_ACS         13 // manual/auto assert cs

/* I²C Controller 0 */
#define I2C0_BASE       (*(REG32 (0xFFFF0050)))
#define I2C0_SIZE       8*4
#define I2C0_CMD        (*(REG32 (0xFFFF0050)))
#define I2C0_STAT       (*(REG32 (0xFFFF0050)))
// unused location      (*(REG32 (0xFFFF0054)))
// unused location      (*(REG32 (0xFFFF0058)))
// unused location      (*(REG32 (0xFFFF005C)))
#define I2C0_PRLO       (*(REG32 (0xFFFF0060)))
#define I2C0_PRHI       (*(REG32 (0xFFFF0064)))
#define I2C0_CTRL       (*(REG32 (0xFFFF0068)))
#define I2C0_DATA       (*(REG32 (0xFFFF006C)))

/* I²C Controller 0 */
#define I2C_EN           7 // enable core

#define I2C_STA          7 // generate start condition
#define I2C_STO          6 // generate stop condition
#define I2C_RD           5 // read
#define I2C_WR           4 // write
#define I2C_ACK          3 // acknowledge
#define I2C_IACK         0 // interrupt ack

#define I2C_RXACK        7 // ack from slave received
#define I2C_BUSY         6 // i2c busy
#define I2C_TIP          1 // transfer in progress

/* PWM Controller 0 */
#define PWM0_BASE       (*(REG32 (0xFFFF0070)))
#define PWM0_SIZE       2*4
#define PWM0_CONF0      (*(REG32 (0xFFFF0070)))
#define PWM0_CONF1      (*(REG32 (0xFFFF0074)))

/* Vector Interrupt Controller */
#define VIC_BASE        (*(REG32 (0xFFFFF000)))
#define VIC_SIZE        64*4
#define VICIRQStatus    (*(REG32 (0xFFFFF000)))
#define VICFIQStatus    (*(REG32 (0xFFFFF004)))
#define VICRawIntr      (*(REG32 (0xFFFFF008)))
#define VICIntSelect    (*(REG32 (0xFFFFF00C)))
#define VICIntEnable    (*(REG32 (0xFFFFF010)))
#define VICIntEnClear   (*(REG32 (0xFFFFF014)))
#define VICSoftInt      (*(REG32 (0xFFFFF018)))
#define VICSoftIntClear (*(REG32 (0xFFFFF01C)))
#define VICProtection   (*(REG32 (0xFFFFF020)))
#define VICVectAddr     (*(REG32 (0xFFFFF030)))
#define VICDefVectAddr  (*(REG32 (0xFFFFF034)))
#define VICTrigLevel    (*(REG32 (0xFFFFF038)))
#define VICTrigMode     (*(REG32 (0xFFFFF03C)))
#define VICVectAddr0    (*(REG32 (0xFFFFF040)))
#define VICVectAddr1    (*(REG32 (0xFFFFF044)))
#define VICVectAddr2    (*(REG32 (0xFFFFF048)))
#define VICVectAddr3    (*(REG32 (0xFFFFF04C)))
#define VICVectAddr4    (*(REG32 (0xFFFFF050)))
#define VICVectAddr5    (*(REG32 (0xFFFFF054)))
#define VICVectAddr6    (*(REG32 (0xFFFFF058)))
#define VICVectAddr7    (*(REG32 (0xFFFFF05C)))
#define VICVectAddr8    (*(REG32 (0xFFFFF060)))
#define VICVectAddr9    (*(REG32 (0xFFFFF064)))
#define VICVectAddr10   (*(REG32 (0xFFFFF068)))
#define VICVectAddr11   (*(REG32 (0xFFFFF06C)))
#define VICVectAddr12   (*(REG32 (0xFFFFF070)))
#define VICVectAddr13   (*(REG32 (0xFFFFF074)))
#define VICVectAddr14   (*(REG32 (0xFFFFF078)))
#define VICVectAddr15   (*(REG32 (0xFFFFF07C)))
#define VICVectCntl0    (*(REG32 (0xFFFFF080)))
#define VICVectCntl1    (*(REG32 (0xFFFFF084)))
#define VICVectCntl2    (*(REG32 (0xFFFFF088)))
#define VICVectCntl3    (*(REG32 (0xFFFFF08C)))
#define VICVectCntl4    (*(REG32 (0xFFFFF090)))
#define VICVectCntl5    (*(REG32 (0xFFFFF094)))
#define VICVectCntl6    (*(REG32 (0xFFFFF098)))
#define VICVectCntl7    (*(REG32 (0xFFFFF09C)))
#define VICVectCntl8    (*(REG32 (0xFFFFF0A0)))
#define VICVectCntl9    (*(REG32 (0xFFFFF0A4)))
#define VICVectCntl10   (*(REG32 (0xFFFFF0A8)))
#define VICVectCntl11   (*(REG32 (0xFFFFF0AC)))
#define VICVectCntl12   (*(REG32 (0xFFFFF0B0)))
#define VICVectCntl13   (*(REG32 (0xFFFFF0B4)))
#define VICVectCntl14   (*(REG32 (0xFFFFF0B8)))
#define VICVectCntl15   (*(REG32 (0xFFFFF0BC)))

#endif // storm_soc_basic_h
