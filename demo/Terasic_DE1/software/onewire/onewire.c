/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>
#include "system.h"

#include "ownet.h"
#include "findtype.h"
#include "temp10.h"
#include "temp28.h"
#include "temp42.h"

// defines
#define MAXDEVICES         20
#define ONEWIRE_P           0

// local functions
void DisplaySerialNum(uchar sn[8]);

int main()
{
  uchar FamilySN[MAXDEVICES][8];
  float current_temp;
  int i = 0;
  int j = 0;
  int NumDevices = 0;
  SMALLINT didRead = 0;

  //use port number for 1-wire
  uchar portnum = ONEWIRE_P;

  //----------------------------------------
  // Introduction header
  printf("\r\nTemperature device demo:\r\n");

  // attempt to acquire the 1-Wire Net
  if (!owAcquire(portnum,NULL))
  {
     printf("Acquire failed\r\n");
#ifdef SOCKIT_OWM_ERR_ENABLE
     while(owHasErrors())
        printf("  - Error %d\r\n", owGetErrorNum());
     return 1;
#endif
  }

  do
  {
     j = 0;
     // Find the device(s)
     NumDevices  = 0;
     NumDevices += FindDevices(portnum, &FamilySN[NumDevices], 0x10, MAXDEVICES-NumDevices);
     NumDevices += FindDevices(portnum, &FamilySN[NumDevices], 0x28, MAXDEVICES-NumDevices);
     NumDevices += FindDevices(portnum, &FamilySN[NumDevices], 0x42, MAXDEVICES-NumDevices);
     if (NumDevices)
     {
        printf("\r\n");
        // read the temperature and print serial number and temperature
        for (i = NumDevices; i; i--)
        {
           printf("(%d) ", j++);
           DisplaySerialNum(FamilySN[i-1]);
           if (FamilySN[i-1][0] == 0x10)
              didRead = ReadTemperature10(portnum, FamilySN[i-1],&current_temp);
           if (FamilySN[i-1][0] == 0x28)
              didRead = ReadTemperature28(portnum, FamilySN[i-1],&current_temp);
           if (FamilySN[i-1][0] == 0x42)
              didRead = ReadTemperature42(portnum, FamilySN[i-1],&current_temp);

           if (didRead)
           {
              printf(" %5.1f Celsius\r\n", current_temp);
           }
           else
           {
              printf("  Convert failed.  Device is");
              if(!owVerify(portnum, FALSE))
                 printf(" not");
              printf(" present.\r\n");
#ifdef SOCKIT_OWM_ERR_ENABLE
              while(owHasErrors())
                 printf("  - Error %d\r\n", owGetErrorNum());
#endif
           }

        }
     }
     else
        printf("No temperature devices found!\r\n");

     printf("\r\nPress any key to continue\r\n");
     i = getchar();
  }
  while (i!='q');

  // release the 1-Wire Net
  owRelease(portnum);

  return 0;
}
// -------------------------------------------------------------------------------
// Read and print the serial number.
//
void DisplaySerialNum(uchar sn[8])
{
   int i;
   for (i = 7; i>=0; i--)
      printf("%02X", (int)sn[i]);
}
