#ifndef __MEM_MAP_H__
#define __MEM_MAP_H__

//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------
#define IO_BASE             0x12000000

//-----------------------------------------------------------------
// Macros:
//-----------------------------------------------------------------
#define REG8                (volatile unsigned char*)
#define REG16               (volatile unsigned short*)
#define REG32               (volatile unsigned int*)

//-----------------------------------------------------------------
// Peripheral Base Addresses
//-----------------------------------------------------------------
#define UART_BASE               (IO_BASE + 0x000)
#define TIMER_BASE              (IO_BASE + 0x100)
#define INTR_BASE               (IO_BASE + 0x200)

//-----------------------------------------------------------------
// Interrupts
//-----------------------------------------------------------------
#define IRQ_UART_RX             0
#define IRQ_TIMER_SYSTICK       1
#define IRQ_TIMER_HIRES         2
#define IRQ_EXT_INT0            8

//-----------------------------------------------------------------
// Peripheral Registers
//-----------------------------------------------------------------

// UART
#define UART_USR            (*(REG32 (UART_BASE + 0x4)))
#define UART_UDR            (*(REG32 (UART_BASE + 0x8)))

// TIMER
#define TIMER_VAL           (*(REG32 (TIMER_BASE + 0x0)))
#define SYS_CLK_COUNT       (*(REG32 (TIMER_BASE + 0x4)))

// IRQ
#define IRQ_MASK            (*(REG32 (INTR_BASE + 0x00)))
#define IRQ_MASK_SET        (*(REG32 (INTR_BASE + 0x00)))
#define IRQ_MASK_CLR        (*(REG32 (INTR_BASE + 0x04)))
#define IRQ_STATUS          (*(REG32 (INTR_BASE + 0x08)))    

#endif 
