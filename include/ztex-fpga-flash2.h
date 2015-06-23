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
    Common functions for FPGA configuration from SPI flash
*/    

__code BYTE fpga_flash_boot_id[] = {'Z','T','E', 'X', 'B', 'S', '\1', '\1'};

/* *********************************************************************
   ***** fpga_first_free_sector ****************************************
   ********************************************************************* */
// First free sector. Returns 0 if no boot sector exeists.   
// Use the macro FLASH_FIRST_FREE_SECTOR instead of this function.
#define[FLASH_FIRST_FREE_SECTOR][fpga_first_free_sector()];
WORD fpga_first_free_sector() {
    BYTE i,j;
#ifdef[@CAPABILITY_MAC_EEPROM;]
    __xdata WORD buf[2];

    if ( config_data_valid ) {
	mac_eeprom_read ( (__xdata BYTE*) buf, 26, 4 );		// read actual and max bitstream size 
	if ( buf[1] != 0 ) {
	    return ( ( ( buf[1] > buf[0] ? buf[1] : buf[0] ) - 1 ) >> ((flash_sector_size & 255) - 12) ) + 1;
	}
    }
#endif    
    flash_read_init( 0 ); 				// prepare reading sector 0
    for ( i=0; i<8 && flash_read_byte()==fpga_flash_boot_id[i]; i++ );
    if ( i != 8 ) {
        flash_read_finish(flash_sector_size - i);	// dummy-read the rest of the sector + finish read opration
        return 0;
    }
    i=flash_read_byte();
    j=flash_read_byte();
    flash_read_finish(flash_sector_size - 10);		// dummy-read the rest of the sector + finish read opration
    
    return (i | (j<<8))+1;
}

/* *********************************************************************
   ***** fpga_configure_from_flash_init ********************************
   ********************************************************************* */
// this function is called by init_USB;
BYTE fpga_configure_from_flash_init() {
    BYTE i;

#ifdef[@CAPABILITY_MAC_EEPROM;]
    __xdata WORD buf[2];

    if ( config_data_valid ) {
	mac_eeprom_read ( (__xdata BYTE*) buf, 26, 4 );		// read actual and max bitstream size 
	if ( buf[1] != 0 ) {
	    if ( buf[0] == 0 ) {
		return fpga_flash_result = 3;
	    }
//	    return 10;
	    goto flash_config;
	}
//	    return 15;
    }
#endif    

    // read the boot sector
    if ( flash_read_init( 0 ) )		// prepare reading sector 0
	return fpga_flash_result = 2;
    for ( i=0; i<8 && flash_read_byte()==fpga_flash_boot_id[i]; i++ );
    if ( i != 8 ) {
	flash_read_finish(flash_sector_size - i);	// dummy-read the rest of the sector + finish read opration
	return fpga_flash_result = 3;
    }
    i = flash_read_byte();
    i |= flash_read_byte();
    flash_read_finish(flash_sector_size - 10);		// dummy-read the rest of the sector + finish read opration
    if ( i==0 )
	return fpga_flash_result = 3;

flash_config:
    fpga_flash_result = fpga_configure_from_flash(0);
    if ( fpga_flash_result == 1 ) {
    	post_fpga_config();
    }
    else if ( fpga_flash_result == 4 ) {
	fpga_flash_result = fpga_configure_from_flash(0);	// up to two tries
    }
    return fpga_flash_result;
}    

#define[INIT_CMDS;][INIT_CMDS;
fpga_flash_result= 255;
]