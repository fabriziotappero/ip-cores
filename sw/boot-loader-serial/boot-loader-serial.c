/*----------------------------------------------------------------
//                                                              //
//  boot-loader.c                                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  The main functions for the boot loader application. This    //
//  application is embedded in the FPGA's SRAM and is used      // 
//  to load larger applications into the DDR3 memory on         //
//  the development board.                                      //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
----------------------------------------------------------------*/

#include "amber_registers.h"
#include "stdio.h"
#include "boot-loader.h"
#include "fpga-version.h"


int main ( void ) {
    int c, esc = 0;
    char buf  [20]; /* current line */
    char lbuf [20]; /* last line    */
    int i = 0;
    int li = 0;
    int j;

    /* Enable the UART FIFO */
    *(unsigned int *) ADR_AMBER_UART0_LCRH = 0x10;
    
    printf("%cAmber Boot Loader v%s\n", 0xc, AMBER_FPGA_VERSION );  /* 0xc == new page */
    

    /* When ADR_AMBER_TEST_SIM_CTRL is non-zero, its a Verilog simulation.
       The  ADR_AMBER_TEST_SIM_CTRL register is always 0 in the real fpga
       The register is in vlog/system/test_module.v
    */   
    if ( *(unsigned int *) ADR_AMBER_TEST_SIM_CTRL ) {
        load_run(*(unsigned int *) ADR_AMBER_TEST_SIM_CTRL, 0);
        }
        

    /* Print the instructions */
    print_help();
    printf("Ready\n> ");
    
    /* Loop forever on user input */
    while (1) {
        if ((c = _inbyte (DLY_1S)) >= 0) {
        
            /* Escape Sequence ? */       
            if (c == 0x1b) esc = 1;
            else if (esc == 1 && c == 0x5b) esc = 2;  
            else if (esc == 2) {
                esc = 0;
                if (c == 'A') {
                    /* Erase current line using backspaces */
                    for (j=0;j<i;j++)  _outbyte(0x08);
                    
                    /* print last line and
                       make current line equal to last line  */
                    for (j=0;j<li;j++) _outbyte(buf[j] = lbuf[j]);
                    i = li;
                    }
                continue;    
                }
            else esc = 0;
            
            /* Character not part of escape sequence so print it 
               and add it to the buffer
            */   
            if (!esc) {
                _outbyte (c);            
                /* Backspace ? */
                if (c == 8 && i > 0) { i--; }
                else                 { buf[i++] = c; }
                }
                        
            /* End of line ? */    
            if (c == '\r' || i >= 19) { 
                if (i>1) { 
                    /* Copy current line buffer to last line buffer */
                    for (j=0;j<20;j++) lbuf[j] = buf[j]; 
                    li = i-1;
                    }
                buf[i] = 0; i = 0; 
                
                /* Process line */
                printf("\n");
                parse( buf ); 
                printf("> ");
                }
            }
        }
}


/* Parse a command line passed from main and execute the command */
void parse ( char * buf ) 
{
    unsigned int found, address, data, i, length, bytes, rdata;
    int file_size;
    char byte;
    unsigned int lcount;                            
    char bad_command_msg[] = "Invalid command";
    
    /* Ignore returns with no trext on the line */
    if (!buf[1]) return;
        
    /* Check if its a single character instruction */
    if (buf[1] == '\r') {
        switch (buf[0]) {
        
            case 'h': /* Help */
                print_help();
                break;
                
            case 'l': /* Load */  
                load_run(1,0);
                break;

            case 's': /* Status */    
                _core_status();
                /* Flush out the uart with spaces */
                print_spaces(16);
                printf  ("\n");
                break;
                
            default:    
                printf  ("%s\n", bad_command_msg);
                break;
            }
        return;    
        }


    /* Check for invalid instruction format for multi-word instructions */
    else if (buf[1] != 0x20) {
        printf ("%s\n", bad_command_msg);
        return;
        }


    switch (buf[0]) {
    
            case 'd': /* Dump block of memory */
                /* Dump memory contents <start address> <number of bytes in hex> */    
                if (get_address_data ( buf, &address, &bytes )) {
                    for (i=address;i<address+bytes;i+=4) {
                        printm (i);
                        }
                    }
                break;

            case 'j': /* Jump to <address> */  
                if (get_hex ( buf, 2, &address, &length )) { 
                    load_run(0, address);
                    }
                break;


            case 'p': /* Print String */
                /* Recover the address from the string - the address is written in hex */  
                if (get_hex ( buf, 2, &address, &length )) { 
                    length = 0;
                    lcount = 0;
                    byte = * (char *)address++;
                    while ( byte < 128 && length < 0x1000 ) {
                    
                        if ( byte != 0 )        _outbyte( byte );
                        if ( byte  == '\r' )    printf("\n"); lcount = 0;
                        if ( lcount == 79 )     printf("\n"); lcount = 0;
                        
                        byte = * (char *)address++;
                        lcount++;
                        length++;
                        }
                    }
                break;

            case 'r': /* Read address */
                /* Recover the address from the string - the address is written in hex */      
                if (get_hex ( buf, 2, &address, &length )) { 
                    printm (address);
                    }
                break;

            case 'b': /* Load binary file into address */
                /* Recover the address from the string - the address is written in hex */      
                if (get_hex ( buf, 2, &address, &length )) { 
                    load_run (5, address);
                    }
                break;

            case 'w': /* Write address */
                /* Get the address */
                if (get_address_data ( buf, &address, &data )) {
                    /* Write to memory */
                    * (unsigned int*) address = data;
                    /* read back */
                    printm (address);
                    }
                break;
            
            default:    
                printf  ("%s\n", bad_command_msg);
                break;
        }        
}


/* Load a binary file into memory via the UART
   If its an elf file, copy it into the correct memory areas
   and execute it.
*/   
void load_run( int type, unsigned int address )
{
    int file_size;        
    char * message = "Send file w/ 1K Xmodem protocol from terminal emulator now...";
    
    switch (type) {
        
        case 1: /* Load a binary file to FILE_LOAD_BASE */   
            /* Load a file using the xmodem protocol */
            printf  ("%s\n", message);

                                      /*       Destination,    Destination Size */
            file_size = xmodemReceive((char *) FILE_LOAD_BASE, FILE_MAX_SIZE);   
            if (file_size < 0 || file_size > FILE_MAX_SIZE) {
                printf ("Xmodem error file size 0x%x \n", file_size);
                return;
                }
                
            printf("\nelf split\n");
            elfsplitter(FILE_LOAD_BASE, file_size);
            break;
    

        case 2: /* testing the boot loader itself in simulation */
            print_help();
            _core_status();        
            print_spaces(16);
            _testpass();
            break;


        case 3: /* vmlinux in simulation */
            printf("j 0x%08x\n", LINUX_JUMP_ADR);
            /* Flush the uart tx buffer with spaces */
            print_spaces(16);
            printf("\n");
            /* pc jump */
            _jump_to_program(LINUX_JUMP_ADR);
            _testpass();
            break;


        case 4: /* programs starting at 0x8000 in simulation */
            printf("j 0x%08x\n", APP_JUMP_ADR);
            /* Flush the uart tx buffer with spaces */
            print_spaces(16);
            printf("\n");
            /* pc jump */
            _jump_to_program(APP_JUMP_ADR);
            _testpass();
            break;

            
        case 5: /* Load a binary file into memory, to 'address' */    
            /* Load a file using the xmodem protocol */
            printf  ("%s\n", message);
                                      /*       Destination,    Destination Size */
            file_size = xmodemReceive((char *) address, FILE_MAX_SIZE);   
            if (file_size < 0 || file_size > FILE_MAX_SIZE) {
                printf ("Xmodem error file size 0x%x \n", file_size);
                return;
                }
            break;


        default:    /* Run the program */    
            printf("j 0x%08x\n", address);
            /* Flush the uart tx buffer with spaces */
            print_spaces(16);
            printf("\n");
            /* pc jump */
            _jump_to_program(address);
            _testpass();
            break;
        }
}


/* Print a memory location */
void printm ( unsigned int address ) 
{
    printf ("mem 0x%08x = 0x%08x\n", address, * (unsigned int *)address);
}


void print_help ( void ) 

{
    printf("Commands\n");
    printf("l");                     
    print_spaces(29);
    printf(": Load elf file\n");

    printf("b <address>");                   
    print_spaces(19);
    printf(": Load binary file to <address>\n");

    printf("d <start address> <num bytes> : Dump mem\n");

    printf("h");                     
    print_spaces(29);
    printf(": Print help message\n");

    printf("j <address>");                     
    print_spaces(19);
    printf(": Execute loaded elf, jumping to <address>\n");

    printf("p <address>");                   
    print_spaces(19);
    printf(": Print ascii mem until first 0\n");
    
    printf("r <address>");                   
    print_spaces(19);
    printf(": Read mem\n");

    printf("s");                              
    print_spaces(29);
    printf(": Core status\n");
    
    printf("w <address> <value>");            
    print_spaces(11);
    printf(": Write mem\n");    
}


/* Print a number of spaces */
void print_spaces ( int num ) 
{
    while(num--) printf(" ");
}


/* Return a number recovered from a string of hex digits */
int get_hex ( char * buf, int start_position, 
              unsigned int *address, 
              unsigned int *length) 
{
                       
    int cpos = 0, done = 0;

    cpos = start_position; done = 0; *address = 0;

    while (done == 0) {    
        if ( buf[cpos] >= '0' && buf[cpos] <= '9' ) {
           *address = *address<<4;
           *address = *address + buf[cpos] - '0';
           }
        else if ( buf[cpos] >= 'A' && buf[cpos] <= 'F' ) {
            *address = *address<<4;
            *address = *address + buf[cpos] - 'A' + 10;
           }
        else if ( buf[cpos] >= 'a' && buf[cpos] <= 'f' ) {
            *address = *address<<4;
            *address = *address + buf[cpos] - 'a' + 10;
           }
        else  {
            done = 1;
            *length = cpos - start_position;
            }
        if ( cpos >= 8+start_position ) {
            done = 1;
            *length = 8;
            }
        cpos++;
        }
            
    /* Return the length of the hexadecimal string */
    if (cpos > start_position+1) return 1; else return 0;
}


/* Parse a string for an address and data in hex */
int get_address_data ( char * buf, unsigned int *address, unsigned int *data ) 
{
    int found, length;

    found = get_hex ( buf, 2, address, &length );
    if (found) {
        /* Get the data */
        found = get_hex ( buf, 3+length, data, &length );
        }
    
    return found;    
}

