
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include <wtypes.h>

void download(const char * filename, HANDLE comm)
{
char buffer[1000];

int total = 0;

FILE * in = fopen(filename, "r");
   assert(in);

   for (;;)
       {
         const int len = fread(buffer, 1, sizeof(buffer), in);
         if (len == 0)   break;
         total += len;
         printf("%d", total);

         DWORD written = 0;
         WriteFile(comm, buffer, len, &written, 0);
         if (written != len)
            {
              errno = GetLastError();
              perror("WriteFile() failed");
              return;
            }
         printf(" ");
       }

   printf("\nTotal of %d (0x%X) bytes downloaded\n", total, total);
   fclose(in);
}

int main(int argc, char * argv[])
{
const char * filename = "rtos.ihx";
   if (argc > 1)   filename = argv[1];

HANDLE comm = CreateFile("COM1",
		         GENERIC_READ | GENERIC_WRITE,
			 0,
			 0,
			 OPEN_EXISTING,
                         0,
			 0);

   assert(comm);

   if (!SetupComm(comm, 1024, 1024))
      {
        errno = GetLastError();
        perror("SetupComm() failed");
        fprintf(stderr,
                "Can't open COM1: (probably used by another process)\n");
        return 1;
      }

DCB dcb;
   if (!GetCommState(comm, &dcb))
      {
        errno = GetLastError();
        perror("GetCommState() failed");
        return 1;
      }

   dcb.BaudRate        = CBR_115200;
   dcb.ByteSize        = 8;
   dcb.Parity          = NOPARITY;
   dcb.StopBits        = ONESTOPBIT;
   dcb.fOutxCtsFlow    = 0;
   dcb.fOutxDsrFlow    = 0;
   dcb.fDsrSensitivity = 0;
   dcb.fDtrControl     = DTR_CONTROL_DISABLE;
   dcb.fRtsControl     = RTS_CONTROL_DISABLE;
   dcb.fOutX           = 0;
   dcb.fInX            = 0;
   dcb.fNull           = 0;
   dcb.fAbortOnError   = 0;

   if (!SetCommState(comm, &dcb))
      {
        errno = GetLastError();
        perror("SetCommState() failed");
        return 1;
      }

COMMTIMEOUTS touts = { MAXDWORD, 0, 50, 0, 0 };

   if (!SetCommTimeouts(comm, &touts))
      {
        errno = GetLastError();
        perror("SetCommTimeouts() failed");
        return 1;
      }

char buffer[1000];
int std = fileno(stdin);

   for (;;)
       {
         DWORD read    = 0;
         DWORD written = 0;
         ReadFile(comm, buffer, sizeof(buffer), &read, 0);
         char c;

         for (int i = 0; i < read; i++)
             {
               c = buffer[i];
               if      (c == '\r')   putchar(c);
               else if (c == '\n')   putchar(c);
               else if (c < ' ')     printf("^%c", c + 0x40);
               else if (c < 0x7F)    putchar(c);
               else                  printf("\\%2.2X", c & 0xFF);
             }

         if (kbhit())
            {
              c = _getch();
              if (c == 0x1B)   break;
              if (c == 0x0C)
                 {
                   download(filename, comm);
                   continue;
                 }
	      WriteFile(comm, &c, 1, &written, 0);
            }
       }
}
