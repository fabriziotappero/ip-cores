/*!
   debug -- debug helper example
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
// ******* Test0 ***************************************************************
// *****************************************************************************
class Debug extends Ztex1v1 {

// ******* Debug ***************************************************************
// constructor
    public Debug ( ZtexDevice1 pDev ) throws UsbException {
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
	    Debug ztex = new Debug ( bus.device(devNum) );
	    ztex.certainWorkarounds = workarounds;
	    
// upload the firmware if necessary
	    if ( force || ! ztex.valid() || ! ztex.dev().productString().equals("debug for EZ-USB devices")  ) {
		System.out.println("Firmware upload time: " + ztex.uploadFirmware( "debug.ihx", force ) + " ms");
	    }
	    
// claim interface 0
	    ztex.trySetConfiguration ( 1 );
	    ztex.claimInterface ( 0 );
	    
// read string from stdin and write it to USB device
	    byte[] buf = new byte[30];
	    BufferedReader reader = new BufferedReader( new InputStreamReader( System.in ) );
	    for (int i=0; i<20; i++ ) {
		try {
    		    Thread.sleep( 2345 );
    		}
		catch ( InterruptedException e) {
    		} 
    		int j = ztex.debugReadMessages(false,buf);
    		System.out.print(ztex.debugNewMessages + " new messages: ");
    		for (int k=0; k<j; k++ ) {
    		    if (k > 0 ) System.out.print("                ");
    		    System.out.println( ((buf[k*3] & 255) | ((buf[k*3+1] & 255)<<8)) + (buf[k*3+2] & 255)*0.01 );
    		}
    	    }
	    
// release interface 0
	    ztex.releaseInterface(0);	
	    
	}
	catch (Exception e) {
	    System.out.println("Error: "+e.getLocalizedMessage() );
	} 
   } 
   
}
