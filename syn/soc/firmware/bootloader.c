/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

volatile unsigned int *jtag = (unsigned int *)0xBFFFFFF0;

void jtag_print(char *ptr) {
    
    while((*ptr) != 0) {
        while((jtag[1] & 0xFFFF0000) == 0) { ; } 
        jtag[0] = (*ptr);
        ptr++;
    }
}

void start_bootloader() {
    jtag_print("Press any key to boot kernel...\n");
    
    while((jtag[0] & 0x8000) == 0) { ; }
    
    jtag_print("Booting kernel...\n");
        
    void (*boot_func)(void) = (void (*)(void))0x80000400;
    
    boot_func();
    
    while(1) { ; }
}
