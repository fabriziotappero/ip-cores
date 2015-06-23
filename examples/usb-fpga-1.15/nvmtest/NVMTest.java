/*!
   nvmtest -- ATxmega non volatile memory test on ZTEX USB-FPGA Module 1.15 plus Experimental Board 1.10
   Copyright (C) 2009-2011 ZTEX GmbH.
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

import java.io.*;
import java.util.*;

import ch.ntb.usb.*;

import ztex.*;

// *****************************************************************************
// ******* ParameterException **************************************************
// *****************************************************************************
// Exception the prints a help message
class ParameterException extends Exception {
    public final static String helpMsg = new String (
		"Parameters:\n"+
		"    -d <number>       Device Number (default: 0)\n" +
		"    -f 	       Force uploads\n" +
		"    -p                Print bus info\n" +
		"    -w                Enable certain workarounds\n"+
		"    -h                This help" );
    
    public ParameterException (String msg) {
	super( msg + "\n" + helpMsg );
    }
}

// *****************************************************************************
// ******* NVMTest *************************************************************
// *****************************************************************************
class NVMTest extends Ztex1v1 {

// ******* NVMTest *************************************************************
// constructor
    public NVMTest ( ZtexDevice1 pDev ) throws UsbException {
	super ( pDev );
    }

// ******* main ****************************************************************
    public static void main (String args[]) {
    
	int devNum = 0;
	boolean force = false;
	boolean workarounds = false;
	
	try {
// init USB stuff
	    LibusbJava.usb_init();

// scan the USB bus
	    ZtexScanBus1 bus = new ZtexScanBus1( ZtexDevice1.ztexVendorId, ZtexDevice1.ztexProductId, true, false, 1);
	    if ( bus.numberOfDevices() <= 0) {
		System.err.println("No devices found");
	        System.exit(0);
	    }
	    
// scan the command line arguments
    	    for (int i=0; i<args.length; i++ ) {
	        if ( args[i].equals("-d") ) {
	    	    i++;
		    try {
			if (i>=args.length) throw new Exception();
    			devNum = Integer.parseInt( args[i] );
		    } 
		    catch (Exception e) {
		        throw new ParameterException("Device number expected after -d");
		    }
		}
		else if ( args[i].equals("-f") ) {
		    force = true;
		}
		else if ( args[i].equals("-p") ) {
	    	    bus.printBus(System.out);
		    System.exit(0);
		}
		else if ( args[i].equals("-p") ) {
	    	    bus.printBus(System.out);
		    System.exit(0);
		}
		else if ( args[i].equals("-w") ) {
	    	    workarounds = true;
		}
		else if ( args[i].equals("-h") ) {
		        System.err.println(ParameterException.helpMsg);
	    	        System.exit(0);
		}
		else throw new ParameterException("Invalid Parameter: "+args[i]);
	    }
	    

// create the main class	    
	    NVMTest ztex = new NVMTest ( bus.device(devNum) );
	    ztex.certainWorkarounds = workarounds;
	    
// upload the firmware if necessary
	    if ( force || ! ztex.valid() || ! ztex.dev().productString().equals("nvmtest for EXP-1.10")  ) {
		System.out.println("Firmware upload time: " + ztex.uploadFirmware( "nvmtest.ihx", force ) + " ms");
	    }
	    
// check for Experimental Bord 1.10
	    if ( ! ztex.xmegaEnabled() )
		throw new Exception("Experimental Board 1.10 required");

// print out some memory information
	    System.out.println("Flash size: " + ztex.xmegaFlashPages()*ztex.xmegaFlashPageSize() + "   EEPROM size: " + ztex.xmegaEepromPages()*ztex.xmegaEepromPageSize() + "   Error code: " + ztex.xmegaEC );
	    
// read out device ID from production signature row
    	    byte buf[] = new byte[ztex.xmegaFlashPageSize()];

            ztex.xmegaNvmRead ( 0x01000090, buf, 4 );
	    System.out.println( "Device ID: " + Integer.toHexString(buf[0] & 255) + " " + Integer.toHexString(buf[1] & 255) + " " + Integer.toHexString(buf[2] & 255));

// test ATxmega Flash by reading / writing random data
	    // generate + write date
	    Random random = new Random();	
    	    for (int i=0; i<ztex.xmegaFlashPageSize(); i++ )
	        buf[i] = (byte) random.nextInt();
	    ztex.xmegaFlashPageWrite ( ztex.xmegaFlashPages()*ztex.xmegaFlashPageSize()-1024, buf );

	    // read + verify data
	    byte buf2[] = new byte[ztex.xmegaFlashPageSize()];
	    ztex.xmegaFlashRead ( ztex.xmegaFlashPages()*ztex.xmegaFlashPageSize()-1024, buf2, ztex.xmegaFlashPageSize());
	    int j = 0;
	    for (int i=0; i<ztex.xmegaFlashPageSize(); i++ ) {
	        if ( buf[i] != buf2[i] ) {
		    if ( j<10 ) 
		        System.out.println("Error at " + i +": " + (buf[i] & 255) + " != " + (buf2[i] & 255));
		    j+=1;
		}
	    }
	    System.out.println(j + " Flash Errors");

// test ATxmega EEPROM by reading / writing random data
	    // generate + write date
	    random = new Random();
	    for (int i=0; i<ztex.xmegaEepromPageSize(); i++ )
	        buf[i] = (byte) random.nextInt();
	    ztex.xmegaEepromPageWrite ( ztex.xmegaEepromPages()*ztex.xmegaEepromPageSize()-64, buf );

	    // read + verify data
	    ztex.xmegaEepromRead ( ztex.xmegaEepromPages()*ztex.xmegaEepromPageSize()-64, buf2, ztex.xmegaEepromPageSize());
	    j = 0;
	    for (int i=0; i<ztex.xmegaEepromPageSize(); i++ ) {
	        if ( buf[i] != buf2[i] ) {
	    	    if ( j<10 ) 
			System.out.println("Error at " + i +": " + (buf[i] & 255) + " != " + (buf2[i] & 255));
		    j+=1;
		}
	    }
	    System.out.println(j + " EEPROM Errors");

// test fuse by reading / writing JTAGUID
	    // read old JTAGUID
	    int i = ztex.xmegaFuseRead ( 0 );
	    System.out.print( "JTAGUID: 0x" + Integer.toHexString(i & 255) );
	    // write + read new JTAGUID
	    ztex.xmegaFuseWrite ( 0, 0x56 );
	    System.out.print( " -> 0x"  + Integer.toHexString(ztex.xmegaFuseRead ( 0 ) ) );
	    // write + read old JTAGUID
	    ztex.xmegaFuseWrite ( 0, i );
	    System.out.println( " -> 0x"  + Integer.toHexString(ztex.xmegaFuseRead ( 0 ) ) );
	    
	}
	catch (Exception e) {
	    System.out.println("Error: "+e.getLocalizedMessage() );
	} 
   } 
   
}
