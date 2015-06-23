/*
 * system.h - SOPC Builder system and BSP software package information
 *
 * Machine generated for CPU 'nios2_qsys_0' in SOPC Builder design 'vga_soc'
 * SOPC Builder design path: ../../vga_soc.sopcinfo
 *
 * Generated: Wed Aug 14 20:55:36 CEST 2013
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
#define ALT_CPU_BREAK_ADDR 0x30820
#define ALT_CPU_CPU_FREQ 50000000u
#define ALT_CPU_CPU_ID_SIZE 1
#define ALT_CPU_CPU_ID_VALUE 0x00000000
#define ALT_CPU_CPU_IMPLEMENTATION "tiny"
#define ALT_CPU_DATA_ADDR_WIDTH 0x14
#define ALT_CPU_DCACHE_LINE_SIZE 0
#define ALT_CPU_DCACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_DCACHE_SIZE 0
#define ALT_CPU_EXCEPTION_ADDR 0x28020
#define ALT_CPU_FLUSHDA_SUPPORTED
#define ALT_CPU_FREQ 50000000
#define ALT_CPU_HARDWARE_DIVIDE_PRESENT 0
#define ALT_CPU_HARDWARE_MULTIPLY_PRESENT 0
#define ALT_CPU_HARDWARE_MULX_PRESENT 0
#define ALT_CPU_HAS_DEBUG_CORE 1
#define ALT_CPU_HAS_DEBUG_STUB
#define ALT_CPU_HAS_JMPI_INSTRUCTION
#define ALT_CPU_ICACHE_LINE_SIZE 0
#define ALT_CPU_ICACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_ICACHE_SIZE 0
#define ALT_CPU_INST_ADDR_WIDTH 0x12
#define ALT_CPU_NAME "nios2_qsys_0"
#define ALT_CPU_RESET_ADDR 0x28000


/*
 * CPU configuration (with legacy prefix - don't use these anymore)
 *
 */

#define NIOS2_BIG_ENDIAN 0
#define NIOS2_BREAK_ADDR 0x30820
#define NIOS2_CPU_FREQ 50000000u
#define NIOS2_CPU_ID_SIZE 1
#define NIOS2_CPU_ID_VALUE 0x00000000
#define NIOS2_CPU_IMPLEMENTATION "tiny"
#define NIOS2_DATA_ADDR_WIDTH 0x14
#define NIOS2_DCACHE_LINE_SIZE 0
#define NIOS2_DCACHE_LINE_SIZE_LOG2 0
#define NIOS2_DCACHE_SIZE 0
#define NIOS2_EXCEPTION_ADDR 0x28020
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
#define NIOS2_INST_ADDR_WIDTH 0x12
#define NIOS2_RESET_ADDR 0x28000


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __ALTERA_AVALON_JTAG_UART
#define __ALTERA_AVALON_ONCHIP_MEMORY2
#define __ALTERA_NIOS2_QSYS
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
#define ALT_STDERR "/dev/jtag_uart_0"
#define ALT_STDERR_BASE 0x31440
#define ALT_STDERR_DEV jtag_uart_0
#define ALT_STDERR_IS_JTAG_UART
#define ALT_STDERR_PRESENT
#define ALT_STDERR_TYPE "altera_avalon_jtag_uart"
#define ALT_STDIN "/dev/jtag_uart_0"
#define ALT_STDIN_BASE 0x31440
#define ALT_STDIN_DEV jtag_uart_0
#define ALT_STDIN_IS_JTAG_UART
#define ALT_STDIN_PRESENT
#define ALT_STDIN_TYPE "altera_avalon_jtag_uart"
#define ALT_STDOUT "/dev/jtag_uart_0"
#define ALT_STDOUT_BASE 0x31440
#define ALT_STDOUT_DEV jtag_uart_0
#define ALT_STDOUT_IS_JTAG_UART
#define ALT_STDOUT_PRESENT
#define ALT_STDOUT_TYPE "altera_avalon_jtag_uart"
#define ALT_SYSTEM_NAME "vga_soc"


/*
 * hal configuration
 *
 */

#define ALT_MAX_FD 32
#define ALT_SYS_CLK none
#define ALT_TIMESTAMP_CLK none


/*
 * jtag_uart_0 configuration
 *
 */

#define ALT_MODULE_CLASS_jtag_uart_0 altera_avalon_jtag_uart
#define JTAG_UART_0_BASE 0x31440
#define JTAG_UART_0_IRQ 0
#define JTAG_UART_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define JTAG_UART_0_NAME "/dev/jtag_uart_0"
#define JTAG_UART_0_READ_DEPTH 64
#define JTAG_UART_0_READ_THRESHOLD 8
#define JTAG_UART_0_SPAN 8
#define JTAG_UART_0_TYPE "altera_avalon_jtag_uart"
#define JTAG_UART_0_WRITE_DEPTH 64
#define JTAG_UART_0_WRITE_THRESHOLD 8


/*
 * onchip_0 configuration
 *
 */

#define ALT_MODULE_CLASS_onchip_0 altera_avalon_onchip_memory2
#define ONCHIP_0_ALLOW_IN_SYSTEM_MEMORY_CONTENT_EDITOR 0
#define ONCHIP_0_ALLOW_MRAM_SIM_CONTENTS_ONLY_FILE 0
#define ONCHIP_0_BASE 0x28000
#define ONCHIP_0_CONTENTS_INFO ""
#define ONCHIP_0_DUAL_PORT 0
#define ONCHIP_0_GUI_RAM_BLOCK_TYPE "AUTO"
#define ONCHIP_0_INIT_CONTENTS_FILE "vga_soc_onchip_0"
#define ONCHIP_0_INIT_MEM_CONTENT 1
#define ONCHIP_0_INSTANCE_ID "NONE"
#define ONCHIP_0_IRQ -1
#define ONCHIP_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define ONCHIP_0_NAME "/dev/onchip_0"
#define ONCHIP_0_NON_DEFAULT_INIT_FILE_ENABLED 0
#define ONCHIP_0_RAM_BLOCK_TYPE "AUTO"
#define ONCHIP_0_READ_DURING_WRITE_MODE "DONT_CARE"
#define ONCHIP_0_SINGLE_CLOCK_OP 0
#define ONCHIP_0_SIZE_MULTIPLE 1
#define ONCHIP_0_SIZE_VALUE 32768
#define ONCHIP_0_SPAN 32768
#define ONCHIP_0_TYPE "altera_avalon_onchip_memory2"
#define ONCHIP_0_WRITABLE 1


/*
 * vga_0_io_b configuration
 *
 */

#define ALT_MODULE_CLASS_vga_0_io_b vga
#define VGA_0_IO_B_BASE 0x3b0
#define VGA_0_IO_B_IRQ -1
#define VGA_0_IO_B_IRQ_INTERRUPT_CONTROLLER_ID -1
#define VGA_0_IO_B_NAME "/dev/vga_0_io_b"
#define VGA_0_IO_B_SPAN 16
#define VGA_0_IO_B_TYPE "vga"


/*
 * vga_0_io_c configuration
 *
 */

#define ALT_MODULE_CLASS_vga_0_io_c vga
#define VGA_0_IO_C_BASE 0x3c0
#define VGA_0_IO_C_IRQ -1
#define VGA_0_IO_C_IRQ_INTERRUPT_CONTROLLER_ID -1
#define VGA_0_IO_C_NAME "/dev/vga_0_io_c"
#define VGA_0_IO_C_SPAN 16
#define VGA_0_IO_C_TYPE "vga"


/*
 * vga_0_io_d configuration
 *
 */

#define ALT_MODULE_CLASS_vga_0_io_d vga
#define VGA_0_IO_D_BASE 0x3d0
#define VGA_0_IO_D_IRQ -1
#define VGA_0_IO_D_IRQ_INTERRUPT_CONTROLLER_ID -1
#define VGA_0_IO_D_NAME "/dev/vga_0_io_d"
#define VGA_0_IO_D_SPAN 16
#define VGA_0_IO_D_TYPE "vga"


/*
 * vga_0_mem configuration
 *
 */

#define ALT_MODULE_CLASS_vga_0_mem vga
#define VGA_0_MEM_BASE 0xa0000
#define VGA_0_MEM_IRQ -1
#define VGA_0_MEM_IRQ_INTERRUPT_CONTROLLER_ID -1
#define VGA_0_MEM_NAME "/dev/vga_0_mem"
#define VGA_0_MEM_SPAN 131072
#define VGA_0_MEM_TYPE "vga"


/*
 * vga_0_sys configuration
 *
 */

#define ALT_MODULE_CLASS_vga_0_sys vga
#define VGA_0_SYS_BASE 0x31000
#define VGA_0_SYS_IRQ -1
#define VGA_0_SYS_IRQ_INTERRUPT_CONTROLLER_ID -1
#define VGA_0_SYS_NAME "/dev/vga_0_sys"
#define VGA_0_SYS_SPAN 1024
#define VGA_0_SYS_TYPE "vga"

#endif /* __SYSTEM_H_ */
