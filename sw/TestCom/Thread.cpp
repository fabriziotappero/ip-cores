//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

#include <stdlib.h>
#include "Thread.h"

#pragma package(smart_init)

//static AnsiString asBuf = "";
static char sBuf[205];
static stErr stErr1;
HANDLE hComm;

//---------------------------------------------------------------------------
//   Important: Methods and properties of objects in VCL can only be
//   used in a method called using Synchronize, for example:
//
//      Synchronize(UpdateCaption);
//
//   where UpdateCaption could look like:
//
//      void __fastcall Thread_Com::UpdateCaption()
//      {
//        Form1->Caption = "Updated in a thread";
//      }
//---------------------------------------------------------------------------
__fastcall Thread_Com::Thread_Com(bool CreateSuspended,
   int NumPortD, int BaudRateD) : TThread(CreateSuspended)
{
   NumPort = NumPortD;
   BaudRate = BaudRateD;
   Priority = tpHigher;
}

//---------------------------------------------------------------------------
void __fastcall Thread_Com::AfterConstruction()
{
   DCB dcb;
   BOOL fSuccess;
   char str[5] = "COM0\x0";

   str[3] = NumPort + 0x30;
   hComm = CreateFile(str, GENERIC_READ | GENERIC_WRITE, 0, 0,
                      OPEN_EXISTING, FILE_FLAG_OVERLAPPED, NULL);

   if (hComm == INVALID_HANDLE_VALUE)
   {
      sLastErr = "Impossible d'ouvrir COM"+AnsiString(NumPort);
   	dwLastErr = CANT_OPEN_COM;
      return;
   }
   fSuccess = GetCommState(hComm, &dcb);
   dcb.BaudRate = BaudRate;
   dcb.ByteSize = 8;
   dcb.Parity = NOPARITY;
   dcb.StopBits = ONESTOPBIT;
   fSuccess |= SetCommState(hComm, &dcb);

   if (!fSuccess)
   {
      sLastErr = "Impossible de configurer COM"+AnsiString(NumPort);
   	dwLastErr = CANT_CONFIG_COM;
      CloseHandle(hComm);
      return;
   }

   Resume();
}


//---------------------------------------------------------------------------
void __fastcall Thread_Com::Execute()
{
   LPSTR lpBuf;
   DWORD dwNumByteRead;
   DWORD dwRes;
   BOOL fWaitingOnRead = false;
   OVERLAPPED osReader = {0};
   lpBuf = (char *)malloc(2);

// Interdire l'execution si le port serie n'a pu être ouvert
   if (hComm == INVALID_HANDLE_VALUE)return;

// Definition d'un évènement
   osReader.hEvent = CreateEvent(NULL, true, false, NULL);
   if (osReader.hEvent == NULL)   // Error creating overlapped event; abort.
   {
      sLastErr = "Erreur lors de la creation d'evènement";
   	dwLastErr = CREATE_EV_ERROR;
   }

   while (Terminated == false)
   {
	// Procedure pour lire sur le port hComm
      if (!fWaitingOnRead)
      {
         // Issue the operation
         if (!ReadFile(hComm, lpBuf, 1, &dwNumByteRead, &osReader))
         {
            if (GetLastError() != ERROR_IO_PENDING)   // Read not delayed ?
            {  // Error in communications ; report it
      			sLastErr = "Erreur de lecture sur COM"+AnsiString(NumPort);
			   	dwLastErr = ERR_READ_COM;
            }
            else fWaitingOnRead = true;
         }
         else // read completed immediately
            HandleASuccessfulRead(*lpBuf);
      }

      if (fWaitingOnRead)
      {
         dwRes = WaitForSingleObject(osReader.hEvent, READ_TIMEOUT);
         switch(dwRes)
         {
            // Read completed
            case WAIT_OBJECT_0:
               if (!GetOverlappedResult(hComm, &osReader, &dwNumByteRead, FALSE))
               {   // Error in communications ; report it
   	   			sLastErr = "Erreur de fin de lecture sur COM"+AnsiString(NumPort);
				   	dwLastErr = ERR_READOVER_COM;
               }
               else // Read completed successfully.
               {
               	dwLastErr = 0;
                  HandleASuccessfulRead(*lpBuf);
                  // Reset flag so that another operation can be issued
                  fWaitingOnRead = false;
               }
               break;
            case WAIT_TIMEOUT:
               // possible background work
               break;
            default:
               // Error in the WaitforSingleObject; abort.
  	   			sLastErr = "Erreur d'attente de lecture sur COM"+AnsiString(NumPort);
			   	dwLastErr = ERR_READWAIT_COM;
               break;
         }
      }
   }
   free(lpBuf);
   CloseHandle(osReader.hEvent);
   CloseHandle(hComm);
}
//---------------------------------------------------------------------------
BOOL __fastcall Thread_Com::WriteToComPort(AnsiString ASbuf)
{
   OVERLAPPED osWrite = {0};
   DWORD dwToWrite;
   DWORD dwNumByteWritten;
   BOOL fRes;

// Si le port serie n'a pu être ouvert, Sortir
   if (hComm == INVALID_HANDLE_VALUE)return false;

   dwToWrite = ASbuf.Length();
   char *lpBuf = ASbuf.c_str();

	// Create this write operation's OVERLAPPED structure's hEvent.
   osWrite.hEvent = CreateEvent(NULL, true, false, NULL);
   if (osWrite.hEvent == NULL)
      // Error creating overlapped event handle
      return false;

   // Issue write.
   if (!WriteFile(hComm, lpBuf, dwToWrite, &dwNumByteWritten, &osWrite))
   {
      if (GetLastError() != ERROR_IO_PENDING)
      {
         // WriteFile failed, but isn't delayed. Report error and abort.
  			sLastErr = "Erreur d'écriture sur COM"+AnsiString(NumPort);
	   	dwLastErr = ERR_WRITE_COM;
         fRes = false;
      }
      else
      {
         // Write is pending.
         if (!GetOverlappedResult(hComm, &osWrite, &dwNumByteWritten, true))
            fRes = false;
         else
         // Write operation completed successfully.
            fRes = true;
      }
   }
   else //WriteFile completed immediately.
   dwLastErr = 0;
   fRes = true;

   CloseHandle(osWrite.hEvent);
   return fRes;
}


//---------------------------------------------------------------------------
extern void ReceiveCallBack(char *c);

void __fastcall Thread_Com::HandleASuccessfulRead(char c)
{
	ReceiveCallBack(&c);
}
