/*!
   intraffic -- example showing how the EZ-USB FIFO interface is used on ZTEX USB-FPGA Module 1.11c
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
// ******* USBReader ***********************************************************
// *****************************************************************************
class UsbReader extends Thread {
    private final int bufNum = 8;
    public final int bufSize = 512*1024;
    public byte[][] buf = new byte[bufNum][];
    public int[] bufBytes = new int[bufNum];
    private int readCount = -1;
    private int getCount = -1;
    public boolean terminate = false;
    private Ztex1v1 ztex;

    public UsbReader ( Ztex1v1 p_ztex ) {
        super ();
        ztex = p_ztex;
	for (int i=0; i<bufNum; i++) {
	    buf[i]=new byte[bufSize];
	}
    }
    
    public int getBuffer () {
	getCount += 1;
	while (getCount >= readCount) {
	    try {
		sleep(1);
            }
            catch ( InterruptedException e) {
            } 
	}
	return getCount % bufNum;
    }

    public void reset () {
	getCount = readCount + 1;
    }

    public void run() {
	setPriority(MAX_PRIORITY);

// claim interface 0
	try {
    	    ztex.trySetConfiguration ( 1 );
    	    ztex.claimInterface ( 0 );
    	}
    	catch ( Exception e) {
	    System.out.println("Error: "+e.getLocalizedMessage() );
	    System.exit(2);
    	} 
    	
	
// reader loop
	while ( !terminate ) {
	    readCount += 1;
	    
	    while ( readCount - bufNum >= getCount ) {
		try {
		    sleep(1);
        	}
    		catch ( InterruptedException e) {
        	} 
	    }

	    int i = readCount % bufNum;
	    bufBytes[i] = LibusbJava.usb_bulk_read(ztex.handle(), 0x82, buf[i], bufSize, 1000);
//	    System.out.println("Buffer " + i +": read " + bufBytes[i] + " bytes");
	}

// release interface 0
        ztex.releaseInterface( 0 );	
	    
    }
}


// *****************************************************************************
// ******* Test0 ***************************************************************
// *****************************************************************************
class InTraffic extends Ztex1v1 {

// ******* InTraffic **************************************************************
// constructor
    public InTraffic ( ZtexDevice1 pDev ) throws UsbException {
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
	    InTraffic ztex = new InTraffic ( bus.device(devNum) );
	    ztex.certainWorkarounds = workarounds;
	    
// upload the firmware if necessary
	    if ( force || ! ztex.valid() || ! ztex.dev().productString().equals("intraffic example for UFM 1.11") ) {
		System.out.println("Firmware upload time: " + ztex.uploadFirmware( "intraffic.ihx", force ) + " ms");
		force = true;
	    }
	    
// upload the bitstream if necessary
	    if ( force || ! ztex.getFpgaConfiguration() ) {
		System.out.println("FPGA configuration time: " + ztex.configureFpga( "fpga/intraffic.bit" , force ) + " ms");
	    } 

// read the traffic
	    UsbReader reader = new UsbReader( ztex );
	    reader.start();

// EZ-USB FIFO test (controlled mode)
	    ztex.vendorCommand (0x60, "Set test mode", 0, 0);
	    reader.reset();
	    
	    int vcurrent = -1;
	    for (int i=0; i<1000; i++) {
		int j = reader.getBuffer();
		int bb = reader.bufBytes[j];
		byte[] b = reader.buf[j];
		int current = vcurrent+1;
		int lastwi = -1;
		int aerrors = 0;
		int ferrors = 0;
		int errors = 0;
		int prevErrors = 0;
		
		for (int k=1; k<bb; k+=2 ) {
		    if ( (b[k] & 0x80) == 0 ) {
			current = ((b[k] & 0x7f) << 8) | (b[k-1] & 0xff);
			if ( lastwi == 0 ) aerrors+=1;
			if ( lastwi == 0 ) System.out.println("Alignment error: 0 at " + i + ":" + (k-1) );
			lastwi = 0;
		    }
		    else {
			current |= ((b[k] & 0x7f) << 23) | ((b[k-1] & 0xff) << 15);
			
			vcurrent += 1;
			if ( vcurrent % 100 == 90 )
			    vcurrent += 10;

			if ( lastwi == 1 ) {
			    aerrors+=1;
			    System.out.println("Alignment error: 1 at " + i + ":" + (k-1) );
			}
			else if ( vcurrent != current ) {
			    if ( (i != 0) && ( k != 3) ) {
				System.out.println("Error: 0b" + Integer.toBinaryString(vcurrent) + " expected at " + i + ":" + (k-3) + " but " );
				System.out.println("       0b" + Integer.toBinaryString(current) + " found");
				errors+=1;
 				prevErrors+=1;
 			    }
 			    vcurrent = current;
			}
			else {
//			    if ( prevErrors > 0 ) System.out.println("       0b" + Integer.toBinaryString(current) );
			    if ( prevErrors == 1 ) 
				ferrors +=1;
			    prevErrors = 0;
			}
			
    			lastwi = 1;
//			System.out.println(current);
		    } 
//		    System.out.println(b[k]+"  " +b[k+1]);
		} 
		System.out.print("Buffer " + i + ": " + (errors-ferrors) + " errors,  " + ferrors + " FIFO errors,  " + aerrors + " alignment errors  \r");
	    }
	    System.out.println();

// performance test (continous mode)
	    ztex.vendorCommand (0x60, "Set test mode", 1, 0);
	    reader.reset();
	    
	    int words = 0;
	    int intSum = 0;
	    int intMax = 0;
	    int intAdj = 0;
	    int lastwi = -1;
	    for (int i=0; i<1000; i++) {
		int j = reader.getBuffer();
		int bb = reader.bufBytes[j];
		byte[] b = reader.buf[j];
		int current = vcurrent+1;
		
		for (int k=1; k<bb; k+=2 ) {
		    if ( (b[k] & 0x80) == 0 ) {
			current = ((b[k] & 0x7f) << 8) | (b[k-1] & 0xff);
			if ( lastwi == 0 ) intAdj -= 1;
			lastwi = 0;
		    }
		    else {
			current |= ((b[k] & 0x7f) << 23) | ((b[k-1] & 0xff) << 15);
			
			if ( lastwi == 1 ) {
			    intAdj += 1;
			}
			else {
			    vcurrent += 1;
			    int it = (current - vcurrent)*2 + intAdj;
			    if ( it > 0 && words > 0) {
				intSum += it;
				if ( it > intMax )
				    intMax = it;
			    }
			    words += 2;
 			    vcurrent = current;
 			    intAdj = 0;
			}
    			lastwi = 1;
//			System.out.println(current);
		    } 
//		    System.out.println(b[k]+"  " +b[k+1]);
		} 
		System.out.print("Buffer " + i + ": " + Math.round(words*6000.0/(words+intSum))/100.0 + "MB/s, max. interrupt: " + Math.round(intMax/150.0)/100 + "ms    \r");
	    } 
	    System.out.println();
    
	    
	    reader.terminate=true;
	    
	}
	catch (Exception e) {
	    System.out.println("Error: "+e.getLocalizedMessage() );
	} 
   } 
   
}
