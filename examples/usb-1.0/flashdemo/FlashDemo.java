/*!
   flashdemo -- demo for Flash memory access from firmware and host software for ZTEX USB Module 1.0
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
		"    -d <number>  Device Number (default: 0)\n" +
		"    -f 	  Force uploads\n" +
		"    -p           Print bus info\n" +
		"    -ue          Upload Firmware to EEPROM\n" +
		"    -re          Reset EEPROM Firmware\n" +
		"    -w           Enable certain workarounds\n" +
		"    -h           This help" );
    
    public ParameterException (String msg) {
	super( msg + "\n" + helpMsg );
    }
}

// *****************************************************************************
// ******* Test0 ***************************************************************
// *****************************************************************************
class FlashDemo extends Ztex1v1 {

// ******* FlashDemo ***********************************************************
// constructor
    public FlashDemo ( ZtexDevice1 pDev ) throws UsbException {
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
		else if ( args[i].equals("-w") ) {
	    	    workarounds = true;
		}
		else if ( args[i].equals("-h") ) {
		        System.err.println(ParameterException.helpMsg);
	    	        System.exit(0);
		}
		else if ( !args[i].equals("-re") && !args[i].equals("-ue") )
		    throw new ParameterException("Invalid Parameter: "+args[i]);
	    }
	    

// create the main class	    
	    FlashDemo ztex = new FlashDemo ( bus.device(devNum) );
	    ztex.certainWorkarounds = workarounds;
	    
// upload the firmware if necessary
	    if ( force || ! ztex.valid() || ! ztex.dev().productString().equals("Flash demo for UM 1.0")  ) {
		System.out.println("Firmware upload time: " + ztex.uploadFirmware( "flashdemo.ihx", force ) + " ms");
	    }	
		
    	    for (int i=0; i<args.length; i++ ) {
		if ( args[i].equals("-re") ) {
		    ztex.eepromDisable();
		} 
		else if ( args[i].equals("-ue") ) {
		    System.out.println("Firmware to EEPROM upload time: " + ztex.eepromUpload( "flashdemo.ihx", force ) + " ms");
		}
	    }
	    
// print some information
	    System.out.println("Capabilities: " + ztex.capabilityInfo(", "));
	    System.out.println("Enabled: " + ztex.flashEnabled());
	    System.out.println("Size: " + ztex.flashSize());
	    
	    byte[] buf = new byte[ztex.flashSectorSize()];
	    ztex.flashReadSector(0,buf);		// read out the las sector;
	    int sector = (buf[0] & 255) | ((buf[1] & 255) << 8) | ((buf[1] & 255) << 16) | ((buf[1] & 255) << 24);
	    System.out.println("Last sector: "+sector);

	    ztex.flashReadSector(sector,buf);		// read out the string
	    int i=0;
	    while ( buf[i] != '\0'&& i < ztex.flashSectorSize() )
		i++;
	    System.out.println("The string: `" + new String(buf,0,i)+ "'");

	}
	catch (Exception e) {
	    System.out.println("Error: "+e.getLocalizedMessage() );
	} 
   } 
   
}
