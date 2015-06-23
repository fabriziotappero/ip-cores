/******************************************************************************/
/*            _   _            __   ____                                      */
/*           / / | |          / _| |  __|                                     */
/*           | |_| |  _   _  / /   | |_                                       */
/*           |  _  | | | | | | |   |  _|                                      */
/*           | | | | | |_| | \ \_  | |__                                      */
/*           |_| |_| \_____|  \__| |____| microLab                            */
/*                                                                            */
/*           Bern University of Applied Sciences (BFH)                        */
/*           Quellgasse 21                                                    */
/*           Room HG 4.33                                                     */
/*           2501 Biel/Bienne                                                 */
/*           Switzerland                                                      */
/*                                                                            */
/*           http://www.microlab.ch                                           */
/******************************************************************************/
/*   GECKO4com
    
     2010/2011 Dr. Theo Kluter
    
     This program is free software: you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation, either version 3 of the License, or
     (at your option) any later version.
    
     This program is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     GNU General Public License for more details. 
     You should have received a copy of the GNU General Public License
     along with these sources.  If not, see <http://www.gnu.org/licenses/>.
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* IMPORTANT: The below table list the already implemented SCPI commands. You
   can add more yourself, but must refrain from:
   1) Editing the ID values of the present SCPI commands.
   2) Using duplicate ID values or duplicate commands!
   3) Using commands longer than 14 chars
*/

#define nr_of_known_scpi_commands 36
const char *scpi_table[nr_of_known_scpi_commands*2] = {
/* ID , command */
"2","*CLS",
"6","*ESE",
"7","*ESE?",
"8","*ESR?",
"9","*IDN?",
"10","*IST?",
"11","*OPC",
"12","*OPC?",
"13","*PUD",
"14","*PUD?",
"15","*RST",
"16","*SRE",
"17","*SRE?",
"18","*STB?",
"20","*TST?",
"21","*WAI",
"22","BITFLASH",
"23","BITFLASH?",
"24","BOARD?",
"25","CONFIG",
"26","ERASE",
"27","FIFO",
"28","FIFO?",
"29","FPGA",
"30","FPGA?",
"35","HEXSWITCH",
"36","HEXSWITCH?",
"37","IDENTIFY",
"51","TRANS",
"58","USERRESET",
"59","VGA:BGCOL",
"60","VGA:CLEAR",
"61","VGA:CURSOR",
"62","VGA:CURSOR?",
"63","VGA:FGCOL",
"64","VGA:PUTSTR"};

typedef struct comand_type {
   unsigned char ID;
   char *command;
} comand_type_t;

unsigned char get_dec( char *str ) {
   unsigned int result;
   int loop,sort;
   
   result = 0;
   for (loop = 0 ; loop < strlen(str) ; loop++) {
      if ((str[loop] >= '0')&&
          (str[loop] <= '9')) {
         result *= 10;
         result += (str[loop]-'0');
      } else {
         printf("ERROR: invalid ID found!\n" );
         return 255;
      }
   }
   if (result > 128) {
      printf( "ERROR: Too big ID found!\n" );
      return 255;
   } else {
      return result;
   }
}

int main() {
   comand_type_t *commands[128],*dummy;
   unsigned char rom[2048];
   int loop,sort,offset;
   
   if (nr_of_known_scpi_commands > 128) {
      printf( "ERROR: Too many SCPI commands defined!\n" );
      return -1;
   }
   
   for (loop = 0 ; loop < 128 ; loop++) {
      commands[loop] = NULL;
   }
   
   for (loop = 0 ; loop < nr_of_known_scpi_commands ; loop++) {
      commands[loop] = (comand_type_t *) malloc( sizeof( comand_type_t ) );
      if (commands[loop] == NULL) {
         printf( "ERROR: Unable to allocate memory!\n" );
         return -1;
      }
      commands[loop]->ID = get_dec(scpi_table[loop*2]);
      if ((strlen(scpi_table[(loop*2)+1]) < 15)&&
          (strlen(scpi_table[(loop*2)+1]) > 0)) {
         commands[loop]->command = (char*) malloc(
               (strlen(scpi_table[(loop*2)+1])+1)*sizeof(char));
         if (commands[loop]->command == NULL) {
            printf( "ERROR: Unable to allocate memory!\n" );
            return -1;
         }
         strcpy(commands[loop]->command , scpi_table[(loop*2)+1]);
         for (sort = 0 ; sort < strlen(commands[loop]->command) ; sort++) {
            if ((commands[loop]->command[sort] >= 'a')&&
                (commands[loop]->command[sort] <= 'z')) {
               commands[loop]->command[sort] -= ('a'-'A');
            }
         }
      } else {
         printf("ERROR: Too long SCPI command \"%s\" found!" ,
                 scpi_table[(loop*2)+1] );
         return -1;
      }
   }
   
   for (loop = 0 ; loop < nr_of_known_scpi_commands-1 ; loop++) {
      for (sort = loop+1 ; sort < nr_of_known_scpi_commands ; sort++) {
         if (commands[loop]->ID == commands[sort]->ID) {
            printf( "ERROR: Duplicate ID found!\n" );
            return -1;
         }
         if (strcmp(commands[loop]->command,commands[sort]->command) == 0) {
            printf( "ERROR: Duplicate SCPI command found!\n" );
            return -1;
         }
         if (strcmp(commands[loop]->command,commands[sort]->command) > 0) {
            dummy = commands[loop];
            commands[loop] = commands[sort];
            commands[sort] = dummy;
         }
      }
   }
   printf( "      -- Command ID <=> Command\n" );
   for (loop = 0 ; loop < nr_of_known_scpi_commands ; loop++) {
      printf( "      --     0x%02X   <=> \"%s\"\n" , commands[loop]->ID , commands[loop]->command );
      offset=loop*16;
      sort = 0;
      while (sort < strlen(commands[loop]->command)) {
         rom[offset+sort] = commands[loop]->command[sort];
         sort++;
      }
      rom[offset+sort] = 0;
      sort++;
      rom[offset+sort] = commands[loop]->ID;
      sort++;
      while (sort < 16) {
         rom[offset+sort] = 0xFF;
         sort++;
      }
   }
   for (loop = nr_of_known_scpi_commands ; loop < 128 ; loop++) {
      offset = loop*16;
      for (sort = 0 ; sort < 16 ; sort++)
         rom[offset+sort] = 0xFE;
   }
   for (loop = 0 ; loop < 64 ; loop++) {
      if (loop == 0) {
         printf( "      GENERIC MAP ( INIT_00 => X\"" );
      } else {
         printf( "                    INIT_%02X => X\"" , loop );
      }
      for (sort = 31 ; sort > -1 ; sort--) {
         printf("%02X",rom[loop*32+sort] );
      }
      if (loop != 63) {
         printf( "\",\n" );
      } else {
         printf( "\")\n" );
      }
   }
   return 0;
}
