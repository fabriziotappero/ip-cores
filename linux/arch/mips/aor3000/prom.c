/*
 * This file is subject to the terms and conditions of the GNU General Public
 * License.  See the file "COPYING" in the main directory of this archive
 * for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

#include <linux/init.h>
#include <linux/bootmem.h>

#include <asm/mipsregs.h>
#include <asm/bootinfo.h>

const char *get_system_type(void)
{
        return "aoR3000 SoC";
}

void __init plat_mem_setup(void)
{
        //set_io_port_base(KSEG1);
        //ioport_resource.start, .end
        
        add_memory_region(PHYS_OFFSET, 0x08000000, BOOT_MEM_RAM);
}

void __init prom_init(void)
{
        //clear_c0_status(ST0_IM | ST0_BEV); -- not needed, done later in trap initialization
}

void __init prom_free_prom_memory(void)
{
}
