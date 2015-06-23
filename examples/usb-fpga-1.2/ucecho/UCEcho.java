/*!
   ucecho -- uppercase conversion example for ZTEX USB-FPGA Module 1.2
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
class UCEcho extends Ztex1v1 {

// ******* UCEcho **************************************************************
// constructor
    public UCEcho ( ZtexDevice1 pDev ) throws UsbException {
	super ( pDev );
    }

// ******* echo ****************************************************************
// writes a string to Endpoint 4, reads it back from Endpoint 2 and writes the output to System.out
    public void echo ( String input ) throws UsbException {
	byte buf[] = input.getBytes(); 
	int i = LibusbJava.usb_bulk_write(handle(), 0x04, buf, buf.length, 1000);
	if ( i<0 )
	    throw new UsbException("Error sending data: " + LibusbJava.usb_strerror());
	System.out.println("Send "+i+" bytes: `"+input+"'" );

	try {
    	    Thread.sleep( 10 );
	}
	    catch ( InterruptedException e ) {
	}

	buf = new byte[1024];
	i = LibusbJava.usb_bulk_read(handle(), 0x82, buf, 1024, 1000);
	if ( i<0 )
	    throw new UsbException("Error receiving data: " + LibusbJava.usb_strerror());
	System.out.println("Read "+i+" bytes: `"+new String(buf,0,i)+"'" );  
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
	    UCEcho ztex = new UCEcho ( bus.device(devNum) );
	    ztex.certainWorkarounds = workarounds;
	    
// upload the firmware if necessary
	    if ( force || ! ztex.valid() || ! ztex.dev().productString().equals("ucecho example for UFM 1.2")  ) {
		System.out.println("Firmware upload time: " + ztex.uploadFirmware( "ucecho.ihx", force ) + " ms");
	    }
	    
// upload the bitstream if necessary
	    if ( force || ! ztex.getFpgaConfiguration() ) {
		System.out.println("FPGA configuration time: " + ztex.configureFpga( "fpga/ucecho.bit" , force ) + " ms");
	    } 


// claim interface 0
	    ztex.trySetConfiguration ( 1 );
	    ztex.claimInterface ( 0 );
	    
// read string from stdin and write it to USB device
	    String str = "";
	    BufferedReader reader = new BufferedReader( new InputStreamReader( System.in ) );
	    while ( ! str.equals("quit") ) {
		System.out.print("Enter a string or `quit' to exit the program: ");
		str = reader.readLine();
		if ( ! str.equals("") )
		    ztex.echo(str);
	        System.out.println("");
	    }
	    
// release interface 0
	    ztex.releaseInterface( 0 );	
	    
	}
	catch (Exception e) {
	    System.out.println("Error: "+e.getLocalizedMessage() );
	} 
   } 
   
}
