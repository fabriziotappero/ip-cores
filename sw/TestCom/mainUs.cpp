//---------------------------------------------------------------------------
#include <stdio.h>
#include <string.h>
#include <conio.h>
#include <windows.h>

#include "main.h"
#include "Thread.h"

#pragma hdrstop
//---------------------------------------------------------------------------

#pragma argsused

#define BUFLENGTH 500	// Size of the cyclic buffer for emit/receive checking

Thread_Com *Thread_Com1;
char Buf[BUFLENGTH];
int BufTop, BufBot;
bool CompErr;

int main(int argc, char* argv[])
{
	int n, i;
   int ComN;
   unsigned int BaudRate;
   long unsigned ncEmit;
   char str[80];
   HANDLE hConsole;
   COORD c1;
   DWORD dw1;

   hConsole =  GetStdHandle (STD_OUTPUT_HANDLE);

   if (argc > 3)
   {
   	printf ("Too many arguments on the command line.\n");
      return 0;
	}
   if (argc == 0)printf ("Err 0.\n");
   if (argc == 1)
   {
      printf("RS232 serial line tester\n");
      printf("By Philippe Carton the 8/01/2002 (philippe.carton2@libertysurf.fr)\n");
      printf("This program give a way to test the reliability of a closed-loop serial line\n");
      printf("It emit a continuous random byte stream, and check that it receive exacly what\n");
      printf("has been sent. The serial line, or the connected equipment must work in CLOSED-\n");
      printf("LOOP, that is to say TxD and RxD tied.\n");
      printf("Syntax:\n");
      printf("TESTCOM port baudrate\n");
      printf("\tport = com port number\n");
      printf("\tFile2 = baudrate (9600, 19200 ...)\n");
      return 0;
   }
   // Parse for the com port
	n = sscanf (argv[1], "%d", &ComN);
   if (n == 0 || ComN < 1 || ComN > 4)
   {
   	printf ("invalid com port (1 to 4).\n");
      return 0;
	}
   // Parse for the baudrate
   BaudRate = 9600; 	// default
   if (argc == 3)
   {
		n = sscanf (argv[2], "%d", &BaudRate);
		if (n == 0 || BaudRate < 110 || BaudRate > 921600)
	   {
	   	printf ("Invalid baudrate. (110 to 921600)\n");
	      return 0;
		}
   }

   // Launch process
   printf ("Com=%d  Baudrate=%d\n", ComN, BaudRate);
   printf ("--Test running, Ctrl-C to stop--\n");

   // Open the thread communication thread
   Thread_Com1 = new Thread_Com(true, ComN, BaudRate);
   if (Thread_Com1->dwLastErr)
   {
   	printf ("%s\n", Thread_Com1->sLastErr);
      exit (0);
   }

   // Ctrl-C Handler
   SetConsoleCtrlHandler (CtrlHandler, true);

   // Continuous random byte emit
   BufTop = 0;
   BufBot = 0;
   CompErr = false;
   ncEmit = 0;

	while (1)
   {
   	// Test that cycling buf don't overflow
      if (BufTop + 1 == BufBot || (BufBot == 0 && BufTop == sizeof(Buf)-1))
      {
      	// Buf is full
         printf ("Test Buffer is full.\n");
         if (ncEmit == BUFLENGTH-1)
         	printf ("No byte has been received. The closed-loop fail.\n");
         else
  	         printf ("This mean that the OS is too slow compared to the specified baudrate.\n");
			break;
      }
      Buf[BufTop] = random(256);
		Thread_Com1->WriteToComPort(Buf[BufTop]);
	   if (Thread_Com1->dwLastErr)
	   {
	   	printf ("%s\n", Thread_Com1->sLastErr);
	      break;
	   }
		BufTop++; if (BufTop >= sizeof(Buf))BufTop = 0;

      // Display the char count every 100 loop
      ncEmit ++;
      if (BufTop == 0)
      {
         sprintf (str, "car emis = %lu", ncEmit);
         c1.X = 4; c1.Y = wherey()-1;
			WriteConsoleOutputCharacter(hConsole, str, strlen(str), c1, &dw1);
      }
      // In case of error detected between Transmit-Receive
      if (CompErr == true)
      {
        	printf ("Mismatch observed between emit/received char.\n");
         printf ("Last emitted char = \n\t");
         for (i = 0; i < 10; i++)
         {
         	printf ("%x ", (unsigned char)Buf[BufTop]);
            BufTop --; if (BufTop < 0)BufTop = sizeof(Buf);
         }
         printf ("\n");
      	break;
      }
   }

   // Close the communication thread
   Thread_Com1->Terminate();
   Thread_Com1->WaitFor();
   delete Thread_Com1;

   return 0;
}

BOOL WINAPI CtrlHandler(DWORD dwCtrlType)
{
  	printf ("Serial line succesfully tested.\n");

   return 0;
}

void ReceiveCallBack(char *c)
{
	if (*c != Buf[BufBot])
   {
   	CompErr = true;
   }
	BufBot++; if (BufBot >= sizeof(Buf))BufBot = 0;
}


