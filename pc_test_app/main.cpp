
#include <stdio.h>
#include <time.h>
#include <windows.h>

#include "ftd2xx.h"
#include "types.h"


#pragma comment(lib, "ftd2xx.lib")


int main(void)
{
	FT_HANDLE ftHandle;

	FT_STATUS ftStatus = FT_Open (0, &ftHandle);

	if (!FT_SUCCESS(ftStatus))
	{
		printf("Unable to open USB device\n");
		return 0;
	}

	FT_Purge(ftHandle, FT_PURGE_RX | FT_PURGE_TX);
	FT_SetBitMode(ftHandle, 0, 0x40); // Single Channel Synchronous 245 FIFO Mode
	FT_SetUSBParameters(ftHandle, 32768, 4096);
	FT_SetResetPipeRetryCount(ftHandle, 100);
	FT_SetFlowControl(ftHandle, FT_FLOW_RTS_CTS, 0, 0);	//Required to avoid data loss, see appnote "an_130_ft2232h_used_in_ft245 synchronous fifo mode.pdf"
	FT_SetTimeouts(ftHandle, 500, 0);

	unsigned long start = GetTickCount();
	unsigned long last = start;
	unsigned char buffer[4096];
	int filesize = 0;
	int errors = 0;
	unsigned char sequence = 0;
	bool initialised = false;
    
	
	while(true)
	{
		DWORD BytesRead = 0;

		if (FT_Read (ftHandle, buffer, sizeof(buffer), &BytesRead) != FT_OK)
			break;

		for (uint32_t i = 0; i < BytesRead; i++)
		{
			uint8_t c = buffer[i];
	    	
		    	sequence++;

      	      if (!initialised)
            	{
				sequence = c;
				initialised = true;
			}

			if (c != sequence)
			{
				errors++;
				sequence = c;
			}
		}
		    
		filesize += BytesRead;
        
		unsigned long current = GetTickCount();

		if (current - last >= 500)
		{
			double kbsec = (double) ((double) filesize / 1000) / ((double) (current - start) / 1000);
			int timepassed = (current - start) / 1000;

			printf("Sec:%d Errors: %d Size:%dKb Rate:%.1fKb/s       \r", timepassed, errors, filesize/1000, kbsec);
			fflush(stdout);

			last = current;
		}
	}

	FT_SetBitMode(ftHandle, 0, 0);

	FT_Close(ftHandle);

	return 0;
}
