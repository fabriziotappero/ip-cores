/*----------------------------------------------------------------------*/
/* FatFs sample project for generic microcontrollers (C)ChaN, 2012      */
/*----------------------------------------------------------------------*/

#include <stdio.h>
#include "../common/fatfs/ff.h"
#include "../common/libsoc/src/hw.h"


FATFS Fatfs;		/* File system object */
FIL Fil;			/* File object */
BYTE Buff[128];		/* File read buffer */


void die (		/* Stop with dying message */
	FRESULT rc	/* FatFs return value */
)
{
    switch(rc){
    case FR_NOT_READY:      printf("Disk absent."); break;
    case FR_DISK_ERR:       printf("Low level disk i/o error."); break;
    case FR_NO_FILESYSTEM:  printf("No valid filesystem in drive."); break;
    case FR_NO_FILE:        printf("File not found."); break;
    default:                printf("Failed with rc=%u.", rc); break;
    }
    printf("\n");
	for (;;) ;
}


/*-----------------------------------------------------------------------*/
/* Program Main                                                          */
/*-----------------------------------------------------------------------*/

int main (void)
{
	FRESULT rc;				/* Result code */
	UINT br, i;
    BYTE *target = (BYTE *)0x00000000;
    UINT wr_index = 0;
    void (*target_fn)(void) = (void *)0x00000000;

    
    printf("ION SD loader -- " __DATE__ "\n\n");
    

	f_mount(0, &Fatfs);		/* Register volume work area (never fails) */

	rc = f_open(&Fil, "CODE.BIN", FA_READ);
	if (rc) die(rc);

    printf("Loading file '/code.bin' onto RAM at address 0x00000000...\n");
    
	for (;;) {
		rc = f_read(&Fil, Buff, sizeof Buff, &br);	/* Read a chunk of file */
		if (rc || !br) break;			/* Error or end of file */
		for (i = 0; i < br; i++){       /* Type the data */
			target[wr_index] = Buff[i];
            wr_index++;
        }
        if(wr_index > 256*1024) break;
	}
	if (rc) die(rc);

        
	rc = f_close(&Fil);
	if (rc) die(rc);
    

    printf("Done. Read %u bytes.\n", wr_index);
    printf("Transferring control to address 0x00000000\n\n");

    target_fn();
    
	for (;;) ;
}



/*---------------------------------------------------------*/
/* User Provided Timer Function for FatFs module           */
/*---------------------------------------------------------*/

DWORD get_fattime (void)
{
	return	  ((DWORD)(2012 - 1980) << 25)	/* Year = 2012 */
			| ((DWORD)1 << 21)				/* Month = 1 */
			| ((DWORD)1 << 16)				/* Day_m = 1*/
			| ((DWORD)0 << 11)				/* Hour = 0 */
			| ((DWORD)0 << 5)				/* Min = 0 */
			| ((DWORD)0 >> 1);				/* Sec = 0 */
}
