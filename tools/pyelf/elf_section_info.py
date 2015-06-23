#!/usr/bin/env python

import elf

# Define section markers for various sections in elf
def elf_loadable_section_info(img):
    elffile = elf.ElfFile.from_file(img)

    # Sections markers for RW sections
    rw_sections_start = 0
    rw_sections_end = 0

    # Section markers for RX and RO section combined
    rx_sections_start = 0
    rx_sections_end = 0

    # Flag encoding used by elf
    sh_flag_write = 1 << 0
    sh_flag_load = 1 << 1
    sh_flag_execute = 1 << 2

    for sheader in elffile.sheaders:
	x = sheader.ai

        # Check for loadable sections
        if x.sh_flags.get() & sh_flag_load:
		start = x.sh_addr.get()
		end = start + x.sh_size.get()

	        # RW Section
                if x.sh_flags.get() & sh_flag_write:
                    if (rw_sections_start == 0) or (rw_sections_start > start):
                        rw_sections_start = start
                    if (rw_sections_end == 0) or (rw_sections_end < end):
                        rw_sections_end = end

            	# RX, RO Section
    	    	else:
		    if (rx_sections_start == 0) or (rx_sections_start > start):
			    rx_sections_start = start
                    if (rx_sections_end == 0) or (rx_sections_end < end):
                            rx_sections_end = end

    return rw_sections_start, rw_sections_end, \
           rx_sections_start, rx_sections_end

