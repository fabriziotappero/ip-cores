#!/usr/bin/env python

import elf

# Calculate the size of loadable sections of elf binary
def elf_binary_size(img):
    elffile = elf.ElfFile.from_file(img)
    paddr_first = 0
    paddr_start = 0
    paddr_end = 0
    for pheader in elffile.pheaders:
        x = pheader.ai
        if str(x.p_type) != "LOAD":
            continue
        if paddr_first == 0:
            paddr_first = 1
            paddr_start = x.p_paddr.value
        if paddr_start > x.p_paddr.value:
            paddr_start = x.p_paddr.value
        if paddr_end < x.p_paddr + x.p_memsz:
            paddr_end = x.p_paddr + x.p_memsz
    return paddr_end - paddr_start

