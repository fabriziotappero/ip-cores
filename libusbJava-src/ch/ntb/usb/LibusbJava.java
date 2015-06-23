/* 
 * Java libusb wrapper
 * Copyright (c) 2005-2006 Andreas Schläpfer <spandi at users.sourceforge.net>
 *
 * http://libusbjava.sourceforge.net
 * This library is covered by the LGPL, read LGPL.txt for details.
 */
package ch.ntb.usb;

/**
 * This class represents the Java Native Interface to the shared library which
 * is (with some exceptions) a one-to-one representation of the libusb API.<br>
 * <br>
 * <h1>Project Description</h1>
 * Java libusb is a Java wrapper for the libusb and libusb-win32 USB library.
 * 
 * <a href="http://libusb.sourceforge.net/">libusb</a> aim is to create a
 * library for use by user level applications to access USB devices regardless
 * of OS.<br>
 * <a href="http://libusb-win32.sourceforge.net/">Libusb-win32</a> is a port of
 * the USB library <a href="http://libusb.sourceforge.net/">libusb</a> to the
 * Windows operating systems. The library allows user space applications to
 * access any USB device on Windows in a generic way without writing any line of
 * kernel driver code.<br>
 * <br>
 * The API description of this class has been copied from the <a
 * href="http://libusb.sourceforge.net/documentation.html">libusb documentation</a>
 * and adapted where neccessary.<br>
 * 
 */
public class LibusbJava {

	/**
	 * System error codes.<br>
	 * This list is not complete! For more error codes see the file 'errorno.h'
	 * on your system.
	 */
	public static int ERROR_SUCCESS, ERROR_BAD_FILE_DESCRIPTOR,
			ERROR_NO_SUCH_DEVICE_OR_ADDRESS, ERROR_BUSY,
			ERROR_INVALID_PARAMETER, ERROR_TIMEDOUT, ERROR_IO_ERROR,
			ERROR_NOT_ENOUGH_MEMORY;;

	/**
	 * Sets the debugging level of libusb.<br>
	 * 
	 * The range is from 0 to 255, where 0 disables debug output and 255 enables
	 * all output. On application start, debugging is disabled (0).
	 * 
	 * @param level
	 *            0 to 255
	 */
	public static native void usb_set_debug(int level);

	// Core
	/**
	 * Just like the name implies, <code>usb_init</code> sets up some internal
	 * structures. <code>usb_init</code> must be called before any other
	 * libusb functions.
	 */
	public static native void usb_init();

	/**
	 * <code>usb_find_busses</code> will find all of the busses on the system.
	 * 
	 * @return the number of changes since previous call to this function (total
	 *         of new busses and busses removed).
	 */
	public static native int usb_find_busses();

	/**
	 * <code>usb_find_devices</code> will find all of the devices on each bus.
	 * This should be called after <code>usb_find_busses</code>.
	 * 
	 * @return the number of changes since the previous call to this function
	 *         (total of new device and devices removed).
	 */
	public static native int usb_find_devices();

	/**
	 * <code>usb_get_busses</code> returns a tree of descriptor objects.<br>
	 * The tree represents the bus structure with devices, configurations,
	 * interfaces and endpoints. Note that this is only a copy. To refresh the
	 * information, <code>usb_get_busses()</code> must be called again.<br>
	 * The name of the objects contained in the tree is starting with
	 * <code>Usb_</code>.
	 * 
	 * @return the structure of all busses and devices. <code>Note:</code> The
	 *         java objects are copies of the C structs.
	 */
	public static native Usb_Bus usb_get_busses();

	// Device Operations
	/**
	 * <code>usb_open</code> is to be used to open up a device for use.
	 * <code>usb_open</code> must be called before attempting to perform any
	 * operations to the device.
	 * 
	 * @param dev
	 *            The device to open.
	 * @return a handle used in future communication with the device. 0 if an
	 *         error has occurred.
	 */
	public static native long usb_open(Usb_Device dev);

	/**
	 * <code>usb_close</code> closes a device opened with
	 * <code>usb_open</code>.
	 * 
	 * @param dev_handle
	 *            The handle to the device.
	 * @return 0 on success or < 0 on error.
	 */
	public static native int usb_close(long dev_handle);

	/**
	 * Sets the active configuration of a device
	 * 
	 * @param dev_handle
	 *            The handle to the device.
	 * @param configuration
	 *            The value as specified in the descriptor field
	 *            bConfigurationValue.
	 * @return 0 on success or < 0 on error.
	 */
	public static native int usb_set_configuration(long dev_handle,
			int configuration);

	/**
	 * Sets the active alternate setting of the current interface
	 * 
	 * @param dev_handle
	 *            The handle to the device.
	 * @param alternate
	 *            The value as specified in the descriptor field
	 *            bAlternateSetting.
	 * @return 0 on success or < 0 on error.
	 */
	public static native int usb_set_altinterface(long dev_handle, int alternate);

	/**
	 * Clears any halt status on an endpoint.
	 * 
	 * @param dev_handle
	 *            The handle to the device.
	 * @param ep
	 *            The value specified in the descriptor field bEndpointAddress.
	 * @return 0 on success or < 0 on error.
	 */
	public static native int usb_clear_halt(long dev_handle, int ep);

	/**
	 * Resets a device by sending a RESET down the port it is connected to.<br>
	 * <br>
	 * <b>Causes re-enumeration:</b> After calling <code>usb_reset</code>,
	 * the device will need to re-enumerate and thusly, requires you to find the
	 * new device and open a new handle. The handle used to call
	 * <code>usb_reset</code> will no longer work.
	 * 
	 * @param dev_handle
	 *            The handle to the device.
	 * @return 0 on success or < 0 on error.
	 */
	public static native int usb_reset(long dev_handle);

	/**
	 * Claim an interface of a device.<br>
	 * <br>
	 * <b>Must be called!:</b> <code>usb_claim_interface</code> must be
	 * called before you perform any operations related to this interface (like
	 * <code>usb_set_altinterface, usb_bulk_write</code>, etc).
	 * 
	 * @param dev_handle
	 *            The handle to the device.
	 * @param interface_
	 *            The value as specified in the descriptor field
	 *            bInterfaceNumber.
	 * @return 0 on success or < 0 on error.
	 */
	public static native int usb_claim_interface(long dev_handle, int interface_);

	/**
	 * Releases a previously claimed interface
	 * 
	 * @param dev_handle
	 *            The handle to the device.
	 * @param interface_
	 *            The value as specified in the descriptor field
	 *            bInterfaceNumber.
	 * @return 0 on success or < 0 on error.
	 */
	public static native int usb_release_interface(long dev_handle,
			int interface_);

	// Control Transfers
	/**
	 * Performs a control request to the default control pipe on a device. The
	 * parameters mirror the types of the same name in the USB specification.
	 * 
	 * @param dev_handle
	 *            The handle to the device.
	 * @param requesttype
	 * @param request
	 * @param value
	 * @param index
	 * @param bytes
	 * @param size
	 * @param timeout
	 * @return the number of bytes written/read or < 0 on error.
	 */
	public static native int usb_control_msg(long dev_handle, int requesttype,
			int request, int value, int index, byte[] bytes, int size,
			int timeout);

	/**
	 * Retrieves the string descriptor specified by index and langid from a
	 * device.
	 * 
	 * @param dev_handle
	 *            The handle to the device.
	 * @param index
	 * @param langid
	 * @return the descriptor String or null
	 */
	public static native String usb_get_string(long dev_handle, int index,
			int langid);

	/**
	 * <code>usb_get_string_simple</code> is a wrapper around
	 * <code>usb_get_string</code> that retrieves the string description
	 * specified by index in the first language for the descriptor.
	 * 
	 * @param dev_handle
	 *            The handle to the device.
	 * @param index
	 * @return the descriptor String or null
	 */
	public static native String usb_get_string_simple(long dev_handle, int index);

	/**
	 * Retrieves a descriptor from the device identified by the type and index
	 * of the descriptor from the default control pipe.<br>
	 * <br>
	 * See {@link #usb_get_descriptor_by_endpoint(long, int, byte, byte, int)}
	 * for a function that allows the control endpoint to be specified.
	 * 
	 * @param dev_handle
	 *            The handle to the device.
	 * @param type
	 * @param index
	 * @param size
	 *            number of charactes which will be retrieved (the length of the
	 *            resulting String)
	 * @return the descriptor String or null
	 */
	public static native String usb_get_descriptor(long dev_handle, byte type,
			byte index, int size);

	/**
	 * Retrieves a descriptor from the device identified by the type and index
	 * of the descriptor from the control pipe identified by ep.
	 * 
	 * @param dev_handle
	 *            The handle to the device.
	 * @param ep
	 * @param type
	 * @param index
	 * @param size
	 *            number of charactes which will be retrieved (the length of the
	 *            resulting String)
	 * @return the descriptor String or null
	 */
	public static native String usb_get_descriptor_by_endpoint(long dev_handle,
			int ep, byte type, byte index, int size);

	// Bulk Transfers
	/**
	 * Performs a bulk write request to the endpoint specified by ep.
	 * 
	 * @param dev_handle
	 *            The handle to the device.
	 * @param ep
	 * @param bytes
	 * @param size
	 * @param timeout
	 * @return the number of bytes written on success or < 0 on error.
	 */
	public static native int usb_bulk_write(long dev_handle, int ep,
			byte[] bytes, int size, int timeout);

	/**
	 * Performs a bulk read request to the endpoint specified by ep.
	 * 
	 * @param dev_handle
	 *            The handle to the device.
	 * @param ep
	 * @param bytes
	 * @param size
	 * @param timeout
	 * @return the number of bytes read on success or < 0 on error.
	 */
	public static native int usb_bulk_read(long dev_handle, int ep,
			byte[] bytes, int size, int timeout);

	// Interrupt Transfers
	/**
	 * Performs an interrupt write request to the endpoint specified by ep.
	 * 
	 * @param dev_handle
	 *            The handle to the device.
	 * @param ep
	 * @param bytes
	 * @param size
	 * @param timeout
	 * @return the number of bytes written on success or < 0 on error.
	 */
	public static native int usb_interrupt_write(long dev_handle, int ep,
			byte[] bytes, int size, int timeout);

	/**
	 * Performs a interrupt read request to the endpoint specified by ep.
	 * 
	 * @param dev_handle
	 *            The handle to the device.
	 * @param ep
	 * @param bytes
	 * @param size
	 * @param timeout
	 * @return the number of bytes read on success or < 0 on error.
	 */
	public static native int usb_interrupt_read(long dev_handle, int ep,
			byte[] bytes, int size, int timeout);

	/**
	 * Returns the error string after an error occured.
	 * 
	 * @return the last error sring.
	 */
	public static native String usb_strerror();

	/** **************************************************************** */

	/**
	 * Maps the Java error code to the system error code.<br>
	 * <br>
	 * Note that not all error codes are be mapped by this method. For more
	 * error codes see the file 'errno.h' on your system.<br>
	 * <br>
	 * 1: EBADF: Bad file descriptor.<br>
	 * 2: ENXIO: No such device or address.<br>
	 * 3: EBUSY: Device or resource busy.<br>
	 * 4: EINVAL: Invalid argument.<br>
	 * 5: ETIMEDOUT: Connection timed out.<br>
	 * 6: EIO: I/O error.<br>
	 * 7: ENOMEM: Not enough memory.<br>
	 * 
	 * 
	 * @return the system error code or 100000 if no mapping has been found.
	 */
	private static native int usb_error_no(int value);

	static {
//		System.out.println("os.name: " + System.getProperty("os.name"));
//		System.out.println("os.arch: " + System.getProperty("os.arch"));
		String os = System.getProperty("os.name");
		if (os.contains("Windows")) {
		    if ( System.getProperty("os.arch").equalsIgnoreCase("amd64") ) {
	    		LibLoader.load( "libusbJava64" );
	    	    }
	    	    else {
	    		LibLoader.load( "libusbJava32" ); 
	    	    }
	    	}
		else {
		    try {
	    		LibLoader.load( "usbJava" );
//	    		System.err.println("loaded libusbJava");
	    	    }
	    	    catch ( UnsatisfiedLinkError e ) {
		        if ( System.getProperty("os.arch").equalsIgnoreCase("amd64") || System.getProperty("os.arch").equalsIgnoreCase("x86_64") ) {
	    		    LibLoader.load( "usbJava64" );
//	    		    System.err.println("loaded libusbJava64");
			}
			else {
			    try {
	    			LibLoader.load( "usbJavaSh" );
//	    			System.err.println("loaded libusbJavaSh");
	    		    }
	    		    catch ( UnsatisfiedLinkError e2 ) {
	    			LibLoader.load( "usbJavaSt" );
//	    			System.err.println("loaded libusbJavaSt");
			    }
			}
	    	    }
		}
		// define the error codes
		ERROR_SUCCESS = 0;
		ERROR_BAD_FILE_DESCRIPTOR = -usb_error_no(1);
		ERROR_NO_SUCH_DEVICE_OR_ADDRESS = -usb_error_no(2);
		ERROR_BUSY = -usb_error_no(3);
		ERROR_INVALID_PARAMETER = -usb_error_no(4);
		ERROR_TIMEDOUT = -usb_error_no(5);
		ERROR_IO_ERROR = -usb_error_no(6);
		ERROR_NOT_ENOUGH_MEMORY = -usb_error_no(7);
	}
}