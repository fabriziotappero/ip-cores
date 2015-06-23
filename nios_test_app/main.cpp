
#include <stdio.h>
#include <unistd.h>

#include "hardware/usb_sync/usb_sync.h"



int main(void)
{
	printf("Started...\n");


	// Setup tx buffer with our sequence
   	uint8_t buffer[1024];
   	
   	for (uint32_t i = 0; i < sizeof(buffer); i++)
   		buffer[i] = (uint8_t) (i & 0xFF);

   		
	int errors = 0;
	unsigned char sequence = 0;
	unsigned char tx_byte = 0;
	bool initialised = false;
    
	while (true)
	{
		// Check the driver's RX FIFO
		if (usb_kbhit())
		{
			uint8_t c = usb_getch();
	    	
			sequence++;

			if (!initialised)
			{
				sequence = c;
				initialised = true;
			}

			if (c != sequence)
			{
				errors++;
				printf("Sequence errors: %d\n", errors);
				sequence = c;
			}
		}
		    
		// Fill the driver's TX FIFO
		while (USB_TX_FREE >= (uint32_t) sizeof(buffer))
			for (uint32_t i = 0; i < (uint32_t) sizeof(buffer); i++)
				USB_DATA_WR(tx_byte++);
	}

	return 0;
}
