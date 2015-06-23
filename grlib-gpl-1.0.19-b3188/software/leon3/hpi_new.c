#include <stdio.h>
#include "hpi_defs.h"
#include "hpi_functions.h"

#define SIMULATION

#ifdef SIMULATION

//#define printf //
#define MSIZE 32
#define LOOPS 1
#define START 0x0000
#define DATA  ((USHORT)~(2*i))
//#define DATA  0xC53A//0xffff//

#else

#define MSIZE 512
#define LOOPS 4
#define START 0x0500 //0x0000
#define DATA  ((USHORT)~(2*i))

#endif

int main(int argc,char *argv[], char *envp[])
{

  USHORT const size = (USHORT) MSIZE;
  USHORT tmp, j, i, error=0;
  USHORT start = (USHORT) START;
  USHORT data1[size];

  CTRL_REG * pctrl = (CTRL_REG *) HPI_CTRL;

  pctrl->RESERVED = 0;
  pctrl->AtoCSlow = 1;
  pctrl->CStoCTRLlow = 2;
  pctrl->CTRLlowDvalid = 2;
  pctrl->CTRLlow = 3;
  pctrl->CTRLhighCShigh = 1;
  pctrl->CShighREC = 1;

  tmp = pctrl->reg;

  printf("\n\nHPI_NEW: Test for the LEON HPI bus interface\n\n");
  printf("Writing %d words from 0x%04x to 0x%04x\n", size, start, start+(size-1)*2);
  printf("AHB2HPI CTRL register: 0x%04x\n\n", tmp);
  printf("Start reading and writing data\n\n");

  for (j=0; j<LOOPS; j++) {
    for(i=0; i<size; i++) {
      lcd_hpi_write_word(start+i*2, DATA);
      tmp = lcd_hpi_read_word(start+i*2);
      if (tmp != DATA) {
        printf("R/W error #%d:\n", ++error);
        printf("Cycle #%d:\n", i);
        printf("Expected:\t0x%x\n", DATA);
        printf("Read:\t\t0x%x\n", tmp);
        printf("Address:\t0x%x\n\n", start+i*2);
      }
    }
  }

  /*
#ifdef SIMULATION
#undef SIMULATION
#endif
  */

  if(error == 0)
    printf("**** FINISHED without errors ****\n");
  else
    printf("**** ERRORS: %d ****\n", error);

  return error;
}

