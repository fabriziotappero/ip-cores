/*!
   lightshow -- lightshow on ZTEX USB-FPGA Module 1.11b plus Experimental Board 1.10
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
		"    -h                This help" );
    
    public ParameterException (String msg) {
	super( msg + "\n" + helpMsg );
    }
}

// *****************************************************************************
// ******* Test0 ***************************************************************
// *****************************************************************************
class Lightshow extends Ztex1v1 {

// ******* Lightshow ***********************************************************
// constructor
    public Lightshow ( ZtexDevice1 pDev ) throws UsbException {
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
		else if ( args[i].equals("-h") ) {
		        System.err.println(ParameterException.helpMsg);
	    	        System.exit(0);
		}
		else throw new ParameterException("Invalid Parameter: "+args[i]);
	    }
	    

// create the main class	    
	    Lightshow ztex = new Lightshow ( bus.device(devNum) );
	    
// upload the firmware if necessary
	    if ( force || ! ztex.valid() || ! ztex.dev().productString().equals("lightshow for EXP-1.10")  ) {
		System.out.println("Firmware upload time: " + ztex.uploadFirmware( "lightshow.ihx", force ) + " ms");
	    }
	    
// check for Experimental Bord 1.10
	    if ( ! ztex.xmegaEnabled() )
		throw new Exception("Experimental Board 1.10 required");

// upload the bitstream if necessary
	    System.out.println("FPGA configuration time: " + ztex.configureFpga( "fpga/lightshow.bit" , true ) + " ms");

// bitstream if necessary
	    System.out.println("AVR Firmware upload time: " + ztex.xmegaWriteFirmware( new IhxFile("avr/lightshow.ihx" ) ) + " ms");

// program the ATxmega 
	    System.out.println( ztex );
	    
	}
	catch (Exception e) {
	    System.out.println("Error: "+e.getLocalizedMessage() );
	} 
   } 
   
}
