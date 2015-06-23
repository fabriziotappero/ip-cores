/* 
 * library loader with the ability to load libraries as system resource (e.g. form the current .jar file)
 * Copyright (c) 2007-2009, ZTEX e.K.
 * http://www.ztex.de
 *
 * This library is covered by the LGPL, read LGPL.txt for details.
 */

package ch.ntb.usb;

import java.io.*;

/**
 * This class allows to load libraries in the normal way or as a system resource (e.g. form the current .jar file).
 * See below for a further description. <br>
 * 
 * @author Stefan Ziegenbalg
 * 
 */
public class LibLoader {

/**
 * Loads a library. This is done in three steps.<br>
 * 1. The library is tried to be load from the path list specified by the java.library.path property. <br>
 * 2. The library is tried to be load from the current directory. <br>
 * 3. The library is searched as a system resource (e.g. in the current .jar file), 
 * copied to to temporary directory and loaded from there. Afterwards the temporary library is deleted.
 * The copying is necessary because libraries can't be loaded directly from .jar files.<br>
 * 
 * @param libName Library name (e.g. usbJava)
 *
 * @throws UnsatisfiedLinkError
 * 
 */
    public static void load( String libName ) {
    
// Step 1: Normal way
	try {
	    System.loadLibrary( libName );
	}
	catch ( Throwable e1 ) {

// Step 2: From the current directory
	    String basename = System.mapLibraryName( libName );
	    try {
		System.load( System.getProperty("user.dir") + System.getProperty("file.separator") + basename );
	    }
	    catch ( Throwable e2 ) {
	    
// Step 2: As system ressource
		String libFileName = System.getProperty("java.io.tmpdir") + System.getProperty("file.separator") + basename;
    		try {
		    InputStream inputStream = ClassLoader.getSystemResourceAsStream( basename );
		    if ( inputStream == null ) {
			throw new Exception();
		    }
		    File libFile = new File( libFileName );

		    FileOutputStream outputStream = new FileOutputStream( libFile );

		    byte[] buf = new byte[65536];
		    int bytesRead = -1;
		    while ( (bytesRead = inputStream.read(buf)) > 0 ) {
			outputStream.write(buf, 0, bytesRead);
		    }
		    outputStream.close();
		    inputStream.close();
	
		    System.load( libFileName );

		    try {
			libFile.delete();
		    }
		    catch (Exception e3) {
//		    	System.err.println( "Warning: Cannot delete temporary library file `" + libFileName + "'" );
		    }
		}
		catch (Exception e3) {
		    throw new UnsatisfiedLinkError ("Library `"+basename+"' cannot be loaded as system resource, from current directory or from java.library.path   (java.library.path=" + System.getProperty("java.library.path")+")" );
		}
	    }
	}
   }
   
}
