/*!
   Java host software API of ZTEX SDK
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

package ztex;

import ch.ntb.usb.*;

/**
  * This class represents the configuration data space of ZTEX FPGA Boards that support it.
  * The internal format is
  * <pre>
  * &lt;Address&gt; &lt;Description&gt;
  * 0..2      Signature "CD0"
  * 3         Kind of FPGA Board, see {@link #boardNames}, e.g. 2 for "ZTEX USB-FPGA Module",
  * 4         FPGA Board series, e.g. 2
  * 5         FPGA Board number (number behind the dot), e.g. 16
  * 6..7      FPGA Board variant (letter), e.g. "b"
  * 8..9      FPGA, see {@link #fpgas}, e.g. 12 for X7A200T
  * 10        FPGA package, see {@link #packages}, e.g. 3 for FBG484
  * 11..13    Speed grade + temperature range, e.g. "2C"
  * 14        RAM size, format is ( n & 0xf0 ) << ( (n & 0xf) + 16 ) bytes
  * 15        RAM type, see {@link #ramTypes}
  * 16..25    Serial number, overwrites SN_STRING of the ZTEX descriptor.  
  *           If it is equal to "0000000000" (default) it is replaced by the unique MAC address.
  * 26..27    Actual size of Bitstream in 4K sectors; 0 means Bitstream disabled (default)
  * 28..29    Maximum size of Bitstream in 4K sectors; 0 means that either no Flash
  *           is present or that this information is stored in Flash (exchangeable media)
  * 30..79    Reserved
  * 80..127   48 bytes user space
  * </pre>
  */   

public class ConfigData {

/** 
  * Kinds of FPGA Boards. 
  * It's defined as
  * <pre>{@code
public static final String boardNames[] = {
    "(unknown)" ,             // 0
    "ZTEX FPGA Module" ,      // 1
    "ZTEX USB-FPGA Module"    // 2
};}</pre>
  **/
    public static final String boardNames[] = {
	"(unknown)" ,             // 0
	"ZTEX FPGA Module" ,      // 1
	"ZTEX USB-FPGA Module"    // 2
    };

/**
  * FPGA's used on ZTEX FPGA Boards.
  * It's defined as
  * <pre>{@code
public static final String fpgas[] = {
	"(unknown)" ,  // 0
	"XC6SLX9" ,    // 1
	"XC6SLX16" ,   // 2
	"XC6SLX25" ,   // 3
	"XC6SLX45" ,   // 4
	"XC6SLX75" ,   // 5
	"XC6SLX100" ,  // 6
	"XC6SLX150" ,  // 7
	"XC7A35T",     // 8
	"XC7A50T",     // 9
	"XC7A75T",     // 10
	"XC7A100T",    // 11
	"XC7A200T",    // 12
	"Quad-XC6SLX150"  // 13
};}</pre>
  **/
    public static final String fpgas[] = {
	"(unknown)" ,  // 0
	"XC6SLX9" ,    // 1
	"XC6SLX16" ,   // 2
	"XC6SLX25" ,   // 3
	"XC6SLX45" ,   // 4
	"XC6SLX75" ,   // 5
	"XC6SLX100" ,  // 6
	"XC6SLX150" ,  // 7
	"XC7A35T",     // 8
	"XC7A50T",     // 9
	"XC7A75T",     // 10
	"XC7A100T",    // 11
	"XC7A200T",    // 12
	"Quad-XC6SLX150"  // 13
    };

/** * FPGA packages used on ZTEX FPGA boards.
  * It's defined as
  * <pre>{@code
public static final String packages[] = {
	"(unknown)",  // 0
	"FTG256" ,    // 1  256 balls, 1.0mm
	"CSG324" ,    // 2  324 balls, 0.8mm
	"CSG484" ,    // 3  484 balls, 0.8mm
	"FBG484"      // 4  484 balls, 1.0mm
};}</pre>
  **/
    public static final String packages[] = {
	"(unknown)",  // 0
	"FTG256" ,    // 1  256 balls, 1.0mm
	"CSG324" ,    // 2  324 balls, 0.8mm
	"CSG484" ,    // 3  484 balls, 0.8mm
	"FBG484"      // 4  484 balls, 1.0mm
    };

/** * RAM types and speed used on ZTEX FPGA boards.
  * It's defined as
  * <pre>{@code
public static final String ramTypes[] = {
	"(unknown)",        // 0
	"DDR-200 SDRAM",    // 1
	"DDR-266 SDRAM",    // 2
	"DDR-333 SDRAM",    // 3
	"DDR-400 SDRAM",    // 4
	"DDR2-400 SDRAM",   // 5
	"DDR2-533 SDRAM",   // 6
	"DDR2-667 SDRAM",   // 7
	"DDR2-800 SDRAM",   // 8
	"DDR2-1066 SDRAM"   // 9
};}</pre>
  **/
    public static final String ramTypes[] = {
	"(unknown)",        // 0
	"DDR-200 SDRAM",    // 1
	"DDR-266 SDRAM",    // 2
	"DDR-333 SDRAM",    // 3
	"DDR-400 SDRAM",    // 4
	"DDR2-400 SDRAM",   // 5
	"DDR2-533 SDRAM",   // 6
	"DDR2-667 SDRAM",   // 7
	"DDR2-800 SDRAM",   // 8
	"DDR2-1066 SDRAM",  // 9
	"DDR3-800 SDRAM",   // 10
	"DDR3-1066 SDRAM"   // 11
    };
    
    private byte[] data = new byte[128];  // data buffer
    private Ztex1v1 ztex = null;

    
/** 
 * Constructs an empty instance.
 */
   public ConfigData() {
	data[0] = 67;
	data[1] = 68;
	data[2] = 48;
	for ( int i=3; i<128; i++)
	    data[i] = 0;
	for ( int i=16; i<26; i++)
	    data[i] = 48;
   }

/** 
  * Constructs an instance and connects it with z. Also see {@link #connect(Ztex1v1)}.
  * @param z The ztex device to connect with.
  * @throws InvalidFirmwareException if interface 1 is not supported.
  * @throws UsbException If a communication error occurs.
  * @throws CapabilityException If no MAC-EEPROM support is present.
  */
   public ConfigData( Ztex1v1 z ) throws InvalidFirmwareException, UsbException, CapabilityException {
	this();
	connect(z);
   }

   
/** 
  * Reads the configuration data (if existent) from a device and connects it to this instance. 
  * After this user defined settings (e.g. serial number, bitstream size) are 
  * stored on device immediately after they are altered.
  * @param z The ztex device to connect with.
  * @return True if configuration data could be read.
  * @throws InvalidFirmwareException If interface 1 is not supported.
  * @throws UsbException If a communication error occurs.
  * @throws CapabilityException If no MAC-EEPROM support is present.
  */
   public boolean connect( Ztex1v1 z ) throws InvalidFirmwareException, UsbException, CapabilityException {
	ztex = z;
	if ( ztex == null ) return false;
	
	byte[] buf = new byte[128];
        ztex.macEepromRead(0,buf,128);
        if ( buf[0]==67 && buf[1]==68 && buf[2]==48 ) {
    	    for ( int i=3; i<128; i++)
		data[i] = buf[i];
	    return true;
	}
	return false;
   }


/** 
  * Disconnects the currently connected device.
  * After this modified settings are not stored on device anymore.
  * @return True if a device was connected.
  */
   public boolean disconnect() {
	if ( ztex == null ) return false;
	ztex = null;
	return true;
    }


/** 
  * Returns a copy of the configuration data array.
  * @return A copy of the configuration data array.
  */
   public byte[] data () {
	byte[] buf = new byte[128];
    	for ( int i=0; i<128; i++)
	    buf[i] = data[i];
	return buf;
   }


/** 
  * Returns a string of an array of strings including range check.
  */
   private String stringOfArray (String[] a, int i) {
	if ( i > a.length || i < 0 ) i = 0;
	return a[i];
    }


/** 
  * Finds a string from array.
  */
   private int findFromArray ( String[] a, String s) {
	int i = 0;
	while ( i < a.length && !a[i].equals(s) ) i++;
	if ( i >= a.length ) {
	    System.err.print("Invalid value: `" + s + "'. Possible values: `" + a[1] + "'");
	    for (int j=2; j<a.length; j++ )
		System.out.print(", `" + a[j] + "'");
	    System.out.println();
	    i = 0;
	}
	return i;
    }
    

/** 
  * Returns a string from data.
  */
   private String stringFromData (int start, int maxlen) {
	int i = 0;
	while ( i < maxlen && data[start+i] != 0 ) i++;
	return new String(data,start,i);
    }


/** 
  * send data
  * returns true if data was sent
  */
   private boolean sendData ( int start, int len) throws InvalidFirmwareException, UsbException, CapabilityException {
	if ( ztex == null ) return false;
	if ( start < 0 ) start = 0;
	if ( len > 128-start ) len = 128-start;
	if ( len <= 0 ) return false;
	byte[] buf = new byte[len];
	for ( int i=0; i<len; i++ ) 
	    buf[i] = data[start+i];
	ConfigData c = ztex.config;
	ztex.config = null;
        ztex.macEepromWrite(start,buf,len);
	ztex.config = c;
        return true;
    }

/** 
  * Convert string to data.
  */
   private void stringToData (String s, int start, int maxlen) {
	byte buf[] = s.getBytes();
	for ( int i=0; i<maxlen; i++ ) {
	    data[start+i] = i<buf.length ? buf[i] : 0;
	}
    }

/** 
  * Returns the name of the FPGA Board.
  * @return The name of the FPGA Board.
  */
   public String getName () {
	return stringOfArray(boardNames,data[3]) + " " + data[4] + "." + data[5] + stringFromData(6,2);
   }

/** 
  * Sets the name of the FPGA Board. 
  * Example: <pre>setName("ZTEX USB-FPGA Module", 2, 16, "b");  // denotes "ZTEX USB-FPGA Module 2.16b"</pre>
  * This setting is not transferred to the FPGA Board because is should not be altered by the user.
  * @param kind Kind of FPGA Board, see {@link #boardNames} for possible values, e.g. "ZTEX USB-FPGA Module"
  * @param series FPGA Board series, e.g. 2
  * @param number FPGA Board number (number behind the dot), e.g. 16
  * @param variant FPGA Board variant (letter), e.g. "b"
 */
   public void setName ( String kind, int series, int number, String variant) {
	data[3] = (byte) findFromArray(boardNames, kind);
	data[4] = (byte) (series & 255);
	data[5] = (byte) (number & 255);
	stringToData(variant,6,2);
   }

/** 
  * Returns FPGA information. 
  * Notation of the result is &lt;name&gt;-&lt;package&gt;-&lt;speed grade and temperature range&gt;, e.g. XC7A200T-FBG484-2C.
  * @return FPGA Information.
  */
   public String getFpga () {
	return stringOfArray(fpgas, (data[8] & 255) | ((data[9] & 255) << 8)) + "-" + stringOfArray(packages, data[10]) + "-" + stringFromData(11,3);
   }

/** 
  * Sets FPGA information. 
  * Example: <pre>setFpga("XC7A200T", "FBG484", "2C");   // denotes Xilinx part number XC7A200T-2FBG484C</pre>
  * This setting is not transferred to the FPGA Board because is should not be altered by the user.
  * @param name Name of the FPGA, see {@link #fpgas} for possible values, e.g. "XC7A200T"
  * @param pckg FPGA package, see {@link #packages} for possible values, e.g. "FBG484"
  * @param sg Speed grade and temperature range, e.g. "2C"
 */
   public void setFpga ( String name, String pckg, String sg) {
	int i = findFromArray(fpgas, name);
	data[8] = (byte) (i & 255);
	data[9] = (byte) ((i>>8) & 255);
	data[10] = (byte) findFromArray(packages, pckg);
	stringToData(sg,11,3);
   }

/** 
  * Returns RAM type and speed. 
  * @return FPGA Information.
  */
   public String getRamType () {
	return stringOfArray(ramTypes, (data[15] & 255));
   }

/** 
  * Returns RAM size in bytes. 
  * @return RAM size in bytes.
  */
   public int getRamSize () {
	return (data[14] & 0xf0) << ( (data[14] & 0xf) + 16 );
   }

/** 
  * Sets RAM information. 
  * Example: <pre>setRam(128, "DDR2-800 SDRAM");   // sets RAM info to 128 MB DDR2-800 SDRAM</pre>
  * This setting is not transferred to the FPGA Board because is should not be altered by the user.
  * @param size RAM size in MBytes, e.g. 128
  * @param type RAM type and speed, see {@link #ramTypes} for possible values, e.g. "DDR2-800 SDRAM"
 */
   public void setRam ( int size, String type) {
	if (size<0 || size>480) {
	    System.err.println("Warning: Invalid RAM size: `" + size + "'. Possible values are 0 to 480.");
	    size = 0;
	}
	int i=0;
	while (size >= 16) {
	    i++;
	    size = size >> 1;
	}
	data[14] = (byte) ((size << 4) | (i & 15));
	data[15] = (byte) findFromArray(ramTypes, type);
   }

/** 
  * Returns maximum size of bitstream in bytes.
  * This is the amount of flash which should be reserved for the bitstream.
  * @return Maximum size of bitstream in bytes sectors.
  */
   public int getMaxBitstreamSize () {
	return ( (data[28] & 255) | ((data[29] & 255) << 8) ) * 4096;
   }

/** 
  * Sets the maximum size of bitstream in 4 KByte sectors.
  * This setting is not transferred to the FPGA Board because is should not be altered by the user.
  * @param size4k Maximum size of bitstream in 4 KByte sectors. E.g. a value of 256 reserves 1 MByte for the bitstream.
 */
   public void setMaxBitstreamSize ( int size4k ) {
	data[28] = (byte) (size4k & 255);
	data[29] = (byte) ((size4k>> 8) & 255);
   }

/** 
  * Returns actual size of bitstream in bytes sectors.
  * 0 means that no bitstream is stored. The value is rounded up to a multiples of 4096.
  * @return Actual size of bitstream in byte sectors.
  */
   public int getBitstreamSize () {
	return ( (data[26] & 255) | ((data[27] & 255) << 8) ) * 4096;
   }

/** 
  * Sets the actual size of bitstream in bytes. The value is rounded up to a multiple of 4096.
  * If a device is connected, this setting is transferred to the FPGA Board.
  * A warning is printed if bitstream size is larger then the reserved size (see {@link #getMaxBitstreamSize()}).
  * @param size Actual size of bitstream in bytes.
  * @return True if a device is connected and setting was send.
  * @throws InvalidFirmwareException If interface 1 is not supported.
  * @throws UsbException If a communication error occurs.
  * @throws CapabilityException If no MAC-EEPROM support is present.
 */
   public boolean setBitstreamSize ( int size ) throws InvalidFirmwareException, UsbException, CapabilityException {
	if ( size < 0 ) size = 0;
	size = (size + 4095) >> 12;
	int i = (data[28] & 255) | ((data[29] & 255) << 8);
	if ( size > i )  System.err.println("Warning: Bitstream size of " + size + " 4K sectors larger than reserved memory of " + i + " 4K sectors");
	data[26] = (byte) (size & 255);
	data[27] = (byte) ((size>> 8) & 255);
	return sendData(26,2);
   }

/** 
  * Returns the serial number. This is not necessarily the serial number
  * returned by the FPGA board according to the USB specification, see {@link #setSN(String)}
  * @return Serial number as stored in the configuration data space.
  */
   public String getSN () {
	return stringFromData(16,10);
   }

/** 
  * Sets the serial number. 
  * During start-up the firmware overwrites SN_STRING from the ZTEX descriptor (see {@link ZtexDevice1}) by this value.  
  * If it is equal to "0000000000" (default) it is replaced by the unique MAC address. <p>
  * This setting is transferred to the FPGA Board.
  * Change takes effect after the next restart of the firmware.
  * @param sn Serial number string. Only the first 10 characters are considered.
  * @return True if a device is connected and setting was send.
  * @throws InvalidFirmwareException If interface 1 is not supported.
  * @throws UsbException If a communication error occurs.
  * @throws CapabilityException If no MAC-EEPROM support is present.
 */
   public boolean setSN ( String sn ) throws InvalidFirmwareException, UsbException, CapabilityException {
	stringToData(sn,16,10);
	return sendData(16,10);
   }

/** 
  * Returns user data at index i.
  * @param i the index. Valid values are 0 to 47.
  * @return User data.
  * @throws IndexOutOfBoundsException If i is smaller than 0 or greater than 47.
  */
   public byte getUserData (int i) {
	if ( i<0 || i>47 ) throw new IndexOutOfBoundsException ( "Invalid index: " + i + ". Valid range is 0 to 47.");
	return data[80+i];
   }

/** 
  * Sets user data at index i to value v. Use the method {@link #getMaxBitstreamSize()}
  * to transfer the data to the FPGA Board.
  * @param i The index. Valid values are 0 to 47.
  * @param v The value.
  * @throws IndexOutOfBoundsException If i is smaller than 0 or greater than 47.
  */
   public void setUserData (int i, byte v) throws IndexOutOfBoundsException {
	if ( i<0 || i>47 ) throw new IndexOutOfBoundsException ( "Invalid index: " + i + ". Valid range is 0 to 47.");
	data[80+i] = v;
   }

/** 
  * Sends the user data to the FPGA Board.
  * @return True if a device is connected and data could be send.
  * @throws InvalidFirmwareException If interface 1 is not supported.
  * @throws UsbException If a communication error occurs.
  * @throws CapabilityException If no MAC-EEPROM support is present.
  */
   public boolean sendtUserData () throws InvalidFirmwareException, UsbException, CapabilityException {
	return sendData(80,48);
   }
}    
