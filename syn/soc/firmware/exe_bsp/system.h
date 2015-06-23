/*
 * system.h - SOPC Builder system and BSP software package information
 *
 * Machine generated for CPU 'nios2' in SOPC Builder design 'system'
 * SOPC Builder design path: ../../system.sopcinfo
 *
 * Generated: Fri Jan 17 00:23:52 CET 2014
 */

/*
 * DO NOT MODIFY THIS FILE
 *
 * Changing this file will have subtle consequences
 * which will almost certainly lead to a nonfunctioning
 * system. If you do modify this file, be aware that your
 * changes will be overwritten and lost when this file
 * is generated again.
 *
 * DO NOT MODIFY THIS FILE
 */

/*
 * License Agreement
 *
 * Copyright (c) 2008
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */

#ifndef __SYSTEM_H_
#define __SYSTEM_H_

/* Include definitions from linker script generator */
#include "linker.h"


/*
 * CPU configuration
 *
 */

#define ALT_CPU_ARCHITECTURE "altera_nios2_qsys"
#define ALT_CPU_BIG_ENDIAN 0
#define ALT_CPU_BREAK_ADDR 0x00009820
#define ALT_CPU_CPU_FREQ 30000000u
#define ALT_CPU_CPU_ID_SIZE 1
#define ALT_CPU_CPU_ID_VALUE 0x00000000
#define ALT_CPU_CPU_IMPLEMENTATION "tiny"
#define ALT_CPU_DATA_ADDR_WIDTH 0x1c
#define ALT_CPU_DCACHE_LINE_SIZE 0
#define ALT_CPU_DCACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_DCACHE_SIZE 0
#define ALT_CPU_EXCEPTION_ADDR 0x00010020
#define ALT_CPU_FLUSHDA_SUPPORTED
#define ALT_CPU_FREQ 30000000
#define ALT_CPU_HARDWARE_DIVIDE_PRESENT 0
#define ALT_CPU_HARDWARE_MULTIPLY_PRESENT 0
#define ALT_CPU_HARDWARE_MULX_PRESENT 0
#define ALT_CPU_HAS_DEBUG_CORE 1
#define ALT_CPU_HAS_DEBUG_STUB
#define ALT_CPU_HAS_JMPI_INSTRUCTION
#define ALT_CPU_ICACHE_LINE_SIZE 0
#define ALT_CPU_ICACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_ICACHE_SIZE 0
#define ALT_CPU_INST_ADDR_WIDTH 0x11
#define ALT_CPU_NAME "nios2"
#define ALT_CPU_RESET_ADDR 0x00010000


/*
 * CPU configuration (with legacy prefix - don't use these anymore)
 *
 */

#define NIOS2_BIG_ENDIAN 0
#define NIOS2_BREAK_ADDR 0x00009820
#define NIOS2_CPU_FREQ 30000000u
#define NIOS2_CPU_ID_SIZE 1
#define NIOS2_CPU_ID_VALUE 0x00000000
#define NIOS2_CPU_IMPLEMENTATION "tiny"
#define NIOS2_DATA_ADDR_WIDTH 0x1c
#define NIOS2_DCACHE_LINE_SIZE 0
#define NIOS2_DCACHE_LINE_SIZE_LOG2 0
#define NIOS2_DCACHE_SIZE 0
#define NIOS2_EXCEPTION_ADDR 0x00010020
#define NIOS2_FLUSHDA_SUPPORTED
#define NIOS2_HARDWARE_DIVIDE_PRESENT 0
#define NIOS2_HARDWARE_MULTIPLY_PRESENT 0
#define NIOS2_HARDWARE_MULX_PRESENT 0
#define NIOS2_HAS_DEBUG_CORE 1
#define NIOS2_HAS_DEBUG_STUB
#define NIOS2_HAS_JMPI_INSTRUCTION
#define NIOS2_ICACHE_LINE_SIZE 0
#define NIOS2_ICACHE_LINE_SIZE_LOG2 0
#define NIOS2_ICACHE_SIZE 0
#define NIOS2_INST_ADDR_WIDTH 0x11
#define NIOS2_RESET_ADDR 0x00010000


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __ALTERA_AVALON_JTAG_UART
#define __ALTERA_AVALON_NEW_SDRAM_CONTROLLER
#define __ALTERA_AVALON_ONCHIP_MEMORY2
#define __ALTERA_AVALON_PIO
#define __ALTERA_NIOS2_QSYS
#define __DRIVER_SD
#define __FLOPPY
#define __HDD
#define __PC_BUS
#define __PIT
#define __RTC
#define __SOUND
#define __VGA


/*
 * System configuration
 *
 */

#define ALT_DEVICE_FAMILY "Cyclone IV E"
#define ALT_ENHANCED_INTERRUPT_API_PRESENT
#define ALT_IRQ_BASE NULL
#define ALT_LOG_PORT "/dev/null"
#define ALT_LOG_PORT_BASE 0x0
#define ALT_LOG_PORT_DEV null
#define ALT_LOG_PORT_TYPE ""
#define ALT_NUM_EXTERNAL_INTERRUPT_CONTROLLERS 0
#define ALT_NUM_INTERNAL_INTERRUPT_CONTROLLERS 1
#define ALT_NUM_INTERRUPT_CONTROLLERS 1
#define ALT_STDERR "/dev/null"
#define ALT_STDERR_BASE 0x0
#define ALT_STDERR_DEV null
#define ALT_STDERR_TYPE ""
#define ALT_STDIN "/dev/null"
#define ALT_STDIN_BASE 0x0
#define ALT_STDIN_DEV null
#define ALT_STDIN_TYPE ""
#define ALT_STDOUT "/dev/jtag_uart"
#define ALT_STDOUT_BASE 0x8888
#define ALT_STDOUT_DEV jtag_uart
#define ALT_STDOUT_IS_JTAG_UART
#define ALT_STDOUT_PRESENT
#define ALT_STDOUT_TYPE "altera_avalon_jtag_uart"
#define ALT_SYSTEM_NAME "system"


/*
 * driver_sd configuration
 *
 */

#define ALT_MODULE_CLASS_driver_sd driver_sd
#define DRIVER_SD_BASE 0x0
#define DRIVER_SD_IRQ -1
#define DRIVER_SD_IRQ_INTERRUPT_CONTROLLER_ID -1
#define DRIVER_SD_NAME "/dev/driver_sd"
#define DRIVER_SD_SPAN 16
#define DRIVER_SD_TYPE "driver_sd"


/*
 * floppy configuration
 *
 */

#define ALT_MODULE_CLASS_floppy floppy
#define FLOPPY_BASE 0x8800
#define FLOPPY_IRQ -1
#define FLOPPY_IRQ_INTERRUPT_CONTROLLER_ID -1
#define FLOPPY_NAME "/dev/floppy"
#define FLOPPY_SPAN 64
#define FLOPPY_TYPE "floppy"


/*
 * hal configuration
 *
 */

#define ALT_MAX_FD 4
#define ALT_SYS_CLK none
#define ALT_TIMESTAMP_CLK none


/*
 * hdd configuration
 *
 */

#define ALT_MODULE_CLASS_hdd hdd
#define HDD_BASE 0x8840
#define HDD_IRQ -1
#define HDD_IRQ_INTERRUPT_CONTROLLER_ID -1
#define HDD_NAME "/dev/hdd"
#define HDD_SPAN 32
#define HDD_TYPE "hdd"


/*
 * jtag_uart configuration
 *
 */

#define ALT_MODULE_CLASS_jtag_uart altera_avalon_jtag_uart
#define JTAG_UART_BASE 0x8888
#define JTAG_UART_IRQ 0
#define JTAG_UART_IRQ_INTERRUPT_CONTROLLER_ID 0
#define JTAG_UART_NAME "/dev/jtag_uart"
#define JTAG_UART_READ_DEPTH 256
#define JTAG_UART_READ_THRESHOLD 8
#define JTAG_UART_SPAN 8
#define JTAG_UART_TYPE "altera_avalon_jtag_uart"
#define JTAG_UART_WRITE_DEPTH 256
#define JTAG_UART_WRITE_THRESHOLD 8


/*
 * onchip_for_nios2 configuration
 *
 */

#define ALT_MODULE_CLASS_onchip_for_nios2 altera_avalon_onchip_memory2
#define ONCHIP_FOR_NIOS2_ALLOW_IN_SYSTEM_MEMORY_CONTENT_EDITOR 0
#define ONCHIP_FOR_NIOS2_ALLOW_MRAM_SIM_CONTENTS_ONLY_FILE 0
#define ONCHIP_FOR_NIOS2_BASE 0x10000
#define ONCHIP_FOR_NIOS2_CONTENTS_INFO ""
#define ONCHIP_FOR_NIOS2_DUAL_PORT 0
#define ONCHIP_FOR_NIOS2_GUI_RAM_BLOCK_TYPE "AUTO"
#define ONCHIP_FOR_NIOS2_INIT_CONTENTS_FILE "system_onchip_for_nios2"
#define ONCHIP_FOR_NIOS2_INIT_MEM_CONTENT 1
#define ONCHIP_FOR_NIOS2_INSTANCE_ID "NONE"
#define ONCHIP_FOR_NIOS2_IRQ -1
#define ONCHIP_FOR_NIOS2_IRQ_INTERRUPT_CONTROLLER_ID -1
#define ONCHIP_FOR_NIOS2_NAME "/dev/onchip_for_nios2"
#define ONCHIP_FOR_NIOS2_NON_DEFAULT_INIT_FILE_ENABLED 0
#define ONCHIP_FOR_NIOS2_RAM_BLOCK_TYPE "AUTO"
#define ONCHIP_FOR_NIOS2_READ_DURING_WRITE_MODE "DONT_CARE"
#define ONCHIP_FOR_NIOS2_SINGLE_CLOCK_OP 0
#define ONCHIP_FOR_NIOS2_SIZE_MULTIPLE 1
#define ONCHIP_FOR_NIOS2_SIZE_VALUE 32768
#define ONCHIP_FOR_NIOS2_SPAN 32768
#define ONCHIP_FOR_NIOS2_TYPE "altera_avalon_onchip_memory2"
#define ONCHIP_FOR_NIOS2_WRITABLE 1


/*
 * pc_bus configuration
 *
 */

#define ALT_MODULE_CLASS_pc_bus pc_bus
#define PC_BUS_BASE 0x88a0
#define PC_BUS_IRQ -1
#define PC_BUS_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PC_BUS_NAME "/dev/pc_bus"
#define PC_BUS_SPAN 16
#define PC_BUS_TYPE "pc_bus"


/*
 * pio_input configuration
 *
 */

#define ALT_MODULE_CLASS_pio_input altera_avalon_pio
#define PIO_INPUT_BASE 0x8890
#define PIO_INPUT_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_INPUT_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_INPUT_CAPTURE 1
#define PIO_INPUT_DATA_WIDTH 8
#define PIO_INPUT_DO_TEST_BENCH_WIRING 0
#define PIO_INPUT_DRIVEN_SIM_VALUE 0
#define PIO_INPUT_EDGE_TYPE "RISING"
#define PIO_INPUT_FREQ 30000000
#define PIO_INPUT_HAS_IN 1
#define PIO_INPUT_HAS_OUT 0
#define PIO_INPUT_HAS_TRI 0
#define PIO_INPUT_IRQ -1
#define PIO_INPUT_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_INPUT_IRQ_TYPE "NONE"
#define PIO_INPUT_NAME "/dev/pio_input"
#define PIO_INPUT_RESET_VALUE 0
#define PIO_INPUT_SPAN 16
#define PIO_INPUT_TYPE "altera_avalon_pio"


/*
 * pio_output configuration
 *
 */

#define ALT_MODULE_CLASS_pio_output altera_avalon_pio
#define PIO_OUTPUT_BASE 0x8860
#define PIO_OUTPUT_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_OUTPUT_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_OUTPUT_CAPTURE 0
#define PIO_OUTPUT_DATA_WIDTH 8
#define PIO_OUTPUT_DO_TEST_BENCH_WIRING 0
#define PIO_OUTPUT_DRIVEN_SIM_VALUE 0
#define PIO_OUTPUT_EDGE_TYPE "NONE"
#define PIO_OUTPUT_FREQ 30000000
#define PIO_OUTPUT_HAS_IN 0
#define PIO_OUTPUT_HAS_OUT 1
#define PIO_OUTPUT_HAS_TRI 0
#define PIO_OUTPUT_IRQ -1
#define PIO_OUTPUT_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_OUTPUT_IRQ_TYPE "NONE"
#define PIO_OUTPUT_NAME "/dev/pio_output"
#define PIO_OUTPUT_RESET_VALUE 255
#define PIO_OUTPUT_SPAN 16
#define PIO_OUTPUT_TYPE "altera_avalon_pio"


/*
 * pit configuration
 *
 */

#define ALT_MODULE_CLASS_pit pit
#define PIT_BASE 0x8880
#define PIT_IRQ -1
#define PIT_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIT_NAME "/dev/pit"
#define PIT_SPAN 8
#define PIT_TYPE "pit"


/*
 * rtc configuration
 *
 */

#define ALT_MODULE_CLASS_rtc rtc
#define RTC_BASE 0x8c00
#define RTC_IRQ -1
#define RTC_IRQ_INTERRUPT_CONTROLLER_ID -1
#define RTC_NAME "/dev/rtc"
#define RTC_SPAN 1024
#define RTC_TYPE "rtc"


/*
 * sdram configuration
 *
 */

#define ALT_MODULE_CLASS_sdram altera_avalon_new_sdram_controller
#define SDRAM_BASE 0x8000000
#define SDRAM_CAS_LATENCY 2
#define SDRAM_CONTENTS_INFO
#define SDRAM_INIT_NOP_DELAY 0.0
#define SDRAM_INIT_REFRESH_COMMANDS 2
#define SDRAM_IRQ -1
#define SDRAM_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SDRAM_IS_INITIALIZED 1
#define SDRAM_NAME "/dev/sdram"
#define SDRAM_POWERUP_DELAY 100.0
#define SDRAM_REFRESH_PERIOD 15.625
#define SDRAM_REGISTER_DATA_IN 1
#define SDRAM_SDRAM_ADDR_WIDTH 0x19
#define SDRAM_SDRAM_BANK_WIDTH 2
#define SDRAM_SDRAM_COL_WIDTH 10
#define SDRAM_SDRAM_DATA_WIDTH 32
#define SDRAM_SDRAM_NUM_BANKS 4
#define SDRAM_SDRAM_NUM_CHIPSELECTS 1
#define SDRAM_SDRAM_ROW_WIDTH 13
#define SDRAM_SHARED_DATA 0
#define SDRAM_SIM_MODEL_BASE 0
#define SDRAM_SPAN 134217728
#define SDRAM_STARVATION_INDICATOR 0
#define SDRAM_TRISTATE_BRIDGE_SLAVE ""
#define SDRAM_TYPE "altera_avalon_new_sdram_controller"
#define SDRAM_T_AC 5.5
#define SDRAM_T_MRD 3
#define SDRAM_T_RCD 20.0
#define SDRAM_T_RFC 70.0
#define SDRAM_T_RP 20.0
#define SDRAM_T_WR 14.0


/*
 * sound configuration
 *
 */

#define ALT_MODULE_CLASS_sound sound
#define SOUND_BASE 0x9000
#define SOUND_IRQ -1
#define SOUND_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SOUND_NAME "/dev/sound"
#define SOUND_SPAN 2048
#define SOUND_TYPE "sound"


/*
 * vga configuration
 *
 */

#define ALT_MODULE_CLASS_vga vga
#define VGA_BASE 0xa000
#define VGA_IRQ -1
#define VGA_IRQ_INTERRUPT_CONTROLLER_ID -1
#define VGA_NAME "/dev/vga"
#define VGA_SPAN 1024
#define VGA_TYPE "vga"

#endif /* __SYSTEM_H_ */
