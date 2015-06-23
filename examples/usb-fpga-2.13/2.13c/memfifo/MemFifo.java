/*!
   memfifo -- implementation of EZ-USB slave FIFO's (input and output) a FIFO using the DDR3 SDRAM for ZTEX USB-FPGA Modules 2.13
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

import java.io.*;
import java.util.*;
import java.text.*;

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

    }
}

// *****************************************************************************
// ******* UsbWriter ***********************************************************
// *****************************************************************************
class UsbWriter extends Thread {
    private final int bufNum = 8;
    public final int bufSize = 512*1024;
    public byte[][] buf = new byte[bufNum][];
    private int writeCount = -1;
    private int getCount = -1;
    public boolean terminate = false;
    private Ztex1v1 ztex;
    public int errorBuffferCount = -1;		// buffer count if an error occurred; otherwise -1
    public int errorResult = 0;			// error code or number of bytes if an error occurred

    public UsbWriter ( Ztex1v1 p_ztex ) {
        super ();
        ztex = p_ztex;
	for (int i=0; i<bufNum; i++) {
	    buf[i]=new byte[bufSize];
	}
    }
    
    public int getBuffer () {
	getCount += 1;
	while (getCount - bufNum >= writeCount) {
	    try {
		sleep(1);
            }
            catch ( InterruptedException e) {
            } 
	}
	return getCount % bufNum;
    }

    public void reset () {
	getCount = writeCount + 1;
	errorBuffferCount = -1;
    }

    public void run() {
	setPriority(MAX_PRIORITY);

// writer loop
	while ( !terminate ) {
	    writeCount += 1;
	    
	    while ( writeCount >= getCount ) {
		try {
		    sleep(1);
        	}
    		catch ( InterruptedException e) {
        	} 
	    }

	    int i = writeCount % bufNum;
	    int j = LibusbJava.usb_bulk_write(ztex.handle(), 0x06, buf[i], bufSize, 1000);
	    if ( j != bufSize ) {
		errorBuffferCount = writeCount;
		errorResult = j;
	    }
//	    System.out.println("Buffer " + i +": wrote " + j + " bytes");
	}
	    
    }
}

// *****************************************************************************
// ******* UsbTestWriter *******************************************************
// *****************************************************************************
class UsbTestWriter extends Thread {
    public boolean terminate = false;
    private UsbWriter writer;

    public UsbTestWriter ( Ztex1v1 p_ztex ) {
        super ();
	writer = new UsbWriter( p_ztex );
    }
    
    public boolean error () {
	return writer.errorBuffferCount >= 0;
    }

    public void run() {
	writer.start();

	int k = 0;
	int cs = 47;
	int sync;
	Random random = new Random();
	while ( !terminate ) {
	    byte[] b = writer.buf[writer.getBuffer()];
	    for ( int i=0; i<writer.bufSize; i++ ) {
		int j = k & 15;
		sync = ( ((j & 1)==1) || (j==14) ) ? 128 : 0;
		if ( j == 15 ) {
		    b[i] = (byte) (sync | ((cs & 127) ^ (cs>>7)));
		    cs = 47;
		}
		else {
//		    b[i] = (byte) ( (j==0 ? (k>>4) & 127 : random.nextInt(128)) | sync );
		    b[i] = (byte) ( (((k>>4)+j) & 127) | sync );
		    cs += (b[i] & 255);
		}
		k=(k+1) & 65535;
	    }
	}
	
        writer.terminate=true;
    }
}


// *****************************************************************************
// ******* MemFifo *************************************************************
// *****************************************************************************
class MemFifo extends Ztex1v1 {

    // constructor
    public MemFifo ( ZtexDevice1 pDev ) throws UsbException {
	super ( pDev );
    }

    // set mode
    public void setMode( int i ) throws UsbException {
	i = i & 3;
	vendorCommand (0x80, "Set test mode", i, 0);
    }

    // reset
    public void reset( ) throws UsbException {
	vendorCommand (0x81, "Reset:", 0, 0);
	try {
	    Thread.sleep(300);
        }
        catch ( InterruptedException e) {
        } 
	byte[] buf = new byte[4096];
	while ( LibusbJava.usb_bulk_read(handle(), 0x82, buf, buf.length, 100) == buf.length ) { };  // empties buffers
    }
    
    // reads data and verifies them. 
    // returns true if errors occurred
    // rate is data rate in kBytes; <=0 means unlimited
    public boolean verify ( UsbReader reader, int iz, int rate ) {
    	boolean valid = false;
	int byte_cnt = 0, sync_cnt = 0, cs = 47, first = 255, prev_first = 255;
	boolean memError = false;

	for (int i=0; i<iz; i++) {
	    if ( i>0 && rate>0 ) {
		try {
		    Thread.sleep(reader.bufSize/rate);
        	}
        	catch ( InterruptedException e) {
        	} 
	    }
	    int j = reader.getBuffer();
	    int bb = reader.bufBytes[j];
	    byte[] b = reader.buf[j];
	    int merrors = 0;
	    int ferrors = 0;
	    int serrors = 0;
	    boolean prev_sync = false;

	    if ( bb != reader.bufSize ) {
		System.out.println("Data read error");
		memError = true;
		break;
	    }

/*	    for ( int l=0; l<512; l+=1) {
		System.out.print("   " + (b[l] & 255) );
		if ( (l & 15) == 15 ) System.out.println();
	    } */

	    for (int k=0; k<bb; k++ ) {
		byte_cnt++;
		sync_cnt++;
		if ( (b[k] & 128) == 0 ) sync_cnt=0;
		if ( byte_cnt == 1 ) {
		    prev_first = first;
    		    first = b[k] & 255;
		} 
// 		if ( k<40 ) System.out.println(k + ": " + (b[k] & 255) + "  " + (b[k] & 127) + "   " + ((cs & 127) ^ (cs>>7)) + "  " + byte_cnt + "  " + sync_cnt +"	" + prev_first + "  " + first );
		if ( sync_cnt == 3 ) {
		    boolean serror = byte_cnt != 16;
		    boolean merror = ( b[k] & 127 ) != ((cs & 127) ^ (cs>>7));
		    boolean ferror = prev_sync && ( first != ((prev_first + 1) & 127) );
		    prev_sync = byte_cnt == 16;
//		    valid = valid || ( !serror && !merror && !ferror );
		    valid = valid || ( !serror && !merror );
		    if ( valid ) {
			if ( serror ) serrors += 1;
			else if ( merror ) merrors += 1;
			else if ( ferror ) ferrors += 1;
			if ( serror && (serrors <= 2) && (k>=byte_cnt-1) && (k+1<bb)  ) {
			    System.out.print( "Sync Error: " + byte_cnt + " at " + k + ": " );
			    for ( int l=1; l<=byte_cnt+1; l++ ) System.out.print((b[k-byte_cnt+l] < 0 ? "*" : "" ) + (b[k-byte_cnt+l] & 127) + " ");
			}
//			if ( ferror && (ferrors == 1) && (k+1<bb) ) System.out.println( "Fifo error: " + prev_first + " " + first + " " +  ( b[k+1] & 127 ) + ":    ");
		    }
		    cs=47;
		    byte_cnt = 0;
		} else {
		    cs += ( b[k] & 255);
		}
	    }
		    
	    if ( ! valid ) {
		System.out.println("Invalid data");
		return true;
	    }
		    
	    System.out.print("Buffer " + i + ": " + serrors + " sync errors, 	" + merrors + " memory or transfer errors,  " + ferrors + " FIFO errors    \r");
	    if ( merrors + ferrors + serrors > (i==0 ? 1 : 0 ) ) { // one error in first buffer may occurs ofter changing mode
	        System.out.println();
	        memError = true;
	    }
	}
        System.out.println();
	return memError;
    }

// ******* main ****************************************************************
    public static void main (String args[]) {
    
	int devNum = 0;
	boolean force = false;
	
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

	    String errStr = "";

// create the main class	    
	    MemFifo ztex = new MemFifo ( bus.device(devNum) );
	    
// upload the firmware if necessary
	    if ( force || ! ztex.valid() || ! ztex.dev().productString().equals("memfifo for UFM 2.13") ) {
		System.out.println("Firmware upload time: " + ztex.uploadFirmware( "memfifo.ihx", force ) + " ms");
		force = true;
	    }
	    
// upload the bitstream if necessary
	    if ( force || ! ztex.getFpgaConfiguration() ) {
		System.out.println("FPGA configuration time: " + ztex.configureFpga( "fpga/memfifo.runs/impl_1/memfifo.bit" , force, -1 ) + " ms");
	    } 

// claim tnterface
    	    ztex.trySetConfiguration ( 1 );
    	    ztex.claimInterface ( 0 );
    	    
// reset FIFO's 
	    if ( !force ) {
		System.out.println("Resetting  FIFO's");
		ztex.reset();
	    }

// PKTEND test
/*	    {
		byte[] buf = new byte[65536];
	        int i = LibusbJava.usb_bulk_write(ztex.handle(), 0x06, buf, buf.length, 1000);
//	        System.out.println("PKTEND test: wrote "+i+" bytes");
		// number of read bytes is usually less than number written bytes because DRAM FIFO is usually never completely emptied in order to avoid small transactions
	        i=LibusbJava.usb_bulk_read(ztex.handle(), 0x82, buf, buf.length, 1000); 
	        // 
	        int j = i & 511;
	        System.out.println("PKTEND test: read "+i+" bytes, last paket: " + (j == 0 ? 512 : j) + " bytes" );
	    } */

// start traffic reader
	    UsbReader reader = new UsbReader( ztex );
	    reader.start();

// Mode 1: 48 MByte/s Test data generator: used for speed test
	    ztex.setMode(1);
	    System.out.println("48 MByte/s test data generator: ");
	    long t0 = new Date().getTime();
	    ztex.verify(reader, 2000, 0);
	    System.out.println("Read data rate: " + Math.round(reader.bufSize*2000.0/((new Date().getTime()-t0)*100.0)*0.1) + " MByte/s");

	    
// Mode 2: 12 MByte/s Test data generator: tests flow control
	    ztex.setMode(2);
	    System.out.println("12 MByte/s test data generator: ");
	    ztex.verify(reader, 2000, 0);

// PKTEND test
	    {
		byte[] buf = new byte[65536];
	        int i;
	        while ( (i = LibusbJava.usb_bulk_write(ztex.handle(), 0x06, buf, buf.length, 1000)) == buf.length ) { }
	        int j = i & 511;
	        System.out.println("PKTEND test: last paket size: " + (j == 0 ? 512 : j) + " bytes" );
	    } 
	    
// Mode 0: write+read mode
	    ztex.reset();
	    UsbTestWriter writer = new UsbTestWriter( ztex );
	    writer.start();
	    reader.reset();

	    System.out.println("USB write + read mode: speed test");
	    t0 = new Date().getTime();
	    ztex.verify(reader, 1000, 0);
	    System.out.println("Read data rate: " + Math.round(reader.bufSize*1000.0/((new Date().getTime()-t0)*100.0)*0.1) + " MByte/s");

	    System.out.println("USB write + read mode: 5 MByte/s read rate");
	    ztex.verify(reader, 1000, 5000);

	    if ( writer.error() ) System.out.println("Write errors occured");

// Terminating threads
	    writer.terminate=true; 	// stop the writer
	    reader.terminate=true;  	// stop the reader
/*	    for (int i=0; i<10000 &&  writer.isAlive() && reader.isAlive(); i++ ) { 
		if ( ( i % 1000 ) == 999 ) System.out.print(".");
		try {
		    Thread.sleep(1);
        	}
    		catch ( InterruptedException e) {
        	} 
	    }
	    System.out.println();
	    
// releases interface	    
    	    ztex.releaseInterface( 0 );	 */
    	    
	}
	catch (Exception e) {
	    System.out.println("Error: "+e.getLocalizedMessage() );
	} 
	
   } 
   
}
