/*!
   ZTEX Firmware Kit for EZ-USB FX2 Microcontrollers
   Copyright (C) 2009-2014 ZTEX GmbH.
   http://www.ztex.de

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License version 3 as
   published by the Free Software Foundation.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, see http://www.gnu.org/licenses/.
!*/

/*
    Support for standard SPI flash. 
*/    

#ifeq[SPI_PORT][A]
#elifeq[SPI_PORT][B]
#elifeq[SPI_PORT][C]
#elifneq[SPI_PORT][D]
#error[Macro `SPI_PORT' is not defined correctly. Valid values are: `A', `B', `C' and `D'.]
#endif

#ifndef[ZTEX_FLASH1_H]
#define[ZTEX_FLASH1_H]

#define[@CAPABILITY_FLASH;]

#ifndef[SPI_PORT]
#error[SPI_PORT not defined]
#endif

#ifndef[SPI_BIT_CS]
#error[SPI_BIT_CS not defined]
#endif

#ifndef[SPI_BIT_DI]
#error[SPI_BIT_DI not defined]
#endif

#ifndef[SPI_BIT_DO]
#error[SPI_BIT_DO not defined]
#endif

#ifndef[SPI_BIT_CLK]
#error[SPI_BIT_CLK not defined]
#endif

#ifndef[SPI_OPORT]
#define[SPI_OPORT][SPI_PORT]
#endif

#define[SPI_IO@][IOSPI_PORT]
#define[SPI_OIO@][IOSPI_OPORT]

#define[SPI_CS][SPI_IO@SPI_BIT_CS]
#define[SPI_CLK][SPI_IO@SPI_BIT_CLK]
#define[SPI_DI][SPI_IO@SPI_BIT_DI]
#define[SPI_DO][SPI_OIO@SPI_BIT_DO]

// may be redefined if the first sectors are reserved (e.g. for a FPGA bitstream)
#define[FLASH_FIRST_FREE_SECTOR][0]

__xdata BYTE flash_enabled;	// 0	1: enabled, 0:disabled
__xdata WORD flash_sector_size; // 1    sector size <sector size> = MSB==0 : flash_sector_size and 0x7fff ? 1<<(flash_sector_size and 0x7fff)
__xdata DWORD flash_sectors;	// 3	number of sectors
__xdata BYTE flash_ec; 	        // 7	error code

__xdata BYTE spi_vendor;	// 0
__xdata BYTE spi_device;	// 1
__xdata BYTE spi_memtype;	// 2
__xdata BYTE spi_erase_cmd;	// 3
__xdata BYTE spi_last_cmd;	// 4
__xdata BYTE spi_buffer[4];	// 5

__xdata WORD spi_write_addr_hi;
__xdata BYTE spi_write_addr_lo;
__xdata BYTE spi_need_pp;
__xdata WORD spi_write_sector;
__xdata BYTE ep0_read_mode;
__xdata BYTE ep0_write_mode;

#define[FLASH_EC_TIMEOUT][2]
#define[FLASH_EC_BUSY][3]
#define[FLASH_EC_PENDING][4]
#define[FLASH_EC_NOTSUPPORTED][7]

/* *********************************************************************
   ***** spi_clocks ****************************************************
   ********************************************************************* */
// perform c (256 if c=0) clocks
void spi_clocks (BYTE c) {
	c;					// this avoids stupid warnings
__asm
	mov 	r2,dpl
010014$:
        setb	_SPI_CLK	// 1
        nop			// 1
        nop			// 1
        nop			// 1
        clr	_SPI_CLK	// 1
	djnz 	r2,010014$	// 3
__endasm;    
}


/* *********************************************************************
   ***** flash_read_byte ***********************************************
   ********************************************************************* */
// read a single byte from the flash
BYTE flash_read_byte() { // uses r2,r3,r4
__asm  
	// 8*7 + 6 = 62 clocks 
	mov	c,_SPI_DO	// 7
        setb	_SPI_CLK
        rlc 	a		
        clr	_SPI_CLK

        mov	c,_SPI_DO	// 6
        setb 	_SPI_CLK
        rlc 	a		
        clr 	_SPI_CLK

        mov	c,_SPI_DO	// 5
        setb 	_SPI_CLK
        rlc 	a		
        clr 	_SPI_CLK

        mov	c,_SPI_DO	// 4
        setb 	_SPI_CLK
        rlc 	a		
        clr 	_SPI_CLK

        mov	c,_SPI_DO	// 3
        setb 	_SPI_CLK
        rlc 	a		
        clr 	_SPI_CLK

        mov	c,_SPI_DO	// 2
        setb 	_SPI_CLK
        rlc 	a		
        clr 	_SPI_CLK

        mov	c,_SPI_DO	// 1
        setb 	_SPI_CLK
        rlc 	a		
        clr 	_SPI_CLK

        mov	c,_SPI_DO	// 0
        setb 	_SPI_CLK
        rlc 	a		
        clr 	_SPI_CLK
        mov	dpl,a
        ret
__endasm;
	return 0;		// never ever called (just to avoid warnings)
} 

/* *********************************************************************
   ***** flash_read ****************************************************
   ********************************************************************* */
// read len (256 if len=0) bytes from the flash to the buffer
void flash_read(__xdata BYTE *buf, BYTE len) {
	*buf;					// this avoids stupid warnings
	len;					// this too
__asm						// *buf is in dptr, len is in _flash_read_PARM_2
	mov	r2,_flash_read_PARM_2
010012$:
	// 2 + len*(8*7 + 9) + 4 = 6 + len*65 clocks
	mov	c,_SPI_DO	// 7
        setb	_SPI_CLK
        rlc 	a		
        clr	_SPI_CLK

        mov	c,_SPI_DO	// 6
        setb 	_SPI_CLK
        rlc 	a		
        clr 	_SPI_CLK

        mov	c,_SPI_DO	// 5
        setb 	_SPI_CLK
        rlc 	a		
        clr 	_SPI_CLK

        mov	c,_SPI_DO	// 4
        setb 	_SPI_CLK
        rlc 	a		
        clr 	_SPI_CLK

        mov	c,_SPI_DO	// 3
        setb 	_SPI_CLK
        rlc 	a		
        clr 	_SPI_CLK

        mov	c,_SPI_DO	// 2
        setb 	_SPI_CLK
        rlc 	a		
        clr 	_SPI_CLK

        mov	c,_SPI_DO	// 1
        setb 	_SPI_CLK
        rlc 	a		
        clr 	_SPI_CLK

        mov	c,_SPI_DO	// 0
        setb 	_SPI_CLK
        rlc 	a		
        clr 	_SPI_CLK

	movx	@dptr,a
	inc	dptr
	djnz 	r2,010012$
__endasm;
} 

/* *********************************************************************
   ***** spi_write_byte ************************************************
   ********************************************************************* */
// send one bytes from buffer buf to the card
void spi_write_byte (BYTE b) {	// b is in dpl
	b;				// this avoids stupid warnings
__asm
        // 3 + 8*7 + 4 = 63 clocks 
	mov 	a,dpl
	rlc	a		// 7

	mov	_SPI_DI,c
        setb	_SPI_CLK
	rlc	a		// 6
        clr	_SPI_CLK

	mov	_SPI_DI,c
        setb	_SPI_CLK
	rlc	a		// 5
        clr	_SPI_CLK

	mov	_SPI_DI,c
        setb	_SPI_CLK
	rlc	a		// 4
        clr	_SPI_CLK

	mov	_SPI_DI,c
        setb	_SPI_CLK
	rlc	a		// 3
        clr	_SPI_CLK

	mov	_SPI_DI,c
        setb	_SPI_CLK
	rlc	a		// 2
        clr	_SPI_CLK

	mov	_SPI_DI,c
        setb	_SPI_CLK
	rlc	a		// 1
        clr	_SPI_CLK

	mov	_SPI_DI,c
        setb	_SPI_CLK
	rlc	a		// 0
        clr	_SPI_CLK

	mov	_SPI_DI,c
        setb	_SPI_CLK
	nop
        clr	_SPI_CLK
__endasm;
}  

/* *********************************************************************
   ***** spi_write *****************************************************
   ********************************************************************* */
// write len (256 if len=0) bytes from the buffer to the flash
void spi_write(__xdata BYTE *buf, BYTE len) {
	*buf;					// this avoids stupid warnings
	len;					// this too
__asm						// *buf is in dptr, len is in _flash_read_PARM_2
	mov	r2,_flash_read_PARM_2
010013$:
	// 2 + len*(3 + 8*7 - 1 + 7 ) + 4 = 6 + len*65 clocks
	movx	a,@dptr
	rlc	a		// 7

	mov	_SPI_DI,c
        setb	_SPI_CLK
	rlc	a		// 6
        clr	_SPI_CLK

	mov	_SPI_DI,c
        setb	_SPI_CLK
	rlc	a		// 5
        clr	_SPI_CLK

	mov	_SPI_DI,c
        setb	_SPI_CLK
	rlc	a		// 4
        clr	_SPI_CLK

	mov	_SPI_DI,c
        setb	_SPI_CLK
	rlc	a		// 3
        clr	_SPI_CLK

	mov	_SPI_DI,c
        setb	_SPI_CLK
	rlc	a		// 2
        clr	_SPI_CLK

	mov	_SPI_DI,c
        setb	_SPI_CLK
	rlc	a		// 1
        clr	_SPI_CLK

	mov	_SPI_DI,c
        setb	_SPI_CLK
	rlc	a		// 0
        clr	_SPI_CLK

	mov	_SPI_DI,c
        setb	_SPI_CLK
	inc	dptr
        clr	_SPI_CLK 

	djnz 	r2,010013$ 
__endasm;
} 

/* *********************************************************************
   ***** spi_select ****************************************************
   ********************************************************************* */
/* 
   select the flash (CS)
*/
void spi_select() {
    SPI_CS = 1;					// CS = 1;
    spi_clocks(8);				// 8 dummy clocks to finish a previous command
    SPI_CS = 0;
}

/* *********************************************************************
   ***** spi_deselect **************************************************
   ********************************************************************* */
// de-select the flash (CS)
void spi_deselect() {
    SPI_CS = 1;					// CS = 1;
    spi_clocks(8);				// 8 dummy clocks to finish a previous command
}

/* *********************************************************************
   ***** spi_start_cmd *************************************************
   ********************************************************************* */
// send a command   
#define[spi_start_cmd(][);][{			// send a command, argument=0
    spi_last_cmd = $0;
    spi_select();				// select
    spi_write_byte($0);				// CMD 90h
}]    
   
/* *********************************************************************
   ***** spi_wait ******************************************************
   ********************************************************************* */
/* 
   wait if prvious read/write command is still prcessed
   result is flash_ec (FLASH_EC_TIMEOUT or 0)
*/
BYTE spi_wait() {
    WORD i;
    // wait up to 11s
    spi_start_cmd(0x05);
    for (i=0; (flash_read_byte() & bmBIT0) && i<65535; i++ ) { 
	spi_clocks(0);				// 256 dummy clocks
//	uwait(20);
    }
    flash_ec = flash_read_byte() & bmBIT0 ? FLASH_EC_TIMEOUT : 0;
    spi_deselect();
    return flash_ec;
}

/* *********************************************************************
   ***** flash_read_init ***********************************************
   ********************************************************************* */
/*
   Start the initialization sequence for reading sector s.
   returns an error code (FLASH_EC_*). 0 means no error.
*/   
BYTE flash_read_init(WORD s) {
    if ( (SPI_CS) == 0 ) {
	flash_ec = FLASH_EC_PENDING;
	return FLASH_EC_PENDING;		// we interrupted a pending Flash operation
    }  
    OESPI_OPORT &= ~bmBITSPI_BIT_DO;
    OESPI_PORT |= bmBITSPI_BIT_CS | bmBITSPI_BIT_DI | bmBITSPI_BIT_CLK;
    if ( spi_wait() ) {
	return flash_ec;
    }

    s = s << ((BYTE)flash_sector_size - 8);     
    spi_start_cmd(0x0b);			// read command
    spi_write_byte(s >> 8);			// 24 byte address
    spi_write_byte(s & 255);
    spi_write_byte(0);
    spi_clocks(8);				// 8 dummy clocks
    return 0;
} 

/* *********************************************************************
   ***** flash_read_next ***********************************************
   ********************************************************************* */
/*
   dummy function for compatibilty
*/   
BYTE flash_read_next() {
    return 0;
} 


/* *********************************************************************
   ***** flash_read_finish *********************************************
   ********************************************************************* */
/*
    Runs the finalization sequence for the read operation.
*/   
void flash_read_finish(WORD n) {
   n;					// avoids warnings
   spi_deselect();
}


/* *********************************************************************
   ***** spi_pp ********************************************************
   ********************************************************************* */
BYTE spi_pp () {	
    spi_deselect();				// finish previous write cmd
    
    spi_need_pp = 0;

    if ( spi_wait() ) {
	return flash_ec;
    }
    spi_start_cmd(0x06);			// write enable command
    spi_deselect();
    
    spi_start_cmd(0x02);			// page write
    spi_write_byte(spi_write_addr_hi >> 8);	// 24 byte address
    spi_write_byte(spi_write_addr_hi & 255);
    spi_write_byte(0);
    return 0;
}
   

/* *********************************************************************
   ***** flash_write_byte **********************************************
   ********************************************************************* */
BYTE flash_write_byte (BYTE b) {
    if ( spi_need_pp && spi_pp() ) return flash_ec;
    spi_write_byte(b);
    spi_write_addr_lo++;
    if ( spi_write_addr_lo == 0 ) {
	spi_write_addr_hi++;
	spi_deselect();				// finish write cmd
	spi_need_pp = 1;
    }
    return 0;
}


/* *********************************************************************
   ***** flash_write ***************************************************
   ********************************************************************* */
// write len (256 if len=0) bytes from the buffer to the flash
BYTE flash_write(__xdata BYTE *buf, BYTE len) {
    BYTE b;
    if ( spi_need_pp && spi_pp() ) return flash_ec;

    if ( spi_write_addr_lo == 0 ) {
	spi_write(buf,len);
    }
    else {
	b = (~spi_write_addr_lo) + 1;
	if ( len==0 || len>b ) {
	    spi_write(buf,b);
	    len-=b;
	    spi_write_addr_hi++;
	    spi_write_addr_lo=0;
	    buf+=b;
	    if ( spi_pp() ) return flash_ec;
	}
	spi_write(buf,len);
    }

    spi_write_addr_lo+=len;
    
    if ( spi_write_addr_lo == 0 ) {
	spi_write_addr_hi++;
	spi_deselect();				// finish write cmd
	spi_need_pp = 1;
    }
	
    return 0;
}
 

/* *********************************************************************
   ***** flash_write_init **********************************************
   ********************************************************************* */
/*
   Start the initialization sequence for writing sector s
   The whole sector will be modified
   returns an error code (FLASH_EC_*). 0 means no error.
*/
BYTE flash_write_init(WORD s) {
    if ( !SPI_CS ) {
	flash_ec = FLASH_EC_PENDING;
	return FLASH_EC_PENDING;		// we interrupted a pending Flash operation
    }  
    OESPI_OPORT &= ~bmBITSPI_BIT_DO;
    OESPI_PORT |= bmBITSPI_BIT_CS | bmBITSPI_BIT_DI | bmBITSPI_BIT_CLK;
    if ( spi_wait() ) {
	return flash_ec;
    }
    spi_write_sector = s;
    s = s << ((BYTE)flash_sector_size - 8);     
    spi_write_addr_hi = s;
    spi_write_addr_lo = 0;

    spi_start_cmd(0x06);			// write enable command
    spi_deselect();
    
    spi_start_cmd(spi_erase_cmd);		// erase command
    spi_write_byte(s >> 8);			// 24 byte address
    spi_write_byte(s & 255);
    spi_write_byte(0);
    spi_deselect();

    spi_need_pp = 1;
    return 0;
}


/* *********************************************************************
   ***** flash_write_finish_sector *************************************
   ********************************************************************* */
/*
   Dummy function for compatibilty.
*/
BYTE flash_write_finish_sector (WORD n) {
    n;
    spi_deselect();
    return 0;
}


/* *********************************************************************
   ***** flash_write_finish ********************************************
   ********************************************************************* */
/*
   Dummy function for compatibilty.
*/
void flash_write_finish () {
    spi_deselect();
}


/* *********************************************************************
   ***** flash_write_next **********************************************
   ********************************************************************* */
/*
   Prepare the next sector for writing, see flash_write_finish1.
*/
BYTE flash_write_next () {
    spi_deselect();
    return flash_write_init(spi_write_sector+1);
}


/* *********************************************************************
   ***** flash_init ****************************************************
   ********************************************************************* */
// init the flash
void flash_init() {
    BYTE i;

    PORTCCFG = 0;
    
    flash_enabled = 1;
    flash_ec = 0;
    flash_sector_size = 0x8010;  // 64 KByte
    spi_erase_cmd = 0xd8;
    
    OESPI_OPORT &= ~bmBITSPI_BIT_DO;
    OESPI_PORT |= bmBITSPI_BIT_CS | bmBITSPI_BIT_DI | bmBITSPI_BIT_CLK;
    SPI_CS = 1;
    spi_clocks(0);				// 256 clocks

    spi_start_cmd(0x90);			// CMD 90h, not supported by all chips
    spi_clocks(24);				// ADDR=0
    spi_device = flash_read_byte();			
    spi_deselect();				// deselect

    spi_start_cmd(0x9F);			// CMD 9Fh
    flash_read(spi_buffer,3);			// read data
    spi_deselect();				// deselect
    if ( spi_buffer[2]<16 || spi_buffer[2]>24 ) {
	goto  disable;
    }
    spi_vendor = spi_buffer[0];
    spi_memtype = spi_buffer[1];

#ifeq[USE_4KSECTORS_ENABLED][1]
    if ( ( spi_vendor==1 && spi_memtype == 0x40 ) ||
	 ( spi_vendor==0x20 && spi_memtype == 0xba )
       ) {
	// support of uniform 4 kbyte (logical) sectors
        flash_sector_size = 0x800C;  // 4 KByte
	spi_erase_cmd = 0x20;
	i=spi_buffer[2]-12;
    }
    else {
	// support of uniform 64 kbyte (logical) sectors
	i=spi_buffer[2]-16;
    }
#else    
    i=spi_buffer[2]-16;
#endif    
    flash_sectors = 1 << i;
    
    return;

disable:
    flash_enabled = 0;
    flash_ec = FLASH_EC_NOTSUPPORTED;
    OESPI_PORT &= ~( bmBITSPI_BIT_CS | bmBITSPI_BIT_DI | bmBITSPI_BIT_CLK );
}


/* *********************************************************************
   ***** EP0 vendor request 0x40 ***************************************
   ********************************************************************* */
// send flash information structure (card size, error status,  ...) to the host
ADD_EP0_VENDOR_REQUEST((0x40,,
    if ( flash_ec == 0 && SPI_CS == 0 ) {
	flash_ec = FLASH_EC_PENDING;
    }
    MEM_COPY1(flash_enabled,EP0BUF,8);
    EP0BCH = 0;
    EP0BCL = 8;
,,
));;

/* *********************************************************************
   ***** EP0 vendor request 0x41 ***************************************
   ********************************************************************* */
/* read modes (ep0_read_mode)
	0: start read
	1: continue read
	2: finish read
*/
void spi_read_ep0 () { 
    flash_read(EP0BUF, ep0_payload_transfer);
    if ( ep0_read_mode==2 && ep0_payload_remaining==0 ) {
	spi_deselect();
    } 
}

ADD_EP0_VENDOR_REQUEST((0x41,,			// read data
    ep0_read_mode = SETUPDAT[5];
    if ( (ep0_read_mode==0) && flash_read_init((SETUPDAT[3] << 8) | SETUPDAT[2]) ) {
	EP0_STALL;
    }  
    spi_read_ep0();  
    EP0BCH = 0;
    EP0BCL = ep0_payload_transfer; 
,,
    if ( ep0_payload_transfer != 0 ) {
	flash_ec = 0;
        spi_read_ep0(); 
    } 
    EP0BCH = 0;
    EP0BCL = ep0_payload_transfer;
));;

/* *********************************************************************
   ***** EP0 vendor command 0x42 ***************************************
   ********************************************************************* */
void spi_send_ep0 () { 
    flash_write(EP0BUF, ep0_payload_transfer);
    if ( ep0_write_mode==2 && ep0_payload_remaining==0 ) {
	spi_deselect();
    } 
}

ADD_EP0_VENDOR_COMMAND((0x42,,			// write integer number of sectors
    ep0_write_mode = SETUPDAT[5];
    if ( (ep0_write_mode == 0) && flash_write_init((SETUPDAT[3] << 8) | SETUPDAT[2]) ) {
	EP0_STALL;
    }
,,
    if ( ep0_payload_transfer != 0 ) {
	flash_ec = 0;
	spi_send_ep0();
        if ( flash_ec != 0 ) {
    	    spi_deselect();
	    EP0_STALL;
	} 
    } 
));;

/* *********************************************************************
   ***** EP0 vendor request 0x43 ***************************************
   ********************************************************************* */
// send detailed SPI status plus debug information
ADD_EP0_VENDOR_REQUEST((0x43,,
    MEM_COPY1(flash_ec,EP0BUF,10);	
    EP0BCH = 0;
    EP0BCL = 10;
,,
));;

#endif  /*ZTEX_FLASH1_H*/