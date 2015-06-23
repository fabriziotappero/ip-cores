/*----------------------------------------------------------------
//                                                              //
//  amber-mem-ascii                                             //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Take a stream of hex format text and convert to ascii       //
//  format. E.g. converts 4B to K                               //
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


#include <stdio.h>
#include <stdlib.h> 


int conv_hstring ( char *string, unsigned int * addr)
{
    int pos = 0;                                                     
    *addr = 0;                                                       

    while (((string[pos] >= '0' && string[pos] <= '9') ||            
           (string[pos] >= 'a' && string[pos] <= 'f')) && pos < 9) { 
        if (string[pos] >= '0' && string[pos] <= '9')                
            *addr =  (*addr << 4) + ( string[pos++] - '0' );         
        else                                                         
            *addr =  (*addr << 4) + ( string[pos++] - 'a' ) + 10;    
        }                                                            
                                                                     
    return pos;                                                      
}


int main (int argc, char **argv)
{
    FILE *input_file;
    int i;
    int bytes_read;
    size_t nbytes = 100;
    char *line_buffer;

    char s_number[12];
    unsigned int number;

    input_file = stdin;

    if (input_file==NULL)
        {
        printf("Input file open failed\n");
        return 1;
        }
        

    /* Read the input file into a structure */
    /* reads a line */
    line_buffer  = (char *) malloc (nbytes + 1);

    /* Assign names to jumps */
    while ( (bytes_read = getline (&line_buffer, &nbytes, input_file)) > 0)
        {
        sscanf(line_buffer, "%s", s_number);
        
        if ( !conv_hstring(s_number, &number) )
            {
            fprintf(stderr,"ERROR: conv_hstring error in jumps file, number, with i = %d\n", i);
            return 1;
            }

        printf("%c", number);        
        }
        
    fclose(input_file);

}


