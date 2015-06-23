/*!
   flashbench -- Flash memory benchmark for ZTEX USB-FPGA Module 1.11
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
		"    -s <number>       Number of sectors to be tested, -1 means all (default: 10000)\n" +
		"    -f 	       Force uploads\n" +
		"    -p                Print bus info\n" +
		"    -w                Enable certain workarounds which may be required for vmware + windows\n"+
		"    -h                This help" );
    
    public ParameterException (String msg) {
	super( msg + "\n" + helpMsg );
    }
}

// *****************************************************************************
// ******* Test0 ***************************************************************
// *****************************************************************************
class FlashBench extends Ztex1v1 {

// ******* FlashBench **********************************************************
// constructor
    public FlashBench ( ZtexDevice1 pDev ) throws UsbException {
	super ( pDev );
    }

// ******* testRW **************************************************************
// measures read + write performance
    public double testRW ( int num ) throws UsbException, InvalidFirmwareException, CapabilityException {
	int secNum = 2048 / flashSectorSize();
	byte[] buf1 = new byte[flashSectorSize() * secNum];
	byte[] buf2 = new byte[flashSectorSize() * secNum];
	int errors = 0;

	long t0 = new Date().getTime();

	for ( int i=0; i<num; i+=secNum ) {
	    int l = Math.min(num-i,secNum);
	    int j=(int) Math.round(65535*Math.random());
	    for (int k=0; k<flashSectorSize()*l; k++) {
		buf1[k] = (byte) (j & 255);
		j+=57;
	    }

	    System.out.print("Sector " + (i+l) + "/" + num+ "  " + Math.round(10000.0*(i+1)/num)/100.0 + "%    \r");
	    flashWriteSector(i,l,buf1);
	    flashReadSector(i,l,buf2);

	    int diffs=flashSectorSize()*l;
	    for (int k=0; k<flashSectorSize()*l; k++) 
		if ( buf1[k] == buf2[k] )
		    diffs -= 1;
	    if ( diffs!=0 /*&& errors==0 */) {
		System.out.println("Error occured at sector " + i +": " + diffs + " differences");
	    } 
	    if ( diffs!=0 )
		errors+=1;
	}
	System.out.println("testRW: " + errors +" errors detected");

	return num*512.0/(new Date().getTime() - t0);
    }

// ******* testW **************************************************************
// measures write performance
    public double testW ( int num, int seed ) throws UsbException, InvalidFirmwareException, CapabilityException {
	int secNum = 2048 / flashSectorSize();
	byte[] buf = new byte[flashSectorSize() * secNum];
	long t0 = new Date().getTime();
	for ( int i=0; i<num; i+=secNum ) {
	    int j = Math.min(num-i,secNum);
	    System.out.print("Sector " + (i+j) + "/" + num+ "  " + Math.round(10000.0*(i+1)/num)/100.0 + "%    \r");
	    for (int k=0; k<flashSectorSize()*j; k++) {
		buf[k] = (byte) (seed & 255);
		seed+=79;
	    }
	    flashWriteSector(i,j,buf);
	}
	return num*512.0/(new Date().getTime() - t0);
    }

// ******* testR **************************************************************
// measures read performance
    public double testR ( int num, int seed ) throws UsbException, InvalidFirmwareException, CapabilityException {
	int secNum = 2048 / flashSectorSize();
	byte[] buf = new byte[flashSectorSize() * secNum];
	int errors = 0;
	long t0 = new Date().getTime();
	for ( int i=0; i<num; i+=secNum ) {
	    int j = Math.min(num-i,secNum);
	    System.out.print("Sector " + (i+j) + "/" + num+ "  " + Math.round(10000.0*(i+1)/num)/100.0 + "%    \r");
	    flashReadSector(i,j,buf);
	    int diffs = flashSectorSize()*j;
	    for (int k=0; k<flashSectorSize()*j; k++) {
		if ( buf[k] == (byte) (seed & 255) )
		    diffs-=1;
		seed+=79;
	    }
	    if ( diffs!=0 && errors==0 ) {
		System.out.println("Error occured at sector " + i +": " + diffs + " differences");
	    } 
	    if ( diffs!=0 )
		errors+=1;
	}
	System.out.println("testR: " + errors +" errors detected");
	return num*512.0/(new Date().getTime() - t0);
    }

// ******* main ****************************************************************
    public static void main (String args[]) {
    
	int devNum = 0;
	boolean force = false;
	boolean workarounds = false;
	int sectors = 10000;
	
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
	        if ( args[i].equals("-s") ) {
	    	    i++;
		    try {
			if (i>=args.length) throw new Exception();
    			sectors = Integer.parseInt( args[i] );
		    } 
		    catch (Exception e) {
		        throw new ParameterException("Number of sectors expected after -s");
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
	    FlashBench ztex = new FlashBench ( bus.device(devNum) );
	    ztex.certainWorkarounds = workarounds;
	    
// upload the firmware if necessary
	    if ( force || ! ztex.valid() || ! ztex.dev().productString().equals("flashbench for UFM 1.11") ) {
		System.out.println("Firmware upload time: " + ztex.uploadFirmware( "flashbench.ihx", force ) + " ms");
	    }
	    
// print some information
	    System.out.println("Capabilities: " + ztex.capabilityInfo(", "));
	    System.out.println("Enabled: " + ztex.flashEnabled());
	    System.out.println("Size: " + ztex.flashSize()+" Bytes");
//	    ztex.printMmcState();
	    
	    if ( sectors<1 || sectors>ztex.flashSectors() ) sectors = ztex.flashSectors();

	    System.out.println("Read + Write Performance: " + ztex.testRW(sectors) + "kb/s      \n");
	    int seed = (int) Math.round(65535*Math.random());
	    System.out.println("Write Performance: " + ztex.testW(sectors, seed) + "kb/s      ");
	    System.out.println("Read Performance: " + ztex.testR(sectors, seed) + "kb/s     \n");
	}
	catch (Exception e) {
	    System.out.println("Error: "+e.getLocalizedMessage() );
	} 
   } 
   
}
