/*----------------------------------------------------------------
//                                                              //
//  amber-func-jumps.c                                          //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Creates a little database of all the function names and     //
//  addresses is a given disassembly file and then uses it      //
//  to list out the jumps in the Amber disassembly log file.    //
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
#include <string.h> 
#define NAMES_SIZE 20000

struct func_name
{
    char name[48];
    unsigned int address;
};    

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


unsigned int conv_dstring ( char *string, unsigned int * addr)
{
unsigned int pos = 0;
*addr = 0;

while (((string[pos] >= '0' && string[pos] <= '9')) && pos < 9) {
    *addr =  (*addr * 10) + ( string[pos++] - '0' );
    }
    
return pos;    
}


int main (int argc, char **argv)
{
FILE *jumps_file;
FILE *func_names_file;
int i, num_func_names, to_func_num, found, exhausted, exact, start, mid, end;
int bytes_read;
size_t nbytes = 100;
char *line_buffer;
unsigned int addr;

struct func_name func_names [NAMES_SIZE];
char a[12], n[48];
char s_clk_count[12], s_from_addr[12], s_to_addr[12], s_r0[12], s_r1[12];
unsigned int from_addr, to_addr, clk_count;
unsigned int x;
char current_func_name [48] = "none";

unsigned int slen;

if (argc < 3)
    {
    printf("errer agrc = %d - need jums file name, func_names file name\n", argc);
    return 1;
    }

jumps_file = fopen (argv[1], "r");
func_names_file = fopen (argv[2], "r");


if (jumps_file==NULL)
    {
    printf("jumps file open failed\n");
    return 1;
    }
    
if (func_names_file==NULL)
    {
    printf("jumps file open failed\n");
    return 1;
    }


/* Read the function names file into a structure */
/* reads a line */
line_buffer  = (char *) malloc (nbytes + 1);

i=0;
while (((bytes_read = getline (&line_buffer, &nbytes, func_names_file)) > 0) && i < NAMES_SIZE )
    {
    sscanf(line_buffer, "%s %s", a, n);
    if ( !conv_hstring(a, &addr) )
        {
        fprintf(stderr,"ERROR: conv_hstring error in func_names file with i = %d\n", i);
        return 1;
        }
    strcpy(func_names[i].name, n);
    func_names[i++].address = addr;
    } 
    
           
if ( i == NAMES_SIZE )
    {
    fprintf(stderr, "WARNING: ran out of space in the function array, can only hold %d entries\n", i);
    return 1;
    }

num_func_names = i;




/* Assign names to jumps */
while ( (bytes_read = getline (&line_buffer, &nbytes, jumps_file)) > 0)
    {
    sscanf(line_buffer, "%s %s %s %s %s", s_clk_count, s_from_addr, s_to_addr, s_r0, s_r1);
    
    if ( !conv_hstring(s_from_addr, &from_addr) )
        {
        fprintf(stderr,"ERROR: conv_hstring error in jumps file, from_addr, with i = %d\n", i);
        return 1;
        }

    if ( !conv_hstring(s_to_addr, &to_addr) )
        {
        fprintf(stderr,"ERROR: conv_hstring error in jumps file, to_addr, with i = %d\n", i);
        return 1;
        }
        
    if ( !conv_dstring(s_clk_count, &clk_count) )
        {
        fprintf(stderr,"ERROR: conv_dstring error in jumps file, r0, with i = %d\n", i);
        return 1;
        }

    /* find matching function name using binary search */
    found       = 0; 
    exhausted   = 0;
    exact       = 0;
    start       = 0; 
    end         = num_func_names-1;
    
    while ( !found && !exhausted )
        {
        mid = (start + end) / 2;
        
        if (  to_addr >= func_names[mid].address &&
             (to_addr <  func_names[mid+1].address || mid == end) )
            {
            found = 1;
            to_func_num = mid;
            if ( to_addr == func_names[mid].address ) exact = 1;
            }
        else
            {
            if ( start == end ) exhausted = 1;
            else if ( start+1 == end )
                start += 1;
            else if (to_addr > func_names[mid].address)
                start = mid;
            else    
                end = mid;
            }    
        }
    
    
    if (!found)
        fprintf(stderr,"WARNING: to_addr 0x%08x not found\n", to_addr);
            
    /* 
       now assign a function to the from_address
       this just assigns a function within the range
    */ 
    if (found) 
        {
        found =0;
        
        start = 0; 
        end = num_func_names-1;
        
        while (!found)
            {
            mid = (start + end) / 2;
            
            if (  from_addr >= func_names[mid].address &&
                 (from_addr <  func_names[mid+1].address || mid == end) )
                {
                found = 1;
                if ( strcmp ( func_names[mid].name, func_names[to_func_num].name ) )
                    {

                    if ( exact ) {                    
                        printf("%9d %s ->", clk_count, func_names[mid].name);
                        
                        slen = 35 - strlen ( func_names[mid].name );
                        if ( slen > 0 ) {
                            for (x=0;x<slen;x++) printf(" ");
                            }
                            
                        printf("( r0 %s, r1 %s ) %s\n",             
                            s_r0,                             
                            s_r1,                             
                            func_names[to_func_num].name);    
                                
                        strcpy(current_func_name, func_names[to_func_num].name);
                        
                        }   
                    else if ( strcmp(func_names[to_func_num].name, current_func_name)) {
                        printf("%9d %s <-", 
                                clk_count, 
                                func_names[to_func_num].name);
                                
                        slen = 35 - strlen ( func_names[to_func_num].name );
                        if ( slen > 0 ) {
                            for (x=0;x<slen;x++) printf(" ");
                            }
                            
                                
                        printf("( r0 %s, r1 %s )\n", 
                                s_r0, s_r1);
                        }         
                    }        
                }
            else
                {
                if ( start == end ) 
                    found = 1;
                else if ( start+1 == end )
                    start += 1;
                else if (from_addr > func_names[mid].address)
                    start = mid;
                else    
                    end = mid;
                }    
            }
        
        }
        
    }
    
fclose(func_names_file);
fclose(jumps_file);


}


