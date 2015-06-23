/*!
   DeviceServer for the ZTEX USB-FPGA Modules
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
    ZTEX device server
*/

import java.io.*;
import java.util.*;
import java.text.*;
import java.net.*;

import com.sun.net.httpserver.*;

import ch.ntb.usb.*;

import ztex.*;

// *****************************************************************************
// ******* ErrorBuffer *********************************************************
// *****************************************************************************
class ErrorBuffer {
    private static final int bufsize = 128;
    private static String cids[] = new String[bufsize];
    private static StringBuilder messages[] = new StringBuilder[bufsize];
    private static int id[] = new int[bufsize];
    private static boolean initialized = false;
    private static int idcnt = 0;

    private static void initialize() {
	if ( ! initialized ) {
	    for ( int i=0; i<bufsize; i++ ) 
		id[i]=-1;
	    initialized = true;
	}
    }
    
    public static void add (String cid, StringBuilder message) {
	if (cid==null) return;
	initialize();
	int j=0, k=-1;
        for ( int i=0; i<bufsize; i++ ) {
    	    if ( id[i]<id[j] ) j=i;
    	    if ( id[i]>=0 && cid.equals(cids[i]) ) k=i;
    	}
    	if ( k>=0 ) {
    	    messages[k].append(message);
    	}
    	else {
    	    id[j] = idcnt;
    	    idcnt ++;
    	    messages[j] = message;
    	    cids[j] = cid;
    	}
    }

    public static StringBuilder get (String cid) {
	if (cid==null) return null;
	initialize();
        for ( int i=0; i<bufsize; i++ ) {
    	    if ( id[i]>=0 && cid.equals(cids[i]) ) {
    		id[i] = -1;
    		return messages[i];
    	    }
    	}
    	return null;
    }
}

// *****************************************************************************
// ******* NonBlockingBufferedInputStream **************************************
// *****************************************************************************
class NonBlockingBufferedInputStream extends BufferedInputStream {
    private final int timeout = 1000;
    private final int delay = 10;
    
    NonBlockingBufferedInputStream(InputStream in) {
	super(in);
    }
    
    public int read( byte[] b, int off, int len) throws IOException {
	int cnt=0, a=1;
	while ( len > 0 && a>0 ) {
	    a=available();
	    int to=0;
	    while ( a<1 && to<timeout ) {
	        try {
    	    	    Thread.sleep( delay );
    		}
		catch ( InterruptedException e) {
    		} 
    		a=available();
    		to+=delay;
    	    }
    	    if (a > len ) a=len;
    	    if ( a > 0 ) super.read(b, off, a);
    	    off+=a;
    	    len-=a;
    	    cnt+=a;
	}
	return cnt;
    }

    public void close() {
    }

}

// *****************************************************************************
// ******* SocketThread ********************************************************
// *****************************************************************************
class SocketThread extends Thread {
    private Socket socket;
    private PrintStream printer = null;
    private BufferedOutputStream binOut = null;
    private NonBlockingBufferedInputStream in = null;
    
// ******* SocketThread ********************************************************
    public SocketThread ( Socket s ) {
	socket = s;
	DeviceServer.addSocket(socket);
	start();
    }
    
// ******* out *****************************************************************
    private BufferedOutputStream binOut() throws IOException {
	if ( binOut == null ) binOut = new BufferedOutputStream( socket.getOutputStream() );
	if ( printer != null ) {
	    printer.flush();
	    printer = new PrintStream( binOut );
	}
	return binOut;
    }
    
// ******* writer **************************************************************
    private PrintStream printer() throws IOException {
	if ( printer == null ) printer = new PrintStream( binOut==null ? socket.getOutputStream() : binOut, true);
	return printer;
    }
    
// ******* printHelp ***********************************************************
    private void printHelp ( String cmd ) throws IOException  {
	boolean all = cmd.equalsIgnoreCase("all");
	PrintStream out = printer();
	boolean b = false;
	if ( all || cmd.equalsIgnoreCase("help") ) {
	    out.println( "Supported commands:\n" + 
	                 "  scan     Scan buses\n" +
	                 "  info     Print device capabilities\n" +
	                 "  upload   Upload firmware\n" +
	                 "  config   Configure FPGA\n" +
	                 "  read     Read data from given endpoint\n" +
	                 "  write    Write data to given endpoint\n" +
	                 "  errors   Returns errors\n" +
	                 "  help     Help\n" +
	                 "  quit     Quit Device Server\n" +
	                 "\n" +
	                 "See help <command>|all  for detailed info\n" );
	    b=true;
	}

	if ( all || cmd.equalsIgnoreCase("scan") ) {
	    out.println( "[<cid:>]scan [-bin]\n" + 
	                 "  (Re)scan buses and returns the device list. If <cid> and -bin are specified\n" +
	                 "  errors are stored and can be read out using \"errors <cid>\". If -bin is not\n" +
	                 "  specified errors are returned directly.\n" +
	                 "    -bin   print it in (computer friendly) binary format\n"
	                );
	    b=true;
	}

	if ( all || cmd.equalsIgnoreCase("info") ) {
	    out.println( "info <bus index> <device number>\n" + 
	                 "  Returns device capabilities.\n" 
	                );
	    b=true;
	}

	if ( all || cmd.equalsIgnoreCase("upload") ) {
	    out.println( "upload <bus index> <device number> [-v] [-nv] [-e] [-f]\n" + 
	                 "  Upload firmware to USB controller. Returns errors, if any.\n" +
	                 "    -v   upload to volatile memory (default if neither -nv nor -env is given)\n" +
	                 "    -nv  upload to non-volatile memory\n" +
	                 "    -e   erase / disable firmware in non-volatile memory\n" +
	                 "    -f   force upload of incompatible firmware\n"
	                );
	    b=true;
	}

	if ( all || cmd.equalsIgnoreCase("config") ) {
	    out.println( "config <bus index> <device number> [-v] [-nv] [-e] [-f]\n" + 
	                 "  Configure FPGA. Returns errors, if any.\n" +
	                 "    -v    upload to volatile memory (default if -nv is not given)\n" +
	                 "    -nv   upload to non-volatile memory\n" +
	                 "    -e    erase / disable bitstream in non-volatile memory\n" +
	                 "    -f    force upload if already configured\n"
	                );
	    b=true;
	}

	if ( all || cmd.equalsIgnoreCase("read") ) {
	    out.println( "[<cid>:]read <bus index> <device number> <ep> [<max. bytes>]\n" + 
	                 "  Read data from endpoint and returns them. If <max. bytes> if not specified\n" + 
	                 "  data is read until end. If <cid> is specified errors are stored and can be\n" +
	                 "  read out using \"errors <cid>\" \n"
	                );
	    b=true;
	}
	
	if ( all || cmd.equalsIgnoreCase("write") ) {
	    out.println( "write <bus number> <device number> <ep>\n" + 
	                 "  write data to endpoint. Returns errors, if any.\n"
	               );
	    b=true;
	}

	if ( all || cmd.equalsIgnoreCase("errors") ) {
	    out.println( "errors <cid>\n" + 
	                 "  Returns errors stored under <cid>.\n"
	               );
	    b=true;
	}

	if ( all || cmd.equalsIgnoreCase("quit") ) {
	    out.println( "quit\n" + 
	                 "  Quit Device Server\n"
	               );
	    b=true;
	}

	if ( ! b )  {
	    out.println( "No help available for command " + cmd + "\n");
	}
    }

// ******* str2bin *************************************************************
    private static void str2bin( String s, byte buf[], int start, int len ) {
	byte bytes[] = null;
	int l = 0;
	if ( s != null ) {
	    bytes = s.getBytes();
	    l = Math.min(bytes.length,len);
	}
	for ( int i=0; i<l; i++ )
	    buf[start+i]=bytes[i];
	for ( int i=l; i<len; i++ )
	    buf[start+i]=0;
    }

// ******* scan ****************************************************************
    private void scan ( boolean bin ) throws IOException  {
	DeviceServer.scanUSB();
	int n = DeviceServer.numberOfDevices();
	if ( bin ) {
	    byte buf[] = new byte[7+15+64+64];
	    BufferedOutputStream out = binOut();
	    if ( n>255 ) n=255;
	    out.write(n);
	    for ( int i=0; i<n; i++ ) {
		try {
		    ZtexDevice1 dev = DeviceServer.device(i);
		    buf[0] = (byte) DeviceServer.busIdx(i);
		    buf[1] = (byte) DeviceServer.devNum(i);
		    buf[2] = (byte) (dev.valid() ? 1 : 0);
		    buf[3] = (byte) dev.productId(0);
		    buf[4] = (byte) dev.productId(1);
		    buf[5] = (byte) dev.productId(2);
		    buf[6] = (byte) dev.productId(3);
		    str2bin( dev.snString(), buf,7,15);
		    str2bin( dev.manufacturerString(), buf,22,64);
		    str2bin( dev.productString(), buf,86,64);
		    out.write(buf);
		}
		catch ( IndexOutOfBoundsException e ) {
		}
	    }
	    out.flush();
	}
	else {
	    PrintStream out = printer();
	    if ( n<1 ) {
		out.println("(No devices)");
	    }
	    else {
		out.println("# <busIdx>:<devNum>	<busName>	<product ID'S>	<serial number string>	<manufacturer string>	<product name>");
	    }
	    for ( int i=0; i<n; i++ ) {
		try {
		    ZtexDevice1 dev = DeviceServer.device(i);
		    out.println(DeviceServer.busIdx(i) + ":" + DeviceServer.devNum(i)
			    + "	" + dev.dev().getBus().getDirname()
			    + ( dev.valid() ? ( "	" + ZtexDevice1.byteArrayString(dev.productId()) ) : "	(unconfigured)" )
			    + "	\"" + ( dev.snString() == null ? "" : dev.snString() ) + "\"" 
			    + "	\"" + ( dev.manufacturerString() == null ? "" : dev.manufacturerString() ) + "\"" 
			    + "	\"" + ( dev.productString() == null ? "" : dev.productString() ) + "\""  );
			    
		}
		catch ( IndexOutOfBoundsException e ) {
		}
	    }
	    
	}
    }

// ******* info ****************************************************************
    private void info ( int busIdx, int devNum ) throws IOException, Exception  {
        ZtexDevice1 dev = DeviceServer.findDevice(busIdx,devNum);
	EPDescriptorVector eps = DeviceServer.getEps(busIdx,devNum);
        if ( dev == null ) throw new Exception("Device " + busIdx + ":" + devNum + " not found");
	Ztex1v1 ztex = new Ztex1v1(dev);
        PrintStream out = printer();
	out.println("Bus name: " + dev.dev().getBus().getDirname() );
	out.println("Device Number: " + devNum );
	out.println("USB ID's: " + Integer.toHexString(dev.usbVendorId()) + ":" + Integer.toHexString(dev.usbProductId()) );
	out.println("Product ID's: " + ( dev.valid() ? ( ZtexDevice1.byteArrayString(dev.productId()) ) : "(unconfigured)" ) );
	out.println("Firmware version: " + ( dev.valid() ? (dev.fwVersion() & 255) : "" ) );
	out.println("Serial Number String: " + ( dev.snString() == null ? "" : dev.snString() ) );
	out.println("Manufacturer String: " + ( dev.manufacturerString() == null ? "" : dev.manufacturerString() ) );
	out.println("Product String: " + ( dev.productString() == null ? "" : dev.productString() ) );
	String s = ztex.capabilityInfo("\nCapability: ");
	if ( s.length()>0 ) out.println("Capability: " + s);
	if ( ztex.config != null ) {
	    out.println("ZTEX Product: " + ztex.config.getName());
	    out.println("FPGA: " + ztex.config.getFpga());
	    if (ztex.config.getRamSize()>0)  out.println("RAM: " + (ztex.config.getRamSize() >> 20) + " MByte " + ztex.config.getRamType());
	}
	s = ztex.flashInfo(); if ( s.length()>0 ) out.println("Flash: " + s);
	try {
	    s = ztex.getFpgaConfigurationStr();
	    out.println("FPGA State: " + s);
	} catch ( Exception e ) {
	}
	if ( eps!=null ) {
	    for ( int i=0; i<eps.size(); i++ ) {
		EPDescriptor ep = eps.elementAt(i);
		out.println("Endpoint: "+ep.num()+" "+(ep.in() ? "read" : "write"));
	    }
	}
    }
    
// ******* run *****************************************************************
    public void run () {
	final int bufSize = 512;
	final int maxArgs = 32;
	
	byte buf[] = new byte[bufSize];
	String args[] = new String[maxArgs];
	int bufN=0, argsN=0;
	String cid="", cid2=null;
	boolean noErrors = false;
	
	try {
	    in = new NonBlockingBufferedInputStream( socket.getInputStream() );
	    
	    // read command and args	    
	    int b = 0;
	    do {
		b = in.read();
		if ( b <= 32 ) {
		    if ( bufN > 0 ) {
			if ( argsN >= maxArgs ) throw new Exception("Error reading command: Argument buffer overflow");
			args[argsN] = new String(buf,0,bufN);
			argsN+=1;
			bufN=0;
		    }
		}
		else {
	    	    if ( bufN >= bufSize ) throw new Exception("Error reading command: Buffer overflow");
		    buf[bufN] = (byte) b;
		    bufN+=1;
		}
	    } while (b!=10 && b>0);
	    
	    if ( argsN == 0 ) throw new Exception ("Command missed");
	}
	catch (Exception e) {
//	    DeviceServer.error("Error: "+e.getLocalizedMessage() );
	    try {
		printer().println("Error: "+e.getLocalizedMessage());
	    }
	    catch (IOException f) {
    		DeviceServer.error("Error: "+e.getLocalizedMessage() );
    	    }
	}  
	    
	StringBuilder messages = new StringBuilder();
	if ( args[0].indexOf(':') > 0 ) {
	    int i = args[0].lastIndexOf(':');
	    cid = args[0].substring(0,i);
	    args[0] = args[0].substring(i+1);
	}

	// process commands
	try {
	    // quit
	    if ( args[0].equalsIgnoreCase("quit") ) {
		DeviceServer.quit = true;
	    }
	    // help [<command>]
	    else if ( args[0].equalsIgnoreCase("help") ) {
		if ( argsN < 2 ) printHelp("help");
		for ( int i=1; i<argsN; i++ ) {
	    	    printHelp( args[i] );
		}
	    }
	    // [<cid>:]scan [-bin]
	    else if ( args[0].equalsIgnoreCase("scan") ) {
		if ( argsN > 2 ) throw new Exception("scan: to much parameters" );
		if ( argsN==2 && ! args[1].equalsIgnoreCase("-bin") ) throw new Exception("scan: invalid parameter: " + args[1] );
		if ( argsN == 2 ) noErrors = true;
		scan( argsN==2 );
	    }
	    // info <bus index> <device number>
	    else if ( args[0].equalsIgnoreCase("info") ) {
		if ( argsN !=3 ) throw new Exception("info: invalid number of parameters" );
		info( Integer.valueOf(args[1]), Integer.valueOf(args[2]) );
	    }
	    // upload <bus index> <device number> [-v] [-nv] [-e] [-f] 
	    // config <bus index> <device number> [-v] [-nv] [-e] [-f]
	    else if ( args[0].equalsIgnoreCase("upload") || args[0].equalsIgnoreCase("config") ) {
		if ( argsN<3 ) throw new Exception(args[0]+": to less parameters" );
		boolean vola=false, nonvola=false, erase=false, force=false;
		for ( int i=3; i<argsN; i++) {
		    if ("-v".equalsIgnoreCase(args[i])) vola=true;
		    else if ("-nv".equalsIgnoreCase(args[i])) nonvola=true;
		    else if ("-e".equalsIgnoreCase(args[i])) erase=true;
		    else if ("-f".equalsIgnoreCase(args[i])) force=true;
		    else throw new Exception("Invalid parameter: "+args[i]);
		}
		int busIdx=Integer.valueOf(args[1]);
		int devNum=Integer.valueOf(args[2]);
		ZtexDevice1 dev = DeviceServer.findDevice(busIdx, devNum);
    		if ( dev == null ) throw new Exception("Device " + busIdx + ":" + devNum + " not found");
		Ztex1v1 ztex = new Ztex1v1(dev);
		
		if ( args[0].equalsIgnoreCase("upload")) {
		    DeviceServer.loadFirmware ( ztex, messages, in, IPPermissions.toString( socket.getInetAddress() ), force, vola, nonvola, erase );
	    	    int ndn = ztex.dev().dev().getDevnum();
		    if ( ndn != devNum ) {
			messages.append("Device re-numerated: " + busIdx + ":" + devNum + " -> " + busIdx + ":" + ndn + "\n");
			DeviceServer.scanUSB();
		    }
		}
		else {
		    DeviceServer.loadBitstream ( ztex, messages, in, IPPermissions.toString( socket.getInetAddress() ), force, vola, nonvola, erase );
		}
	    }
	    // write <bus number> <device number> <ep> 
	    else if ( args[0].equalsIgnoreCase("write") ) {
		if ( argsN !=4 ) throw new Exception("write: invalid number of parameters" );
		int busIdx=Integer.valueOf(args[1]);
		int devNum=Integer.valueOf(args[2]);
		ZtexDevice1 dev = DeviceServer.findDevice(busIdx, devNum);
    		if ( dev == null ) throw new Exception("Device " + busIdx + ":" + devNum + " not found");
    		Ztex1v1 ztex = new Ztex1v1(dev);
		EPDescriptorVector eps = DeviceServer.getEps(busIdx,devNum);
		try {
		    DeviceServer.epUpload (ztex, eps.find(Integer.valueOf(args[3])), in, messages);
		}
		finally {
		    DeviceServer.release(ztex);
		}
	    }
	    // [<cid>:]read <bus index> <device number> <ep> [<max. bytes>]
	    else if ( args[0].equalsIgnoreCase("read") ) {
		noErrors = true;
		if ( argsN<4 || argsN>5 ) throw new Exception("read: invalid number of parameters" );
		int busIdx=Integer.valueOf(args[1]);
		int devNum=Integer.valueOf(args[2]);
		ZtexDevice1 dev = DeviceServer.findDevice(busIdx, devNum);
    		if ( dev == null ) throw new Exception("Device " + busIdx + ":" + devNum + " not found");
    		Ztex1v1 ztex = new Ztex1v1(dev);
		EPDescriptorVector eps = DeviceServer.getEps(busIdx,devNum);
		int max_size = argsN==5 ? Integer.valueOf(args[4]) : Integer.MAX_VALUE;
		try {
		    DeviceServer.epDownload (ztex, eps.find(Integer.valueOf(args[3])), binOut(), max_size, messages);
		    binOut.flush();
		}
		finally {
		    DeviceServer.release(ztex);
		}
	    }
	    // error <cid>
	    else if ( args[0].equalsIgnoreCase("errors") ) {
		cid2 = cid;
		cid = null;
		if ( argsN > 2 ) throw new Exception("errors: to much parameters" );
		if ( argsN == 2 ) cid2 = args[1];
		messages = ErrorBuffer.get(cid2);
		if (messages != null) printer().print( messages );
		messages = new StringBuilder();
	    }
	    else {
		throw new Exception("Invalid command: "+args[0] );
	    }
	} 
	catch ( IOException e) {
	    DeviceServer.error("Error: "+e.getLocalizedMessage() );
	}  
	catch (NumberFormatException e) {
	    messages.append("Error: Number expected: "+e.getLocalizedMessage()+"\n");
	}  
	catch (Exception e) {
	    messages.append("Error: "+e.getLocalizedMessage()+"\n");
	}  
	
	try {
	    if ( messages != null && messages.length()>0 ) {
		if ( ! noErrors ) printer().print(messages);
		ErrorBuffer.add(cid,messages);
	    }
	}
	catch ( IOException e) {
	    DeviceServer.error("Error2: "+e.getLocalizedMessage() );
	}  
	    

	try {
	    socket.getInputStream().close();
    	}
	catch (Exception e) {
	    DeviceServer.error("Error closing input stream: "+e.getLocalizedMessage() );
	}  

	try {
	    if ( binOut!=null ) binOut.close();
	    else if ( printer != null ) printer.close();
	}
	catch (Exception e) {
	    DeviceServer.error("Error closing output stream: "+e.getLocalizedMessage() );
	}
	  
	DeviceServer.removeSocket(socket);
	try {
	    socket.close();
	}
	catch (Exception e) {
	    DeviceServer.error("Error closing output socket: "+e.getLocalizedMessage() );
	}
    }
}


// *****************************************************************************
// ******* MultipartFormDataReader ********************************************
// *****************************************************************************
class MultipartFormDataReader {
    private final byte eol[] = { 13, 10 };
    private InputStream in;
    private byte sep[] = null;
    private boolean eof = false;
    public String name = "";
    public String fileName = "";
    
// ******* readTo **************************************************************
    private boolean readTo ( OutputStream out, byte s[] ) {
	byte buf[] = new byte[s.length];
	int eq = 0;
	while ( eq<s.length && !eof ) {
	    int i = 0;
	    try {
	        i = in.read();
		eof = i<0;
	    }
	    catch ( IOException e ) {
		eof = true;
	    }
	    if ( !eof ) {
		buf[eq] = (byte) i;
		if ( buf[eq] == s[eq] ) {
		    eq++;
		}
		else {
		    try {
			if ( out != null ) out.write(buf,0,eq+1);
		    }
		    catch ( IOException e ) {
		    }
		    eq=0;
		}
	    }
	}
	return !eof;
    }

// ******* MultiPartFormDataReader *********************************************
    MultipartFormDataReader ( InputStream in_ ) {
	in = in_;
	do {
	    try {
		if ( in.read() == 45 && in.read() == 45 ) {
		    ByteArrayOutputStream buf = new ByteArrayOutputStream();
		    buf.write(eol,0,eol.length);
		    buf.write(45);
		    buf.write(45);
		    readTo( buf, eol );
		    sep = buf.toByteArray();
//		    System.out.println("sep: -->" + new String(sep) + "<--");
		}
		else {
		    readTo( null, eol );
		}
	    } 
	    catch ( IOException e ) {
		eof = true;
	    }
	} while ( sep == null && !eof );
    }

// ******* readField ***********************************************************
    public boolean readField ( OutputStream data ) {	
	if ( sep == null ) return false;
	ByteArrayOutputStream lineBuf = new ByteArrayOutputStream();
	String line;
	name = "";
	fileName = "";
	do {
	    readTo ( lineBuf, eol );
	    line = lineBuf.toString();
//	    System.out.println("line: "+line);
	    int i=0;
	    while ( i<line.length() && line.codePointAt(i) <= 32 ) i++;
	    if ( line.length()>=i+19 && line.substring(i,i+19).equalsIgnoreCase("Content-Disposition") ) {
		String tokens[] = line.split(";");
		for ( int j=1; j<tokens.length; j++ ) {
		    String t = tokens[j];
		    i=0;
		    while ( t.codePointAt(i) <= 32 && i < t.length() ) i++;
		    String s=t.substring(i,i+5);
		    if ( s.equalsIgnoreCase("name ") || s.equalsIgnoreCase("name=") ) {
			int a = t.indexOf("\"");
			int z = t.lastIndexOf("\"");
			if ( a>0 && z>a ) name=t.substring(a+1,z);
		    }
		    s=t.substring(i,i+9);
		    if ( s.equalsIgnoreCase("filename ") || s.equalsIgnoreCase("filename=") ) {
			int a = t.indexOf("\"");
			int z = t.lastIndexOf("\"");
			if ( a>0 && z>a ) fileName=t.substring(a+1,z);
		    }
		}
//		System.out.println("name: "+name);
//		System.out.println("filename: "+fileName);
	    }
	    lineBuf.reset();
	} while ( line.length()>0 && !eof );
	if ( ! eof ) readTo( data, sep );
	boolean result = !eof;
	try {
	    in.read();
	    in.read();
	}
        catch ( IOException e ) {
	    eof = true;
	}
	return result;
    }
}


// *****************************************************************************
// ******* ZtexHttpHandler *****************************************************
// *****************************************************************************
class ZtexHttpHandler implements HttpHandler {

// ******* htmlHeader **********************************************************
    private StringBuilder htmlHeader ( String title )  {
	StringBuilder sb = new StringBuilder();
	sb.append("<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\n");
	sb.append("<html>\n");
	sb.append("<head>\n");
	sb.append("  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">\n");
	sb.append("  <meta http-equiv=\"Content-Language\" content=\"en\">\n");
	sb.append("  <meta name=\"author\" content=\"ZTEX GmbH\">\n");
	sb.append("<title>" + title + "</title>\n");
	sb.append("<style type=\"text/css\">\n");
	sb.append("body { background-color:#f0f0f0; color:#202020; font-family:Helvetica,Helv,sans-serif; font-size:11pt}\n");
	sb.append("a:link { color:#2020a0; }\n");
	sb.append("a:visited { color:#a02020; }\n");
	sb.append("a:active { color:#208020; }\n");
	sb.append("a.topmenu { color:#ffffff; font-size:12pt; text-decoration:none; font-weight:bold }\n");
	sb.append("a.topmenu:link { color:#ffffff; }\n");
	sb.append("a.topmenu:visited { color:#ffffff; }\n");
	sb.append("a.topmenu:hover { color:#202020; }\n");
	sb.append("</style>\n");
	sb.append("</head>\n");
	sb.append("<body>\n");
	sb.append("<center><table border=0 bgcolor=\"#7870a0\" cellpadding=2 cellspacing=0><tr><td>\n");
	sb.append("<table border=0 bgcolor=\"#eae6ff\" cellpadding=5 cellspacing=10>\n");
	sb.append("  <tr><th bgcolor=\"#cac4ec\">\n");
	sb.append("    <span style=\"font-size:125%\">" + title + "</span>\n");
	sb.append("  </th></tr>\n");
	sb.append("  <tr><td align=center>\n");
        return sb;
    }

// ******* heading *************************************************************
    private StringBuilder heading ( StringBuilder sb, String s )  { 
	sb.append ( "</td></tr>\n");
	sb.append("  <tr><th bgcolor=\"#cac4ec\">\n");
	sb.append("    <span style=\"font-size:125%\">" + s + "</span>\n");
	sb.append("  </th></tr>\n");
	sb.append("  <tr><td align=center>\n");
	return sb;
    }
  
// ******* htmlConvert *********************************************************
    private byte[] htmlConvert ( StringBuilder sb )  { 
	sb.append ( "</td></tr>\n");
	sb.append ( "</table>\n");
	sb.append ( "</td></tr></table><center>\n");
	sb.append ( "<p>\n");
	sb.append ( "<hr>\n");
	sb.append ( "<center>\n");
	sb.append ( "  <a href=\"http://www.ztex.de/\">[ZTEX Homepage]</a>&nbsp;\n");
	sb.append ( "  <a href=\"http://wiki.ztex.de/\">[ZTEX Wiki]</a>&nbsp;\n");
	sb.append ( "  <span style=\"font-size:80%\">&#169; ZTEX GmbH</span>\n");
	sb.append ( "</center>\n");
	sb.append ( "</body></html>" );
	return sb.toString().getBytes();
    }
    
// ******* test ****************************************************************
    private byte[] test (HttpExchange t) throws IOException {
	InputStream in = new BufferedInputStream( t.getRequestBody() );
	System.out.println("Request Body: " + in.available() + "Bytes");
	int i;
	do {
	    i = in.read();
	    if ( i>=0 ) System.out.print((char)i);
	} while (i>=0);

	Headers h = t.getResponseHeaders();
        h.add("Content-Type", "text/html;Charset=iso-8859-1");
	StringBuilder sb = htmlHeader ("Test");
	sb.append ("<form action=\"test\" method=\"post\" enctype=\"multipart/form-data\">\n");
	sb.append ("  <p>W&auml;hlen Sie eine Textdatei (txt, html usw.) von Ihrem Rechner aus:<br>\n");
	sb.append ("    <input name=\"Datei\" type=\"file\" size=\"50\" maxlength=\"100000\" >\n");
	sb.append ("  </p>\n");
        sb.append ("  <input type=\"checkbox\" name=\"upload_to\" value=\"v\">Volatile Memory &nbsp;&nbsp;&nbsp;&nbsp;\n");
        sb.append ("  <input type=\"checkbox\" name=\"upload_to\" value=\"v\">Non-Volatile Memory &nbsp;&nbsp;&nbsp;&nbsp;\n");
        sb.append ("  <input type=\"submit\" value=\"Submit\">\n");
	sb.append ("</form>\n");

	return htmlConvert(sb);
    }

// ******* test2 ***************************************************************
    private byte[] test2 (HttpExchange t) throws IOException {
	MultipartFormDataReader form = new MultipartFormDataReader( new BufferedInputStream( t.getRequestBody() ) );
	ByteArrayOutputStream data = new ByteArrayOutputStream();
	while ( form.readField( data ) ) { 
	    System.out.println( "Name=\"" + form.name + "\"" );
	    System.out.println( "Filename=\"" + form.fileName + "\"" );
	    System.out.println( "Data -->" + data + "<--" );
	    data.reset();
	}

	Headers h = t.getResponseHeaders();
        h.add("Content-Type", "text/html;Charset=iso-8859-1");
	StringBuilder sb = htmlHeader ("Test2");
	sb.append ("<form action=\"test2\" method=\"post\" enctype=\"multipart/form-data\">\n");
	sb.append ("  <p>W&auml;hlen Sie eine Textdatei (txt, html usw.) von Ihrem Rechner aus:<br>\n");
	sb.append ("    <input name=\"Datei\" type=\"file\" size=\"50\" maxlength=\"100000\" >\n");
	sb.append ("  </p>\n");
        sb.append ("  <input type=\"checkbox\" name=\"upload_to\" value=\"v\">Volatile Memory &nbsp;&nbsp;&nbsp;&nbsp;\n");
        sb.append ("  <input type=\"checkbox\" name=\"upload_to\" value=\"nv\">Non-Volatile Memory &nbsp;&nbsp;&nbsp;&nbsp;\n");
        sb.append ("  <input type=\"submit\" value=\"Submit\">\n");
	sb.append ("</form>\n");

	return htmlConvert(sb);
    }

// ******* scan ****************************************************************
    private byte[] scan (HttpExchange t) {
	DeviceServer.scanUSB();
	int n = DeviceServer.numberOfDevices();
	Headers h = t.getResponseHeaders();
        h.add("Content-Type", "text/html;Charset=iso-8859-1");
	StringBuilder sb = htmlHeader ("Device overview");
	sb.append ("<table border=\"0\" bgcolor=\"#808080\" cellspacing=1 cellpadding=4>\n");
	sb.append ("  <tr>\n");
	sb.append ("    <td align=center bgcolor=\"#e0e0e0\">Device Link / <br> &lt;Bus Index&gt;:&lt;Device Number&gt;</td>\n");
	sb.append ("    <td align=center bgcolor=\"#e0e0e0\">Bus Name</td>\n");
	sb.append ("    <td align=center bgcolor=\"#e0e0e0\">Product ID's</td>\n");
	sb.append ("    <td align=center bgcolor=\"#e0e0e0\">Serial Number String</td>\n");
	sb.append ("    <td align=center bgcolor=\"#e0e0e0\">Manufacturer String</td>\n");
	sb.append ("    <td align=center bgcolor=\"#e0e0e0\">Product String</td>\n");
	sb.append ("  </tr>\n");
	if ( n<1 ) {
	    sb.append("<tr><td align=center bgcolor=\"#f0f0f0\" colspan=6>(No devices)</td>");
        } else {
	    for ( int i=0; i<n; i++ ) {
		try {
		    ZtexDevice1 dev = DeviceServer.device(i);
		    sb.append("    <tr>\n");
		    sb.append("    <td align=center bgcolor=\"#f0f0f0\"><a href=\"" + DeviceServer.busIdx(i) + ":" + DeviceServer.devNum(i) + "\">" + DeviceServer.busIdx(i) + ":" + DeviceServer.devNum(i) + "</a></td>\n");
		    sb.append("    <td align=center bgcolor=\"#f0f0f0\">" + dev.dev().getBus().getDirname() + "</td>\n");
		    sb.append("    <td align=center bgcolor=\"#f0f0f0\">" + ( dev.valid() ? ( ZtexDevice1.byteArrayString(dev.productId()) ) : "(unconfigured)" ) + "</td>\n");
		    sb.append("    <td align=center bgcolor=\"#f0f0f0\">" + ( dev.snString() == null ? "" : dev.snString() ) + "</td>\n");
		    sb.append("    <td align=center bgcolor=\"#f0f0f0\">" + ( dev.manufacturerString() == null ? "" : dev.manufacturerString() ) + "</td>\n");
		    sb.append("    <td align=center bgcolor=\"#f0f0f0\">" + ( dev.productString() == null ? "" : dev.productString() ) + "</td>\n");
		    sb.append("  </tr>\n");
		}
		catch ( IndexOutOfBoundsException e ) {
		}
	    }
        }
	sb.append ("</table>\n");
	sb.append ("<p>\n");
	sb.append ("<a href=\"/scan\"><button>Re-Scan</button></a>\n");
	return htmlConvert(sb);
    }

// ******* device **************************************************************
    private byte[] device ( HttpExchange t, int busIdx, int devNum, int epnum, ZtexDevice1 dev ) {

	StringBuilder messages = new StringBuilder();
	EPDescriptorVector eps = DeviceServer.getEps(busIdx,devNum);
	Headers h = t.getResponseHeaders();
    
	// ***********
	// * request *
	// ***********
	boolean fw_force = false;
	boolean fw_upload_v = false;
	boolean fw_upload_nv = false;
	boolean fw_erase = false;
	ByteArrayInputStream fw_data = null;
	String fw_data_name = null;

	boolean bs_force = false;
	boolean bs_upload_v = false;
	boolean bs_upload_nv = false;
	boolean bs_erase = false;
	byte bs_data[] = null;
	String bs_data_name = null;

	ByteArrayInputStream ep_data = null;
	String ep_data_name = null;
	int ep_data_num = -1;
	int ep_down_size = -1;
		
	MultipartFormDataReader form = new MultipartFormDataReader( new BufferedInputStream( t.getRequestBody() ) );
	ByteArrayOutputStream data = new ByteArrayOutputStream();
	while ( form.readField( data ) ) { 
/*	    System.out.println( "Name=\"" + form.name + "\"" );
	    System.out.println( "Filename=\"" + form.fileName + "\"" );
	    System.out.println( "Data -->" + data + "<--" ); */
	    if ( data.size()>0 ) {
		if ( form.name.equalsIgnoreCase("fw_force" ) ) fw_force=true;
		else if ( form.name.equalsIgnoreCase("fw_upload_v" ) ) fw_upload_v=true;
		else if ( form.name.equalsIgnoreCase("fw_upload_nv" ) ) fw_upload_nv=true;
		else if ( form.name.equalsIgnoreCase("fw_erase" ) ) fw_erase=true;
		else if ( form.name.equalsIgnoreCase("fw_data" ) ) {
		    fw_data = new ByteArrayInputStream(data.toByteArray());
		    fw_data_name = IPPermissions.toString( t.getRemoteAddress().getAddress() ) + ":" + form.fileName;
		}
		else if ( form.name.equalsIgnoreCase("bs_force" ) ) bs_force=true;
		else if ( form.name.equalsIgnoreCase("bs_upload_v" ) ) bs_upload_v=true;
		else if ( form.name.equalsIgnoreCase("bs_upload_nv" ) ) bs_upload_nv=true;
		else if ( form.name.equalsIgnoreCase("bs_erase" ) ) bs_erase=true;
		else if ( form.name.equalsIgnoreCase("bs_data" ) ) {
		    bs_data = data.toByteArray();
		    bs_data_name = IPPermissions.toString( t.getRemoteAddress().getAddress() ) + ":" + form.fileName;
		}
		else if ( form.name.equalsIgnoreCase("ep_down_size" ) ) {
		    try {
			ep_down_size = Integer.valueOf(data.toString());
		    }
		    catch (Exception e) {
			ep_down_size = -1;
		    }
//		    System.out.println(ep_down_size);
		}
		else {
		    for ( int i=0; eps!=null && i<eps.size(); i++ ) {
			EPDescriptor ep = eps.elementAt(i);
			if ( ! ep.in() && form.name.equalsIgnoreCase("ep_"+ep.num()+"_data" ) ) {
			    ep_data = new ByteArrayInputStream(data.toByteArray());
			    ep_data_name = IPPermissions.toString( t.getRemoteAddress().getAddress() ) + ":" + form.fileName;
			    ep_data_num = ep.num();
			}
		    }
		}
		data.reset();
	    }
	}

	// **********
	// * action *
	// **********
	Ztex1v1 ztex = null;
	try {
	    ztex = new Ztex1v1(dev);
	} catch ( Exception e ) {
	    ztex = null;
	    messages.append( "Error: " + e.getLocalizedMessage() + "\n");
	}
	
	int oldDevNum = devNum;
	try { 
	    DeviceServer.loadFirmware ( ztex, messages, fw_data, fw_data_name, fw_force, fw_upload_v, fw_upload_nv, fw_erase );
	    if ( ztex != null ) {
		devNum = ztex.dev().dev().getDevnum();
		if ( devNum != oldDevNum ) {
		    messages.append("Device re-numerated: " + busIdx + ":" + oldDevNum + " -> " + busIdx + ":" + devNum + "\n");
		    DeviceServer.scanUSB();
		    eps = DeviceServer.getEps(busIdx,devNum);
		}
	    }
	} catch ( Exception e ) {
	    messages.append( "Error: " + e.getLocalizedMessage() + '\n' );
	}

	try { 
	    if ( ztex != null ) DeviceServer.loadBitstream ( ztex, messages, bs_data, bs_data_name, bs_force, bs_upload_v, bs_upload_nv, bs_erase );
	} catch ( Exception e ) {
	    messages.append( "Error: " + e.getLocalizedMessage() + '\n' );
	}

	try { 
	    if ( ep_data != null ) DeviceServer.epUpload (ztex, eps.find(ep_data_num), ep_data, messages);
	} catch ( Exception e ) {
	    messages.append( "Error: " + e.getLocalizedMessage() + '\n' );
	}

	try { 
	    if ( epnum>0 ){
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		DeviceServer.epDownload (ztex, eps.find(epnum), out, ep_down_size, messages);
		h.add("Content-Type", "application/octet-stream");
		return out.toByteArray();
	    }
	} catch ( Exception e ) {
	    messages.append( "Error: " + e.getLocalizedMessage() + '\n' );
	}
	
	DeviceServer.release (ztex);
	
	// ************
	// * response *
	// ************
        h.add("Content-Type", "text/html;Charset=iso-8859-1");
	StringBuilder sb = htmlHeader ("Device " + busIdx + ":" + devNum + ( devNum!=oldDevNum ? ( " (was " + busIdx + ":" + oldDevNum +")" ) : "" ) );

	// info	
	sb.append ("<table border=\"0\" bgcolor=\"#808080\" cellspacing=1 cellpadding=4>\n");
	sb.append("  <tr><td align=left bgcolor=\"#e0e0e0\"> Bus name: </td><td align=left bgcolor=\"#f0f0f0\">" + dev.dev().getBus().getDirname() + "</td></tr>\n");
	sb.append("  <tr><td align=left bgcolor=\"#e0e0e0\"> Device Number: </td><td align=left bgcolor=\"#f0f0f0\">" + devNum + "</td></tr>\n");
	sb.append("  <tr><td align=left bgcolor=\"#e0e0e0\"> USB ID's: </td><td align=left bgcolor=\"#f0f0f0\">" + Integer.toHexString(dev.usbVendorId()) + ":" + Integer.toHexString(dev.usbProductId()) + "</td></tr>\n");
	sb.append("  <tr><td align=left bgcolor=\"#e0e0e0\"> Product ID's: </td><td align=left bgcolor=\"#f0f0f0\">" + ( dev.valid() ? ( ZtexDevice1.byteArrayString(dev.productId()) ) : "(unconfigured)" ) + "</td></tr>\n");
	sb.append("  <tr><td align=left bgcolor=\"#e0e0e0\"> Firmware version: </td><td align=left bgcolor=\"#f0f0f0\">" + ( dev.valid() ? (dev.fwVersion() & 255) : "" ) + "</td></tr>\n");
	sb.append("  <tr><td align=left bgcolor=\"#e0e0e0\"> Serial Number String: </td><td align=left bgcolor=\"#f0f0f0\">" + ( dev.snString() == null ? "" : dev.snString() ) + "</td></tr>\n");
	sb.append("  <tr><td align=left bgcolor=\"#e0e0e0\"> Manufacturer String: </td><td align=left bgcolor=\"#f0f0f0\">" + ( dev.manufacturerString() == null ? "" : dev.manufacturerString() ) + "</td></tr>\n");
	sb.append("  <tr><td align=left bgcolor=\"#e0e0e0\"> Product String: </td><td align=left bgcolor=\"#f0f0f0\">" + ( dev.productString() == null ? "" : dev.productString() ) + "</td></tr>\n");
	if ( ztex != null ) {
	    String s = ztex.capabilityInfo(", ");
	    if ( s.length()>0 ) sb.append("  <tr><td align=left bgcolor=\"#e0e0e0\"> Capabilities: </td><td align=left bgcolor=\"#f0f0f0\">" + s + "</td></tr>\n");
	    if ( ztex.config != null ) {
		sb.append("  <tr><td align=left bgcolor=\"#e0e0e0\"> ZTEX Product: </td><td align=left bgcolor=\"#f0f0f0\">" + ztex.config.getName() + "</td></tr>\n");
		sb.append("  <tr><td align=left bgcolor=\"#e0e0e0\"> FPGA: </td><td align=left bgcolor=\"#f0f0f0\">" + ztex.config.getFpga() + "</td></tr>\n");
		if (ztex.config.getRamSize()>0) sb.append("  <tr><td align=left bgcolor=\"#e0e0e0\"> RAM: </td><td align=left bgcolor=\"#f0f0f0\">" + (ztex.config.getRamSize() >> 20) + " MByte " + ztex.config.getRamType() + "</td></tr>\n");
		s = ztex.flashInfo(); if ( s.length()>0 ) sb.append("  <tr><td align=left bgcolor=\"#e0e0e0\"> Flash: </td><td align=left bgcolor=\"#f0f0f0\">" + s + "</td></tr>\n");
	    }
	    try {
		s = ztex.getFpgaConfigurationStr();
		sb.append("  <tr><td align=left bgcolor=\"#e0e0e0\"> FPGA State: </td><td align=left bgcolor=\"#f0f0f0\">" + s + "</td></tr>\n");
	    } catch ( Exception e ) {
	    }
	}
	sb.append ("</table>\n");
        sb.append ("<p><a href=\"/\"><button>Device Overview</button></a>\n");

	// firmware
	heading(sb,"Firmware Upload");
	sb.append ("<form action=\"" + busIdx + ":" + devNum + "\" method=\"post\" enctype=\"multipart/form-data\">\n");
	sb.append ("  <div align=left>\n");
	sb.append ("    Firmware file: <input name=\"fw_data\" type=\"file\" size=\"70\" accept=\".ihx\" maxlength=\"5000000\"><p>\n");
        sb.append ("  	<input type=\"checkbox\" name=\"fw_upload_v\" value=\"x\" " + ( fw_upload_v ? "checked" : "" ) + ">Upload to volatile Memory &nbsp;&nbsp;&nbsp;&nbsp;\n");
//        try {
//    	    if ( ztex != null ) {
//		ztex.checkCapability(ztex.CAPABILITY_EEPROM);
    		sb.append ("    <input type=\"checkbox\" name=\"fw_upload_nv\" value=\"x\"" + ( fw_upload_nv ? "checked" : "" ) + ">Upload to non-Volatile Memory &nbsp;&nbsp;&nbsp;&nbsp;\n");
    		sb.append ("    <input type=\"checkbox\" name=\"fw_erase\" value=\"x\"" + ( fw_erase ? "checked" : "" ) + ">Erase firmware in non-volatile memory");
//    	    }
//    	}
//    	catch ( Exception a ) {
//    	}
        sb.append ("    <input type=\"checkbox\" name=\"fw_force\" value=\"x\"" + ( fw_force ? "checked" : "" ) + ">Enforce upload<p>");
	sb.append ("    (Before firmware can be loaded into non-volatile memory some firmware must be installed in volatile memory.)<p>\n");
	sb.append ("  </div>\n");
        sb.append ("  <input type=\"submit\" value=\"Submit\">\n");
        sb.append ("</form>\n");

	// bitstream
	try {
	    if ( ztex == null ) throw new Exception();
	    ztex.checkCapability(ztex.CAPABILITY_FPGA);
	    heading(sb,"Bitstream Upload");
	    sb.append ("<form action=\"" + busIdx + ":" + devNum + "\" method=\"post\" enctype=\"multipart/form-data\">\n");
	    sb.append ("  <div align=left>\n");
	    sb.append ("    Bitstream file: <input name=\"bs_data\" type=\"file\" size=\"70\" accept=\".ihx\" maxlength=\"5000000\"><p>\n");
    	    sb.append ("  	<input type=\"checkbox\" name=\"bs_upload_v\" value=\"x\" " + ( bs_upload_v ? "checked" : "" ) + ">Upload to volatile Memory &nbsp;&nbsp;&nbsp;&nbsp;\n");
    	    try {
    		if ( ztex != null && ztex.flashEnabled() ) {
    		    sb.append ("    <input type=\"checkbox\" name=\"bs_upload_nv\" value=\"x\"" + ( bs_upload_nv ? "checked" : "" ) + ">Upload to non-Volatile Memory &nbsp;&nbsp;&nbsp;&nbsp;\n");
    		    sb.append ("    <input type=\"checkbox\" name=\"bs_erase\" value=\"x\"" + ( bs_erase ? "checked" : "" ) + ">Erase bitstream in non-volatile memory");
    		}
    	    }
    	    catch ( Exception a ) {
    	    }
    	    sb.append ("    <input type=\"checkbox\" name=\"bs_force\" value=\"x\"" + ( bs_force ? "checked" : "" ) + ">Enforce upload<p>");
	    sb.append ("  </div>\n");
    	    sb.append ("  <input type=\"submit\" value=\"Submit\">\n");
    	    sb.append ("</form>\n");
    	}
        catch ( Exception a ) {
        }

	// endpoints
	if ( eps!=null && eps.size()>0) {
	    heading(sb,"Endpoints");
	    sb.append ("<table border=\"0\" bgcolor=\"#808080\" cellspacing=1 cellpadding=12>\n");
	    for (int i=0; i<eps.size(); i++ ) {
		EPDescriptor ep = eps.elementAt(i);
		if ( ep.in() ) {
		    sb.append("  <tr><td align=left bgcolor=\"#e0e0e0\"> IN EP " + ep.num() +":</td>  <td align=left bgcolor=\"#f0f0f0\">" 
			+ "<form action=\"" + busIdx + ":" + devNum + ":" + ep.num() + "\" method=\"post\" enctype=\"multipart/form-data\">"
			+ "Maximum size: <input type=\"text\" name=\"ep_down_size\" value=\"1000000\" size=12 maxlength=11>" 
		        + "&nbsp;&nbsp;&nbsp;&nbsp;<input type=\"submit\" value=\"Download\">"
			+ "</form></td></tr>\n" );
		} else {
		    sb.append("  <tr><td align=left bgcolor=\"#e0e0e0\"> OUT EP " + ep.num() +":</td>  <td align=left bgcolor=\"#f0f0f0\">" 
			+ "<form action=\"" + busIdx + ":" + devNum + "\" method=\"post\" enctype=\"multipart/form-data\">"
			+ "File: <input name=\"ep_"+ep.num()+"_data\" type=\"file\" size=\"60\" accept=\"\" maxlength=\"50000000\">"
		        + "&nbsp;&nbsp;&nbsp;&nbsp;<input type=\"submit\" value=\"Upload\">"
			+ "</form></td></tr>\n" );
		}
	    }
	    sb.append ("</table>\n");
	}

	// messages
	if ( messages.length() > 0 ) {
	    heading(sb,"Messages");
	    sb.append ("<div align=left><pre>\n");
	    sb.append(messages);
	    sb.append ("</pre></div>");
	}

	return htmlConvert(sb);
    }

// ******* handle **************************************************************
    public void handle(HttpExchange t) throws IOException {
	String path = t.getRequestURI().getPath();
	int responseCode = 200;
	byte buf[] = {};
	if ( path.charAt(0) != '/' ) path = '/' + path;
	int rcvd = t.getRequestBody().available();

	if ( ! DeviceServer.httpPermissions().checkAddress( t.getRemoteAddress().getAddress() ) ) {
	    responseCode = 400;
	    StringBuilder sb = htmlHeader ("400 Bad Request");
	    sb.append("Access denied" );
	    buf = htmlConvert(sb);
	}
/*	else if ( path.equalsIgnoreCase("/test") ) {
	    buf = test(t);
	}
	else if ( path.equalsIgnoreCase("/test2") ) {
	    buf = test2(t);
	} */
	else if ( path.equalsIgnoreCase("/") || path.equalsIgnoreCase("/scan") ) {
	    buf = scan(t);
	}
	else if ( path.indexOf(':') > 0 ) {
	    try {
		int i = path.indexOf(':');
		int j = path.lastIndexOf(':');
		if (j<=i) j=path.length();
		int busIdx = Integer.valueOf(path.substring(1,i));
		int devNum = Integer.valueOf(path.substring(i+1,j ));
		int epNum = j < path.length() ? Integer.valueOf(path.substring(j+1)) : -1;
	        ZtexDevice1 dev = DeviceServer.findDevice(busIdx,devNum);
	        if ( dev == null ) throw new Exception();
	        buf = device(t, busIdx, devNum, epNum, dev);
    	    }
    	    catch ( Exception e ) {
		responseCode = 400;
		StringBuilder sb = htmlHeader ("400 Bad Request");
		sb.append("Invalid device path: " + path );
	        sb.append ("<p>\n");
		sb.append ("<a href=\"/\"><button>Device Overview</button></a>\n");
		buf = htmlConvert(sb);
    	    }
	}
	else {
	    responseCode = 404;
	    StringBuilder sb = htmlHeader ("404 Not Found");
	    sb.append("Invalid path: " + path );
	    sb.append ("<p>\n");
	    sb.append ("<a href=\"/\"><button>Device Overview</button></a>\n");
	    buf = htmlConvert(sb);
	}
        DeviceServer.info( "Connection from " + IPPermissions.toString( t.getRemoteAddress().getAddress() ) + ": " + path + ": " + responseCode + ": received " + rcvd + " bytes,  sent " + buf.length + " bytes" );
        t.sendResponseHeaders(responseCode, buf.length);
        OutputStream os = t.getResponseBody();
        os.write(buf);
        os.close();
    }
}


// *****************************************************************************
// ******* IPPermissionList ****************************************************
// *****************************************************************************
class IPPermissions {
    private byte ip[][] = { { 127, 0, 0, 1 } };
    private boolean deny[] = { false };
    private int mask[] = { 32 };
    
    public IPPermissions(String adrs) throws UnknownHostException,IllegalArgumentException {
	String strs[] = adrs.split(",");
	ip = new byte[strs.length][];
	deny = new boolean[strs.length];
	mask = new int[strs.length];
	for (int i=0; i<strs.length; i++ ) {
	    if ( strs[i].length()==0 ) throw new IllegalArgumentException( "Invalid address format at position " + (i+1) + ": empty string");
	    deny[i] = strs[i].charAt(0) == '-';
	    int start = deny[i] ? 1 : 0;
	    int end = strs[i].lastIndexOf("/");
	    if ( end < 0 ) end = strs[i].length();
	    ip[i] = InetAddress.getByName(strs[i].substring(start,end)).getAddress();
	    try {
		mask[i] = ( end+1 < strs[i].length() ) ? Integer.parseInt(strs[i].substring(end+1)) : ip[i].length*8;
	    }
	    catch (Exception e) {
		throw new IllegalArgumentException("Invalid mask format at position " + (i+1) + ": `" + strs[i].substring(end+1) + "'" );
	    }
	}
    }

    public IPPermissions() {
    }
    
    public boolean checkAddress ( byte rip[]) {
	boolean allow = false;
	for ( int i=0; i<ip.length; i++ ) {
	    if ( ip[i].length == rip.length ) {
		boolean eq = true;
	        for ( int j=0; j<rip.length; j++ ) {
	    	    int k = Math.max( (j+1)*8-mask[i], 0);
	    	    eq = eq && ( (ip[i][j] & 255)>>k == (rip[j] & 255)>>k );
	    	}
	    	if ( eq ) allow = ! deny[i];
	    }
	}
	return allow;
    }

    public boolean checkAddress ( InetAddress adr ) {
	return checkAddress( adr.getAddress() );
    }
    
    public static String toString(byte ip[]) {
	StringBuilder sb = new StringBuilder();
	if ( ip.length<6 || (ip.length & 1) != 0 ) {
	    for (int i=0; i<ip.length; i++ ) {
		if (i>0) sb.append('.');
		sb.append(ip[i] & 255);
	    }
	}
	else {
	    for (int i=0; i+1<ip.length; i+=2 ) {
		if (i>0) sb.append(':');
		sb.append(Integer.toString( ((ip[i] & 255)<<8) | (ip[i+1] & 255), 16 ) );
	    }
	}
	
	return sb.toString();
    }

    public static String toString(InetAddress adr) {
	return toString( adr.getAddress() );
    }

    public String toString() {
	StringBuilder sb = new StringBuilder();
	for (int i=0; i<ip.length; i++ ) {
	    if (i>0) sb.append(',');
	    if (deny[i]) sb.append('-');
	    sb.append(toString(ip[i])+"/"+mask[i]);
	}
	return sb.toString();
    }
}

// *****************************************************************************
// ******* EPDescriptor ********************************************************
// *****************************************************************************
class EPDescriptor {
    private boolean in, bulk;
    public int num;
    public int size;
    
    public EPDescriptor ( boolean p_in, int p_num, boolean p_bulk, int p_size ) {
	in = p_in;
	num = p_num;
	bulk = p_bulk;
	size = p_size;
//	System.out.println((in ? "IN" : "OUT" ) + " EP "+num + ": " + (bulk ? "BULK" : "INT" ) + ", " + size);
    }
    
    public boolean in () {
	return in;
    }
    
    public int num () {
	return num;
    }
    
    public boolean bulk () {
	return bulk;
    }

    public int size () {
	return size;
    }
}
    
// *****************************************************************************
// ******* EPDescriptorVector **************************************************
// *****************************************************************************
class EPDescriptorVector extends Vector<EPDescriptor> { 
    public EPDescriptor find(int num) {
	for (int i=0; i<size(); i++) {
	    if ( elementAt(i).num() == num ) return elementAt(i);
	}
	return null;
    }
}

// *****************************************************************************
// ******* DeviceServer ********************************************************
// *****************************************************************************
class DeviceServer {
    public static final int maxConnections = 128;
    public final static SimpleDateFormat msgDateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");

    public static int usbVendorId = ZtexDevice1.ztexVendorId;
    public static int usbProductId = -1;
    public static boolean cypress = true;
    public static int httpPort = 9080;
    public static int socketPort = 9081;
    public static boolean quit = false;
    
    private static Vector<Socket> socketVector = new Vector<Socket>();
    private static boolean verbose = false;
    private static boolean quiet = false;
    private static PrintStream logFile = null;
    private static PrintStream log2File = null;
    
    private static IPPermissions httpPermissions = new IPPermissions();
    private static IPPermissions socketPermissions = new IPPermissions();
    private static String httpBind = null, socketBind = null;
    
    private static ZtexScanBus1 scanBus;
    private static int busIdx[];
    private static int devNum[];
    private static int confNum[];
    private static EPDescriptorVector eps[];
    private static Vector<String> dirnameDB = new Vector<String>();

// ******* addSocket ***********************************************************
    public synchronized static void addSocket( Socket socket ) {
        info( "Connection from " + IPPermissions.toString( socket.getInetAddress() ) + " established" );
	socketVector.addElement(socket);
    }

// ******* removeSocket ********************************************************
    public synchronized static void removeSocket(Socket socket) {
        info( "Connection from " + IPPermissions.toString( socket.getInetAddress() ) + " closed" );
	socketVector.remove(socket);
    }

// ******* httpPermissions *****************************************************
    public static IPPermissions httpPermissions() {
	return httpPermissions;
    }
    
// ******* sleep ***************************************************************
    public static void sleep(int ms) {
	try {
	    Thread.sleep(ms);
        }
	catch ( InterruptedException e ) {
	}
    }

// ******* info ****************************************************************
    public synchronized static void info (String msg) {
	if ( verbose ) System.err.println( msg );
	if ( log2File != null ) log2File.println( msgDateFormat.format(new Date()) + ": " + msg );
    }

// ******* error ***************************************************************
    public synchronized static void error (String msg) {
	if ( ! quiet ) System.err.println( msg );
	if ( logFile != null ) logFile.println( msgDateFormat.format(new Date()) + ": " + msg );
	if ( log2File != null ) log2File.println( msgDateFormat.format(new Date()) + ": " + msg );
    }

// ******* getDirnameNum *******************************************************
    public static int getDirnameIdx ( String dirname ) {
	if ( dirname == null ) return -1;
	for ( int i=0; i<dirnameDB.size(); i++ ) {
	    if ( dirname.equals(dirnameDB.elementAt(i)) ) return i;
	}
	dirnameDB.add(dirname);
	info("Found bus \"" +dirname + "\": assigned bus index " + (dirnameDB.size()-1));
	return dirnameDB.size()-1;
    }

// ******* scanUSB *************************************************************
    public synchronized static void scanUSB () {
	info("Scanning USB ...");
	scanBus = new ZtexScanBus1( usbVendorId, usbProductId, cypress, false, 1 );
	int n = scanBus.numberOfDevices();
	if ( n > 0 ) {
	    busIdx = new int[n];
	    devNum = new int[n];
	    confNum = new int[n];
	    eps = new EPDescriptorVector[n];
	    for ( int i=0; i<n; i++ ) {
		Usb_Device dev = scanBus.device(i).dev();
		busIdx[i] = getDirnameIdx( dev.getBus().getDirname() );
		devNum[i] = dev.getDevnum();
		confNum[i] = -1;
		eps[i] = new EPDescriptorVector();
		try {
		    if ( dev.getDescriptor().getBNumConfigurations() < 1 ) throw new Exception();
		    Usb_Config_Descriptor conf = dev.getConfig()[0];
		    confNum[i] = conf.getBConfigurationValue();
		    if ( conf.getBNumInterfaces() < 1 ) throw new Exception();
		    Usb_Interface iface = conf.getInterface()[0];
		    if ( iface.getNumAltsetting() < 1 ) throw new Exception();
		    Usb_Interface_Descriptor desc = iface.getAltsetting()[0];
		    if ( desc.getBNumEndpoints() < 1 ) throw new Exception();
		    Usb_Endpoint_Descriptor epd[] = desc.getEndpoint();
		    for ( int j=0; j<epd.length; j++ ) {
			int t = epd[j].getBmAttributes() & Usb_Endpoint_Descriptor.USB_ENDPOINT_TYPE_MASK;
			if ( t == Usb_Endpoint_Descriptor.USB_ENDPOINT_TYPE_BULK || t == Usb_Endpoint_Descriptor.USB_ENDPOINT_TYPE_INTERRUPT )
			    eps[i].addElement(new EPDescriptor( 
				    (epd[j].getBEndpointAddress() & Usb_Endpoint_Descriptor.USB_ENDPOINT_DIR_MASK) != 0,
				    epd[j].getBEndpointAddress() & Usb_Endpoint_Descriptor.USB_ENDPOINT_ADDRESS_MASK,
				    t == Usb_Endpoint_Descriptor.USB_ENDPOINT_TYPE_BULK,
				    epd[j].getWMaxPacketSize() 
				) );
		    }
		}
		catch (Exception e) {
		}
	    }
	}
    }

// ******* loadFirmware ********************************************************
    public synchronized static void loadFirmware ( Ztex1v1 ztex, StringBuilder messages, InputStream in, String inName, boolean force, boolean toVolatile, boolean toNonVolatile, boolean eraseEeprom ) throws Exception {
	if ( ztex == null ) return;
	eraseEeprom = eraseEeprom && (! toNonVolatile );
	if ( toVolatile || toNonVolatile ) {
	    if ( in == null ) throw new Exception("No firmware defined.");
	    ZtexIhxFile1 ihxFile = new ZtexIhxFile1( in, inName );
	    if ( toVolatile ) {
		long i = ztex.uploadFirmware( ihxFile, force );
		if ( messages != null ) messages.append("Firmware uploaded to volatile memory: "+i+"ms\n");
		}
	    if ( toNonVolatile ) {
		 long i = ztex.eepromUpload( ihxFile, force );
		if ( messages != null ) messages.append("Firmware uploaded to non-volatile memory: "+i+"ms\n");
	    }
	}
	if ( eraseEeprom ) {
	    ztex.eepromDisable();
	    if ( messages != null ) messages.append("Firmware in non-volatile memory disabled\n");
	}
    }

// ******* loadBitstream *******************************************************
    public synchronized static void loadBitstream ( Ztex1v1 ztex, StringBuilder messages, byte[] buf, String inName, boolean force, boolean toVolatile, boolean toNonVolatile, boolean eraseFlash ) throws Exception {
	if ( ztex == null ) return;
	eraseFlash = eraseFlash && (! toNonVolatile );
	if ( toVolatile || toNonVolatile ) {
	    if ( buf == null ) throw new Exception("No firmware defined.");
	    if ( toVolatile ) {
		long i = ztex.configureFpga( new ByteArrayInputStream(buf), force, -1 );
		if ( messages != null ) messages.append("Bitstream uploaded to volatile memory: "+i+"ms\n");
		}
	    if ( toNonVolatile ) {
		long i = ztex.flashUploadBitstream( new ByteArrayInputStream(buf), -1 );
		if ( messages != null ) messages.append("Bitstream uploaded to non-volatile memory: "+i+"ms\n");
	    }
	}
	if ( eraseFlash ) {
	    ztex.flashResetBitstream();
	    if ( messages != null ) messages.append("Bitstream in non-volatile memory disabled\n");
	}
    }

    public synchronized static void loadBitstream ( Ztex1v1 ztex, StringBuilder messages, InputStream in, String inName, boolean force, boolean toVolatile, boolean toNonVolatile, boolean eraseFlash ) throws Exception {
	byte buf[] = new byte[65536];
	ByteArrayOutputStream out = new ByteArrayOutputStream();
	int i;
	do {
	    i=in.read(buf);
	    if (i>0) out.write(buf,0,i);
	} while (i>0);
	loadBitstream(ztex, messages, out.toByteArray(), inName, force, toVolatile, toNonVolatile, eraseFlash);
    }

// ******* claim ***************************************************************
    public synchronized static void claim ( Ztex1v1 ztex, StringBuilder messages ) {
	int c = 1;
	for (int i=0; i<scanBus.numberOfDevices(); i++ ) {
	    if ( scanBus.device(i) == ztex.dev() ) {
		c=confNum[i];
	    }
	}
	try {
	    ztex.setConfiguration(c);
	}
	catch ( UsbException e ) {
	    if (messages!=null) messages.append("Warning: "+e.getLocalizedMessage()+'\n');
	}

	try {
	    ztex.claimInterface(0);
	}
	catch ( UsbException e ) {
	    if (messages!=null) messages.append("Warning: "+e.getLocalizedMessage()+'\n');
	}
    }

// ******* release *************************************************************
    public synchronized static void release ( Ztex1v1 ztex ) {
	if (ztex!=null) ztex.releaseInterface(0);
    }

// ******* epUpload ************************************************************
    public synchronized static void epUpload ( Ztex1v1 ztex, EPDescriptor ep, InputStream in, StringBuilder messages ) throws Exception {
	if ( ztex == null ) return;
	if ( ep == null || ep.in() ) throw new UsbException(ztex.dev().dev(), "No valid endpoint defined");
	
	claim(ztex,messages);
	
	int bufSize = ep.num()==1 ? 64 : 256*1024;
	byte buf[] = new byte[bufSize];
	int r,i;
	do {
	    i = r = Math.max(in.read(buf),0);
	    if ( i>0 ) i = ep.bulk() ? LibusbJava.usb_bulk_write(ztex.handle(), ep.num, buf, r, 1000) : LibusbJava.usb_interrupt_write(ztex.handle(), ep.num, buf, r, 1000);
	} while (r>0 && r==i);

	if (i<0) throw new UsbException("Write error: " + LibusbJava.usb_strerror());
	if ( r!=i ) throw new UsbException("Write error: wrote " + i + " bytes instead of " + r + " bytes");
    }

// ******* epDownload **********************************************************
    public synchronized static void epDownload ( Ztex1v1 ztex, EPDescriptor ep, OutputStream out, int maxSize, StringBuilder messages ) throws Exception {
	if ( ztex == null ) return;
	if ( ep == null || ! ep.in() ) throw new UsbException(ztex.dev().dev(), "No valid endpoint defined");
	if ( maxSize < 1 ) maxSize = Integer.MAX_VALUE;
	
	claim(ztex,messages);
	
	int bufSize = ep.num()==1 ? 64 : 256*1024;
	byte buf[] = new byte[bufSize];
	int r,i;
	int j=0;
	do {
	    r = Math.min(bufSize,maxSize);
	    maxSize-=r;
	    i = ep.bulk() ? LibusbJava.usb_bulk_read(ztex.handle(), 0x80 | ep.num, buf, r, j==0 ? 5000 : 1000) : LibusbJava.usb_interrupt_read(ztex.handle(), 0x80 | ep.num, buf, r, 1000);
	    if (i>0) out.write(buf,0,i);
//	    System.out.println("r: "+i);
	    j++;
	} while (maxSize>0 && r==i);

	if (i<0) throw new UsbException("Read error: " + LibusbJava.usb_strerror());
    }

// ******* numberOfDevices *****************************************************
    public synchronized static int numberOfDevices() {
	return scanBus.numberOfDevices();
    }

// ******* device **************************************************************
    public synchronized static ZtexDevice1 device (int i) throws IndexOutOfBoundsException {
	return scanBus.device(i);
    }

// ******* findDevice **********************************************************
    public synchronized static ZtexDevice1 findDevice (int b, int d) {
	int n = numberOfDevices();
	for ( int i=0; i<n; i++ ) {
	    try {
	        if ( busIdx[i]==b && devNum[i]==d ) return scanBus.device(i);
	    } catch ( IndexOutOfBoundsException e ) {
	    }
	}
	return null;
    }

// ******* busIdx **************************************************************
    public synchronized static int busIdx (int i) throws IndexOutOfBoundsException {
	if ( i<0 || i>=busIdx.length) throw new IndexOutOfBoundsException( "Device number out of range. Valid numbers are 0.." + (busIdx.length-1) ); 
	return busIdx[i];
    }

// ******* devNum **************************************************************
    public synchronized static int devNum (int i) throws IndexOutOfBoundsException {
	if ( i<0 || i>=devNum.length) throw new IndexOutOfBoundsException( "Device number out of range. Valid numbers are 0.." + (devNum.length-1) ); 
	return devNum[i];
    }

// ******* getEps  *************************************************************
    public synchronized static EPDescriptorVector getEps (int b, int d) {
	int n = numberOfDevices();
	for ( int i=0; i<n; i++ ) {
	    try {
	        if ( busIdx[i]==b && devNum[i]==d ) return eps[i];
	    } catch ( IndexOutOfBoundsException e ) {
	    }
	}
	return null;
    }

// ******* main ****************************************************************
    public static void main (String args[]) {
	LibusbJava.usb_init();

	final String helpMsg = new String (
			"Global parameters:\n"+
			"    -nc              Do not scan for Cypress EZ-USB devices without ZTEX firmware\n"+
			"    -id <VID> <PID>  Scan for devices with given Vendor ID and Product ID\n"+
			"    -sp <port>       Port number for the socket interface (default: 9081; <0: disabled)\n"+
			"    -hp <port>       Port number for the HTTP interface (default: 9080; <0: disabled)\n"+
			"    -sa [-]<address>[/<mask>][,...]  Allow (permit if '-' is given) HTTP connection from this address(es),\n"+
			"                     <mask> 24 is equivalent to 255.255.255.0, default: 127.0.0.1\n"+
			"    -ha [-]<address>[/<mask>][,...]  Allow (permit if '-' is given) HTTP connection from this address(es),\n"+
			"                     <mask> 24 is equivalent to 255.255.255.0, default: 127.0.0.1\n"+
			"    -sb <address>    Bind socket server to this address (default: listen on all interfaces)\n"+
			"    -hb <address>    Bind HTTP server to this address (default: listen on all interfaces)\n"+
			"    -v               Be verbose\n"+
			"    -q               Be quiet\n"+
			"    -l               Log file\n"+
			"    -l2              Verbose log file\n"+
			"    -h               Help" );
			
// process parameters
	try {

	    for (int i=0; i<args.length; i++ ) {
		if ( args[i].equals("-nc") ) {
		    cypress = false;
		}
		else if ( args[i].equals("-id") ) {
		    i++;
		    try {
			if (i>=args.length) 
			    throw new Exception();
    			usbVendorId = Integer.decode( args[i] );
		    } 
		    catch (Exception e) {
			System.err.println("Error: Vendor ID expected after -id");
			System.err.println(helpMsg);
			System.exit(1);
		    }
		    i++;
		    try {
			if (i>=args.length) 
			    throw new Exception();
    			usbProductId = Integer.decode( args[i] );
		    } 
		    catch (Exception e) {
			System.err.println("Error: Product ID expected after -id <VID>");
			System.err.println(helpMsg);
			System.exit(1);
		    }
		}
		else if ( args[i].equals("-hp") ) {
		    i++;
		    try {
			if (i>=args.length) 
			    throw new Exception();
    			httpPort = Integer.parseInt( args[i] );
		    } 
		    catch (Exception e) {
			System.err.println("Error: Port number expected after -hp");
			System.err.println(helpMsg);
			System.exit(1);
		    }
		}
		else if ( args[i].equals("-sp") ) {
		    i++;
		    try {
			if (i>=args.length) 
			    throw new Exception();
    			socketPort = Integer.parseInt( args[i] );
		    } 
		    catch (Exception e) {
			System.err.println("Error: Port number expected after -sp");
			System.err.println(helpMsg);
			System.exit(1);
		    }
		}
		else if ( args[i].equals("-ha") ) {
		    i++;
		    try {
			if (i>=args.length) 
			    throw new Exception("Argument expected after -ha");
    			httpPermissions = new IPPermissions( args[i] );
		    } 
		    catch (Exception e) {
			System.err.println("Error parsing HTTP permissions:");
			System.exit(1);
		    }
		}
		else if ( args[i].equals("-sa") ) {
		    i++;
		    try {
			if (i>=args.length) 
			    throw new Exception("Argument expected after -hs");
    			socketPermissions = new IPPermissions( args[i] );
		    } 
		    catch (Exception e) {
			System.err.println("Error parsing socket permissions:");
			System.exit(1);
		    }
		}
		else if ( args[i].equals("-hb") ) {
		    i++;
		    try {
			if (i>=args.length) 
			    throw new Exception("Argument expected after -hb");
    			httpBind = args[i];
		    } 
		    catch (Exception e) {
			System.err.println("Error parsing HTTP permissions:");
			System.exit(1);
		    }
		}
		else if ( args[i].equals("-sb") ) {
		    i++;
		    try {
			if (i>=args.length) 
			    throw new Exception("Argument expected after -sb");
    			socketBind = args[i];
		    } 
		    catch (Exception e) {
			System.err.println("Error parsing HTTP permissions:");
			System.exit(1);
		    }
		}
		else if ( args[i].equals("-hb") ) {
		    i++;
		    try {
			if (i>=args.length) 
			    throw new Exception("Argument expected after -hb");
    			httpBind = args[i];
		    } 
		    catch (Exception e) {
			System.err.println("Error parsing HTTP permissions:");
			System.exit(1);
		    }
		}
		else if ( args[i].equals("-v") ) {
		    verbose = true;
		}
		else if ( args[i].equals("-q") ) {
		    quiet = true;
		}
		else if ( args[i].equals("-l") ) {
		    i++;
		    if (i>=args.length) {
			System.err.println("Error: File name expected after `-l'");
			System.err.println(helpMsg);
			System.exit(1);
		    }
		    try {
			logFile = new PrintStream ( new FileOutputStream ( args[i], true ), true );
		    } 
		    catch (Exception e) {
			System.err.println("Error: File name expected after `-l': "+e.getLocalizedMessage() );
			System.err.println(helpMsg);
			System.exit(1); 
		    }
		}
		else if ( args[i].equals("-l2") ) {
		    i++;
		    if (i>=args.length) {
			System.err.println("Error: File name expected after `-l2'");
			System.err.println(helpMsg);
			System.exit(1);
		    }
		    try {
			log2File = new PrintStream ( new FileOutputStream ( args[i], true ), true );
		    } 
		    catch (Exception e) {
			System.err.println("Error: File name expected after `-l2': "+e.getLocalizedMessage() );
			System.err.println(helpMsg);
			System.exit(1);
		    }
		}
		else if ( args[i].equals("-h") ) {
		    System.err.println(helpMsg);
		    System.exit(0);
		}
		else {
		    System.err.println("Error: Invalid option: `"+args[i]+"'");
		    System.err.println(helpMsg);
		    System.exit(1);
		}
	    }

	    if ( httpPort < 0 && socketPort < 0 ) {
		error("neither HTTP nor socket interface enabled: exiting");
		System.exit(0);
	    }

// init USB stuff
	    LibusbJava.usb_init();
	    LibusbJava.usb_find_busses();
	    Usb_Bus bus = LibusbJava.usb_get_busses();
    	    while ( bus != null ) {
		getDirnameIdx(bus.getDirname());
		bus = bus.getNext();
	    }
	    scanUSB();

// start http server
	    HttpServer httpServer = null;
	    if ( httpPort > 0 ) {
		error ( "Listening for http connections at port " + httpPort + " from addresses " + httpPermissions ); // not really an error
    		httpServer = HttpServer.create( ( httpBind == null ) ? new InetSocketAddress(httpPort) : new InetSocketAddress(InetAddress.getByName(httpBind),httpPort), 0);
    		httpServer.createContext("/", new ZtexHttpHandler());
    		httpServer.setExecutor(null);
    		httpServer.start();
    	    }

// run socket server
	    if ( socketPort > 0 ) {
		error ( "Listening for socket connections at port " + socketPort + " from addresses " + socketPermissions ); // not really an error
		ServerSocket ss = (socketBind == null) ?  new ServerSocket ( socketPort, 20 ) : new ServerSocket ( socketPort, 20,  InetAddress.getByName(socketBind));
		ss.setSoTimeout(500);
		while ( ! quit ) {
		    if ( socketVector.size() < maxConnections ) {
			try {
			    Socket cs = ss.accept();
			    if ( socketPermissions.checkAddress( cs.getInetAddress() ) ) {
				new SocketThread( cs );
			    }
			    else {
    				info( "Connection from " + IPPermissions.toString( cs.getInetAddress() ) + " refused" );
			    }
			}
			catch ( SocketTimeoutException e ) {
			}
		    }
		    else {
			sleep(1000);
		    }
		}
	    }
	    else {
		while ( ! quit ) {
		    sleep(1000);
		}
	    }

// stop http server
	    if ( httpServer!=null ) httpServer.stop(1);
	    
	} 
	catch (Exception e) {
	    error("Error: "+e.getLocalizedMessage() );
	}  
   } 
   
}
