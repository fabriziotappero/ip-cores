//
// MMC Card CRC7 calculator and checker
// www.openchip.org
//
//

#include <iostream>
#include <stdio.h>

using namespace std;

char crc7[8];
char cmd[49]; 

void do_crc7(char c) {
  char c3;
  char c0;
  // last stage and input bit
  c0 = (crc7[6] == c) ? '0' : '1';
  //
  c3 = (crc7[2] == c0) ? '0' : '1';

  // shift register  
  crc7[6] = crc7[5];
  crc7[5] = crc7[4];
  crc7[4] = crc7[3];
  crc7[3] = c3;
  crc7[2] = crc7[1];
  crc7[1] = crc7[0];
  crc7[0] = c0;
} 

/*
CMD17 Argument=0x00000100 CRC7=0x43 OK, checked!
CMD17 Argument=0x00004000 CRC7=0x8F OK, checked!
*/

void calc_crc(int command, unsigned int arg) {
  int i;
  unsigned int mask;
  
  // fill CMD
  mask = 1;
  for (i=0;i<6;i++) {
    if (mask & command) {
      cmd[7-i] = '1';
    } else {
      cmd[7-i]='0';
    }
    mask <<= 1;
  }  
  // fill ARG
  mask = 1;
  for (i=0;i<32;i++) {
    if (mask & arg) {
      cmd[39-i] = '1';
    } else {
      cmd[39-i]='0';
    }
    mask <<= 1;    
  }  
  // clear CRC
  for (i=0;i<7;i++) crc7[i] = '0';  
  
  // calc CRC
  for (i=0;i<40;i++) do_crc7(cmd[i]);  

  // copy CRC
  cmd[40] = crc7[6];
  cmd[41] = crc7[5];
  cmd[42] = crc7[4];
  cmd[43] = crc7[3];
  cmd[44] = crc7[2];
  cmd[45] = crc7[1];
  cmd[46] = crc7[0];
}

int main (int argc, char *argv[])
{ 
    char quit;  
    
    

    int i;

    // clear CRC
    crc7[7] = 0;    
    for (i=0;i<7;i++) crc7[i] = '0';
    // clear CMD, ARG
    cmd[48] = 0;    
    for (i=0;i<48;i++) cmd[i] = '0';
    
    cmd[1] = '1';   // Start bit
    cmd[47] = '1';  // Stop Bit
   
    // check CRC calculation
    calc_crc(0,0);        printf("\n\rTest CMD0 ,0x0     %s", cmd);
    calc_crc(17,0x100);   printf("\n\rTest CMD17,0x0100  %s", cmd);
    calc_crc(17,0x4000);  printf("\n\rTest CMD17,0x04000 %s", cmd);

    printf("\n\rCalc CRCs");   
    calc_crc(0,0);           printf("\n\rTest CMD0 ,0x0        %s", cmd);
    calc_crc(1,0x80FF8000);  printf("\n\rTest CMD1 ,0x80FF8000 %s", cmd);
    calc_crc(2,0);           printf("\n\rTest CMD2 ,0x0        %s", cmd);
    calc_crc(3,0x10000);     printf("\n\rTest CMD3 ,0x10000    %s", cmd);
    calc_crc(7,0x10000);     printf("\n\rTest CMD7 ,0x10000    %s", cmd);
    calc_crc(11,0x0000);     printf("\n\rTest CMD11,0x00000    %s", cmd);
    calc_crc(55,0x0000);     printf("\n\rTest CMD55,0x00000    %s", cmd);
    calc_crc(41,0x80FF8000); printf("\n\rTest ACMD41,0x80FF8000 %s", cmd);

      
      
      
    cin >>quit;
    

    return 0;
}

